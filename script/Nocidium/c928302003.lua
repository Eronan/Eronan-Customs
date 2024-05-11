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
	--Place Nocidium Counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
	--Move Nocidium Counter to another card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.ctcost2)
	e4:SetTarget(s.cttg2)
	e4:SetOperation(s.ctop2)
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
s.listed_names={928302001,928302004}
s.counter_place_list={0x10fc}
--Place Nocidium Counter on your opponent's monster
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    --Place counter on all Special Summoned monster(s)
	local g=eg:Filter(Card.IsFaceup,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(0x10fc,1)
		if tc:GetFlagEffect(0x10fc)==0 then
			local c=e:GetHandler()
			--destroy replace
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
end
--move Nocidium counter
function s.ctcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x10fc,1,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,0x10fc,1,REASON_COST)
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) 
		and not c:HasFlagEffect(id) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	c:RegisterFlagEffect(id,RESET_PHASE|PHASE_DRAW|PHASE_STANDBY|PHASE_MAIN1|PHASE_BATTLE|PHASE_MAIN2|PHASE_END,0,0)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x10fc,1)
		if tc:GetFlagEffect(0x10fc)~=0 then return end
		local c=e:GetHandler()
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
--Special Summon "Tempest, Emberwind Acolyte"
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