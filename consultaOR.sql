-- Criação do tipo Organizador
CREATE OR REPLACE TYPE Organizador_Tipo UNDER Participante_Tipo (
    cargo VARCHAR2(50),
    departamento VARCHAR2(50),
    cpf_supervisor VARCHAR2(11),
    
    CONSTRUCTOR FUNCTION Organizador_Tipo(
        cpf_participante VARCHAR2,
        cargo VARCHAR2,
        departamento VARCHAR2,
        cpf_supervisor VARCHAR2
    ) RETURN SELF AS RESULT
) NOT FINAL;

-- Criação do corpo do tipo Organizador
-- TODO ajeitar sintaxe 
CREATE OR REPLACE TYPE BODY Organizador_Tipo AS
    CONSTRUCTOR FUNCTION Organizador_Tipo(
        cpf_participante VARCHAR2,
        cargo VARCHAR2,
        departamento VARCHAR2,
        cpf_supervisor VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF := Organizador_Tipo(cpf_participante, '','','','', cargo, departamento, cpf_supervisor);
        RETURN;
    END;

    OVERRIDING MEMBER FUNCTION participante_json RETURN VARCHAR2 IS
    BEGIN
        -- Retorna um JSON contendo informações sobre o organizador, incluindo cargo e departamento
        RETURN '{"cpf":"' || SELF.cpf || '","nome":"' || SELF.nome || '","email":"' || SELF.email || '","numero":"' || SELF.numero || '","cep":"' || SELF.cep || '","cargo":"' || SELF.cargo || '","departamento":"' || SELF.departamento || '","cpf_supervisor":"' || SELF.cpf_supervisor || '"}';
    END;

-- Criação da tabela Organizador
CREATE TABLE Organizador OF Organizador_Tipo (
    cpf_participante PRIMARY KEY,
    CONSTRAINT fk_organizador_participante FOREIGN KEY (cpf_participante) REFERENCES Participante,
    CONSTRAINT fk_organizador_supervisor FOREIGN KEY (cpf_supervisor) REFERENCES Organizador
);

-- Criação do tipo Palestrante
CREATE OR REPLACE TYPE Palestrante_Tipo UNDER Participante_Tipo (
    empresa_vinculo VARCHAR2(100),
    
    CONSTRUCTOR FUNCTION Palestrante_Tipo(
        cpf_participante VARCHAR2,
        empresa_vinculo VARCHAR2
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Palestrante
CREATE TABLE Palestrante OF Palestrante_Tipo (
    cpf PRIMARY KEY,
    CONSTRAINT fk_palestrante_participante FOREIGN KEY (cpf) REFERENCES Participante
);

-- Criação do tipo Ouvinte
CREATE OR REPLACE TYPE Ouvinte_Tipo UNDER Participante_Tipo (
    numero_do_ingresso INT,
    
    CONSTRUCTOR FUNCTION Ouvinte_Tipo(
        cpf_participante VARCHAR2,
        numero_do_ingresso INT
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Ouvinte
CREATE TABLE Ouvinte OF Ouvinte_Tipo (
    cpf PRIMARY KEY,
    CONSTRAINT fk_ouvinte_participante FOREIGN KEY (cpf) REFERENCES Participante
);

-- Criação do tipo Produto
CREATE OR REPLACE TYPE Produto_Tipo AS OBJECT (
    id_produto INT,
    nome VARCHAR2(100),
    preco DECIMAL(10, 2),
    categoria VARCHAR2(50),
    estoque INT,
    
    CONSTRUCTOR FUNCTION Produto_Tipo(
        id_produto INT,
        nome VARCHAR2,
        preco DECIMAL,
        categoria VARCHAR2,
        estoque INT
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Produto
CREATE TABLE Produto OF Produto_Tipo (
    id_produto PRIMARY KEY
);

-- Criação do tipo Estande
CREATE OR REPLACE TYPE Estande_Tipo AS OBJECT (
    id_estande INT,
    categoria VARCHAR2(50),
    nome VARCHAR2(100),
    
    CONSTRUCTOR FUNCTION Estande_Tipo(
        id_estande INT,
        categoria VARCHAR2,
        nome VARCHAR2
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Estande
CREATE TABLE Estande OF Estande_Tipo (
    id_estande PRIMARY KEY
);

-- Criação do tipo Atividade
CREATE OR REPLACE TYPE Atividade_Tipo AS OBJECT (
    id_atvd INT,
    nome VARCHAR2(100),
    categoria VARCHAR2(50),
    capacidade INT,
    
    CONSTRUCTOR FUNCTION Atividade_Tipo(
        id_atvd INT,
        nome VARCHAR2,
        categoria VARCHAR2,
        capacidade INT
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Atividade
CREATE TABLE Atividade OF Atividade_Tipo (
    id_atvd PRIMARY KEY
);

-- Criação do tipo LocalEvento
CREATE OR REPLACE TYPE LocalEvento_Tipo AS OBJECT (
    geolocalizacao VARCHAR2(100),
    nome VARCHAR2(100),
    
    CONSTRUCTOR FUNCTION LocalEvento_Tipo(
        geolocalizacao VARCHAR2,
        nome VARCHAR2
    ) RETURN SELF AS RESULT
);

-- Criação da tabela LocalEvento
CREATE TABLE LocalEvento OF LocalEvento_Tipo (
    geolocalizacao PRIMARY KEY
);

-- Criação do tipo Cupom
CREATE OR REPLACE TYPE Cupom_Tipo AS OBJECT (
    codigo_promocional VARCHAR2(20),
    
    CONSTRUCTOR FUNCTION Cupom_Tipo(
        codigo_promocional VARCHAR2
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Cupom
CREATE TABLE Cupom OF Cupom_Tipo (
    codigo_promocional PRIMARY KEY
);

-- Criação do tipo Compra
CREATE OR REPLACE TYPE Compra_Tipo AS OBJECT (
    cpf_participante VARCHAR2(11),
    id_produto INT,
    id_estande INT,
    
    CONSTRUCTOR FUNCTION Compra_Tipo(
        cpf_participante VARCHAR2,
        id_produto INT,
        id_estande INT
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Compra
CREATE TABLE Compra OF Compra_Tipo;

ALTER TABLE Compra ADD CONSTRAINT fk_compra_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf);

ALTER TABLE Compra ADD CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES Produto(id_produto);

ALTER TABLE Compra ADD CONSTRAINT fk_compra_estande FOREIGN KEY (id_estande) REFERENCES Estande(id_estande);

-- Criação do tipo Reserva
CREATE OR REPLACE TYPE Reserva_Tipo AS OBJECT (
    cpf_organizador VARCHAR2(11),
    geolocalizacao_local VARCHAR2(100),
    id_atividade INT,
    data_alocacao DATE,
    
    CONSTRUCTOR FUNCTION Reserva_Tipo(
        cpf_organizador VARCHAR2,
        geolocalizacao_local VARCHAR2,
        id_atividade INT,
        data_alocacao DATE
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Reserva
CREATE TABLE Reserva OF Reserva_Tipo;

ALTER TABLE Reserva ADD CONSTRAINT fk_reserva_organizador FOREIGN KEY (cpf_organizador) REFERENCES Organizador;
ALTER TABLE Reserva ADD CONSTRAINT fk_reserva_local FOREIGN KEY (geolocalizacao_local) REFERENCES LocalEvento;
ALTER TABLE Reserva ADD CONSTRAINT fk_reserva_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade;

-- Criação do tipo Ministra
CREATE OR REPLACE TYPE Ministra_Tipo AS OBJECT (
    cpf_palestrante VARCHAR2(11),
    id_atividade INT,
    
    CONSTRUCTOR FUNCTION Ministra_Tipo(
        cpf_palestrante VARCHAR2,
        id_atividade INT
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Ministra
CREATE TABLE Ministra OF Ministra_Tipo (
    cpf_palestrante PRIMARY KEY,
    CONSTRAINT fk_ministra_palestrante FOREIGN KEY (cpf_palestrante) REFERENCES Participante,
    CONSTRAINT fk_ministra_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade
);

-- Criação do tipo Participa
CREATE OR REPLACE TYPE Participa_Tipo AS OBJECT (
    cpf_ouvinte VARCHAR2(11),
    id_atividade INT,
    
    CONSTRUCTOR FUNCTION Participa_Tipo(
        cpf_ouvinte VARCHAR2,
        id_atividade INT,
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Participa
CREATE TABLE Participa OF Participa_Tipo (
    CONSTRAINT fk_participa_ouvinte FOREIGN KEY (cpf_ouvinte) REFERENCES Participante,
    CONSTRAINT fk_participa_atividade FOREIGN KEY (id_atividade) REFERENCES Atividade,
);

-- Criação do tipo Acesso_VIP
CREATE OR REPLACE TYPE Acesso_VIP_Tipo AS OBJECT (
    VIP_ID INT,
    dia_do_acesso DATE,
    categoria_do_acesso VARCHAR2(50),
    cpf_ouvinte VARCHAR2(11)
);

-- Criação da tabela Acesso_VIP com relacionamento Privilegia
CREATE TABLE Acesso_VIP_Ref (
    row_id ROWID PRIMARY KEY,
    ref_value REF Acesso_VIP_Tipo SCOPE IS Acesso_VIP
);

CREATE TABLE Acesso_VIP OF Acesso_VIP_Tipo (
    VIP_ID PRIMARY KEY,
    CONSTRAINT fk_acesso_vip_ouvinte FOREIGN KEY (cpf_ouvinte) REFERENCES Participante
);

-- Criação do relacionamento 1:1 Ganha (Cupom e Participa)
ALTER TYPE Participa_Tipo ADD ATTRIBUTE codigo_promocional VARCHAR2(20) CASCADE;

-- Adicionando a restrição UNIQUE diretamente ao tipo
ALTER TYPE Participa_Tipo ADD CONSTRAINT uniq_codigo_promocional UNIQUE (codigo_promocional);

-- Criação do tipo Endereco
CREATE OR REPLACE TYPE Endereco_Tipo AS OBJECT (
    cep VARCHAR2(9),
    estado VARCHAR2(50),
    cidade VARCHAR2(50),
    bairro VARCHAR2(50),
    rua VARCHAR2(100),
    
    CONSTRUCTOR FUNCTION Endereco_Tipo(
        cep VARCHAR2,
        estado VARCHAR2,
        cidade VARCHAR2,
        bairro VARCHAR2,
        rua VARCHAR2
    ) RETURN SELF AS RESULT
);

-- Criação da tabela Endereco
CREATE TABLE Endereco OF Endereco_Tipo (
    cep PRIMARY KEY
);

--Criacao do tipo Telefone (numero de celular)
CREATE TYPE varray_cel AS VARRAY (3) of VARCHAR2(11);
/


-- Criação do tipo Participante
CREATE OR REPLACE TYPE Participante_Tipo AS OBJECT (
    cpf VARCHAR2(11),
    nome VARCHAR2(100),
    email VARCHAR2(100),
		--lista de numero de telefones
    numero varray_cel,
    cep VARCHAR2(9),
    
    CONSTRUCTOR FUNCTION Participante_Tipo(
        cpf VARCHAR2,
        nome VARCHAR2,
        email VARCHAR2,
        numero varray_cel,
        cep VARCHAR2
    ) RETURN SELF AS RESULT,
    
    MEMBER PROCEDURE update_email(email_novo VARCHAR2),
    MEMBER FUNCTION contar_participantes RETURN INT,
    MAP MEMBER FUNCTION participante_json RETURN VARCHAR2
) NOT FINAL;

CREATE OR REPLACE TYPE BODY Participante_Tipo AS
    CONSTRUCTOR FUNCTION Participante_Tipo(
        cpf VARCHAR2,
        nome VARCHAR2,
        email VARCHAR2,
        numero varray_cel,
        cep VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.cpf := cpf;
        SELF.nome := nome;
        SELF.email := email;
        SELF.numero := numero;
        SELF.cep := cep;
        RETURN;
    END Participante_Tipo;

	MEMBER PROCEDURE update_email(email_novo VARCHAR2) IS
    BEGIN
        SELF.email := email_novo;
    END;

	MEMBER FUNCTION contar_participantes RETURN INT IS
        total_participantes INT;
    BEGIN
        SELECT COUNT(*) INTO total_participantes FROM DUAL;
        RETURN total_participantes;
    END contar_participantes;

	MAP MEMBER FUNCTION participante_json RETURN VARCHAR2 IS
    BEGIN
        -- Retorna um JSON contendo informações sobre o participante
        RETURN '{"cpf":"' || SELF.cpf || '","nome":"' || SELF.nome || '","email":"' || SELF.email || '","numero":"' || SELF.numero || '","cep":"' || SELF.cep || '"}';
    END participante_json;
END;


-- Criação da tabela Participante
CREATE TABLE Participante OF Participante_Tipo (
    cpf PRIMARY KEY,
    CONSTRAINT fk_participante_cep FOREIGN KEY (cep) REFERENCES Endereco 
);