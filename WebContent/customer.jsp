<%@ page import="java.sql.*, java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>My Profile</title>
<link rel="stylesheet" href="css/index.css">
<link rel="stylesheet" href="css/listprod.css">

<style>
    .profile-container { 
        display: flex;
        gap: 20px; 
        flex-wrap: wrap; 
        text-align: left; 
    }
    
    .profile-box, .orders-box {
        background: rgba(0,0,0,0.6);
        border: 4px groove #00ffff;
        padding: 25px; 
        border-radius: 20px;
        box-shadow: 0 0 15px #330066;
    }
    
    .profile-box { flex: 1; min-width: 300px; }
    .orders-box { flex: 2; min-width: 400px; }
    
    h3 { 
        color: #ffea00; 
        text-shadow: 0 0 8px #ff00ff;
        border-bottom: 2px dashed #FF00FF; 
        padding-bottom: 10px;
        margin-top: 0;
    }

    input[type="text"], input[type="password"] {
        width: 100%; 
        box-sizing: border-box;
        padding: 10px;
        margin-bottom: 15px;
        background-color: #000022;
        color: #00ffea;
        border: 3px inset #00ffff;
        border-radius: 10px;
        font-family: "Comic Sans MS", cursive;
        font-size: 16px;
        outline: none;
    }

    input[type="text"]:focus, input[type="password"]:focus {
        background-color: #000044;
        box-shadow: 0 0 10px cyan;
        border-color: #ffffff;
    }

    table { width: 100%; border-collapse: collapse; color: #FFF; margin-top: 10px; }
    th { background: linear-gradient(90deg, #ff00ff, #9900ff); color: yellow; padding: 10px; text-shadow: 1px 1px 2px black; border-bottom: 2px solid cyan;}
    td { border-bottom: 1px dashed #00ffff; padding: 10px; color: #c3f9ff; }
    
    label { font-weight: bold; color: #00ffcc; text-shadow: 0 0 5px #000; }
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
    
    String msg = request.getParameter("msg");
    if (msg != null) out.println("<div style='background:rgba(255,0,0,0.3); border:2px solid red; color:white; padding:10px; margin-bottom:15px; font-weight:bold;'>" + msg + "</div>");

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
        
        <div class="profile-box">
            <h3>Edit Profile</h3>
            <form action="update_profile.jsp" method="post">
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

                <label>State/Province:</label>
                <input type="text" name="state" value="<%= rsCust.getString("state") != null ? rsCust.getString("state") : "" %>">

                <label>Zip/Postal Code:</label>
                <input type="text" name="postalCode" value="<%= rsCust.getString("postalCode") != null ? rsCust.getString("postalCode") : "" %>">

                <label>Country:</label>
                <input type="text" name="country" value="<%= rsCust.getString("country") != null ? rsCust.getString("country") : "" %>">
                
                <label>Password:</label>
                <input type="password" name="password" value="<%= rsCust.getString("password") %>">
                
                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Update Info" class="btn">
                </div>
            </form>
        </div>

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
                    if (!hasOrders) out.println("<tr><td colspan='4' style='text-align:center; padding:20px;'>No orders found.</td></tr>");
                %>
            </table>
        </div>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<div style='color:red; background:pink; padding:10px;'>Error: " + e + "</div>");
    }
%>
</div>
</div>
</body>
</html>