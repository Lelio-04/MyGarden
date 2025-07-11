package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

@WebServlet("/remove-from-cart")
public class RemoveFromCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        // Recupera il DataSource dal ServletContext
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        cartDAO = new CartDAO(dataSource);
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
                // Utente loggato: rimuove dal DB
                cartDAO.removeItem(userId, productCode);
            } else {
                // Utente ospite: rimuove da guestCart nella sessione
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
