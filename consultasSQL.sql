-- AVG, GROUP BY, HAVING, ORDER BY
-- Mostra a média dos preços dos produtos agrupados por categoria,
-- e com média superior a 25
SELECT categoria, AVG(preco) FROM Produto
GROUP BY categoria
HAVING AVG(preco) > 25
ORDER BY AVG(preco)


-- Subconsulta com IN, subconsulta com operador relacional
SELECT p.nome
FROM Participante p
WHERE p.cpf IN (
    SELECT o.cpf_participante
    FROM Ouvinte o
    JOIN Acesso_VIP a ON O.cpf_participante = a.cpf_ouvinte
);


--INSERT INTO
--adiciona um endereço de Sao Paulo
INSERT INTO Endereco VALUES ('05417-020','São Paulo','São Paulo','Pinheiros','Rua Simão Álvares');
--adiciona um participante de Sao Paulo
INSERT INTO Participante VALUES ('39594066814', 'Alberto Souza dos Santos', 'albertopaulista@gmail.com', '(11) 99653-5229', '05417-020');


-- To com duvida se isso faz sentido
-- COUNT, LEFT OUTER JOIN
-- Mostra nome de participante e 
SELECT p.nome , COUNT(*)
FROM Participante p
Left Outer JOIN Compra c
ON p.cpf = c.cpf_participante
GROUP BY p.nome


--ALTER TABLE
-- adiciona o campo cupom para participa
ALTER TABLE Participa ADD codigo_promocional VARCHAR2(20);
ALTER TABLE Participa ADD CONSTRAINT fk_participa_cupom FOREIGN KEY (codigo_promocional) REFERENCES Cupom(codigo_promocional);
ALTER TABLE Participa ADD CONSTRAINT uniq_codigo_promocional UNIQUE (codigo_promocional);


--INNER JOIN
--Verificar o nome dos palestrantes as respectivas atividades que eles estao ministrando
SELECT
    Participante.Nome AS PalestranteNome,
    Palestrante.Cpf_participante AS PalestranteCPF,
    Ministra.id_atividade,
    Atividade.nome
    
FROM
    Participante
INNER JOIN
    Palestrante ON Participante.cpf = palestrante.cpf_participante
INNER JOIN
    Ministra ON Palestrante.cpf_participante = Ministra.cpf_palestrante
INNER JOIN
    Atividade ON Ministra.id_atividade = Atividade.ID_ATVD


--INER JOIN e IN
/*Verifica quais sao as atividades e os locais de evento que foram reservados
	pelo organizador de cpf 23322076431
*/
SELECT
    LocalEvento.nome AS NomeEspaco,
    Atividade.nome AS NomeAtividade,
    Reserva.data_alocacao AS DataEHora

FROM
    Atividade
INNER JOIN
    Reserva ON Atividade.id_atvd = reserva.id_atividade
INNER JOIN
    LocalEvento ON Reserva.geolocalizacao_local = LocalEvento.geolocalizacao
WHERE
    Reserva.cpf_organizador IN ('23322076431')


-- BETWEEN
--Verificar quais são os produtos que tem o preço entre R$20,00 e R$50,00
SELECT 
    Produto.nome AS ProdutoNome,
    Produto.preco AS Preco
FROM
    Produto
Where 
    Preco BETWEEN 20 AND 50


-- LIKE
-- Procura por produtos que foram comprados em estandes terminados em 'Quadrinhos'
SELECT
    Estande.nome AS EstandeNome,
    Produto.nome AS ProdutoNome
FROM
    Produto
INNER JOIN 
    Compra ON Produto.id_produto = Compra.id_produto
INNER JOIN
    Estande ON Compra.id_estande = Estande.id_estande
WHERE
    Estande.nome LIKE '%Quadrinhos'


--IS NULL
--Verificar qual supervisor participa de alguma atividade
--se o campo cpf_supervisor == NULL entao o participante eh organizador e supervisor
SELECT 
    Participante.nome AS NomeParticipante,
    Atividade.nome AS NomeAtividade
FROM
    Atividade
INNER JOIN
    Participa ON Atividade.id_atvd = Participa.id_atividade
INNER JOIN
    Participante ON Participa.cpf_ouvinte = Participante.cpf
INNER JOIN
    Organizador ON Participante.cpf = Organizador.cpf_participante
