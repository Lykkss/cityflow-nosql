# Mes requêtes MongoDB — TP NoSQL B3

## Niveau 1 — Filtres simples

### Requête 1 — Utilisateurs entre 25 et 35 ans
Query: {"age": {"$gte": 25, "$lte": 35}}
Projection: {"firstName": 1, "age": 1, "_id": 0}
Résultat: Alice (28), Karim (34)

### Requête 2 — Emails contenant example.com
Query: {"email": {"$regex": "example\\.com$", "$options": "i"}}
Projection: {"firstName": 1, "email": 1, "_id": 0}
Résultat: Les 6 utilisateurs

### Requête 3 — Utilisateurs avec exactement 2 adresses
Query: {"addresses": {"$size": 2}}
Projection: {"firstName": 1, "addresses": 1, "_id": 0}
Résultat: Karim (seul avec 2 adresses)

### Requête 4 — Utilisateurs sans le champ preferences
Query: {"preferences": {"$exists": false}}
Projection: {"firstName": 1, "_id": 0}
Résultat: Alice, Karim, Sofia, Léa

## Niveau 2 — Combinaisons

### Requête 5 — Lyon OU Villeurbanne, ET plus de 25 ans
Query:
{
  "$and": [
    {"age": {"$gt": 25}},
    {"$or": [
      {"addresses.city": "Lyon"},
      {"addresses.city": "Villeurbanne"}
    ]}
  ]
}
Projection: {"firstName": 1, "age": 1, "_id": 0}
Résultat: Alice (28), Karim (34), Pierre (58)
Note: Thomas est à Vénissieux donc exclu

### Requête 6 — Adresse de type home à Lyon
Query: {"addresses": {"$elemMatch": {"type": "home", "city": "Lyon"}}}
Projection: {"firstName": 1, "addresses": 1, "_id": 0}
Résultat: Alice, Karim, Léa, Pierre

### Requête 7 — Tags premium ET eco-friendly
Query: {"tags": {"$all": ["premium", "eco-friendly"]}}
Projection: {"firstName": 1, "tags": 1, "_id": 0}
Résultat: Thomas uniquement

## Niveau 3 — Tri et pagination (mode Aggregate query)

### Requête 8 — Top 3 utilisateurs les plus âgés
Pipeline:
[
  {"$sort": {"age": -1}},
  {"$limit": 3},
  {"$project": {"firstName": 1, "age": 1, "email": 1, "_id": 0}}
]
Résultat: Pierre (58), Thomas (45), Karim (34)

### Requête 9 — Tri par ville alphabétique puis âge décroissant
Pipeline:
[
  {"$unwind": "$addresses"},
  {"$sort": {"addresses.city": 1, "age": -1}},
  {"$project": {"firstName": 1, "age": 1, "city": "$addresses.city", "_id": 0}}
]
Résultat: Lyon (Pierre 58, Karim 34x2, Alice 28, Léa 19), Villeurbanne (Sofia 22), Vénissieux (Thomas 45)
Note: Karim apparaît 2 fois car $unwind déplie ses 2 adresses

### Requête 10 — Pagination page 2, 2 users par page, triés par createdAt
Pipeline:
[
  {"$sort": {"createdAt": 1}},
  {"$skip": 2},
  {"$limit": 2},
  {"$project": {"firstName": 1, "createdAt": 1, "_id": 0}}
]
Résultat: Alice (2025-10-01), Karim (2025-11-15)

## Niveau 4 — Bonus

### Requête 11 — Vérifiés, moins de 30 ans, pas à Lyon
Pipeline:
[
  {"$match": {
    "isVerified": true,
    "age": {"$lt": 30},
    "addresses.city": {"$ne": "Lyon"}
  }},
  {"$project": {"firstName": 1, "age": 1, "_id": 0}}
]
Résultat: Aucun document — normal, aucun user ne cumule ces 3 critères

### Requête 12 — Tags commençant par 'p'
Pipeline:
[
  {"$match": {"tags": {"$regex": "^p", "$options": "i"}}},
  {"$project": {"firstName": 1, "tags": 1, "_id": 0}}
]
Résultat: Alice (premium), Thomas (premium), Pierre (premium)

## Index créés

### Index 1 — email unique
db.users.createIndex({"email": 1}, {unique: true})
Justification: L'email est un identifiant métier unique, évite les doublons.

### Index 2 — ville + âge composé (règle ESR)
db.users.createIndex({"addresses.city": 1, "age": -1})
Justification: Optimise les requêtes fréquentes filtrant par ville (Equality)
et triant par âge (Sort). Couvre les requêtes 5, 6, 9.

### Index 3 — createdAt décroissant
db.users.createIndex({"createdAt": -1})
Justification: Optimise les tris et paginations par date (requête 10).

### Index bonus ESR — pour la requête "Lyon, 18-30 ans, triés par createdAt"
db.users.createIndex({"addresses.city": 1, "createdAt": -1, "age": 1})
Justification: E=city (égalité), S=createdAt (tri), R=age (intervalle).