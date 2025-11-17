<%@ page import="java.sql.*, java.text.NumberFormat, java.util.HashMap, java.util.Iterator, java.util.ArrayList, java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>iGifUp Order Processing</title>
<link rel="stylesheet" href="css/listprod.css">
<style>
    .order-container {
        max-width: 900px;
        margin: 40px auto;
        padding: 30px;
        background: linear-gradient(135deg, #330066, #5800cc 40%, #9900ff 90%);
        border: 8px double #ffcc00;
        border-radius: 20px;
        box-shadow: 0 0 30px #ff00ff, 0 0 40px cyan;
    }
    
    .order-container h1 {
        color: #ffff33;
        text-align: center;
        text-shadow: 2px 2px 5px #ff00ff;
        margin-bottom: 20px;
        font-size: 36px;
    }
    
    .success-box {
        background: rgba(0, 255, 0, 0.2);
        border: 3px solid #00ff00;
        padding: 20px;
        border-radius: 15px;
        margin: 20px 0;
        text-align: center;
    }
    
    .success-box h2 {
        color: #00ff00;
        text-shadow: 0 0 10px #00ff00;
        margin: 0 0 10px 0;
    }
    
    .success-box p {
        color: #ccffcc;
        font-size: 18px;
        margin: 5px 0;
    }
    
    .error-box {
        background: rgba(255, 0, 0, 0.2);
        border: 3px solid #ff0000;
        padding: 20px;
        border-radius: 15px;
        margin: 20px 0;
        text-align: center;
    }
    
    .error-box h2 {
        color: #ff0000;
        text-shadow: 0 0 10px #ff0000;
        margin: 0 0 10px 0;
    }
    
    .error-box p {
        color: #ffcccc;
        font-size: 16px;
    }
    
    .order-summary {
        background: rgba(0, 0, 0, 0.4);
        padding: 20px;
        border-radius: 15px;
        border: 3px inset yellow;
        box-shadow: inset 0 0 15px magenta;
        margin: 20px 0;
    }
    
    .order-summary h3 {
        color: #00ffcc;
        text-shadow: 0 0 5px #ff00ff;
        margin-bottom: 15px;
    }
    
    .summary-info {
        display: grid;
        grid-template-columns: auto 1fr;
        gap: 10px;
        margin-bottom: 20px;
    }
    
    .summary-info strong {
        color: #00ffcc;
        text-shadow: 0 0 3px #ff00ff;
    }
    
    .summary-info span {
        color: #ffff99;
    }
    
    .order-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
        background: rgba(0, 0, 40, 0.8);
        border: 5px ridge #00ffff;
        box-shadow: 0 0 20px cyan;
    }
    
    .order-table th {
        background: linear-gradient(90deg, #ff00ff, #9900ff);
        border-bottom: 4px solid cyan;
        color: yellow;
        font-weight: bold;
        padding: 14px;
        text-shadow: 0 0 4px black;
    }
    
    .order-table td {
        padding: 12px;
        border-bottom: 1px dashed #66ffff;
        color: #c3f9ff;
    }
    
    .order-table tr:nth-child(even) {
        background: rgba(0, 0, 60, 0.5);
    }
    
    .order-table tr:hover {
        background: rgba(0, 255, 255, 0.2);
    }
    
    .order-table .total-row {
        font-weight: bold;
        background: linear-gradient(90deg, #00cc00, #009900) !important;
        color: #ffff00;
        font-size: 18px;
    }
    
    .action-links {
        text-align: center;
        margin-top: 30px;
    }
    
    .action-links a {
        display: inline-block;
        padding: 14px 30px;
        margin: 0 10px;
        background: linear-gradient(#ff00ff, #8200ff);
        border: 3px outset white;
        color: yellow;
        text-decoration: none;
        border-radius: 10px;
        font-size: 18px;
        font-weight: bold;
        text-shadow: 1px 1px 2px black;
    }
    
    .action-links a:hover {
        background: linear-gradient(#00ffff, #0066aa);
        color: black;
        border: 3px inset white;
        transform: scale(1.05);
    }
</style>
</head>
<body>
<div class="page-container">

<%@ include file="header.jsp" %>

<div class="order-container">

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
        out.println("<div class='error-box'>");
        out.println("<h2>Empty Shopping Cart</h2>");
        out.println("<p>Your shopping cart is empty. Please add some items first!</p>");
        out.println("</div>");
        out.println("<div class='action-links'><a href='listprod.jsp'>Start Shopping</a></div>");
        out.println("</div></div></body></html>");
        return;
    }
    
    // Validate customer ID
    int numericCustId = 0;
    if (custId == null || custId.trim().isEmpty()) {
        out.println("<div class='error-box'>");
        out.println("<h2>Missing Customer ID</h2>");
        out.println("<p>You must enter a customer ID.</p>");
        out.println("</div>");
        out.println("<div class='action-links'><a href='checkout.jsp'>Go Back</a></div>");
        out.println("</div></div></body></html>");
        return;
    }
    
    try {
        numericCustId = Integer.parseInt(custId);
    } catch (NumberFormatException e) {
        out.println("<div class='error-box'>");
        out.println("<h2>Invalid Customer ID</h2>");
        out.println("<p>Customer ID must be a valid number.</p>");
        out.println("</div>");
        out.println("<div class='action-links'><a href='checkout.jsp'>Go Back</a></div>");
        out.println("</div></div></body></html>");
        return;
    }

    // Validate password
    if (password == null || password.trim().isEmpty()) {
        out.println("<div class='error-box'>");
        out.println("<h2>Missing Password</h2>");
        out.println("<p>You must enter a password.</p>");
        out.println("</div>");
        out.println("<div class='action-links'><a href='checkout.jsp'>Go Back</a></div>");
        out.println("</div></div></body></html>");
        return;
    }

    // SQL Server connection
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // Verify customer credentials with case-sensitive password
    String sqlValidateCust = "SELECT customerId, firstName, lastName FROM customer WHERE customerId = ? AND password COLLATE Latin1_General_CS_AS = ?";
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
        out.println("<div class='error-box'>");
        out.println("<h2>Invalid Credentials</h2>");
        out.println("<p>Customer ID or password is incorrect.</p>");
        out.println("</div>");
        out.println("<div class='action-links'><a href='checkout.jsp'>Go Back</a></div>");
        out.println("</div></div></body></html>");
        return;
    }
    
    // Start transaction
    con.setAutoCommit(false);
    
    // Insert into ordersummary table
    String sqlInsertOrder = "INSERT INTO orderSummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), ?)";
    
    try (PreparedStatement pstmt = con.prepareStatement(sqlInsertOrder, Statement.RETURN_GENERATED_KEYS)) {
        pstmt.setInt(1, numericCustId);
        pstmt.setDouble(2, 0.0);
        pstmt.executeUpdate();
        
        ResultSet keys = pstmt.getGeneratedKeys();
        if (keys.next()) {
            orderId = keys.getInt(1);
        } else {
            throw new SQLException("Failed to retrieve new orderId.");
        }
    }

    // Insert order products
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
            
            pstmtProd.executeUpdate();
        }
    } 

    // Update total amount
    String sqlUpdateTotal = "UPDATE orderSummary SET totalAmount = ? WHERE orderId = ?";
    try (PreparedStatement pstmtUpdate = con.prepareStatement(sqlUpdateTotal)) {
        pstmtUpdate.setDouble(1, totalOrderAmount);
        pstmtUpdate.setInt(2, orderId);
        pstmtUpdate.executeUpdate();
    }
    
    // Commit transaction
    con.commit();
    
    // Display success message
    out.println("<div class='success-box'>");
    out.println("<h2>Order Complete!</h2>");
    out.println("<p>Thank you for your order, <strong>" + customerName + "</strong>!</p>");
    out.println("</div>");
    
    out.println("<div class='order-summary'>");
    out.println("<h3>Order Summary</h3>");
    out.println("<div class='summary-info'>");
    out.println("<strong>Order ID:</strong> <span>#" + orderId + "</span>");
    out.println("<strong>Customer:</strong> <span>" + customerName + "</span>");
    out.println("<strong>Customer ID:</strong> <span>" + numericCustId + "</span>");
    out.println("</div>");
    
    out.println("<h3>Order Details</h3>");
    out.println("<table class='order-table'>");
    out.println("<tr><th>Product Name</th><th>Quantity</th><th>Price</th><th>Subtotal</th></tr>");
    
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    
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
    
    out.println("<tr class='total-row'>");
    out.println("<td colspan='3' align='right'><strong>Order Total:</strong></td>");
    out.println("<td align='right'>" + currFormat.format(totalOrderAmount) + "</td>");
    out.println("</tr>");
    out.println("</table>");
    out.println("</div>");

    out.println("<div class='action-links'>");
    out.println("<a href='listprod.jsp'>Continue Shopping</a>");
    out.println("<a href='listorder.jsp'>View All Orders</a>");
    out.println("</div>");

    // Clear shopping cart
    session.removeAttribute("productList");

} catch (SQLException e) {
    if (con != null) {
        try {
            con.rollback();
        } catch (SQLException ex) {
            out.println("<p>Error during rollback: " + ex.getMessage() + "</p>");
        }
    }
    out.println("<div class='error-box'>");
    out.println("<h2>Database Error</h2>");
    out.println("<p>Your order could not be placed due to a database error.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    out.println("</div>");
    out.println("<div class='action-links'><a href='checkout.jsp'>Try Again</a></div>");
    
} finally {
    if (con != null) {
        try {
            con.setAutoCommit(true);
            con.close();
        } catch (SQLException e) {
            out.println(e);
        }
    }
}
%>

</div>
</div>
</body>
</html>