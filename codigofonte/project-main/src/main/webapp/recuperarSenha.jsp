<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Captura mensagens de sucesso ou erro vindas do Servlet
    String mensagemSucesso = (String) request.getAttribute("sucesso");
    String mensagemErro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>HelpDesk - Recuperar Senha</title>
    <%@ include file="components/header.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <%@ include file="components/navbar.jsp" %>

    <main class="container d-flex flex-grow-1 justify-content-center align-items-center" style="padding-top: 80px; padding-bottom: 40px;">
        <div class="card p-4 shadow-sm border-0" style="width: 100%; max-width: 400px;">
            
            <div class="text-center mb-4">
                <div class="bg-warning text-dark rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width: 60px; height: 60px;">
                    <i class="fa-solid fa-key fa-lg"></i>
                </div>
                <h3 class="fw-bold text-dark mb-1">Recuperar Senha</h3>
                <p class="text-muted small">Insira seu e-mail cadastrado para receber as instruções de recuperação.</p>
            </div>

            <% if (mensagemSucesso != null) { %>
                <div class="alert alert-success small py-2" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><%= mensagemSucesso %>
                </div>
            <% } %>

            <% if (mensagemErro != null) { %>
                <div class="alert alert-danger alert-dismissible fade show small py-2" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><%= mensagemErro %>
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth" method="POST">
                <input type="hidden" name="action" value="recuperar">

                <div class="mb-3">
                    <label for="email" class="form-label small fw-bold">E-mail Cadastrado</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-envelope"></i></span>
                        <input type="email" id="email" name="email" class="form-control" placeholder="seu-email@empresa.com" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 fw-bold mt-2 py-2">
                    <i class="fa-solid fa-paper-plane me-2"></i>Enviar Link
                </button>
            </form>

            <div class="text-center mt-4 pt-3 border-top">
                <p class="small mb-0"><a href="login.jsp" class="fw-bold text-decoration-none"><i class="fa-solid fa-arrow-left me-1"></i> Voltar para o Login</a></p>
            </div>

        </div>
    </main>

    <%@ include file="components/footer.jsp" %>

    <%@ include file="components/scripts.jsp" %>
</body>
</html>