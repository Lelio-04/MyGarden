package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Iterator;

@WebServlet("/remove-from-cart")
public class RemoveFromCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAODriverManager cartDAO;

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAODriverManager(new DriverManagerConnectionPool());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        String productCodeParam = request.getParameter("productCode");
        if (productCodeParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Codice prodotto mancante.");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeParam);

            if (userId != null) {
                // Utente loggato → rimozione da DB
                cartDAO.removeItem(userId, productCode);
            } else {
                // Utente non loggato → rimozione da guestCart in sessione
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    Iterator<CartBean> iterator = guestCart.iterator();
                    while (iterator.hasNext()) {
                        CartBean item = iterator.next();
                        if (item.getProductCode() == productCode) {
                            iterator.remove();
                            break;
                        }
                    }
                    session.setAttribute("guestCart", guestCart);
                }
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Codice prodotto non valido.");
            return;
        } catch (SQLException e) {
            throw new ServletException("Errore nella rimozione dal carrello", e);
        }

        response.sendRedirect("cart");
    }
}
