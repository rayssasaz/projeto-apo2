<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%
    // Validação de Segurança
    Usuario adminLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (adminLogado == null || !models.NivelAcesso.ADMIN.equals(adminLogado.getAcesso())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<%
    // Recupera os valores enviados pelo Servlet (com fallback para 0 caso algo falhe)
    Integer totalChamados = (Integer) request.getAttribute("totalChamados");
    Integer chamadosFila = (Integer) request.getAttribute("chamadosFila");
    Integer chamadosResolvidos = (Integer) request.getAttribute("chamadosResolvidos");
    Integer totalUsuarios = (Integer) request.getAttribute("totalUsuarios");
    
    // Tratamento anti-nulo de segurança
    int txtTotal = (totalChamados != null) ? totalChamados : 0;
    int txtFila = (chamadosFila != null) ? chamadosFila : 0;
    int txtResolvidos = (chamadosResolvidos != null) ? chamadosResolvidos : 0;
    int txtUsuarios = (totalUsuarios != null) ? totalUsuarios : 0;
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Admin - Painel Global</title>
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
                        <h1 class="h2"><i class="fa-solid fa-gauge text-danger me-2"></i>Visão Global do Sistema</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <span class="text-muted mt-2">Bem-vindo(a), <strong><%= adminLogado.getNome() %></strong></span>
                        </div>
                    </div>

                    <div class="row g-4 mb-5">
                        <div class="col-md-3">
                            <div class="card shadow-sm border-0 bg-primary text-white h-100">
                                <div class="card-body">
								    <h6 class="card-title">TOTAL DE CHAMADOS</h6>
								    <h2 class="display-5 fw-bold"><%= txtTotal %></h2>
								</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card shadow-sm border-0 bg-warning text-dark h-100">
                                <div class="card-body">
								    <h6 class="card-title">EM ABERTO / FILA</h6>
								    <h2 class="display-5 fw-bold"><%= txtFila %></h2>
								</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card shadow-sm border-0 bg-success text-white h-100">
                                <div class="card-body">
								    <h6 class="card-title">RESOLVIDOS</h6>
								    <h2 class="display-5 fw-bold"><%= txtResolvidos %></h2>
								</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card shadow-sm border-0 bg-danger text-white h-100">
                                <div class="card-body">
								    <h6 class="card-title">USUÁRIOS ATIVOS</h6>
								    <h2 class="display-5 fw-bold"><%= txtUsuarios %></h2>
								</div>
                            </div>
                        </div>
                    </div>

                    <h4 class="mb-4 text-dark fw-bold">Ações de Gerenciamento</h4>

                    <div class="row g-4">
                        
                        <div class="col-md-6 col-lg-4">
                            <div class="card shadow-sm border-0 h-100 text-center p-4 action-card">
                                <div class="card-body">
                                    <i class="fa-solid fa-users-gear fa-3x text-primary mb-3"></i>
                                    <h5 class="fw-bold">Controle de Usuários</h5>
                                    <p class="text-muted small mb-4">Promova clientes a técnicos de suporte ou rebaixe administradores.</p>
                                    <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn btn-outline-primary w-100">
									    Gerenciar Acessos
									</a>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6 col-lg-4">
                            <div class="card shadow-sm border-0 h-100 text-center p-4 action-card">
                                <div class="card-body">
                                    <i class="fa-solid fa-tags fa-3x text-danger mb-3"></i>
                                    <h5 class="fw-bold">Categorias de Chamados</h5>
                                    <p class="text-muted small mb-4">Adicione, edite ou remova as opções de triagem do sistema.</p>
                                    <a href="${pageContext.request.contextPath}/admin/categorias" class="btn btn-outline-danger w-100">
                                        Configurar Categorias
                                    </a>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6 col-lg-4">
                            <div class="card shadow-sm border-0 h-100 text-center p-4 action-card">
                                <div class="card-body">
                                    <i class="fa-solid fa-file-contract fa-3x text-success mb-3"></i>
                                    <h5 class="fw-bold">Relatórios do Sistema</h5>
                                    <p class="text-muted small mb-4">Exporte os dados de chamados e produtividade da equipe.</p>
                                    <button class="btn btn-outline-success w-100" disabled>
                                        Em Breve
                                    </button>
                                </div>
                            </div>
                        </div>

                    </div>

                </div>
            </main>

            <%@ include file="../components/footer.jsp" %>
        </div>
    </div>

    <%@ include file="../components/scripts.jsp" %>
    
    <style>
        .action-card { transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .action-card:hover { transform: translateY(-5px); box-shadow: 0 .5rem 1rem rgba(0,0,0,.15)!important; }
    </style>
</body>
</html>