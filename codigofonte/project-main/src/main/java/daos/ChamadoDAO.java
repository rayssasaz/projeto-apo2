package daos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import models.Chamado;

public class ChamadoDAO {
    
    private Connection conn;

    public ChamadoDAO(Connection conn) {
        this.conn = conn;
    }

    /**
     * Insere um novo chamado no banco de dados (Ação do Cliente)
     */
    public boolean inserirChamado(Chamado chamado) {
        PreparedStatement stmt = null;
        
        // Repare que id_tecnico e observacoes_tecnico não entram no INSERT,
        // pois o chamado nasce sem técnico (NULL no banco) e sem observações.
        String sql = "INSERT INTO tb_chamado (id_cliente, id_categoria, titulo, descricao, status, data_abertura, data_atualizacao) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try {
            stmt = conn.prepareStatement(sql);
            
            // 1. Chaves estrangeiras (Pega os IDs de dentro dos objetos Cliente e Categoria)
            stmt.setInt(1, chamado.getCliente().getIdUsuario());
            stmt.setInt(2, chamado.getCategoria().getIdCategoria());
            
            // 2. Textos
            stmt.setString(3, chamado.getTitulo());
            stmt.setString(4, chamado.getDescricao());
            
            // 3. Status (Transforma o Enum do Java em String para o MySQL)
            stmt.setString(5, chamado.getStatus().name());
            
            // 4. Datas (Converte o LocalDateTime do Java 8 para o java.sql.Timestamp exigido pelo JDBC)
            stmt.setTimestamp(6, Timestamp.valueOf(chamado.getDataAbertura()));
            stmt.setTimestamp(7, Timestamp.valueOf(chamado.getDataAtualizacao()));
            
            int linhasAfetadas = stmt.executeUpdate();
            return linhasAfetadas > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
        
    }
    
    /**
     * Retorna o histórico de chamados de um cliente específico
     */
    /**
     * Retorna o histórico de chamados de um cliente específico (Atualizado)
     */
    public java.util.List<Chamado> listarPorCliente(int idCliente) {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Chamado> lista = new java.util.ArrayList<>();

        // ADICIONADO: ch.observacoes_tecnico na consulta
        String sql = "SELECT ch.id_chamado, ch.titulo, ch.status, ch.data_abertura, ch.observacoes_tecnico, " +
                     "cat.nome_categoria, tec.nome_usuario AS nome_tecnico " +
                     "FROM tb_chamado ch " +
                     "INNER JOIN tb_categoria cat ON ch.id_categoria = cat.id_categoria " +
                     "LEFT JOIN tb_usuario tec ON ch.id_tecnico = tec.id_usuario " +
                     "WHERE ch.id_cliente = ? ORDER BY ch.data_abertura DESC";

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idCliente);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Chamado c = new Chamado();
                c.setIdChamado(rs.getInt("id_chamado"));
                c.setTitulo(rs.getString("titulo"));
                c.setStatus(models.StatusChamado.valueOf(rs.getString("status")));
                c.setDataAbertura(rs.getTimestamp("data_abertura").toLocalDateTime());
                
                // ADICIONADO: Popula a observação técnica no objeto
                c.setObservacoesTecnico(rs.getString("observacoes_tecnico"));

                models.CategoriaChamado cat = new models.CategoriaChamado();
                cat.setNome(rs.getString("nome_categoria"));
                c.setCategoria(cat);

                String nomeTecnico = rs.getString("nome_tecnico");
                if (nomeTecnico != null) {
                    models.Usuario tecnico = new models.Usuario();
                    tecnico.setNome(nomeTecnico);
                    c.setTecnico(tecnico);
                }

