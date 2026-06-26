# Modélisation Cassandra — CityFlow

## Philosophie
Cassandra = modélisation orientée requêtes.
Une table par requête principale. Pas de JOIN, pas de sous-requêtes.
La partition key détermine la distribution des données sur le cluster.

## Keyspace
cityflow — SimpleStrategy, replication_factor: 1 (dev local)

## Tables

### trips_by_user
Partition key: user_id
Clustering key: trip_date DESC, trip_id ASC
Cas d'usage: "Tous les trajets d'un utilisateur, du plus récent au plus ancien"

### trips_by_date
Partition key: trip_date
Clustering key: trip_id ASC
Cas d'usage: "Tous les trajets d'une journée donnée"

### station_availability
Partition key: station_id
Clustering key: recorded_at DESC
Cas d'usage: "Historique des disponibilités d'une station, du plus récent"

### event_logs
Partition key: log_date
Clustering key: event_time DESC, event_id ASC
Cas d'usage: "Tous les événements d'une journée, du plus récent"

## Choix de modélisation

### Pourquoi trips_by_user ET trips_by_date ?
Cassandra ne fait pas de JOIN. Si on veut requêter par user_id
ET par date, il faut deux tables. C'est la dénormalisation
intentionnelle de Cassandra : on duplique les données pour
servir chaque requête efficacement.

### Pourquoi CLUSTERING ORDER BY DESC ?
Pour les time-series (logs, disponibilités, trajets), on veut
toujours les données les plus récentes en premier.
Le tri est stocké physiquement — LIMIT 1 = dernière valeur
en O(1) sans scan.

### ALLOW FILTERING
À éviter en production. Signale une requête qui ne peut pas
utiliser la partition key — scan complet de la table.
Acceptable uniquement en développement ou sur de petits volumes.

## Index créés
Aucun index secondaire — les tables sont conçues pour éviter
les requêtes sans partition key.
