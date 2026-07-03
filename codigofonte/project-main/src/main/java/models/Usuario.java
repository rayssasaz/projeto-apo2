package models;

public class Usuario {
	private int idUsuario;
	private String nome;
	private String email;
	private String senha;
	private boolean emailVerificado;
	
	private NivelAcesso acesso;

	
	public Usuario() {
		
	}
	

	public Usuario(int idusuario, String nome, String email, String senha, NivelAcesso acesso) {
		this.idUsuario = idusuario;
		this.nome = nome;
		this.email = email;
		this.senha = senha;
		this.acesso = acesso;
	}



	public int getIdUsuario() {
		return idUsuario;
	}

	public void setIdUsuario(int idusuario) {
		this.idUsuario = idusuario;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getSenha() {
		return senha;
	}

	public void setSenha(String senha) {
		this.senha = senha;
	}

	public NivelAcesso getAcesso() {
		return acesso;
	}

	public void setAcesso(NivelAcesso acesso) {
		this.acesso = acesso;
	}


	public boolean isEmailVerificado() {
		return emailVerificado;
	}


	public void setEmailVerificado(boolean emailVerificado) {
		this.emailVerificado = emailVerificado;
	}
	
	
	
	
	
}
