<!DOCTYPE html>
<html>
<head>
<title>Join iGifUp</title>
<link rel="stylesheet" href="css/index.css">
<style>
    .signup-form {
        width: 500px; margin: 0 auto; background: rgba(0, 0, 0, 0.5);
        padding: 30px; border: 4px ridge #00FF00; border-radius: 15px;
        text-align: left;
    }
    .signup-form input {
        width: 100%; padding: 8px; margin-bottom: 10px;
        background: #000033; color: #00FFFF; border: 2px inset #FFF;
    }
    .error-msg { color: #FF0000; background: #FFCCCC; font-weight: bold; text-align: center; }
</style>

<script>
    function validateSignup() {
        // Data Validation Criteria
        var user = document.forms["regForm"]["userid"].value;
        var pass = document.forms["regForm"]["password"].value;
        var email = document.forms["regForm"]["email"].value;
        var phone = document.forms["regForm"]["phonenum"].value;

        if (user == "" || pass == "" || email == "") {
            alert("Username, Password, and Email are required!");
            return false;
        }
        
        // Validate Password Length
        if (pass.length < 5) {
            alert("Password must be at least 5 characters long.");
            return false;
        }

        // Simple Email Regex
        var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(email)) {
            alert("Please enter a valid email address.");
            return false;
        }

        return true;
    }
</script>
</head>
<body>
<div class="page-container">
<%@ include file="header.jsp" %>

<div class="main-content">
    <div class="welcome-section">
        <h2>Create Account</h2>
        <p>Join the retro revolution!</p>
    </div>

    <div class="signup-form">
        <form name="regForm" action="create_account.jsp" method="post" onsubmit="return validateSignup()">
            
            <label style="color:#FFFF00">First Name:</label>
            <input type="text" name="firstName">
            
            <label style="color:#FFFF00">Last Name:</label>
            <input type="text" name="lastName">
            
            <label style="color:#FFFF00">Email (*):</label>
            <input type="text" name="email">
            
            <label style="color:#FFFF00">Phone:</label>
            <input type="text" name="phonenum">
            
            <label style="color:#FFFF00">Address:</label>
            <input type="text" name="address">
            
            <label style="color:#FFFF00">City:</label>
            <input type="text" name="city">
            
            <label style="color:#FFFF00">State/Prov:</label>
            <input type="text" name="state">
            
            <label style="color:#FFFF00">Postal Code:</label>
            <input type="text" name="postalCode">
            
            <label style="color:#FFFF00">Country:</label>
            <input type="text" name="country">

            <hr style="border: 1px dashed #00FF00; margin: 15px 0;">

            <label style="color:#00FF00">Username (*):</label>
            <input type="text" name="userid">
            
            <label style="color:#00FF00">Password (*):</label>
            <input type="password" name="password">

            <input type="submit" value="Register Now" style="background: linear-gradient(#ff00ff, #8200ff); color: yellow; font-weight: bold; cursor: pointer;">
        </form>
    </div>
</div>
</div>
</body>
</html>