<!DOCTYPE html>
<html>
<head>
<title>iGifUp Checkout</title>
<link rel="stylesheet" href="css/listprod.css">
<style>
    .checkout-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 30px;
        background: linear-gradient(135deg, #330066, #5800cc 40%, #9900ff 90%);
        border: 8px double #ffcc00;
        border-radius: 20px;
        box-shadow: 0 0 30px #ff00ff, 0 0 40px cyan;
    }
    
    .checkout-container h1 {
        color: #ffff33;
        text-align: center;
        text-shadow: 2px 2px 5px #ff00ff;
        margin-bottom: 30px;
        font-size: 36px;
    }
    
    .checkout-form {
        background: rgba(0, 0, 0, 0.4);
        padding: 25px;
        border-radius: 15px;
        border: 3px inset yellow;
        box-shadow: inset 0 0 15px magenta;
    }
    
    .form-group {
        margin-bottom: 20px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
        color: #00ffcc;
        font-size: 18px;
        text-shadow: 0 0 5px #ff00ff;
    }
    
    .form-group input[type="text"],
    .form-group input[type="password"] {
        width: 100%;
        padding: 12px;
        border: 3px inset #00ffff;
        border-radius: 10px;
        background: #000022;
        color: #00ffea;
        font-size: 16px;
        box-sizing: border-box;
        font-family: "Comic Sans MS", sans-serif;
    }
    
    .form-group input:disabled {
        background: #001133;
        color: #6699cc;
        cursor: not-allowed;
    }
    
    .form-group input::placeholder {
        color: #66ffee;
    }
    
    .form-group input:focus {
        outline: none;
        border: 3px outset #00ffff;
        box-shadow: 0 0 10px cyan;
    }
    
    .form-buttons {
        display: flex;
        gap: 15px;
        margin-top: 30px;
    }
    
    .form-buttons input,
    .form-buttons a {
        flex: 1;
        padding: 14px;
        border: 3px outset white;
        border-radius: 10px;
        cursor: pointer;
        font-size: 18px;
        font-weight: bold;
        font-family: "Comic Sans MS", sans-serif;
        text-shadow: 1px 1px 2px black;
        text-decoration: none;
        text-align: center;
        display: block;
    }
    
    .form-buttons input[type="submit"] {
        background: linear-gradient(#ff00ff, #8200ff);
        color: yellow;
    }
    
    .form-buttons input[type="submit"]:hover {
        background: linear-gradient(#00ffff, #0066aa);
        color: black;
        border: 3px inset white;
        transform: scale(1.05);
    }
    
    .form-buttons .cancel-btn {
        background: linear-gradient(#ff0000, #990000);
        color: white;
    }
    
    .form-buttons .cancel-btn:hover {
        background: linear-gradient(#ff6666, #cc0000);
        border: 3px inset white;
        transform: scale(1.05);
    }
    
    .info-text {
        color: #ffe600;
        text-align: center;
        margin-top: 20px;
        font-size: 14px;
        background: rgba(0, 0, 0, 0.5);
        padding: 10px;
        border-radius: 8px;
    }
    
    .login-prompt {
        color: #ffff33;
        text-align: center;
        background: rgba(255, 0, 0, 0.3);
        padding: 20px;
        border-radius: 10px;
        border: 3px solid #ff0000;
    }
    
    .login-prompt a {
        color: #00ffff;
        font-weight: bold;
        text-decoration: underline;
    }
</style>
</head>
<body>
<div class="page-container">

<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>

<%
String userName = (String) session.getAttribute("authenticatedUser");

if (userName == null) {
    // User is not logged in
    %>
    <div class="checkout-container">
        <h1>Checkout</h1>
        <div class="login-prompt">
            <h2>Please Log In</h2>
            <p>You must be logged in to complete your order.</p>
            <p><a href="login.jsp">Click here to log in</a></p>
        </div>
    </div>
    <%
} else {
    // User is logged in - get their customer ID
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    String customerId = "";
    String customerName = "";
    
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection(url, uid, pw);
        
        String sql = "SELECT customerId, firstName, lastName FROM customer WHERE userid = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, userName);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            customerId = rs.getString("customerId");
            customerName = rs.getString("firstName") + " " + rs.getString("lastName");
        }
        
        rs.close();
        pstmt.close();
        con.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
    %>

<div class="checkout-container">
    <h1>Complete Your Order</h1>
    
    <div class="checkout-form">
        <form method="get" action="order.jsp">
            <div class="form-group">
                <label for="customerName">Ordering as:</label>
                <input type="text" id="customerName" value="<%= customerName %> (<%= userName %>)" disabled>
            </div>
            
            <input type="hidden" name="customerId" value="<%= customerId %>">
            
            <div class="form-group">
                <label for="password">Confirm Password:</label>
                <input type="password" id="password" name="password" placeholder="Enter your password to confirm" required>
            </div>
            
            <div class="form-buttons">
                <input type="submit" value="Place Order">
                <a href="showcart.jsp" class="cancel-btn">Back to Cart</a>
            </div>
        </form>
        
        <div class="info-text">
            <strong>Secure Checkout</strong><br>
            Your order will be processed once you confirm your password.
        </div>
    </div>
</div>

<%
}
%>

</div>
</body>
</html>