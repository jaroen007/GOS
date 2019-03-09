--[======[
  ___           _   _   
 |_ _|  _ __   (_) | |_ 
  | |  | '_ \  | | | __|
  | |  | | | | | | | |_ 
 |___| |_| |_| |_|  \__|
                        
--]======]

-- SCRIPT INFO
local Version = 0.01;
local ScriptName = "NeoChogath";

-- RETURN IF NOT JHIN
if (myHero.charName ~= "Chogath") then
    return;
end

-- RETURN IF LOADED
if (_G.NeoChogathLoaded) then
    return;
end
_G.NeoChogathLoaded = true;

-- REQUIRE CORE
if (not FileExist(COMMON_PATH .. "GamsteronCore.lua")) then
    DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronCore.lua", COMMON_PATH .. "GamsteronCore.lua", function() end);
    while (not FileExist(COMMON_PATH .. "GamsteronCore.lua")) do
    end
end
require('GamsteronCore');

-- REQUIRE PREDICTION
if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
    DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
    while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
require('GamsteronPrediction')

-- LIBRARIES
local LocalSDK = _G.SDK;
local LocalCore = _G.GamsteronCore;

-- AUTO UPDATER
local UpdateSuccess, UpdateVersion = LocalCore:AutoUpdate({
    version = Version,
    scriptPath = SCRIPT_PATH .. ScriptName .. ".lua",
    scriptUrl = "https://raw.githubusercontent.com/jaroen007/GOS/master/" .. ScriptName .. ".lua",
    versionPath = SCRIPT_PATH .. ScriptName .. ".version",
    versionUrl = "https://raw.githubusercontent.com/jaroen007/GOS/master/" .. ScriptName .. ".version"
})
if (UpdateSuccess) then
    print(ScriptName .. " updated to version " .. UpdateVersion .. ". Please Reload with 2x F6 !");
    return;
end

local ORBWALKER_MODE_NONE = -1;
local ORBWALKER_MODE_COMBO = 0;
local ORBWALKER_MODE_HARASS = 1;
local ORBWALKER_MODE_LANECLEAR = 2;
local ORBWALKER_MODE_JUNGLECLEAR = 3;
local ORBWALKER_MODE_LASTHIT = 4;
local ORBWALKER_MODE_FLEE = 5;

local HEROES_SPELL = 0;
local HEROES_ATTACK = 1;
local HEROES_IMMORTAL = 2;

local DAMAGE_TYPE_PHYSICAL = 0;
local DAMAGE_TYPE_MAGICAL = 1;
local DAMAGE_TYPE_TRUE = 2;

local HITCHANCE_NORMAL = 2;
local HITCHANCE_HIGH = 3;
local HITCHANCE_IMMOBILE = 4;

