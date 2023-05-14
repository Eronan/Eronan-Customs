--Ulano, Winged Subshifter
local s,id=GetID()
function s.initial_effect(c)
	--ritual
	c:EnableReviveLimit()
	--activate cost
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ACTIVATE_COST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetCost(s.costchk)
	e1:SetTarget(s.costtg)
    e1:SetOperation(s.costop)
    c:RegisterEffect(e1)
	--accumulate
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(id)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1)
    c:RegisterEffect(e2)
	--banish card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Link summon 1 link monster during opponent's main phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.costchk(e,te_or_c,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.CheckLPCost(tp,ct*500)
end
function s.costtg(e,te,tp)
	return te:GetActivateLocation()~=LOCATION_ONFIELD
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.PayLPCost(tp,500)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsPlayerAffectedByEffect(1-tp,69832741) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil))
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g
	if Duel.IsPlayerAffectedByEffect(1-tp,69832741) then
		g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	else
		g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	end
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.spfilter(c,must)
	return c:IsSetCard(0xfd3) and c:IsLinkSummonable(must)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),c)
	end
end
