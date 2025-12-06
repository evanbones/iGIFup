<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8" %>
<!DOCTYPE html>
<html>
<head>
    <title>iGifUp Main Page</title>
    <link rel="stylesheet" href="css/index.css">
</head>
<body>
    <div class="page-container">
        <%@ include file="header.jsp" %>

        <div class="main-content">
            <div class="welcome-section">
                <h2>Welcome to iGifUp</h2>
                <p>An early 2000s-style e-commerce site for buying and selling retro GIFs</p>
            </div>

            <div class="button-container">
                <a href="listprod.jsp">Begin Shopping</a>
                <a href="loaddata.jsp">Load Data</a>
                <a href="customer.jsp">Profile</a>
                <a href="admin.jsp">Administrator</a>
            </div>

            <%-- Trending Section --%>
            <div class="trending-section">
                <h2>Best Sellers</h2>
                <%
                String homeUrl = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
                String homeUid = "sa"; 
                String homePw = "304#sa#pw";

                // SQL to find top 3 products
                String popularSql = "SELECT TOP 3 p.productId, p.productName, p.productImageURL, SUM(op.quantity) as totalSold " +
                                    "FROM orderproduct op JOIN product p ON op.productId = p.productId " +
                                    "GROUP BY p.productId, p.productName, p.productImageURL " +
                                    "ORDER BY totalSold DESC";

                try (java.sql.Connection con = java.sql.DriverManager.getConnection(homeUrl, homeUid, homePw);
                        java.sql.Statement stmt = con.createStatement();
                        java.sql.ResultSet rs = stmt.executeQuery(popularSql)) {

                    out.println("<div class='trending-list'>"); // Matches CSS
                    while (rs.next()) {
                        String pName = rs.getString("productName");
                        String pImg = rs.getString("productImageURL");
                        int pId = rs.getInt("productId");
                        
                        // FIXED: Removed inline styles so CSS classes control the look
                        out.println("<div class='product-card'>"); 
                        out.println("<img src='" + pImg + "' alt='Product'>");
                        out.println("<p><a href='product.jsp?id=" + pId + "'>" + pName + "</a></p>");
                        out.println("</div>");
                    }
                    out.println("</div>");
                } catch (Exception e) {
                    out.println("<p>Error loading best sellers.</p>");
                }
                %>
            </div>

            <%
                String currentUser = (String) session.getAttribute("authenticatedUser");
                if (currentUser != null) {
            %>
                <div class="trending-section">
                    <h2>Recommended For You</h2>
                    <%
                    String recSql = "SELECT TOP 3 p.productName, p.productId, p.productImageURL FROM product p " +
                                    "WHERE p.categoryId = (" +
                                        "SELECT TOP 1 p2.categoryId FROM ordersummary os " +
                                        "JOIN customer c ON os.customerId = c.customerId " +
                                        "JOIN orderproduct op ON os.orderId = op.orderId " +
                                        "JOIN product p2 ON op.productId = p2.productId " +
                                        "WHERE c.userid = ? " +
                                        "GROUP BY p2.categoryId " +
                                        "ORDER BY SUM(op.quantity) DESC" +
                                    ") ORDER BY NEWID()"; 

                    try (java.sql.Connection conRec = java.sql.DriverManager.getConnection(homeUrl, homeUid, homePw);
                         java.sql.PreparedStatement pstmtRec = conRec.prepareStatement(recSql)) {
                         
                        pstmtRec.setString(1, currentUser);
                        java.sql.ResultSet rsRec = pstmtRec.executeQuery();

                        out.println("<div class='trending-list'>");
                        boolean foundRecs = false;
                        while (rsRec.next()) {
                            foundRecs = true;
                            out.println("<div class='product-card'>");
                            out.println("<img src='" + rsRec.getString("productImageURL") + "'>");
                            out.println("<p><a href='product.jsp?id=" + rsRec.getInt("productId") + "'>" + 
                                        rsRec.getString("productName") + "</a></p>");
                            out.println("</div>");
                        }
                        if (!foundRecs) out.println("<p>Make a purchase to get recommendations!</p>");
                        out.println("</div>");

                    } catch (Exception e) {
                        out.println("Error loading recommendations.");
                    }
                    %>
                </div>
            <% } %>

        </div>
    </div>
</body>
</html>