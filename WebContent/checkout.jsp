<!DOCTYPE html>
<html>
<head>
<title>iGifUp Checkout</title>
<link rel="stylesheet" href="css/listprod.css">
<style>
    /* ... (KEEPING YOUR EXISTING CSS EXACTLY AS IS) ... */
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
    .form-group { margin-bottom: 20px; }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
        color: #00ffcc;
        font-size: 18px;
        text-shadow: 0 0 5px #ff00ff;
    }
    .form-group input[type="text"],
    .form-group input[type="password"],
    .form-group select {
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
    .form-group input:focus {
        outline: none;
        border: 3px outset #00ffff;
        box-shadow: 0 0 10px cyan;
    }
    .form-buttons { display: flex; gap: 15px; margin-top: 30px; }
    .form-buttons input, .form-buttons a {
        flex: 1; padding: 14px; border: 3px outset white; border-radius: 10px;
        cursor: pointer; font-size: 18px; font-weight: bold;
        font-family: "Comic Sans MS", sans-serif; text-shadow: 1px 1px 2px black;
        text-decoration: none; text-align: center; display: block;
    }
    .form-buttons input[type="submit"] { background: linear-gradient(#ff00ff, #8200ff); color: yellow; }
    .form-buttons input[type="submit"]:hover { background: linear-gradient(#00ffff, #0066aa); color: black; border: 3px inset white; transform: scale(1.05); }
    .form-buttons .cancel-btn { background: linear-gradient(#ff0000, #990000); color: white; }
    .form-buttons .cancel-btn:hover { background: linear-gradient(#ff6666, #cc0000); border: 3px inset white; transform: scale(1.05); }
    .info-text { color: #ffe600; text-align: center; margin-top: 20px; font-size: 14px; background: rgba(0, 0, 0, 0.5); padding: 10px; border-radius: 8px; }
    .login-prompt { color: #ffff33; text-align: center; background: rgba(255, 0, 0, 0.3); padding: 20px; border-radius: 10px; border: 3px solid #ff0000; }
    .login-prompt a { color: #00ffff; font-weight: bold; text-decoration: underline; }
    
    /* New Style for Sections */
    .section-header {
        border-bottom: 2px dashed #00ffcc;
        margin-bottom: 15px;
        padding-bottom: 5px;
        color: #ffff33;
        font-size: 22px;
    }
</style>

<script>
    // DATA VALIDATION CRITERIA
    function validateCheckout() {
        var cardNum = document.getElementById("paymentNumber").value;
        var expiry = document.getElementById("paymentExpiryDate").value;
        var address = document.getElementById("shiptoAddress").value;

        if (address.trim() == "") {
            alert("Shipping Address is required!");
            return false;
        }
        
        // Simple check: Credit Card must be numbers and at least 10 digits
        if (isNaN(cardNum) || cardNum.length < 10) {
            alert("Please enter a valid Credit Card Number (Digits only).");
            return false;
        }

        // Simple check: Expiry must be length 7 (MM/YYYY) or standard date format
        if (expiry.length < 5) {
            alert("Please enter a valid Expiry Date.");
            return false;
        }

        return true;
    }
</script>
</head>
<body>
<div class="page-container">

<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>

<%
String userName = (String) session.getAttribute("authenticatedUser");
if (userName == null) {
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
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    // Variables to hold customer data
    String customerId = "";
    String customerName = "";
    String address = "";
    String city = "";
    String state = "";
    String postalCode = "";
    String country = "";

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection(url, uid, pw);
        
        // FETCH CUSTOMER DATA FOR PRE-FILLING
        String sql = "SELECT customerId, firstName, lastName, address, city, state, postalCode, country FROM customer WHERE userid = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, userName);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            customerId = rs.getString("customerId");
            customerName = rs.getString("firstName") + " " + rs.getString("lastName");
            address = rs.getString("address");
            city = rs.getString("city");
            state = rs.getString("state");
            postalCode = rs.getString("postalCode");
            country = rs.getString("country");
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
        <form method="get" action="order.jsp" onsubmit="return validateCheckout()">
            
            <input type="hidden" name="customerId" value="<%= customerId %>">
            
            <div class="form-group">
                <label>Customer ID:</label>
                <input type="text" value="<%= customerId %> (<%= customerName %>)" disabled>
            </div>

            <div class="section-header">Shipping Information</div>
            
            <div class="form-group">
                <label for="shiptoAddress">Address:</label>
                <input type="text" id="shiptoAddress" name="shiptoAddress" value="<%= address %>" required>
            </div>
            
            <div class="form-group">
                <label for="shiptoCity">City:</label>
                <input type="text" id="shiptoCity" name="shiptoCity" value="<%= city %>" required>
            </div>

            <div class="form-group" style="display:flex; gap:10px;">
                <div style="flex:1;">
                    <label for="shiptoState">State/Prov:</label>
                    <input type="text" id="shiptoState" name="shiptoState" value="<%= state %>" required>
                </div>
                <div style="flex:1;">
                    <label for="shiptoPostalCode">Zip/Postal:</label>
                    <input type="text" id="shiptoPostalCode" name="shiptoPostalCode" value="<%= postalCode %>" required>
                </div>
            </div>

            <div class="form-group">
                <label for="shiptoCountry">Country:</label>
                <input type="text" id="shiptoCountry" name="shiptoCountry" value="<%= country %>" required>
            </div>

            <div class="section-header" style="margin-top:20px;">Payment Details</div>

            <div class="form-group">
                <label for="paymentType">Payment Method:</label>
                <select id="paymentType" name="paymentType">
                    <option value="Visa">Visa</option>
                    <option value="MasterCard">MasterCard</option>
                    <option value="Amex">American Express</option>
                </select>
            </div>

            <div class="form-group">
                <label for="paymentNumber">Card Number:</label>
                <input type="text" id="paymentNumber" name="paymentNumber" placeholder="xxxx-xxxx-xxxx-xxxx" maxlength="19" required>
            </div>

            <div class="form-group">
                <label for="paymentExpiryDate">Expiry Date:</label>
                <input type="text" id="paymentExpiryDate" name="paymentExpiryDate" placeholder="MM/YYYY" required>
            </div>
            
            <div class="section-header" style="margin-top:20px;">Verification</div>

            <div class="form-group">
                <label for="password">Confirm Password:</label>
                <input type="password" id="password" name="password" placeholder="Enter password to confirm" required>
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