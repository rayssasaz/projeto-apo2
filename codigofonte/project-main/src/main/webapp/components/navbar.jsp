<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%
    // Recupera o usuário logado da sessão de forma nativa
    Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioAutenticado");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top shadow-sm" style="height: 56px;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-primary" href="${pageContext.request.contextPath}/index.jsp">
            <i class="fa-solid fa-headset me-2"></i>HelpDesk Central
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center">
                
                <% if (usuarioLogado != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-white" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                            <i class="fa-solid fa-user-circle fa-lg me-1"></i>
                            <%= usuarioLogado.getNome() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/perfil"><i class="fa-solid fa-id-card me-2 text-muted"></i>Meu Perfil</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-right-from-bracket me-2"></i>Sair</a></li>
                        </ul>
                    </li>
                <% } else { %>
                    <li class="nav-item"><a class="btn btn-outline-light btn-sm px-3 me-2" href="${pageContext.request.contextPath}/login.jsp">Login</a></li>
                    <li class="nav-item"><a class="btn btn-primary btn-sm px-3" href="${pageContext.request.contextPath}/cadastro.jsp">Cadastrar-se</a></li>
                <% } %>
                
            </ul>
        </div>
    </div>
</nav>