<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    // Retrieve parameters
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    String userid = request.getParameter("userid");
    String password = request.getParameter("password");

    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        // Check if user exists
        String checkSql = "SELECT userid FROM customer WHERE userid = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, userid);
        ResultSet rs = checkStmt.executeQuery();

        if (rs.next()) {
            // User exists
            out.println("<script>alert('Username already taken!'); window.location='signup.jsp';</script>");
        } else {
            // Insert new user
            String sql = "INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, email);
            pstmt.setString(4, phonenum);
            pstmt.setString(5, address);
            pstmt.setString(6, city);
            pstmt.setString(7, state);
            pstmt.setString(8, postalCode);
            pstmt.setString(9, country);
            pstmt.setString(10, userid);
            pstmt.setString(11, password);
            
            pstmt.executeUpdate();
            
            // Auto-login (Optional: or redirect to login)
            session.setAttribute("authenticatedUser", userid);
            response.sendRedirect("index.jsp");
        }
    } catch (Exception e) {
        out.println("Error: " + e);
    }
%>