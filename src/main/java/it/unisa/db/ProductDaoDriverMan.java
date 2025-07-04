package it.unisa.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collection;
import java.util.LinkedList;

public class ProductDaoDriverMan implements IProductDao {

    private static final String TABLE_NAME = "product";
    private DriverManagerConnectionPool dmcp = null;

    public ProductDaoDriverMan(DriverManagerConnectionPool dmcp) {
        this.dmcp = dmcp;
        System.out.println("DriverManager Product Model creation...");
    }

    @Override
    public synchronized void doSave(ProductBean product) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        String insertSQL = "INSERT INTO " + TABLE_NAME + " (NAME, DESCRIPTION, PRICE, QUANTITY, IMAGE) VALUES (?, ?, ?, ?, ?)";

        try {
            connection = dmcp.getConnection();
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
                dmcp.releaseConnection(connection);
            }
        }
    }

    @Override
    public synchronized ProductBean doRetrieveByKey(int code) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ProductBean bean = new ProductBean();

        String selectSQL = "SELECT * FROM " + TABLE_NAME + " WHERE CODE = ?";

        try {
            connection = dmcp.getConnection();
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
                dmcp.releaseConnection(connection);
            }
        }

        return bean;
    }

    @Override
    public synchronized boolean doDelete(int code) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        int result = 0;

        String deleteSQL = "DELETE FROM " + TABLE_NAME + " WHERE CODE = ?";

        try {
            connection = dmcp.getConnection();
            preparedStatement = connection.prepareStatement(deleteSQL);
            preparedStatement.setInt(1, code);

            result = preparedStatement.executeUpdate();

        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                dmcp.releaseConnection(connection);
            }
        }

        return (result != 0);
    }

    @Override
    public synchronized void doUpdate(ProductBean product) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        String updateSQL = "UPDATE " + TABLE_NAME + " SET NAME=?, DESCRIPTION=?, PRICE=?, QUANTITY=?, IMAGE=? WHERE CODE=?";

        try {
            connection = dmcp.getConnection();
            preparedStatement = connection.prepareStatement(updateSQL);
            preparedStatement.setString(1, product.getName());
            preparedStatement.setString(2, product.getDescription());
            preparedStatement.setDouble(3, product.getPrice());
            preparedStatement.setInt(4, product.getQuantity());
            preparedStatement.setString(5, product.getImage());
            preparedStatement.setInt(6, product.getCode());

            preparedStatement.executeUpdate();

        } finally {
            try {
                if (preparedStatement != null)
                    preparedStatement.close();
            } finally {
                dmcp.releaseConnection(connection);
            }
        }
    }

    @Override
    public synchronized Collection<ProductBean> doRetrieveAll(String order) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        Collection<ProductBean> products = new LinkedList<>();

        String selectSQL = "SELECT * FROM " + TABLE_NAME;
        if (order != null && !order.isEmpty()) {
            selectSQL += " ORDER BY " + order;
        }

        try {
            connection = dmcp.getConnection();
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
                dmcp.releaseConnection(connection);
            }
        }

        return products;
    }
}
