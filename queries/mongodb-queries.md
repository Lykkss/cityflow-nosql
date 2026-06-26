# Requêtes MongoDB — CityFlow

## US-M1 : Profil + 10 derniers trajets d'un utilisateur

// Étape 1 : profil
db.users.findOne({"firstName": "Alice"})

// Étape 2 : 10 derniers trajets
db.trips.find(
  {"userId": ObjectId('6a3e3cbecab41eee949df8ad')},
  {"date": 1, "distance": 1, "comment": 1, "_id": 0}
).sort({"date": -1}).limit(10)

Résultat : 5 trajets d'Alice, triés du plus récent au plus ancien.
Choix : 2 requêtes séparées (profil + trajets) car les trajets sont
référencés — embedding aurait explosé le document sur le long terme.

---

## US-M2 : Véhicules d'un type donné dans un arrondissement

db.vehicles.find(
  {"type": "scooter", "status": "available", "location.arrondissement": "Lyon 3"},
  {"model": 1, "status": 1, "location": 1, "_id": 0}
)

Résultat : Peugeot Django (Lyon 3, available)
Index suggéré : { type: 1, status: 1, "location.arrondissement": 1 }

---

## US-M3 : Statistiques globales

// Trajets par jour + distance moyenne
db.trips.aggregate([
  {"$group": {
    "_id": {"$dateToString": {"format": "%Y-%m-%d", "date": "$date"}},
    "nbTrajets": {"$sum": 1},
    "distanceMoyenne": {"$avg": "$distance"}
  }},
  {"$sort": {"_id": 1}}
])

// Top 5 conducteurs
db.trips.aggregate([
  {"$group": {
    "_id": "$userId",
    "nbTrajets": {"$sum": 1}
  }},
  {"$sort": {"nbTrajets": -1}},
  {"$limit": 5},
  {"$lookup": {
    "from": "users",
    "localField": "_id",
    "foreignField": "_id",
    "as": "user"
  }},
  {"$project": {
    "nbTrajets": 1,
    "firstName": {"$arrayElemAt": ["$user.firstName", 0]}
  }}
])

Résultat top 5 : Alice (5), Karim (5), Thomas (3), Amara (2), Léa (2)

---

## US-M4 : Recherche full-text sur les commentaires

// Création de l'index (à faire une seule fois)
db.trips.createIndex({"comment": "text"})

// Recherche
db.trips.find(
  {"$text": {"$search": "confortable"}},
  {"comment": 1, "distance": 1, "_id": 0}
)

Résultat : tous les trajets dont le commentaire contient "confortable".
L'index text permet une recherche insensible à la casse et aux accents.
