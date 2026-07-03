package services;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class MailtrapRestService {

    private static final String API_URL = "https://sandbox.api.mailtrap.io/api/send/4416328";
    private static final String API_TOKEN = "c687d61a4bb2751fa1b78d1d85752d49";
    private static final String SENDER_EMAIL = "no-reply@helpdesk.com";
    private static final String SENDER_NAME = "Sistema Help Desk";

    public static void enviarEmailValidacao(String nomeDestinatario, String emailDestinatario, String link) throws Exception {
        String jsonBody = """
            {
              "to": [{"email": "%s", "name": "%s"}],
              "from": {"email": "%s", "name": "%s"},
              "subject": "Confirme seu cadastro no Help Desk",
              "html": "<h3>Olá, %s!</h3><p>Seu cadastro foi realizado com sucesso.</p><p>Para ativar sua conta, clique no link abaixo:</p><a href='%s'>Ativar minha conta</a>"
            }
            """.formatted(emailDestinatario, nomeDestinatario, SENDER_EMAIL, SENDER_NAME, nomeDestinatario, link);

        dispararRequisicao(jsonBody);
    }

    public static void enviarEmailRecuperacao(String emailDestinatario, String link) throws Exception {
        String jsonBody = """
            {
              "to": [{"email": "%s"}],
              "from": {"email": "%s", "name": "%s"},
              "subject": "Recuperação de Senha",
              "html": "<h3>Recuperação de Senha</h3><p>Você solicitou a redefinição da sua senha.</p><p>Clique no link abaixo para cadastrar uma nova senha:</p><a href='%s'>Redefinir minha senha</a><p>Se você não solicitou isso, ignore este e-mail.</p>"
            }
            """.formatted(emailDestinatario, SENDER_EMAIL, SENDER_NAME, link);

        dispararRequisicao(jsonBody);
    }

    private static void dispararRequisicao(String jsonBody) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .header("Api-Token", API_TOKEN)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());	
        
        if (response.statusCode() != 200) {
            // AGORA VAMOS CAPTURAR O MOTIVO EXATO!
            String detalheErro = response.body();
            System.err.println("ERRO DO MAILTRAP: " + detalheErro);
            System.err.println("JSON ENVIADO: " + jsonBody); // Imprime o JSON para você inspecionar
            
            throw new RuntimeException("Erro na API do Mailtrap. Código: " + response.statusCode() + " - " + detalheErro);
        }
        
        if (response.statusCode() != 200) {
            throw new RuntimeException("Erro na API do Mailtrap. Código: " + response.statusCode());
        }
    }
}