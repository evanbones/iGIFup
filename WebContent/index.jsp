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
                        <a href="listorder.jsp">List All Orders</a>
                        <a href="loaddata.jsp">Load Data</a>
                        <a href="customer.jsp">Customer Info</a>
                        <a href="admin.jsp">Administrators</a></h2>
                    </div>
                    <div class="button-container">
                        <a href="login.jsp">Login</a>
                        <a href="logout.jsp">Logout</a>

                        <% String userName=(String) session.getAttribute("authenticatedUser"); if (userName !=null)
                            out.println("<h3 align=\"center\">Signed in as: "+userName+"</h3>");
                            %>
                    </div>
                </div>

        </div>
    </body>

    </html>