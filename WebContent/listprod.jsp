<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>iGifUp Grocery</title>
</head>
<body>

<h1>Search for the products you want to buy:</h1>

<form method="get" action="listprod.jsp">
<input type="text" name="productName" size="50">
<input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
</form>

<% 
String name = request.getParameter("productName");

//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

String sql = "";

// If 'name' is empty or null, select all products.
if (name == null || name.trim().isEmpty()) {
    sql = "SELECT productId, productName, productPrice FROM product";
} else {
    // Otherwise, select products matching the name.
    sql = "SELECT productId, productName, productPrice FROM product WHERE productName LIKE ?";
}

try (
    Connection con = DriverManager.getConnection(url, uid, pw);
    
    PreparedStatement pstmt = con.prepareStatement(sql)
) {
    
    if (name != null && !name.trim().isEmpty()) {
        pstmt.setString(1, "%" + name + "%");
    }

    try (ResultSet rs = pstmt.executeQuery()) {

        out.println("<h2>Product List</h2>");
        out.println("<table border='1' cellpadding='5'>");
        out.println("<tr><th>Product</th><th>Price</th><th>Add to Cart</th></tr>");
        
        NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        
        while (rs.next()) {
       
            int productId = rs.getInt("productId");
            String productName = rs.getString("productName");
            double price = rs.getDouble("productPrice");
            
            String formattedPrice = currFormat.format(price);
            
            String encodedName = URLEncoder.encode(productName, "UTF-8");
            String link = "addcart.jsp?id=" + productId + "&name=" + encodedName + "&price=" + price;
            
            out.println("<tr>");
            out.println("<td>" + productName + "</td>");
            out.println("<td>" + formattedPrice + "</td>");
            out.println("<td><a href='" + link + "'>Add</a></td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
    }
    
} catch (SQLException e) {
    out.println("<h3>Error connecting to or querying the database.</h3>");
    out.println("<pre>" + e.toString() + "</pre>");
} catch (Exception e) {
    out.println("An error occurred: " + e.toString());
}
%>

</body>
</html>