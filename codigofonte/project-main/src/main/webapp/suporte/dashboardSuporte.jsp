<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.Chamado" %>
<%@ page import="models.StatusChamado" %>
<%@ page import="models.CategoriaChamado" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Usuario tecnicoLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (tecnicoLogado == null || !models.NivelAcesso.SUPORTE.equals(tecnicoLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Chamado> filaChamados = (List<Chamado>) request.getAttribute("listaChamados");

    // Recebe a lista de especialidades do técnico enviada pelo Servlet
    @SuppressWarnings("unchecked")
    List<CategoriaChamado> especialidades = (List<CategoriaChamado>) request.getAttribute("minhasEspecialidades");
    
 		// Recebe a lista de todas especialidades  enviada pelo Servlet
    @SuppressWarnings("unchecked")
    List<CategoriaChamado> todasCategorias = (List<CategoriaChamado>) request.getAttribute("todasCategorias");
  
    DateTimeFormatter formatadorData = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Painel do Técnico - Help Desk</title>
    <%@ include file="../components/header.jsp" %>
</head>
<body class="bg-light">

    <%@ include file="../components/navbar.jsp" %>

    <div class="d-flex" style="padding-top: 56px;">
        <%@ include file="../components/sidebar.jsp" %>

        <div class="d-flex flex-column flex-grow-1 min-vh-100">
            <main class="p-4 flex-grow-1">
                <div class="container-fluid">
                    
                    <div class="pb-2 mb-4 border-bottom">
                        <div class="d-flex justify-content-between align-items-center flex-wrap flex-md-nowrap">
                            <h1 class="h2"><i class="fa-solid fa-screwdriver-wrench text-info me-2"></i>Fila de Atendimento</h1>
                            <span class="badge bg-secondary p-2"><%= (filaChamados != null) ? filaChamados.size() : 0 %> Chamados na Área</span>
                        </div>
                        
                        <div class="mt-2 text-muted small">
                            <span class="fw-bold me-2"><i class="fa-solid fa-tags me-1 text-primary"></i>Suas Especialidades:</span>
                            <% 
                                if (especialidades != null && !especialidades.isEmpty()) {
                                    for (CategoriaChamado esp : especialidades) {
                            %>
                                <span class="badge bg-primary bg-gradient me-1 shadow-sm" title="<%= (esp.getDescricao() != null) ? esp.getDescricao() : "" %>">
                                    <%= esp.getNome() %>
                                </span>
                            <% 
                                    }
                                } else { 
                            %>
                                <span class="text-danger fw-bold"><i class="fa-solid fa-triangle-exclamation me-1"></i>Nenhuma especialidade vinculada. Procure o Administrador.</span>
                            <% } %>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="px-4" style="width: 8%">ID</th>
                                            <th style="width: 15%">Solicitante</th>
                                            <th style="width: 25%">Problema</th>
                                            <th style="width: 12%">Categoria</th>
                                            <th style="width: 15%">Abertura</th>
                                            <th style="width: 10%">Status</th>
                                            <th class="text-center" style="width: 15%">Ações</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            if (filaChamados != null && !filaChamados.isEmpty()) { 
                                                for (Chamado c : filaChamados) {
                                                    String badgeClass = "bg-secondary";
                                                    if (c.getStatus() == StatusChamado.ABERTO) badgeClass = "bg-warning text-dark";
                                                    else if (c.getStatus() == StatusChamado.EM_ANDAMENTO) badgeClass = "bg-info text-dark";
                                                    else if (c.getStatus() == StatusChamado.RESOLVIDO) badgeClass = "bg-success";
                                                    else if (c.getStatus() == StatusChamado.CANCELADO) badgeClass = "bg-danger";
                                        %>
                                            <tr class="<%= (c.getStatus() == StatusChamado.RESOLVIDO || c.getStatus() == StatusChamado.CANCELADO) ? "opacity-50" : "" %>">
                                                <td class="px-4 fw-bold text-muted">#<%= String.format("%04d", c.getIdChamado()) %></td>
                                                <td class="fw-semibold text-dark"><i class="fa-regular fa-user me-1 text-muted"></i><%= c.getCliente().getNome() %></td>
                                                <td class="text-truncate" style="max-width: 200px;" title="<%= c.getTitulo() %>"><%= c.getTitulo() %></td>
                                                <td>
												    <% if (c.getStatus() == StatusChamado.ABERTO || c.getStatus() == StatusChamado.EM_ANDAMENTO) { %>
												        <select class="form-select form-select-sm select-categoria-chamado" data-id="<%= c.getIdChamado() %>">
												            <% if (todasCategorias != null) { 
												                for (CategoriaChamado cat : todasCategorias) { %>
												                    <option value="<%= cat.getIdCategoria() %>" <%= cat.getNome().equals(c.getCategoria().getNome()) ? "selected" : "" %>>
												                        <%= cat.getNome() %>
												                    </option>
												            <% } } %>
												        </select>
												    <% } else { %>
												        <span class="badge bg-light text-dark border"><%= c.getCategoria().getNome() %></span>
												    <% } %>
												</td>
                                                <td class="text-muted small"><%= c.getDataAbertura().format(formatadorData) %></td>
                                                <td><span class="badge <%= badgeClass %>"><%= c.getStatus() %></span></td>
                                                
                                                <td class="text-center">
                                                    <% if (c.getStatus() == StatusChamado.ABERTO) { %>
                                                        <button class="btn btn-sm btn-primary fw-bold btn-assumir" data-id="<%= c.getIdChamado() %>">
														    <i class="fa-solid fa-hand-holding-hand me-1"></i>Assumir
														</button>
                                                    <% } else if (c.getStatus() == StatusChamado.EM_ANDAMENTO && c.getTecnico() != null && c.getTecnico().getNome().equals(tecnicoLogado.getNome())) { %>
                                                        <button class="btn btn-sm btn-success fw-bold btn-tratar" 
														        data-bs-toggle="modal" data-bs-target="#modalResolver"
														        data-id="<%= c.getIdChamado() %>" 
														        data-titulo="<%= c.getTitulo() %>">
														    <i class="fa-solid fa-check me-1"></i>Tratar
														</button>
                                                    <% } else { %>
                                                        <span class="text-muted small">—</span>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% 
                                                }
                                            } else { 
                                        %>
                                            <tr>
                                                <td colspan="7" class="text-center py-5 text-muted">
                                                    <i class="fa-solid fa-mug-hot fa-3x mb-3 d-block text-black-50"></i>
                                                    Fila vazia! Não há demandas abertas na sua área.
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                </div>
            </main>
            
            <div class="modal fade" id="modalResolver" tabindex="-1" aria-hidden="true">
			    <div class="modal-dialog">
			        <div class="modal-content border-0 shadow">
			            <div class="modal-header bg-success text-white">
			                <h5 class="modal-title fw-bold"><i class="fa-solid fa-check-double me-2"></i>Resolver Chamado</h5>
			                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Fechar"></button>
			            </div>
			            <form id="formResolver">
			                <div class="modal-body p-4">
			                    <input type="hidden" id="modalIdChamado" name="idChamado">
			                    
			                    <p class="mb-3 text-muted small">
			                        Você está encerrando o atendimento para o problema: <br>
			                        <strong id="modalTituloChamado" class="text-dark fs-6"></strong>
			                    </p>
			                    
			                    <div class="mb-3">
			                        <label for="observacoes" class="form-label fw-bold small">Observações da Resolução / Diagnóstico</label>
			                        <textarea id="observacoes" name="observacoes" class="form-control" rows="5" placeholder="Descreva a solução aplicada. Ex: 'Driver da impressora atualizado para a versão 3.0' ou 'Acesso liberado via painel de administração'." required></textarea>
			                    </div>
			                </div>
			                <div class="modal-footer bg-light">
			                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancelar</button>
			                    <button type="submit" class="btn btn-success fw-bold" id="btnSalvarResolucao">
			                        <i class="fa-solid fa-floppy-disk me-1"></i>Encerrar Chamado
			                    </button>
			                </div>
			            </form>
			        </div>
			    </div>
			</div>
            <%@ include file="../components/footer.jsp" %>
        </div>
    </div>
    <%@ include file="../components/scripts.jsp" %>
    <script>
        $(document).ready(function() {
            $('.btn-assumir').on('click', function() {
                var btn = $(this);
                var idChamado = btn.data('id');
                
                btn.prop('disabled', true).html('<i class="fa-solid fa-spinner fa-spin me-1"></i>Aguarde...');
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/suporte/assumir",
                    type: "POST",
                    data: { idChamado: idChamado },
                    dataType: "json",
                    success: function(resposta) {
                        // Recarrega a página para atualizar o status e exibir o botão "Tratar"
                        window.location.reload();
                    },
                    error: function(xhr) {
                        btn.prop('disabled', false).html('<i class="fa-solid fa-hand-holding-hand me-1"></i>Assumir');
                        var erroJson = xhr.responseJSON;
                        alert(erroJson && erroJson.mensagem ? erroJson.mensagem : "Erro ao assumir o chamado.");
                    }
                });
            });
         // 1. Preenche o modal com os dados do chamado clicado
            $('.btn-tratar').on('click', function() {
                var idChamado = $(this).data('id');
                var titulo = $(this).data('titulo');
                
                $('#modalIdChamado').val(idChamado);
                $('#modalTituloChamado').text(titulo);
                $('#observacoes').val(''); // Limpa o texto de chamados anteriores
            });

            // 2. Dispara a requisição de resolução
            $('#formResolver').on('submit', function(e) {
                e.preventDefault();
                var $btn = $('#btnSalvarResolucao');
                $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-2"></span>Salvando...');

                $.ajax({
                    url: "${pageContext.request.contextPath}/suporte/resolver",
                    type: "POST",
                    data: $(this).serialize(),
                    dataType: "json",
                    success: function(res) {
                        $('#modalResolver').modal('hide'); // Esconde o modal
                        window.location.reload(); // Recarrega para aplicar as opacidades nos resolvidos
                    },
                    error: function(xhr) {
                        $btn.prop('disabled', false).html('<i class="fa-solid fa-floppy-disk me-1"></i>Encerrar Chamado');
                        var err = xhr.responseJSON;
                        alert(err && err.mensagem ? err.mensagem : "Erro ao encerrar o chamado.");
                    }
                });
            });
            
         // AJAX para Redirecionamento de Categoria direto na tabela
            $('.select-categoria-chamado').on('change', function() {
                var $select = $(this);
                var idChamado = $select.data('id');
                var idNovaCat = $select.val();
                
                // Feedback visual de carregamento
                $select.addClass('is-valid');
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/suporte/redirecionar",
                    type: "POST",
                    data: {
                        idChamado: idChamado,
                        idCategoria: idNovaCat
                    },
                    dataType: "json",
                    success: function(res) {
                        // Como a categoria mudou, o chamado não pertence mais a esta especialidade.
                        // O reload atualiza a fila e faz o chamado "sumir" da tela do técnico atual.
                        window.location.reload();
                    },
                    error: function(xhr) {
                        $select.removeClass('is-valid');
                        var err = xhr.responseJSON;
                        alert(err && err.mensagem ? err.mensagem : "Erro ao redirecionar chamado.");
                        // Recarrega para voltar o select à categoria original em caso de erro
                        window.location.reload();
                    }
                });
            });
        });
        
    </script>
</body>
</html>