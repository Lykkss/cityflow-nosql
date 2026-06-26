-- Seed Cassandra CityFlow
-- Usage : docker exec -i cityflow-cassandra cqlsh < seed/cassandra/init.cql

CREATE KEYSPACE IF NOT EXISTS cityflow
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE cityflow;

CREATE TABLE IF NOT EXISTS trips_by_user (
  user_id UUID,
  trip_date TIMESTAMP,
  trip_id UUID,
  vehicle_type TEXT,
  distance_km DOUBLE,
  duration_min INT,
  departure TEXT,
  arrival TEXT,
  status TEXT,
  PRIMARY KEY (user_id, trip_date, trip_id)
) WITH CLUSTERING ORDER BY (trip_date DESC, trip_id ASC);

CREATE TABLE IF NOT EXISTS trips_by_date (
  trip_date DATE,
  trip_id UUID,
  user_id UUID,
  vehicle_type TEXT,
  distance_km DOUBLE,
  duration_min INT,
  departure TEXT,
  arrival TEXT,
  PRIMARY KEY (trip_date, trip_id)
) WITH CLUSTERING ORDER BY (trip_id ASC);

CREATE TABLE IF NOT EXISTS station_availability (
  station_id TEXT,
  recorded_at TIMESTAMP,
  available_bikes INT,
  available_scooters INT,
  available_cars INT,
  station_name TEXT,
  arrondissement TEXT,
  PRIMARY KEY (station_id, recorded_at)
) WITH CLUSTERING ORDER BY (recorded_at DESC);

CREATE TABLE IF NOT EXISTS event_logs (
  log_date DATE,
  event_time TIMESTAMP,
  event_id UUID,
  event_type TEXT,
  user_id UUID,
  details TEXT,
  PRIMARY KEY (log_date, event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);
