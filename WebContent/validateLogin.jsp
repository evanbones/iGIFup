=<%@ page language="java" import="java.io.*,java.sql.*,java.util.ArrayList,java.util.HashMap" %>
<%@ include file="jdbc.jsp" %>
<%
    String authenticatedUser = null;
    session = request.getSession(true);

    try
    {
        authenticatedUser = validateLogin(out,request,session);
    }
    catch(IOException e)
    {   System.err.println(e); }

    if(authenticatedUser != null)
        response.sendRedirect("index.jsp");     // Successful login
    else
        response.sendRedirect("login.jsp");     // Failed login
%>

<%!
    String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException
    {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String retStr = null;

        if(username == null || password == null)
                return null;
        if((username.length() == 0) || (password.length() == 0))
                return null;

        try 
        {
            getConnection();
            
            // --- MODIFIED QUERY: We now select 'customerId' as well ---
            String query = "SELECT userid, customerId FROM customer WHERE userid = ? AND password COLLATE Latin1_General_CS_AS = ?";
            PreparedStatement pstmt = con.prepareStatement(query);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();

            if(rs.next())
            {
                retStr = rs.getString("userid");
                int customerId = rs.getInt("customerId");
                
                // Check if this customer has an active cart (Order not in orderproduct)
                String cartSql = "SELECT orderId FROM ordersummary WHERE customerId = ? " +
                                 "AND orderId NOT IN (SELECT orderId FROM orderproduct)";
                
                PreparedStatement cartStmt = con.prepareStatement(cartSql);
                cartStmt.setInt(1, customerId);
                ResultSet cartRs = cartStmt.executeQuery();
                
                int orderId = -1;
                if (cartRs.next()) {
                    orderId = cartRs.getInt("orderId");
                }
                cartRs.close();
                cartStmt.close();

                // If cart found, load items into Session HashMap
                if (orderId != -1) {
                    HashMap<String, ArrayList<Object>> productList = new HashMap<String, ArrayList<Object>>();
                    
                    String itemSql = "SELECT ic.productId, p.productName, ic.price, ic.quantity " +
                                     "FROM incart ic JOIN product p ON ic.productId = p.productId " +
                                     "WHERE ic.orderId = ?";
                    
                    PreparedStatement itemStmt = con.prepareStatement(itemSql);
                    itemStmt.setInt(1, orderId);
                    ResultSet itemRs = itemStmt.executeQuery();
                    
                    while (itemRs.next()) {
                        ArrayList<Object> product = new ArrayList<Object>();
                        product.add(String.valueOf(itemRs.getInt("productId"))); // 0: ID
                        product.add(itemRs.getString("productName"));            // 1: Name
                        product.add(itemRs.getDouble("price"));                  // 2: Price
                        product.add(itemRs.getInt("quantity"));                  // 3: Qty
                        
                        // Add to map
                        productList.put(String.valueOf(itemRs.getInt("productId")), product);
                    }
                    itemRs.close();
                    itemStmt.close();
                    
                    // SAVE TO SESSION
                    session.setAttribute("productList", productList);
                }
            }
            rs.close();
            pstmt.close();  
        } 
        catch (SQLException ex) {
            out.println(ex);
        }
        finally
        {
            closeConnection();
        }   
        
        if(retStr != null)
        {   session.removeAttribute("loginMessage");
            session.setAttribute("authenticatedUser",username);
        }
        else
            session.setAttribute("loginMessage","Could not connect to the system using that username/password.");

        return retStr;
    }
%>