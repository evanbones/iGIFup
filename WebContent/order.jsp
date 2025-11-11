<%@ page import="java.sql.*, java.text.NumberFormat, java.util.HashMap, java.util.Iterator, java.util.ArrayList, java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>iGifUp Order Processing</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 20px;
    }
    h1 {
        color: #333;
    }
    table {
        border-collapse: collapse;
        margin: 20px 0;
        width: 100%;
        max-width: 800px;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 10px;
        text-align: left;
    }
    th {
        background-color: #4CAF50;
        color: white;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
    .error {
        color: #f44336;
        font-weight: bold;
        padding: 15px;
        background-color: #ffebee;
        border-left: 4px solid #f44336;
        margin: 20px 0;
    }
    .success {
        color: #4CAF50;
        font-weight: bold;
        padding: 15px;
        background-color: #e8f5e9;
        border-left: 4px solid #4CAF50;
        margin: 20px 0;
    }
    .order-summary {
        background-color: #e7f3e7;
        padding: 15px;
        border-radius: 4px;
        margin: 20px 0;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<% 
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

double totalOrderAmount = 0.0;
int orderId = 0;
Connection con = null;

try {
    // Get customer id and password
    String custId = request.getParameter("customerId");
    String password = request.getParameter("password");
    
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    // Check if shopping cart is empty
    if (productList == null || productList.isEmpty()) {
        out.println("<div class='error'>");
        out.println("<h2>Error: Empty Shopping Cart</h2>");
        out.println("<p>Your shopping cart is empty. Please <a href='listprod.jsp'>continue shopping</a>.</p>");
        out.println("</div>");
        return;
    }
    
    // Validate customer ID
    int numericCustId = 0;
    if (custId == null || custId.trim().isEmpty()) {
        out.println("<div class='error'>");
        out.println("<h2>Error: Missing Customer ID</h2>");
        out.println("<p>You must enter a customer ID. <a href='checkout.jsp'>Go back</a></p>");
        out.println("</div>");
        return;
    }
    
    try {
        numericCustId = Integer.parseInt(custId);
    } catch (NumberFormatException e) {
        out.println("<div class='error'>");
        out.println("<h2>Error: Invalid Customer ID</h2>");
        out.println("<p>Customer ID must be a valid number. <a href='checkout.jsp'>Go back</a></p>");
        out.println("</div>");
        return;
    }

    // Validate password
    if (password == null || password.trim().isEmpty()) {
        out.println("<div class='error'>");
        out.println("<h2>Error: Missing Password</h2>");
        out.println("<p>You must enter a password. <a href='checkout.jsp'>Go back</a></p>");
        out.println("</div>");
        return;
    }

    // SQL Server connection
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // customer id exists in the database.
    String sqlValidateCust = "SELECT customerId, firstName, lastName FROM customer WHERE customerId = ? AND password = ?";
    boolean customerExists = false;
    String customerName = "";
    
    try (PreparedStatement pstmtCust = con.prepareStatement(sqlValidateCust)) {
        pstmtCust.setInt(1, numericCustId);
        pstmtCust.setString(2, password);
        try (ResultSet rsCust = pstmtCust.executeQuery()) {
            if (rsCust.next()) {
                customerExists = true;
                customerName = rsCust.getString("firstName") + " " + rsCust.getString("lastName");
            }
        }
    }

    if (!customerExists) {
        out.println("<div class='error'>");
        out.println("<h2>Error: Invalid Credentials</h2>");
        out.println("<p>Customer ID " + numericCustId + " does not exist or password is incorrect. <a href='checkout.jsp'>Go back</a></p>");
        out.println("</div>");
        return;
    }
    
    // if we get here, the customer ID is valid and the cart is not empty

    // start a transaction - all operations must work or none are executed
    con.setAutoCommit(false);
    
    // insert into ordersummary table and retrieve auto-generated id
    String sqlInsertOrder = "INSERT INTO orderSummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), ?)";
    
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
    out.println("<div class='success'>");
    out.println("<h1>Order Complete</h1>");
    out.println("<p>Thank you for your order, " + customerName + "!</p>");
    out.println("</div>");
    
    out.println("<div class='order-summary'>");
    out.println("<p><b>Order ID:</b> " + orderId + "</p>");
    out.println("<p><b>Customer ID:</b> " + numericCustId + "</p>");
    out.println("<p><b>Customer Name:</b> " + customerName + "</p>");
    out.println("</div>");
    
    out.println("<h3>Order Details:</h3>");
    
    out.println("<table>");
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
        out.println("<td align='center'>" + qty + "</td>");
        out.println("<td align='right'>" + currFormat.format(price) + "</td>");
        out.println("<td align='right'>" + currFormat.format(subtotal) + "</td>");
        out.println("</tr>");
    }
    
    out.println("<tr style='font-weight: bold; background-color: #4CAF50; color: white;'>");
    out.println("<td colspan='3' align='right'>Order Total:</td>");
    out.println("<td align='right'>" + currFormat.format(totalOrderAmount) + "</td>");
    out.println("</tr>");
    out.println("</table>");

    out.println("<p><a href='listprod.jsp'>Continue Shopping</a></p>");

    // clear the shopping cart
    session.removeAttribute("productList");

} catch (SQLException e) {
        // if anything went wrong, roll back the transaction
    if (con != null) {
        try {
            con.rollback();
        } catch (SQLException ex) {
            out.println("<p>Error during transaction rollback: " + ex.getMessage() + "</p>");
        }
    }
    out.println("<div class='error'>");
    out.println("<h2>Database Error</h2>");
    out.println("<p>Your order could not be placed due to a database error.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    out.println("</div>");
    e.printStackTrace(new java.io.PrintWriter(out));
    
} catch (Exception e) {
    out.println("<div class='error'>");
    out.println("<h2>Application Error</h2>");
    out.println("<p>Your order could not be placed due to an application error.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    out.println("</div>");
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
</body>
</html>