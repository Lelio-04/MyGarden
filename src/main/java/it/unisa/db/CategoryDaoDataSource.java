package it.unisa.db;

import java.sql.*;
import java.util.*;

import javax.sql.DataSource;

public class CategoryDaoDataSource {
    private DataSource dataSource;

    public CategoryDaoDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<CategoryBean> getAllCategories() throws SQLException {
        List<CategoryBean> categories = new ArrayList<>();

        try (Connection conn = dataSource.getConnection()) {
            String query = "SELECT id, name FROM categories"; // Esegui la query per ottenere le categorie
            try (Statement stmt = conn.createStatement()) {
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
                    CategoryBean category = new CategoryBean();
                    category.setId(rs.getInt("id"));
                    category.setName(rs.getString("name"));
                    categories.add(category);
                }
            }
        }

        return categories;
    }
}
