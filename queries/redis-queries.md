# Requêtes Redis — CityFlow

## US-R1 : Disponibilité station S001

// Cache hit
GET station:S001:available_bikes
GET station:S001:available_scooters

// Louer un vélo (décrémenter)
DECR station:S001:available_bikes

// Rendre un vélo (incrémenter)
INCR station:S001:available_bikes

// Cache miss → recréer avec TTL
SET station:S001:available_bikes 12 EX 3600

---

## US-R2 : Session 30 min renouvelée

// Vérifier existence session
EXISTS cityflow:session:sess001

// Lire les données
HGETALL cityflow:session:sess001

// Renouveler le TTL à chaque action
EXPIRE cityflow:session:sess001 1800

// Vérifier TTL restant
TTL cityflow:session:sess001

---

## US-R3 : Top 10 conducteurs du mois

ZREVRANGE cityflow:leaderboard:monthly 0 9 WITHSCORES

// Incrémenter après un trajet
ZINCRBY cityflow:leaderboard:monthly 1 "user:alice"

// Réinitialisation mensuelle
RENAME cityflow:leaderboard:monthly cityflow:leaderboard:archive:2026-06

---

## US-R4 : Rate limiting 100 req/min

// Incrémenter le compteur
INCR cityflow:ratelimit:user:alice:2026062611

// Fixer TTL si nouvelle clé (première requête de la minute)
EXPIRE cityflow:ratelimit:user:alice:2026062611 60

// Vérifier le seuil
GET cityflow:ratelimit:user:alice:2026062611

// Bloquer si > 100
SET cityflow:blocked:user:thomas 1 EX 3600

// Vérifier si bloqué
GET cityflow:blocked:user:thomas
