--Caraphron Exuvion
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon procedure
    c:EnableReviveLimit()
    -- 1 Effect monster that cannot be Normal Summoned/Set + 1 "Caraphron" Spell card
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(s.stfilter),1,1)

    --(1) Quick Effect: Equip 1 "Caraphron" Equip Spell from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    --(2) When sent to GY: Equip 1 Caraphron Equip Spell from GY to appropriate monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)

    --Board control effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetOperation(s.ctrlop)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc0}
--==========================
--Rune Summon materials
--==========================
function s.monfilter(c,rc,sumtype,tp)
    return not c:IsSummonableCard() and c:IsType(TYPE_EFFECT)
end
function s.stfilter(c,rc,sumtype,tp)
    return c:IsSetCard(0xfc0) and c:IsSpell()
end
--==========================
--Effect 1: Quick Equip from GY
--==========================
function s.eqfilter(c,tp)
    return c:IsSetCard(0xfc0) and c:IsType(TYPE_EQUIP)
        and Duel.IsExistingTarget(s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.eqcheck(c,ec)
    return ec:CheckEquipTarget(c)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local mg=Duel.SelectMatchingCard(tp,s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
        if #mg>0 then
            Duel.Equip(tp,tc,mg:GetFirst())
        end
    end
end

--==========================
--Effect 2: Quick Equip from GY
--==========================
function s.gyfilter(c)
	return c:IsSetCard(0xfc0) and c:IsSSetable()
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
	if tc:IsEquipSpell() and Duel.IsExistingMatchingCard(s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        --Equip to an appropriate monster instead
		local ec=Duel.SelectMatchingCard(tp,s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
		Duel.Equip(tp,tc,ec:GetFirst())
	else
        -- Set to the field
		Duel.SSet(tp,tc)
	end
end

--==========================
--Effect 3: Grant control effect to equip spells.
--==========================
function s.ctrltg(_,tc)
    return tc:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0xfc0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
    -- Apply a flag to indicate the effects are active, with a client hint for the player
    local reapply=Duel.GetFlagEffect(tp,id)>0
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2)
    
    local effs = s[tp]
    -- If effects already exist, extend them
    if effs and reapply then
        effs.control:SetReset(RESET_PHASE+PHASE_END,2)
        effs.race:SetReset(RESET_PHASE+PHASE_END,2)
        return
    end

    local c=e:GetHandler()
    -- Otherwise, apply them for the first time
    local control=Effect.CreateEffect(c)
    control:SetDescription(aux.Stringid(id,3))
    control:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    control:SetType(EFFECT_TYPE_FIELD)
    control:SetCode(EFFECT_SET_CONTROL)
    control:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    control:SetTarget(s.ctrltg)
    control:SetValue(tp)
    control:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(control,tp)

    local race=Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_FIELD)
    race:SetCode(EFFECT_CHANGE_RACE)
    race:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    race:SetTarget(s.ctrltg)
    race:SetValue(RACE_INSECT)
    race:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(race,tp)

    -- Store both effects globally for this player
    s[tp] = {
        control = control,
        race = race
    }
end
