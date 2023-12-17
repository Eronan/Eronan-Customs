CREATE TEMP TABLE _Types(Type TEXT PRIMARY KEY, Value INTEGER);
CREATE TEMP TABLE _Attributes(Att TEXT PRIMARY KEY, Value INTEGER);
CREATE TEMP TABLE _Races(Race TEXT PRIMARY KEY, Value INTEGER);
CREATE TEMP TABLE _LinkMarkers(LinkMarker TEXT PRIMARY KEY, Value INTEGER);

-- Types
INSERT INTO _Types (Type, Value) VALUES ("MONSTER", hex("0x1"));
INSERT INTO _Types (Type, Value) VALUES ("SPELL", hex("0x2"));
INSERT INTO _Types (Type, Value) VALUES ("TRAP", hex("0x4"));
INSERT INTO _Types (Type, Value) VALUES ("NORMAL", hex("0x10"));
INSERT INTO _Types (Type, Value) VALUES ("EFFECT", hex("0x20"));
INSERT INTO _Types (Type, Value) VALUES ("FUSION", hex("0x40"));
INSERT INTO _Types (Type, Value) VALUES ("RITUAL", hex("0x80"));
INSERT INTO _Types (Type, Value) VALUES ("TRAPMONSTER", hex("0x100"));
INSERT INTO _Types (Type, Value) VALUES ("SPIRIT", hex("0x200"));
INSERT INTO _Types (Type, Value) VALUES ("UNION", hex("0x400"));
INSERT INTO _Types (Type, Value) VALUES ("GEMINI", hex("0x800"));
INSERT INTO _Types (Type, Value) VALUES ("TUNER", hex("0x1000"));
INSERT INTO _Types (Type, Value) VALUES ("SYNCHRO", hex("0x2000"));
INSERT INTO _Types (Type, Value) VALUES ("TOKEN", hex("0x4000"));
INSERT INTO _Types (Type, Value) VALUES ("MAXIMUM", hex("0x8000"));
INSERT INTO _Types (Type, Value) VALUES ("QUICKPLAY", hex("0x10000"));
INSERT INTO _Types (Type, Value) VALUES ("CONTINUOUS", hex("0x20000"));
INSERT INTO _Types (Type, Value) VALUES ("EQUIP", hex("0x40000"));
INSERT INTO _Types (Type, Value) VALUES ("FIELD", hex("0x80000"));
INSERT INTO _Types (Type, Value) VALUES ("COUNTER", hex("0x100000"));
INSERT INTO _Types (Type, Value) VALUES ("FLIP", hex("0x200000"));
INSERT INTO _Types (Type, Value) VALUES ("TOON", hex("0x400000"));
INSERT INTO _Types (Type, Value) VALUES ("XYZ", hex("0x800000"));
INSERT INTO _Types (Type, Value) VALUES ("PENDULUM", hex("0x1000000"));
INSERT INTO _Types (Type, Value) VALUES ("SPSUMMON", hex("0x2000000"));
INSERT INTO _Types (Type, Value) VALUES ("LINK", hex("0x4000000"));
INSERT INTO _Types (Type, Value) VALUES ("SKILL", hex("0x8000000"));
INSERT INTO _Types (Type, Value) VALUES ("ACTION", hex("0x10000000"));
INSERT INTO _Types (Type, Value) VALUES ("PLUS", hex("0x20000000"));
INSERT INTO _Types (Type, Value) VALUES ("MINUS", hex("0x40000000"));
INSERT INTO _Types (Type, Value) VALUES ("ARMOR", hex("0x80000000"));
INSERT INTO _Types (Type, Value) VALUES ("RUNE", hex("0x80000000"));

-- Attributes
INSERT INTO _Attributes (Att, Value) VALUES ("EARTH", hex("0x1"));
INSERT INTO _Attributes (Att, Value) VALUES ("WATER", hex("0x2"));
INSERT INTO _Attributes (Att, Value) VALUES ("FIRE", hex("0x4"));
INSERT INTO _Attributes (Att, Value) VALUES ("WIND", hex("0x8"));
INSERT INTO _Attributes (Att, Value) VALUES ("LIGHT", hex("0x10"));
INSERT INTO _Attributes (Att, Value) VALUES ("DARK", hex("0x20"));
INSERT INTO _Attributes (Att, Value) VALUES ("DIVINE", hex("0x40"));

