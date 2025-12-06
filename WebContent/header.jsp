<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<link rel="stylesheet", href="css/header.css">

<div class="site-header">
    <h1>iGifUp</h1>
    <nav class="site-nav">
        <a href="index.jsp">Home</a>
        <a href="listprod.jsp">Products</a>
        <a href="showcart.jsp">Shopping Cart</a>
        <span class="user-status" style="float:right; margin-left: 20px; color: white;">
            <%
                String headerUser = (String) session.getAttribute("authenticatedUser");
                if (headerUser != null) {
                    // LINK TO CUSTOMER PAGE
                    out.println("Welcome, <a href='customer.jsp' style='color:#FFFF00;text-decoration:underline;'>" + headerUser + "</a> | <a href='logout.jsp'>Logout</a>");
                } else {
                    out.println("<a href='login.jsp'>Login</a> | <a href='signup.jsp'>Sign Up</a>");
                }
            %>
        </span>
    </nav>
</div>