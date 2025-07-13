package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/update-cart-quantity")
public class UpdateCartQuantityServlet extends HttpServlet {

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

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        String productCodeStr = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");

        if (productCodeStr == null || quantityStr == null) {
            // Parametri mancanti, redirect senza modifiche
            response.sendRedirect("cart");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeStr);
            int quantity = Integer.parseInt(quantityStr);

            if (userId != null) {
                // Utente loggato: aggiorna nel DB
                if (quantity <= 0) {
                    cartDAO.removeItem(userId, productCode);
                } else {
                    cartDAO.updateQuantity(userId, productCode, quantity);
                }
            } else {
                // Utente ospite: aggiorna nella guestCart in sessione
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    CartBean itemToUpdate = null;
                    // Cerca elemento con productCode uguale
                    for (CartBean item : guestCart) {
                        // usa equals per confrontare gli Integer
                        if (Integer.valueOf(productCode).equals(item.getProductCode())) {
                            itemToUpdate = item;
                            break;
                        }
                    }

                    if (itemToUpdate != null) {
                        if (quantity <= 0) {
                            guestCart.remove(itemToUpdate);
                        } else {
                            itemToUpdate.setQuantity(quantity);
                        }
                        session.setAttribute("guestCart", guestCart);
                    } else {
                        // Se non trovato, potresti aggiungere log o comportamento alternativo
                        System.out.println("Prodotto non trovato in guestCart: " + productCode);
                    }
                } else {
                    // guestCart non esiste, puoi decidere di crearla o loggare
                    System.out.println("guestCart non presente in sessione.");
                }
            }
        } catch (NumberFormatException e) {
            System.err.println("Parametro productCode o quantity non valido: " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            // Potresti aggiungere messaggi di errore più dettagliati per l’utente
        }

        response.sendRedirect("cart");
    }
}
