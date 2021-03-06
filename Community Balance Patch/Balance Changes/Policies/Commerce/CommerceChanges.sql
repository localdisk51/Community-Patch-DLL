-- Unlock Time
UPDATE PolicyBranchTypes
SET EraPrereq = 'ERA_RENAISSANCE'
WHERE Type = 'POLICY_BRANCH_COMMERCE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Commerce Opener

UPDATE Policy_CapitalYieldModifiers
SET Yield = '0'
WHERE PolicyType = 'POLICY_COMMERCE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Wagon Trains (now Turnpikes)
UPDATE Policies
SET LandTradeRouteGoldChange = '400'
WHERE Type = 'POLICY_CARAVANS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET RouteGoldMaintenanceMod = '0'
WHERE Type = 'POLICY_CARAVANS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET PovertyHappinessMod = '-20'
WHERE Type = 'POLICY_CARAVANS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Mercantilism (the same)
UPDATE Policy_HurryModifiers
SET HurryCostModifier = '-5'
WHERE PolicyType = 'POLICY_MERCANTILISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET InternalTradeRouteYieldModifier = '33'
WHERE Type = 'POLICY_MERCANTILISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Trade Unions
UPDATE Policies
SET PortraitIndex = '6'
WHERE Type = 'POLICY_TRADE_UNIONS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET IconAtlas = 'POLICY_ATLAS_EXP2'
WHERE Type = 'POLICY_TRADE_UNIONS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET IconAtlasAchieved = 'POLICY_A_ATLAS_EXP2'
WHERE Type = 'POLICY_TRADE_UNIONS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET InvestmentModifier = '-15'
WHERE Type = 'POLICY_TRADE_UNIONS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CIVS' AND Value= 1 );

-- Entrepreneurship

UPDATE Policies
SET TradeMissionGoldModifier = '0'
WHERE Type = 'POLICY_ENTREPRENEURSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET EmbarkedExtraMoves = '0'
WHERE Type = 'POLICY_ENTREPRENEURSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );
  
-- Protectionism
UPDATE Policies
SET FreeTradeRoute = '1'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET SeaTradeRouteGoldChange = '200'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET ExtraHappinessPerLuxury = '0'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Finisher
UPDATE Policies
SET IdeologyPoint = '1'
WHERE Type = 'POLICY_COMMERCE_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policy_ImprovementYieldChanges
SET Yield = '0'
WHERE PolicyType = 'POLICY_COMMERCE_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET ExtraHappinessPerLuxury = '1'
WHERE Type = 'POLICY_COMMERCE_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

