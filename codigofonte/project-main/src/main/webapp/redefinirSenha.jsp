<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Redefinir Senha - Help Desk</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Pequeno ajuste para garantir que o fundo fique com um tom suave */
        body {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body class="d-flex align-items-center py-4 bg-body-tertiary vh-100">

    <main class="form-signin w-100 m-auto" style="max-width: 400px;">
        <div class="card shadow-sm">
            <div class="card-body p-4">
                
                <h2 class="h4 mb-4 fw-normal text-center">Criar Nova Senha</h2>
                
                <% if (request.getAttribute("erro") != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= request.getAttribute("erro") %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/auth" method="POST">
                    <input type="hidden" name="action" value="salvarNovaSenha">
                    
                    <input type="hidden" name="token" value="<%= request.getParameter("token") %>">

                    <div class="mb-3">
                        <label for="novaSenha" class="form-label">Digite sua nova senha</label>
                        <input type="password" class="form-control" id="novaSenha" name="novaSenha" minlength="6" placeholder="Mínimo de 6 caracteres" required>
                    </div>
                    
                    <button class="btn btn-primary w-100 py-2 mt-2" type="submit">Atualizar Senha</button>
                </form>

            </div>
        </div>
        
        <p class="mt-4 mb-3 text-body-secondary text-center">© Help Desk Management System</p>
    </main>