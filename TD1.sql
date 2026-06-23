--QUESTION 1 | Pour visualiser toute la table film
SELECT * FROM film;

--QUESTION 2 | On affiche les 5 premiers films, ici j'ai decidé de les afficher par ordre alphabétique
SELECT * FROM film ORDER BY 3 LIMIT 5;

--QUESTION 3 | On affiche seulement le titre et le genre du film
SELECT titre, genre FROM film;

--QUESTION 4 | On utilise DISTINCT pour afficher les genre sans doublons
SELECT DISTINCT genre FROM film;

--QUESTION 5 | On utilise AS pour nommer la nouvelle colonne qui multiplie par 2 l'id film
SELECT id_film*2 AS id_film_fois2 FROM film;

--QUESTION 6 | On utilise concat() pour concatener le nom d'un film et son genre pour l'afficher
SELECT CONCAT(titre, ' ', genre) AS nom_et_genre FROM film;

--QUESTION 7 | LEFT(x,a) permet d'obtenir les x premières lettres (on part de la gauche) de l'attribut, on peut utiliser right() pour partir de la fin
SELECT LEFT (titre, 1) AS premiere_lettre FROM film;

-- 6. WHERE

--QUESTION 8 | Afficher les films ayant comme genre Drame
SELECT * FROM film WHERE genre = 'Drame'; 

--QUESTION 9 | On peut utiliser '>' car 2000 est un nombre (pas de guillemets ducoup)
SELECT * FROM film WHERE annee_production > 2000;

--QUESTION 10 | On utilise LIKE pour vérifier équivalent 
SELECT * FROM film WHERE titre LIKE 'A%';

--QUESTION 11 | IS NULL permet de cibler les attributs vides (ou nuls)
SELECT * FROM film WHERE genre IS NULL;

--QUESTION 12 | Jointure sur sur film avec personne sur une condition
SELECT * FROM film INNER JOIN personne ON film.id_realisateur = personne.id_personne;

--QUESTION 13 : Il faut d'abord effectuer la jointure pour permettre aux tables de se lier (joindre)

--QUESTION 14 | LEFT JOIN permet de garder les lignes de la première dont les correspondances avec la deuxième sont nulles
SELECT * FROM film LEFT JOIN personne ON film.id_realisateur = personne.id_personne;

--QUESTION 15 | On peut utiliser left join ou inner join
SELECT * FROM film LEFT JOIN personne ON film.id_realisateur = personne.id_personne;

--QUESTION 16 Car sinon ça deviendrait un INNER JOIN en éliminant les X null

--QUESTION 17 | On groupe par genre le COUNT, affichant donc chaque Genre et le nombre de films ayant ce genre
SELECT genre, COUNT(*) AS nb_films FROM film GROUP BY genre;

--QUESTION 18 | On ajoute à la requête d'avant un WHERE avant le GROUP BY;
SELECT genre, COUNT(*) AS nb_films FROM film WHERE annee_production > 2000 GROUP BY genre;
--QUESTION 19 | On fait HAVING sur le COUNT * pour sélectionner les genre ayant + de 2 films
SELECT genre, COUNT(*) AS nb_films FROM film GROUP BY genre HAVING COUNT(*) > 2;

--QUESTION 20 | ORDER BY effectue un tri par ordre alphabétique par défaut
SELECT * FROM film ORDER BY titre;

--QUESTION 21 
--21.1 
SELECT * FROM film ORDER BY genre;
--21.2 | On utilise DESC pour ordre décroissant et ASC pour ordre croissant (qui est aussi celui par défaut)
SELECT * FROM film ORDER BY titre;

--QUESTION 22 | On utilise ORDER BY annee_production DESC pour obtenir les plus récents puis LIMIT 3 pour limiter le SELECT aux 3 premiers
SELECT * FROM film ORDER BY annee_production DESC LIMIT 3;

--QUESTION 23 | On utilise COUNT *
SELECT COUNT(*) AS total FROM film;

--QUESTION 24 | On utilise MAX(annee_production)
SELECT MAX(annee_production) FROM film;

--QUESTION  25 | On associe DISTINCT et COUNT pour supprimer les doublons du compte
SELECT DISTINCT COUNT(genre) AS total_genre FROM film;

--QUESTION 26 | On utilise IN pour faire une sous-requête
SELECT * FROM personne WHERE id_personne IN ( SELECT id_acteur FROM jouer );

--QUESTION 27 | On utilise NOT IN pour obtenir l'inverse de la sous requête
SELECT * FROM personne WHERE id_personne NOT IN ( SELECT id_realisateur FROM film WHERE id_realisateur IS NOT NULL );