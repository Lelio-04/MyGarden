package it.unisa.db;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/getCategories")
public class GetCategoriesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private transient DataSource dataSource;
    private transient CategoryDaoDataSource categoryDao;

    @Override
    public void init() throws ServletException {
        try {
            //Recupera DataSource da contesto JNDI
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:comp/env");
            dataSource = (DataSource) envContext.lookup("jdbc/storage"); // Nome JNDI configurato

            categoryDao = new CategoryDaoDataSource(dataSource);

        } catch (NamingException e) {
            throw new ServletException("Impossibile ottenere il DataSource tramite JNDI", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<CategoryBean> categorie = categoryDao.getAllCategories();

            CategoryBean allCategories = new CategoryBean();
            allCategories.setId(0);
            allCategories.setName("Tutte le categorie");
            categorie.add(0, allCategories);
            StringBuilder json = new StringBuilder("[");

            int i = 0;
            for (CategoryBean categoria : categorie) {
                json.append("{");
                json.append("\"id\":").append(categoria.getId()).append(",");
                json.append("\"name\":\"").append(escapeJson(categoria.getName())).append("\"");
                json.append("}");

                if (i < categorie.size() - 1) json.append(",");
                i++;
            }

            json.append("]");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Errore DB durante il recupero delle categorie\"}");
        }
    }
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
}

