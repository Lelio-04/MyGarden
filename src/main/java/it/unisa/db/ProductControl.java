package it.unisa.db;

import it.unisa.cart.*;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collection;
import java.util.List;

@WebServlet("/product")
public class ProductControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ProductControl() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Recupera il DataSource dal context
        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");

        IProductDao productDao = new ProductDaoDataSource(ds);
        CartDAO cartDao = new CartDAO(ds); // 🔄 ora usa DataSource

        // Recupera sessione utente
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        String action = request.getParameter("action");

        try {
            if (action != null && userId != null) {
                switch (action.toLowerCase()) {
                    case "addc":
                        int addId = Integer.parseInt(request.getParameter("id"));
                        cartDao.addToCart(userId, addId, 1);
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
                        ProductBean bean = new ProductBean();
                        bean.setName(request.getParameter("name"));
                        bean.setDescription(request.getParameter("description"));
                        bean.setPrice(Double.parseDouble(request.getParameter("price")));
                        bean.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                        bean.setImage(request.getParameter("image"));
                        productDao.doSave(bean);
                        break;

                    case "update":
                        ProductBean updateBean = new ProductBean();
                        updateBean.setCode(Integer.parseInt(request.getParameter("id")));
                        updateBean.setName(request.getParameter("name"));
                        updateBean.setDescription(request.getParameter("description"));
                        updateBean.setPrice(Double.parseDouble(request.getParameter("price")));
                        updateBean.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                        updateBean.setImage(request.getParameter("image"));
                        productDao.doUpdate(updateBean);
                        break;
                }
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore: " + e.getMessage());
        }

        // Ricarica carrello per l'utente
        try {
            if (userId != null) {
                List<CartBean> cartItems = cartDao.getCartItems(userId);
                request.setAttribute("cartItems", cartItems);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore caricamento carrello: " + e.getMessage());
        }

        // Carica catalogo prodotti
        String sort = request.getParameter("sort");
        try {
            Collection<ProductBean> products = productDao.doRetrieveAll(sort);
            request.setAttribute("products", products);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore durante il recupero dei prodotti: " + e.getMessage());
        }

        // Destinazione finale
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        String nextPage = (isAdmin != null && isAdmin) ? "/admin/adminProduct.jsp" : "/catalogo.jsp";

        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(nextPage);
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
