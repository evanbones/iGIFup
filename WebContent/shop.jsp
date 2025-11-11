<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>iGifUp Main Page</title>
<style>
body {
    font-family: Arial, sans-serif;
    margin: 20px;
    background-color: #f5f5f5;
}

.main-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 40px 20px;
}

.welcome-section {
    background-color: white;
    padding: 40px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    text-align: center;
    margin-bottom: 40px;
}

.welcome-section h2 {
    color: #333;
    font-size: 36px;
    margin-bottom: 20px;
}

.welcome-section p {
    color: #666;
    font-size: 18px;
    line-height: 1.6;
    max-width: 800px;
    margin: 0 auto 30px;
}

.button-container {
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-top: 30px;
}

.button-container a {
    display: inline-block;
    background-color: #0078d7;
    color: white;
    text-decoration: none;
    padding: 15px 30px;
    border-radius: 6px;
    font-size: 18px;
    font-weight: bold;
    box-shadow: 0 3px 6px rgba(0,0,0,0.1);
    transition: all 0.2s ease-in-out;
}

.button-container a:hover {
    background-color: #005fa3;
    transform: translateY(-2px);
    box-shadow: 0 5px 10px rgba(0,0,0,0.15);
}
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="main-content">
    <div class="welcome-section">
        <h2>Welcome to iGifUp</h2>
        <p>An early 2000s-style e-commerce site for buying and selling retro GIFs</p>
    </div>

    <div class="button-container">
        <a href="listprod.jsp">Begin Shopping</a>
        <a href="listorder.jsp">List All Orders</a>
        <a href="loaddata.jsp">Load Data</a>
    </div>
</div>

</body>
</html>