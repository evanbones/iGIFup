<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<%
String userName = (String) session.getAttribute("authenticatedUser");
if (userName == null) {
    session.setAttribute("loginMessage", "You must be logged in to submit a review.");
    response.sendRedirect("login.jsp");
    return;
}

String productIdStr = request.getParameter("productId");
String ratingStr = request.getParameter("rating");
String comment = request.getParameter("comment");

if (productIdStr == null || ratingStr == null || comment == null) {
    response.sendRedirect("product.jsp?id=" + productIdStr + "&error=missing");
    return;
}

int productId = 0;
int rating = 0;

try {
    productId = Integer.parseInt(productIdStr);
    rating = Integer.parseInt(ratingStr);
} catch (NumberFormatException e) {
    response.sendRedirect("product.jsp?id=" + productIdStr + "&error=invalid");
    return;
}

if (rating < 1 || rating > 5) {
    response.sendRedirect("product.jsp?id=" + productId + "&error=rating");
    return;
}

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    Connection con = DriverManager.getConnection(url, uid, pw);
    
    String getCustomerSql = "SELECT customerId FROM customer WHERE userid = ?";
    PreparedStatement custStmt = con.prepareStatement(getCustomerSql);
    custStmt.setString(1, userName);
    ResultSet custRs = custStmt.executeQuery();
    
    if (!custRs.next()) {
        custRs.close();
        custStmt.close();
        con.close();
        response.sendRedirect("product.jsp?id=" + productId + "&error=account");
        return;
    }
    
    int customerId = custRs.getInt("customerId");
    custRs.close();
    custStmt.close();
    
    String checkReviewSql = "SELECT reviewId FROM review WHERE customerId = ? AND productId = ?";
    PreparedStatement checkStmt = con.prepareStatement(checkReviewSql);
    checkStmt.setInt(1, customerId);
    checkStmt.setInt(2, productId);
    ResultSet checkRs = checkStmt.executeQuery();
    
    if (checkRs.next()) {
        checkRs.close();
        checkStmt.close();
        con.close();
        response.sendRedirect("product.jsp?id=" + productId + "&error=duplicate");
        return;
    }
    checkRs.close();
    checkStmt.close();
    
    String insertSql = "INSERT INTO review (reviewRating, reviewDate, customerId, productId, reviewComment) VALUES (?, GETDATE(), ?, ?, ?)";
    PreparedStatement insertStmt = con.prepareStatement(insertSql);
    insertStmt.setInt(1, rating);
    insertStmt.setInt(2, customerId);
    insertStmt.setInt(3, productId);
    insertStmt.setString(4, comment);
    
    insertStmt.executeUpdate();
    insertStmt.close();
    con.close();
    
    response.sendRedirect("product.jsp?id=" + productId + "&reviewSuccess=true");
    
} catch (SQLException e) {
    out.println("Database error: " + e.getMessage());
    e.printStackTrace();
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace();
}
%>