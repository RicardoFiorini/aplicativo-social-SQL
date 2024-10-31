-- Criação do banco de dados
CREATE DATABASE AppMidiaSocial;
USE AppMidiaSocial;

-- Tabela para armazenar informações dos usuários
CREATE TABLE Usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    data_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    biografia TEXT,
    foto_perfil VARCHAR(255),
    UNIQUE KEY (email)
);

-- Tabela para armazenar postagens
CREATE TABLE Postagens (
    postagem_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_postagem DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- Tabela para armazenar seguidores
CREATE TABLE Seguidores (
    usuario_id INT NOT NULL,
    seguidor_id INT NOT NULL,
    data_seguindo DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, seguidor_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (seguidor_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- Índices para melhorar a performance
CREATE INDEX idx_usuario_email ON Usuarios(email);
CREATE INDEX idx_postagem_usuario ON Postagens(usuario_id);
CREATE INDEX idx_seguidores_usuario ON Seguidores(usuario_id);
CREATE INDEX idx_seguidores_seguidor ON Seguidores(seguidor_id);

-- View para listar postagens com detalhes do usuário
CREATE VIEW ViewPostagens AS
SELECT p.postagem_id, u.nome AS autor, p.conteudo, p.data_postagem
FROM Postagens p
JOIN Usuarios u ON p.usuario_id = u.usuario_id
ORDER BY p.data_postagem DESC;

-- Função para contar seguidores de um usuário
DELIMITER //
CREATE FUNCTION ContarSeguidores(usuarioId INT) RETURNS INT
BEGIN
    DECLARE qtd INT;
    SELECT COUNT(*) INTO qtd FROM Seguidores WHERE usuario_id = usuarioId;
    RETURN qtd;
END //
DELIMITER ;

-- Função para contar postagens de um usuário
DELIMITER //
CREATE FUNCTION ContarPostagens(usuarioId INT) RETURNS INT
BEGIN
    DECLARE qtd INT;
    SELECT COUNT(*) INTO qtd FROM Postagens WHERE usuario_id = usuarioId;
    RETURN qtd;
END //
DELIMITER ;

-- Trigger para garantir que um usuário não possa se seguir
DELIMITER //
CREATE TRIGGER Trigger_AntesSeguir
BEFORE INSERT ON Seguidores
FOR EACH ROW
BEGIN
    IF NEW.usuario_id = NEW.seguidor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Um usuário não pode se seguir.';
    END IF;
END //
DELIMITER ;

-- Inserção de exemplo de usuários
INSERT INTO Usuarios (nome, email, senha, biografia, foto_perfil) VALUES 
('João Silva', 'joao@example.com', 'senhaJoao', 'Amo tecnologia e esportes.', 'foto_joao.jpg'),
('Maria Costa', 'maria@example.com', 'senhaMaria', 'Viajante e fotógrafa.', 'foto_maria.jpg'),
('Pedro Almeida', 'pedro@example.com', 'senhaPedro', 'Entusiasta de culinária.', 'foto_pedro.jpg');

-- Inserção de exemplo de postagens
INSERT INTO Postagens (usuario_id, conteudo) VALUES 
(1, 'Olá, mundo! Este é meu primeiro post!'),
(2, 'Amo explorar novos lugares! #viagem'),
(1, 'Estou aprendendo SQL e estou adorando!');

-- Inserção de exemplo de seguidores
INSERT INTO Seguidores (usuario_id, seguidor_id) VALUES 
(1, 2), 
(2, 1), 
(1, 3);

-- Selecionar todas as postagens
SELECT * FROM ViewPostagens;

-- Contar seguidores de um usuário específico
SELECT ContarSeguidores(1) AS seguidores_usuario_1;

-- Contar postagens de um usuário específico
SELECT ContarPostagens(1) AS postagens_usuario_1;

-- Excluir uma postagem
DELETE FROM Postagens WHERE postagem_id = 1;

-- Excluir um usuário (isso falhará se o usuário tiver postagens ou seguidores)
DELETE FROM Usuarios WHERE usuario_id = 1;
