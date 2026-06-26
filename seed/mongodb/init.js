// Script de seed CityFlow — MongoDB 7.0
// Usage : mongosh -u admin -p cityflow2025 --file seed/mongodb/init.js

use("cityflow");

// Nettoyage
db.vehicles.drop();
db.users.drop();
db.trips.drop();

// VEHICLES 
db.vehicles.insertMany([
  {"type": "vélo", "model": "B'Twin 500", "status": "available", "location": {"arrondissement": "Lyon 1", "lat": 45.7676, "lng": 4.8344}},
  {"type": "vélo", "model": "B'Twin 300", "status": "available", "location": {"arrondissement": "Lyon 2", "lat": 45.7485, "lng": 4.8322}},
  {"type": "vélo", "model": "Decathlon City", "status": "maintenance", "location": {"arrondissement": "Villeurbanne", "lat": 45.7715, "lng": 4.8902}},
  {"type": "scooter", "model": "Peugeot Django", "status": "available", "location": {"arrondissement": "Lyon 3", "lat": 45.7589, "lng": 4.8499}},
  {"type": "scooter", "model": "Yamaha Xenter", "status": "available", "location": {"arrondissement": "Lyon 6", "lat": 45.7713, "lng": 4.8573}},
  {"type": "scooter", "model": "Honda PCX", "status": "available", "location": {"arrondissement": "Vénissieux", "lat": 45.6969, "lng": 4.8894}},
  {"type": "voiture", "model": "Renault Zoé", "status": "available", "location": {"arrondissement": "Lyon 7", "lat": 45.7365, "lng": 4.8342}},
  {"type": "voiture", "model": "Peugeot e-208", "status": "available", "location": {"arrondissement": "Lyon 8", "lat": 45.7269, "lng": 4.8638}},
  {"type": "voiture", "model": "Tesla Model 3", "status": "maintenance", "location": {"arrondissement": "Lyon 9", "lat": 45.7783, "lng": 4.7969}},
  {"type": "voiture", "model": "Citroën ë-C3", "status": "available", "location": {"arrondissement": "Lyon 4", "lat": 45.7784, "lng": 4.8285}}
]);

// USERS 
db.users.insertMany([
  {"firstName": "Alice", "lastName": "Dupont", "email": "alice.dupont@cityflow.fr", "age": 28, "city": "Lyon 1", "isVerified": true, "createdAt": new Date("2025-09-01")},
  {"firstName": "Karim", "lastName": "Benali", "email": "karim.benali@cityflow.fr", "age": 34, "city": "Lyon 3", "isVerified": true, "createdAt": new Date("2025-09-05")},
  {"firstName": "Sofia", "lastName": "Martin", "email": "sofia.martin@cityflow.fr", "age": 22, "city": "Villeurbanne", "isVerified": false, "createdAt": new Date("2025-09-10")},
  {"firstName": "Thomas", "lastName": "Dubois", "email": "thomas.dubois@cityflow.fr", "age": 45, "city": "Vénissieux", "isVerified": true, "createdAt": new Date("2025-09-15")},
  {"firstName": "Léa", "lastName": "Rousseau", "email": "lea.rousseau@cityflow.fr", "age": 19, "city": "Lyon 2", "isVerified": false, "createdAt": new Date("2025-10-01")},
  {"firstName": "Pierre", "lastName": "Morel", "email": "pierre.morel@cityflow.fr", "age": 58, "city": "Lyon 6", "isVerified": true, "createdAt": new Date("2025-10-05")},
  {"firstName": "Nadia", "lastName": "Hamdi", "email": "nadia.hamdi@cityflow.fr", "age": 31, "city": "Lyon 7", "isVerified": true, "createdAt": new Date("2025-10-10")},
  {"firstName": "Julien", "lastName": "Petit", "email": "julien.petit@cityflow.fr", "age": 26, "city": "Lyon 4", "isVerified": false, "createdAt": new Date("2025-10-15")},
  {"firstName": "Amara", "lastName": "Diallo", "email": "amara.diallo@cityflow.fr", "age": 38, "city": "Lyon 8", "isVerified": true, "createdAt": new Date("2025-11-01")},
  {"firstName": "Clara", "lastName": "Bernard", "email": "clara.bernard@cityflow.fr", "age": 24, "city": "Villeurbanne", "isVerified": true, "createdAt": new Date("2025-11-05")},
  {"firstName": "Mehdi", "lastName": "Larbi", "email": "mehdi.larbi@cityflow.fr", "age": 29, "city": "Lyon 9", "isVerified": false, "createdAt": new Date("2025-11-10")},
  {"firstName": "Inès", "lastName": "Fontaine", "email": "ines.fontaine@cityflow.fr", "age": 42, "city": "Lyon 1", "isVerified": true, "createdAt": new Date("2025-11-15")},
  {"firstName": "Romain", "lastName": "Leroy", "email": "romain.leroy@cityflow.fr", "age": 33, "city": "Vénissieux", "isVerified": true, "createdAt": new Date("2025-12-01")},
  {"firstName": "Fatou", "lastName": "Diop", "email": "fatou.diop@cityflow.fr", "age": 27, "city": "Lyon 5", "isVerified": false, "createdAt": new Date("2025-12-10")},
  {"firstName": "Lucas", "lastName": "Simon", "email": "lucas.simon@cityflow.fr", "age": 21, "city": "Lyon 3", "isVerified": true, "createdAt": new Date("2026-01-05")}
]);

// INDEX 
db.users.createIndex({"email": 1}, {unique: true});
db.users.createIndex({"city": 1, "age": -1});
db.users.createIndex({"createdAt": -1});
db.vehicles.createIndex({"type": 1, "status": 1, "location.arrondissement": 1});
db.trips.createIndex({"comment": "text"});
db.trips.createIndex({"userId": 1, "date": -1});

print("Seed CityFlow terminé ✓");
print("users: " + db.users.countDocuments());
print("vehicles: " + db.vehicles.countDocuments());
