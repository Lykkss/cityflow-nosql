#!/bin/bash
# Seed Redis CityFlow
# Usage : bash seed/redis/init.sh

REDIS="docker exec cityflow-redis redis-cli -a cityflow2025"

echo "Nettoyage..."
$REDIS FLUSHDB

echo "Stations..."
$REDIS SET station:S001:available_bikes 12 EX 3600
$REDIS SET station:S001:available_scooters 5 EX 3600
$REDIS SET station:S002:available_bikes 8 EX 3600
$REDIS SET station:S002:available_scooters 3 EX 3600
$REDIS SET station:S003:available_bikes 15 EX 3600
$REDIS SET station:S003:available_scooters 7 EX 3600
$REDIS SET station:S004:available_bikes 4 EX 3600
$REDIS SET station:S005:available_bikes 9 EX 3600
$REDIS SET station:S006:available_bikes 11 EX 3600
$REDIS SET station:S007:available_bikes 6 EX 3600
$REDIS SET station:S008:available_bikes 14 EX 3600

echo "Sessions..."
$REDIS HSET cityflow:session:sess001 userId "user:alice" firstName "Alice" city "Lyon" lastAction "2026-06-26T11:00:00Z"
$REDIS EXPIRE cityflow:session:sess001 1800
$REDIS HSET cityflow:session:sess002 userId "user:karim" firstName "Karim" city "Lyon" lastAction "2026-06-26T10:55:00Z"
$REDIS EXPIRE cityflow:session:sess002 1800

echo "Leaderboard..."
$REDIS ZADD cityflow:leaderboard:monthly 98 "user:alice"
$REDIS ZADD cityflow:leaderboard:monthly 87 "user:karim"
$REDIS ZADD cityflow:leaderboard:monthly 76 "user:thomas"
$REDIS ZADD cityflow:leaderboard:monthly 71 "user:nadia"
$REDIS ZADD cityflow:leaderboard:monthly 65 "user:amara"
$REDIS ZADD cityflow:leaderboard:monthly 58 "user:pierre"
$REDIS ZADD cityflow:leaderboard:monthly 52 "user:lea"
$REDIS ZADD cityflow:leaderboard:monthly 45 "user:sofia"
$REDIS ZADD cityflow:leaderboard:monthly 38 "user:julien"
$REDIS ZADD cityflow:leaderboard:monthly 32 "user:clara"

echo "Rate limiting..."
$REDIS SET cityflow:ratelimit:user:alice:2026062611 45 EX 60
$REDIS SET cityflow:ratelimit:user:karim:2026062611 87 EX 60

echo "Seed Redis terminé ✓"
$REDIS DBSIZE
