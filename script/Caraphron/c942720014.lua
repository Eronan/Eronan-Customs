--Caraphron Vanquistrix
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon procedure
    c:EnableReviveLimit()
    -- 1 non-Token Insect monster + 1+ "Caraphron" Spell card
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(Card.IsEquipSpell),1,99)
    --Continuous Negation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.ctrtg)
	c:RegisterEffect(e1)

    --(2) When 2+ monsters sent to GY or this card sent to GY: equip a Caraphron Equip Spell from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.eqcon1)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc0}

--==========================
--Rune Summon materials
--==========================
function s.monfilter(c,rc,sumtype,tp)
    return not c:IsType(TYPE_TOKEN) and c:IsRace(RACE_INSECT,rc,sumtype,tp)
end

--==========================
--Effect 2: Take control of equipped monsters
--==========================
function s.ctrtg(e,c)
    return c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0xfc0)
end

--==========================
--Effect 2: equip from GY
--==========================
function s.eqconfilter(c,tp)
    return c:IsSummonLocation(LOCATION_EXTRA) and c:IsControler(1-tp)
end
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.eqconfilter,1,nil,tp)
end
function s.gyfilter(c)
	return c:IsSetCard(0xfc0) and c:IsSSetable()
end
function s.eqfilter(c,ec)
    return ec:CheckEquipTarget(c)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tg=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=tg:GetFirst()
    if tc:IsEquipSpell() then Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,g,1,0,0) end
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	if tc:IsEquipSpell() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        --Equip to an appropriate monster instead
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
		Duel.Equip(tp,tc,ec:GetFirst())
	else
        -- Set to the field
		Duel.SSet(tp,tc)
	end
end