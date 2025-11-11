<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>iGifUp Order List</title>
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
        margin-bottom: 30px;
        width: 100%;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #4CAF50;
        color: white;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
    .order-header {
        background-color: #e7f3e7;
        font-weight: bold;
    }
    .product-table {
        margin-left: 20px;
        width: 95%;
    }
    .error {
        color: red;
        font-weight: bold;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<h1>Order List</h1>

<%
// Note: Forces loading of SQL Server driver
try {
    // Load driver class
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
} catch (java.lang.ClassNotFoundException e) {
    out.println("ClassNotFoundException: " + e);
}

// Useful code for formatting currency values:
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

try (Connection con = DriverManager.getConnection(url, uid, pw)) {
    
    // Query to retrieve all order summary records
    String orderQuery = "SELECT orderId, orderDate, customerId, totalAmount FROM ordersummary";
    
    try (Statement stmt = con.createStatement();
         ResultSet rst = stmt.executeQuery(orderQuery)) {
        
        if (!rst.isBeforeFirst()) {
            out.println("<p>No orders found in the database.</p>");
        } else {
            while (rst.next()) {
                int orderId = rst.getInt("orderId");
                Timestamp orderDate = rst.getTimestamp("orderDate");
                int customerId = rst.getInt("customerId");
                double totalAmount = rst.getDouble("totalAmount");
                
                // Print out the order summary information
                out.println("<table>");
                out.println("<tr class='order-header'>");
                out.println("<th colspan='5'>Order ID: " + orderId + "</th>");
                out.println("</tr>");
                out.println("<tr class='order-header'>");
                out.println("<td><strong>Order Date:</strong> " + orderDate + "</td>");
                out.println("<td><strong>Customer ID:</strong> " + customerId + "</td>");
                out.println("<td colspan='3'><strong>Total Amount:</strong> " + currFormat.format(totalAmount) + "</td>");
                out.println("</tr>");
                
                // Column headers for products
                out.println("<tr>");
                out.println("<th>Product ID</th>");
                out.println("<th>Product Name</th>");
                out.println("<th>Quantity</th>");
                out.println("<th>Price</th>");
                out.println("<th>Subtotal</th>");
                out.println("</tr>");
                
                // Query to retrieve the products in the order
                String productQuery = "SELECT op.productId, p.productName, op.quantity, op.price " +
                                    "FROM orderproduct op " +
                                    "JOIN product p ON op.productId = p.productId " +
                                    "WHERE op.orderId = ?";
                
                try (PreparedStatement pstmt = con.prepareStatement(productQuery)) {
                    pstmt.setInt(1, orderId);
                    
                    try (ResultSet productRst = pstmt.executeQuery()) {
                        while (productRst.next()) {
                            int productId = productRst.getInt("productId");
                            String productName = productRst.getString("productName");
                            int quantity = productRst.getInt("quantity");
                            double price = productRst.getDouble("price");
                            double subtotal = quantity * price;
                            
                            // Write out product information
                            out.println("<tr>");
                            out.println("<td>" + productId + "</td>");
                            out.println("<td>" + productName + "</td>");
                            out.println("<td>" + quantity + "</td>");
                            out.println("<td>" + currFormat.format(price) + "</td>");
                            out.println("<td>" + currFormat.format(subtotal) + "</td>");
                            out.println("</tr>");
                        }
                    }
                }
                
                out.println("</table>");
                out.println("<br>");
            }
        }
    }
    
} catch (SQLException e) {
    out.println("<p class='error'>SQL Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

</body>
</html>