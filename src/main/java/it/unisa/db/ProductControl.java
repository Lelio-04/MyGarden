package it.unisa.db;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collection;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

public class ProductControl extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ProductControl() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		boolean isDataSource = true;
		IProductDao productDao;

		if (isDataSource) {
			DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
			productDao = new ProductDaoDataSource(ds);
		} else {
			DriverManagerConnectionPool dm = (DriverManagerConnectionPool) getServletContext()
					.getAttribute("DriverManager");
			productDao = new ProductDaoDriverMan(dm);
		}

		Cart cart = (Cart) request.getSession().getAttribute("cart");
		if (cart == null) {
			cart = new Cart();
			request.getSession().setAttribute("cart", cart);
		}

		String action = request.getParameter("action");

		try {
			if (action != null) {
				switch (action.toLowerCase()) {
					case "addc":
						int addId = Integer.parseInt(request.getParameter("id"));
						cart.addProduct(productDao.doRetrieveByKey(addId));
						break;

					case "deletec":
						int delId = Integer.parseInt(request.getParameter("id"));
						cart.deleteProduct(productDao.doRetrieveByKey(delId));
						break;

					case "read":
						int readId = Integer.parseInt(request.getParameter("id"));
						request.setAttribute("product", productDao.doRetrieveByKey(readId));
						break;

					case "delete":
						int deleteId = Integer.parseInt(request.getParameter("id"));
						productDao.doDelete(deleteId);
						break;

					case "insert":
						String name = request.getParameter("name");
						String description = request.getParameter("description");
						int price = Integer.parseInt(request.getParameter("price"));
						int quantity = Integer.parseInt(request.getParameter("quantity"));
						String image = request.getParameter("image");

						ProductBean bean = new ProductBean();
						bean.setName(name);
						bean.setDescription(description);
						bean.setPrice(price);
						bean.setQuantity(quantity);
						bean.setImage(image);

						productDao.doSave(bean);
						break;

					case "update":
						int updateId = Integer.parseInt(request.getParameter("id"));
						String nameU = request.getParameter("name");
						String descU = request.getParameter("description");
						int priceU = Integer.parseInt(request.getParameter("price"));
						int qtyU = Integer.parseInt(request.getParameter("quantity"));
						String imageU = request.getParameter("image");

						ProductBean updateBean = new ProductBean();
						updateBean.setCode(updateId);
						updateBean.setName(nameU);
						updateBean.setDescription(descU);
						updateBean.setPrice(priceU);
						updateBean.setQuantity(qtyU);
						updateBean.setImage(imageU);

						productDao.doUpdate(updateBean);
						break;
				}
			}
		} catch (SQLException | NumberFormatException e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Errore: " + e.getMessage());
		}

		request.getSession().setAttribute("cart", cart);

		String sort = request.getParameter("sort");
		try {
			Collection<ProductBean> products = productDao.doRetrieveAll(sort);
			request.setAttribute("products", products);
		} catch (SQLException e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Errore durante il recupero dei prodotti: " + e.getMessage());
		}

		Boolean isAdmin = (Boolean) request.getSession().getAttribute("isAdmin");
		String nextPage = (isAdmin != null && isAdmin) ? "/adminProduct.jsp" : "/catalogo.jsp";

		RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(nextPage);
		dispatcher.forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
