<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Inventory</title>
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

    <h1>Inventory Management</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    String action = request.getParameter("action");
    String msg = "";
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // --- HANDLE UPDATES & ADDS ---
        if ("update".equals(action)) {
            String sql = "UPDATE productinventory SET quantity = ?, price = ? WHERE productId = ? AND warehouseId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("quantity")));
            pstmt.setDouble(2, Double.parseDouble(request.getParameter("price")));
            pstmt.setInt(3, Integer.parseInt(request.getParameter("productId")));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("warehouseId")));
            pstmt.executeUpdate();
            msg = "Inventory Updated!";
            
        } else if ("add".equals(action)) {
            // Check if exists first
            String checkSql = "SELECT * FROM productinventory WHERE productId = ? AND warehouseId = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setInt(1, Integer.parseInt(request.getParameter("productId")));
            checkStmt.setInt(2, Integer.parseInt(request.getParameter("warehouseId")));
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                msg = "Error: This product is already in that warehouse. Update it instead.";
            } else {
                String sql = "INSERT INTO productinventory (productId, warehouseId, quantity, price) VALUES (?, ?, ?, ?)";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("productId")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("warehouseId")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("quantity")));
                pstmt.setDouble(4, Double.parseDouble(request.getParameter("price")));
                pstmt.executeUpdate();
                msg = "Product Added to Warehouse!";
            }
        } else if ("delete".equals(action)) {
            String sql = "DELETE FROM productinventory WHERE productId = ? AND warehouseId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("productId")));
            pstmt.setInt(2, Integer.parseInt(request.getParameter("warehouseId")));
            pstmt.executeUpdate();
            msg = "Removed from Warehouse.";
        }
    %>
    
    <% if(msg.length() > 0) out.println("<h3 style='color:#00FF00; text-align:center;'>" + msg + "</h3>"); %>

    <!-- FILTER BAR -->
    <div style="background:rgba(0,0,0,0.5); padding:15px; border:2px solid #FF00FF; margin-bottom:20px; text-align:center;">
        <form method="get" action="admin_inventory.jsp">
            <label style="color:yellow; font-weight:bold;">Filter by Warehouse:</label>
            <select name="filterWarehouse" onchange="this.form.submit()">
                <option value="all">All Warehouses</option>
                <%
                String filterId = request.getParameter("filterWarehouse");
                Statement stmtW = con.createStatement();
                ResultSet rsW = stmtW.executeQuery("SELECT * FROM warehouse");
                while(rsW.next()) {
                    String selected = (filterId != null && filterId.equals(rsW.getString("warehouseId"))) ? "selected" : "";
                    out.println("<option value='" + rsW.getInt("warehouseId") + "' " + selected + ">" + rsW.getString("warehouseName") + "</option>");
                }
                %>
            </select>
        </form>
    </div>

    <div style="display:flex; gap:20px;">
        
        <!-- ADD INVENTORY FORM -->
        <div style="flex:1; background:rgba(0,0,0,0.5); padding:20px; border:2px solid #00FFFF; height:fit-content;">
            <h2>Add Product to Warehouse</h2>
            <form method="post" action="admin_inventory.jsp">
                <input type="hidden" name="action" value="add">
                
                <label>Product:</label><br>
                <select name="productId" style="width:100%; padding:5px;">
                    <%
                    Statement stmtP = con.createStatement();
                    ResultSet rsP = stmtP.executeQuery("SELECT productId, productName FROM product ORDER BY productName");
                    while(rsP.next()) {
                        out.println("<option value='" + rsP.getInt("productId") + "'>" + rsP.getString("productName") + "</option>");
                    }
                    %>
                </select><br><br>

                <label>Warehouse:</label><br>
                <select name="warehouseId" style="width:100%; padding:5px;">
                    <%
                    // Reset Result Set for Warehouse Dropdown
                    rsW = stmtW.executeQuery("SELECT * FROM warehouse ORDER BY warehouseName");
                    while(rsW.next()) {
                        out.println("<option value='" + rsW.getInt("warehouseId") + "'>" + rsW.getString("warehouseName") + "</option>");
                    }
                    %>
                </select><br><br>
                
                <label>Quantity:</label><br>
                <input type="number" name="quantity" value="0" required style="width:100%"><br><br>

                <label>Price in Warehouse:</label><br>
                <input type="text" name="price" value="0.00" required style="width:100%"><br><br>
                
                <input type="submit" value="Add Inventory" class="btn">
            </form>
        </div>

        <!-- INVENTORY LIST -->
        <div style="flex:2;">
            <h2>Current Inventory</h2>
            <table>
                <tr>
                    <th>Product</th>
                    <th>Warehouse</th>
                    <th>Qty</th>
                    <th>Price</th>
                    <th>Action</th>
                </tr>
                <%
                String sqlInv = "SELECT PI.productId, PI.warehouseId, PI.quantity, PI.price, P.productName, W.warehouseName " +
                                "FROM productinventory PI " +
                                "JOIN product P ON PI.productId = P.productId " +
                                "JOIN warehouse W ON PI.warehouseId = W.warehouseId ";
                
                if (filterId != null && !filterId.equals("all")) {
                    sqlInv += "WHERE PI.warehouseId = " + filterId + " ";
                }
                
                sqlInv += "ORDER BY W.warehouseName, P.productName";
                
                Statement stmtInv = con.createStatement();
                ResultSet rsInv = stmtInv.executeQuery(sqlInv);
                NumberFormat curr = NumberFormat.getCurrencyInstance();
                
                while(rsInv.next()){
                    int pId = rsInv.getInt("productId");
                    int wId = rsInv.getInt("warehouseId");
                %>
                <tr>
                    <form method="post" action="admin_inventory.jsp">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="productId" value="<%= pId %>">
                        <input type="hidden" name="warehouseId" value="<%= wId %>">
                        
                        <td><%= rsInv.getString("productName") %></td>
                        <td><%= rsInv.getString("warehouseName") %></td>
                        <td>
                            <input type="number" name="quantity" value="<%= rsInv.getInt("quantity") %>" style="width:60px; color:black;">
                        </td>
                        <td>
                            <input type="text" name="price" value="<%= rsInv.getDouble("price") %>" style="width:80px; color:black;">
                        </td>
                        <td>
                            <input type="submit" value="Save" style="cursor:pointer; background:green; color:white; border:none; padding:5px;">
                            <a href="admin_inventory.jsp?action=delete&productId=<%= pId %>&warehouseId=<%= wId %>" 
                               style="color:red; margin-left:10px; font-size:12px;" 
                               onclick="return confirm('Remove this inventory record?');">X</a>
                        </td>
                    </form>
                </tr>
                <% } %>
            </table>
        </div>
    </div>

    <% } catch(Exception e) { out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>"); } %>
</div>
</body>
</html>