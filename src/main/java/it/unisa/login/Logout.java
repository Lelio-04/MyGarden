package it.unisa.login;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class Logout
 */
@WebServlet("/common/Logout")
public class Logout extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		
		Boolean isAdmin = (Boolean) request.getSession().getAttribute("isAdmin");
		if (isAdmin == null){	
		    response.sendRedirect(request.getContextPath() + "/login.jsp"); 
		    return;
		}
		
		request.getSession().invalidate();
		response.sendRedirect(request.getContextPath() + "/index.jsp");	
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		doGet(request, response);
	}
	
	private static final long serialVersionUID = 1L;
	
}
