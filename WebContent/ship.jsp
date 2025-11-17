<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>iGifUp Shipment Processing</title>
<link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">
        
<%@ include file="header.jsp" %>

<h1>Shipment Processing</h1>

<%
// Get order id from parameter
String orderIdParam = request.getParameter("orderId");

if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
    out.println("<p class='error'>No order ID provided.</p>");
    out.println("<h2><a href='listorder.jsp'>Back to Orders</a></h2>");
    return;
}

int orderId = 0;
try {
    orderId = Integer.parseInt(orderIdParam);
} catch (NumberFormatException e) {
    out.println("<p class='error'>Invalid order ID format.</p>");
    out.println("<h2><a href='listorder.jsp'>Back to Orders</a></h2>");
    return;
}

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";
Connection con = null;
int shipmentId = 0;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);
    
    // Check if valid order id in database
    String checkOrderSql = "SELECT orderId FROM ordersummary WHERE orderId = ?";
    PreparedStatement checkStmt = con.prepareStatement(checkOrderSql);
    checkStmt.setInt(1, orderId);
    ResultSet orderRs = checkStmt.executeQuery();
    
    if (!orderRs.next()) {
        out.println("<p class='error'>Order ID " + orderId + " does not exist.</p>");
        out.println("<h2><a href='listorder.jsp'>Back to Orders</a></h2>");
        orderRs.close();
        checkStmt.close();
        return;
    }
    orderRs.close();
    checkStmt.close();
    
    // Start transaction - turn off auto-commit
    con.setAutoCommit(false);
    
    out.println("<h2>Processing Order #" + orderId + "</h2>");
    
    // Retrieve all items in the order
    String getItemsSql = "SELECT productId, quantity FROM orderproduct WHERE orderId = ?";
    PreparedStatement itemsStmt = con.prepareStatement(getItemsSql);
    itemsStmt.setInt(1, orderId);
    ResultSet itemsRs = itemsStmt.executeQuery();
    
    java.util.ArrayList<int[]> orderItems = new java.util.ArrayList<int[]>();
    while (itemsRs.next()) {
        int[] item = new int[2];
        item[0] = itemsRs.getInt("productId");  // productId
        item[1] = itemsRs.getInt("quantity");   // quantity
        orderItems.add(item);
    }
    itemsRs.close();
    itemsStmt.close();
    
    if (orderItems.isEmpty()) {
        out.println("<p class='error'>No items found in this order.</p>");
        con.rollback();
        out.println("<h2><a href='listorder.jsp'>Back to Orders</a></h2>");
        return;
    }
    
    // Check inventory for all items before making any changes
    boolean canShip = true;
    String inventoryError = "";
    
    for (int[] item : orderItems) {
        int productId = item[0];
        int quantityNeeded = item[1];
        
        // Check warehouse 1 for this product
        String checkInventorySql = "SELECT quantity, productId FROM productinventory " +
                                   "WHERE productId = ? AND warehouseId = 1";
        PreparedStatement invStmt = con.prepareStatement(checkInventorySql);
        invStmt.setInt(1, productId);
        ResultSet invRs = invStmt.executeQuery();
        
        if (!invRs.next()) {
            canShip = false;
            inventoryError = "Product ID " + productId + " not found in warehouse.";
            invRs.close();
            invStmt.close();
            break;
        }
        
        int currentQuantity = invRs.getInt("quantity");
        invRs.close();
        invStmt.close();
        
        if (currentQuantity < quantityNeeded) {
            canShip = false;
            inventoryError = "Insufficient inventory for product ID " + productId + 
                           ". Needed: " + quantityNeeded + ", Available: " + currentQuantity;
            break;
        }
    }
    
    // If we can't ship, rollback and show error
    if (!canShip) {
        con.rollback();
        out.println("<p class='error'><strong>Shipment Failed:</strong> " + inventoryError + "</p>");
        out.println("<h2><a href='listorder.jsp'>Back to Orders</a></h2>");
        return;
    }
    
    // All items have sufficient inventory - create shipment record
    String createShipmentSql = "INSERT INTO shipment (shipmentDate, shipmentDesc, warehouseId) " +
                              "VALUES (GETDATE(), ?, 1)";
    PreparedStatement shipStmt = con.prepareStatement(createShipmentSql, Statement.RETURN_GENERATED_KEYS);
    shipStmt.setString(1, "Order #" + orderId);
    shipStmt.executeUpdate();
    
    ResultSet keys = shipStmt.getGeneratedKeys();
    if (keys.next()) {
        shipmentId = keys.getInt(1);
    }
    keys.close();
    shipStmt.close();
    
    out.println("<p class='success'>Created shipment record #" + shipmentId + "</p>");
    out.println("<h3>Processing Items:</h3>");
    out.println("<table>");
    out.println("<tr><th>Product ID</th><th>Quantity Ordered</th><th>Previous Inventory</th><th>New Inventory</th></tr>");
    
    // Update inventory for each item
    for (int[] item : orderItems) {
        int productId = item[0];
        int quantityShipped = item[1];
        
        // Get current inventory
        String getCurrentInvSql = "SELECT quantity FROM productinventory " +
                                 "WHERE productId = ? AND warehouseId = 1";
        PreparedStatement getCurrentStmt = con.prepareStatement(getCurrentInvSql);
        getCurrentStmt.setInt(1, productId);
        ResultSet currentInvRs = getCurrentStmt.executeQuery();
        currentInvRs.next();
        int previousInventory = currentInvRs.getInt("quantity");
        currentInvRs.close();
        getCurrentStmt.close();
        
        // Update inventory
        String updateInventorySql = "UPDATE productinventory SET quantity = quantity - ? " +
                                   "WHERE productId = ? AND warehouseId = 1";
        PreparedStatement updateStmt = con.prepareStatement(updateInventorySql);
        updateStmt.setInt(1, quantityShipped);
        updateStmt.setInt(2, productId);
        updateStmt.executeUpdate();
        updateStmt.close();
        
        int newInventory = previousInventory - quantityShipped;
        
        out.println("<tr>");
        out.println("<td>" + productId + "</td>");
        out.println("<td>" + quantityShipped + "</td>");
        out.println("<td>" + previousInventory + "</td>");
        out.println("<td>" + newInventory + "</td>");
        out.println("</tr>");
    }
    
    out.println("</table>");
    
    // Commit the transaction
    con.commit();
    out.println("<p class='success'><strong>Order #" + orderId + " shipped successfully!</strong></p>");
    
} catch (SQLException e) {
    // Rollback on any error
    if (con != null) {
        try {
            con.rollback();
            out.println("<p class='error'><strong>Transaction rolled back due to error:</strong> " + 
                       e.getMessage() + "</p>");
        } catch (SQLException ex) {
            out.println("<p class='error'>Error during rollback: " + ex.getMessage() + "</p>");
        }
    }
    e.printStackTrace();
} catch (Exception e) {
    out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
} finally {
    // Turn auto-commit back on
    if (con != null) {
        try {
            con.setAutoCommit(true);
            con.close();
        } catch (SQLException e) {
            out.println("<p class='error'>Error closing connection: " + e.getMessage() + "</p>");
        }
    }
}
%>

<h2><a href="listorder.jsp">Back to Orders</a></h2>

</div>
</body>
</html>