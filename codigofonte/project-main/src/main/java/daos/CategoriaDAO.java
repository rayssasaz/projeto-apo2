package daos;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;


import models.CategoriaChamado;
import java.sql.Connection;

public class CategoriaDAO {
	private Connection conn;
	
	public CategoriaDAO(Connection conn){
		this.conn = conn;
	}
	
	public boolean inserirCategoria(CategoriaChamado categoria) {
		PreparedStatement stmt = null;
		
		String sql = "INSERT INTO tb_categoria(nome_categoria, descricao) values (?, ?)";
		
		try {
			stmt = conn.prepareStatement(sql);
	        stmt.setString(1, categoria.getNome());
	        stmt.setString(2, categoria.getDescricao());
	        
	        // Executa a inserção no banco
	        int linhasAfetadas = stmt.executeUpdate();
	        
	        // Se inseriu pelo menos 1 linha, retorna true
	        return linhasAfetadas > 0;
			
		}catch(SQLException e) {
			e.printStackTrace();
	        return false;
		}				
	}
	
	public List<CategoriaChamado> listarCategorias(){
		PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.ArrayList<CategoriaChamado> lista = new java.util.ArrayList<>();
       // String sql = "SELECT id_categoria, nome_categoria, descricao FROM tb_categoria";
        String sql = "SELECT id_categoria, nome_categoria, descricao FROM tb_categoria ORDER BY nome_categoria ASC";
        
        try {
        	stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while(rs.next()) {
            	CategoriaChamado c = new CategoriaChamado();
            	c.setIdCategoria(rs.getInt("id_categoria"));
            	c.setNome(rs.getString("nome_categoria"));
            	c.setDescricao(rs.getString("descricao"));
            	
            	lista.add(c);
            }          
        }catch(SQLException e){
        	e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
	}
	
	/**
     * Remove uma categoria pelo ID
     */
    public boolean deletarCategoria(int id) {
        PreparedStatement stmt = null;
        String sql = "DELETE FROM tb_categoria WHERE id_categoria = ?";

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);

            int linhasAfetadas = stmt.executeUpdate();
            return linhasAfetadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false; // Retorna false se violar chaves estrangeiras (categoria em uso por chamados)
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * Retorna a lista de especialidades (categorias) associadas a um técnico
     */
    public java.util.List<CategoriaChamado> listarPorTecnico(int idTecnico) {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<CategoriaChamado> lista = new java.util.ArrayList<>();
        
        // CORREÇÃO 1: Mudei descricao_categoria para descricao
        String sql = "SELECT c.id_categoria, c.nome_categoria, c.descricao " +
                     "FROM tb_categoria c " +
                     "INNER JOIN tb_tecnico_categoria tc ON c.id_categoria = tc.id_categoria " +
                     "WHERE tc.id_usuario = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idTecnico);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                CategoriaChamado cat = new CategoriaChamado();
                cat.setIdCategoria(rs.getInt("id_categoria"));
                cat.setNome(rs.getString("nome_categoria"));
                
                // CORREÇÃO 2: Mudei aqui também para ler a coluna correta
                cat.setDescricao(rs.getString("descricao")); 
                lista.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // DICA: Se der erro, olhe a aba "Console" do Eclipse, o motivo em vermelho estará lá!
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
    }
	
}
