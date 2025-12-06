<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Inventory</title>
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
            min-width: 300px;
            border-color: #ff00ff;
        }

        .right-panel {
            flex: 2;
            min-width: 500px;
        }

        .neon-input, select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            background-color: #000022;
            color: #00ffea;
            border: 3px inset #00ffff;
            border-radius: 10px;
            font-family: "Comic Sans MS", cursive;
            font-size: 16px;
            display: block;
            box-sizing: border-box;
        }

        .neon-input:focus, select:focus {
            outline: none;
            background-color: #000044;
            box-shadow: 0 0 15px cyan;
            border-color: #ffffff;
        }

        .table-input {
            width: 80px;
            padding: 5px;
            background: rgba(0,0,0,0.3);
            border: 1px solid #00ffff;
            color: yellow;
            border-radius: 5px;
            text-align: center;
        }

        .btn-save {
            background: linear-gradient(#00aa00, #006600);
            color: white;
            border: 2px outset #00ff00;
            padding: 5px 10px;
            cursor: pointer;
            font-weight: bold;
            border-radius: 5px;
        }
        .btn-save:hover { background: #00ff00; color: black; }

        .btn-delete {
            background: linear-gradient(#aa0000, #660000);
            color: white;
            border: 2px outset #ff0000;
            padding: 5px 10px;
            cursor: pointer;
            font-weight: bold;
            border-radius: 5px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-delete:hover { background: red; }

        .filter-box {
            background: rgba(0, 0, 0, 0.6);
            border: 2px dashed #00ffcc;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
            border-radius: 15px;
        }

        label { color: #FFFF00; font-weight: bold; text-shadow: 1px 1px 0px black; }
        h2 { margin-top: 0; color: #00ffff; text-shadow: 0 0 10px #ff00ff; border-bottom: 2px dashed #ff00ff; padding-bottom: 10px; margin-bottom: 20px; }
    </style>
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>

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
    
    <% if(msg.length() > 0) { %>
        <div style="background:rgba(0,255,0,0.2); border:2px dashed #00FF00; padding:10px; margin-bottom:20px; text-align:center;">
            <h3 style="color:#00FF00; margin:0; text-shadow:1px 1px 2px black;"><%= msg %></h3>
        </div>
    <% } %>

    <div class="filter-box">
        <form method="get" action="admin_inventory.jsp" style="display:flex; justify-content:center; align-items:center; gap:15px;">
            <label style="font-size:18px;">Filter by Warehouse:</label>
            <select name="filterWarehouse" onchange="this.form.submit()" style="width:auto; margin-bottom:0; display:inline-block;">
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

    <div class="admin-layout">
        
        <div class="admin-panel left-panel">
            <h2>Add Inventory</h2>
    
            <form method="post" action="admin_inventory.jsp">
                <input type="hidden" name="action" value="add">
                
                <label>Product:</label>
                <select name="productId">
                    <%
                    Statement stmtP = con.createStatement();
                    ResultSet rsP = stmtP.executeQuery("SELECT productId, productName FROM product ORDER BY productName");
                    while(rsP.next()) {
                        out.println("<option value='" + rsP.getInt("productId") + "'>" + rsP.getString("productName") + "</option>");
                    }
                    %>
                </select>

                <label>Warehouse:</label>
                <select name="warehouseId">
                    <%
                    rsW = stmtW.executeQuery("SELECT * FROM warehouse ORDER BY warehouseName");
                    while(rsW.next()) {
                        out.println("<option value='" + rsW.getInt("warehouseId") + "'>" + rsW.getString("warehouseName") + "</option>");
                    }
                    %>
                </select>
                
                <label>Quantity:</label>
                <input type="number" name="quantity" value="0" required class="neon-input">

                <label>Price in Warehouse:</label>
                <input type="text" name="price" value="0.00" required class="neon-input">
                
                <div style="text-align:center; margin-top:20px;">
                    <input type="submit" value="Add Inventory" class="btn">
                </div>
            </form>
        </div>

        <div class="admin-panel right-panel">
            <h2>Current Inventory</h2>
            <table style="font-size:14px;">
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
                
                while(rsInv.next()){
                    int pId = rsInv.getInt("productId");
                    int wId = rsInv.getInt("warehouseId");
                %>
                <tr>
                    <form method="post" action="admin_inventory.jsp">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="productId" value="<%= pId %>">
                        <input type="hidden" name="warehouseId" value="<%= wId %>">
                        
                        <td style="color:cyan; font-weight:bold;"><%= rsInv.getString("productName") %></td>
                        <td><%= rsInv.getString("warehouseName") %></td>
                        
                        <td>
                            <input type="number" name="quantity" value="<%= rsInv.getInt("quantity") %>" class="table-input">
                        </td>
                        <td>
                            <input type="text" name="price" value="<%= rsInv.getDouble("price") %>" class="table-input">
                        </td>
                        <td style="white-space:nowrap;">
                            <input type="submit" value="Save" class="btn-save">
                            <a href="admin_inventory.jsp?action=delete&productId=<%= pId %>&warehouseId=<%= wId %>" 
                               class="btn-delete"
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