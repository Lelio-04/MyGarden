package it.unisa.db;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import javax.sql.DataSource;

@WebListener
public class MainContext implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();

        try {
            Context initCtx = new InitialContext();
            Context envCtx = (Context) initCtx.lookup("java:comp/env");

            DataSource dsStorage = (DataSource) envCtx.lookup("jdbc/storage");
            context.setAttribute("DataSourceStorage", dsStorage);
            context.setAttribute("DataSourceUtenti", dsStorage);
            System.out.println("✅ DataSource 'storage' inizializzato correttamente");

        } catch (NamingException e) {
            System.out.println("❌ Errore JNDI: " + e.getMessage());
        }
    }

}
