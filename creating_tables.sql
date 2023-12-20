-- Criação da tabela Endereco
CREATE TABLE Endereco (
    cep VARCHAR2(9) PRIMARY KEY,
    estado VARCHAR2(50),
    cidade VARCHAR2(50),
    bairro VARCHAR2(50),
    rua VARCHAR2(100)
);

-- Criação da tabela Participante
CREATE TABLE Participante (
    cpf VARCHAR2(11) PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    numero VARCHAR2(15),
    cep VARCHAR2(9),
    CONSTRAINT fk_participante_cep FOREIGN KEY (cep) REFERENCES Endereco(cep),
    CONSTRAINT chk_cep CHECK (LENGTH(cep) = 9)
);

-- Criação da tabela Organizador com autorelacionamento Supervisiona
CREATE TABLE Organizador (
    cpf_participante VARCHAR2(11) PRIMARY KEY,
    cargo VARCHAR2(50),
    departamento VARCHAR2(50),
    cpf_supervisor VARCHAR2(11),
    CONSTRAINT fk_organizador_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf),
    CONSTRAINT fk_organizador_supervisor FOREIGN KEY (cpf_supervisor) REFERENCES Organizador(cpf_participante)
);

-- Criação da tabela Palestrante
CREATE TABLE Palestrante (
    cpf_participante VARCHAR2(11),
    empresa_vinculo VARCHAR2(100),
    CONSTRAINT fk_palestrante_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf)
);

-- Criação da tabela Ouvinte
CREATE TABLE Ouvinte (
    cpf_participante VARCHAR2(11),
    numero_do_ingresso INT,
    CONSTRAINT fk_ouvinte_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf)
);

-- Criação da tabela Produto
CREATE TABLE Produto (
    id_produto INT PRIMARY KEY,
    nome VARCHAR2(100),
    preco DECIMAL(10, 2),
    categoria VARCHAR2(50),
    estoque INT
);

-- Criação da tabela Estande
CREATE TABLE Estande (
    id_estande INT PRIMARY KEY,
    categoria VARCHAR2(50),
    nome VARCHAR2(100)
);

-- Criação da tabela Atividade
CREATE TABLE Atividade (
    id_atvd INT PRIMARY KEY,
    nome VARCHAR2(100),
    categoria VARCHAR2(50),
    capacidade INT
);

-- Criação da tabela Local
CREATE TABLE LocalEvento (
    geolocalizacao VARCHAR2(100) PRIMARY KEY,
    nome VARCHAR2(100)
);

-- Criação da tabela Cupom
CREATE TABLE Cupom (
    codigo_promocional VARCHAR2(20) PRIMARY KEY
);

-- Criação do relacionamento triplo Compra
CREATE TABLE Compra (
    cpf_participante VARCHAR2(11),
    id_produto INT,
    id_estande INT,
    CONSTRAINT fk_compra_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    CONSTRAINT fk_compra_estande FOREIGN KEY (id_estande) REFERENCES Estande(id_estande)
);

-- Criação do relacionamento triplo e temporal Compra
CREATE TABLE Reserva (
    cpf_organizador VARCHAR2(11),
    geolocalizacao_local VARCHAR2(100),
    id_atividade INT,
    data_alocacao DATE,
    CONSTRAINT fk_reserva_organizador FOREIGN KEY (cpf_organizador) REFERENCES Organizador(cpf_participante),
    CONSTRAINT fk_reserva_local FOREIGN KEY (geolocalizacao_local) REFERENCES LocalEvento(geolocalizacao),
    CONSTRAINT fk_reserva_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade(id_atvd)
);

-- Criação do relacionamento N:N Ministra
CREATE TABLE Ministra (
    cpf_palestrante VARCHAR2(11) PRIMARY KEY,
    id_atividade INT,
    CONSTRAINT fk_ministra_palestrante FOREIGN KEY (cpf_palestrante) REFERENCES Participante(cpf),
    CONSTRAINT fk_ministra_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade(id_atvd)
);

-- Criação do relacionamento N:N Participa (Atividade-Ouvinte)
CREATE TABLE Participa (
    cpf_ouvinte VARCHAR2(11),
    id_atividade INT,
    CONSTRAINT fk_participa_ouvinte FOREIGN KEY (cpf_ouvinte) REFERENCES Participante(cpf),
    CONSTRAINT fk_participa_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade(id_atvd)
);

-- Criação da tabela Acesso_VIP com relacionamento Privilegia
CREATE TABLE Acesso_VIP (
    VIP_ID INT,
    dia_do_acesso DATE,
    categoria_do_acesso VARCHAR2(50),
    cpf_ouvinte VARCHAR2(11),
    CONSTRAINT pk_acesso_vip PRIMARY KEY (VIP_ID, dia_do_acesso, cpf_ouvinte),
    CONSTRAINT fk_acesso_vip_ouvinte FOREIGN KEY (cpf_ouvinte) REFERENCES Participante(cpf)
);

-- Criação do relacionamento 1:1 Ganha (Cupom e Participa)
ALTER TABLE Participa ADD codigo_promocional VARCHAR2(20);
ALTER TABLE Participa ADD CONSTRAINT fk_participa_cupom FOREIGN KEY (codigo_promocional) REFERENCES Cupom(codigo_promocional);
ALTER TABLE Participa ADD CONSTRAINT uniq_codigo_promocional UNIQUE (codigo_promocional);