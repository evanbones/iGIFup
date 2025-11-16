<!DOCTYPE html>
<html>
<head>
<title>Login Screen</title>
</head>
<body>
<link rel="stylesheet" href="css/login.css">
<div class="page-container">
<%@ include file="header.jsp" %>

<div style="margin:0 auto;text-align:center;display:inline">

<div class="page-container">

<div class="login-box">

<h3>Please Login to System</h3>

<%
if (session.getAttribute("loginMessage") != null)
    out.println("<p>"+session.getAttribute("loginMessage")+"</p>");
%>

<form name="MyForm" method="post" action="validateLogin.jsp">
    <table>
        <tr>
            <td>Username:</td>
            <td><input type="text" name="username" size="10" maxlength="10"></td>
        </tr>
        <tr>
            <td>Password:</td>
            <td><input type="password" name="password" size="10" maxlength="10"></td>
        </tr>
    </table>
    <br>
    <input class="submit" type="submit" value="Log In">
</form>

</div>
</div>



</body>
</html>

