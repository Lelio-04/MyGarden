package it.unisa.db;

import java.sql.SQLException;
import java.util.Collection;

public interface IProductDao {
	
	public void doSave(ProductBean product) throws SQLException;

	public boolean doDelete(int code) throws SQLException;

	public ProductBean doRetrieveByKey(int code) throws SQLException;
	
	public void doUpdate(ProductBean product) throws SQLException;
	
	public Collection<ProductBean> doRetrieveAll(String order) throws SQLException;

}



