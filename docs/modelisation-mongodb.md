# Modélisation MongoDB — CityFlow

## Contexte
CityFlow est une plateforme de mobilité urbaine multimodale (vélos, scooters, voitures).
Base : MongoDB 7.0 — 3 collections principales.

## Collections

### users
Stocke les profils utilisateurs.
Embedding choisi pour les préférences (relation 1-1, toujours lues avec le profil).

Champs principaux :
- _id : ObjectId (auto-généré)
- firstName, lastName : String
- email : String (index unique)
- age : Integer
- city : String
- isVerified : Boolean
- createdAt : Date

### vehicles
Stocke les véhicules disponibles sur la plateforme.

Champs principaux :
- _id : ObjectId
- type : String (vélo / scooter / voiture)
- model : String
- status : String (available / maintenance)
- location : Object embedé { arrondissement, lat, lng }

Justification embedding location : la localisation est toujours lue avec le véhicule,
pas d'existence propre, relation 1-1.

### trips
Stocke les trajets effectués.
Référencement choisi pour userId et vehicleId.

Champs principaux :
- _id : ObjectId
- userId : ObjectId → référence users
- vehicleId : ObjectId → référence vehicles
- date : Date
- distance : Double (km)
- duration : Integer (minutes)
- status : String (completed / cancelled)
- comment : String (pour recherche full-text US-M4)

## Choix Embedding vs Référencement

| Relation | Stratégie | Justification |
|----------|-----------|---------------|
| Vehicle → location | Embedding | Relation 1-1, toujours lue ensemble |
| Trip → User | Référencement | 1 user a potentiellement des milliers de trajets |
| Trip → Vehicle | Référencement | Un véhicule existe indépendamment, réutilisé pour N trajets |

## Index créés

### Collection users
- { email: 1 } unique — évite les doublons
- { city: 1, age: -1 } composé — optimise les filtres par ville et âge
- { createdAt: -1 } — optimise les tris par date

### Collection trips
- { comment: "text" } — permet la recherche full-text (US-M4)
- { userId: 1, date: -1 } — optimise US-M1 (10 derniers trajets d'un user)

### Index ESR pour la requête "Lyon, 18-30 ans, triés par createdAt"
{ city: 1, createdAt: -1, age: 1 }
E = city (égalité), S = createdAt (tri), R = age (intervalle)

## Règle d'or appliquée
Modélisation orientée requêtes : chaque collection est conçue
pour répondre à ses user stories principales en un minimum d'allers-retours.
