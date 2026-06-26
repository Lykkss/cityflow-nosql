# Mes commandes Redis — TP NoSQL B3

## Niveau 1 — Strings et compteurs

### Commande 1 — Compteur de likes pour le post 100
SET post:100:likes 0
Résultat: OK

### Commande 2 — Incrémenter 5 fois
INCR post:100:likes (x5)
Résultat: 1, 2, 3, 4, 5

### Commande 3 — Lire la valeur
GET post:100:likes
Résultat: "5"

### Commande 4 — Flag maintenance avec TTL 60s
SET maintenance:mode 1 EX 60
Résultat: OK — disparaît automatiquement après 60s

### Commande 5 — TTL restant
TTL maintenance:mode
Résultat: 53 (secondes restantes)

---

## Niveau 2 — Hashes

### Commande 6 — Profil produit
HSET product:101 nom "Vélo B'Twin" prix 299 stock 15 categorie "mobilite"
Résultat: 4 (4 champs créés)

### Commande 7 — Incrémenter le stock de 10
HINCRBY product:101 stock 10
Résultat: 25

### Commande 8 — Décrémenter le stock de 3
HINCRBY product:101 stock -3
Résultat: 22

### Commande 9 — Récupérer nom et prix uniquement
HMGET product:101 nom prix
Résultat: 1) "Vélo B'Twin" 2) "299"

---

## Niveau 3 — Lists

### Commande 10 — File de 5 tâches
RPUSH tasks:queue "envoyer_email_alice"
RPUSH tasks:queue "generer_rapport"
RPUSH tasks:queue "notifier_karim"
RPUSH tasks:queue "sync_mongodb"
RPUSH tasks:queue "cleanup_sessions"
Résultat: 1, 2, 3, 4, 5

### Commande 11 — Consommer les 2 premières (FIFO)
LPOP tasks:queue → "envoyer_email_alice"
LPOP tasks:queue → "generer_rapport"

### Commande 12 — Ce qu'il reste
LRANGE tasks:queue 0 -1
Résultat: 1) "notifier_karim" 2) "sync_mongodb" 3) "cleanup_sessions"

### Commande 13 — Limiter aux 100 dernières
LTRIM tasks:queue 0 99
Résultat: OK

---

## Niveau 4 — Sets

### Commande 14 — Tags de 3 utilisateurs
SADD user:4:tags "premium" "fr" "verified"
SADD user:5:tags "fr" "eco-friendly" "newbie"
SADD user:6:tags "premium" "eco-friendly" "fr"

### Commande 15 — Tags communs aux 3
SINTER user:4:tags user:5:tags user:6:tags
Résultat: 1) "fr"

### Commande 16 — Tags de user:4 absents chez user:5
SDIFF user:4:tags user:5:tags
Résultat: 1) "premium" 2) "verified"

### Commande 17 — Tag aléatoire de user:4
SRANDMEMBER
Résultat: "premium" (aléatoire)

---

## Niveau 5 — Sorted Sets

### Commande 18 — 10 joueurs dans leaderboard:season1
ZADD leaderboard:season1 2100 "carol"
ZADD leaderboard:season1 1800 "bob"
ZADD leaderboard:season1 1750 "dave"
ZADD leaderboard:season1 1500 "alice"
ZADD leaderboard:season1 1300 "eve"
ZADD leaderboard:season1 1100 "frank"
ZADD leaderboard:season1 950 "grace"
ZADD leaderboard:season1 800 "henry"
ZADD leaderboard:season1 650 "iris"
ZADD leaderboard:season1 400 "jack"

### Commande 19 — Top 5 par score décroissant
ZREVRANGE leaderboard:season1 0 4 WITHSCORES
Résultat: carol(2100), bob(1800), dave(1750), alice(1500), eve(1300)

### Commande 20 — Joueurs entre 1000 et 2000 points
ZRANGEBYSCORE leaderboard:season1 1000 2000 WITHSCORES
Résultat: frank(1100), eve(1300), alice(1500), dave(1750), bob(1800)

### Commande 21 — Rang de carol
ZREVRANK leaderboard:season1 "carol"
Résultat: 0 (1ère place)

### Commande 22 — Joueurs avec plus de 1500 points
ZCOUNT leaderboard:season1 1500 +inf
Résultat: 4

---

## Bonus

### Commande 23 — Union de deux Sorted Sets
ZUNIONSTORE leaderboard:combined 2 leaderboard:season1 leaderboard:weekly
Résultat: 20 (clés dans le nouveau set)

### Commande 24 — Renommer une clé
RENAME leaderboard:season1 leaderboard:archive:season1
Résultat: OK

---

## Partie 8 — Leaderboard hebdomadaire CityFlow

### Leaderboard avec 15 utilisateurs
ZADD leaderboard:weekly:trips 95 "user:1" ... (x15)

### Requêtes leaderboard
- Top 5 : ZREVRANGE leaderboard:weekly:trips 0 4 WITHSCORES
  Résultat: user:1(98), user:2(88), user:3(76), user:4(71), user:5(65)
- 5 moins actifs : ZRANGE leaderboard:weekly:trips 0 4 WITHSCORES
  Résultat: user:15(5), user:14(9), user:13(15), user:12(21), user:11(27)
- ZINCRBY leaderboard:weekly:trips 3 "user:1" → 98
- ZREVRANK → 0 (toujours 1er)
- ZCOUNT 50 +inf → 7
- ZRANGEBYSCORE 30 70 → user:10 à user:5
- ZCARD → 15

### Archivage hebdomadaire
RENAME leaderboard:weekly:trips leaderboard:archive:2025-W26
EXISTS leaderboard:archive:2025-W26 → 1
EXISTS leaderboard:weekly:trips → 0

---

## Partie 8 — Cache des stations

### Stations avec TTL 3600s
SET station:S001:available_bikes 12 EX 3600 (x8 stations)

### Requêtes cache
- GET station:S001:available_bikes → "12"
- MGET S001 S002 S003 → 12, 8, 15
- DECR station:S002:available_bikes → 7 (location)
- INCR station:S005:available_bikes → 10 (retour)
- TTL station:S001:available_bikes → 3426s

### Observation expiration
TTL -2 = clé expirée (cache miss)
→ L'application doit régénérer la clé depuis la base de référence

### Pattern Cache Aside
1. GET station:S001:available_bikes
2. Si null → requêter la base
3. SET station:S001:available_bikes {valeur} EX 3600
4. Retourner la valeur
