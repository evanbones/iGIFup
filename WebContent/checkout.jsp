<!DOCTYPE html>
<html>
<head>
<title>iGifUp Checkout</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 20px;
    }
    .checkout-form {
        max-width: 500px;
        margin: 20px auto;
        padding: 30px;
        border: 2px solid #4CAF50;
        border-radius: 8px;
        background-color: #f9f9f9;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
        color: #333;
    }
    .form-group input[type="text"],
    .form-group input[type="password"] {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        box-sizing: border-box;
        font-size: 14px;
    }
    .form-buttons {
        display: flex;
        gap: 10px;
        margin-top: 25px;
    }
    .form-buttons input[type="submit"],
    .form-buttons input[type="reset"] {
        flex: 1;
        padding: 12px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 16px;
        font-weight: bold;
    }
    .form-buttons input[type="submit"] {
        background-color: #4CAF50;
        color: white;
    }
    .form-buttons input[type="submit"]:hover {
        background-color: #45a049;
    }
    .form-buttons input[type="reset"] {
        background-color: #f44336;
        color: white;
    }
    .form-buttons input[type="reset"]:hover {
        background-color: #da190b;
    }
    h1 {
        color: #333;
        text-align: center;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<h1>Complete Your Order</h1>

<div class="checkout-form">
    <form method="get" action="order.jsp">
        <div class="form-group">
            <label for="customerId">Customer ID:</label>
            <input type="text" id="customerId" name="customerId" required>
        </div>
        
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        
        <div class="form-buttons">
            <input type="submit" value="Place Order">
            <input type="reset" value="Reset">
        </div>
    </form>
</div>

</body>
</html>