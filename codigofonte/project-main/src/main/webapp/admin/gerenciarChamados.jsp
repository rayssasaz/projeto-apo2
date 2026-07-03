<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.Chamado" %>
<%@ page import="models.StatusChamado" %>
<%@ page import="models.CategoriaChamado" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Usuario adminLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (adminLogado == null || !models.NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Chamado> todosChamados = (List<Chamado>) request.getAttribute("listaChamados");
    
    @SuppressWarnings("unchecked")
    List<CategoriaChamado> categoriasDoSistema = (List<CategoriaChamado>) request.getAttribute("listaCategorias");
    
    DateTimeFormatter formatadorData = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Admin - Fila Global de Chamados</title>
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
                        <h1 class="h2"><i class="fa-solid fa-list-check text-danger me-2"></i>Fila Global de Chamados</h1>
                    </div>

                    <div id="alertGlobal" class="d-none alert alert-success alert-dismissible fade show small" role="alert">
                        <span id="alertGlobalMsg"></span>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="px-4" style="width: 8%">ID</th>
                                            <th style="width: 15%">Cliente</th>
                                            <th style="width: 20%">Assunto</th>
                                            <th style="width: 18%">Categoria (Reclassificar)</th>
                                            <th style="width: 12%">Data</th>
                                            <th style="width: 12%">Status</th>
                                            <th style="width: 15%">Atribuído a</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            if (todosChamados != null && !todosChamados.isEmpty()) { 
                                                for (Chamado c : todosChamados) {
                                        %>
                                            <tr>
                                                <td class="px-4 fw-bold text-muted">#<%= String.format("%04d", c.getIdChamado()) %></td>
                                                <td class="fw-semibold text-dark"><i class="fa-regular fa-user me-1 text-muted"></i><%= c.getCliente().getNome() %></td>
                                                <td class="text-truncate" style="max-width: 180px;" title="<%= c.getTitulo() %>"><%= c.getTitulo() %></td>
                                                
                                                <td>
                                                    <select class="form-select form-select-sm select-categoria-chamado" data-id="<%= c.getIdChamado() %>">
                                                        <% if (categoriasDoSistema != null) { 
                                                            for (CategoriaChamado cat : categoriasDoSistema) { %>
                                                                <option value="<%= cat.getIdCategoria() %>" <%= cat.getNome().equals(c.getCategoria().getNome()) ? "selected" : "" %>>
                                                                    <%= cat.getNome() %>
                                                                </option>
                                                        <% } } %>
                                                    </select>
                                                </td>
                                                
                                                <td class="text-muted small"><%= c.getDataAbertura().format(formatadorData) %></td>
                                                
                                                <td>
                                                    <select class="form-select form-select-sm select-status-chamado fw-semibold" data-id="<%= c.getIdChamado() %>">
                                                        <option value="ABERTO" class="text-warning" <%= c.getStatus() == StatusChamado.ABERTO ? "selected" : "" %>>ABERTO</option>
                                                        <option value="EM_ANDAMENTO" class="text-info" <%= c.getStatus() == StatusChamado.EM_ANDAMENTO ? "selected" : "" %>>EM ANDAMENTO</option>
                                                        <option value="RESOLVIDO" class="text-success" <%= c.getStatus() == StatusChamado.RESOLVIDO || c.getStatus() == StatusChamado.RESOLVIDO ? "selected" : "" %>>RESOLVIDO</option>
                                                        <option value="CANCELADO" class="text-danger" <%= c.getStatus() == StatusChamado.CANCELADO ? "selected" : "" %>>CANCELADO</option>
                                                    </select>
                                                </td>
                                                
                                                <td class="text-muted small">
                                                    <% if (c.getTecnico() != null) { %>
                                                        <i class="fa-solid fa-headset me-1 text-primary"></i><%= c.getTecnico().getNome() %>
                                                    <% } else { %>
                                                        <span class="text-warning"><i class="fa-solid fa-clock me-1"></i>Fila de Espera</span>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% 
                                                }
                                            } else { 
                                        %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted">Nenhum chamado localizado.</td></tr>
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
            
            // 1. AJAX para Alteração de Status
            $('.select-status-chamado').on('change', function() {
                var $select = $(this);
                var idChamado = $select.data('id');
                var novoStatus = $select.val();
                
                $select.addClass('is-valid');
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/admin/chamados",
                    type: "POST",
                    data: {
                        action: "atualizarStatus",
                        idChamado: idChamado,
                        status: novoStatus
                    },
                    dataType: "json",
                    success: function(res) {
                        $select.removeClass('is-valid');
                        $('#alertGlobalMsg').text(res.mensagem);
                        $('#alertGlobal').removeClass('d-none alert-danger').addClass('alert-success show');
                        setTimeout(function() { $('#alertGlobal').addClass('d-none'); }, 2500);
                    },
                    error: function(xhr) {
                        $select.removeClass('is-valid');
                        var err = xhr.responseJSON;
                        alert(err && err.mensagem ? err.mensagem : "Erro ao modificar status.");
                        window.location.reload();
                    }
                });
            });

            // 2. AJAX para Alteração de Categoria (Reclassificação)
            $('.select-categoria-chamado').on('change', function() {
                var $select = $(this);
                var idChamado = $select.data('id');
                var idNovaCat = $select.val();
                
                $select.addClass('is-valid');
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/admin/chamados",
                    type: "POST",
                    data: {
                        action: "atualizarCategory" == "atualizarCategoria" ? "atualizarCategoria" : "atualizarCategoria",
                        action: "atualizarCategoria",
                        idChamado: idChamado,
                        idCategoria: idNovaCat
                    },
                    dataType: "json",
                    success: function(res) {
                        $select.removeClass('is-valid');
                        $('#alertGlobalMsg').text(res.mensagem);
                        $('#alertGlobal').removeClass('d-none alert-danger').addClass('alert-success show');
                        setTimeout(function() { $('#alertGlobal').addClass('d-none'); }, 2500);
                    },
                    error: function(xhr) {
                        $select.removeClass('is-valid');
                        var err = xhr.responseJSON;
                        alert(err && err.mensagem ? err.mensagem : "Erro ao reclassificar chamado.");
                        window.location.reload();
                    }
                });
            });
        });
    </script>
</body>
</html>