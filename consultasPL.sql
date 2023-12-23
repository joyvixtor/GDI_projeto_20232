DECLARE
   TYPE EnderecoType IS RECORD (
      cep VARCHAR2(9),
      estado VARCHAR2(50),
      cidade VARCHAR2(50),
      bairro VARCHAR2(50),
      rua VARCHAR2(100)
   );

   endereco_rec EnderecoType;

   participante_rec Participante%ROWTYPE;

BEGIN
   endereco_rec.cep := '50740-120';
   endereco_rec.estado := 'Pernambuco';
   endereco_rec.cidade := 'Recife';
   endereco_rec.bairro := 'Várzea';
   endereco_rec.rua := 'Rua Emetério Maciel';

   SELECT *
   INTO participante_rec
   FROM Participante
   WHERE cpf = '34934945482';

   DBMS_OUTPUT.PUT_LINE('Nome do Participante: ' || participante_rec.nome);
END;
/



--declaracao TABLE
CREATE OR REPLACE TYPE CepListType AS TABLE OF VARCHAR2(9);
/
--TABLE bloco anônimo
DECLARE

   lista_ceps CepListType := CepListType('50740-120', '50100-400', '50690-665');
BEGIN

   FOR i IN lista_ceps.FIRST .. lista_ceps.LAST LOOP
      DBMS_OUTPUT.PUT_LINE('CEP: ' || lista_ceps(i));
   END LOOP;
END;
/
DROP TYPE CepListType;



--usa CREATE PROCEDURE e um CASE WHEN
--Diminui o estoque dos produtos quando uma compra eh catalogada
CREATE OR REPLACE PROCEDURE AtualizarEstoque(
    p_id_produto INT,
    p_quantidade_comprada INT
) AS
    v_estoque_atual INT;

BEGIN
    SELECT estoque INTO v_estoque_atual
    FROM Produto
    WHERE id_produto = p_id_produto;

    UPDATE Produto
    SET estoque = v_estoque_atual - p_quantidade_comprada
    WHERE id_produto = p_id_produto;

    -- Exibir mensagem de sucesso
    DBMS_OUTPUT.PUT_LINE('Estoque atualizado com sucesso.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Produto não encontrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar o estoque.');

END AtualizarEstoque;
/



--CREATE FUNCTION
-- Criacao de uma funcao para calcular o preço total de uma compra
CREATE OR REPLACE FUNCTION CalcularPrecoTotal(
    p_id_produto INT,
    p_quantidade_comprada INT
) RETURN DECIMAL IS
    v_preco_unitario DECIMAL(10, 2);
    v_preco_total DECIMAL(10, 2);

BEGIN
    SELECT preco INTO v_preco_unitario
    FROM Produto
    WHERE id_produto = p_id_produto;

    v_preco_total := v_preco_unitario * p_quantidade_comprada;

    RETURN v_preco_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;

END CalcularPrecoTotal;
/



-- IF/ELSE
--Verifica se o organizador eh supervisor ou nao
CREATE OR REPLACE PROCEDURE VerificarCargoParticipante(p_cpf VARCHAR2) AS
    v_cargo_participante VARCHAR2(50);

BEGIN
    SELECT cargo INTO v_cargo_participante
    FROM Organizador
    WHERE cpf_participante = p_cpf;


    IF v_cargo_participante = 'Supervisor' THEN
        DBMS_OUTPUT.PUT_LINE('O participante é um dos organizadores chefe.');
		ELSIF v_cargo_participante = 'Jornalista' THEN
        DBMS_OUTPUT.PUT_LINE('O participante é da área de comunicação.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('O participante é um organizador regular');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Participante não encontrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao verificar o cargo.');

END VerificarCargoParticipante;



--Utilizando LOOPS
--LOOP EXIT WHEN
--O codigo para quando encontra um Social Media
CREATE OR REPLACE PROCEDURE VerificarCargosParticipantes AS
    v_cpf_participante VARCHAR2(11);
    v_cargo_participante VARCHAR2(50);

BEGIN
    FOR participante_rec IN (SELECT cpf FROM Participante) LOOP
        v_cpf_participante := participante_rec.cpf;

        SELECT cargo INTO v_cargo_participante
        FROM Organizador
        WHERE cpf_participante = v_cpf_participante;

        CASE v_cargo_participante
            WHEN 'Supervisor' THEN
                DBMS_OUTPUT.PUT_LINE('O participante com CPF ' || v_cpf_participante || ' é um dos organizadores chefe.');
            WHEN 'Social Media' THEN
                DBMS_OUTPUT.PUT_LINE('O participante com CPF ' || v_cpf_participante || ' é um Social Media. Encerra loop.');
                EXIT; 
            ELSE
                DBMS_OUTPUT.PUT_LINE('O participante com CPF ' || v_cpf_participante || ' é um organizador comum.');
        END CASE;

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Verificação de cargos concluída.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao verificar cargos.');

