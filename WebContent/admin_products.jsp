<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Products</title>
    <link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>

    <%-- Security Check: Hardcoded for 'admin' user --%>
    <%
        String authUser = (String) session.getAttribute("authenticatedUser");
        if (authUser == null || !authUser.equals("admin")) { // admin is just the user with the username "admin"
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    
    <div style="text-align:center; margin-bottom:20px;">
        <a href="admin.jsp" class="btn">Back to Dashboard</a>
    </div>

    <h1>Product Management</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    // Actions
    String action = request.getParameter("action");
    String msg = "";
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        if ("add".equals(action)) {
            String sql = "INSERT INTO product (productName, productPrice, productDesc, categoryId, productImageURL) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("name"));
            pstmt.setDouble(2, Double.parseDouble(request.getParameter("price")));
            pstmt.setString(3, request.getParameter("desc"));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("catId")));
            pstmt.setString(5, request.getParameter("img"));
            pstmt.executeUpdate();
            msg = "Product Added Successfully!";
        } else if ("delete".equals(action)) {
            String sql = "DELETE FROM product WHERE productId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
            pstmt.executeUpdate();
            msg = "Product Deleted!";
        } else if ("update".equals(action)) {
             String sql = "UPDATE product SET productName=?, productPrice=?, productDesc=?, categoryId=?, productImageURL=? WHERE productId=?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("name"));
            pstmt.setDouble(2, Double.parseDouble(request.getParameter("price")));
            pstmt.setString(3, request.getParameter("desc"));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("catId")));
            pstmt.setString(5, request.getParameter("img"));
            pstmt.setInt(6, Integer.parseInt(request.getParameter("id")));
            pstmt.executeUpdate();
            msg = "Product Updated!";
        }
    %>
    
    <% if(msg.length() > 0) out.println("<h3 style='color:#00FF00; text-align:center;'>" + msg + "</h3>"); %>

    <div style="display:flex; gap:20px;">
        <div style="flex:1; background:rgba(0,0,0,0.5); padding:20px; border:2px solid yellow;">
            <h2>Add / Edit Product</h2>
            <form method="post" action="admin_products.jsp">
                <input type="hidden" name="action" value="add"> <label>Product Name:</label><br>
                <input type="text" name="name" required style="width:100%"><br><br>
                
                <label>Price:</label><br>
                <input type="text" name="price" required><br><br>
                
                <label>Description:</label><br>
                <textarea name="desc" rows="3" style="width:100%"></textarea><br><br>
                
                <label>Image URL:</label><br>
                <input type="text" name="img" placeholder="img/1.gif" style="width:100%"><br>
                <small style="color:#CCC;">For file upload, rename your file to 'img/X.gif' and place it in the folder manually, then type path here.</small><br><br>
                
                <label>Category ID:</label><br>
                <input type="number" name="catId" required><br><br>
                
                <input type="submit" value="Save Product" class="btn">
            </form>
        </div>

        <div style="flex:2;">
            <h2>Existing Products</h2>
            <table>
                <tr><th>ID</th><th>Name</th><th>Price</th><th>Category</th><th>Action</th></tr>
                <%
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM product ORDER BY productId DESC");
                while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("productId") %></td>
                    <td><%= rs.getString("productName") %></td>
                    <td><%= rs.getDouble("productPrice") %></td>
                    <td><%= rs.getInt("categoryId") %></td>
                    <td>
                        <a href="admin_products.jsp?action=delete&id=<%= rs.getInt("productId") %>" style="color:red;" onclick="return confirm('Delete?');">Delete</a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>

    <% } catch(Exception e) { out.println(e); } %>
</div>
</body>
</html>