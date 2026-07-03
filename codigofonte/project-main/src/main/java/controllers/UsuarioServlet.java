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

import daos.UsuarioDAO;
import daos.CategoriaDAO;
import database.DBConnection;
import models.NivelAcesso;
import models.Usuario;
import models.CategoriaChamado;

@WebServlet("/admin/usuarios")
public class UsuarioServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario adminLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        if (adminLogado == null || !NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            UsuarioDAO usuarioDAO = new UsuarioDAO(conn);
            
            // --- ENDPOINT JSON: Busca as categorias atuais de um técnico via AJAX ---
            if ("obterCategoriasTecnico".equals(action)) {
                int idTecnico = Integer.parseInt(request.getParameter("idUsuario"));
                List<Integer> ids = usuarioDAO.listarIdsCategoriasPorTecnico(idTecnico);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Converte a lista [1, 2, 3] na string JSON "[1,2,3]"
                if (ids == null) {
                    response.getWriter().write("[]");
                } else {
                    response.getWriter().write(ids.toString());
                }
                return;
            }

            // --- FLUXO PADRÃO: Carrega a página de gerenciamento ---
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);
            
            List<Usuario> listaUsuarios = usuarioDAO.listarTodos();
            List<CategoriaChamado> listaCategorias = categoriaDAO.listarCategorias();
            
            request.setAttribute("listaUsuarios", listaUsuarios);
            request.setAttribute("listaCategorias", listaCategorias); // Envia todas as categorias para o Modal Checklist
            
            request.getRequestDispatcher("/admin/gerenciarUsuarios.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            UsuarioDAO usuarioDAO = new UsuarioDAO(conn);

            // --- FLUXO 1: Mudar papel de nível de acesso ---
            if ("alterarPapel".equals(action)) {
                int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
                NivelAcesso novoAcesso = NivelAcesso.valueOf(request.getParameter("novoPapel"));

                Usuario adminLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
                if (adminLogado != null && adminLogado.getIdUsuario() == idUsuario) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro: Não altere seu próprio papel.\"}");
                    return;
                }

                boolean sucesso = usuarioDAO.alterarPapel(idUsuario, novoAcesso);
                response.setContentType("application/json");
                if (sucesso) {
                	response.getWriter().write("{\"sucesso\": " + sucesso + ", \"mensagem\": \"Acesso modificado com sucesso!\"}");
                }else {
                	response.getWriter().write("{\"sucesso\": " + sucesso + ", \"mensagem\": \"Erro ao modificar acesso!\"}");
                }                
                return;
            }
            
            // --- ENDPOINT JSON/POST 2: Salvar especialidades do técnico ---
            else if ("salvarEspecialidades".equals(action)) {
                int idTecnico = Integer.parseInt(request.getParameter("idUsuario"));
                // Captura a lista de IDs de categorias marcados no form do modal
                String[] categoriasMarcadas = request.getParameterValues("categorias"); 

                boolean sucesso = usuarioDAO.salvarCategoriasTecnico(idTecnico, categoriasMarcadas);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                if (sucesso) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Especialidades sincronizadas!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Falha ao salvar no banco.\"}");
                }
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}