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
import database.DBConnection;
import models.Chamado;
import models.NivelAcesso;
import models.Usuario;

@WebServlet("/cliente/dashboard")
public class ClienteDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario clienteLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        // Trava de segurança: Se não estiver logado ou não for CLIENTE, expulsa
        if (clienteLogado == null || !NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            
            // Busca apenas os chamados do cliente logado
            List<Chamado> meusChamados = chamadoDAO.listarPorCliente(clienteLogado.getIdUsuario());
            
            // Pendura na requisição e despacha para a JSP
            request.setAttribute("listaChamados", meusChamados);
            request.getRequestDispatcher("/cliente/dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao carregar o dashboard do cliente.");
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}