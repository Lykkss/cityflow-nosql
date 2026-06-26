# CityFlow — Architecture de persistance polyglotte

> Plateforme de mobilité urbaine multimodale pour la métropole de Lyon.  
> Projet fil rouge — Module NoSQL B3 INFO — Ynov Campus Lyon 2025/2026

---

## Équipe

| Nom | Rôle |
|-----|------|
| Lisa Quaglieri | Cloud Security Engineer — Architecture & implémentation |

---

## Contexte

CityFlow est une startup fictive qui développe une plateforme unifiée de mobilité urbaine.
L'objectif est de permettre à un utilisateur de planifier, réserver et suivre un trajet
multimodal (transports en commun, covoiturage, vélos en libre-service) depuis une seule application.

La direction technique a choisi une **architecture de persistance polyglotte** :
chaque type de donnée est stocké dans la base la mieux adaptée à son usage.

---

## Stack technique

| Base | Version | Rôle | Port | Interface |
|------|---------|------|------|-----------|
| MongoDB | 7.0 | Profils, trajets, véhicules | 27018 | mongo-express :8082 |
| Redis | 7-alpine | Cache, sessions, leaderboard | 6379 | redis-commander :8083 |
| Cassandra | 4.1 | Logs, time-series, événements | 9042 | cassandra-web :9091 |
| Neo4j | 5-community | Réseau de transport, itinéraires | 7687 | Neo4j Browser :7474 |

---

## Lancement en une commande

```bash
# 1. Cloner le dépôt
git clone 
cd cityflow-nosql

# 2. Copier les variables d'environnement
cp .env.example .env

# 3. Lancer toute la stack
docker compose up -d

# 4. Vérifier que les 7 conteneurs sont Up
docker compose ps
```

> Cassandra met environ 60-90 secondes à démarrer. Attendez que
> `cityflow-cassandra` passe à l'état `healthy` avant d'interagir.

---

## Interfaces d'administration

| Interface | URL | Identifiants |
|-----------|-----|--------------|
| Mongo Express | http://localhost:8082 | student / nosql2025 |
| Redis Commander | http://localhost:8083 | student / nosql2025 |
| Neo4j Browser | http://localhost:7474 | neo4j / cityflow2025 |
| Cassandra Web | http://localhost:9091 | — |

---

## Structure du projet
cityflow-nosql/

├── docker-compose.yml          # Orchestration des 4 bases

├── .env.example                # Variables d'environnement type

├── README.md                   # Ce fichier

├── docs/

│   ├── architecture.md         # Schéma global + justifications

│   ├── modelisation-mongodb.md # Collections + choix embed/ref

│   ├── modelisation-redis.md   # Clés + structures + naming

│   ├── modelisation-cassandra.md # Tables + partition keys

│   └── modelisation-neo4j.md  # Nœuds, relations, propriétés

├── seed/

│   ├── mongodb/init.js         # Création collections + données

│   ├── redis/init.sh           # Peuplement initial Redis

│   ├── cassandra/init.cql      # Création keyspace + tables

│   └── neo4j/init.cypher       # Création nœuds et relations

└── queries/

├── mongodb-queries.md      # User stories M1-M4

├── redis-queries.md        # User stories R1-R4

├── cassandra-queries.md    # User stories C1-C4

└── neo4j-queries.md        # User stories N1-N4

---

## User Stories implémentées

### MongoDB — Données métier riches
| ID | Story | Requête |
|----|-------|---------|
| US-M1 | Profil + 10 derniers trajets d'un utilisateur | `find` + `sort` + `limit` |
| US-M2 | Véhicules disponibles par type et arrondissement | `find` avec filtre composé |
| US-M3 | Statistiques agrégées (trajets/jour, distance moyenne, top 5) | `aggregate` + `$group` + `$lookup` |
| US-M4 | Recherche full-text sur les commentaires | Index `text` + `$text` + `$search` |

### Redis — Temps réel et performance
| ID | Story | Structure |
|----|-------|-----------|
| US-R1 | Disponibilités temps réel des stations | String + TTL 3600s |
| US-R2 | Sessions utilisateurs 30 min renouvelées | Hash + EXPIRE 1800s |
| US-R3 | Top 10 conducteurs du mois | Sorted Set + ZREVRANGE |
| US-R4 | Rate limiting 100 req/min par utilisateur | String + INCR + TTL 60s |

### Cassandra — Données massives et time-series
| ID | Story | Table |
|----|-------|-------|
| US-C1 | Historique passages d'une station sur une période | `station_availability` |
| US-C2 | Enregistrement massif d'événements | `event_logs` |
| US-C3 | Connexions d'un utilisateur sur 30 jours | `trips_by_user` |
| US-C4 | Évolution journalière des passages | `trips_by_date` |

### Neo4j — Relations et itinéraires
| ID | Story | Requête |
|----|-------|---------|
| US-N1 | Plus court chemin entre deux stations | `shortestPath` + Dijkstra |
| US-N2 | Stations accessibles en moins de 15 minutes | `CONNECTED_TO*1..6` + `reduce` |
| US-N3 | Stations hubs (les plus connectées) | `count` relations |
| US-N4 | Itinéraire sans correspondance | `:SERVES` sur même ligne |

---

## Choix d'architecture

| Besoin | SQL seul | Solution CityFlow |
|--------|----------|-------------------|
| Profils imbriqués | Multiples JOINs | MongoDB — 1 requête |
| Disponibilités temps réel | Polling (~100ms) | Redis (<1ms) |
| Millions d'événements/jour | Saturation | Cassandra — scalabilité linéaire |
| Plus court chemin réseau | JOINs récursifs | Neo4j — shortestPath natif |

---

## Documentation

- [Architecture globale](docs/architecture.md)
- [Modélisation MongoDB](docs/modelisation-mongodb.md)
- [Modélisation Redis](docs/modelisation-redis.md)
- [Modélisation Cassandra](docs/modelisation-cassandra.md)
- [Modélisation Neo4j](docs/modelisation-neo4j.md)
