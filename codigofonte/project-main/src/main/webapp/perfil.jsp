<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Usuario" %>
<%
    Usuario userLogado = (Usuario) session.getAttribute("usuarioAutenticado");
    if (userLogado == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Meu Perfil</title>
    <%@ include file="components/header.jsp" %>
</head>
<body class="bg-light">

    <%@ include file="components/navbar.jsp" %>

    <div class="d-flex" style="padding-top: 56px;">
        
        <%@ include file="components/sidebar.jsp" %>

        <div class="d-flex flex-column flex-grow-1 min-vh-100">
            <main class="p-4 flex-grow-1">
                <div class="container" style="max-width: 800px;">
                    
                    <div class="d-flex justify-content-between align-items-center pb-2 mb-4 border-bottom">
                        <h1 class="h2"><i class="fa-regular fa-id-badge text-primary me-2"></i>Minha Conta</h1>
                    </div>

                    <div id="alertPerfil" class="alert d-none alert-dismissible fade show" role="alert">
                        <span id="alertPerfilMsg"></span>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-4">
                            <form id="formPerfil">
                                <h5 class="fw-bold mb-4 text-dark">Informações Pessoais</h5>
                                
                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Nome Completo</label>
                                        <input type="text" name="nome" class="form-control" value="<%= usuarioLogado.getNome() %>" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">E-mail</label>
                                        <input type="email" name="email" class="form-control" value="<%= usuarioLogado.getEmail() %>" required>
                                    </div>
                                </div>

                                <h5 class="fw-bold mb-3 text-dark border-top pt-4">Segurança da Conta</h5>
                                <p class="text-muted small mb-3">Preencha os campos abaixo apenas se desejar alterar sua senha atual.</p>

                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Nova Senha</label>
                                        <input type="password" id="novaSenha" name="novaSenha" class="form-control" placeholder="Deixe em branco para manter a atual">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Confirmar Nova Senha</label>
                                        <input type="password" id="confirmaSenha" class="form-control" placeholder="Repita a nova senha">
                                        <div id="senhaFeedback" class="invalid-feedback">As senhas não coincidem.</div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-end border-top pt-3">
                                    <button type="submit" id="btnSalvar" class="btn btn-primary fw-bold px-5">
                                        <i class="fa-solid fa-floppy-disk me-2"></i>Salvar Alterações
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>
            </main>

            <%@ include file="components/footer.jsp" %>
        </div>
    </div>

    <%@ include file="components/scripts.jsp" %>

    <script>
        $(document).ready(function() {
        	// Validação de e-mail duplicado em tempo real no Perfil
            $("#emailPerfil").on("blur", function() {
                var emailDigitado = $(this).val();
                var emailOriginal = $(this).data('original'); // Recupera o e-mail atual do usuário
                
                // Se o campo estiver vazio ou for o próprio e-mail dele, limpa os alertas e permite salvar
                if (emailDigitado.trim() === "" || emailDigitado === emailOriginal) {
                    $("#emailPerfil").removeClass("is-invalid is-valid");
                    $("#btnSalvar").prop("disabled", false);
                    return;
                }
                
                // Reutiliza o endpoint de verificação que criamos no AuthServlet!
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
                            // E-mail livre no sistema
                            $("#emailPerfil").removeClass("is-invalid").addClass("is-valid");
                            $("#btnSalvar").prop("disabled", false);
                        } else {
                            // E-mail já pertence a outra pessoa
                            $("#emailPerfil").removeClass("is-valid").addClass("is-invalid");
                            alert("Atenção: Este e-mail já está associado a outra conta cadastrada.");
                            $("#btnSalvar").prop("disabled", true); // Bloqueia o botão de salvar
                        }
                    }
                });
            });
        	
            $('#formPerfil').on('submit', function(e) {
                e.preventDefault();
                
                var senha = $('#novaSenha').val();
                var confirma = $('#confirmaSenha').val();
                
                // Validação de senha no front-end
                if (senha !== confirma) {
                    $('#confirmaSenha').addClass('is-invalid');
                    return; // Bloqueia o envio
                } else {
                    $('#confirmaSenha').removeClass('is-invalid');
                }

                var $btn = $('#btnSalvar');
                $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-2"></span>Salvando...');

                $.ajax({
                    url: "${pageContext.request.contextPath}/perfil",
                    type: "POST",
                    data: $(this).serialize(),
                    dataType: "json",
                    success: function(res) {
                        $btn.prop('disabled', false).html('<i class="fa-solid fa-floppy-disk me-2"></i>Salvar Alterações');
                        
                        // Atualiza os nomes dinamicamente na tela (Navbar e saudação)
                        var novoNome = $('input[name="nome"]').val();
                        $('.navbar .nav-link:contains("<%= usuarioLogado.getNome() %>")').html('<i class="fa-regular fa-circle-user fa-lg me-2"></i>' + novoNome);
                        
                        $('#alertPerfilMsg').text(res.mensagem);
                        $('#alertPerfil').removeClass('d-none alert-danger').addClass('alert-success');
                        
                        // Limpa os campos de senha por segurança
                        $('#novaSenha, #confirmaSenha').val('');
                    },
                    error: function(xhr) {
                        $btn.prop('disabled', false).html('<i class="fa-solid fa-floppy-disk me-2"></i>Salvar Alterações');
                        var erroJson = xhr.responseJSON;
                        $('#alertPerfilMsg').text(erroJson && erroJson.mensagem ? erroJson.mensagem : "Erro ao atualizar dados.");
                        $('#alertPerfil').removeClass('d-none alert-success').addClass('alert-danger');
                    }
                });
            });
        });
    </script>
</body>
</html>