<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String erroCadastro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>HelpDesk - Criar Conta</title>
    <%@ include file="components/header.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <%@ include file="components/navbar.jsp" %>

    <main class="container d-flex flex-grow-1 justify-content-center align-items-center" style="padding-top: 80px; padding-bottom: 40px;">
        <div class="card p-4 shadow-sm border-0" style="width: 100%; max-width: 450px;">
            
            <div class="text-center mb-4">
                <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width: 60px; height: 60px;">
                    <i class="fa-solid fa-user-plus fa-lg"></i>
                </div>
                <h3 class="fw-bold text-dark mb-1">Criar Nova Conta</h3>
                <p class="text-muted small">Cadastre-se para abrir chamados de suporte</p>
            </div>

            <% if (erroCadastro != null) { %>
                <div class="alert alert-danger alert-dismissible fade show small py-2" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><%= erroCadastro %>
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth" method="POST" id="formCadastro">
                <input type="hidden" name="action" value="cadastrar">

                <div class="mb-3">
                    <label for="nome" class="form-label small fw-bold">Nome Completo</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-user"></i></span>
                        <input type="text" id="nome" name="nome" class="form-control" placeholder="Ex: João da Silva" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label small fw-bold">E-mail</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-envelope"></i></span>
                        <input type="email" id="email" name="email" class="form-control" placeholder="joao@empresa.com" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="senha" class="form-label small fw-bold">Senha</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-key"></i></span>
                            <input type="password" id="senha" name="senha" class="form-control" placeholder="Mín. 6 caracteres" minlenght="6" required>
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="confirmarSenha" class="form-label small fw-bold">Confirmar Senha</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-circle-check"></i></span>
                            <input type="password" id="confirmarSenha" class="form-control" placeholder="Repita a senha" required>
                        </div>
                    </div>
                </div>

                <div id="senhaFeedback" class="text-danger small mb-3 d-none">
                    <i class="fa-solid fa-circle-xmark me-1"></i> As senhas informadas não coincidem.
                </div>

                <button type="submit" id="btnSubmit" class="btn btn-success w-100 fw-bold mt-2 py-2">
                    <i class="fa-solid fa-check me-2"></i>Finalizar Cadastro
                </button>
            </form>

            <div class="text-center mt-4 pt-3 border-top">
                <p class="text-muted small mb-0">Já possui uma conta? <a href="login.jsp" class="fw-bold text-decoration-none">Faça login</a></p>
            </div>

        </div>
    </main>

    <%@ include file="components/footer.jsp" %>

    <%@ include file="components/scripts.jsp" %>

    <script>
       /* $(document).ready(function() {
            $('#formCadastro').on('submit', function(e) {
                var senha = $('#senha').val();
                var confirma = $('#confirmarSenha').val();
                
                if (senha !== confirma) {
                    e.preventDefault(); // Impede o envio do formulário
                    $('#senhaFeedback').removeClass('d-none');
                    $('#confirmarSenha').addClass('is-invalid');
                } else {
                    $('#senhaFeedback').addClass('d-none');
                    $('#confirmarSenha').removeClass('is-invalid');
                }
            });
        }); */
        
        $(document).ready(function() {
            
            // 1. AJAX de validação de e-mail em tempo real
            $("#email").on("blur", function() {
                var emailDigitado = $(this).val();
                
                // Ignora a validação se o campo estiver limpo
                if(emailDigitado.trim() === "") return;
                
                $.ajax({
                    url: "${pageContext.request.contextPath}/auth",
                    type: "GET",
                    data: { 
                        action: "verificarEmail", 
                        email: emailDigitado 
                    },
                    dataType: "json",
                    success: function(data) {
                        if (data.disponivel) {
                            // E-mail livre: adiciona borda verde do Bootstrap
                            $("#email").removeClass("is-invalid").addClass("is-valid");
                            $("#btnSubmit").prop("disabled", false); // Ativa o botão de envio
                        } else {
                            // E-mail já cadastrado: adiciona borda vermelha
                            $("#email").removeClass("is-valid").addClass("is-invalid");
                            alert("Atenção: Este e-mail já está associado a uma conta ativa.");
                            $("#btnSubmit").prop("disabled", true); // Bloqueia o envio do form
                        }
                    },
                    error: function() {
                        console.error("Falha ao conectar com o endpoint de validação.");
                    }
                });
            });

            // 2. Validação client-side das senhas (Mantida do nosso escopo anterior)
            $('#formCadastro').on('submit', function(e) {
                var senha = $('#senha').val();
                var confirma = $('#confirmarSenha').val();
                
                if (senha !== confirma) {
                    e.preventDefault(); 
                    $('#senhaFeedback').removeClass('d-none');
                    $('#confirmarSenha').addClass('is-invalid');
                } else {
                    $('#senhaFeedback').addClass('d-none');
                    $('#confirmarSenha').removeClass('is-invalid');
                }
            });
        });
    </script>
    
</body>
</html>