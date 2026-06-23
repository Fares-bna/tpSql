-- SÉANCE 4 - Dénormalisation avec PostgreSQL : Données JSON

-- 4.1 Génération de bulletins JSON

-- QUESTION 1 | Liste des évaluations avec id, nom, échelle et coefficient
SELECT id_evaluation, nom, echelle, coefficient
FROM evaluation
ORDER BY id_evaluation;

-- QUESTION 2 | Même chose mais la colonne nom est de type jsonb formatée {"nom": "nom_evaluation"}
SELECT id_evaluation,
       jsonb_build_object('nom', nom) AS nom,
       echelle,
       coefficient
FROM evaluation
ORDER BY id_evaluation;

-- QUESTION 3 | Liste des notes avec id_etudiant, id_module, note, échelle et coefficient
SELECT n.id_etudiant, e.id_module, n.note, e.echelle, e.coefficient
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 4 | Modules et étudiants avec le nombre d'évaluations de l'étudiant pour ce module
SELECT n.id_etudiant, e.id_module, COUNT(*) AS nb_notes
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
GROUP BY n.id_etudiant, e.id_module
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 5 | Même chose mais avec la moyenne sur 20 (pondérée par l'échelle et le coefficient), max 2 décimales
SELECT n.id_etudiant, e.id_module,
       ROUND(
           (SUM(n.note / e.echelle * 20 * e.coefficient) / SUM(e.coefficient))::numeric,
           2
       ) AS moyenne
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
GROUP BY n.id_etudiant, e.id_module
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 6 | Depuis Q4, tableau JSON d'un objet par évaluation (juste le nom formaté comme Q2) via jsonb_agg()
SELECT n.id_etudiant, e.id_module,
       jsonb_agg(jsonb_build_object('nom', e.nom)) AS tab_eval
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
GROUP BY n.id_etudiant, e.id_module
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 7 | Ajouter note, échelle et coefficient dans chaque objet JSON du tableau
SELECT n.id_etudiant, e.id_module,
       jsonb_agg(jsonb_build_object(
           'nom',         e.nom,
           'note',        n.note,
           'echelle',     e.echelle,
           'coefficient', e.coefficient
       )) AS tab_eval
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
GROUP BY n.id_etudiant, e.id_module
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 8 | Ajouter le nom du module et sa moyenne dans un objet JSON englobant le tableau d'évaluations
SELECT n.id_etudiant, e.id_module,
       jsonb_build_object(
           'nom',         m.intitule,
           'moyenne',     ROUND((SUM(n.note / e.echelle * 20 * e.coefficient) / SUM(e.coefficient))::numeric, 2),
           'evaluations', jsonb_agg(jsonb_build_object(
               'nom',         e.nom,
               'note',        n.note,
               'echelle',     e.echelle,
               'coefficient', e.coefficient
           ))
       ) AS tab_eval
FROM notation n
JOIN evaluation e ON n.id_evaluation = e.id_evaluation
JOIN module m ON m.id_module = e.id_module
GROUP BY n.id_etudiant, e.id_module, m.intitule
ORDER BY n.id_etudiant, e.id_module;

-- QUESTION 9 | Bulletin complet par étudiant : CTE de Q8 + jsonb_insert() pour nom/prénom + jsonb_agg() des modules
WITH bulletins_modules AS (
    SELECT n.id_etudiant, e.id_module,
           jsonb_build_object(
               'nom',         m.intitule,
               'moyenne',     ROUND((SUM(n.note / e.echelle * 20 * e.coefficient) / SUM(e.coefficient))::numeric, 2),
               'evaluations', jsonb_agg(jsonb_build_object(
                   'nom',         e.nom,
                   'note',        n.note,
                   'echelle',     e.echelle,
                   'coefficient', e.coefficient
               ))
           ) AS bulletin_module
    FROM notation n
    JOIN evaluation e ON n.id_evaluation = e.id_evaluation
    JOIN module m ON m.id_module = e.id_module
    GROUP BY n.id_etudiant, e.id_module, m.intitule
)
SELECT bm.id_etudiant,
       jsonb_insert(
           jsonb_build_object('nom', et.nom, 'prenom', et.prenom),
           '{modules}',
           jsonb_agg(bm.bulletin_module)
       ) AS bulletin
FROM bulletins_modules bm
JOIN etudiant et ON et.id_etudiant = bm.id_etudiant
GROUP BY bm.id_etudiant, et.nom, et.prenom
ORDER BY bm.id_etudiant;

-- QUESTION 10 | Vue bulletin_JSON correspondant à la requête précédente
CREATE VIEW bulletin_JSON AS
WITH bulletins_modules AS (
    SELECT n.id_etudiant, e.id_module,
           jsonb_build_object(
               'nom',         m.intitule,
               'moyenne',     ROUND((SUM(n.note / e.echelle * 20 * e.coefficient) / SUM(e.coefficient))::numeric, 2),
               'evaluations', jsonb_agg(jsonb_build_object(
                   'nom',         e.nom,
                   'note',        n.note,
                   'echelle',     e.echelle,
                   'coefficient', e.coefficient
               ))
           ) AS bulletin_module
    FROM notation n
    JOIN evaluation e ON n.id_evaluation = e.id_evaluation
    JOIN module m ON m.id_module = e.id_module
    GROUP BY n.id_etudiant, e.id_module, m.intitule
)
SELECT bm.id_etudiant,
       jsonb_insert(
           jsonb_build_object('nom', et.nom, 'prenom', et.prenom),
           '{modules}',
           jsonb_agg(bm.bulletin_module)
       ) AS bulletin
FROM bulletins_modules bm
JOIN etudiant et ON et.id_etudiant = bm.id_etudiant
GROUP BY bm.id_etudiant, et.nom, et.prenom;

-- QUESTION 11 | Affichage indenté (jsonb_pretty) du bulletin de l'étudiant 1
SELECT jsonb_pretty(bulletin)
FROM bulletin_JSON
WHERE id_etudiant = 1;
