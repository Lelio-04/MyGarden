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


    @WebServlet("/GetCartServlet")
    public class GetCartServlet extends HttpServlet {

        private static final long serialVersionUID = 1L;
        private transient CartDAO cartDAO;
        private transient ProductDaoDataSource productDAO;

        @Override
        public void init() throws ServletException {
            //Ottieni DataSource da contesto
            DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
            cartDAO = new CartDAO(dataSource);
            productDAO = new ProductDaoDataSource(dataSource);
        }

        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId"); //Verifica se utente loggato

            List<CartBean> cartItems = new ArrayList<>();

            try {
                if (userId != null) {
                    //Se utente loggato, prendi carrello dal database
                    cartItems = cartDAO.getCartItems(userId);
                } else {
                    //Se utente non è loggato, prendi carrello da sessione
                    @SuppressWarnings("unchecked")
                    List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                    if (guestCart != null) {
                        cartItems = guestCart;
                    }
                }

                //Aggiungi dettagli prod per ogni elemento del carrello
                for (CartBean item : cartItems) {
                    ProductBean product = productDAO.doRetrieveByKey(item.getProductCode());
                    item.setProduct(product);
                }

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Errore DB durante il recupero del carrello\"}");
                return;
            }

            //Costruzione JSON per carrello
            StringBuilder json = new StringBuilder("[");

            for (int i = 0; i < cartItems.size(); i++) {
                CartBean item = cartItems.get(i);
                ProductBean p = item.getProduct();
                if (p == null) continue;

                json.append("{");
                json.append("\"id\":").append(item.getProductCode()).append(",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"name\":\"").append(escapeJson(p.getName())).append("\",");
                json.append("\"price\":").append(p.getPrice()).append(",");
                json.append("\"image\":\"").append(escapeJson(p.getImage())).append("\",");
                json.append("\"maxQty\":").append(p.getQuantity());
                json.append("}");


                if (i < cartItems.size() - 1) json.append(",");
            }
            json.append("]");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());
        }

        private String escapeJson(String s) {
            if (s == null) return "";
            return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
        }
}