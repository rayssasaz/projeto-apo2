package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import daos.CategoriaDAO;
import database.DBConnection;
import models.CategoriaChamado;
import models.Usuario;

@WebServlet("/admin/categorias")
public class CategoriaServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    public CategoriaServlet() {
        super();
    }

	/**
	 * MÉTOD0 GET: Intercepta o clique do menu lateral, busca as categorias no banco e joga na tabela
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. Controle de Acesso: Segurança para garantir que só administradores acessem o endpoint
        Usuario usuarioLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        if (usuarioLogado == null || !models.NivelAcesso.ADMIN.equals(usuarioLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);
            
            // Busca a lista atualizada do MySQL
            List<CategoriaChamado> lista = categoriaDAO.listarCategorias();
            
            // Pendura a lista na requisição para que a JSP consiga ler no laço 'for'
            request.setAttribute("listaCategorias", lista);
            
            // Redireciona os dados internamente para a página de gerenciamento
            request.getRequestDispatcher("/admin/gerenciarCategorias.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao carregar o painel de categorias.");
        } finally {
            // Fecha a conexão de forma segura após o término da requisição
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
	}

	/**
	 * MÉTODO POST: Trata os envios dos formulários da gerenciarCategorias.jsp (Salvar e Deletar)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//  FORÇA O SERVLET A LER TUDO COM ACENTUAÇÃO CORRETA
	    request.setCharacterEncoding("UTF-8");
		String action = request.getParameter("action");
        
        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);

            // ==========================================
            // SUB-FLUXO: CADASTRAR CATEGORIA
            // ==========================================
            if ("cadastrar".equals(action)) {
                String nome = request.getParameter("nome");
                String descricao = request.getParameter("descricao"); // Coleta o campo do textarea

                if (nome != null && !nome.trim().isEmpty()) {
                    CategoriaChamado novaCategoria = new CategoriaChamado();
                    novaCategoria.setNome(nome.trim());
                    // Se a descrição vier vazia, armazena nulo, senão limpa os espaços em branco
                    novaCategoria.setDescricao(descricao != null && !descricao.trim().isEmpty() ? descricao.trim() : null);

                    boolean sucesso = categoriaDAO.inserirCategoria(novaCategoria);
                    if (sucesso) {
                        request.setAttribute("sucesso", "Categoria '" + nome + "' adicionada com sucesso!");
                    } else {
                        request.setAttribute("erro", "Erro ao salvar. O nome informado já existe no sistema.");
                    }
                } else {
                    request.setAttribute("erro", "O campo 'Nome da Categoria' é obrigatório.");
                }
            }

         // ==========================================
            // SUB-FLUXO: DELETAR CATEGORIA (PREPARADO PARA AJAX)
            // ==========================================
            else if ("deletar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));

                boolean sucesso = categoriaDAO.deletarCategoria(id);
                
                // Verifica se a requisição veio via AJAX (comum checar pelo cabeçalho X-Requested-With)
                String requestedWith = request.getHeader("X-Requested-With");
                if ("XMLHttpRequest".equals(requestedWith)) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    
                    // Retorna um JSON simples de sucesso ou erro
                    if (sucesso) {
                        response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Categoria removida!\"}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro: categoria não existe ou está vinculada a um chamado.\"}");
                    }
                    return; // Interrompe aqui para não fazer o forward da página inteira!
                }
                
                // Fluxo tradicional (caso o JS falhe por algum motivo)
                if (sucesso) {
                    request.setAttribute("sucesso", "Categoria removida com sucesso.");
                } else {
                    request.setAttribute("erro", "Não foi possível excluir. Existem chamados vinculados.");
                }
            }

            // RECONSTRUÇÃO DA LISTA: Independente se cadastrou ou deletou, precisamos atualizar
            // os registros da tabela antes de devolver o controle para a página JSP
            List<CategoriaChamado> listaAtualizada = categoriaDAO.listarCategorias();
            request.setAttribute("listaCategorias", listaAtualizada);
            
            // Despacha de volta os dados atualizados junto com os alertas de sucesso ou erro
            request.getRequestDispatcher("/admin/gerenciarCategorias.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erro", "Ocorreu um erro interno de processamento no servidor.");
            request.getRequestDispatcher("/admin/gerenciarCategorias.jsp").forward(request, response);
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
	}

}