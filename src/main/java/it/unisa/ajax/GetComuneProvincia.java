package it.unisa.ajax;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/GetComuneProvincia")
public class GetComuneProvincia extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (dataSource == null) {
            throw new ServletException("DataSourceStorage non disponibile.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String cap = request.getParameter("cap");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            if (cap == null || !cap.matches("\\d{5}")) {
                out.write("{\"success\": false, \"error\": \"CAP non valido\"}");
                return;
            }

            try (Connection conn = dataSource.getConnection()) {
                String sql = "SELECT nome_comune, sigla_provincia FROM comuni WHERE cap = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, cap);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String comune = rs.getString("nome_comune");
                            String provincia = rs.getString("sigla_provincia");
                            out.write("{\"success\": true, \"city\": \"" + comune + "\", \"provincia\": \"" + provincia + "\"}");
                        } else {
                            out.write("{\"success\": false, \"error\": \"CAP non trovato\"}");
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.write("{\"success\": false, \"error\": \"Errore DB\"}");
            }
        }
    }
}
