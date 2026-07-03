package models;

import java.time.LocalDateTime;

public class Chamado {
	private int idChamado;
    private String titulo;
    private String descricao;
    private StatusChamado status;
    
    private LocalDateTime dataAbertura;
    private LocalDateTime dataAtualizacao; // Removido o acento (cedilha/til)
    private String observacoesTecnico;     // NOVO: Para o técnico registrar o progresso
    
    private Usuario cliente;
    private Usuario tecnico;               // NOVO: Para saber quem assumiu o chamado
    private CategoriaChamado categoria;
	

	public Chamado() {
		
	}
	public Chamado(int idChamado, String titulo, String descricao, StatusChamado status, LocalDateTime dataAbertura,
			LocalDateTime dataAtualizacao, Usuario cliente, CategoriaChamado categoria) {
		
		this.idChamado = idChamado;
		this.titulo = titulo;
		this.descricao = descricao;
		this.status = status;
		this.dataAbertura = dataAbertura;
		this.dataAtualizacao = dataAtualizacao;
		this.cliente = cliente;
		this.categoria = categoria;
	}
	
	
	public Chamado(int idChamado, String titulo, String descricao, StatusChamado status, LocalDateTime dataAbertura,
			LocalDateTime dataAtualizacao, String observacoesTecnico, Usuario cliente, Usuario tecnico,
			CategoriaChamado categoria) {
		this.idChamado = idChamado;
		this.titulo = titulo;
		this.descricao = descricao;
		this.status = status;
		this.dataAbertura = dataAbertura;
		this.dataAtualizacao = dataAtualizacao;
		this.observacoesTecnico = observacoesTecnico;
		this.cliente = cliente;
		this.tecnico = tecnico;
		this.categoria = categoria;
	}
	
	
	// getters and setters
	public int getIdChamado() {
		return idChamado;
	}
	public void setIdChamado(int idChamado) {
		this.idChamado = idChamado;
	}
	public String getTitulo() {
		return titulo;
	}
	public void setTitulo(String titulo) {
		this.titulo = titulo;
	}
	public String getDescricao() {
		return descricao;
	}
	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}
	public StatusChamado getStatus() {
		return status;
	}
	public void setStatus(StatusChamado status) {
		this.status = status;
	}
	public LocalDateTime getDataAbertura() {
		return dataAbertura;
	}
	public void setDataAbertura(LocalDateTime dataAbertura) {
		this.dataAbertura = dataAbertura;
	}
	public LocalDateTime getDataAtualizacao() {
		return dataAtualizacao;
	}
	public void setDataAtualizacao(LocalDateTime dataAtualizacao) {
		this.dataAtualizacao = dataAtualizacao;
	}
	public Usuario getCliente() {
		return cliente;
	}
	public void setCliente(Usuario cliente) {
		this.cliente = cliente;
	}
	public CategoriaChamado getCategoria() {
		return categoria;
	}
	public void setCategoria(CategoriaChamado categoria) {
		this.categoria = categoria;
	}
	public String getObservacoesTecnico() {
		return observacoesTecnico;
	}
	public void setObservacoesTecnico(String observacoesTecnico) {
		this.observacoesTecnico = observacoesTecnico;
	}
	public Usuario getTecnico() {
		return tecnico;
	}
	public void setTecnico(Usuario tecnico) {
		this.tecnico = tecnico;
	}
	
}
