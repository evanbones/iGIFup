<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet", href="css/listprod.css">
<title>iGifUp Product Catalog</title>
</head>
<body>
<div class="page-container">

<%@ include file="header.jsp" %>

<h1>Product Catalog</h1>

<div class="search-container">
    <h2>Search Products</h2>
    <form method="get" action="listprod.jsp" class="search-form">
        <input type="text" name="productName" size="50" placeholder="Enter product name..." 
               value="<%= request.getParameter("productName") != null ? request.getParameter("productName") : "" %>">
        
        <select name="categoryId">
            <option value="">All Categories</option>
            <%
            String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
            String uid = "sa";
            String pw = "304#sa#pw";
            
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            } catch (java.lang.ClassNotFoundException e) {
                out.println("ClassNotFoundException: " + e);
            }
            
            String selectedCategory = request.getParameter("categoryId");
            
            // Get all categories for dropdown
            try (Connection con = DriverManager.getConnection(url, uid, pw);
                 Statement stmt = con.createStatement();
                 ResultSet rsCategories = stmt.executeQuery("SELECT categoryId, categoryName FROM category ORDER BY categoryName")) {
                
                while (rsCategories.next()) {
                    int catId = rsCategories.getInt("categoryId");
                    String catName = rsCategories.getString("categoryName");
                    String selected = (selectedCategory != null && selectedCategory.equals(String.valueOf(catId))) ? "selected" : "";
                    out.println("<option value='" + catId + "' " + selected + ">" + catName + "</option>");
                }
            } catch (SQLException e) {
                out.println("Error loading categories: " + e.getMessage());
            }
            %>
        </select>
        
        <input type="submit" value="Search">
        <input type="reset" value="Reset">
    </form>
    <p class="filter-note">Leave product name blank to show all products. Select a category to filter by category.</p>
</div>

<% 
String name = request.getParameter("productName");
String categoryId = request.getParameter("categoryId");

String sql = "SELECT p.productId, p.productName, p.productPrice, c.categoryName " +
             "FROM product p LEFT JOIN category c ON p.categoryId = c.categoryId WHERE 1=1";

boolean hasNameFilter = (name != null && !name.trim().isEmpty());
boolean hasCategoryFilter = (categoryId != null && !categoryId.trim().isEmpty());

if (hasNameFilter) {
    sql += " AND p.productName LIKE ?";
}
if (hasCategoryFilter) {
    sql += " AND p.categoryId = ?";
}

sql += " ORDER BY p.productName";

try (Connection con = DriverManager.getConnection(url, uid, pw);
     PreparedStatement pstmt = con.prepareStatement(sql)) {
    
    int paramIndex = 1;
    if (hasNameFilter) {
        pstmt.setString(paramIndex++, "%" + name + "%");
    }
    if (hasCategoryFilter) {
        pstmt.setInt(paramIndex++, Integer.parseInt(categoryId));
    }

    try (ResultSet rs = pstmt.executeQuery()) {

        if (!rs.isBeforeFirst()) {
            out.println("<div class='no-products'>");
            out.println("<h3>No products found</h3>");
            out.println("<p>Try adjusting your search criteria.</p>");
            out.println("</div>");
        } else {
            out.println("<h2>Available Products</h2>");
            out.println("<table>");
            out.println("<tr><th>Product Name</th><th>Category</th><th>Price</th><th>Add to Cart</th></tr>");
            
            NumberFormat currFormat = NumberFormat.getCurrencyInstance();
            
            while (rs.next()) {
                int productId = rs.getInt("productId");
                String productName = rs.getString("productName");
                double price = rs.getDouble("productPrice");
                String category = rs.getString("categoryName");
                if (category == null) category = "Uncategorized";
                
                String formattedPrice = currFormat.format(price);
                String productLink = "product.jsp?id=" + productId;
                String addToCartLink = "addcart.jsp?id=" + productId + "&name=" + URLEncoder.encode(productName, "UTF-8") + "&price=" + price;
                
                out.println("<tr>");
                out.println("<td class='product-name'><a href='" + productLink + "'>" + productName + "</a></td>");
                out.println("<td>" + category + "</td>");
                out.println("<td class='price'>" + formattedPrice + "</td>");
                out.println("<td align='center'><a href='" + addToCartLink + "' class='add-cart-link'>Add to Cart</a></td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
        }
    }
    
} catch (SQLException e) {
    out.println("<div class='no-products' style='background-color: #ffebee; color: #c62828;'>");
    out.println("<h3>Database Error</h3>");
    out.println("<p>Error connecting to or querying the database.</p>");
    out.println("<pre>" + e.toString() + "</pre>");
    out.println("</div>");
} catch (Exception e) {
    out.println("<div class='no-products' style='background-color: #ffebee; color: #c62828;'>");
    out.println("<h3>Error</h3>");
    out.println("<p>An error occurred: " + e.toString() + "</p>");
    out.println("</div>");
}
%>
</div>
</body>
</html>