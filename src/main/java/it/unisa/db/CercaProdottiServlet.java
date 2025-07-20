package it.unisa.db;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collection;

import javax.sql.DataSource;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/CercaProdottiServlet")
public class CercaProdottiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private transient ProductDaoDataSource productDao;

    @Override
    public void init() throws ServletException {
        //Ottieni DataSource dal contesto
        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        productDao = new ProductDaoDataSource(ds);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //Parametri ricerca
        String q = request.getParameter("q"); //nome prodotto
        String categoria = request.getParameter("categoria"); //Categoria
        String ordine = request.getParameter("ordine"); //Ordinamento
        String prezzoMin = request.getParameter("prezzoMin"); //Prezzo minimo
        String prezzoMax = request.getParameter("prezzoMax"); //Prezzo massimo

        if (categoria != null && categoria.equals("0")) {
            categoria = "";
        }

        try {
            //Ottieni prod filtrati
            Collection<ProductBean> prodotti = productDao.doSearch(q, categoria, ordine, prezzoMin, prezzoMax);

            //Costruzione JSON
            StringBuilder json = new StringBuilder("[");

            int i = 0;
            for (ProductBean prodotto : prodotti) {
                json.append("{");
                json.append("\"code\":").append(prodotto.getCode()).append(",");
                json.append("\"name\":\"").append(escapeJson(prodotto.getName())).append("\",");
                json.append("\"description\":\"").append(escapeJson(prodotto.getDescription())).append("\",");
                json.append("\"price\":").append(prodotto.getPrice()).append(",");
                json.append("\"quantity\":").append(prodotto.getQuantity()).append(",");
                json.append("\"image\":\"").append(escapeJson(prodotto.getImage())).append("\"");
                json.append("}");

                if (i < prodotti.size() - 1) json.append(",");
                i++;
            }

            json.append("]");

            //Imposta risposta JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Errore DB durante il recupero dei prodotti\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
}
