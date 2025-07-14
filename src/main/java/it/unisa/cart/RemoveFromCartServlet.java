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
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (dataSource == null) {
            throw new ServletException("DataSource non trovato nel contesto");
        }
        cartDAO = new CartDAO(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");
        String productCodeParam = request.getParameter("productCode");

        if (productCodeParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Codice prodotto mancante.\"}");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeParam);

            if (userId != null) {
                cartDAO.removeItem(userId, productCode);
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    Iterator<CartBean> iterator = guestCart.iterator();
                    boolean removed = false;
                    while (iterator.hasNext()) {
                        CartBean item = iterator.next();
                        if (item.getProductCode() == productCode) {
                            iterator.remove();
                            removed = true;
                            break;
                        }
                    }
                    if (removed) {
                        session.setAttribute("guestCart", guestCart);
                    }
                }
            }

            response.getWriter().write("{\"status\":\"success\"}");

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Codice prodotto non valido.\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Errore durante la rimozione dal carrello.\"}");
            e.printStackTrace();
        }
    }
}
