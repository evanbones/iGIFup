<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>iGifUp - Product Information</title>
<link rel="stylesheet" href="css/product.css">
</head>
<body>
<div class="page-container">
<%@ include file="header.jsp" %>

<%
String productId = request.getParameter("id");

if (productId == null || productId.isEmpty()) {
    out.println("<div class='product-detail'>");
    out.println("<div class='error-message'>");
    out.println("<h3>Error</h3>");
    out.println("<p>No product ID specified.</p>");
    out.println("<a href='listprod.jsp' class='btn btn-continue'>Back to Products</a>");
    out.println("</div>");
    out.println("</div>");
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
            
            out.println("<div class='product-images'>");
            
            if (imageURL != null && !imageURL.trim().isEmpty()) {
                out.println("<div>");
                out.println("<h3>Product Image</h3>");
                out.println("<img src='" + request.getContextPath() + "/" + imageURL + "' alt='" + productName + "'>");
                out.println("</div>");
            }
            
            byte[] binaryImage = rs.getBytes("productImage");
            if (binaryImage != null && binaryImage.length > 0) {
                out.println("<div>");
                if (imageURL != null && !imageURL.trim().isEmpty()) {
                    out.println("<h3>Additional Product Image</h3>");
                } else {
                    out.println("<h3>Product Image</h3>");
                }
                out.println("<img src='displayImage.jsp?id=" + pid + "' alt='" + productName + " (from database)'>");
                out.println("</div>");
            }
            
            out.println("</div>");
            
            out.println("<div class='product-info'>");
            out.println("<p><strong>Category:</strong> " + categoryName + "</p>");
            out.println("<p class='price'>" + formattedPrice + "</p>");
            
            if (description != null && !description.trim().isEmpty()) {
                out.println("<div class='description'>");
                out.println("<h3>Description</h3>");
                out.println("<p>" + description + "</p>");
                out.println("</div>");
            }
            
            String encodedName = URLEncoder.encode(productName, "UTF-8");
            String addToCartLink = "addcart.jsp?id=" + pid + "&name=" + encodedName + "&price=" + price;
            
            out.println("<div class='action-links'>");
            out.println("<a href='" + addToCartLink + "' class='btn btn-cart'>Add to Cart</a>");
            out.println("<a href='listprod.jsp' class='btn btn-continue'>Continue Shopping</a>");
            out.println("</div>");
            
            out.println("</div>");
            out.println("</div>");
            
            out.println("<div class='reviews-section'>");
            out.println("<h2>Customer Reviews</h2>");
            
            String reviewSuccess = request.getParameter("reviewSuccess");
            String deleteSuccess = request.getParameter("deleteSuccess");
            String error = request.getParameter("error");
            
            if ("true".equals(reviewSuccess)) {
                out.println("<div class='success-message'>");
                out.println("Thank you! Your review has been submitted successfully!");
                out.println("</div>");
            }
            
            if ("true".equals(deleteSuccess)) {
                out.println("<div class='success-message'>");
                out.println("Review deleted successfully!");
                out.println("</div>");
            }
            
            // Error container exists regardless of initial state for JS to target
            String displayStyle = (error != null) ? "block" : "none";
            out.println("<div id='globalErrorContainer' class='error-message-review' style='display: " + displayStyle + ";'>");
            
            if (error != null) {
                if ("duplicate".equals(error)) {
                    out.println("You have already reviewed this product.");
                } else if ("rating".equals(error)) {
                    out.println("Invalid rating. Please select 1-5 stars.");
                } else if ("missing".equals(error)) {
                    out.println("Please fill in all fields.");
                } else if ("invalid".equals(error)) {
                    out.println("Invalid input. Please try again.");
                } else if ("account".equals(error)) {
                    out.println("Account error. Please log in again.");
                } else if ("unauthorized".equals(error)) {
                    out.println("You are not authorized to delete this review.");
                } else if ("notfound".equals(error)) {
                    out.println("Review not found.");
                }
            }
            out.println("</div>");
            
            String reviewSql = "SELECT r.reviewId, r.reviewRating, r.reviewDate, r.reviewComment, r.customerId, c.firstName, c.lastName " +
                              "FROM review r " +
                              "JOIN customer c ON r.customerId = c.customerId " +
                              "WHERE r.productId = ? " +
                              "ORDER BY r.reviewDate DESC";
            
            PreparedStatement reviewStmt = con.prepareStatement(reviewSql);
            reviewStmt.setInt(1, pid);
            ResultSet reviewRs = reviewStmt.executeQuery();
            
            Integer currentCustomerId = null;
            boolean isAdmin = false;
            String userName = (String) session.getAttribute("authenticatedUser");
            
            if (userName != null) {
                String getCurrentCustomerSql = "SELECT customerId FROM customer WHERE userid = ?";
                PreparedStatement currentCustStmt = con.prepareStatement(getCurrentCustomerSql);
                currentCustStmt.setString(1, userName);
                ResultSet currentCustRs = currentCustStmt.executeQuery();
                if (currentCustRs.next()) {
                    currentCustomerId = currentCustRs.getInt("customerId");
                }
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
                out.println("<div class='review-header'>");
                out.println("<span class='review-author'>" + firstName + " " + lastName + "</span>");
                out.println("<div class='review-header-right'>");
                out.println("<span class='review-date'>" + reviewDate + "</span>");
                if (canDelete) {
                    out.println("<a href='deleteReview.jsp?reviewId=" + reviewId + "&productId=" + pid + "' class='delete-review-btn' onclick='return confirm(\"Are you sure you want to delete this review?\");'>Delete</a>");
                }
                out.println("</div>");
                out.println("</div>");
                out.println("<div class='review-rating'>");
                out.println("<span class='stars-display' data-rating='" + rating + "'></span>");
                out.println("<span class='rating-number'>(" + String.format("%.0f", rating) + "/5)</span>");
                out.println("</div>");
                out.println("<div class='review-comment'>" + comment + "</div>");
                out.println("</div>");
            }
            
            if (!hasReviews) {
                out.println("<div class='no-reviews'>");
                out.println("No reviews yet. Be the first to review this product!");
                out.println("</div>");
            }
            
            reviewRs.close();
            reviewStmt.close();
     
            if (userName != null) {
                out.println("<div class='review-form'>");
                out.println("<h3>Write a Review</h3>");
                out.println("<form id='reviewForm' method='post' action='submitReview.jsp' onsubmit='return validateReview()'>");
                
                out.println("<input type='hidden' name='productId' value='" + pid + "'>");
                out.println("<input type='hidden' id='ratingValue' name='rating' value='0'>");
                
                out.println("<div class='form-group'>");
                out.println("<label>Rating: <span id='ratingText'>0</span> / 5</label>");
                
                out.println("<div class='rating-interactive-container'>");
                out.println("<div class='stars-input-wrapper' id='starsInteractive'></div>");
                out.println("</div>");
                
                out.println("</div>");
                
                out.println("<div class='form-group'>");
                out.println("<label for='comment'>Your Review:</label>");
                out.println("<textarea id='comment' name='comment' placeholder='Share your thoughts about this product...' required></textarea>");
                out.println("</div>");
                
                out.println("<button type='submit' class='submit-review-btn'>Submit Review</button>");
                out.println("</form>");
                out.println("</div>");
            } else {
                out.println("<div class='login-prompt'>");
                out.println("<p>Please <a href='login.jsp'>log in</a> to write a review.</p>");
                out.println("</div>");
            }
            
            out.println("</div>"); // end reviews-section
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

<script>
/**
 * Shared function to create an SVG Star.
 * @param {string|number} size - Pixel size (e.g. 24 or 45)
 * @param {boolean} isFull - True for Gold, False for Grey
 */
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
  
  if (isFull) {
    path.setAttribute('fill', '#FFD700'); 
    path.setAttribute('stroke', '#FFA500');
  } else {
    path.setAttribute('fill', '#666666');
    path.setAttribute('stroke', '#444444'); 
  }
  
  path.setAttribute('stroke-width', '1');
  svg.appendChild(path);
  return svg;
}

