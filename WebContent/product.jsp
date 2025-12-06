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
    /* Add to Cart form styles */
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
            // Check for binary image too
            byte[] binaryImage = rs.getBytes("productImage");
            if (binaryImage != null && binaryImage.length > 0) {
                 out.println("<div><img src='displayImage.jsp?id=" + pid + "' alt='Binary Image'></div>");
            }
            out.println("</div>");
            
            // Info Section
            out.println("<div class='product-info'>");
            out.println("<p><strong>Category:</strong> " + categoryName + "</p>");
            out.println("<p class='price'>" + formattedPrice + "</p>");
            
            // --- INVENTORY DISPLAY & DROPDOWN BUILDER ---
            out.println("<div class='inventory-section'>");
            out.println("<h4>Current Stock Status</h4>");
            
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
            
            // --- ADD TO CART FORM ---
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

            // =========================================================================
            // REVIEWS SECTION
            // =========================================================================
            out.println("<div class='reviews-section'>");
            out.println("<h2>Customer Reviews</h2>");
            
            String reviewSuccess = request.getParameter("reviewSuccess");
            String deleteSuccess = request.getParameter("deleteSuccess");
            String error = request.getParameter("error");
            
            if ("true".equals(reviewSuccess)) out.println("<div class='success-message'>Thank you! Your review has been submitted successfully!</div>");
            if ("true".equals(deleteSuccess)) out.println("<div class='success-message'>Review deleted successfully!</div>");
            
            String displayStyle = (error != null) ? "block" : "none";
            out.println("<div id='globalErrorContainer' class='error-message-review' style='display: " + displayStyle + ";'>");
            if (error != null) out.println("Error: " + error);
            out.println("</div>");
            
            String reviewSql = "SELECT r.reviewId, r.reviewRating, r.reviewDate, r.reviewComment, r.customerId, c.firstName, c.lastName " +
                              "FROM review r JOIN customer c ON r.customerId = c.customerId " +
                              "WHERE r.productId = ? ORDER BY r.reviewDate DESC";
            
            PreparedStatement reviewStmt = con.prepareStatement(reviewSql);
            reviewStmt.setInt(1, pid);
            ResultSet reviewRs = reviewStmt.executeQuery();
            
            // Check current user for delete permissions
            Integer currentCustomerId = null;
            boolean isAdmin = false;
            String userName = (String) session.getAttribute("authenticatedUser");
            
            if (userName != null) {
                String getCurrentCustomerSql = "SELECT customerId FROM customer WHERE userid = ?";
                PreparedStatement currentCustStmt = con.prepareStatement(getCurrentCustomerSql);
                currentCustStmt.setString(1, userName);
                ResultSet currentCustRs = currentCustStmt.executeQuery();
                if (currentCustRs.next()) currentCustomerId = currentCustRs.getInt("customerId");
                currentCustRs.close();
                currentCustStmt.close();
                isAdmin = "admin".equals(userName);
            }
            
            boolean hasReviews = false;
            while (reviewRs.next()) {
                hasReviews = true;
                int reviewId = reviewRs.getInt("reviewId");
                double rating = reviewRs.getDouble("reviewRating");
                Timestamp reviewDate = reviewRs.getTimestamp("reviewDate");
                String comment = reviewRs.getString("reviewComment");
                String firstName = reviewRs.getString("firstName");
                String lastName = reviewRs.getString("lastName");
                int reviewCustomerId = reviewRs.getInt("customerId");
                
                boolean canDelete = isAdmin || (currentCustomerId != null && currentCustomerId == reviewCustomerId);
                
                out.println("<div class='review-item'>");
                out.println("<div class='review-header'><span class='review-author'>" + firstName + " " + lastName + "</span>");
                out.println("<div class='review-header-right'><span class='review-date'>" + reviewDate + "</span>");
                if (canDelete) {
                    out.println("<a href='deleteReview.jsp?reviewId=" + reviewId + "&productId=" + pid + "' class='delete-review-btn' onclick='return confirm(\"Delete review?\");'>Delete</a>");
                }
                out.println("</div></div>");
                out.println("<div class='review-rating'><span class='stars-display' data-rating='" + rating + "'></span></div>");
                out.println("<div class='review-comment'>" + comment + "</div>");
                out.println("</div>");
            }
            
            if (!hasReviews) out.println("<div class='no-reviews'>No reviews yet. Be the first!</div>");
            reviewRs.close();
            reviewStmt.close();
     
            if (userName != null) {
                out.println("<div class='review-form'><h3>Write a Review</h3>");
                out.println("<form id='reviewForm' method='post' action='submitReview.jsp' onsubmit='return validateReview()'>");
                out.println("<input type='hidden' name='productId' value='" + pid + "'>");
                out.println("<input type='hidden' id='ratingValue' name='rating' value='0'>");
                
                out.println("<div class='form-group'><label>Rating: <span id='ratingText'>0</span> / 5</label>");
                out.println("<div class='rating-interactive-container'><div class='stars-input-wrapper' id='starsInteractive'></div></div></div>");
                
                out.println("<div class='form-group'><label for='comment'>Your Review:</label>");
                out.println("<textarea id='comment' name='comment' placeholder='Share your thoughts...' required></textarea></div>");
                out.println("<button type='submit' class='submit-review-btn'>Submit Review</button>");
                out.println("</form></div>");
            } else {
                out.println("<div class='login-prompt'><p>Please <a href='login.jsp'>log in</a> to write a review.</p></div>");
            }
            
            out.println("</div>"); // End Reviews Section

        } else {
            out.println("<h3>Product Not Found</h3>");
        }
        
        rs.close();
        pstmt.close();
    } catch (Exception ex) {
        out.println("Error: " + ex.getMessage());
    }
}
%>
</div>

