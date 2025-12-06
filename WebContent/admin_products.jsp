<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Products</title>
    <link rel="stylesheet" href="css/listprod.css">
    <style>
        .admin-layout {
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
            align-items: flex-start;
        }

        .admin-panel {
            background: rgba(0, 0, 0, 0.6);
            border: 4px groove #00ffff;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 0 20px #ff00ff, inset 0 0 10px #330066;
        }

        .left-panel {
            flex: 1;
            min-width: 320px;
            border-color: #ff00ff; 
        }

        .right-panel {
            flex: 2;
            min-width: 450px;
        }

        .neon-input {
            width: 95%;
            padding: 10px;
            margin-bottom: 15px;
            background-color: #000022;
            color: #00ffea;
            border: 3px inset #00ffff;
            border-radius: 10px;
            font-family: "Comic Sans MS", cursive;
            font-size: 16px;
            display: block;
        }

        .neon-input:focus {
            outline: none;
            background-color: #000044;
            box-shadow: 0 0 15px cyan;
            border-color: #ffffff;
        }

        label {
            color: #FFFF00;
            font-weight: bold;
            text-shadow: 2px 2px 0px #000;
            display: block;
            margin-bottom: 5px;
            text-align: left;
            font-size: 1.1em;
        }

        h2 {
            margin-top: 0;
            text-shadow: 0 0 10px #ff00ff;
            color: #00ffff;
            border-bottom: 2px dashed #ff00ff;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        
        table { font-size: 14px; }
        td { padding: 8px; vertical-align: middle; }
    </style>
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>

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
    
    String action = request.getParameter("action");
    String msg = "";
    
    String editId = "";
    String editName = "";
    String editPrice = "";
    String editDesc = "";
    String editImg = "";
    String editCatId = "";

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
            try {
                String sql = "DELETE FROM product WHERE productId = ?";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
                pstmt.executeUpdate();
                msg = "Product Deleted!";
            } catch (SQLException e) {
                msg = "Error: Cannot delete product. It is likely referenced in existing orders.";
            }
            
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
            
        } else if ("edit".equals(action)) {
            String sql = "SELECT * FROM product WHERE productId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                editId = rs.getString("productId");
                editName = rs.getString("productName");
                editPrice = rs.getString("productPrice");
                editDesc = rs.getString("productDesc");
                editImg = rs.getString("productImageURL");
                editCatId = rs.getString("categoryId");
            }
        }
    %>
    
    <% if(msg.length() > 0) { %>
        <div style="background:rgba(0,255,0,0.2); border:2px dashed #00FF00; padding:10px; margin-bottom:20px;">
            <h3 style="color:#00FF00; margin:0; text-shadow:1px 1px 2px black;"><%= msg %></h3>
        </div>
    <% } %>

    <div class="admin-layout">
        
        <div class="admin-panel left-panel">
            <h2><%= (action != null && action.equals("edit")) ? "Edit Product (ID: " + editId + ")" : "Add New Product" %></h2>
            
            <form method="post" action="admin_products.jsp">
                <input type="hidden" name="action" value="<%= (action != null && action.equals("edit")) ? "update" : "add" %>">
                <% if(action != null && action.equals("edit")) { %>
                    <input type="hidden" name="id" value="<%= editId %>">
                <% } %>
                
                <label>Product Name:</label>
                <input type="text" name="name" value="<%= editName %>" required class="neon-input">

                <label>Price:</label>
                <input type="text" name="price" value="<%= editPrice %>" required class="neon-input">
                
                <label>Category ID:</label>
                <input type="number" name="catId" value="<%= editCatId %>" required class="neon-input">

                <label>Description:</label>
                <textarea name="desc" rows="4" class="neon-input" style="height:auto;"><%= editDesc %></textarea>
        
                <label>Image URL:</label>
                <input type="text" name="img" value="<%= editImg %>" placeholder="img/1.gif" class="neon-input">
                
                <div style="text-align:center; margin-top:20px;">
                    <input type="submit" value="<%= (action != null && action.equals("edit")) ? "Update Product" : "Save Product" %>" class="btn">
                    
                    <% if(action != null && action.equals("edit")) { %>
                        <br><br>
                        <a href="admin_products.jsp" style="color:cyan; text-decoration:underline;">Cancel Edit</a>
                    <% } %>
                </div>
            </form>
        </div>

        <div class="admin-panel right-panel">
            <h2>Existing Products</h2>
            <table>
                <tr>
                    <th width="5%">ID</th>
                    <th width="20%">Name</th>
                    <th width="10%">Price</th>
                    <th width="10%">Cat ID</th>
                    <th width="20%">Actions</th>
                </tr>
                <%
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM product ORDER BY productId DESC");
                while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("productId") %></td>
                    <td class="product-name"><%= rs.getString("productName") %></td>
                    <td>$<%= rs.getDouble("productPrice") %></td>
                    <td><%= rs.getInt("categoryId") %></td>
                    <td>
                        <a href="admin_products.jsp?action=edit&id=<%= rs.getInt("productId") %>" 
                           style="color:yellow; font-weight:bold; margin-right:10px;">
                           Edit
                        </a> 
                        
                        <a href="admin_products.jsp?action=delete&id=<%= rs.getInt("productId") %>" 
                           style="color:red; font-weight:bold;"
                           onclick="return confirm('Delete this product?');">
                           X
                        </a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>

    <% } catch(Exception e) { 
        out.println("<div class='no-products' style='background:red; border-color:yellow;'><h3>Error</h3><p>" + e.getMessage() + "</p></div>"); 
    } %>
</div>
</body>
</html>