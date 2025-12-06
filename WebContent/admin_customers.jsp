<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Customers</title>
    <link rel="stylesheet" href="css/listprod.css">
</head>
<body>
<div class="page-container">
    <%@ include file="header.jsp" %>
    
    <%-- Security Check: Hardcoded for 'admin' user --%>
    <%
        String authUser = (String) session.getAttribute("authenticatedUser");
        if (authUser == null || !authUser.equals("admin")) { // admin is just the user with the username "admin"
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <div style="text-align:center; margin-bottom:20px;">
        <a href="admin.jsp" class="btn">Back to Dashboard</a>
    </div>

    <h1>Customer Management</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";
    
    String action = request.getParameter("action");
    String msg = "";
    
    // Variables for Editing
    String editId = "";
    String editFirst = "";
    String editLast = "";
    String editEmail = "";
    String editPhone = "";
    String editUser = "";
    String editPass = "";
    
    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        // --- HANDLE ACTIONS ---
        if ("add".equals(action)) {
            String sql = "INSERT INTO customer (firstName, lastName, email, phonenum, userid, password, address, city, state, postalCode, country) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("firstName"));
            pstmt.setString(2, request.getParameter("lastName"));
            pstmt.setString(3, request.getParameter("email"));
            pstmt.setString(4, request.getParameter("phonenum"));
            pstmt.setString(5, request.getParameter("userid"));
            pstmt.setString(6, request.getParameter("password"));
            pstmt.setString(7, ""); // Defaults for address to avoid null errors
            pstmt.setString(8, "");
            pstmt.setString(9, "");
            pstmt.setString(10, "");
            pstmt.setString(11, "");
            pstmt.executeUpdate();
            msg = "Customer Added!";
            
        } else if ("delete".equals(action)) {
            String sql = "DELETE FROM customer WHERE customerId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
            pstmt.executeUpdate();
            msg = "Customer Deleted!";
            
        } else if ("update".equals(action)) {
            String sql = "UPDATE customer SET firstName=?, lastName=?, email=?, phonenum=?, userid=?, password=? WHERE customerId=?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("firstName"));
            pstmt.setString(2, request.getParameter("lastName"));
            pstmt.setString(3, request.getParameter("email"));
            pstmt.setString(4, request.getParameter("phonenum"));
            pstmt.setString(5, request.getParameter("userid"));
            pstmt.setString(6, request.getParameter("password"));
            pstmt.setInt(7, Integer.parseInt(request.getParameter("id")));
            pstmt.executeUpdate();
            msg = "Customer Updated!";
            
        } else if ("edit".equals(action)) {
            // Fetch data to populate the form
            String sql = "SELECT * FROM customer WHERE customerId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                editId = rs.getString("customerId");
                editFirst = rs.getString("firstName");
                editLast = rs.getString("lastName");
                editEmail = rs.getString("email");
                editPhone = rs.getString("phonenum");
                editUser = rs.getString("userid");
                editPass = rs.getString("password");
            }
        }
    %>
    
    <% if(msg.length() > 0) out.println("<h3 style='color:#00FF00; text-align:center;'>" + msg + "</h3>"); %>

    <div style="display:flex; gap:20px;">
        
        <div style="flex:1; background:rgba(0,0,0,0.5); padding:20px; border:2px solid #FF00FF;">
            <h2><%= (action != null && action.equals("edit")) ? "Edit Customer" : "Add New Customer" %></h2>
            
            <form method="post" action="admin_customers.jsp">
                <input type="hidden" name="action" value="<%= (action != null && action.equals("edit")) ? "update" : "add" %>">
                <% if(action != null && action.equals("edit")) { %>
                    <input type="hidden" name="id" value="<%= editId %>">
                <% } %>
                
                <label>First Name:</label><br>
                <input type="text" name="firstName" value="<%= editFirst %>" required style="width:100%"><br><br>
                
                <label>Last Name:</label><br>
                <input type="text" name="lastName" value="<%= editLast %>" required style="width:100%"><br><br>
                
                <label>Email:</label><br>
                <input type="text" name="email" value="<%= editEmail %>" required style="width:100%"><br><br>
                
                <label>Phone:</label><br>
                <input type="text" name="phonenum" value="<%= editPhone %>" style="width:100%"><br><br>
                
                <label style="color:#FFFF00;">Username:</label><br>
                <input type="text" name="userid" value="<%= editUser %>" required style="width:100%"><br><br>

                <label style="color:#FFFF00;">Password:</label><br>
                <input type="text" name="password" value="<%= editPass %>" required style="width:100%"><br><br>
                
                <input type="submit" value="<%= (action != null && action.equals("edit")) ? "Update Customer" : "Add Customer" %>" class="btn">
                <% if(action != null && action.equals("edit")) { %>
                    <a href="admin_customers.jsp" class="btn" style="background:gray;">Cancel</a>
                <% } %>
            </form>
        </div>

        <!-- CUSTOMER LIST -->
        <div style="flex:2;">
            <h2>Customer List</h2>
            
            <!-- Search Bar -->
            <form method="get" action="admin_customers.jsp" style="margin-bottom:10px;">
                <input type="text" name="search" placeholder="Search by name or ID..." value="<%= request.getParameter("search")!=null?request.getParameter("search"):"" %>">
                <input type="submit" value="Search">
            </form>

            <table style="font-size:14px;">
                <tr><th>ID</th><th>Name</th><th>User/Pass</th><th>Email</th><th>Actions</th></tr>
                <%
                String search = request.getParameter("search");
                String listSql = "SELECT * FROM customer";
                if (search != null && !search.trim().isEmpty()) {
                    listSql += " WHERE firstName LIKE '%"+search+"%' OR lastName LIKE '%"+search+"%' OR userid LIKE '%"+search+"%'";
                }
                listSql += " ORDER BY customerId DESC";
                
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery(listSql);
                while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("customerId") %></td>
                    <td><%= rs.getString("firstName") %> <%= rs.getString("lastName") %></td>
                    <td>
                        <small style="color:#CCC;"><%= rs.getString("userid") %></small><br>
                        <small style="color:#555;"><%= rs.getString("password") %></small>
                    </td>
                    <td><%= rs.getString("email") %></td>
                    <td>
                        <a href="admin_customers.jsp?action=edit&id=<%= rs.getInt("customerId") %>" style="color:#FFFF00;">Edit</a> | 
                        <a href="admin_customers.jsp?action=delete&id=<%= rs.getInt("customerId") %>" style="color:red;" onclick="return confirm('Delete this customer? This will also delete their orders.');">Delete</a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>

    <% } catch(Exception e) { out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>"); } %>
</div>
</body>
</html>