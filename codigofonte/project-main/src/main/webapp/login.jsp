<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Captura possíveis mensagens de erro enviadas pelo Servlet de Autenticação
    String mensagemErro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>HelpDesk - Fazer Login</title>
    <%@ include file="components/header.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <%@ include file="components/navbar.jsp" %>

    <main class="container d-flex flex-grow-1 justify-content-center align-items-center" style="padding-top: 80px; padding-bottom: 40px;">
        <div class="card p-4 shadow-sm border-0" style="width: 100%; max-width: 400px;">
            
            <div class="text-center mb-4">
                <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width: 60px; height: 60px;">
                    <i class="fa-solid fa-lock fa-lg"></i>
                </div>
                <h3 class="fw-bold text-dark mb-1">Acessar o Sistema</h3>
                <p class="text-muted small">Insira suas credenciais para continuar</p>
            </div>

            <% if (mensagemErro != null) { %>
                <div class="alert alert-danger alert-dismissible fade show small py-2" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><%= mensagemErro %>
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% if (request.getAttribute("sucesso") != null) { %>
			    <div style="color: green; background-color: #e6ffed; padding: 10px; margin-bottom: 15px; border-radius: 5px;">
			        <%= request.getAttribute("sucesso") %>
			    </div>
			<% } %>
			
			
            <form action="${pageContext.request.contextPath}/auth" method="POST">
                <input type="hidden" name="action" value="login">

                <div class="mb-3">
                    <label for="email" class="form-label small fw-bold">E-mail Corporativo</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-envelope"></i></span>
                        <input type="email" id="email" name="email" class="form-control" placeholder="nome@empresa.com" required>
                    </div>
                </div>

                <div class="mb-3">
                    <div class="d-flex justify-content-between">
                        <label for="senha" class="form-label small fw-bold">Senha</label>
                        <a href="recuperarSenha.jsp" class="small text-decoration-none">Esqueceu a senha?</a>
                    </div>
                    <div class="input-group">
                        <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-key"></i></span>
                        <input type="password" id="senha" name="senha" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 fw-bold mt-2 py-2">
                    <i class="fa-solid fa-right-to-bracket me-2"></i>Entrar
                </button>
            </form>

            <div class="text-center mt-4 pt-3 border-top">
                <p class="text-muted small mb-0">Não possui uma conta? <a href="cadastro.jsp" class="fw-bold text-decoration-none">Cadastre-se aqui</a></p>
            </div>

        </div>
    </main>

    <%@ include file="components/footer.jsp" %>

    <%@ include file="components/scripts.jsp" %>
</body>
</html>