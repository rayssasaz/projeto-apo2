  UPDATE `bdapo2`.`tb_usuario` SET `papel` = 'CLIENTE' WHERE (`id_usuario` = '1'); -- define administradores do sistema
delete from tb_categoria;
alter table tb_categoria auto_increment = 1;

SELECT * FROM tb_chamado WHERE id_categoria IN (8, 9);

alter table tb_chamado auto_increment = 1;
alter table tb_categoria auto_increment = 1;
delete from tb_usuario where id_usuario = 2;


ALTER TABLE tb_usuario ADD COLUMN email_verificado BOOLEAN DEFAULT FALSE;

UPDATE tb_usuario SET email_verificado = TRUE; -- todos criados anteriormente sem a verificação se manterão ativos

-- TODA A CARGA INICIAL (INSERTS E UPDATES) FORAM FEITAS ATRAVÉS DO FRONTEND DO PROJETO.