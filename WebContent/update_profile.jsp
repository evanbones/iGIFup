<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
    // Security check: Must be logged in
    String currentUser = (String) session.getAttribute("authenticatedUser");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }

    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    // Retrieve parameters
    String oldUserid = request.getParameter("oldUserid");
    String newUserid = request.getParameter("userid"); // The value from the input box
    
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String password = request.getParameter("password");

    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // 1. If username changed, check if the NEW one is already taken
        if (!newUserid.equals(oldUserid)) {
            String checkSql = "SELECT userid FROM customer WHERE userid = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, newUserid);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                // Username is taken! Redirect back with error
                response.sendRedirect("customer.jsp?msg=Username " + newUserid + " is already taken.");
                return;
            }
        }

        // 2. Perform Update (Including userid)
        // We use 'oldUserid' in the WHERE clause to find the correct row
        String sql = "UPDATE customer SET userid=?, firstName=?, lastName=?, email=?, phonenum=?, address=?, city=?, password=? WHERE userid=?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, newUserid);
        pstmt.setString(2, firstName);
        pstmt.setString(3, lastName);
        pstmt.setString(4, email);
        pstmt.setString(5, phonenum);
        pstmt.setString(6, address);
        pstmt.setString(7, city);
        pstmt.setString(8, password);
        pstmt.setString(9, oldUserid); // Identify record by OLD name
        
        pstmt.executeUpdate();
        
        // 3. Update Session if username changed
        // If we don't do this, the website will think they are still 'oldUserid' 
        // which no longer exists in the DB, causing errors on page load.
        if (!newUserid.equals(oldUserid)) {
            session.setAttribute("authenticatedUser", newUserid);
        }
        
        // Redirect back to profile
        response.sendRedirect("customer.jsp");

    } catch (Exception e) {
        out.println("Error updating profile: " + e);
    }
%>