package it.unisa.api;

import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet("/get-product-info")  // Rimuovi /* e usa il percorso diretto
public class GetProductInfoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private transient ProductDaoDataSource productDAO;

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        productDAO = new ProductDaoDataSource(dataSource);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        System.out.println("GetProductInfoServlet doGet called with id=" + idParam); // Debugging
        if (idParam == null || idParam.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"ID prodotto mancante\"}");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"ID prodotto non valido\"}");
            return;
        }

        try {
            ProductBean product = productDAO.doRetrieveByKey(productId);

            if (product == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Prodotto non trovato\"}");
                return;
            }

            // JSON manuale come richiesto
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"id\":").append(product.getCode()).append(",");
            json.append("\"name\":\"").append(escapeJson(product.getName())).append("\",");
            json.append("\"price\":").append(product.getPrice()).append(",");
            json.append("\"image\":\"").append(escapeJson(product.getImage())).append("\",");
            json.append("\"maxQty\":").append(product.getQuantity());
            json.append("}");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.write(json.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Errore database\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
}