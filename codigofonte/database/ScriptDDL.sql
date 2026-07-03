create database BDAPO2;
use BDAPO2;
CREATE TABLE `bdapo2`.`tb_usuario` (
  `id_usuario` INT NULL AUTO_INCREMENT,
  `nome_usuario` VARCHAR(50) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `senha` VARCHAR(255) NOT NULL,
  `papel` ENUM('CLIENTE', 'SUPORTE', 'ADMIN') NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id_usuario`));
  
  SELECT * FROM tb_usuario;

  
  CREATE TABLE `bdapo2`.`tb_categoria` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nome_categoria` VARCHAR(50) NOT NULL,
  `descricao` VARCHAR(255) NULL,
  PRIMARY KEY (`id_categoria`));
  

CREATE TABLE tb_tecnico_categoria (
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    PRIMARY KEY (id_usuario, id_categoria),
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES tb_categoria(id_categoria) ON DELETE CASCADE
);

CREATE TABLE tb_chamado (
    id_chamado INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_tecnico INT NULL, -- Pode ser nulo, pois o chamado nasce sem técnico definido
    id_categoria INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    status ENUM('ABERTO', 'EM_ANDAMENTO', 'RESOLVIDO', 'CANCELADO') DEFAULT 'ABERTO',
    data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME NOT NULL,
    observacoes_tecnico TEXT NULL,
    
    -- Chaves Estrangeiras
    FOREIGN KEY (id_cliente) REFERENCES tb_usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_tecnico) REFERENCES tb_usuario(id_usuario) ON DELETE SET NULL,
    FOREIGN KEY (id_categoria) REFERENCES tb_categoria(id_categoria)
);


