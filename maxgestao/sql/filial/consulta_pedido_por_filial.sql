-- CTE para selecionar usuários ativos em filiais específicas
WITH usuarios_ativos AS (
    SELECT codusur
    FROM pcusuari
    WHERE codfilial IN (
        '01','02','03','04','05','06','07','08','09','10',
        '11','12','13','14','15','16','18','21','52','53'  -- Lista de filiais consideradas
    )
    AND dttermino IS NULL  -- Usuário sem data de término, ou seja, ativo
),

-- CTE para filtrar pedidos dentro do período desejado, importados, e realizados por usuários ativos
pedidos_filtrados AS (
    SELECT
        p.codfilial,
        p.codusur,
        p.numped,
        p.numpedrca,
        p.idpedidonv,
        p.importado,
        p.dtinclusao
    FROM
        pcpedcfv p
    WHERE
        p.dtinclusao >= TO_DATE('30-04-2025', 'DD-MM-YYYY')  -- Data inicial (inclusiva)
        AND p.dtinclusao < TO_DATE('01-05-2025', 'DD-MM-YYYY')  -- Data final (exclusiva)
        AND p.importado IN (1, 4)  -- Filtra tipos de pedidos importados específicos
        AND p.codusur IN (SELECT codusur FROM usuarios_ativos)  -- Só usuários ativos das filiais selecionadas
),

-- CTE para resumir a quantidade de pedidos por filial
resumo_filial AS (
    SELECT
        p.codfilial AS codfilial,
        COUNT(1) AS qtd_pedidos
    FROM
        pedidos_filtrados p
    GROUP BY
        p.codfilial
),

-- CTE para adicionar uma linha com o total geral de pedidos somando todas as filiais
resumo_com_total AS (
    SELECT
        codfilial,
        qtd_pedidos
    FROM
        resumo_filial

    UNION ALL  -- Une os dados por filial com a linha total

    SELECT
        'TOTAL' AS codfilial,  -- Label para linha total
        SUM(qtd_pedidos) AS qtd_pedidos
    FROM
        resumo_filial
)

-- Seleção final ordenando para mostrar as filiais em ordem numérica e a linha 'TOTAL' por último
SELECT
    codfilial,
    qtd_pedidos
FROM
    resumo_com_total
ORDER BY
    CASE 
        WHEN codfilial = 'TOTAL' THEN 999999  -- Garante que o 'TOTAL' fique sempre no final
        ELSE TO_NUMBER(codfilial)              -- Ordena as filiais numericamente
    END;
