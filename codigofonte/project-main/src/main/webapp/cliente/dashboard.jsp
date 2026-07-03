<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.Chamado" %>
<%@ page import="models.StatusChamado" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Usuario clienteLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (clienteLogado == null || !models.NivelAcesso.CLIENTE.equals(clienteLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Chamado> meusChamados = (List<Chamado>) request.getAttribute("listaChamados");
    DateTimeFormatter formatadorData = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Meu Painel - Help Desk</title>
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
                        <h1 class="h2"><i class="fa-solid fa-house-user text-primary me-2"></i>Meus Chamados</h1>
                        
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <a href="${pageContext.request.contextPath}/cliente/abrir-chamado" class="btn btn-primary fw-bold shadow-sm">
                                <i class="fa-solid fa-plus me-2"></i>Abrir Novo Chamado
                            </a>
                        </div>
                    </div>

                    <% if (request.getAttribute("sucesso") != null) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-check-circle me-2"></i><%= request.getAttribute("sucesso") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="px-4" style="width: 10%">Protocolo</th>
                                            <th style="width: 25%">Título / Assunto</th>
                                            <th style="width: 15%">Categoria</th>
                                            <th style="width: 15%">Data de Abertura</th>
                                            <th style="width: 15%">Status</th>
                                            <th style="width: 10%">Técnico Responsável</th>
                                            <th class="text-center" style="width: 10%">Ações</th> 
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            if (meusChamados != null && !meusChamados.isEmpty()) { 
                                                for (Chamado c : meusChamados) {
                                                    // Define a cor da badge com base no status do Enum
                                                    String badgeClass = "bg-secondary";
                                                    if (c.getStatus() == StatusChamado.ABERTO) badgeClass = "bg-warning text-dark";
                                                    else if (c.getStatus() == StatusChamado.EM_ANDAMENTO) badgeClass = "bg-info text-dark";
                                                    else if (c.getStatus() == StatusChamado.RESOLVIDO) badgeClass = "bg-success";
                                                    else if (c.getStatus() == StatusChamado.CANCELADO) badgeClass = "bg-danger";
                                        %>
                                            <tr id="linha-chamado-<%= c.getIdChamado() %>">
											    <td class="px-4 fw-bold text-muted">#<%= String.format("%04d", c.getIdChamado()) %></td>
											    <td class="fw-semibold text-dark"><%= c.getTitulo() %></td>
											    <td><span class="badge bg-light text-dark border"><%= c.getCategoria().getNome() %></span></td>
											    <td class="text-muted small"><%= c.getDataAbertura().format(formatadorData) %></td>
											    <td>
											        <span id="badge-status-<%= c.getIdChamado() %>" class="badge <%= badgeClass %>"><%= c.getStatus() %></span>
											    </td>
											    <td class="text-muted small">
											        <%= (c.getTecnico() != null) ? c.getTecnico().getNome() : "Aguardando" %>
											    </td>
											    <td class="text-center">
											        <% if (c.getStatus() == StatusChamado.ABERTO) { %>
											            <button class="btn btn-outline-danger btn-sm btn-cancelar border-0" 
											                    data-id="<%= c.getIdChamado() %>" 
											                    title="Cancelar Chamado">
											                <p>Cancelar</p>
											            </button>
											        <% } else if (c.getStatus() == StatusChamado.RESOLVIDO) { %>
											            <button class="btn btn-outline-info btn-sm btn-ver-solucao border-0" 
											                    data-bs-toggle="modal" data-bs-target="#modalSolucao"
											                    data-id="<%= String.format("%04d", c.getIdChamado()) %>"
											                    data-tecnico="<%= (c.getTecnico() != null) ? c.getTecnico().getNome() : "Técnico de Suporte" %>"
											                    data-solucao="<%= (c.getObservacoesTecnico() != null) ? c.getObservacoesTecnico().replace("\"", "&quot;") : "Nenhum parecer técnico registrado." %>"
											                    title="Visualizar Solução">
											                <i class="fa-solid fa-eye text-info"></i>
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
                                                <td colspan="6" class="text-center py-5 text-muted">
                                                    <i class="fa-solid fa-inbox fa-3x mb-3 d-block text-black-50"></i>
                                                    Você ainda não abriu nenhum chamado no sistema.
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
            <%@ include file="../components/footer.jsp" %>
        </div>
    </div>
    <%@ include file="../components/scripts.jsp" %>
    <script>
	    $(document).ready(function() {
	        $('.btn-cancelar').on('click', function() {
	            var btn = $(this);
	            var idChamado = btn.data('id');
	            
	            if (confirm("Tem certeza que deseja cancelar o chamado #" + idChamado.toString().padStart(4, '0') + "? Esta ação não pode ser desfeita.")) {
	                
	                // Desabilita o botão para evitar cliques duplos
	                btn.prop('disabled', true).html('<i class="fa-solid fa-spinner fa-spin"></i>');
	                
	                $.ajax({
	                    url: "${pageContext.request.contextPath}/cliente/cancelar-chamado",
	                    type: "POST",
	                    data: { idChamado: idChamado },
	                    dataType: "json",
	                    success: function(resposta) {
	                        // Atualiza a badge de status na tela
	                        var badge = $('#badge-status-' + idChamado);
	                        badge.removeClass('bg-warning text-dark').addClass('bg-danger text-white').text('CANCELADO');
	                        
	                        // Remove o botão de cancelar da tela, deixando apenas o traço (—)
	                        btn.parent().html('<span class="text-muted small">—</span>');
	                    },
	                    error: function(xhr) {
	                        btn.prop('disabled', false).html('<i class="fa-solid fa-xmark"></i>');
	                        var erroJson = xhr.responseJSON;
	                        alert(erroJson && erroJson.mensagem ? erroJson.mensagem : "Erro ao cancelar o chamado.");
	                    }
	                });
	            }
	        });
	     // Captura o clique no botão de olho e joga os dados para dentro do Modal
	        $('.btn-ver-solucao').on('click', function() {
	            var idChamado = $(this).data('id');
	            var tecnico = $(this).data('tecnico');
	            var solucao = $(this).data('solucao');
	            
	            $('#viewIdChamado').text('#' + idChamado);
	            $('#viewTecnico').text(tecnico);
	            $('#viewSolucaoTxt').text(solucao);
	        });
	    });
	</script>
    
  <div class="modal fade" id="modalSolucao" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-info text-dark">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-info me-2"></i>Parecer Técnico do Chamado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
            </div>
            <div class="modal-body p-4">
                <p class="text-muted small mb-1">Protocolo: <strong id="viewIdChamado" class="text-dark"></strong></p>
                <p class="text-muted small mb-4">Responsável Técnico: <strong id="viewTecnico" class="text-dark"></strong></p>
                
                <div class="mb-2">
                    <label class="form-label fw-bold small text-dark">Resolução Aplicada:</label>
                    <div id="viewSolucaoTxt" class="p-3 bg-light rounded border text-secondary" style="white-space: pre-wrap;"></div>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary fw-bold" data-bs-dismiss="modal">Fechar Janela</button>
            </div>
        </div>
    </div>
</div>  
</body>
</html>