document.querySelectorAll('.stars-display').forEach(function(el) {
  const rawRating = parseFloat(el.getAttribute('data-rating'));
  const rating = Math.round(rawRating); 
  
  for(let i=1; i<=5; i++) {
    el.appendChild(createStarSVG(24, i <= rating));
  }
});

const starsInteractive = document.getElementById('starsInteractive');

if (starsInteractive) {
    const ratingText = document.getElementById('ratingText');
    const ratingInput = document.getElementById('ratingValue');
    let savedRating = 0; 

    function renderInteractiveStars(rating) {
        starsInteractive.innerHTML = '';
        const count = Math.round(rating);
        
        for(let i=1; i<=5; i++) {
            starsInteractive.appendChild(createStarSVG(45, i <= count));
        }
        if(ratingText) ratingText.innerText = count;
    }

    function calculateRating(e) {
        const rect = starsInteractive.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const width = rect.width;
        
        let percent = x / width;
        let rawRating = percent * 5;
        
        let starCount = Math.ceil(rawRating);
        if(starCount < 1) starCount = 1;
        if(starCount > 5) starCount = 5;
        return starCount;
    }

    starsInteractive.addEventListener('mousemove', function(e) {
        const tempRating = calculateRating(e);
        renderInteractiveStars(tempRating);
    });

    starsInteractive.addEventListener('mouseleave', function(e) {
        renderInteractiveStars(savedRating);
    });

    starsInteractive.addEventListener('click', function(e) {
        savedRating = calculateRating(e);
        if(ratingInput) ratingInput.value = savedRating;
        renderInteractiveStars(savedRating);
        
        const errorDiv = document.getElementById('globalErrorContainer');
        if(errorDiv) errorDiv.style.display = 'none';
    });

    renderInteractiveStars(0);
}

function validateReview() {
    const ratingInput = document.getElementById('ratingValue');
    const errorContainer = document.getElementById('globalErrorContainer');
    
    if (!ratingInput || ratingInput.value === '0' || ratingInput.value === '') {
        if(errorContainer) {
            errorContainer.innerHTML = "You must select a star rating (1-5) before submitting.";
            errorContainer.style.display = 'block';
            errorContainer.scrollIntoView({ behavior: 'smooth' });
        } else {
            alert("You must select a star rating (1-5) before submitting.");
        }
        return false;
    }
    return true;
}
</script>
</body>
</html>