                lista.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
    }
    
    
    /**
     * Cancela um chamado (Ação do Cliente)
     */
    public boolean cancelarChamado(int idChamado, int idClienteLogado) {
        PreparedStatement stmt = null;
        
        // A trava de segurança: Só atualiza se o ID do cliente bater e o status for ABERTO
        String sql = "UPDATE tb_chamado SET status = 'CANCELADO', data_atualizacao = ? "
                   + "WHERE id_chamado = ? AND id_cliente = ? AND status = 'ABERTO'";
        
        try {
            stmt = conn.prepareStatement(sql);
            
            // Registra o momento exato do cancelamento
            stmt.setTimestamp(1, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            stmt.setInt(2, idChamado);
            stmt.setInt(3, idClienteLogado);
            
            int linhasAfetadas = stmt.executeUpdate();
            return linhasAfetadas > 0; // Retorna true se conseguiu alterar a linha
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    
    // MÉTODO PAA GERENCIAMENTO GLOBAL DE CHAMADOS PELO ADMIN
    /**
     * Retorna a fila global de chamados do sistema (Visão do Administrador/Suporte)
     */
    public java.util.List<Chamado> listarTodos() {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Chamado> lista = new java.util.ArrayList<>();

        // JOIN duplo na tb_usuario: um para o Cliente (cli) e outro para o Técnico (tec)
        String sql = "SELECT ch.id_chamado, ch.titulo, ch.status, ch.data_abertura, " +
                     "cat.nome_categoria, " +
                     "cli.nome_usuario AS nome_cliente, " +
                     "tec.nome_usuario AS nome_tecnico " +
                     "FROM tb_chamado ch " +
                     "INNER JOIN tb_usuario cli ON ch.id_cliente = cli.id_usuario " +
                     "INNER JOIN tb_categoria cat ON ch.id_categoria = cat.id_categoria " +
                     "LEFT JOIN tb_usuario tec ON ch.id_tecnico = tec.id_usuario " +
                     "ORDER BY ch.data_abertura DESC";

        try {
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Chamado c = new Chamado();
                c.setIdChamado(rs.getInt("id_chamado"));
                c.setTitulo(rs.getString("titulo"));
                c.setStatus(models.StatusChamado.valueOf(rs.getString("status")));
                c.setDataAbertura(rs.getTimestamp("data_abertura").toLocalDateTime());

                // Monta o objeto Categoria
                models.CategoriaChamado cat = new models.CategoriaChamado();
                cat.setNome(rs.getString("nome_categoria"));
                c.setCategoria(cat);

                // Monta o objeto Cliente (Obrigatório)
                models.Usuario cliente = new models.Usuario();
                cliente.setNome(rs.getString("nome_cliente"));
                c.setCliente(cliente);

                // Monta o objeto Técnico (Pode ser nulo se estiver ABERTO)
                String nomeTecnico = rs.getString("nome_tecnico");
                if (nomeTecnico != null) {
                    models.Usuario tecnico = new models.Usuario();
                    tecnico.setNome(nomeTecnico);
                    c.setTecnico(tecnico);
                }

                lista.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
    }
    
    
    
    /**
     * Retorna a fila de chamados APENAS das categorias em que o técnico é especialista
     */
    public java.util.List<Chamado> listarFilaDoTecnico(int idTecnico) {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Chamado> lista = new java.util.ArrayList<>();

        // Usamos uma subquery limpa para evitar escopos ambíguos nas colunas e duplicação de dados
        String sql = "SELECT ch.id_chamado, ch.titulo, ch.status, ch.data_abertura, " +
                     "cat.nome_categoria, " +
                     "cli.nome_usuario AS nome_cliente, " +
                     "tec.nome_usuario AS nome_tecnico " +
                     "FROM tb_chamado ch " +
                     "INNER JOIN tb_usuario cli ON ch.id_cliente = cli.id_usuario " +
                     "INNER JOIN tb_categoria cat ON ch.id_categoria = cat.id_categoria " +
                     "LEFT JOIN tb_usuario tec ON ch.id_tecnico = tec.id_usuario " +
                     "WHERE ch.id_categoria IN (" +
                     "    SELECT tc.id_categoria FROM tb_tecnico_categoria tc WHERE tc.id_usuario = ?" +
                     ") " +
                     "ORDER BY " +
                     "CASE WHEN ch.status = 'ABERTO' THEN 1 " +
                     "WHEN ch.status = 'EM_ANDAMENTO' THEN 2 " +
                     "ELSE 3 END, ch.data_abertura ASC"; // Prioriza Abertos e os mais antigos primeiro

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idTecnico);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Chamado c = new Chamado();
                c.setIdChamado(rs.getInt("id_chamado"));
                c.setTitulo(rs.getString("titulo"));
                c.setStatus(models.StatusChamado.valueOf(rs.getString("status")));
                c.setDataAbertura(rs.getTimestamp("data_abertura").toLocalDateTime());

                models.CategoriaChamado cat = new models.CategoriaChamado();
                cat.setNome(rs.getString("nome_categoria"));
                c.setCategoria(cat);

                models.Usuario cliente = new models.Usuario();
                cliente.setNome(rs.getString("nome_cliente"));
                c.setCliente(cliente);

                String nomeTecnico = rs.getString("nome_tecnico");
                if (nomeTecnico != null) {
                    models.Usuario tec = new models.Usuario();
                    tec.setNome(nomeTecnico);
                    c.setTecnico(tec);
                }

                lista.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return lista;
    }
    
    /**
     * Atualiza o status de um chamado (Ação do Admin/Suporte)
     */
    public boolean atualizarStatus(int idChamado, models.StatusChamado novoStatus) {
        PreparedStatement stmt = null;
        String sql = "UPDATE tb_chamado SET status = ?, data_atualizacao = ? WHERE id_chamado = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, novoStatus.name());
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            stmt.setInt(3, idChamado);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    

    /**
     * Altera a categoria de um chamado caso tenha sido classificado errado (Ação do Admin/Suporte)
     */
    public boolean atualizarCategoria(int idChamado, int idNovaCategoria) {
        PreparedStatement stmt = null;
        String sql = "UPDATE tb_chamado SET id_categoria = ?, data_atualizacao = ? WHERE id_chamado = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idNovaCategoria);
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            stmt.setInt(3, idChamado);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    
    /**
     * Atribui um técnico responsável a um chamado específico
     */
    public boolean atribuirTecnico(int idChamado, int idTecnico) {
        PreparedStatement stmt = null;
        String sql = "UPDATE tb_chamado SET id_tecnico = ?, data_atualizacao = ? WHERE id_chamado = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idTecnico);
            
            // Registra o exato momento em que o técnico assumiu o problema
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            stmt.setInt(3, idChamado);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            // Fechamento seguro para evitar o temido erro de "ResultSet closed" ou vazamento de conexões
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * Encerra o chamado registrando a solução técnica (Ação do Suporte)
     */
    public boolean resolverChamado(int idChamado, String observacoesTecnico) {
        PreparedStatement stmt = null;
        String sql = "UPDATE tb_chamado SET status = 'RESOLVIDO', observacoes_tecnico = ?, data_atualizacao = ? WHERE id_chamado = ?";
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, observacoesTecnico);
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            stmt.setInt(3, idChamado);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * Retorna as estatísticas gerais de chamados para o Dashboard
     * Retorna um array com: [0] Total, [1] Fila (Abertos+Andamento), [2] Resolvidos
     */
    public int[] obterEstatisticasChamados() {
        PreparedStatement stmt = null;
        ResultSet rs = null;
        int[] stats = new int[]{0, 0, 0}; // Padrão: tudo zero
        
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status IN ('ABERTO', 'EM_ANDAMENTO') THEN 1 ELSE 0 END) AS fila, " +
                     "SUM(CASE WHEN status IN ('RESOLVIDO', 'RESOLVED') THEN 1 ELSE 0 END) AS resolvidos " +
                     "FROM tb_chamado";
        
        try {
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                stats[0] = rs.getInt("total");
                stats[1] = rs.getInt("fila");
                stats[2] = rs.getInt("resolvidos");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        }
        return stats;
    }
}