<!DOCTYPE html>
<html>

<head>
	<title>Customer Page</title>
</head>
<link rel="stylesheet" href="css/listprod.css">

<body>
	<div class="page-container">
		<%@ include file="auth.jsp" %>
			<%@ page import="java.sql.*" %>

				<%@ include file="header.jsp" %>

					<%  // ensure user is logged in 
						String userName=(String) session.getAttribute("authenticatedUser");
						if (userName==null) { out.println("<p><b>Error:</b> You must be logged in to view this page.</p>
						");
						return;
						}

						String url =
						"jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
						String uid = "sa";
						String pw = "304#sa#pw";

						try {
						Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
						} catch (ClassNotFoundException e) {
						out.println("ClassNotFoundException: " + e.getMessage());
						}

						String sql = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state,
						postalCode, country " +
						"FROM customer WHERE customerId = ?";

						try (Connection con = DriverManager.getConnection(url, uid, pw);
						PreparedStatement pstmt = con.prepareStatement(sql)) {

						pstmt.setString(1, userName);

						try (ResultSet rs = pstmt.executeQuery()) {

						if (rs.next()) {

						int customerId = rs.getInt("customerId");
						String firstName = rs.getString("firstName");
						String lastName = rs.getString("lastName");
						String email = rs.getString("email");
						String phone = rs.getString("phonenum");
						String address = rs.getString("address");
						String city = rs.getString("city");
						String state = rs.getString("state");
						String postal = rs.getString("postalCode");
						String country = rs.getString("country");
						%>

						<h2>Customer Information</h2>

						<table border="1" cellpadding="8">
							<tr>
								<th>Customer ID</th>
								<td>
									<%= customerId %>
								</td>
							</tr>
							<tr>
								<th>Name</th>
								<td>
									<%= firstName %>
										<%= lastName %>
								</td>
							</tr>
							<tr>
								<th>Email</th>
								<td>
									<%= email %>
								</td>
							</tr>
							<tr>
								<th>Phone</th>
								<td>
									<%= phone %>
								</td>
							</tr>
							<tr>
								<th>Address</th>
								<td>
									<%= address %>
								</td>
							</tr>
							<tr>
								<th>City</th>
								<td>
									<%= city %>
								</td>
							</tr>
							<tr>
								<th>State</th>
								<td>
									<%= state %>
								</td>
							</tr>
							<tr>
								<th>Postal Code</th>
								<td>
									<%= postal %>
								</td>
							</tr>
							<tr>
								<th>Country</th>
								<td>
									<%= country %>
								</td>
							</tr>
						</table>

						<% } else { out.println("<p>No customer record found.</p>");
							}

							}

							} catch (SQLException e) {
							out.println("<p>Error loading customer information: " + e.getMessage() + "</p>");
							}
							%>

	</div>
</body>

</html>