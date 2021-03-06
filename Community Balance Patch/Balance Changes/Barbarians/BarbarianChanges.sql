-- Barbarian Healing

INSERT INTO Defines (
Name, Value)
SELECT 'BALANCE_BARBARIAN_HEAL_RATE', '0'
WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='BARBARIAN_HEAL' AND Value= 0 );

INSERT INTO Defines (
Name, Value)
SELECT 'BALANCE_BARBARIAN_HEAL_RATE', '5'
WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='BARBARIAN_HEAL' AND Value= 1 );

INSERT INTO Defines (
Name, Value)
SELECT 'BALANCE_BARBARIAN_HEAL_RATE', '10'
WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='BARBARIAN_HEAL' AND Value= 2 );

-- Barbarian Promotions

UPDATE Features
SET SpawnLocationUnitFreePromotion = 'PROMOTION_MARSH_WALKER'
WHERE Type = 'FEATURE_MARSH';

UPDATE Features
SET SpawnLocationUnitFreePromotion = 'PROMOTION_MARSH_WALKER'
WHERE Type = 'FEATURE_FLOOD_PLAINS';

UPDATE Features
SET SpawnLocationUnitFreePromotion = 'PROMOTION_WOODS_WALKER'
WHERE Type = 'FEATURE_FOREST';

UPDATE Features
SET SpawnLocationUnitFreePromotion = 'PROMOTION_WOODS_WALKER'
WHERE Type = 'FEATURE_JUNGLE';

UPDATE Terrains
SET SpawnLocationUnitFreePromotion = 'PROMOTION_DESERT_WALKER'
WHERE Type = 'TERRAIN_DESERT';

UPDATE Terrains
SET AdjacentSpawnLocationUnitFreePromotion = 'PROMOTION_COAST_WALKER'
WHERE Type = 'TERRAIN_COAST';

UPDATE Terrains
SET SpawnLocationUnitFreePromotion = 'PROMOTION_HILL_WALKER'
WHERE Type = 'TERRAIN_HILL';

UPDATE Terrains
SET SpawnLocationUnitFreePromotion = 'PROMOTION_WHITE_WALKER'
WHERE Type = 'TERRAIN_SNOW';

UPDATE Terrains
SET SpawnLocationUnitFreePromotion = 'PROMOTION_WHITE_WALKER'
WHERE Type = 'TERRAIN_TUNDRA';