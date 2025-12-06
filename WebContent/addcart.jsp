<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<%
    // 1. Get the Cart from Session
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList == null) {
        productList = new HashMap<String, ArrayList<Object>>();
    }

    // 2. Get Parameters
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String priceStr = request.getParameter("price");
    String action = request.getParameter("action"); 
    String qtyStr = request.getParameter("quantity");
    String warehouseStr = request.getParameter("warehouseId"); // NEW PARAMETER

    if (action == null || action.isEmpty()) action = "add";
    
    double price = 0.0;
    int quantity = 1;
    int warehouseId = 0; // 0 means "Any" or "Not Specified"

    try {
        if (priceStr != null) price = Double.parseDouble(priceStr);
        if (qtyStr != null) quantity = Integer.parseInt(qtyStr);
        if (warehouseStr != null) warehouseId = Integer.parseInt(warehouseStr);
    } catch (NumberFormatException e) {
    }

    // 3. Update Session Map
    if (action.equals("delete")) {
        if (productList.containsKey(id)) productList.remove(id);
    } 
    else if (action.equals("update")) {
        if (quantity <= 0) {
            productList.remove(id);
        } else if (productList.containsKey(id)) {
            ArrayList<Object> product = productList.get(id);
            product.set(3, quantity);
        }
    } 
    else {
        // ADD
        if (productList.containsKey(id)) {
            // Item exists, increment quantity
            ArrayList<Object> product = productList.get(id);
            int currentQty = (Integer) product.get(3);
            product.set(3, currentQty + 1);
            
            // If user selected a specific warehouse this time, update preference
            if (warehouseId > 0) {
                if (product.size() > 4) product.set(4, warehouseId);
                else product.add(warehouseId);
            }
        } else {
            // New item
            ArrayList<Object> product = new ArrayList<Object>();
            product.add(id);       // 0
            product.add(name);     // 1
            product.add(price);    // 2
            product.add(quantity); // 3
            product.add(warehouseId); // 4 (New Warehouse ID)
            productList.put(id, product);
        }
    }

    session.setAttribute("productList", productList);

    // 4. Database Sync (Optional - Warehouse ID is not stored in incart table by default schema)
    // We keep the existing logic to ensure cart persists, even if warehouse preference is lost on logout
    String user = (String) session.getAttribute("authenticatedUser");
    if (user != null) {
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";

        try (Connection con = DriverManager.getConnection(url, uid, pw)) {
            
            // Retrieve Customer ID
            int customerId = -1;
            String custSql = "SELECT customerId FROM customer WHERE userid = ?";
            PreparedStatement custStmt = con.prepareStatement(custSql);
            custStmt.setString(1, user);
            ResultSet custRs = custStmt.executeQuery();
            if (custRs.next()) customerId = custRs.getInt("customerId");
            custRs.close();
            custStmt.close();

            if (customerId != -1) {
                // Find or Create Cart Order
                Integer dbOrderId = null;
                String findOrderSql = "SELECT orderId FROM ordersummary WHERE customerId = ? AND orderId NOT IN (SELECT orderId FROM orderproduct)";
                PreparedStatement findStmt = con.prepareStatement(findOrderSql);
                findStmt.setInt(1, customerId);
                ResultSet findRs = findStmt.executeQuery();
                if (findRs.next()) dbOrderId = findRs.getInt("orderId");
                findRs.close();
                findStmt.close();

                if (dbOrderId == null) {
                    String createSql = "INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), 0.0)";
                    PreparedStatement createStmt = con.prepareStatement(createSql, Statement.RETURN_GENERATED_KEYS);
                    createStmt.setInt(1, customerId);
                    createStmt.executeUpdate();
                    ResultSet genKeys = createStmt.getGeneratedKeys();
                    if (genKeys.next()) dbOrderId = genKeys.getInt(1);
                    genKeys.close();
                    createStmt.close();
                }

                // Sync Items
                if (dbOrderId != null) {
                    if (action.equals("delete")) {
                        String delSql = "DELETE FROM incart WHERE orderId = ? AND productId = ?";
                        PreparedStatement pstmt = con.prepareStatement(delSql);
                        pstmt.setInt(1, dbOrderId);
                        pstmt.setInt(2, Integer.parseInt(id));
                        pstmt.executeUpdate();
                    } else if (action.equals("update")) {
                        String upSql = "UPDATE incart SET quantity = ? WHERE orderId = ? AND productId = ?";
                        PreparedStatement pstmt = con.prepareStatement(upSql);
                        pstmt.setInt(1, quantity);
                        pstmt.setInt(2, dbOrderId);
                        pstmt.setInt(3, Integer.parseInt(id));
                        pstmt.executeUpdate();
                    } else {
                        // Add/Upsert
                        String checkSql = "SELECT quantity FROM incart WHERE orderId = ? AND productId = ?";
                        PreparedStatement checkStmt = con.prepareStatement(checkSql);
                        checkStmt.setInt(1, dbOrderId);
                        checkStmt.setInt(2, Integer.parseInt(id));
                        ResultSet rs = checkStmt.executeQuery();
                        if (rs.next()) {
                            String incSql = "UPDATE incart SET quantity = quantity + 1 WHERE orderId = ? AND productId = ?";
                            PreparedStatement upStmt = con.prepareStatement(incSql);
                            upStmt.setInt(1, dbOrderId);
                            upStmt.setInt(2, Integer.parseInt(id));
                            upStmt.executeUpdate();
                        } else {
                            String inSql = "INSERT INTO incart (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
                            PreparedStatement inStmt = con.prepareStatement(inSql);
                            inStmt.setInt(1, dbOrderId);
                            inStmt.setInt(2, Integer.parseInt(id));
                            inStmt.setInt(3, quantity);
                            inStmt.setDouble(4, price);
                            inStmt.executeUpdate();
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Database Cart Error: " + e);
        }
    }

    response.sendRedirect("showcart.jsp");
%>