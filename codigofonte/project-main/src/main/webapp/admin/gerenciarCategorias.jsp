<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.CategoriaChamado" %>
<%@ page import="java.util.List" %>
<%
    // 1. Validação de Segurança Básica na View (Garante que só ADMIN entra)
    Usuario adminLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (adminLogado == null || !models.NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 2. Recupera mensagens de feedback enviadas pelo CategoriaServlet
    String sucesso = (String) request.getAttribute("sucesso");
    String erro = (String) request.getAttribute("erro");

    // 3. Recupera a lista de categorias que o Servlet buscou no banco
    List<CategoriaChamado> categorias = (List<CategoriaChamado>) request.getAttribute("listaCategorias");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Admin - Gerenciar Categorias</title>
    <%@ include file="../components/header.jsp" %>
</head>
<body class="bg-light">

    <%@ include file="../components/navbar.jsp" %>

    <div class="d-flex" style="padding-top: 56px;">
        
        <%@ include file="../components/sidebar.jsp" %>

        <div class="d-flex flex-column flex-grow-1 min-vh-100">
            <main class="p-4 flex-grow-1">
                <div class="container-fluid">
                    
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-4 border-bottom">
                        <h1 class="h2"><i class="fa-solid fa-sliders text-danger me-2"></i>Configurações do Sistema</h1>
                    </div>

                    <% if (sucesso != null) { %>
                        <div class="alert alert-success alert-dismissible fade show small" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i><%= sucesso %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    <% if (erro != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= erro %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>

                    <div class="row g-4">
                        
                        <div class="col-lg-4">
                            <div class="card shadow-sm border-0">
                                <div class="card-header bg-white py-3 border-0">
                                    <h5 class="card-title fw-bold text-dark mb-0">Nova Categoria</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/admin/categorias" method="POST">
                                        <input type="hidden" name="action" value="cadastrar">
                                        
                                        <div class="mb-3">
                                            <label for="nomeCategoria" class="form-label small fw-bold">Nome da Categoria</label>
                                            <input type="text" id="nomeCategoria" name="nome" class="form-control" placeholder="Ex: Redes, Hardware..." required>
                                            <div class="form-text small">Evite nomes muito longos ou duplicados.</div>
                                        </div>
                                         <div class="mb-3">
                                            <label for="descricao" class="form-label small fw-bold">Descrição</label>
                                            <input type="text" id="descricao" name="descricao" class="form-control" placeholder="Ex: Teclado, monitor..." required>
                                            <div class="form-text small">Descreva brevemente com exemplos.</div>
                                        </div>
                                        <button type="submit" class="btn btn-danger w-100 fw-bold">
                                            <i class="fa-solid fa-plus me-2"></i>Adicionar Categoria
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-8">
                            <div class="card shadow-sm border-0">
                                <div class="card-header bg-white py-3 border-0 d-flex justify-content-between align-items-center">
                                    <h5 class="card-title fw-bold text-dark mb-0">Categorias Cadastradas</h5>
                                    <span class="badge bg-secondary">
                                        <%= (categorias != null) ? categorias.size() : 0 %> Ativas
                                    </span>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th class="px-4" style="width: 15%">ID</th>
                                                    <th style="width: 25%">Nome da Categoria</th>
                                                    <th style="width: 60%">Descrição</th>
                                                    <th class="text-center" style="width: 15%">Ações</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% 
                                                    if (categorias != null && !categorias.isEmpty()) { 
                                                        for (CategoriaChamado cat : categorias) {
                                                %>
                                                    <tr id="linha-categoria-<%= cat.getIdCategoria() %>">
                                                        <td class="px-4 text-muted fw-bold">#<%= cat.getIdCategoria() %></td>
                                                        <td class="fw-semibold text-dark"><%= cat.getNome() %></td>
                                                        <td class="fw-semibold text-dark"><%= cat.getDescricao() %></td>
                                                        <td class="text-center">
                                                            <form action="${pageContext.request.contextPath}/admin/categorias" method="POST" class="d-inline form-deletar">
															    <input type="hidden" name="action" value="deletar">
															    <input type="hidden" name="id" value="<%= cat.getIdCategoria() %>">
															    <button type="submit" class="btn btn-outline-danger btn-sm border-0" title="Excluir Categoria">
															        <i class="fa-solid fa-trash-can"></i>
															    </button>
															</form>
                                                        </td>
                                                    </tr>
                                                <% 
                                                        }
                                                    } else { 
                                                %>
                                                    <tr>
                                                        <td colspan="3" class="text-center py-4 text-muted">
                                                            <i class="fa-solid fa-folder-open fa-2x mb-2 d-block"></i>
                                                            Nenhuma categoria cadastrada ainda.
                                                        </td>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div> </div>
            </main>

            <%@ include file="../components/footer.jsp" %>
        </div>
    </div>

    <%@ include file="../components/scripts.jsp" %>

<script>
    $(document).ready(function() {
        
        // Intercepta o envio do formulário de deletar
        $('.form-deletar').on('submit', function(e) {
            e.preventDefault(); // Impede o formulário de recarregar a página tradicionalmente
            
            var $form = $(this);
            var idCategoria = $form.find('input[name="id"]').val();
            var urlAcao = $form.attr('action');
            
            if (confirm("Tem certeza que deseja excluir esta categoria?")) {
                
                // Dispara a requisição AJAX
                $.ajax({
                    url: urlAcao,
                    type: "POST",
                    data: {
                        action: "deletar",
                        id: idCategoria
                    },
                    dataType: "json",
                    success: function(resposta) {
                        // Se o banco deletou com sucesso, some com a linha da tabela de forma suave
                        $('#linha-categoria-' + idCategoria).fadeOut(400, function() {
                            $(this).remove(); // Remove o elemento do HTML após o efeito
                        });
                        
                        // Opcional: Atualiza o contador de categorias ativas no topo da tabela
                        var contadorAtual = parseInt($('.badge.bg-secondary').text());
                        $('.badge.bg-secondary').text((contadorAtual - 1) + " Ativas");
                    },
                    error: function(xhr) {
                        // Se falhar (ex: restrição de chave estrangeira), exibe o erro em um alert
                        var erroJson = xhr.responseJSON;
                        alert(erroJson && erroJson.mensagem ? erroJson.mensagem : "Erro ao excluir a categoria.");
                    }
                });
            }
        });
    });
</script>
</body>
</html>