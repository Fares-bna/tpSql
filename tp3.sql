--VUES 3.1
--QUESTION 1 | On utilise AVG pour la moyenne on divise par l'échelle et multiple par 20 pour obtenir la moyenne sur 20
SELECT evaluation.*, (AVG(notation.note)/evaluation.echelle*20) AS moyenne_sur_20 FROM evaluation JOIN notation ON notation.id_evaluation = evaluation.id_evaluation GROUP BY evaluation.id_evaluation, evaluation.nom;

--QUESTION 2 | NON, on ne peut pas faire de jointure avec d'autres tables sur des colonne générées.

--QUESTION 3
CREATE VIEW evaluation_avec_moyenne AS
SELECT
    evaluation.*,
    (AVG(notation.note)/evaluation.echelle*20) AS moyenne_sur_20
FROM evaluation
JOIN notation
    ON notation.id_evaluation = evaluation.id_evaluation
GROUP BY evaluation.id_evaluation;

--QUESTION 4
CREATE MATERIALIZED VIEW vuemat_evaluation AS SELECT evaluation.*, (AVG(notation.note)/evaluation.echelle*20) FROM evaluation JOIN notation ON evaluation.id_evaluation = notation.id_evaluation GROUP BY evaluation.id_evaluation;
--QUESTION 5 : on remarque que la vue matérialisée s'exécute 163 fois plus rapidement que la vue classique (6,53ms pour 0,045ms)
--QUESTION 7 : on remarque que la requête est exécutée beaucoup plus rapidement (environ 1,5 ms) que la précédente, cela signifie qu'elle ne recalcule pas entièrement la table. En utilisant explain analyse on voit ce qui se passe.
-- QUESTION 8 : Pour la vue matérialisée, on remarque que le temps d'exécution est légèment plus long d'un centième de seconde, on peut émettre comme hypothèse que la vue matérialisée, elle, se recalcule entièrement


--TABLEAUX 3.2
--QUESTION 9 | On compte les lignes puis on fait une jointure
SELECT module.id_module, module.intitule, COUNT(evaluation.*) AS Nb_eval FROM module JOIN evaluation ON evaluation.id_module = module.id_module GROUP BY module.id_module ORDER BY module.id_module;

--QUESTION 10 |
SELECT module.id_module, module.intitule, array_agg(evaluation.id_evaluation) AS tab_eval FROM module JOIN evaluation ON evaluation.id_module = module.id_module GROUP BY module.id_module ORDER BY module.id_module;

-- QUESTION 11 | On utilise cast pour utiliser le array agg avec 2 valeurs différentes de 2 types différents
SELECT module.id_module, module.intitule, array_agg(CAST(evaluation.id_evaluation AS varchar) || ' ' || CAST(evaluation.nom AS varchar)) AS tab_eval FROM module JOIN evaluation ON evaluation.id_module = module.id_module GROUP BY module.id_module ORDER BY module.id_module;

--QUESTION 12
SELECT evaluation.id_evaluation, evaluation.nom, evaluation.id_module, MAX(notation.note/evaluation.echelle*20) AS max, MIN(notation.note/evaluation.echelle*20) AS min FROM evaluation JOIN notation USING (id_evaluation) GROUP BY evaluation.id_evaluation, evaluation.id_module, evaluation.id_module ORDER BY 1;

--QUESTION 13 | On utilise Q12 en CTE pour calculer max/min par évaluation, puis on agrège par module avec un tableau 2D [id, nom, max, min]
WITH max_min AS (
    SELECT e.id_evaluation, e.nom, e.id_module,
           MAX(n.note / e.echelle * 20) AS max,
           MIN(n.note / e.echelle * 20) AS min
    FROM evaluation e
    JOIN notation n USING (id_evaluation)
    GROUP BY e.id_evaluation, e.id_module
)
SELECT m.id_module, m.intitule,
       array_agg(ARRAY[mm.id_evaluation::varchar, mm.nom, mm.max::varchar, mm.min::varchar]) AS tab_eval
FROM module m
JOIN max_min mm ON mm.id_module = m.id_module
GROUP BY m.id_module, m.intitule
ORDER BY m.id_module;

--QUESTION 14 | Vue à partir de Q13, notes arrondies à 1 décimale, dernière colonne nommée
CREATE VIEW vue_evals_module AS
WITH max_min AS (
    SELECT e.id_evaluation, e.nom, e.id_module,
           MAX(n.note / e.echelle * 20) AS max,
           MIN(n.note / e.echelle * 20) AS min
    FROM evaluation e
    JOIN notation n USING (id_evaluation)
    GROUP BY e.id_evaluation, e.id_module
)
SELECT m.id_module, m.intitule,
       array_agg(ARRAY[
           mm.id_evaluation::varchar,
           mm.nom,
           ROUND(mm.max::numeric, 1)::varchar,
           ROUND(mm.min::numeric, 1)::varchar
       ]) AS evaluations
FROM module m
JOIN max_min mm ON mm.id_module = m.id_module
GROUP BY m.id_module, m.intitule;

--QUESTION 15 | Pour chaque module, nom de la première évaluation et sa note maximale
-- tableau 2D : evaluations[ligne][colonne], col 2 = nom, col 3 = max
SELECT id_module, intitule,
       evaluations[1][2] AS nom_premiere_eval,
       evaluations[1][3] AS note_max
FROM vue_evals_module;

-- TYPES COMPOSITES 3.3
--QUESTION 16 | Type composite avec identifiant, nom, note max, note min
CREATE TYPE type_evaluation AS (
    id_evaluation integer,
    nom           varchar,
    note_max      numeric,
    note_min      numeric
);

--QUESTION 17 | Suppression de la vue de Q14
DROP VIEW vue_evals_module;

--QUESTION 18 | Recréation de la vue avec un tableau 1D d'éléments de type composite
CREATE VIEW vue_evals_module AS
WITH max_min AS (
    SELECT e.id_evaluation, e.nom, e.id_module,
           MAX(n.note / e.echelle * 20) AS max,
           MIN(n.note / e.echelle * 20) AS min
    FROM evaluation e
    JOIN notation n USING (id_evaluation)
    GROUP BY e.id_evaluation, e.id_module
)
SELECT m.id_module, m.intitule,
       array_agg(
           ROW(mm.id_evaluation, mm.nom, ROUND(mm.max::numeric, 1), ROUND(mm.min::numeric, 1))::type_evaluation
       ) AS evaluations
FROM module m
JOIN max_min mm ON mm.id_module = m.id_module
GROUP BY m.id_module, m.intitule;

--QUESTION 19 | Pour chaque module, nom de la première évaluation et sa note maximale (accès par nom de champ UDT)
SELECT id_module, intitule,
       (evaluations[1]).nom      AS nom_premiere_eval,
       (evaluations[1]).note_max AS note_max
FROM vue_evals_module;
