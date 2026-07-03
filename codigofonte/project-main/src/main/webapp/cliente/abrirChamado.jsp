<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.CategoriaChamado" %>
<%@ page import="java.util.List" %>
<%
    Usuario clienteLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (clienteLogado == null || !models.NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<CategoriaChamado> categorias = (List<CategoriaChamado>) request.getAttribute("listaCategorias");
    String erro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Novo Chamado - Help Desk</title>
    <%@ include file="../components/header.jsp" %>
</head>
<body class="bg-light">

    <%@ include file="../components/navbar.jsp" %>

    <div class="d-flex" style="padding-top: 56px;">
        <%@ include file="../components/sidebar.jsp" %>

        <div class="d-flex flex-column flex-grow-1 min-vh-100">
            <main class="p-4 flex-grow-1">
                <div class="container" style="max-width: 800px;">
                    
                    <div class="d-flex justify-content-between align-items-center pb-2 mb-4 border-bottom">
                        <h1 class="h2"><i class="fa-solid fa-file-circle-plus text-primary me-2"></i>Abrir Novo Chamado</h1>
                        <a href="${pageContext.request.contextPath}/cliente/dashboard" class="btn btn-outline-secondary btn-sm fw-bold">
                            <i class="fa-solid fa-arrow-left me-1"></i>Voltar
                        </a>
                    </div>

                    <% if (erro != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= erro %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-4">
                            <p class="text-muted mb-4">Descreva o seu problema detalhadamente para que nossa equipe técnica possa ajudar da melhor forma possível.</p>
                            
                            <form action="${pageContext.request.contextPath}/cliente/abrir-chamado" method="POST">
                                
                                <div class="mb-3">
                                    <label for="titulo" class="form-label fw-bold small">Título / Assunto Principal</label>
                                    <input type="text" id="titulo" name="titulo" class="form-control" placeholder="Ex: Computador não liga, Sistema lento, Erro de impressão..." required maxlength="100">
                                </div>

                                <div class="mb-4">
                                    <label for="categoria" class="form-label fw-bold small">Categoria do Problema</label>
                                    <select id="categoria" name="categoria" class="form-select" required>
                                        <option value="" disabled selected>Selecione a área relacionada ao problema...</option>
                                        <% 
                                            if (categorias != null && !categorias.isEmpty()) {
                                                for (CategoriaChamado cat : categorias) {
                                        %>
                                            <option value="<%= cat.getIdCategoria() %>">
                                                <%= cat.getNome() %> <%= (cat.getDescricao() != null) ? " - " + cat.getDescricao() : "" %>
                                            </option>
                                        <% 
                                                }
                                            }
                                        %>
                                    </select>
                                </div>

                                <div class="mb-4">
                                    <label for="descricao" class="form-label fw-bold small">Descrição Detalhada</label>
                                    <textarea id="descricao" name="descricao" class="form-control" rows="6" placeholder="Por favor, informe os passos que levaram ao problema, mensagens de erro que apareceram na tela, e qualquer outro detalhe relevante." required></textarea>
                                </div>

                                <div class="d-flex justify-content-end border-top pt-3">
                                    <button type="submit" class="btn btn-primary fw-bold px-4">
                                        <i class="fa-solid fa-paper-plane me-2"></i>Enviar Solicitação
                                    </button>
                                </div>

                            </form>
                        </div>
                    </div>

                </div>
            </main>
            <%@ include file="../components/footer.jsp" %>
        </div>
    </div>
    <%@ include file="../components/scripts.jsp" %>
</body>
</html>