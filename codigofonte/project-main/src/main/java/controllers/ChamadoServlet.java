package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import daos.CategoriaDAO;
import daos.ChamadoDAO;
import database.DBConnection;
import models.CategoriaChamado;
import models.Chamado;
import models.NivelAcesso;
import models.StatusChamado;
import models.Usuario;

@WebServlet("/cliente/abrir-chamado")
public class ChamadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * MÉTOD0 GET: Prepara a tela de abertura carregando as categorias disponíveis
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario clienteLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        if (clienteLogado == null || !NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        DBConnection db = new DBConnection();
        try (Connection conn = db.getConnection()) {
            CategoriaDAO categoriaDAO = new CategoriaDAO(conn);
            List<CategoriaChamado> categorias = categoriaDAO.listarCategorias();
            
            request.setAttribute("listaCategorias", categorias);
            request.getRequestDispatcher("/cliente/abrirChamado.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * MÉTODO POST: Recebe os dados, monta o objeto e salva no banco de dados
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        Usuario clienteLogado = (Usuario) request.getSession().getAttribute("usuarioAutenticado");
        if (clienteLogado == null || !NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String titulo = request.getParameter("titulo");
        String descricao = request.getParameter("descricao");
        int idCategoria = Integer.parseInt(request.getParameter("categoria"));

        DBConnection db = new DBConnection();
        try (Connection conn = db.getConnection()) {
            // Monta a Categoria (Só precisamos do ID para o banco)
            CategoriaChamado categoria = new CategoriaChamado();
            categoria.setIdCategoria(idCategoria);

            // Monta o Chamado
            Chamado novoChamado = new Chamado();
            novoChamado.setTitulo(titulo);
            novoChamado.setDescricao(descricao);
            novoChamado.setStatus(StatusChamado.ABERTO); // Todo chamado nasce ABERTO
            
            LocalDateTime agora = LocalDateTime.now();
            novoChamado.setDataAbertura(agora);
            novoChamado.setDataAtualizacao(agora);
            
            novoChamado.setCliente(clienteLogado);
            novoChamado.setCategoria(categoria);

            ChamadoDAO chamadoDAO = new ChamadoDAO(conn);
            boolean sucesso = chamadoDAO.inserirChamado(novoChamado);

            if (sucesso) {
                // Devolve a mensagem de sucesso para a requisição e manda o fluxo para o Dashboard
                request.setAttribute("sucesso", "Seu chamado foi registrado e já está na fila de atendimento!");
             
                // request.getRequestDispatcher("/cliente/dashboard").forward(request, response);

                //(Redirecionamento HTTP 302):
                response.sendRedirect(request.getContextPath() + "/cliente/dashboard");
            } else {
                request.setAttribute("erro", "Ocorreu um erro ao registrar o chamado. Tente novamente.");
                doGet(request, response); // Recarrega a tela de formulário
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}