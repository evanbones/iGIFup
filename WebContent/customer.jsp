<%@ page import="java.sql.*, java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>My Profile</title>
<link rel="stylesheet" href="css/index.css">
<style>
    .profile-container { display: flex; gap: 20px; flex-wrap: wrap; text-align: left; }
    .profile-box, .orders-box {
        background: rgba(0,0,0,0.6); border: 3px outset #00FFFF; padding: 20px; border-radius: 10px;
    }
    .profile-box { flex: 1; min-width: 300px; }
    .orders-box { flex: 2; min-width: 400px; }
    
    h3 { color: #FFFF00; border-bottom: 2px dashed #FF00FF; padding-bottom: 5px; }
    input[type="text"], input[type="password"] {
        width: 95%; background: #000; color: #FFF; border: 1px solid #00FF00; padding: 5px; margin-bottom: 8px;
    }
    table { width: 100%; border-collapse: collapse; color: #FFF; }
    th { background: #330066; color: #00FF00; padding: 8px; }
    td { border-bottom: 1px solid #555; padding: 8px; }
</style>
</head>
<body>
<div class="page-container">
<%@ include file="header.jsp" %>
<div class="main-content">

<%
    String user = (String) session.getAttribute("authenticatedUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check for error/success messages from update page
    String msg = request.getParameter("msg");
    if (msg != null) out.println("<p style='background:red; color:white; padding:5px;'>" + msg + "</p>");

    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        String sqlCust = "SELECT * FROM customer WHERE userid = ?";
        PreparedStatement pstmt = con.prepareStatement(sqlCust);
        pstmt.setString(1, user);
        ResultSet rsCust = pstmt.executeQuery();
        
        if (rsCust.next()) {
            int custId = rsCust.getInt("customerId");
%>
    <div class="welcome-section">
        <h2>My Account</h2>
    </div>

    <div class="profile-container">
        
        <!-- EDIT ACCOUNT INFO SECTION -->
        <div class="profile-box">
            <h3>Edit Profile</h3>
            <form action="update_profile.jsp" method="post">
                <!-- IMPORTANT: Send the OLD userid so we know who to update -->
                <input type="hidden" name="oldUserid" value="<%= rsCust.getString("userid") %>">

                <label style="color:#FFFF00;">Username:</label>
                <input type="text" name="userid" value="<%= rsCust.getString("userid") %>">

                <label>First Name:</label>
                <input type="text" name="firstName" value="<%= rsCust.getString("firstName") %>">
                
                <label>Last Name:</label>
                <input type="text" name="lastName" value="<%= rsCust.getString("lastName") %>">
                
                <label>Email:</label>
                <input type="text" name="email" value="<%= rsCust.getString("email") %>">
                
                <label>Phone:</label>
                <input type="text" name="phonenum" value="<%= rsCust.getString("phonenum") %>">
                
                <label>Address:</label>
                <input type="text" name="address" value="<%= rsCust.getString("address") %>">
                
                <label>City:</label>
                <input type="text" name="city" value="<%= rsCust.getString("city") %>">

                <!-- NEW FIELDS -->
                <label>State/Province:</label>
                <input type="text" name="state" value="<%= rsCust.getString("state") != null ? rsCust.getString("state") : "" %>">

                <label>Zip/Postal Code:</label>
                <input type="text" name="postalCode" value="<%= rsCust.getString("postalCode") != null ? rsCust.getString("postalCode") : "" %>">

                <label>Country:</label>
                <input type="text" name="country" value="<%= rsCust.getString("country") != null ? rsCust.getString("country") : "" %>">
                
                <label>Password:</label>
                <input type="password" name="password" value="<%= rsCust.getString("password") %>">
                
                <input type="submit" value="Update Info" style="margin-top:10px; cursor:pointer;">
            </form>
        </div>

        <!-- LIST ORDERS SECTION -->
        <div class="orders-box">
            <h3>My Order History</h3>
            <table>
                <tr><th>ID</th><th>Date</th><th>Amount</th><th>Ship To</th></tr>
                <%
                    NumberFormat curr = NumberFormat.getCurrencyInstance();
                    String sqlOrders = "SELECT orderId, orderDate, totalAmount, shiptoCity FROM ordersummary WHERE customerId = ? ORDER BY orderDate DESC";
                    PreparedStatement pstmtOrd = con.prepareStatement(sqlOrders);
                    pstmtOrd.setInt(1, custId);
                    ResultSet rsOrd = pstmtOrd.executeQuery();
                    
                    boolean hasOrders = false;
                    while (rsOrd.next()) {
                        hasOrders = true;
                        out.println("<tr>");
                        out.println("<td>#" + rsOrd.getInt("orderId") + "</td>");
                        out.println("<td>" + rsOrd.getTimestamp("orderDate") + "</td>");
                        out.println("<td>" + curr.format(rsOrd.getDouble("totalAmount")) + "</td>");
                        out.println("<td>" + rsOrd.getString("shiptoCity") + "</td>");
                        out.println("</tr>");
                    }
                    if (!hasOrders) out.println("<tr><td colspan='4'>No orders found.</td></tr>");
                %>
            </table>
        </div>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("Error: " + e);
    }
%>
</div>
</div>
</body>
</html>