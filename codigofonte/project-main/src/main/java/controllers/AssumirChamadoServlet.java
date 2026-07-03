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
import models.StatusChamado;
import models.Usuario;

@WebServlet("/suporte/assumir")
public class AssumirChamadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario tecnicoLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (tecnicoLogado == null || !NivelAcesso.SUPORTE.equals(tecnicoLogado.getAcesso())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Acesso negado.\"}");
            return;
        }

        try {
            int idChamado = Integer.parseInt(request.getParameter("idChamado"));

            DBConnection db = new DBConnection();
            try (Connection conn = db.getConnection()) {
                ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
                
                // 1. Atribui o chamado ao técnico logado
                boolean tecnicoAtribuido = chamadoDAO.atribuirTecnico(idChamado, tecnicoLogado.getIdUsuario());
                
                // 2. Muda o status para EM_ANDAMENTO
                boolean statusAtualizado = chamadoDAO.atualizarStatus(idChamado, StatusChamado.EM_ANDAMENTO);

                if (tecnicoAtribuido && statusAtualizado) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Chamado assumido com sucesso!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Não foi possível assumir este chamado.\"}");
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"ID do chamado inválido.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro interno no servidor.\"}");
        }
    }
}