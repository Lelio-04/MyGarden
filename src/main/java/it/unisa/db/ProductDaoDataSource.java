package it.unisa.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import javax.sql.DataSource;

public class ProductDaoDataSource implements IProductDao {
    
    private static final String TABLE_NAME = "product";
    private DataSource ds = null;

    public ProductDaoDataSource(DataSource ds) {
        this.ds = ds;
        System.out.println("DataSource Product Model creation....");
    }

    @Override
    public synchronized void doSave(ProductBean product) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        String insertSQL = "INSERT INTO " + TABLE_NAME
                + " (NAME, DESCRIPTION, PRICE, QUANTITY, IMAGE, is_deleted) VALUES (?, ?, ?, ?, ?, FALSE)";

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(insertSQL);
            preparedStatement.setString(1, product.getName());
            preparedStatement.setString(2, product.getDescription());
            preparedStatement.setDouble(3, product.getPrice());
            preparedStatement.setInt(4, product.getQuantity());
            preparedStatement.setString(5, product.getImage());

            preparedStatement.executeUpdate();

        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                if (connection != null)
                    connection.close();
            }
        }
    }

    @Override
    public synchronized ProductBean doRetrieveByKey(int code) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        ProductBean bean = new ProductBean();

        String selectSQL = "SELECT * FROM " + TABLE_NAME + " WHERE CODE = ? AND is_deleted = FALSE";

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(selectSQL);
            preparedStatement.setInt(1, code);

            ResultSet rs = preparedStatement.executeQuery();

            if (rs.next()) {
                bean.setCode(rs.getInt("CODE"));
                bean.setName(rs.getString("NAME"));
                bean.setDescription(rs.getString("DESCRIPTION"));
                bean.setPrice(rs.getDouble("PRICE"));
                bean.setQuantity(rs.getInt("QUANTITY"));
                bean.setImage(rs.getString("IMAGE"));
            }

        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                if (connection != null)
                    connection.close();
            }
        }
        return bean;
    }

    @Override
    public synchronized boolean doDelete(int code) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        int result = 0;

        String deleteSQL = "UPDATE " + TABLE_NAME + " SET is_deleted = TRUE WHERE code = ?";

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(deleteSQL);
            preparedStatement.setInt(1, code);

            result = preparedStatement.executeUpdate();
        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                if (connection != null)
                    connection.close();
            }
        }

        return (result != 0);
    }

    public void doUpdate(ProductBean product) throws SQLException {
        String sql = "UPDATE " + TABLE_NAME + " SET name=?, description=?, price=?, quantity=?, image=? WHERE code=?";
        try (Connection con = ds.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setInt(4, product.getQuantity());
            ps.setString(5, product.getImage());
            ps.setInt(6, product.getCode());
            ps.executeUpdate();
        }
    }

    @Override
    public synchronized Collection<ProductBean> doRetrieveAll(String order) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        Collection<ProductBean> products = new LinkedList<>();

        String selectSQL = "SELECT * FROM " + TABLE_NAME + " WHERE is_deleted = FALSE";
        if (order != null && !order.equals("")) {
            selectSQL += " ORDER BY " + order;
        }

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(selectSQL);

            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                ProductBean bean = new ProductBean();
                bean.setCode(rs.getInt("CODE"));
                bean.setName(rs.getString("NAME"));
                bean.setDescription(rs.getString("DESCRIPTION"));
                bean.setPrice(rs.getDouble("PRICE"));
                bean.setQuantity(rs.getInt("QUANTITY"));
                bean.setImage(rs.getString("IMAGE"));
                products.add(bean);
            }

        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                if (connection != null)
                    connection.close();
            }
        }
        return products;
    }
    
    public synchronized Collection<ProductBean> doRetrieveByCategory(String categoryName) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        Collection<ProductBean> products = new LinkedList<>();

        String selectSQL = "SELECT p.* FROM " + TABLE_NAME + " p " +
                           "JOIN categories c ON p.category_id = c.id " +
                           "WHERE c.name = ? AND p.is_deleted = FALSE";

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(selectSQL);
            preparedStatement.setString(1, categoryName);

            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                ProductBean bean = new ProductBean();
                bean.setCode(rs.getInt("CODE"));
                bean.setName(rs.getString("NAME"));
                bean.setDescription(rs.getString("DESCRIPTION"));
                bean.setPrice(rs.getDouble("PRICE"));
                bean.setQuantity(rs.getInt("QUANTITY"));
                bean.setImage(rs.getString("IMAGE"));
                // Salva solo il nome della categoria se hai un campo per questo
                // bean.setCategory(categoryName);
                products.add(bean);
            }

        } finally {
            try {
                if (preparedStatement != null) preparedStatement.close();
            } finally {
                if (connection != null) connection.close();
            }
        }

        return products;
    }
    public Collection<ProductBean> doSearch(String q, String categoria, String ordine, String prezzoMin, String prezzoMax) throws SQLException {
        List<ProductBean> prodotti = new ArrayList<>();
        Connection connection = null;

        try {
            // Ottieni la connessione dal DataSource
            connection = ds.getConnection();
            
            // Creiamo una query base per la ricerca
            String query = "SELECT * FROM product WHERE name LIKE ?";

            // Aggiungi il filtro per la categoria se presente
            if (categoria != null && !categoria.isEmpty()) {
                query += " AND category_id = ?";
            }

            // Aggiungi il filtro per il prezzo minimo
            if (prezzoMin != null && !prezzoMin.isEmpty()) {
                query += " AND price >= ?";
            }

            // Aggiungi il filtro per il prezzo massimo
            if (prezzoMax != null && !prezzoMax.isEmpty()) {
                query += " AND price <= ?";
            }

            // Aggiungi l'ordinamento
            if (ordine != null && !ordine.isEmpty()) {
                query += " ORDER BY " + ordine;
            }

            // Prepara la query
            PreparedStatement stmt = connection.prepareStatement(query);

            int paramIndex = 1;

            // Imposta il parametro per il nome prodotto
            stmt.setString(paramIndex++, "%" + q + "%");

            // Imposta il parametro per la categoria, se presente
            if (categoria != null && !categoria.isEmpty()) {
                stmt.setString(paramIndex++, categoria);
            }

            // Imposta il parametro per il prezzo minimo, se presente
            if (prezzoMin != null && !prezzoMin.isEmpty()) {
                stmt.setDouble(paramIndex++, Double.parseDouble(prezzoMin));
            }

            // Imposta il parametro per il prezzo massimo, se presente
            if (prezzoMax != null && !prezzoMax.isEmpty()) {
                stmt.setDouble(paramIndex++, Double.parseDouble(prezzoMax));
            }

            // Esegui la query
            ResultSet rs = stmt.executeQuery();

            // Crea una lista di prodotti
            while (rs.next()) {
                ProductBean prodotto = new ProductBean();
                prodotto.setCode(rs.getInt("code"));
                prodotto.setName(rs.getString("name"));
                prodotto.setDescription(rs.getString("description"));
                prodotto.setPrice(rs.getDouble("price"));
                prodotto.setQuantity(rs.getInt("quantity"));
                prodotto.setImage(rs.getString("image"));
                prodotti.add(prodotto);
            }

        } finally {
            if (connection != null) {
                connection.close(); // Assicurati di chiudere la connessione
            }
        }

        return prodotti;
    }
    public synchronized Collection<String> getCategories() throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        Collection<String> categories = new LinkedList<>();

        String selectSQL = "SELECT name FROM categories";

        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(selectSQL);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                categories.add(rs.getString("name"));
            }

        } finally {
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) connection.close();
        }

        return categories;
    }


}
