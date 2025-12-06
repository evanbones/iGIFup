<%
	// Remove the user from the session to log them out
	session.setAttribute("authenticatedUser",null);
	session.invalidate();
	response.sendRedirect("index.jsp");		// Re-direct to main page
%>

