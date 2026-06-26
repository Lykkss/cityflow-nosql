# Modélisation Redis — CityFlow

## Schéma de clés

| Besoin | Structure | Clé | TTL | Commandes |
|--------|-----------|-----|-----|-----------|
| Disponibilité station | String | station:S001:available_bikes | 3600s | GET, INCR, DECR |
| Session utilisateur | Hash | cityflow:session:sess001 | 1800s | HSET, HGETALL, EXPIRE |
| Leaderboard mensuel | Sorted Set | cityflow:leaderboard:monthly | permanent | ZADD, ZREVRANGE, ZINCRBY |
| Rate limiting | String | cityflow:ratelimit:user:alice:2026062611 | 60s | INCR, GET |
| Blocage utilisateur | String | cityflow:blocked:user:thomas | 3600s | SET EX, GET |

## Justifications

### US-R1 — Disponibilités stations
Structure : String avec INCR/DECR atomique.
TTL 3600s : on accepte des données vieilles d'1h max.
Pattern Cache Aside : si GET renvoie null → requêter Cassandra → SET EX 3600.

### US-R2 — Sessions utilisateurs
Structure : Hash pour stocker plusieurs champs (userId, city, lastAction).
TTL 1800s renouvelé à chaque action via EXPIRE.
Séquence : HGETALL → vérifier TTL → EXPIRE 1800 → retourner données.

### US-R3 — Leaderboard mensuel
Structure : Sorted Set — parfait pour classements dynamiques.
Pas de TTL : réinitialisé manuellement chaque mois via RENAME + nouveau ZADD.
Commande unique pour le top 10 : ZREVRANGE 0 9 WITHSCORES.

### US-R4 — Rate limiting
Structure : String avec INCR atomique.
TTL 60s : fenêtre glissante par minute.
Clé : cityflow:ratelimit:user:{id}:{YYYYMMDDHH}
Si compteur > 100 →