<!-- SCRIPTS FOR STAR RATING -->
<script>
function createStarSVG(size, isFull) {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('width', size);
  svg.setAttribute('height', size);
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.style.display = 'inline-block';
  svg.style.marginRight = '2px';
  if(size > 30) svg.style.pointerEvents = 'none'; 
  const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
  path.setAttribute('d', 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z');
  
  if (isFull) { path.setAttribute('fill', '#FFD700'); path.setAttribute('stroke', '#FFA500'); } 
  else { path.setAttribute('fill', '#666666'); path.setAttribute('stroke', '#444444'); }
  
  path.setAttribute('stroke-width', '1');
  svg.appendChild(path);
  return svg;
}

document.querySelectorAll('.stars-display').forEach(function(el) {
  const rating = Math.round(parseFloat(el.getAttribute('data-rating'))); 
  for(let i=1; i<=5; i++) el.appendChild(createStarSVG(24, i <= rating));
});

const starsInteractive = document.getElementById('starsInteractive');
if (starsInteractive) {
    const ratingText = document.getElementById('ratingText');
    const ratingInput = document.getElementById('ratingValue');
    let savedRating = 0; 

    function renderInteractiveStars(rating) {
        starsInteractive.innerHTML = '';
        const count = Math.round(rating);
        for(let i=1; i<=5; i++) starsInteractive.appendChild(createStarSVG(45, i <= count));
        if(ratingText) ratingText.innerText = count;
    }

    function calculateRating(e) {
        const rect = starsInteractive.getBoundingClientRect();
        const percent = (e.clientX - rect.left) / rect.width;
        let starCount = Math.ceil(percent * 5);
        if(starCount < 1) starCount = 1; if(starCount > 5) starCount = 5;
        return starCount;
    }

    starsInteractive.addEventListener('mousemove', function(e) { renderInteractiveStars(calculateRating(e)); });
    starsInteractive.addEventListener('mouseleave', function(e) { renderInteractiveStars(savedRating); });
    starsInteractive.addEventListener('click', function(e) {
        savedRating = calculateRating(e);
        if(ratingInput) ratingInput.value = savedRating;
        renderInteractiveStars(savedRating);
    });
    renderInteractiveStars(0);
}

function validateReview() {
    const ratingInput = document.getElementById('ratingValue');
    if (!ratingInput || ratingInput.value === '0' || ratingInput.value === '') {
        alert("You must select a star rating (1-5) before submitting.");
        return false;
    }
    return true;
}
</script>
</body>
</html>