# Requêtes Neo4j — CityFlow

## US-N1 : Plus court chemin entre 2 stations

// En nombre de stations
MATCH path = shortestPath(
  (start:Station {name:'Bellecour'})-[:CONNECTED_TO*]-(end:Station {name:'Croix-Rousse'})
)
RETURN [n IN nodes(path) | n.name] AS itineraire, length(path) AS nb_stations

// En durée (Dijkstra)
MATCH (start:Station {name:'Bellecour'}), (end:Station {name:'Croix-Rousse'})
CALL apoc.algo.dijkstra(start, end, 'CONNECTED_TO>', 'duration_min')
YIELD path, weight
RETURN [n IN nodes(path) | n.name] AS itineraire, weight AS duree_totale_min

---

## US-N2 : Stations accessibles en moins de 15 minutes

MATCH path = (start:Station {name:'Bellecour'})-[:CONNECTED_TO*1..6]-(end:Station)
WHERE start <> end
WITH end, reduce(total = 0, r IN relationships(path) | total + r.duration_min) AS duree
WHERE duree < 15
RETURN DISTINCT end.name, min(duree) AS duree_min
ORDER BY duree_min ASC

---

## US-N3 : Stations hubs

MATCH (s:Station)-[:CONNECTED_TO]-()
RETURN s.name, count(*) AS nb_connexions
ORDER BY nb_connexions DESC
LIMIT 5

---

## US-N4 : Itinéraire sans correspondance

MATCH (start:Station {name:'Bellecour'}), (end:Station {name:'Cordeliers'})
MATCH (l:Line)-[:SERVES]->(start)
MATCH (l)-[:SERVES]->(end)
RETURN l.number AS ligne, "Trajet direct sans correspondance" AS message
