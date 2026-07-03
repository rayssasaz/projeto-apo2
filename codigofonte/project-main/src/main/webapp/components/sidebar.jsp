<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%@ page import="models.NivelAcesso" %>
<%
    Usuario userSidebar = (Usuario) session.getAttribute("usuarioAutenticado");
    String uriAtual = request.getRequestURI();
    
    // 1. CORREÇÃO: Se não tiver logado OU se estiver na index.jsp, a sidebar não renderiza nada!
    if (userSidebar == null || uriAtual.endsWith("index.jsp") || uriAtual.endsWith("/")) {
        return; 
    }
    
    String papel = "";
    if (userSidebar.getAcesso() != null) {
        papel = userSidebar.getAcesso().name(); 
    }
%>

<div class="bg-dark text-white p-3 flex-shrink-0 d-flex flex-column shadow" style="width: 240px; min-height: calc(100vh - 56px);">
    <div class="text-muted text-uppercase small fw-bold mb-3 px-2">Navegação</div>
    <ul class="nav nav-pills flex-column mb-auto">
        
        <% if ("CLIENTE".equals(papel)) { %>
            <li class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/cliente/dashboard" 
                   class="nav-link text-white <%= uriAtual.contains("dashboard.jsp") ? "active bg-primary" : "" %>">
                    <i class="fa-solid fa-chart-pie me-2"></i>Meu Painel
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/cliente/abrir-chamado" 
                   class="nav-link text-white <%= uriAtual.contains("abrirChamado.jsp") ? "active bg-primary" : "" %>">
                    <i class="fa-solid fa-plus-circle me-2"></i>Abrir Chamado
                </a>
            </li>
            <li class="nav-item mb-2">
			    <a href="${pageContext.request.contextPath}/perfil" 
			       class="nav-link text-white <%= uriAtual.contains("perfil") ? "active bg-primary" : "" %>">
			        <i class="fa-regular fa-id-badge me-2"></i>Meu Perfil
			    </a>
			</li>
        <% } %>

        <% if ("SUPORTE".equals(papel)) { %>
            <li class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/suporte/dashboard" 
                   class="nav-link text-dark <%= uriAtual.contains("dashboardSuporte.jsp") ? "active bg-warning" : "bg-warning text-dark fw-bold" %>">
                    <i class="fa-solid fa-list-check me-2"></i>Fila de Chamados
                </a>
            </li>
            <li class="nav-item mb-2">
			    <a href="${pageContext.request.contextPath}/perfil" 
			       class="nav-link text-white <%= uriAtual.contains("perfil") ? "active bg-primary" : "" %>">
			        <i class="fa-regular fa-id-badge me-2"></i>Meu Perfil
			    </a>
			</li>
        <% } %>

        <% if ("ADMIN".equals(papel)) { %>
            <li class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/admin/dashboard" 
                   class="nav-link text-white <%= uriAtual.contains("dashboard-global.jsp") ? "active bg-danger" : "" %>">
                    <i class="fa-solid fa-gauge me-2"></i>Painel Geral
                </a>
            </li>
            <li class="nav-item mb-2">
			    <a href="${pageContext.request.contextPath}/admin/usuarios" 
			       class="nav-link text-white <%= uriAtual.contains("usuarios") ? "active bg-danger" : "" %>">
			        <i class="fa-solid fa-users me-2"></i>Controle de Usuários
			    </a>
			</li>
            <li class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/admin/categorias" 
                   class="nav-link text-white <%= uriAtual.contains("categorias") || uriAtual.contains("configuracoes") ? "active bg-danger" : "" %>">
                    <i class="fa-solid fa-sliders me-2"></i>Categorias e Sistema
                </a>
            </li>
            <li class="nav-item mb-2">
			    <a href="${pageContext.request.contextPath}/perfil" 
			       class="nav-link text-white <%= uriAtual.contains("perfil") ? "active bg-primary" : "" %>">
			        <i class="fa-regular fa-id-badge me-2"></i>Meu Perfil
			    </a>
			</li>
			<li class="nav-item mb-2">
			    <a href="${pageContext.request.contextPath}/admin/chamados" 
			       class="nav-link text-white <%= uriAtual.contains("admin/chamados") ? "active bg-danger" : "" %>">
			        <i class="fa-solid fa-list-check me-2"></i>Fila de Chamados
			    </a>
			</li>
        <% } %>
        
    </ul>
    
    <% if (!"".equals(papel)) { 
        String corBadge = "bg-primary";
        if("ADMIN".equals(papel)) corBadge = "bg-danger";
        if("SUPORTE".equals(papel)) corBadge = "bg-warning text-dark";
    %>
        <div class="border-top border-secondary pt-3 px-2">
            <span class="badge <%= corBadge %> w-100 p-2">
                <%= papel %>
            </span>
        </div>
    <% } %>
</div>