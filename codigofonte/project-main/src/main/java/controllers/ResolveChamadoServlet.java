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

@WebServlet("/suporte/resolver")
public class ResolveChamadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Usuario tecnicoLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Bloqueio de segurança
        if (tecnicoLogado == null || !NivelAcesso.SUPORTE.equals(tecnicoLogado.getAcesso())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Acesso negado.\"}");
            return;
        }

        try {
            int idChamado = Integer.parseInt(request.getParameter("idChamado"));
            String observacoes = request.getParameter("observacoes");

            DBConnection db = new DBConnection();
            try (Connection conn = db.getConnection()) {
                ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
                
                boolean sucesso = chamadoDAO.resolverChamado(idChamado, observacoes);

                if (sucesso) {
                    response.getWriter().write("{\"sucesso\": true, \"mensagem\": \"Chamado encerrado com sucesso!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro ao gravar a resolução do chamado no banco de dados.\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"sucesso\": false, \"mensagem\": \"Erro interno no servidor.\"}");
        }
    }
}