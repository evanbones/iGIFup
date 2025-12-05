<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<%
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList == null) {
        productList = new HashMap<String, ArrayList<Object>>();
    }

    // 2. Get Parameters from the Form/Link
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String priceStr = request.getParameter("price");
    String action = request.getParameter("action"); // 'add', 'update', or 'delete'
    String qtyStr = request.getParameter("quantity");

    // Defaults
    if (action == null || action.isEmpty()) action = "add";
    
    // Parse numeric values safely
    double price = 0.0;
    int quantity = 1;
    try {
        if (priceStr != null) price = Double.parseDouble(priceStr);
        if (qtyStr != null) quantity = Integer.parseInt(qtyStr);
    } catch (NumberFormatException e) {
        // Keep defaults
    }

    if (action.equals("delete")) {
        if (productList.containsKey(id)) {
            productList.remove(id);
        }
    } 
    else if (action.equals("update")) {
        if (quantity <= 0) {
            productList.remove(id); // If user types 0, delete it
        } else if (productList.containsKey(id)) {
            ArrayList<Object> product = productList.get(id);
            product.set(3, quantity); // Update the quantity index
        }
    } 
    else {
        if (productList.containsKey(id)) {
            // Item exists, increment quantity
            ArrayList<Object> product = productList.get(id);
            int currentQty = (Integer) product.get(3);
            product.set(3, currentQty + 1);
        } else {
            // New item, add to list
            ArrayList<Object> product = new ArrayList<Object>();
            product.add(id);
            product.add(name);
            product.add(price);
            product.add(quantity);
            productList.put(id, product);
        }
    }

    // Save updated list back to session
    session.setAttribute("productList", productList);

    String user = (String) session.getAttribute("authenticatedUser");
    
    if (user != null) {
        // Only save to DB if user is logged in
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";

        try (Connection con = DriverManager.getConnection(url, uid, pw)) {
            
          Integer dbOrderId = null;
            int customerId = -1;

            // Get the Customer ID for the logged-in user
            String custSql = "SELECT customerId FROM customer WHERE userid = ?";
            try (PreparedStatement custStmt = con.prepareStatement(custSql)) {
                custStmt.setString(1, user);
                try (ResultSet custRs = custStmt.executeQuery()) {
                    if (custRs.next()) {
                        customerId = custRs.getInt("customerId");
                    }
                }
            }

            if (customerId != -1) {
                // Find an "Active" Order (One that is NOT in the orderproduct table yet)
                String findOrderSql = "SELECT orderId FROM ordersummary " +
                                      "WHERE customerId = ? " +
                                      "AND orderId NOT IN (SELECT orderId FROM orderproduct)";
                
                try (PreparedStatement findStmt = con.prepareStatement(findOrderSql)) {
                    findStmt.setInt(1, customerId);
                    try (ResultSet findRs = findStmt.executeQuery()) {
                        if (findRs.next()) {
                            // Found an existing cart!
                            dbOrderId = findRs.getInt("orderId");
                        }
                    }
                }

                // If no active order exists, create a new one
                if (dbOrderId == null) {
                    String createSql = "INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), 0.0)";
                    // We use RETURN_GENERATED_KEYS to get the new orderId immediately
                    try (PreparedStatement createStmt = con.prepareStatement(createSql, Statement.RETURN_GENERATED_KEYS)) {
                        createStmt.setInt(1, customerId);
                        createStmt.executeUpdate();
                        try (ResultSet genKeys = createStmt.getGeneratedKeys()) {
                            if (genKeys.next()) {
                                dbOrderId = genKeys.getInt(1);
                            }
                        }
                    }
                }
            }

            if (dbOrderId != null) {
                if (action.equals("delete")) {
                    String delSql = "DELETE FROM incart WHERE orderId = ? AND productId = ?";
                    PreparedStatement pstmt = con.prepareStatement(delSql);
                    pstmt.setInt(1, dbOrderId);
                    pstmt.setInt(2, Integer.parseInt(id));
                    pstmt.executeUpdate();
                } 
                else if (action.equals("update")) {
                    String upSql = "UPDATE incart SET quantity = ? WHERE orderId = ? AND productId = ?";
                    PreparedStatement pstmt = con.prepareStatement(upSql);
                    pstmt.setInt(1, quantity);
                    pstmt.setInt(2, dbOrderId);
                    pstmt.setInt(3, Integer.parseInt(id));
                    pstmt.executeUpdate();
                } 
                else { 
                    // ADD - Check if exists first (Upsert)
                    String checkSql = "SELECT quantity FROM incart WHERE orderId = ? AND productId = ?";
                    PreparedStatement checkStmt = con.prepareStatement(checkSql);
                    checkStmt.setInt(1, dbOrderId);
                    checkStmt.setInt(2, Integer.parseInt(id));
                    ResultSet rs = checkStmt.executeQuery();
                    
                    if (rs.next()) {
                        // Exists in DB, update it
                        String incSql = "UPDATE incart SET quantity = quantity + 1 WHERE orderId = ? AND productId = ?";
                        PreparedStatement upStmt = con.prepareStatement(incSql);
                        upStmt.setInt(1, dbOrderId);
                        upStmt.setInt(2, Integer.parseInt(id));
                        upStmt.executeUpdate();
                    } else {
                        // Insert new
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
        } catch (SQLException e) {
            System.out.println("Database Cart Error: " + e);
        }
    }

    // 5. Redirect back to Cart
    response.sendRedirect("showcart.jsp");
%>