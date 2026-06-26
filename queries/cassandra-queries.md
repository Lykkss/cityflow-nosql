# Requêtes Cassandra — CityFlow

## US-C1 : Trajets d'un utilisateur

SELECT trip_date, vehicle_type, departure, arrival, distance_km, status
FROM trips_by_user
WHERE user_id = 9cdd9c3f-3e25-41f8-8347-8bd89837faeb
LIMIT 10;

---

## US-C2 : Trajets d'une journée

SELECT trip_id, vehicle_type, departure, arrival, distance_km
FROM trips_by_date
WHERE trip_date = '2026-06-01';

---

## US-C3 : Disponibilité actuelle d'une station

SELECT station_name, available_bikes, available_scooters, available_cars, recorded_at
FROM station_availability
WHERE station_id = 'S001'
LIMIT 1;

-- Historique sur une période
SELECT recorded_at, available_bikes, available_scooters
FROM station_availability
WHERE station_id = 'S001'
AND recorded_at >= '2026-06-26 08:00:00+0000'
AND recorded_at <= '2026-06-26 10:00:00+0000';

---

## US-C4 : Logs d'une journée

-- Tous les événements
SELECT event_time, event_type, details
FROM event_logs
WHERE log_date = '2026-06-26';

-- Filtrer par type (ALLOW FILTERING car event_type n'est pas clé)
SELECT event_time, event_type, details
FROM event_logs
WHERE log_date = '2026-06-26'
AND event_type = 'LOGIN'
ALLOW FILTERING;