END VerificarCargosParticipantes;
/



--WHILE LOOP
--Contador com o numero de participantes
--Lista os participantes que sao supervisores e que sao organizadores comuns
CREATE OR REPLACE PROCEDURE VerificarCargosParticipantes AS
    v_cpf_participante VARCHAR2(11);
    v_cargo_participante VARCHAR2(50);
    v_contador INT := 1;

BEGIN
    v_contador := (SELECT COUNT(*) FROM Participante);

    WHILE v_contador > 0 LOOP
        SELECT cpf INTO v_cpf_participante
        FROM Participante
        WHERE ROWNUM = 1;

        SELECT cargo INTO v_cargo_participante
        FROM Organizador
        WHERE cpf_participante = v_cpf_participante;

        CASE v_cargo_participante
            WHEN 'Supervisor' THEN
                DBMS_OUTPUT.PUT_LINE('O participante com CPF ' || v_cpf_participante || ' é um dos organizadores chefe.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('O participante com CPF ' || v_cpf_participante || ' é um organizador comum.');
        END CASE;

        v_contador := v_contador - 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Verificação de cargos concluída.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao verificar cargos.');

END VerificarCargosParticipantes;
/



--OPEN, FETCH, CLOSE
--faz a listagem de todos os produtos do banco de dados
CREATE OR REPLACE PROCEDURE listar_produtos IS
    CURSOR produto_cursor IS
        SELECT id_produto, nome, preco, categoria, estoque
        FROM Produto;
        
    v_id_produto Produto.id_produto%TYPE;
    v_nome Produto.nome%TYPE;
    v_preco Produto.preco%TYPE;
    v_categoria Produto.categoria%TYPE;
    v_estoque Produto.estoque%TYPE;

BEGIN
    OPEN produto_cursor;

    LOOP
        FETCH produto_cursor INTO v_id_produto, v_nome, v_preco, v_categoria, v_estoque;
        EXIT WHEN produto_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID Produto: ' || v_id_produto || ', Nome: ' || v_nome ||
                             ', Preço: ' || v_preco || ', Categoria: ' || v_categoria || ', Estoque: ' || v_estoque);
    END LOOP;

    CLOSE produto_cursor;
END listar_produtos;
/



--IN e OUT
--Recebe como IN um cpf e o OUT eh o participante que tem esse CPF
CREATE OR REPLACE PROCEDURE ObterNomeParticipante(
    p_cpf_participante IN VARCHAR2,
    p_nome_participante OUT VARCHAR2
) AS
BEGIN
    SELECT nome
    INTO p_nome_participante
    FROM Participante
    WHERE cpf = p_cpf_participante;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_nome_participante := NULL; 
END ObterNomeParticipante;
/



----------------------------- CREATE OR REPLACE PACKAGE COM SEU BODY -----------------------------------------
-- CREATE OR REPLACE PACKAGE
--Dessa vez cria um pacote que recebe o CPF e retorna o email do participante
CREATE OR REPLACE PACKAGE PacoteParticipante AS
    PROCEDURE ObterEmailParticipante(
        p_cpf_participante IN VARCHAR2,
        p_email_participante OUT VARCHAR2
    );
END PacoteParticipante;
/
--CREATE OR REPLACE PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY PacoteParticipante AS
    PROCEDURE ObterEmailParticipante(
        p_cpf_participante IN VARCHAR2,
        p_email_participante OUT VARCHAR2
    ) AS
    BEGIN
        SELECT email INTO p_email_participante
        FROM Participante
        WHERE cpf = p_cpf_participante;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_email_participante := NULL; 
    END ObterEmailParticipante;
END PacoteParticipante;
/




--CREATE OR REPLACE TRIGGER (LINHA)
--trigger que verifica se o cpf do participante eh unico
--acionado quando tenta adicionar um novo participante
CREATE OR REPLACE TRIGGER VerificarCpfUnico
BEFORE INSERT ON Participante
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Participante
    WHERE cpf = :NEW.cpf;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF de participante já em uso. Escolha um número diferente.');
    END IF;
END VerificarNumeroUnico;
/




--CREATE OR REPLACE TRIGGER (COMANDO)
--qualquer instrucao no atributo preco do produto
--nao deixa que um produto fique com valor negativo
CREATE OR REPLACE TRIGGER verifica_preco_positivo
BEFORE UPDATE OF preco
ON Produto
FOR EACH STATEMENT
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Produto
        WHERE preco < 0
    ) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Atualização não permitida. Preço não pode ser negativo.');
    END IF;
END verifica_preco_positivo;
/
