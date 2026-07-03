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
import database.DBConnection;
import models.NivelAcesso;
import models.Usuario;

@WebServlet("/cliente/cancelar-chamado")
public class CancelarChamadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario clienteLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        // Configura a resposta para JSON imediatamente
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (clienteLogado == null || !NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Sessão expirada ou acesso negado.\"}");
            return;
        }

        try {
            int idChamado = Integer.parseInt(request.getParameter("idChamado"));

            DBConnection db = new DBConnection();
            try (Connection conn = db.getConnection()) {
                ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
                
                boolean sucesso = chamadoDAO.cancelarChamado(idChamado, clienteLogado.getIdUsuario());

                if (sucesso) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Chamado cancelado com sucesso.\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Não foi possível cancelar. O chamado já está em atendimento ou não pertence a você.\"}");
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"ID do chamado inválido.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro interno do servidor.\"}");
        }
    }
}