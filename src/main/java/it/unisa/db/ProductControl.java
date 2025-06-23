package it.unisa.db;

import it.unisa.cart.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collection;
import java.util.List;

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

		DriverManagerConnectionPool pool = (DriverManagerConnectionPool) getServletContext()
				.getAttribute("DriverManager");

		CartDAO cartDao = new CartDAO(pool);

		// Recupera username e ID utente dalla sessione
		String username = (String) request.getSession().getAttribute("username");
		Integer userId = (Integer) request.getSession().getAttribute("userId"); // Assicurati di settarlo in login

		String action = request.getParameter("action");

		try {
			if (action != null && userId != null) {
				switch (action.toLowerCase()) {

					case "addc":
						int addId = Integer.parseInt(request.getParameter("id"));
						cartDao.addToCart(userId, addId, 1); // aggiunge 1 quantità

						// ✅ DEBUG: conferma inserimento
						System.out.println("✅ DEBUG: Prodotto con ID " + addId + " aggiunto al carrello per l'utente con ID " + userId);

						// ✅ DEBUG: mostra stato carrello attuale
						try {
							List<CartBean> debugCart = cartDao.getCartItems(userId);
							System.out.println("🛒 DEBUG: Contenuto attuale del carrello:");
							for (CartBean item : debugCart) {
								System.out.println("- Prodotto ID: " + item.getProductCode() + " | Quantità: " + item.getQuantity());
							}
						} catch (SQLException e) {
							System.out.println("❌ Errore nel recuperare il carrello per debug: " + e.getMessage());
						}
						break;

					case "deletec":
						int delId = Integer.parseInt(request.getParameter("id"));
						cartDao.removeItem(userId, delId);
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

		// Mostra articoli nel carrello
		try {
			if (userId != null) {
				List<CartBean> cartItems = cartDao.getCartItems(userId);
				request.setAttribute("cartItems", cartItems);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Errore caricamento carrello: " + e.getMessage());
		}

		// Carica lista prodotti
		String sort = request.getParameter("sort");
		try {
			Collection<ProductBean> products = productDao.doRetrieveAll(sort);
			request.setAttribute("products", products);
		} catch (SQLException e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Errore durante il recupero dei prodotti: " + e.getMessage());
		}

		Boolean isAdmin = (Boolean) request.getSession().getAttribute("isAdmin");
		String nextPage = (isAdmin != null && isAdmin) ? "/admin/adminProduct.jsp" : "/catalogo.jsp";

		RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(nextPage);
		dispatcher.forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
