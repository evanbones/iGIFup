<!DOCTYPE html>
<html>
<head>
<title>Administrator Page</title>
<link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">

<%@ include file="header.jsp" %>
<%@ include file="auth.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>

<h1>Administrator Sales Report</h1>

<%
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
} catch (java.lang.ClassNotFoundException e) {
    out.println("ClassNotFoundException: " + e);
}

// SQL query to get total order amount by day
String sql = "SELECT CAST(orderDate AS DATE) as orderDay, SUM(totalAmount) as dailyTotal " +
             "FROM ordersummary " +
             "GROUP BY CAST(orderDate AS DATE) " +
             "ORDER BY orderDay DESC";

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try (Connection con = DriverManager.getConnection(url, uid, pw);
     Statement stmt = con.createStatement();
     ResultSet rs = stmt.executeQuery(sql)) {
    
    out.println("<table>");
    out.println("<tr><th>Order Date</th><th>Total Sales</th></tr>");
    
    boolean hasData = false;
    while (rs.next()) {
        hasData = true;
        String orderDay = rs.getString("orderDay");
        double dailyTotal = rs.getDouble("dailyTotal");
        
        out.println("<tr>");
        out.println("<td>" + orderDay + "</td>");
        out.println("<td>" + currFormat.format(dailyTotal) + "</td>");
        out.println("</tr>");
    }
    
    if (!hasData) {
        out.println("<tr><td colspan='2'>No orders found</td></tr>");
    }
    
    out.println("</table>");
    
} catch (SQLException e) {
    out.println("<p class='error'>Database Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

</div>
</body>
</html>