# Architecture polyglotte CityFlow

## Vision générale

CityFlow est une plateforme de mobilité urbaine multimodale pour la métropole de Lyon.
L'architecture adopte une persistance polyglotte : chaque type de donnée est stocké
dans la base la mieux adaptée à son usage.

## Schéma global

bashnano ~/Documents/ynov/B3/nosql/cityflow-nosql/docs/architecture.md
Colle :
markdown# Architecture polyglotte CityFlow

## Vision générale

CityFlow est une plateforme de mobilité urbaine multimodale pour la métropole de Lyon.
L'architecture adopte une persistance polyglotte : chaque type de donnée est stocké
dans la base la mieux adaptée à son usage.

## Schéma global
┌─────────────────────────────────────────────────────────────┐

│                    CLIENT CITYFLOW                          │

└───────────────┬─────────────┬───────────────┬───────────────┘

│              │              │              │

▼              ▼              ▼              ▼

┌─────────┐ ┌───────┐  ┌───────────┐  ┌──────────┐

│ MongoDB │ │ Redis │  │ Cassandra │  │  Neo4j   │

│  :27018 │ │ :6379 │  │   :9042   │  │  :7687   │

└─────────┘ └───────┘  └───────────┘  └──────────┘

Profils     Cache       Time-series    Réseau de

Trajets     Sessions    Logs           transport

Véhicules   Leaderboard Événements     Itinéraires

## Rôle de chaque base

### MongoDB — Données métier riches
**Pourquoi MongoDB ?**
Les profils utilisateurs et les trajets sont des entités riches avec des
sous-documents imbriqués (adresses, préférences, étapes de trajet).
MongoDB permet le schéma flexible et les requêtes ad-hoc sans JOIN.
Une requête MongoDB remplace 3-4 jointures SQL.

**Ce qu'elle stocke :**
- Collection `users` : profils avec adresses et préférences embarquées
- Collection `trips` : trajets avec références vers users et vehicles
- Collection `vehicles` : véhicules avec localisation

**Trade-off accepté :**
Cohérence éventuelle sur certaines opérations multi-documents.
Acceptable car les profils ne nécessitent pas de transactions ACID strictes.

---

### Redis — Temps réel et performance
**Pourquoi Redis ?**
Latence sub-milliseconde indispensable pour l'affichage temps réel
des disponibilités. Les sessions et le leaderboard nécessitent des
structures spécialisées (TTL automatique, Sorted Sets).

**Ce qu'elle stocke :**
- `station:S001:available_bikes` : disponibilités avec TTL 3600s
- `cityflow:session:*` : sessions utilisateurs avec TTL 1800s
- `cityflow:leaderboard:monthly` : classement conducteurs (Sorted Set)
- `cityflow:ratelimit:*` : compteurs rate limiting avec TTL 60s

**Trade-off accepté :**
Données volatiles en RAM. Perte acceptable en cas de crash
(les données sont régénérées depuis Cassandra/MongoDB).

---

### Cassandra — Volumes massifs et time-series
**Pourquoi Cassandra ?**
1000+ stations × 1 mesure/min = millions d'événements/jour.
Cassandra est optimisé pour les écritures massives et les requêtes
time-series par partition key. Scalabilité horizontale linéaire.

**Ce qu'elle stocke :**
- `trips_by_user` : historique trajets par utilisateur (partition = user_id)
- `trips_by_date` : trajets par journée (partition = trip_date)
- `station_availability` : historique disponibilités (partition = station_id)
- `event_logs` : logs d'événements (partition = log_date)

**Trade-off accepté :**
Pas de JOIN, une table par requête. Dénormalisation intentionnelle.
ALLOW FILTERING interdit en production sur grands volumes.

---

### Neo4j — Réseau et itinéraires
**Pourquoi Neo4j ?**
Un réseau de transport est naturellement un graphe. Les requêtes
de plus court chemin (shortestPath) et de traversée multi-niveaux
sont impossibles efficacement en SQL (N jointures pour N niveaux).
Neo4j traverse en O(1) par nœud grâce à l'index-free adjacency.

**Ce qu'elle stocke :**
- Nœuds `:Station` : 15 stations de la métropole lyonnaise
- Nœuds `:Line` : 4 lignes de métro (A, B, C, D)
- Relations `:CONNECTED_TO` : connexions avec durée en minutes
- Relations `:SERVES` : lignes desservant les stations avec ordre

**Trade-off accepté :**
Scalabilité verticale (moins adapté aux très grands volumes que Cassandra).
Acceptable car le réseau de transport est de taille finie et stable.

---

## Interfaces d'administration

| Interface | URL | Identifiants |
|-----------|-----|--------------|
| Mongo Express | http://localhost:8082 | student / nosql2025 |
| Redis Commander | http://localhost:8083 | student / nosql2025 |
| Neo4j Browser | http://localhost:7474 | neo4j / cityflow2025 |
| Cassandra Web | http://localhost:9091 | — |

## Lancement

```bash
git clone <repo_url>
cd cityflow-nosql
cp .env.example .env
docker compose up -d
```

## Justification de l'architecture polyglotte

| Besoin | SQL seul | Polyglotte CityFlow |
|--------|----------|---------------------|
| Profils imbriqués | Multiples JOINs lents | MongoDB — 1 requête |
| Disponibilités temps réel | Polling BDD (~100ms) | Redis (<1ms) |
| Millions d'événements/jour | Saturation disque | Cassandra — scalabilité linéaire |
| Plus court chemin réseau | N JOINs récursifs impossibles | Neo4j — shortestPath natif |

**Conclusion :** Une base SQL unique pourrait tout faire, mais avec des
performances et une complexité de requête inacceptables pour les cas
d'usage temps réel et les volumes de CityFlow. L'architecture polyglotte
permet d'utiliser le bon outil pour le bon besoin, au prix d'une complexité
opérationnelle maîtrisée via Docker Compose.
