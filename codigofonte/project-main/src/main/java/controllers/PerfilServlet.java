package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import daos.UsuarioDAO;
import database.DBConnection;
import models.Usuario;
import utils.Criptografia;

@WebServlet("/perfil")
public class PerfilServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Redireciona para a tela de perfil
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioAutenticado") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        request.getRequestDispatcher("/perfil.jsp").forward(request, response);
    }

    // Processa a atualização dos dados via AJAX
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        Usuario usuarioLogado = (session != null) ? (Usuario) session.getAttribute("usuarioAutenticado") : null;
        
        if (usuarioLogado == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String novaSenha = request.getParameter("novaSenha");

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            UsuarioDAO usuarioDAO = new UsuarioDAO(conn);
            
         // 1. ANTES DE ATUALIZAR: Reutiliza o buscarPorEmail para checar duplicidade
            Usuario donoDoEmail = usuarioDAO.buscarPorEmail(email);
            
            // Se achou alguém com esse e-mail E o ID for diferente do meu ID logado, bloqueia!
            if (donoDoEmail != null && donoDoEmail.getIdUsuario() != usuarioLogado.getIdUsuario()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro: Este e-mail já está sendo utilizado por outra conta.\"}");
                return; // Encerra o processamento aqui
            }

            // Verifica se a senha foi preenchida
            boolean alterarSenha = (novaSenha != null && !novaSenha.trim().isEmpty());
            
            // Atualiza os dados no objeto (Memória)
            usuarioLogado.setNome(nome);
            usuarioLogado.setEmail(email);
            if (alterarSenha) {
                usuarioLogado.setSenha(Criptografia.converterParaSHA256(novaSenha));
            }

            
            // Persiste no banco de dados
            boolean sucesso = usuarioDAO.atualizarPerfil(usuarioLogado, alterarSenha);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            if (sucesso) {
                // Atualiza o objeto da sessão para a Navbar refletir o novo nome imediatamente
                session.setAttribute("usuarioAutenticado", usuarioLogado);
                response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Perfil atualizado com sucesso!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro: Este e-mail já está em uso por outra conta.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro interno do servidor.\"}");
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}