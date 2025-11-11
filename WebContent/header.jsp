<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<style>
    .site-header {
        background-color: #4CAF50;
        padding: 15px 20px;
        margin: -20px -20px 20px -20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .site-header h1 {
        margin: 0 0 10px 0;
        color: white;
        font-size: 28px;
    }
    .site-nav {
        display: flex;
        gap: 20px;
        flex-wrap: wrap;
    }
    .site-nav a {
        color: white;
        text-decoration: none;
        padding: 8px 16px;
        background-color: rgba(255,255,255,0.2);
        border-radius: 4px;
        transition: background-color 0.3s;
        font-weight: bold;
    }
    .site-nav a:hover {
        background-color: rgba(255,255,255,0.3);
    }
</style>

<div class="site-header">
    <h1>iGifUp</h1>
    <nav class="site-nav">
        <a href="shop.jsp">Home</a>
        <a href="listprod.jsp">Products</a>
        <a href="showcart.jsp">Shopping Cart</a>
        <a href="listorder.jsp">Orders</a>
    </nav>
</div>