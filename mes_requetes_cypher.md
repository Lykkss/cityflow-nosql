# Mes requêtes Cypher — TP NoSQL B3

## Niveau 1 — MATCH simples

### Requête 1 — Utilisateurs de plus de 25 ans
MATCH (u:User)
WHERE u.age > 25
RETURN u.name, u.age
ORDER BY u.age DESC

### Requête 2 — Utilisateurs de Lyon OU Villeurbanne
MATCH (u:User)
WHERE u.city = "Lyon" OR u.city = "Villeurbanne"
RETURN u.name, u.city

### Requête 3 — Compter utilisateurs et films
MATCH (u:User) WITH count(u) AS users
MATCH (m:Movie) RETURN users, count(m) AS movies
Résultat: 10 users, 8 movies

### Requête 4 — Films de SF triés par année
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre {name: "SF"})
RETURN m.title, m.year
ORDER BY m.year ASC

---

## Niveau 2 — Relations simples

### Requête 5 — Amis directs de Carol
MATCH (carol:User {name: "Carol"})-[:FRIEND_OF]-(friend)
RETURN friend.name, friend.city

### Requête 6 — Nombre d'amis par utilisateur
MATCH (u:User)
WITH u, size((u)-[:FRIEND_OF]-()) AS nb_amis
RETURN u.name, nb_amis
ORDER BY nb_amis DESC

### Requête 7 — Films notés par Bob
MATCH (bob:User {name: "Bob"})-[r:LIKES]->(m:Movie)
RETURN m.title, r.rating

### Requête 8 — Note moyenne d'Inception
MATCH (m:Movie {title: "Inception"})<-[r:LIKES]-()
RETURN m.title, avg(r.rating) AS note_moyenne

---

## Niveau 3 — Traversées à 2 niveaux

### Requête 9 — Amis d'amis d'Alice (profondeur 2)
MATCH (alice:User {name: "Alice"})-[:FRIEND_OF*2]-(fof)
WHERE fof <> alice
RETURN DISTINCT fof.name

### Requête 10 — Films aimés par amis d'Alice qu'elle n'a pas notés
MATCH (alice:User {name: "Alice"})-[:FRIEND_OF]-(friend)-[:LIKES]->(m:Movie)
WHERE NOT (alice)-[:LIKES]->(m)
RETURN DISTINCT m.title

### Requête 11 — Genres aimés par chaque utilisateur
MATCH (u:User)-[:LIKES]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN u.name, collect(DISTINCT g.name) AS genres

---

## Niveau 4 — Agrégations

### Requête 12 — Top 3 films les plus populaires
MATCH (m:Movie)<-[:LIKES]-()
RETURN m.title, count(*) AS nb_likes
ORDER BY nb_likes DESC
LIMIT 3

### Requête 13 — Note moyenne par film
MATCH (m:Movie)<-[r:LIKES]-()
RETURN m.title, avg(r.rating) AS note_moyenne
ORDER BY note_moyenne DESC

### Requête 14 — Utilisateurs par ville
MATCH (u:User)
RETURN u.city, count(u) AS nb_users
ORDER BY nb_users DESC

### Requête 15 — Utilisateurs ayant noté au moins 3 films
MATCH (u:User)-[:LIKES]->(m:Movie)
WITH u, count(m) AS nb_films
WHERE nb_films >= 3
RETURN u.name, nb_films
ORDER BY nb_films DESC

---

## Niveau 5 — Recommandations

### Requête 16 — Utilisateurs avec 2+ amis communs avec Alice
MATCH (alice:User {name: "Alice"})-[:FRIEND_OF]-(friend)-[:FRIEND_OF]-(suggest)
WHERE NOT (alice)-[:FRIEND_OF]-(suggest)
AND alice <> suggest
RETURN suggest.name, count(DISTINCT friend) AS amis_communs
ORDER BY amis_communs DESC

### Requête 17 — Films non notés par Alice, notés 4+ par 2+ amis
MATCH (alice:User {name: "Alice"})-[:FRIEND_OF]-(friend)-[r:LIKES]->(m:Movie)
WHERE NOT (alice)-[:LIKES]->(m)
AND r.rating >= 4
WITH m, count(DISTINCT friend) AS nb_amis
WHERE nb_amis >= 2
RETURN m.title, nb_amis
ORDER BY nb_amis DESC

### Requête 18 — Films aimés par plus de 3 utilisateurs
MATCH (u:User)-[r:LIKES]->(m:Movie)
WITH m, count(DISTINCT u) AS nb_users, avg(r.rating) AS note_moy
WHERE nb_users > 3
RETURN m.title, nb_users, note_moy
ORDER BY nb_users DESC

---

## Niveau 6 — Bonus

### Requête 19 — Utilisateur le plus connecté
MATCH (u:User)-[:FRIEND_OF]-()
RETURN u.name, count(*) AS nb_amis
ORDER BY nb_amis DESC
LIMIT 1

### Requête 20 — Clique de 3 utilisateurs tous amis
MATCH (a:User)-[:FRIEND_OF]-(b:User)-[:FRIEND_OF]-(c:User)-[:FRIEND_OF]-(a)
WHERE a.name < b.name AND b.name < c.name
RETURN a.name, b.name, c.name

---

## Partie 9 — Réseau de transport

### Requête 1 — Stations connectées à Bellecour
MATCH (b:Station {name:'Bellecour'})-[:CONNECTED_TO]-(s)
RETURN s.name

### Requête 2 — Durée Bellecour → Cordeliers
MATCH (b:Station {name:'Bellecour'})-[r:CONNECTED_TO]-(c:Station {name:'Cordeliers'})
RETURN r.duration_min AS duree_min

### Requête 3 — Plus court chemin Bellecour → Croix-Rousse
MATCH path = shortestPath(
  (b:Station {name:'Bellecour'})-[:CONNECTED_TO*]-(r:Station {name:'Croix-Rousse'})
)
RETURN path, length(path) AS nb_stations

### Requête 4 — Chemin sous forme de liste
MATCH path = shortestPath(
  (b:Station {name:'Bellecour'})-[:CONNECTED_TO*]-(r:Station {name:'Croix-Rousse'})
)
RETURN [n IN nodes(path) | n.name] AS itineraire

### Requête 5 — Chemins de longueur 3
MATCH path = (b:Station {name:'Bellecour'})-[:CONNECTED_TO*3]-(ch:Station {name:'Charpennes'})
RETURN [n IN nodes(path) | n.name] AS itineraire

### Requête 6 — Itinéraire le plus rapide (Dijkstra)
MATCH (start:Station {name:'Bellecour'}), (end:Station {name:'Croix-Rousse'})
CALL apoc.algo.dijkstra(start, end, 'CONNECTED_TO>', 'duration_min')
YIELD path, weight
RETURN [n IN nodes(path) | n.name] AS itineraire, weight AS duree_totale_min

### Requête 7 — Stations accessibles en moins de 3 sauts
MATCH (b:Station {name:'Bellecour'})-[:CONNECTED_TO*1..3]-(s:Station)
RETURN DISTINCT s.name

### Requête 8 — Stations accessibles en moins de 10 minutes
MATCH path = (b:Station {name:'Bellecour'})-[:CONNECTED_TO*1..5]-(s:Station)
WHERE s.name <> 'Bellecour'
WITH s, reduce(total = 0, r IN relationships(path) | total + r.duration_min) AS duree
WHERE duree < 10
RETURN DISTINCT s.name, min(duree) AS duree_min
ORDER BY duree_min ASC

