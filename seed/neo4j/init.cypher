// Seed Neo4j CityFlow
// Usage : copier-coller dans Neo4j Browser

// Nettoyage
MATCH (n) DETACH DELETE n;

// Contraintes
CREATE CONSTRAINT station_code IF NOT EXISTS FOR (s:Station) REQUIRE s.code IS UNIQUE;
CREATE CONSTRAINT line_number IF NOT EXISTS FOR (l:Line) REQUIRE l.number IS UNIQUE;

// Stations
CREATE
(a1:Station {code:'BEL', name:'Bellecour', type:'metro'}),
(a2:Station {code:'COR', name:'Cordeliers', type:'metro'}),
(a3:Station {code:'HDV', name:'Hôtel de Ville', type:'metro'}),
(a4:Station {code:'PDP', name:'Perrache', type:'metro'}),
(a5:Station {code:'AMP', name:'Ampère', type:'metro'}),
(b1:Station {code:'CDX', name:'Charpennes', type:'metro'}),
(b2:Station {code:'PDI', name:'Part-Dieu', type:'metro'}),
(b3:Station {code:'BOC', name:'Brotteaux', type:'metro'}),
(b4:Station {code:'MAS', name:'Masséna', type:'metro'}),
(c1:Station {code:'CRP', name:'Croix-Paquet', type:'metro'}),
(c2:Station {code:'CRX', name:'Croix-Rousse', type:'metro'}),
(c3:Station {code:'HEN', name:'Henon', type:'metro'}),
(d1:Station {code:'VAI', name:'Gare de Vaise', type:'metro'}),
(d2:Station {code:'VAL', name:'Valmy', type:'metro'}),
(d3:Station {code:'GOR', name:'Gorge de Loup', type:'metro'});

// Lignes
CREATE
(la:Line {number:'A', color:'red', type:'metro'}),
(lb:Line {number:'B', color:'blue', type:'metro'}),
(lc:Line {number:'C', color:'orange', type:'metro'}),
(ld:Line {number:'D', color:'green', type:'metro'});

// Init terminé — ajouter les CONNECTED_TO et SERVES manuellement
