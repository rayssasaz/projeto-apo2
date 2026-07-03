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
import models.Usuario;

@WebServlet("/suporte/dashboard")
public class SuporteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario tecnicoLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        
        // Bloqueio rigoroso de acesso: Somente papel SUPORTE entra nesta rota
        if (tecnicoLogado == null || !NivelAcesso.SUPORTE.equals(tecnicoLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        Connection conn = null;

        try {
            conn = db.getConnection();
            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);
            
            // 1. Busca os chamados da fila restritos às especialidades do técnico
            List<Chamado> filaEspecializada = chamadoDAO.listarFilaDoTecnico(tecnicoLogado.getIdUsuario());
            
            // 2. Busca as especialidades do próprio técnico para renderizar as tags de identificação
            List<CategoriaChamado> minhasEspecialidades = categoriaDAO.listarPorTecnico(tecnicoLogado.getIdUsuario());
            
            // 3. Busca a lista integral de categorias para alimentar o `<select>` do Modal de Transferência
            List<CategoriaChamado> todasCategorias = categoriaDAO.listarCategorias();
            
            // Pendura os três pacotes de dados na requisição para a JSP
            request.setAttribute("listaChamados", filaEspecializada);
            request.setAttribute("minhasEspecialidades", minhasEspecialidades);
            request.setAttribute("todasCategorias", todasCategorias);
            
            // Envia o processamento para a View
            request.getRequestDispatcher("/suporte/dashboardSuporte.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao processar e carregar o painel do suporte.");
        } finally {
            // Liberação de recursos do MySQL
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}