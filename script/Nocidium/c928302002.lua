--Maris, Aquamire Crater Celsitial
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,99,Rune.STFunction(nil),2,99,nil,s.exgroup,nil,nil,nil,s.customop)
    c:EnableReviveLimit()
    --Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
    --Cannot negate activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.effval)
	c:RegisterEffect(e2)
    --Place 1 Nocidium Counter on a monster you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(_,tp,_,ep) return ep==1-tp end)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(function(_,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	c:RegisterEffect(e4)
    --Special summon 1 "Maris, Aquamire Mystic"
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={928302000}
s.counter_place_list={0x10fc}
--Rune Summon
function s.mfilter(c,rc,sumtyp,tp)
    return c:IsRitualMonster() and c:IsOnField()
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--Cannot negate activated effects
function s.effval(e,ct)
	local re=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    local rc=re:GetHandler()
    if not (re:GetHandlerPlayer()==e:GetHandlerPlayer() and re:GetActivateLocation()==LOCATION_MZONE) then return false end
	return re:GetHandler():GetCounter(0x10fc)>0
end
--Place a Nocidium Counter on a monster
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
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
	if Duel.NegateEffect(ev) then
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
	return c:IsCode(928302000) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
	end
end