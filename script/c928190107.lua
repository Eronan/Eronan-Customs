--Vines into Bloom
local s,id=GetID()
function s.initial_effect(c)
	--replace opponent monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Re-Special Summon "Vestas of Parasitic Bloom"
	-- Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e4)
end
s.listed_names={928190100}
s.listed_card_types={TYPE_GEMINI}
--replace monster without level
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_GEMINI)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(c,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) and Duel.CheckReleaseGroup(1-tp,nil,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
    local g=Duel.SelectReleaseGroup(1-tp,nil,1,1,nil)
    if g and Duel.Release(g,REASON_RULE,1-tp) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
			Duel.SpecialSummonComplete()
		end
    end
end
--Re-Summon
function s.cfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return re:GetHandlerPlayer()==e:GetHandlerPlayer() and re:GetHandler():IsCode(928190100)
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsCode(928190100)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		g:Match(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
		if #g==0 then return end
		if #g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,1,1,nil)
		end
		for tc in g:Iter() do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				tc:EnableGeminiStatus()
			end
		end
		Duel.SpecialSummonComplete()
	end
end