WHERE
    cpf_supervisor IS NULL;


--MIN
--Pega as atividades com menor capacidade e indica seus locais de realizacao
SELECT 
    Atividade.nome AS AtividadeMax,
    LocalEvento.nome AS LocalDoEvento
FROM
    LocalEvento
INNER JOIN
    Reserva ON LocalEvento.geolocalizacao = Reserva.geolocalizacao_local
INNER JOIN
    Atividade ON Reserva.id_atividade = Atividade.id_atvd
WHERE 
    Atividade.capacidade = (SELECT MIN(capacidade) FROM Atividade)
GROUP BY
    Atividade.nome, LocalEvento.nome;


--MAX
/* verifica quais foram os participantes que compraram os produtos
com maior estoque dentro dos estandes */
SELECT 
    Participante.nome AS NomeParticipante,
    Estande.nome AS EstandeDaCompra
FROM
    Participante
INNER JOIN
    Compra ON Participante.cpf = Compra.cpf_participante
INNER JOIN
    Estande ON Compra.id_estande = Estande.id_estande
INNER JOIN
    Produto ON Compra.id_produto = Produto.id_produto
WHERE
    Produto.estoque = (SELECT MAX(Estoque) FROM Produto)
GROUP BY
		Participante.nome, Estande.nome;


--CREATE INDEX
CREATE INDEX idx_nome ON Participante (nome);
SELECT cpf, nome, email, numero, cep
FROM Participante
WHERE nome = 'Ana Oliveira';


--DELETE 
--Apaga os produtos que nunca tiveram registros de compra durante o evento
DELETE FROM Produto
WHERE id_produto IN (
    SELECT Produto.id_produto
    FROM Produto
    LEFT JOIN Compra ON Compra.id_produto = Produto.id_produto
    WHERE Compra.id_produto IS NULL
);


--SUBCONSULTA ANY
--Verificando os locais que realizam mais de uma atividade atraves de subconsulta ANY
SELECT 
    LocalEvento.nome AS NomeLocal
FROM
    LocalEvento
WHERE
    LocalEvento.geolocalizacao = ANY (
        SELECT geolocalizacao_local
        FROM Reserva
        GROUP BY geolocalizacao_local
        HAVING COUNT(geolocalizacao_local) > 1
    )
GROUP BY
    LocalEvento.nome;


--UPDATE
--adiciona o sufixo Vip Place aos locais de evento que realizam mais de uma atividade
UPDATE LocalEvento
SET nome = nome + ' Vip Place'
WHERE nome IN (
    SELECT LocalEvento.nome
    FROM Reserva
    INNER JOIN LocalEvento ON Reserva.geolocalizacao_local = LocalEvento.geolocalizacao
    GROUP BY LocalEvento.nome
    HAVING COUNT(Reserva.geolocalizacao_local) > 1
);


--UPDATE
--retorna todos os ouvintes que são bahianos
SELECT *
FROM Ouvinte
WHERE 'Bahia' = ALL (
    SELECT Endereco.Estado
    FROM Endereco
    INNER JOIN Participante ON Participante.cep = Endereco.cep
    WHERE Participante.cpf = Ouvinte.cpf_participante
);


--UNION
--Retorna respectivamente o produto de Maior e Menor estoque disponíveis para compra
SELECT
    Produto.nome AS NomeProduto
FROM
    Compra
INNER JOIN 
    Produto ON Compra.id_produto = Produto.id_produto
WHERE
    Produto.estoque = (SELECT MAX(Estoque) FROM Produto)
    
UNION

SELECT
    Produto.nome AS NomeProduto
FROM
    Compra
INNER JOIN 
    Produto ON Compra.id_produto = Produto.id_produto
WHERE
    Produto.estoque = (SELECT MIN(Estoque) FROM Produto);


--CREATE VIEW
--Cria uma tabela com o nome dos participantes e suas atividades que serao realizadas durante o evento
CREATE VIEW ParticipantesAtividades AS
SELECT
    P.cpf AS cpf_participante,
    P.nome AS nome_participante,
    A.id_atvd,
    A.nome AS nome_atividade
FROM
    Participante P
    JOIN Participa PA ON P.cpf = PA.cpf_ouvinte
    JOIN Atividade A ON PA.id_atividade = A.id_atvd;