<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
	Collection<?> products = (Collection<?>) request.getAttribute("products");
	if(products == null) {
		response.sendRedirect("./product");	
		return;
	}
	ProductBean product = (ProductBean) request.getAttribute("product");
	
	Cart cart = (Cart) session.getAttribute("cart");
%>

<!DOCTYPE html>
<html>
<%@ page contentType="text/html; charset=UTF-8" import="java.util.*,it.unisa.db.ProductBean,it.unisa.db.Cart"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link href="styles/style2.css" rel="stylesheet" type="text/css">
	<link rel="icon" href="images/favicon.png" type="image/png">
	<title>Storage DS/BF</title>
</head>

<body>
	<h2>Products</h2>
	<a href="product">List</a>
	<table border="1">
		<tr>
			<th>Code <a href="product?sort=code">Sort</a></th>
			<th>Name <a href="product?sort=name">Sort</a></th>
			<th>Description <a href="product?sort=description">Sort</a></th>
			<th>Action</th>
			<th>Image</th>
		</tr>
		<%
			if (products != null && products.size() != 0) {
				Iterator<?> it = products.iterator();
				while (it.hasNext()) {
					ProductBean bean = (ProductBean) it.next();
		%>
		<tr>
			<td><%=bean.getCode()%></td>
			<td><%=bean.getName()%></td>
			<td><%=bean.getDescription()%></td>
			<td><a href="product?action=delete&id=<%=bean.getCode()%>">Delete</a><br>
				<a href="product?action=read&id=<%=bean.getCode()%>">Details</a><br>
				<a href="product?action=addC&id=<%=bean.getCode()%>">Add to cart</a>
				</td>
				<td><img src= <%= bean.getImage() %> alt=<%= bean.getName()%> width="50"></td>
		</tr>
		<%
				}
			} else {
		%>
		<tr>
			<td colspan="6">No products available </td>
		</tr>
		<%
			}
		%>
	</table>
	
	<h2>Details</h2>
	<%
		if (product != null) {
	%>
	<table border="1">
		<tr>
			<th>Code</th>
			<th>Name</th>
			<th>Description</th>
			<th>Price</th>
			<th>Quantity</th>
			<th>Image</th>
		</tr>
		<tr>
			<td><%=product.getCode()%></td>
			<td><%=product.getName()%></td>
			<td><%=product.getDescription()%></td>
			<td><%=product.getPrice()%></td>
			<td><%=product.getQuantity()%></td>
			<td><img src="<%=product.getImage()%>" alt="<%=product.getName()%>" width="60"></td>

		</tr>
	</table>
	<%
		}
	%>
	<h2>Insert</h2>
	<form action="product" method="post">
		<input type="hidden" name="action" value="insert"> 
		
		<label for="name">Name:</label><br> 
		<input name="name" type="text" maxlength="20" required placeholder="enter name"><br> 
		
		<label for="description">Description:</label><br>
		<textarea name="description" maxlength="100" rows="3" required placeholder="enter description"></textarea><br>
		
		<label for="price">Price:</label><br> 
		<input name="price" type="number" min="0" value="0" required><br>

		<label for="quantity">Quantity:</label><br> 
		<input name="quantity" type="number" min="1" value="1" required><br>

		<input type="submit" value="Add"><input type="reset" value="Reset">
	</form>
	<% if(cart != null) { %>
		<h2>Cart</h2>
		<table border="1">
		<tr>
			<th>Name</th>
			<th>Action</th>
		</tr>
		<% List<ProductBean> prodcart = cart.getProducts(); 	
		   for(ProductBean beancart: prodcart) {
		%>
		<tr>
			<td><%=beancart.getName()%></td>
			<td><a href="product?action=deleteC&id=<%=beancart.getCode()%>">Delete from cart</a></td>
		</tr>
		<%} %>
	</table>		
	<% } %>	
</body>
</html>