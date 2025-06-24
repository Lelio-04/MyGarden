package it.unisa.db;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/DettaglioProdottoServlet")
public class DettaglioProdottoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private ProductDaoDriverMan productDao;

    @Override
    public void init() throws ServletException {
        DriverManagerConnectionPool dmcp = new DriverManagerConnectionPool();
        productDao = new ProductDaoDriverMan(dmcp);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String codeParam = request.getParameter("code");

        if (codeParam == null || codeParam.isEmpty()) {
            response.sendRedirect("product");
            return;
        }

        try {
            int code = Integer.parseInt(codeParam);
            ProductBean product = productDao.doRetrieveByKey(code);

            if (product == null || product.getName() == null) {
                response.sendRedirect("product");
                return;
            }

            request.setAttribute("product", product);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/dettaglioProdotto.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel recupero del prodotto.");
        }
    }
}
