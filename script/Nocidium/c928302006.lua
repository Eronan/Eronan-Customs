--Voice of Maris
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names={928302000}
s.counter_place_list={0x10fc}
--Special Summon as Effect monster
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,0,2500,8,RACE_AQUA,ATTRIBUTE_EARTH,POS_FACEUP,tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and s.sptg(e,tp,eg,ep,ev,re,r,rp,0) then
		c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
		Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
		--Negate face-up cards the opponent controls
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_COUNTER)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetTarget(s.cttg)
		e1:SetOperation(s.ctop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		--Allow summon from deck
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_RUNE_LOCATION)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,928302000))
		e2:SetTargetRange(LOCATION_DECK,0)
		e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:AddMonsterAttributeComplete()
	end
	Duel.SpecialSummonComplete()
end
--Nocidium Counter
function s.ctfilter(c)
	return c:IsFaceup() and not c:IsCode(id)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
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
        e2:SetRange(LOCATION_MZONE)
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
--activate from hand
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end