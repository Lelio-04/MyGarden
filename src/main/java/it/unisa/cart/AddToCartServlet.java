package it.unisa.cart;

import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;
    private transient ProductDaoDataSource productDAO;

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        cartDAO = new CartDAO(dataSource);
        productDAO = new ProductDaoDataSource(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            int productCode = Integer.parseInt(request.getParameter("productCode"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            if (userId != null) {
                // Utente loggato → usa DB
                cartDAO.addToCart(userId, productCode, quantity);
                System.out.println("✅ Prodotto aggiunto al carrello (utente loggato): userId=" + userId);
            } else {
                // Utente non loggato → salva in sessione
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                if (guestCart == null) {
                    guestCart = new ArrayList<>();
                }

                boolean found = false;
                for (CartBean item : guestCart) {
                    if (item.getProductCode() == productCode) {
                        item.setQuantity(item.getQuantity() + quantity);
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    ProductBean product = productDAO.doRetrieveByKey(productCode);
                    CartBean item = new CartBean();
                    item.setProductCode(productCode);
                    item.setQuantity(quantity);
                    item.setProduct(product);
                    guestCart.add(item);
                }

                session.setAttribute("guestCart", guestCart);
                System.out.println("🛒 Prodotto aggiunto al carrello guest (non loggato): code=" + productCode);
            }

        } catch (NumberFormatException | SQLException e) {
            System.out.println("❌ Errore nel parsing/salvataggio carrello: " + e.getMessage());
        }

        response.sendRedirect("catalogo.jsp?added=1");
    }
}
