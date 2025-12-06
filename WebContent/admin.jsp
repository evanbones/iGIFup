<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Administrator Dashboard</title>
    <link rel="stylesheet" href="css/listprod.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .admin-nav { 
            background: #330066;
            padding: 15px; 
            border-bottom: 4px solid #FF00FF; 
            margin-bottom: 20px; 
            text-align: center;
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        .admin-nav a { 
            color: #FFFF00; 
            font-weight: bold; 
            text-decoration: none;
            font-size: 18px; 
            padding: 5px 10px;
            border: 1px solid transparent;
            transition: all 0.3s;
        }
        .admin-nav a:hover { 
            color: #00FFFF;
            text-shadow: 0 0 10px cyan;
            border: 1px dashed #00FFFF;
            border-radius: 5px;
            background: rgba(0, 255, 255, 0.1);
        }
        
        .dashboard-grid { display: flex; gap: 20px; flex-wrap: wrap; }
        .chart-container { flex: 2; background: rgba(0,0,0,0.5); padding: 20px; border: 2px solid #00FFFF; border-radius: 10px; }
        .stats-container { flex: 1; background: rgba(0,0,0,0.5); padding: 20px; border: 2px solid #FF00FF; border-radius: 10px; }
        h2 { color: #00FFCC; border-bottom: 1px dashed #FFF; padding-bottom: 5px; }
        
        /* Styled List for Quick Actions */
        .quick-actions-list {
            list-style: none;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-top: 20px;
        }
        .quick-actions-list li {
            width: 100%;
        }
        .quick-actions-list .btn {
            display: block;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="page-container">
    
    <%
        String authUser = (String) session.getAttribute("authenticatedUser");
        if (authUser == null || !authUser.equals("admin")) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <%@ include file="header.jsp" %>

    <div class="admin-nav">
        <a href="admin.jsp">Dashboard</a>
        <a href="admin_products.jsp">Manage Products</a>
        <a href="admin_inventory.jsp">Inventory</a>
        <a href="listorder.jsp">View All Orders</a>
        <a href="admin_orders.jsp">Manage Orders</a>
        <a href="admin_warehouses.jsp">Warehouses</a>
        <a href="admin_customers.jsp">Customers</a>
        <a href="loaddata.jsp">Restore DB</a>
    </div>

    <h1>Administrator Dashboard</h1>

    <%
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    StringBuilder dateLabels = new StringBuilder("[");
    StringBuilder salesData = new StringBuilder("[");
    
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    double totalLifetimeSales = 0;
    int totalOrders = 0;

    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        
        String sql = "SELECT CAST(orderDate AS DATE) as orderDay, SUM(totalAmount) as dailyTotal, COUNT(*) as dailyCount " +
                     "FROM ordersummary GROUP BY CAST(orderDate AS DATE) ORDER BY orderDay ASC";
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        while (rs.next()) {
            String day = rs.getString("orderDay");
            double total = rs.getDouble("dailyTotal");
            int count = rs.getInt("dailyCount");
            
            dateLabels.append("'").append(day).append("',");
            salesData.append(total).append(",");
            
            totalLifetimeSales += total;
            totalOrders += count;
        }
        if (dateLabels.length() > 1) dateLabels.setLength(dateLabels.length() - 1);
        if (salesData.length() > 1) salesData.setLength(salesData.length() - 1);
        
        dateLabels.append("]");
        salesData.append("]");
    %>

    <div class="dashboard-grid">
        <div class="chart-container">
            <h2>Sales Trends</h2>
            <canvas id="salesChart"></canvas>
        </div>

        <div class="stats-container">
            <h2>Lifetime Statistics</h2>
            <p style="font-size: 20px; color: #FFFF00;">Total Sales: <%= currFormat.format(totalLifetimeSales) %></p>
            <p style="font-size: 20px; color: #00FF00;">Total Orders: <%= totalOrders %></p>
            <hr>
            <h3>Quick Actions</h3>
            <ul class="quick-actions-list">
                <li><a href="admin_products.jsp" class="btn">Add / Edit Products</a></li>
                <li><a href="admin_orders.jsp" class="btn">Ship Pending Orders</a></li>
                <li><a href="admin_inventory.jsp" class="btn">Update Inventory</a></li>
            </ul>
        </div>
    </div>
    
    <%
    } catch (Exception e) {
        out.println("<h3 class='error'>Error: " + e.getMessage() + "</h3>");
    }
    %>
    
    <script>
        const ctx = document.getElementById('salesChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: <%= dateLabels.toString() %>,
                datasets: [{
                    label: 'Daily Sales ($)',
                    data: <%= salesData.toString() %>,
                    borderColor: '#00FFFF',
                    backgroundColor: 'rgba(0, 255, 255, 0.2)',
                    borderWidth: 3,
                    tension: 0.3
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true, grid: { color: '#555' } },
                    x: { grid: { color: '#555' } }
                },
                plugins: { legend: { labels: { color: 'white' } } }
            }
        });
    </script>

</div>
</body>
</html>