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

import daos.ChamadoDAO;
import daos.CategoriaDAO;
import database.DBConnection;
import models.Chamado;
import models.CategoriaChamado;
import models.NivelAcesso;
import models.StatusChamado;
import models.Usuario;

@WebServlet("/admin/chamados")
public class GerenciarChamadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Carrega a listagem global de chamados e a lista de categorias para a triagem
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario adminLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        if (adminLogado == null || !NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);
            
            List<Chamado> todosChamados = chamadoDAO.listarTodos();
            List<CategoriaChamado> listaCategorias = categoriaDAO.listarCategorias();
            
            request.setAttribute("listaChamados", todosChamados);
            request.setAttribute("listaCategorias", listaCategorias); // Enviando para popular os selects na tabela
            
            request.getRequestDispatcher("/admin/gerenciarChamados.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }

    /**
     * Processa as atualizações de Status e Categoria via AJAX
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        Usuario adminLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (adminLogado == null || !NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Acesso negado.\"}");
            return;
        }

        DBConnection db = new DBConnection();
        try (Connection conn = db.getConnection()) {
            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            int idChamado = Integer.parseInt(request.getParameter("idChamado"));

            if ("atualizarStatus".equals(action)) {
                StatusChamado novoStatus = StatusChamado.valueOf(request.getParameter("status"));
                boolean sucesso = chamadoDAO.atualizarStatus(idChamado, novoStatus);
                
                if (sucesso) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Status do chamado atualizado!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro ao atualizar o status.\"}");
                }
            } 
            
            else if ("atualizarCategoria".equals(action)) {
                int idCategoria = Integer.parseInt(request.getParameter("idCategoria"));
                boolean sucesso = chamadoDAO.atualizarCategoria(idChamado, idCategoria);
                
                if (sucesso) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Chamado reclassificado com sucesso!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro ao alterar a categoria.\"}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro interno no servidor.\"}");
        }
    }
}