<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart</title>
<link rel="stylesheet" href="css/listprod.css">
<script>
    function validateUpdate(form) {
        var qty = form.newQty.value;
        if (isNaN(qty) || qty < 0) {
            alert("Please enter a valid quantity.");
            return false;
        }
        return true;
    }
</script>
</head>
<body>
<div class="page-container">
<%@ include file="header.jsp" %>

<%
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null || productList.isEmpty()) {    
    out.println("<div class='gradient-container'>");
    out.println("<h1>Your Shopping Cart is Empty!</h1>");
    out.println("<p><a href='listprod.jsp' class='btn'>Start Shopping</a></p>");
    out.println("</div>");
} else {
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    // Connect to DB to look up Warehouse names
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
    
        out.println("<h1>Your Shopping Cart</h1>");
        out.println("<table>");
        out.println("<tr><th>Product ID</th><th>Product Name</th><th>Warehouse</th><th>Quantity</th><th>Price</th><th>Subtotal</th><th>Remove</th></tr>");

        double total = 0;
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
        
        while (iterator.hasNext()) {    
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
            
            String productId = (String) product.get(0);
            String productName = (String) product.get(1);
            double price = Double.parseDouble(product.get(2).toString());
            int qty = Integer.parseInt(product.get(3).toString());
            
            // Check for Warehouse ID (stored at index 4)
            String warehouseName = "Auto-Assign";
            if (product.size() > 4 && product.get(4) != null) {
                int wId = Integer.parseInt(product.get(4).toString());
                if (wId > 0) {
                    // Look up the name
                    String wSql = "SELECT warehouseName FROM warehouse WHERE warehouseId = ?";
                    try (PreparedStatement wStmt = con.prepareStatement(wSql)) {
                        wStmt.setInt(1, wId);
                        ResultSet rsW = wStmt.executeQuery();
                        if (rsW.next()) {
                            warehouseName = rsW.getString("warehouseName");
                        }
                    }
                }
            }

            out.print("<tr>");
            out.print("<td>" + productId + "</td>");
            out.print("<td>" + productName + "</td>");
            
            // NEW COLUMN: WAREHOUSE
            out.print("<td style='font-size:0.9em; color:#ffff00;'>" + warehouseName + "</td>");

            out.print("<td align='center'>");
            out.print("<form method='get' action='addcart.jsp' onsubmit='return validateUpdate(this);' style='margin:0;'>");
            out.print("<input type='hidden' name='id' value='" + productId + "'>");
            out.print("<input type='hidden' name='name' value='" + productName + "'>");
            out.print("<input type='hidden' name='price' value='" + price + "'>");
            out.print("<input type='hidden' name='action' value='update'>"); 
            out.print("<input type='text' name='quantity' value='" + qty + "' size='3' style='text-align:center;'> ");
            out.print("<input type='submit' value='Update' class='btn-small'>");
            out.print("</form>");
            out.print("</td>");

            out.print("<td align='right'>" + currFormat.format(price) + "</td>");
            out.print("<td align='right'>" + currFormat.format(price * qty) + "</td>");
            
            out.print("<td align='center'><a href='addcart.jsp?id=" + productId + "&action=delete' style='color:red;'>Remove</a></td>");
            
            out.println("</tr>");
            total = total + (price * qty);
        }
        
        out.println("<tr class='total-row'><td colspan='7' align='right'><b>Order Total: " + currFormat.format(total) + "</b></td></tr>");
        out.println("</table>");

        out.println("<div class='action-links'>");
        out.println("<a href='checkout.jsp' class='add-cart-link'>Proceed to Checkout</a>");
        out.println("<a href='listprod.jsp' class='add-cart-link'>Continue Shopping</a>");
        out.println("</div>");
        
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
}
%>
</div>
</body>
</html>