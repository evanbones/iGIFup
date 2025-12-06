<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>iGifUp - Product Information</title>
<link rel="stylesheet" href="css/product.css">
<style>
    .inventory-section {
        margin: 15px 0;
        padding: 10px;
        background: rgba(0, 0, 0, 0.3);
        border: 2px dashed #00ff00;
    }
    .inventory-section h4 {
        margin-top: 0;
        color: #ffff00;
        border-bottom: 1px dotted #ff00ff;
    }
    .inventory-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 5px;
        color: #fff;
        font-size: 0.9em;
    }
    .inventory-table th {
        text-align: left;
        border-bottom: 1px solid #00ff00;
        color: #00ff00;
        padding: 4px;
    }
    .inventory-table td {
        padding: 4px;
        border-bottom: 1px solid #333;
    }
    /* New styles for the Add to Cart form */
    .add-cart-form {
        margin-top: 20px;
        background: rgba(255, 255, 255, 0.1);
        padding: 15px;
        border-radius: 10px;
        border: 1px solid #00ffff;
    }
    .add-cart-form select {
        padding: 8px;
        border-radius: 5px;
        background: #000;
        color: #fff;
        border: 1px solid #00ff00;
        margin-right: 10px;
    }
</style>
</head>
<body>
<div class="page-container">
<%@ include file="header.jsp" %>

<%
String productId = request.getParameter("id");

if (productId == null || productId.isEmpty()) {
    out.println("<h3>No product ID specified.</h3>");
} else {
    int idVal = -1;
    try { idVal = Integer.parseInt(productId); } catch(Exception e){}
    
    String sql = "SELECT p.productId, p.productName, p.productPrice, p.productDesc, " +
                 "p.productImageURL, p.productImage, c.categoryName " +
                 "FROM product p LEFT JOIN category c ON p.categoryId = c.categoryId " +
                 "WHERE p.productId = ?";
    
    try {
        getConnection();
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, idVal);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int pid = rs.getInt("productId");
            String productName = rs.getString("productName");
            double price = rs.getDouble("productPrice");
            String description = rs.getString("productDesc");
            String imageURL = rs.getString("productImageURL");
            String categoryName = rs.getString("categoryName");
            if (categoryName == null) categoryName = "Uncategorized";
            
            NumberFormat currFormat = NumberFormat.getCurrencyInstance();
            String formattedPrice = currFormat.format(price);
            
            out.println("<div class='product-detail'>");
            out.println("<h1 class='product-title'>" + productName + "</h1>");
            out.println("<div class='product-content'>");
            
            // Image Section
            out.println("<div class='product-images'>");
            if (imageURL != null && !imageURL.trim().isEmpty()) {
                out.println("<div><img src='" + request.getContextPath() + "/" + imageURL + "' alt='" + productName + "'></div>");
            }
            out.println("</div>");
            
            // Info Section
            out.println("<div class='product-info'>");
            out.println("<p><strong>Category:</strong> " + categoryName + "</p>");
            out.println("<p class='price'>" + formattedPrice + "</p>");
            
            // --- INVENTORY DISPLAY ---
            out.println("<div class='inventory-section'>");
            out.println("<h4>Current Stock Status</h4>");
            
            // We'll store the results to populate the dropdown later without re-querying
            // Using a simple HTML string builder approach for the dropdown options
            StringBuilder dropdownOptions = new StringBuilder();
            boolean productAvailable = false;

            String invSql = "SELECT w.warehouseId, w.warehouseName, pi.quantity " +
                            "FROM productinventory pi " +
                            "JOIN warehouse w ON pi.warehouseId = w.warehouseId " +
                            "WHERE pi.productId = ? " +
                            "ORDER BY pi.quantity DESC";
                            
            PreparedStatement pstmtInv = con.prepareStatement(invSql);
            pstmtInv.setInt(1, pid);
            ResultSet rsInv = pstmtInv.executeQuery();
            
            out.println("<table class='inventory-table'>");
            out.println("<tr><th>Warehouse</th><th>Quantity</th></tr>");
            
            while(rsInv.next()){
                int wId = rsInv.getInt("warehouseId");
                int qty = rsInv.getInt("quantity");
                String wName = rsInv.getString("warehouseName");
                String qtyStyle = (qty < 5) ? "color:#ff5555; font-weight:bold;" : "color:#00ffff;";
                
                out.println("<tr>");
                out.println("<td>" + wName + "</td>");
                out.println("<td style='" + qtyStyle + "'>" + qty + "</td>");
                out.println("</tr>");

                // Build dropdown options for warehouses that have stock
                if (qty > 0) {
                    productAvailable = true;
                    dropdownOptions.append("<option value='" + wId + "'>" + wName + " (" + qty + " available)</option>");
                }
            }
            out.println("</table>");
            out.println("</div>");
            rsInv.close();
            pstmtInv.close();
            
            // Description
            if (description != null) {
                out.println("<div class='description'><h3>Description</h3><p>" + description + "</p></div>");
            }
            
            // --- ADD TO CART FORM (Replaces the old Link) ---
            if (productAvailable) {
                out.println("<form action='addcart.jsp' method='get' class='add-cart-form'>");
                out.println("<input type='hidden' name='id' value='" + pid + "'>");
                out.println("<input type='hidden' name='name' value='" + productName + "'>");
                out.println("<input type='hidden' name='price' value='" + price + "'>");
                
                out.println("<label for='warehouseId' style='color:#FFFF00; font-weight:bold;'>Select Warehouse:</label><br>");
                out.println("<select name='warehouseId' required>");
                out.println(dropdownOptions.toString());
                out.println("</select>");
                
                out.println("<input type='submit' value='Add to Cart' class='btn btn-cart' style='margin-top:10px; cursor:pointer;'>");
                out.println("</form>");
            } else {
                out.println("<div style='color:red; font-weight:bold; border:2px solid red; padding:10px; margin-top:20px;'>Out of Stock</div>");
            }

            out.println("<div class='action-links' style='margin-top:10px;'>");
            out.println("<a href='listprod.jsp' class='btn btn-continue'>Continue Shopping</a>");
            out.println("</div>");
            
            out.println("</div></div></div>"); // Close info, content, detail
        }
        rs.close();
        pstmt.close();
    } catch (Exception ex) {
        out.println("Error: " + ex.getMessage());
    }
}
%>
</div>
</body>
</html>