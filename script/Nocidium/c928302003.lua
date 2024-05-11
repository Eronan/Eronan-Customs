--Tempest, Emberwind Sage
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --spsummon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.ritlimit)
    c:RegisterEffect(e1)
    --Place 1 Nocidium Counter on your opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
    --prevent removal of opponent's Nocidium counters on negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
    --Special summon 1 "Maris, Aquamire Mystic"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={928302001,928302004}
s.counter_place_list={0x10fc}
--Place Nocidium Counter on your opponent's monster
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:GetHandler():IsOnField() and (re:IsActiveType(TYPE_MONSTER)
        or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=re:GetHandler()
	if tc:IsFaceup() and tc:IsOnField() then
		tc:AddCounter(0x10fc,1)
		if tc:GetFlagEffect(0x10fc)~=0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(s.reptg)
		e1:SetOperation(s.repop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
        --disable
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_CHAIN_SOLVING)
        e2:SetRange(LOCATION_MZONE|LOCATION_SZONE)
        e2:SetCondition(s.discon)
        e2:SetOperation(s.disop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(0x10fc,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
--destroy replace
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE) and e:GetHandler():GetCounter(0x10fc)>0 end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():RemoveCounter(tp,0x10fc,1,REASON_EFFECT)
end
--disable
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()~=e:GetHandler() or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:GetHandler():GetCounter(0x10fc)>0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and not Duel.IsPlayerAffectedByEffect(tp,id) then
		Duel.BreakEffect()
		e:GetHandler():RemoveCounter(tp,0x10fc,1,REASON_EFFECT)
	end
end
--Special Summon "Maris, Aquamire Mystic"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(928302001) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end