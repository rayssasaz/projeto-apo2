package daos;



import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import models.Usuario;
import models.NivelAcesso;

public class UsuarioDAO {
	
	private Connection conn;
	
	public UsuarioDAO(Connection conn) {
		this.conn = conn;
	}
	
	
	public boolean validarEmail(String email) {
	    String sql = "UPDATE tb_usuario SET email_verificado = TRUE WHERE email = ?";
	    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
	        stmt.setString(1, email);
	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}
	
	
	public boolean inserir(Usuario usuario) {
	    PreparedStatement stmt = null;
	  //  Connection conn = null; // Certifique-se de obter a conexão aqui dentro ou passar por parâmetro
	    
	    String sql = "INSERT INTO tb_usuario (nome_usuario, email, senha, papel) values (?, ?, ?, ?)";
	    
	    try {
	        // 1. Obtém a conexão com o banco
	      //  conn = ConnectionFactory.getConnection();
	        
	        // 2. Prepara o statement
	        stmt = conn.prepareStatement(sql);
	        stmt.setString(1, usuario.getNome());
	        stmt.setString(2, usuario.getEmail());
	        stmt.setString(3, usuario.getSenha());
	        
	        // A MÁGICA ESTÁ AQUI: O .name() transforma o Enum ADMIN em uma String "ADMIN"
	        stmt.setString(4, usuario.getAcesso().name());
	        
	        // 3. Executa a inserção no banco
	        int linhasAfetadas = stmt.executeUpdate();
	        
	        // Se inseriu pelo menos 1 linha, retorna true
	        return linhasAfetadas > 0;
	        
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false; // Se der erro (ex: e-mail duplicado), retorna false
	    } finally {
	        // 4. Sempre feche os recursos para evitar travamento do banco
	        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
	       // try { if (conn != null) conn.close(); } catch (SQLException e) {}
	    }
	}
	
	

