<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.NivelAcesso" %>
<%@ page import="models.CategoriaChamado" %>
<%@ page import="java.util.List" %>
<%
    Usuario adminLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (adminLogado == null || !NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("listaUsuarios");
    
    @SuppressWarnings("unchecked")
    List<CategoriaChamado> todasCategorias = (List<CategoriaChamado>) request.getAttribute("listaCategorias");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Admin - Controle de Usuários</title>
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
                        <h1 class="h2"><i class="fa-solid fa-users-gear text-danger me-2"></i>Controle de Usuários</h1>
                    </div>

                    <div id="liveAlert" class="d-none alert alert-success alert-dismissible fade show small" role="alert">
                        <span id="liveAlertMessage"></span>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="px-4" style="width: 10%">ID</th>
                                            <th style="width: 30%">Nome do Usuário</th>
                                            <th style="width: 30%">E-mail</th>
                                            <th style="width: 20%">Nível de Acesso (Papel)</th>
                                            <th class="text-center" style="width: 10%">Ações</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            if (usuarios != null && !usuarios.isEmpty()) { 
                                                for (Usuario u : usuarios) {
                                        %>
                                            <tr>
                                                <td class="px-4 text-muted fw-bold">#<%= u.getIdUsuario() %></td>
                                                <td class="fw-semibold text-dark"><%= u.getNome() %></td>
                                                <td class="text-muted"><%= u.getEmail() %></td>
                                                <td>
                                                    <select class="form-select form-select-sm select-papel" data-id="<%= u.getIdUsuario() %>" <%= (adminLogado.getIdUsuario() == u.getIdUsuario()) ? "disabled" : "" %>>
                                                        <option value="CLIENTE" <%= NivelAcesso.CLIENTE.equals(u.getAcesso()) ? "selected" : "" %>>Cliente</option>
                                                        <option value="SUPORTE" <%= NivelAcesso.SUPORTE.equals(u.getAcesso()) ? "selected" : "" %>>Suporte (Técnico)</option>
                                                        <option value="ADMIN" <%= NivelAcesso.ADMIN.equals(u.getAcesso()) ? "selected" : "" %>>Administrador</option>
                                                    </select>
                                                </td>
                                                <td class="text-center">
                                                    <% if (NivelAcesso.SUPORTE.equals(u.getAcesso())) { %>
                                                        <button type="button" class="btn btn-outline-primary btn-sm btn-especialidades" data-id="<%= u.getIdUsuario() %>" data-nome="<%= u.getNome() %>">
                                                            <i class="fa-solid fa-tags"></i> Especialidades
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
                                            <tr><td colspan="5" class="text-center py-4 text-muted">Nenhum usuário localizado.</td></tr>
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

    <div class="modal fade" id="modalEspecialidades" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <form id="formEspecialidades">
                    <input type="hidden" name="action" value="salvarEspecialidades">
                    <input type="hidden" name="idUsuario" id="modalIdUsuario">
                    
                    <div class="modal-header bg-dark text-white border-0">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-tags text-primary me-2"></i>Especialidades do Técnico</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-4">
                        <p class="small text-muted mb-3">Selecione as categorias de chamado que <strong id="modalNomeUsuario" class="text-dark"></strong> está apto(a) a atender:</p>
                        
                        <div class="row g-2">
                            <% 
                                if (todasCategorias != null && !todasCategorias.isEmpty()) {
                                    for (CategoriaChamado cat : todasCategorias) {
                            %>
                                <div class="col-10">
                                    <div class="form-check p-2 rounded border bg-light ps-4">
                                        <input class="form-check-input check-categoria" type="checkbox" name="categorias" value="<%= cat.getIdCategoria() %>" id="check-<%= cat.getIdCategoria() %>">
                                        <label class="form-check-label fw-semibold text-dark small" for="check-<%= cat.getIdCategoria() %>">
                                            <%= cat.getNome() %>
                                        </label>
                                        <% if (cat.getDescricao() != null) { %>
                                            <small class="d-block text-muted style-italic" style="font-size:0.75rem;"><%= cat.getDescricao() %></small>
                                        <% } %>
                                    </div>
                                </div>
                            <% 
                                    }
                                } else {
                            %>
                                <div class="text-center text-muted py-3 small">Nenhuma categoria cadastrada no sistema.</div>
                            <% } %>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-light fw-bold" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary fw-bold px-4">Salvar Alterações</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="../components/scripts.jsp" %>

    <script>
        $(document).ready(function() {
            
            // ==================================================
            // AJAX 1: ALTERAR PAPEL (MUDANÇA DO SELECT)
            // ==================================================
            $('.select-papel').on('change', function() {
                var $select = $(this);
                $.ajax({
                    url: "${pageContext.request.contextPath}/admin/usuarios",
                    type: "POST",
                    data: { action: "alterarPapel", idUsuario: $select.data('id'), novoPapel: $select.val() },
                    dataType: "json",
                    success: function(res) {
                        $('#liveAlertMessage').text(res.mensagem);
                        $('#liveAlert').removeClass('d-none alert-danger').addClass('alert-success show');
                        setTimeout(function() { window.location.reload(); }, 1500); // Recarrega para desenhar/sumir o botão especialidades
                    },
                    error: function() { alert("Erro ao mudar o nível de acesso."); window.location.reload(); }
                });
            });

            // ==================================================
            // AJAX 2: ABRIR MODAL E POPULAR CHECKBOXES (GET JSON)
            // ==================================================
            $('.btn-especialidades').on('click', function() {
                var idUser = $(this).data('id');
                var nomeUser = $(this).data('nome');
                
                $('#modalIdUsuario').val(idUser);
                $('#modalNomeUsuario').text(nomeUser);
                $('.check-categoria').prop('checked', false); // Limpa as marcações do modal anterior
                
                // Dispara requisição assíncrona para buscar as especialidades atuais do técnico
                $.ajax({
                    url: "${pageContext.request.contextPath}/admin/usuarios",
                    type: "GET",
                    data: { action: "obterCategoriasTecnico", idUsuario: idUser },
                    dataType: "json",
                    success: function(listaIds) {
                        // Varre o array recebido do Servlet [1, 4] e marca os checkboxes correspondentes
                        $.each(listaIds, function(index, idCat) {
                            $('#check-' + idCat).prop('checked', true);
                        });
                        // Abre o modal visualmente
                        $('#modalEspecialidades').modal('show');
                    }
                });
            });

            // ==================================================
            // AJAX 3: SALVAR MARCAÇÕES DO MODAL (POST JSON)
            // ==================================================
            $('#formEspecialidades').on('submit', function(e) {
                e.preventDefault();
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/admin/usuarios",
                    type: "POST",
                    data: $(this).serialize(), // Empacota automaticamente todos os checkboxes marcados
                    dataType: "json",
                    success: function(res) {
                        $('#modalEspecialidades').modal('hide');
                        $('#liveAlertMessage').text(res.mensagem);
                        $('#liveAlert').removeClass('d-none alert-danger').addClass('alert-success show');
                        setTimeout(function() { $('#liveAlert').addClass('d-none'); }, 3000);
                    },
                    error: function(xhr) {
                        alert("Ocorreu uma falha ao tentar salvar as especialidades.");
                    }
                });
            });
        });
    </script>
</body>
</html>