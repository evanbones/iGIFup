<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Warehouses</title>
    <link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>
    
    <%-- Security Check --%>
    <%
        String authUser = (String) session.getAttribute("authenticatedUser");
        if (authUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <div style="text-align:center; margin-bottom:20px;">
        <a href="admin.jsp" class="btn">Back to Dashboard</a>
    </div>

    <h1>Warehouse Management</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    String action = request.getParameter("action");
    String msg = "";
    
    // Variables for Editing
    String editId = "";
    String editName = "";
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // --- HANDLE ACTIONS ---
        if ("add".equals(action)) {
            String sql = "INSERT INTO warehouse (warehouseName) VALUES (?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("warehouseName"));
            pstmt.executeUpdate();
            msg = "Warehouse Added!";
            
        } else if ("delete".equals(action)) {
            // Check constraints? Usually safe if ON DELETE NO ACTION is set, DB will throw error if used.
            try {
                String sql = "DELETE FROM warehouse WHERE warehouseId = ?";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
                pstmt.executeUpdate();
                msg = "Warehouse Deleted!";
            } catch (SQLException e) {
                msg = "Error: Cannot delete warehouse. It likely contains products or shipments.";
            }
            
        } else if ("update".equals(action)) {
            String sql = "UPDATE warehouse SET warehouseName=? WHERE warehouseId=?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("warehouseName"));
            pstmt.setInt(2, Integer.parseInt(request.getParameter("id")));
            pstmt.executeUpdate();
            msg = "Warehouse Updated!";
            
        } else if ("edit".equals(action)) {
            String sql = "SELECT * FROM warehouse WHERE warehouseId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                editId = rs.getString("warehouseId");
                editName = rs.getString("warehouseName");
            }
        }
    %>
    
    <% if(msg.length() > 0) out.println("<h3 style='color:#00FF00; text-align:center;'>" + msg + "</h3>"); %>

    <div style="display:flex; gap:20px;">
        
        <!-- ADD / EDIT FORM -->
        <div style="flex:1; background:rgba(0,0,0,0.5); padding:20px; border:2px solid #00FFFF;">
            <h2><%= (action != null && action.equals("edit")) ? "Edit Warehouse" : "Add New Warehouse" %></h2>
            
            <form method="post" action="admin_warehouses.jsp">
                <input type="hidden" name="action" value="<%= (action != null && action.equals("edit")) ? "update" : "add" %>">
                <% if(action != null && action.equals("edit")) { %>
                    <input type="hidden" name="id" value="<%= editId %>">
                <% } %>
                
                <label>Warehouse Name:</label><br>
                <input type="text" name="warehouseName" value="<%= editName %>" required style="width:100%"><br><br>
                
                <input type="submit" value="<%= (action != null && action.equals("edit")) ? "Update Warehouse" : "Add Warehouse" %>" class="btn">
                <% if(action != null && action.equals("edit")) { %>
                    <a href="admin_warehouses.jsp" class="btn" style="background:gray;">Cancel</a>
                <% } %>
            </form>
        </div>

        <!-- WAREHOUSE LIST -->
        <div style="flex:2;">
            <h2>Warehouse List</h2>
            <table>
                <tr><th>ID</th><th>Name</th><th>Actions</th></tr>
                <%
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM warehouse ORDER BY warehouseId ASC");
                while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("warehouseId") %></td>
                    <td><%= rs.getString("warehouseName") %></td>
                    <td>
                        <a href="admin_warehouses.jsp?action=edit&id=<%= rs.getInt("warehouseId") %>" style="color:#FFFF00;">Edit</a> | 
                        <a href="admin_warehouses.jsp?action=delete&id=<%= rs.getInt("warehouseId") %>" style="color:red;" onclick="return confirm('Delete this warehouse?');">Delete</a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>

    <% } catch(Exception e) { out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>"); } %>
</div>
</body>
</html>