--[======[
 _____ _                       _   _     
/  __ \ |                     | | | |    
| /  \/ |__   ___   __ _  __ _| |_| |__  
| |   | '_ \ / _ \ / _` |/ _` | __| '_ \ 
| \__/\ | | | (_) | (_| | (_| | |_| | | |
 \____/_| |_|\___/ \__, |\__,_|\__|_| |_|
                    __/ |                
                   |___/                 
                           
--]======]

-- MENU
local Menu = MenuElement({name = "Neo Chogath", id = "neochogath", type = MENU, leftIcon = "https://raw.githubusercontent.com/jaroen007/GOS/master/Icons/neochogath_avatar.png"})
-- Menu:MenuElement({id = "autor", name = "Auto R -> if jhin has R Buff", value = true})
-- Menu:MenuElement({name = "Q settings", id = "qset", type = MENU})
-- Menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
-- Menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
-- Menu:MenuElement({name = "W settings", id = "wset", type = MENU})
-- Menu.wset:MenuElement({id = "stun", name = "Only if stun (marked targets)", value = true})
-- Menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
-- Menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
-- Menu:MenuElement({name = "E settings", id = "eset", type = MENU})
-- Menu.eset:MenuElement({id = "onlyimmo", name = "Only Immobile", value = true})
-- Menu.eset:MenuElement({id = "combo", name = "Combo", value = true})
-- Menu.eset:MenuElement({id = "harass", name = "Harass", value = false})
-- Menu:MenuElement({name = "Version " .. tostring(Version), type = _G.SPACE, id = "verspace"})

-- JHIN VARIABLES
-- local champInfo =
-- {
--     hasPBuff = false,
--     hasRBuff = false,
-- };
-- local rData =
-- {
--     polygon = nil,
--     canDraw = false,
--     startPos = nil,
--     pos1 = nil,
--     middle = nil,
--     pos2 = nil,
-- };
-- local spellData =
-- {
--     q = {Delay = 0.25, Range = 550, },
--     w = {Delay = 0.75, Range = 3000, Radius = 45, Speed = math.huge, Type = 0, Collision = false, },
--     e = {Delay = 0.25, Range = 750, Radius = 120, Speed = 1600, Type = 1, Collision = false, },
--     r = {Delay = 0.25, Range = 3500, Radius = 80, Speed = 5000, Type = 0, Collision = false, },
-- };

-- UTILITES
-- local function Bool(x)
--     return x;
-- end

-- local function Num(x)
--     return x;
-- end

-- local function Get2D(p1)
--     if (p1.pos) then
--         p1 = p1.pos;
--     end
--     local result = {x = 0, z = 0};
--     if (p1.x) then
--         result.x = p1.x;
--     end
--     if (p1.z) then
--         result.z = p1.z;
--     elseif (p1.y) then
--         result.z = p1.y;
--     end
--     return result;
-- end

-- local function GetDistance(p1, p2)
--     p1 = Get2D(p1);
--     p2 = Get2D(p2);
--     local dx = p2.x - p1.x;
--     local dz = p2.z - p1.z;
--     return math.sqrt(dx * dx + dz * dz);
-- end

-- local function InsidePolygon(polygon, point)
--     local result = false
--     local j = #polygon
--     point = Get2D(point);
--     local pointx = point.x
--     local pointz = point.z
--     for i = 1, #polygon do
--         if (polygon[i].z < pointz and polygon[j].z >= pointz or polygon[j].z < pointz and polygon[i].z >= pointz) then
--             if (polygon[i].x + (pointz - polygon[i].z) / (polygon[j].z - polygon[i].z) * (polygon[j].x - polygon[i].x) < pointx) then
--                 result = not result
--             end
--         end
--         j = i
--     end
--     return result
-- end

-- local function HasBuff(unit, bName)
--     for i = 0, unit.buffCount do
--         local buff = unit:GetBuff(i)
--         if buff and buff.count > 0 and buff.name:lower() == bName then
--             return true
--         end
--     end
--     return false
-- end

-- local function IsValid(unit, range, bbox)
--     if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
--         local bbRange = 0;
--         if (bbox) then
--             bbRange = myHero.boundingRadius + unit.boundingRadius;
--         end
--         if (GetDistance(myHero, unit) < range + bbRange) then
--             return true;
--         end
--     end
--     return false;
-- end

-- local function GetEnemyHeroes(range, bbox)
--     local _EnemyHeroes = {};
--     for i = 1, Game.HeroCount() do
--         local hero = Game.Hero(i);
--         if IsValid(hero, range, bbox) and hero.isEnemy then
--             table.insert(_EnemyHeroes, hero);
--         end
--     end
--     return _EnemyHeroes;
-- end

-- local function ImmobileTime(unit)
--     local iT = 0
--     for i = 0, unit.buffCount do
--         local buff = unit:GetBuff(i)
--         if buff and buff.count > 0 then
--             local bType = buff.type
--             if bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall" then
--                 local bDuration = buff.duration
--                 if bDuration > iT then
--                     iT = bDuration
--                 end
--             end
--         end
--     end
--     return iT
-- end

-- local function GetImmobileEnemy(range, duration)
--     local num = 0
--     local result = nil
--     local enemyList = GetEnemyHeroes(range, false);
--     for i, hero in pairs(enemyList) do
--         local iT = ImmobileTime(hero)
--         if iT > num and iT >= duration then
--             num = iT
--             result = hero
--         end
--     end
--     return result
-- end

-- -- SPELLS
-- local function IsReadyCombo(spell, menuCombo, menuHarass, delays)
--     local isCombo = LocalSDK.Orbwalker.Modes[ORBWALKER_MODE_COMBO];
--     local isHarass = LocalSDK.Orbwalker.Modes[ORBWALKER_MODE_HARASS];
--     if (Bool(Bool(isCombo and menuCombo) or Bool(isHarass and menuHarass)) and LocalSDK.Spells:IsReady(spell, delays)) then
--         return true;
--     end
--     return false;
-- end

-- local function CastTarget(hkSpell, sData, dType, hType, bbox, func)
--     local target = LocalSDK.TargetSelector:GetComboTarget();
--     local range = sData.Range - 35;
--     if (bbox) then
--         range = range + myHero.boundingRadius;
--     end
--     if (target ~= nil) then
--         local extraRange = 0;
--         if (bbox) then
--             extraRange = target.boundingRadius;
--         end
--         if (GetDistance(target, myHero) > range + extraRange or func(target) == false) then
--             target = nil;
--         end
--     end
--     if (target == nil) then
--         target = LocalSDK.TargetSelector:GetTarget(LocalSDK.ObjectManager:GetEnemyHeroes(range, bbox, hType, func), dType);
--     end
--     if (target) then
--         Control.CastSpell(hkSpell, target);
--     end
-- end

-- local function CastSkillShot(hkSpell, sData, dType, hType, bbox, hc, func)
--     local target = LocalSDK.TargetSelector:GetComboTarget();
--     local range = sData.Range - 35;
--     if (bbox) then
--         range = range + myHero.boundingRadius;
--     end
--     if (target ~= nil) then
--         local extraRange = 0;
--         if (bbox) then
--             extraRange = target.boundingRadius;
--         end
--         if (GetDistance(target, myHero) > range + extraRange or func(target) == false) then
--             target = nil;
--         end
--     end
--     if (target == nil) then
--         target = LocalSDK.TargetSelector:GetTarget(LocalSDK.ObjectManager:GetEnemyHeroes(range, bbox, hType, func), dType);
--     end
--     if (target) then
--         local Pred = GetGamsteronPrediction(target, sData, myHero);
--         if (Pred.Hitchance >= hc) then
--             Control.CastSpell(hkSpell, Pred.CastPosition);
--         end
--     end
-- end

-- local function RLogic()
--     local spell = myHero.activeSpell;
--     if (spell and spell.valid and spell.name:lower() == "jhinr") then
--         champInfo.hasRBuff = true;
--         if (rData.canDraw == false and Game.Timer() > LocalSDK.Spells.LastRk + 0.250) then
--             rData.canDraw = true;
--             local middlePos = Vector(spell.placementPos);
--             local startPos = Vector(spell.startPos);
--             local pos1 = startPos + (middlePos - startPos):Rotated(0, 30.6 * math.pi / 180, 0):Normalized() * 3500;
--             local pos2 = startPos + (middlePos - startPos):Rotated(0, -30.6 * math.pi / 180, 0):Normalized() * 3500;
--             rData.polygon =
--             {
--                 pos1 + (pos1 - startPos):Normalized() * 3500,
--                 pos2 + (pos2 - startPos):Normalized() * 3500,
--                 startPos,
--             };
--             rData.middle = middlePos;
--             rData.pos1 = pos1;
--             rData.pos2 = pos2;
--             rData.startPos = startPos;
--         end
--         if (rData.canDraw == true and Menu.autor:Value() and LocalSDK.Spells:IsReady(_R, {q = 0, w = 0, e = 0, r = 0.75})) then
--             local rTargets = {};
--             local enemyList = LocalSDK.ObjectManager:GetEnemyHeroes(3500, false, HEROES_SPELL);
--             for i, unit in pairs(enemyList) do
--                 if (InsidePolygon(rData.polygon, unit) == true) then
--                     table.insert(rTargets, unit);
--                 end
--             end
--             local rTarget = LocalSDK.TargetSelector:GetTarget(rTargets, 0);
--             if (rTarget) then
--                 local HitChance = 3;
--                 local Pred = GetGamsteronPrediction(rTarget, spellData.r, myHero);
--                 if (Pred.Hitchance >= HitChance and InsidePolygon(rData.polygon, Pred.CastPosition) == true) then
--                     Control.CastSpell(HK_R, Pred.CastPosition);
--                 end
--             end
--         end
--     elseif (champInfo.hasRBuff == true and rData.canDraw == true and Game.Timer() > LocalSDK.Spells.LastRk + 0.500) then
--         champInfo.hasRBuff = false;
--         rData.canDraw = false;
--     elseif (Game.Timer() < LocalSDK.Spells.LastRk + 0.35) then
--         champInfo.hasRBuff = true;
--     elseif champInfo.hasRBuff then
--         champInfo.hasRBuff = false;
--     end
-- end
AddLoadCallback(function()
	print("texttttt");
end)

LocalSDK.Orbwalker:CanAttackEvent(function()
    if (LocalSDK.Spells:CheckSpellDelays({q = 0.250, w = 0.750, e = 0.250, r = 0.500}) and champInfo.hasPBuff == false and champInfo.hasRBuff == false) then
        return true;
    end
    return false;
end)

LocalSDK.Orbwalker:CanMoveEvent(function()
    if (LocalSDK.Spells:CheckSpellDelays({q = 0.150, w = 0.600, e = 0.150, r = 0.500}) and champInfo.hasRBuff == false) then
        return true;
    end
    return false;
end)
    
-- AddLoadCallback(function()
--     _G.GamsteronMenuSpell.isaaa:Value(true);
--     -- TICK
--     Callback.Add('Draw', function()
--         -- p
--         champInfo.hasPBuff = HasBuff(myHero, "jhinpassivereload");
--         -- r
--         RLogic();
--         -- qwe
--         if (champInfo.hasRBuff) then
--             return;
--         end
--         -- after attack
--         if (Bool(champInfo.hasPBuff or LocalSDK.Orbwalker:CanMoveSpell())) then
--             -- q
--             if (IsReadyCombo(_Q, Menu.qset.combo:Value(), Menu.qset.harass:Value(), {q = 1, w = 0.75, e = 0.35, r = 0.5, })) then
--                 CastTarget(
--                     HK_Q,
--                     spellData.q,
--                     DAMAGE_TYPE_PHYSICAL,
--                     true,
--                     HEROES_SPELL,
--                     function(unit)
--                         return true;
--                     end
--                 );
--             end
--             -- w
--             if (IsReadyCombo(_W, Menu.wset.combo:Value(), Menu.wset.harass:Value(), {q = 0.35, w = 1, e = 0.35, r = 0.5, })) then
--                 CastSkillShot(
--                     HK_W,
--                     spellData.w,
--                     DAMAGE_TYPE_PHYSICAL,
--                     false,
--                     HEROES_SPELL,
--                     HITCHANCE_HIGH,
--                     function(unit)
--                         if (Menu.wset.stun:Value()) then
--                             if (HasBuff(unit, "jhinespotteddebuff")) then
--                                 return true;
--                             end
--                             return false;
--                         end
--                         return true;
--                     end
--                 );
--             end
--             -- e
--             if (IsReadyCombo(_E, Menu.eset.combo:Value(), Menu.eset.harass:Value(), {q = 0.35, w = 0.75, e = 1, r = 0.5, })) then
--                 local target = GetImmobileEnemy(spellData.e.Range, 0.5);
--                 if (target) then
--                     Control.CastSpell(HK_E, target.pos);
--                 elseif (not Menu.eset.onlyimmo:Value()) then
--                     CastSkillShot(
--                         HK_E,
--                         spellData.e,
--                         DAMAGE_TYPE_PHYSICAL,
--                         false,
--                         HEROES_SPELL,
--                         HITCHANCE_HIGH,
--                         function(unit)
--                             return true;
--                         end
--                     );
--                 end
--             end
--         end
--     end)
    
    -- DRAW
    -- local set = 0;
    -- Callback.Add('Draw', function()
    --     --[===============[
    --     local str = "";
    --     local sd = myHero:GetSpellData(_W);
    --     for i, k in pairs(sd) do
    --         str = str .. i .. ": " .. k .. "\n";
    --     end
    --     str = str .. tostring(sd.ammoTime - Game.Timer());
    --     Draw.Text(str, myHero.pos:To2D())
    --     local s = myHero.activeSpell;
    --     if s and s.valid then
    --         set = s.startTime;
    --     end
    --     local et = Game.Timer() - set - 0.067;
    --     if et > 0.8 and et < 0.9 then
    --         print(et);
    --     end
    --     --]===============]
    --     if rData.canDraw then
    --         local p1 = rData.startPos:To2D()
    --         local p2 = rData.pos1:To2D()
    --         local p3 = rData.pos2:To2D()
    --         Draw.Line(p1.x, p1.y, p2.x, p2.y, 1, Draw.Color(255, 255, 255, 255))
    --         Draw.Line(p1.x, p1.y, p3.x, p3.y, 1, Draw.Color(255, 255, 255, 255))
    --     end
    -- end)
-- end)
