--consulta com REF
--Qual ouvinte participou de mais atvds?
SELECT p.cpf, p.nome, COUNT(ref(pa)) AS total_atividades
FROM Participa pa
JOIN Participante p ON pa.cpf_ouvinte = p.cpf
GROUP BY p.cpf
ORDER BY COUNT(ref(pa)) DESC
FETCH FIRST 1 ROW ONLY;
/


--consulta com DEREF
--Quanto cada participante gastou em compras de produtos? Organizado do menor para o maior
SELECT DEREF(c.cpf_participante).cpf_participante AS cpf_participante,
SUM(DEREF(c.id_produto).preco) AS total_compras
FROM Compra c
JOIN Estande e ON DEREF(c.id_estande).id_estande = e.id_estande
GROUP BY DEREF(c.participante).cpf_participante
ORDER BY total_compras;
/


--consulta com VARRAY
--participantes que sao ouvintes e participaram da atvd "Jogo de Realidade Alternativa"
--da o nome e os telefones dos ouvintes
SELECT p.nome, p.cpf, c.*
FROM Participante p, TABLE (p.numero) c
JOIN Participa pa ON DEREF(pa.cpf_ouvinte).cpf_ouvinte = p.cpf
JOIN Atividade a ON DEREF(pa.id_atividade).id_atividade = a.id_atvd
WHERE DEREF(a.nome).nome_atividade LIKE 'Jogo de Realidade Alternativa';
/



--na atividade passada (atvd 05), a gnt nao usou NESTED TABLE para criar tabelas :(
--to refazendo a tabela Compra para suprir a necessidade e fazer a consulta com NESTED TABLE
--tipo compra

--cria um tipo pra cada item que um participante comprou (ele pode comprar mais de um item)
CREATE TYPE Item_Tipo AS OBJECT (
    id_produto INT,
    id_estande INT
);
/
--cria o tipo compra que ja existia
CREATE OR REPLACE TYPE Compra_Tipo AS OBJECT (
    cpf_participante VARCHAR2(11),
    compras Compra_Nested_Table
);
/
--cria a nested table dos itens que um participante comprou
CREATE TYPE Compra_Nested_Table AS TABLE OF Item_Tipo;
/
CREATE TABLE Compra OF Compra_Tipo;
ALTER TABLE Compra ADD CONSTRAINT fk_compra_participante FOREIGN KEY (cpf_participante) REFERENCES Participante(cpf);
ALTER TABLE Compra ADD CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES Produto(id_produto);
ALTER TABLE Compra ADD CONSTRAINT fk_compra_estande FOREIGN KEY (id_estande) REFERENCES Estande(id_estande);


--itens comprados pelo cpf 11121530397 com o nome dos itens e seus estandes
SELECT DEREF(tab).id_produto, p.nome, DEREF(tab).id_estande, e.nome AS nome_estande
FROM Compra c, TABLE(c.compras) tab, Produto p, Estande e
WHERE c.cpf_participante = '11121530397'
  AND DEREF(tab).id_produto = p.id_produto
  AND DEREF(tab).id_estande = e.id_estande;