package it.unisa.db;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDao {
    private final DataSource dataSource;

    public ReviewDao(DataSource ds) {
        this.dataSource = ds;
    }

    public List<ReviewBean> getByProductId(int productId) throws SQLException {
        List<ReviewBean> reviews = new ArrayList<>();

        String sql = "SELECT * FROM recensioni WHERE prodotto_id = ?";
        try (Connection con = dataSource.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewBean review = new ReviewBean();
                    review.setId(rs.getInt("id"));
                    review.setProdottoId(rs.getInt("prodotto_id"));
                    review.setUser(rs.getString("utente"));
                    review.setStars(rs.getInt("stelle"));
                    review.setText(rs.getString("testo"));
                    reviews.add(review);
                }
            }
        }

        return reviews;
    }
}
