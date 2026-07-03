============================================================
PROJETO: SISTEMA DE HELP DESK (APO2)
============================================================

1. NOME DO PROJETO:
   Sistema de Help Desk para Gestão de Chamados Técnicos

2. INTEGRANTES:
   - [Rayssa Soares Oliveira Azevedo]
   - [Dandara]

3. DATAS IMPORTANTES:
   - Início do Desenvolvimento: 04/05/2026
   - Data de Entrega Final: 02/07/2026

4. USUÁRIOS E SENHAS INICIAIS PARA TESTES:
   Para fins de avaliação, o script de banco de dados 'database/schema.sql' 
   já insere os seguintes usuários padrão:

   - Administrador (mudança de papel no banco): 
     Email: rayssaazevedo31@gmail.com
     Senha: rayssa123
 
   - Suporte Técnico: 
     Email: rayssasazev@gmail.com
     Senha: rayssa123
     Email: paulodetarso@gmail.com
     Senha: paulo123
 
   - Cliente: 
     Email: sabrinaspellmanki@gmail.com
     Senha: sabrina123
	

5. DEPENDÊNCIAS DO SISTEMA:
   - Java Development Kit (JDK) 17+
   - Apache Tomcat 9.0+
   - MySQL Server 8.0+
   - Bibliotecas Adicionais (presentes na pasta /WEB-INF/lib):
     - JDBC Driver (mysql-connector-j)
     - Biblioteca JSON (ex: org.json)
     - [activation, gson-2.8.6, gson-2.8.6-javadoc, mail, mysql-connector-java-5.1.34-bin
	mysql-connector-java-8.0.17]

6. INSTRUÇÕES PARA EXECUÇÃO:
   a) Banco de Dados:
      - Crie um schema no MySQL com o nome de sua preferência.
      - Importe o arquivo 'codigofonte/database/ScriptDDL.sql' e 'codigofonte/database/ScriptDML.sql' 
	via MySQL Workbench.
      - Certifique-se de atualizar as credenciais do banco no arquivo 
        'codigofonte/project-main/src/database/DBConnection.java'.

   b) Configuração da API:
      - O sistema utiliza o serviço Mailtrap. As chaves de acesso estão 
        definidas na classe 'services.MailtrapRestService.java'.
      - Substitua os valores das constantes pelas suas próprias credenciais, 
        caso deseje testar o disparo real de e-mails.

   c) Execução:
      - Importe a pasta 'codigofonte/project-main' como um projeto "Dynamic Web" no Eclipse.
      - Configure um servidor Apache Tomcat e adicione o projeto ao servidor.
      - Inicie o Tomcat e acesse: http://localhost:8080/nome-do-seu-projeto/