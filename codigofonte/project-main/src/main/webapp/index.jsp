<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%
    // Recupera o usuário logado para saber qual botão de ação exibir no meio da tela
    Usuario usuarioIndex = (Usuario) session.getAttribute("usuarioAutenticado");
    
    String papelIndex = "";
    if (usuarioIndex != null && usuarioIndex.getAcesso() != null) {
        papelIndex = usuarioIndex.getAcesso().name();
    }
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>HelpDesk Central - Soluções em TI</title>
    <%@ include file="components/header.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <%@ include file="components/navbar.jsp" %>
   

    <main style="padding-top: 56px;">
        
        <div class="bg-dark text-white text-center py-5 position-relative overflow-hidden">
            <div class="container py-5 my-3">
                <i class="fa-solid fa-headset fa-4x text-primary mb-4"></i>
                <h1 class="display-4 fw-bold">Suporte Técnico Inteligente e Descomplicado</h1>
                <p class="lead text-muted mb-4 mx-auto" style="max-width: 700px;">
                    Abra chamados, acompanhe atendimentos e resolva incidentes de Hardware, Redes e Software em um único lugar.
                </p>
                <div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
                    
                    <% if (usuarioIndex == null) { %>
                        <a href="login.jsp" class="btn btn-primary btn-lg px-4 me-sm-3 fw-bold">
                            <i class="fa-solid fa-right-to-bracket me-2"></i>Solicitar Suporte
                        </a>
                        <a href="cadastro.jsp" class="btn btn-outline-light btn-lg px-4">Criar Conta</a>
                        
                    <% } else if ("CLIENTE".equals(papelIndex)) { %>
                        <a href="cliente/dashboard" class="btn btn-primary btn-lg px-4 fw-bold">
                            <i class="fa-solid fa-gauge-high me-2"></i>Ir para Meu Painel
                        </a>
                        
                    <% } else if ("SUPORTE".equals(papelIndex)) { %>
                        <a href="suporte/dashboard" class="btn btn-warning btn-lg px-4 fw-bold text-dark">
                            <i class="fa-solid fa-list-check me-2"></i>Acessar Fila de Atendimento
                        </a>
                        
                    <% } else if ("ADMIN".equals(papelIndex)) { %>
                        <a href="admin/dashboard" class="btn btn-danger btn-lg px-4 fw-bold">
                            <i class="fa-solid fa-sliders me-2"></i>Painel do Administrador
                        </a>
                    <% } %>
                    
                </div>
            </div>
        </div>

        <div class="container py-5">
            <div class="row text-center g-4">
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm p-4">
                        <div class="card-body">
                            <div class="bg-primary text-white fs-2 rounded-3 mb-3 d-inline-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                                <i class="fa-solid fa-laptop-code"></i>
                            </div>
                            <h5 class="fw-bold text-dark">Triagem por Especialidade</h5>
                            <p class="text-muted small">Seu problema de redes vai direto para a equipe de redes. Sem intermediários, sem perda de tempo.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm p-4">
                        <div class="card-body">
                            <div class="bg-success text-white fs-2 rounded-3 mb-3 d-inline-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                                <i class="fa-solid fa-bolt"></i>
                            </div>
                            <h5 class="fw-bold text-dark">Resolução Ágil</h5>
                            <p class="text-muted small">Acompanhe as mudanças de status do seu chamado em tempo real com notificações claras sobre o andamento.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm p-4">
                        <div class="card-body">
                            <div class="bg-info text-white fs-2 rounded-3 mb-3 d-inline-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                                <i class="fa-solid fa-shield-halved"></i>
                            </div>
                            <h5 class="fw-bold text-dark">Painel Administrativo</h5>
                            <p class="text-muted small">Gestores possuem controle total sobre níveis de acesso, relatórios de produtividade e cargas de trabalho.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white py-5 border-top border-bottom">
            <div class="container">
                <div class="row text-center g-4">
                    <div class="col-6 col-md-4">
                        <h2 class="fw-bold text-primary">98%</h2>
                        <p class="text-muted mb-0">Satisfação</p>
                    </div>
                    <div class="col-6 col-md-4">
                        <h2 class="fw-bold text-primary">+1500</h2>
                        <p class="text-muted mb-0">Chamados Resolvidos</p>
                    </div>
                    <div class="col-6 col-md-4">
                        <h2 class="fw-bold text-primary">&lt;30min</h2>
                        <p class="text-muted mb-0">Tempo médio de resposta</p>
                    </div>
                    
                </div>
            </div>
        </div>

    </main>

    <%@ include file="components/footer.jsp" %>

    <%@ include file="components/scripts.jsp" %>
</body>
</html>