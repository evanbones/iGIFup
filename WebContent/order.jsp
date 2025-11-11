<%@ page import="java.sql.*, java.text.NumberFormat, java.util.HashMap, java.util.Iterator, java.util.ArrayList, java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>YOUR NAME Grocery Order Processing</title>
</head>
<body>

<% 
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

double totalOrderAmount = 0.0;
int orderId = 0;
Connection con = null;

try {
    // get customer id 
    String custId = request.getParameter("customerId");
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    // show error message if shopping cart is empty
    if (productList == null || productList.isEmpty()) {
        out.println("<h1>Error</h1>");
        out.println("<p>Your shopping cart is empty. Please <a href='listprod.jsp'>continue shopping</a>.</p>");
        return; // Stop processing the page
    }
    
    // validate customer's id
    int numericCustId = 0;
    if (custId == null || custId.trim().isEmpty()) {
        out.println("<h1>Error</h1>");
        out.println("<p>You must enter a customer ID.</p>");
        return;
    }
    
    try {
        numericCustId = Integer.parseInt(custId);
    } catch (NumberFormatException e) {
        out.println("<h1>Error</h1>");
        out.println("<p>Customer ID must be a valid number.</p>");
        return;
    }

    // SQL Server connection
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // customer id exists in the database.
    String sqlValidateCust = "SELECT customerId FROM customer WHERE customerId = ?";
    boolean customerExists = false;
    
    try (PreparedStatement pstmtCust = con.prepareStatement(sqlValidateCust)) {
        pstmtCust.setInt(1, numericCustId);
        try (ResultSet rsCust = pstmtCust.executeQuery()) {
            if (rsCust.next()) {
                customerExists = true;
            }
        }
    }

    if (!customerExists) {
        out.println("<h1>Error</h1>");
        out.println("<p>Customer ID " + numericCustId + " does not exist in our records.</p>");
        return;
    }
    
    // if we get here, the customer ID is valid and the cart is not empty
    
    // start a transaction - all operations must work or none are executed
    con.setAutoCommit(false);
    
    // insert into ordersummary table and retrieve auto-generated id
    String sqlInsertOrder = "INSERT INTO orderSummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), ?)";
    
    // insert with a total of 0.0 and will update it later.
    try (PreparedStatement pstmt = con.prepareStatement(sqlInsertOrder, Statement.RETURN_GENERATED_KEYS)) {
        pstmt.setInt(1, numericCustId);
        pstmt.setDouble(2, 0.0); // Placeholder total
        pstmt.executeUpdate();
        
        ResultSet keys = pstmt.getGeneratedKeys();
        if (keys.next()) {
            orderId = keys.getInt(1);
        } else {
            throw new SQLException("Failed to retrieve new orderId.");
        }
    }

    // Traverse list of products and store each in orderproduct table
    String sqlInsertProduct = "INSERT INTO orderProduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
    
    try (PreparedStatement pstmtProd = con.prepareStatement(sqlInsertProduct)) {
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
            int productId = Integer.parseInt((String) product.get(0));
            double price = Double.parseDouble((String) product.get(2)); 
            int qty = ((Integer) product.get(3)).intValue();
            
            totalOrderAmount += (price * qty);

            pstmtProd.setInt(1, orderId);
            pstmtProd.setInt(2, productId);
            pstmtProd.setInt(3, qty);
            pstmtProd.setDouble(4, price);
            
            pstmtProd.executeUpdate(); // Insert this product
        }
    } 

    // update total amount for the order in OrderSummary table
    String sqlUpdateTotal = "UPDATE orderSummary SET totalAmount = ? WHERE orderId = ?";
    try (PreparedStatement pstmtUpdate = con.prepareStatement(sqlUpdateTotal)) {
        pstmtUpdate.setDouble(1, totalOrderAmount);
        pstmtUpdate.setInt(2, orderId);
        pstmtUpdate.executeUpdate();
    }
    
    // if all database operations were successful, commit the transaction
    con.commit();
    
    // display the order information
    out.println("<h1>Order Complete</h1>");
    out.println("<p>Thank you! Your order has been placed.</p>");
    out.println("<p><b>Order ID:</b> " + orderId + "</p>");
    out.println("<p><b>Customer ID:</b> " + numericCustId + "</p>");
    out.println("<h3>Order Details:</h3>");
    
    out.println("<table border='1' cellpadding='5'>");
    out.println("<tr><th>Product Name</th><th>Quantity</th><th>Price</th><th>Subtotal</th></tr>");
    
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    
    // iterate again to print the summary
    Iterator<Map.Entry<String, ArrayList<Object>>> displayIterator = productList.entrySet().iterator();
    while (displayIterator.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = displayIterator.next();
        ArrayList<Object> product = (ArrayList<Object>) entry.getValue();

        String name = (String) product.get(1); 
        double price = Double.parseDouble((String) product.get(2));
        int qty = ((Integer) product.get(3)).intValue();
        double subtotal = price * qty;

        out.println("<tr>");
        out.println("<td>" + name + "</td>");
        out.println("<td>" + qty + "</td>");
        out.println("<td>" + currFormat.format(price) + "</td>");
        out.println("<td>" + currFormat.format(subtotal) + "</td>");
        out.println("</tr>");
    }
    
    out.println("</table>");
    out.println("<h3>Order Total: " + currFormat.format(totalOrderAmount) + "</h3>");

    // clear the shopping cart
    session.removeAttribute("productList");

} catch (SQLException e) {
    // if anything went wrong, roll back the transaction
    if (con != null) {
        try {
            con.rollback();
        } catch (SQLException ex) {
            out.println("Error during transaction rollback: " + ex.getMessage());
        }
    }
    out.println("<h1>Database Error</h1>");
    out.println("<p>Your order could not be placed due to a database error.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    
} catch (Exception e) {
    // Catch other errors (e.g., ClassNotFound, parsing errors)
    out.println("<h1>Application Error</h1>");
    out.println("<p>Your order could not be placed due to an application error.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    
} finally {
    if (con != null) {
        try {
            con.setAutoCommit(true); // Reset to default
            con.close();
        } catch (SQLException e) {
            out.println(e);
        }
    }
}
%>
</BODY>
</HTML>