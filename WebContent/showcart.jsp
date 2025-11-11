<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 20px;
        background-color: #f5f5f5;
    }
    h1 {
        color: #333;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        max-width: 900px;
        background-color: white;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin: 20px 0;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 12px;
        text-align: left;
    }
    th {
        background-color: #4CAF50;
        color: white;
        font-weight: bold;
    }
    tr:nth-child(even) {
        background-color: #f9f9f9;
    }
    .total-row {
        font-weight: bold;
        background-color: #e7f3e7;
        font-size: 18px;
    }
    .empty-cart {
        background-color: white;
        padding: 40px;
        text-align: center;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .action-links {
        margin-top: 20px;
    }
    .action-links a {
        display: inline-block;
        padding: 12px 24px;
        margin: 10px 10px 10px 0;
        text-decoration: none;
        border-radius: 4px;
        font-weight: bold;
        font-size: 16px;
    }
    .checkout-btn {
        background-color: #4CAF50;
        color: white;
    }
    .checkout-btn:hover {
        background-color: #45a049;
    }
    .continue-btn {
        background-color: #2196F3;
        color: white;
    }
    .continue-btn:hover {
        background-color: #0b7dda;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null || productList.isEmpty())
{	
    out.println("<div class='empty-cart'>");
    out.println("<h1>Your Shopping Cart is Empty!</h1>");
    out.println("<p>Start shopping to add items to your cart.</p>");
    out.println("</div>");
}
else
{
	NumberFormat currFormat = NumberFormat.getCurrencyInstance();

	out.println("<h1>Your Shopping Cart</h1>");
	out.print("<table><tr><th>Product ID</th><th>Product Name</th><th>Quantity</th>");
	out.println("<th>Price</th><th>Subtotal</th></tr>");

	double total = 0;
	Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
	while (iterator.hasNext()) 
	{	
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
		ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
		if (product.size() < 4)
		{
			out.println("Expected product with four entries. Got: "+product);
			continue;
		}
		
		out.print("<tr><td>"+product.get(0)+"</td>");
		out.print("<td>"+product.get(1)+"</td>");

		out.print("<td align=\"center\">"+product.get(3)+"</td>");
		Object price = product.get(2);
		Object itemqty = product.get(3);
		double pr = 0;
		int qty = 0;
		
		try
		{
			pr = Double.parseDouble(price.toString());
		}
		catch (Exception e)
		{
			out.println("Invalid price for product: "+product.get(0)+" price: "+price);
		}
		try
		{
			qty = Integer.parseInt(itemqty.toString());
		}
		catch (Exception e)
		{
			out.println("Invalid quantity for product: "+product.get(0)+" quantity: "+qty);
		}		

		out.print("<td align=\"right\">"+currFormat.format(pr)+"</td>");
		out.print("<td align=\"right\">"+currFormat.format(pr*qty)+"</td></tr>");
		out.println("</tr>");
		total = total +pr*qty;
	}
	out.println("<tr class='total-row'><td colspan=\"4\" align=\"right\">Order Total</td>"
			+"<td align=\"right\">"+currFormat.format(total)+"</td></tr>");
	out.println("</table>");

	out.println("<div class='action-links'>");
	out.println("<a href=\"checkout.jsp\" class='checkout-btn'>Proceed to Checkout</a>");
	out.println("<a href=\"listprod.jsp\" class='continue-btn'>Continue Shopping</a>");
	out.println("</div>");
}

if (productList == null || productList.isEmpty()) {
    out.println("<div class='action-links'>");
    out.println("<a href=\"listprod.jsp\" class='continue-btn'>Start Shopping</a>");
    out.println("</div>");
}
%>

</body>
</html>