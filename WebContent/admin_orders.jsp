<%@ page import="java.sql.*, java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Orders</title>
    <link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>
    <div style="text-align:center; margin-bottom:20px;"><a href="admin.jsp" class="btn">Back to Dashboard</a></div>

    <h1>Order Management</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    NumberFormat curr = NumberFormat.getCurrencyInstance();
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // Handle Status Update
        String newStatus = request.getParameter("status");
        String orderId = request.getParameter("orderId");
        if (newStatus != null && orderId != null) {
            String upSql = "UPDATE ordersummary SET orderStatus = ? WHERE orderId = ?";
            PreparedStatement pstmt = con.prepareStatement(upSql);
            pstmt.setString(1, newStatus);
            pstmt.setInt(2, Integer.parseInt(orderId));
            pstmt.executeUpdate();
            out.println("<p style='color:#00FF00; text-align:center;'>Order #" + orderId + " updated to " + newStatus + "</p>");
        }
    %>
    
    <table>
        <tr>
            <th>Order ID</th>
            <th>Date</th>
            <th>Customer</th>
            <th>Total</th>
            <th>Status</th>
            <th>Update Status</th>
        </tr>
        <%
        String sql = "SELECT O.orderId, O.orderDate, O.totalAmount, O.orderStatus, C.firstName, C.lastName " +
                     "FROM ordersummary O JOIN customer C ON O.customerId = C.customerId ORDER BY O.orderDate DESC";
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        while(rs.next()){
            String status = rs.getString("orderStatus");
            if(status == null) status = "Processing"; // Fallback if NULL
        %>
        <tr>
            <td>#<%= rs.getInt("orderId") %></td>
            <td><%= rs.getTimestamp("orderDate") %></td>
            <td><%= rs.getString("firstName") %> <%= rs.getString("lastName") %></td>
            <td align="right"><%= curr.format(rs.getDouble("totalAmount")) %></td>
            <td style="color: <%= status.equals("Shipped") ? "#00FF00" : "yellow" %>"><%= status %></td>
            <td>
                <form action="admin_orders.jsp" method="get" style="margin:0;">
                    <input type="hidden" name="orderId" value="<%= rs.getInt("orderId") %>">
                    <select name="status">
                        <option value="Processing" <%= status.equals("Processing")?"selected":"" %>>Processing</option>
                        <option value="Shipped" <%= status.equals("Shipped")?"selected":"" %>>Shipped</option>
                        <option value="Delivered" <%= status.equals("Delivered")?"selected":"" %>>Delivered</option>
                        <option value="Cancelled" <%= status.equals("Cancelled")?"selected":"" %>>Cancelled</option>
                    </select>
                    <input type="submit" value="Update" style="font-size:10px;">
                </form>
            </td>
        </tr>
        <% } %>
    </table>

    <% } catch(Exception e) { out.println(e); } %>
</div>
</body>
</html>