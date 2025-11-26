<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<%
String userName = (String) session.getAttribute("authenticatedUser");
if (userName == null) {
    session.setAttribute("loginMessage", "You must be logged in to delete a review.");
    response.sendRedirect("login.jsp");
    return;
}

String reviewIdStr = request.getParameter("reviewId");
String productIdStr = request.getParameter("productId");

if (reviewIdStr == null || productIdStr == null) {
    response.sendRedirect("listprod.jsp");
    return;
}

int reviewId = 0;
int productId = 0;

try {
    reviewId = Integer.parseInt(reviewIdStr);
    productId = Integer.parseInt(productIdStr);
} catch (NumberFormatException e) {
    response.sendRedirect("product.jsp?id=" + productIdStr + "&error=invalid");
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
    
    int currentCustomerId = custRs.getInt("customerId");
    custRs.close();
    custStmt.close();
    
    boolean isAdmin = "admin".equals(userName);
    
    String getReviewSql = "SELECT customerId FROM review WHERE reviewId = ?";
    PreparedStatement reviewStmt = con.prepareStatement(getReviewSql);
    reviewStmt.setInt(1, reviewId);
    ResultSet reviewRs = reviewStmt.executeQuery();
    
    if (!reviewRs.next()) {
        reviewRs.close();
        reviewStmt.close();
        con.close();
        response.sendRedirect("product.jsp?id=" + productId + "&error=notfound");
        return;
    }
    
    int reviewCustomerId = reviewRs.getInt("customerId");
    reviewRs.close();
    reviewStmt.close();
    
    if (!isAdmin && currentCustomerId != reviewCustomerId) {
        con.close();
        response.sendRedirect("product.jsp?id=" + productId + "&error=unauthorized");
        return;
    }
    
    String deleteSql = "DELETE FROM review WHERE reviewId = ?";
    PreparedStatement deleteStmt = con.prepareStatement(deleteSql);
    deleteStmt.setInt(1, reviewId);
    deleteStmt.executeUpdate();
    deleteStmt.close();
    con.close();
    
    response.sendRedirect("product.jsp?id=" + productId + "&deleteSuccess=true");
    
} catch (SQLException e) {
    out.println("Database error: " + e.getMessage());
    e.printStackTrace();
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace();
}
%>