<%@ page import="java.sql.*" %>
    <%@ page import="java.text.NumberFormat" %>
        <%@ page import="java.net.URLEncoder" %>
            <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8" %>
                <%@ include file="jdbc.jsp" %>

                    <html>

                    <head>
                        <title>iGifUp - Product Information</title>
                        <link rel="stylesheet" , href="css/product.css">
                    </head>

                    <body>
                        <div class="page-container">
                            <%@ include file="header.jsp" %>

                                <% String productId=request.getParameter("id"); if (productId==null ||
                                    productId.isEmpty()) { out.println("<div class='product-detail'>");
                                    out.println("<div class='error-message'>");
                                        out.println("<h3>Error</h3>");
                                        out.println("<p>No product ID specified.</p>");
                                        out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to
                                            Products</a>");
                                        out.println("</div>");
                                    out.println("
                        </div>");
                        } else {
                        int idVal = -1;
                        try {
                        idVal = Integer.parseInt(productId);
                        } catch (Exception e) {
                        out.println("<div class='product-detail'>");
                            out.println("<div class='error-message'>");
                                out.println("<h3>Error</h3>");
                                out.println("<p>Invalid product ID format.</p>");
                                out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to Products</a>");
                                out.println("</div>");
                            out.println("</div>");
                        return;
                        }

                        // retrieve product information
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

                                // display images
                                out.println("<div class='product-images'>");

                                    if (imageURL != null && !imageURL.trim().isEmpty()) {
                                    out.println("<div>");
                                        out.println("<h3>Product Image</h3>");
                                        out.println("<img src='" + request.getContextPath() + "/" + imageURL + "'
                                            alt='" + productName + "'>");
                                        out.println("</div>");
                                    }

                                    // display binary image from database if available (im probably not using this)
                                    byte[] binaryImage = rs.getBytes("productImage");
                                    if (binaryImage != null && binaryImage.length > 0) {
                                    out.println("<div>");
                                        if (imageURL != null && !imageURL.trim().isEmpty()) {
                                        out.println("<h3>Additional Product Image</h3>");
                                        } else {
                                        out.println("<h3>Product Image</h3>");
                                        }
                                        out.println("<img src='displayImage.jsp?id=" + pid + "'
                                            alt='" + productName + " (from database)'>");
                                        out.println("</div>");
                                    }

                                    out.println("</div>"); // end product-images

                                // product information section
                                out.println("<div class='product-info'>");
                                    out.println("<p><strong>Category:</strong> " + categoryName + "</p>");
                                    out.println("<p class='price'>" + formattedPrice + "</p>");

                                    if (description != null && !description.trim().isEmpty()) {
                                    out.println("<div class='description'>");
                                        out.println("<h3>Description</h3>");
                                        out.println("<p>" + description + "</p>");
                                        out.println("</div>");
                                    }

                                    // action links
                                    String encodedName = URLEncoder.encode(productName, "UTF-8");
                                    String addToCartLink = "addcart.jsp?id=" + pid + "&name=" + encodedName + "&price="
                                    + price;

                                    out.println("<div class='action-links'>");
                                        out.println("<a href='" + addToCartLink + "' class='btn btn-cart'>Add to
                                            Cart</a>");
                                        out.println("<a href='listprod.jsp' class='btn btn-continue'>Continue
                                            Shopping</a>");
                                        out.println("</div>");

                                    out.println("</div>"); // end product-info
                                out.println("</div>"); // end product-content
                            out.println("</div>"); // end product-detail

                        } else {
                        out.println("<div class='product-detail'>");
                            out.println("<div class='error-message'>");
                                out.println("<h3>Product Not Found</h3>");
                                out.println("<p>The product with ID " + idVal + " could not be found.</p>");
                                out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to Products</a>");
                                out.println("</div>");
                            out.println("</div>");
                        }

                        rs.close();
                        pstmt.close();
                        } catch (SQLException ex) {
                        out.println("<div class='product-detail'>");
                            out.println("<div class='error-message'>");
                                out.println("<h3>Database Error</h3>");
                                out.println("<p>Error retrieving product information: " + ex.getMessage() + "</p>");
                                out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to Products</a>");
                                out.println("</div>");
                            out.println("</div>");
                        } catch (Exception ex) {
                        out.println("<div class='product-detail'>");
                            out.println("<div class='error-message'>");
                                out.println("<h3>Error</h3>");
                                out.println("<p>An error occurred: " + ex.getMessage() + "</p>");
                                out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to Products</a>");
                                out.println("</div>");
                            out.println("</div>");
                        }
                        }
                        %>
                        </div>
                    </body>

                    </html>