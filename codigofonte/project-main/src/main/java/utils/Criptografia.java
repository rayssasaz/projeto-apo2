package utils;

import java.security.MessageDigest;

public class Criptografia {

    public static String converterParaSHA256(String senhaLimpa) {
        try {
            // Instancia o gerador de hash com o algoritmo SHA-256
            MessageDigest algorithm = MessageDigest.getInstance("SHA-256");
            
            // Calcula o hash em bytes
            byte[] messageDigest = algorithm.digest(senhaLimpa.getBytes("UTF-8"));
            
            // Converte os bytes para o formato Hexadecimal (String legível)
            StringBuilder hexString = new StringBuilder();
            for (byte b : messageDigest) {
                hexString.append(String.format("%02X", b));
            }
            
            return hexString.toString(); // Retorna o hash com 64 caracteres
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}