package utils;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class GerenciadorTokens {
    
    // Armazena Token -> E-mail
    private static final Map<String, String> tokensValidacao = new ConcurrentHashMap<>();
    private static final Map<String, String> tokensRecuperacao = new ConcurrentHashMap<>();

    // --- Métodos para Validação de Cadastro ---
    public static void adicionarTokenValidacao(String token, String email) {
        tokensValidacao.put(token, email);
    }

    public static String obterEmailPorTokenValidacao(String token) {
        return tokensValidacao.get(token);
    }

    public static void removerTokenValidacao(String token) {
        tokensValidacao.remove(token);
    }

    // --- Métodos para Recuperação de Senha ---
    public static void adicionarTokenRecuperacao(String token, String email) {
        tokensRecuperacao.put(token, email);
    }

    public static String obterEmailPorTokenRecuperacao(String token) {
        return tokensRecuperacao.get(token);
    }

    public static void removerTokenRecuperacao(String token) {
        tokensRecuperacao.remove(token);
    }
}