# Modélisation Neo4j — CityFlow

## Schéma du graphe

### Labels de nœuds
- :Station — une station de transport (code, name, type)
- :Line — une ligne de transport (number, color, type)

### Types de relations
- :CONNECTED_TO {duration_min, line} — connexion entre deux stations
- :SERVES {order} — une ligne dessert une station dans un ordre donné

### Contraintes d'unicité
- Station.code IS UNIQUE
- Line.number IS UNIQUE

## Choix de modélisation

### Un seul label :Station
Justification : toutes les stations partagent les mêmes propriétés
(code, name, type). Le type (metro, tram, bus) est une propriété,
pas un label séparé. On évite la multiplication de labels.

### Lignes comme nœuds :Line
Justification : une ligne a son propre identité, ses propres
propriétés, et des relations SERVES vers les stations.
C'est un nœud, pas une propriété de la relation CONNECTED_TO.

### Bidirectionnalité des connexions
Justification : les métros circulent dans les deux sens.
On crée deux relations CONNECTED_TO (A→B et B→A) pour
permettre shortestPath sans contrainte de direction.

### US-N4 — Sans correspondance
Modélisation via :SERVES avec order.
Une ligne directe = une :Line qui SERVES les deux stations.

## Index créés
- station_code (unicité)
- line_number (unicité)
