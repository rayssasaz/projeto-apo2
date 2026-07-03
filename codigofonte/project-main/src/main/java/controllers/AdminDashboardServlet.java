package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import daos.ChamadoDAO;
import daos.UsuarioDAO;
import database.DBConnection;
import models.NivelAcesso;
import models.Usuario;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Verificação rigorosa de Autenticação e Autorização
        Usuario adminLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        if (adminLogado == null || !NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            
            // 2. Instanciação das DAOs
            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            UsuarioDAO usuarioDAO = new UsuarioDAO(conn); 
            
            // 3. Coleta dos dados consolidados no banco
            int[] statsChamados = chamadoDAO.obterEstatisticasChamados();
            int totalUsuarios = usuarioDAO.contarTotalUsuarios();
            
            // 4. Empacotamento dos dados na requisição para leitura na JSP
            request.setAttribute("totalChamados", statsChamados[0]);
            request.setAttribute("chamadosFila", statsChamados[1]);
            request.setAttribute("chamadosResolvidos", statsChamados[2]);
            request.setAttribute("totalUsuarios", totalUsuarios);
            
            // 5. Despacho para a View correta
            request.getRequestDispatcher("/admin/dashboard-global.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao processar as métricas do painel administrativo.");
        } finally {
            // 6. Fechamento seguro da conexão para evitar vazamento de memória
            try { 
                if (conn != null) conn.close(); 
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}