    public Usuario autenticar(String email, String senha) { //SENHA HASHEADA
     //   Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Usuario usuario = null;	

        try {
          
            // prepara a query SQL (Segura contra SQL Injection)
            String sql = "SELECT id_usuario, nome_usuario, email, papel, email_verificado FROM tb_usuario WHERE email = ? AND senha = ?";
            stmt = conn.prepareStatement(sql);
            // Nota: A senha ja está hasheada (o AuthServlet passa a senha hasheada como parâmetro na chamada do método)
            stmt.setString(1, email);
            stmt.setString(2, senha); // O banco vai comparar HASH com HASH
            
            // 3. Executa a query
            rs = stmt.executeQuery();
            
            

            // 4. Se encontrou o usuário, preenche o objeto
            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNome(rs.getString("nome_usuario"));
                usuario.setEmail(rs.getString("email"));
                usuario.setEmailVerificado(rs.getBoolean("email_verificado"));
                
                // Converte a String do ENUM do MySQL para o Enum do Java
                String papelBanco = rs.getString("papel");
                usuario.setAcesso(NivelAcesso.valueOf(papelBanco));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Fecha os recursos do banco (Boa prática obrigatória)
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
           // try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        return usuario; // retorna o usuário preenchido ou null se falhar
    }
    
    
    public boolean atualizarSenha(String email, String novaSenhaHasheada) {
        String sql = "UPDATE tb_usuario SET senha = ? WHERE email = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, novaSenhaHasheada);
            stmt.setString(2, email);
            
            int linhasAfetadas = stmt.executeUpdate();
            return linhasAfetadas > 0; // retorna true se conseguiu atualizar
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Usuario buscarPorEmail(String email) {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Usuario usuario = null;
        String sql = "SELECT id_usuario, nome_usuario, email, papel FROM tb_usuario WHERE email = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNome(rs.getString("nome_usuario"));
                usuario.setEmail(rs.getString("email"));
                usuario.setAcesso(NivelAcesso.valueOf(rs.getString("papel")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return usuario;
    }
    
    // OUTROS MÉTODOS
    
 // Para o Administrador mudar o nível de acesso de um usuário (RF16)
    public boolean alterarPapel(int idUsuario, NivelAcesso novoAcesso) {
        PreparedStatement stmt = null;
        String sql = "UPDATE tb_usuario SET papel = ? WHERE id_usuario = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, novoAcesso.name());
            stmt.setInt(2, idUsuario);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }

    // Para o Administrador listar todos os usuários no painel de controle
    public java.util.List<Usuario> listarTodos() {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.ArrayList<Usuario> lista = new java.util.ArrayList<>();
        String sql = "SELECT id_usuario, nome_usuario, email, papel FROM tb_usuario";
        
        try {
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Usuario u = new Usuario();
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setNome(rs.getString("nome_usuario"));
                u.setEmail(rs.getString("email"));
                u.setAcesso(NivelAcesso.valueOf(rs.getString("papel")));
                lista.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
    }
    
    
    
    
    
 // Busca apenas os IDs das categorias que um técnico específico atende
    public java.util.List<Integer> listarIdsCategoriasPorTecnico(int idTecnico) {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Integer> ids = new java.util.ArrayList<>();
        String sql = "SELECT id_categoria FROM tb_tecnico_categoria WHERE id_usuario = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idTecnico);
            rs = stmt.executeQuery();
            while (rs.next()) {
                ids.add(rs.getInt("id_categoria"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return ids;
    }

    // Atualiza as especialidades do técnico (Deleta as antigas e insere as novas)
    public boolean salvarCategoriasTecnico(int idTecnico, String[] idsCategorias) {
        PreparedStatement stmtDelete = null;
        PreparedStatement stmtInsert = null;
        
        String sqlDelete = "DELETE FROM tb_tecnico_categoria WHERE id_usuario = ?";
        String sqlInsert = "INSERT INTO tb_tecnico_categoria (id_usuario, id_categoria) VALUES (?, ?)";
        
        try {
            // Desativa o auto-commit para fazer as operações como uma transação segura
            boolean autoCommitOriginal = conn.getAutoCommit();
            conn.setAutoCommit(false);
            
            // 1. Limpa o que ele já tinha cadastrado
            stmtDelete = conn.prepareStatement(sqlDelete);
            stmtDelete.setInt(1, idTecnico);
            stmtDelete.executeUpdate();
            
            // 2. Insere as novas marcações (se houver alguma selecionada)
            if (idsCategorias != null && idsCategorias.length > 0) {
                stmtInsert = conn.prepareStatement(sqlInsert);
                for (String idCatStr : idsCategorias) {
                    stmtInsert.setInt(1, idTecnico);
                    stmtInsert.setInt(2, Integer.parseInt(idCatStr));
                    stmtInsert.addBatch(); // Adiciona em lote para performance
                }
                stmtInsert.executeBatch();
            }
            
            conn.commit(); // Grava tudo de vez no banco
            conn.setAutoCommit(autoCommitOriginal);
            return true;
            
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmtDelete != null) stmtDelete.close(); } catch (Exception e) {}
            try { if (stmtInsert != null) stmtInsert.close(); } catch (Exception e) {}
        }
    }
    
    
 // Atualiza os dados básicos e, opcionalmente, a senha
    public boolean atualizarPerfil(Usuario usuario, boolean alterarSenha) {
        PreparedStatement stmt = null;
        // Se for alterar a senha, o UPDATE inclui a coluna senha. Senão, ignora ela.
        String sql = alterarSenha 
            ? "UPDATE tb_usuario SET nome_usuario = ?, email = ?, senha = ? WHERE id_usuario = ?"
            : "UPDATE tb_usuario SET nome_usuario = ?, email = ? WHERE id_usuario = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, usuario.getNome());
            stmt.setString(2, usuario.getEmail());
            
            if (alterarSenha) {
                stmt.setString(3, usuario.getSenha()); // Senha já deve vir criptografada do Servlet
                stmt.setInt(4, usuario.getIdUsuario());
            } else {
                stmt.setInt(3, usuario.getIdUsuario());
            }
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false; // Retorna false caso o e-mail escolhido já exista no banco (UNIQUE constraint)
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * Retorna o total de usuários cadastrados no sistema
     */
    public int contarTotalUsuarios() {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        int total = 0;
        
        String sql = "SELECT COUNT(*) AS total FROM tb_usuario";
        
        try {
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                total = rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return total;
    }
}