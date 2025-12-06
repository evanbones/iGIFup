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
    String newUserid = request.getParameter("userid"); 
    
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    
    // NEW PARAMETERS
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    
    String password = request.getParameter("password");

    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // 1. If username changed, check if the NEW one is already taken
        if (!newUserid.equals(oldUserid)) {
            String checkSql = "SELECT userid FROM customer WHERE userid = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, newUserid);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                response.sendRedirect("customer.jsp?msg=Username " + newUserid + " is already taken.");
                return;
            }
        }

        // 2. Perform Update
        String sql = "UPDATE customer SET userid=?, firstName=?, lastName=?, email=?, phonenum=?, address=?, city=?, state=?, postalCode=?, country=?, password=? WHERE userid=?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, newUserid);
        pstmt.setString(2, firstName);
        pstmt.setString(3, lastName);
        pstmt.setString(4, email);
        pstmt.setString(5, phonenum);
        pstmt.setString(6, address);
        pstmt.setString(7, city);
        
        // Bind new fields
        pstmt.setString(8, state);
        pstmt.setString(9, postalCode);
        pstmt.setString(10, country);
        
        pstmt.setString(11, password);
        pstmt.setString(12, oldUserid); // Identify record by OLD name
        
        pstmt.executeUpdate();
        
        // 3. Update Session if username changed
        if (!newUserid.equals(oldUserid)) {
            session.setAttribute("authenticatedUser", newUserid);
        }
        
        // Redirect back to profile
        response.sendRedirect("customer.jsp");

    } catch (Exception e) {
        out.println("Error updating profile: " + e);
    }
%>