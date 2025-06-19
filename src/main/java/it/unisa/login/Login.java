package it.unisa.login;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Login")
public class Login extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		List<String> errors = new ArrayList<>();
		RequestDispatcher dispatcherToLoginPage = request.getRequestDispatcher("login.jsp");
		if (username == null || username.trim().isEmpty()) {
			errors.add("Il campo username non può essere vuoto!");
		}
		if (password == null || password.trim().isEmpty()) {
			errors.add("Il campo password non può essere vuoto!");
		}
		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			dispatcherToLoginPage.forward(request, response);
			return; // note the return statement here!!!
		}
		username = username.trim();
		password = password.trim();
		String hashPassword = toHash(password);
		// Hash of "mypass":
		String hashPasswordToBeMatch = 
				"1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2";
		if (username.equals("admin") && hashPassword.equals(hashPasswordToBeMatch)) { // admin
			request.getSession().setAttribute("isAdmin", Boolean.TRUE); // inserisco il token nella sessione
			response.sendRedirect("admin/protected.jsp");
		} else if (username.equals("user") && hashPassword.equals(hashPasswordToBeMatch)) { // user
			request.getSession().setAttribute("isAdmin", Boolean.FALSE); // inserisco il token nella sessione
			response.sendRedirect("common/protected.jsp");
		} else {
			errors.add("Username o password non validi!");
			request.setAttribute("errors", errors);
			dispatcherToLoginPage.forward(request, response);
		}
	}

	private String toHash(String password) {
		String hashString = null;
		try {
			java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-512");
			byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
			hashString = "";
			for (int i = 0; i < hash.length; i++) {
				hashString += Integer.toHexString((hash[i] & 0xFF) | 0x100).substring(1, 3);
			}
		} catch (java.security.NoSuchAlgorithmException e) {
			System.out.println(e);
		}
		return hashString;
	}

	private static final long serialVersionUID = 1L;

}
