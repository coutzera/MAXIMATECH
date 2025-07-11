/*
    -------------------------------------------------------------------------
    SCRIPT: Consulta de produtos ativos com estoque por filial (Fornecedor 37)
    -------------------------------------------------------------------------
    Objetivo:
    - Retornar, por filial, a quantidade de produtos distintos do fornecedor 37
      que estão marcados como ATIVOS para venda (ENVIARFORCAVENDAS = 'S')
      e possuem ESTOQUE > 0.
*/

-- CTE 1: Filtra todos os produtos do fornecedor 37
WITH PRODUTOS_FORNECEDOR_37 AS (
    SELECT CODPROD
    FROM PCPRODUT
    WHERE CODFORNEC = 37
),

-- CTE 2: Seleciona produtos ativos para venda com estoque positivo por filial
PRODUTOS_ATIVOS_ESTOQUE AS (
    SELECT DISTINCT
        E.CODPROD,
        E.CODFILIAL
    FROM
        PCEST E
        INNER JOIN PCPRODFILIAL PF ON PF.CODPROD = E.CODPROD
                                 AND PF.CODFILIAL = E.CODFILIAL
    WHERE
        E.QTEST > 0                      -- Somente produtos com estoque positivo
        AND PF.ENVIARFORCAVENDAS = 'S'   -- Marcados como ativos para força de vendas
)

-- Resultado Final:
-- Conta, por filial, a quantidade de produtos distintos do fornecedor 37
SELECT
    PA.CODFILIAL AS FILIAL,              -- Código da filial
    COUNT(DISTINCT PA.CODPROD) AS QTDE_PRODUTOS  -- Quantidade de produtos distintos
FROM
    PRODUTOS_ATIVOS_ESTOQUE PA
    INNER JOIN PRODUTOS_FORNECEDOR_37 PF37 ON PA.CODPROD = PF37.CODPROD
GROUP BY
    PA.CODFILIAL
ORDER BY
    PA.CODFILIAL;