-- Races
INSERT INTO _Races (RACE, Value) VALUES ("WARRIOR", hex("0x1"));
INSERT INTO _Races (RACE, Value) VALUES ("SPELLCASTER", hex("0x2"));
INSERT INTO _Races (RACE, Value) VALUES ("FAIRY", hex("0x4"));
INSERT INTO _Races (RACE, Value) VALUES ("FIEND", hex("0x8"));
INSERT INTO _Races (RACE, Value) VALUES ("ZOMBIE", hex("0x10"));
INSERT INTO _Races (RACE, Value) VALUES ("MACHINE", hex("0x20"));
INSERT INTO _Races (RACE, Value) VALUES ("AQUA", hex("0x40"));
INSERT INTO _Races (RACE, Value) VALUES ("PYRO", hex("0x80"));
INSERT INTO _Races (RACE, Value) VALUES ("ROCK", hex("0x100"));
INSERT INTO _Races (RACE, Value) VALUES ("WINGEDBEAST", hex("0x200"));
INSERT INTO _Races (RACE, Value) VALUES ("PLANT", hex("0x400"));
INSERT INTO _Races (RACE, Value) VALUES ("INSECT", hex("0x800"));
INSERT INTO _Races (RACE, Value) VALUES ("THUNDER", hex("0x1000"));
INSERT INTO _Races (RACE, Value) VALUES ("DRAGON", hex("0x2000"));
INSERT INTO _Races (RACE, Value) VALUES ("BEAST", hex("0x4000"));
INSERT INTO _Races (RACE, Value) VALUES ("BEASTWARRIOR", hex("0x8000"));
INSERT INTO _Races (RACE, Value) VALUES ("DINOSAUR", hex("0x10000"));
INSERT INTO _Races (RACE, Value) VALUES ("FISH", hex("0x20000"));
INSERT INTO _Races (RACE, Value) VALUES ("SEASERPENT", hex("0x40000"));
INSERT INTO _Races (RACE, Value) VALUES ("REPTILE", hex("0x80000"));
INSERT INTO _Races (RACE, Value) VALUES ("PSYCHIC", hex("0x100000"));
INSERT INTO _Races (RACE, Value) VALUES ("DIVINE", hex("0x200000"));
INSERT INTO _Races (RACE, Value) VALUES ("CREATORGOD", hex("0x400000"));
INSERT INTO _Races (RACE, Value) VALUES ("WYRM", hex("0x800000"));
INSERT INTO _Races (RACE, Value) VALUES ("CYBERSE", hex("0x1000000"));
INSERT INTO _Races (RACE, Value) VALUES ("ILLUSION", hex("0x2000000"));
INSERT INTO _Races (RACE, Value) VALUES ("CYBORG", hex("0x4000000"));
INSERT INTO _Races (RACE, Value) VALUES ("MAGICALKNIGHT", hex("0x8000000"));
INSERT INTO _Races (RACE, Value) VALUES ("HIGHDRAGON", hex("0x10000000"));
INSERT INTO _Races (RACE, Value) VALUES ("OMEGAPSYCHIC", hex("0x20000000"));
INSERT INTO _Races (RACE, Value) VALUES ("CELESTIALWARRIOR", hex("0x40000000"));
INSERT INTO _Races (RACE, Value) VALUES ("GALAXY", hex("0x80000000"));
INSERT INTO _Races (RACE, Value) VALUES ("YOKAI", hex("0x4000000000000000"));

-- Link Markers
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("BOTTOM_LEFT", hex("0x1"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("BOTTOM", hex("0x2"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("BOTTOM_RIGHT", hex("0x4"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("LEFT", hex("0x8"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("RIGHT", hex("0x20"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("TOP_LEFT", hex("0x40"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("TOP", hex("0x80"));
INSERT INTO _LinkMarkers (LinkMarker, Value) VALUES ("TOP_RIGHT", hex("0x100"));

CREATE TEMP TABLE _Card(id INTEGER PRIMARY KEY, );
INSERT INTO _Card(id, 



DROP TABLE _Types;
DROP TABLE _Attributes;
DROP TABLE _Races;
DROP TABLE _LinkMarkers;
DROP TABLE _Card;