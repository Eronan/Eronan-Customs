--Skaldia Underworld Chanter
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon procedure
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsAttribute),ATTRIBUTE_EARTH),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc2),1,1,nil,s.exgroup)

	--Effect 1: Quick Rune Summon from hand during opponent's Main Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hdcon)
	e1:SetCost(s.hdcost)
	e1:SetTarget(s.hdtg)
	e1:SetOperation(s.hdop)
	c:RegisterEffect(e1)

	--Effect 2: SS Tuner from GY, then Synchro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.syncon)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc2}

--Extra material group: allow hand if opponent controls a Special Summoned monster
function s.exgroup(tp,ex,c)
	if Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil) then
		return Duel.GetMatchingGroup(Card.IsCanBeRuneMaterial,tp,LOCATION_HAND,0,nil,c)
	end
	return Group.CreateGroup()
end

--Condition: Opponent's Main Phase
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end

--Cost: Pay 500 LP + reveal this card
function s.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and not e:GetHandler():IsPublic() end
	Duel.PayLPCost(tp,500)
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

--Send Skaldia monster to GY
function s.tgfilter(c)
	return c:IsSetCard(0xfc2) and c:IsMonster() and c:IsAbleToGrave()
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and c:IsRuneSummonable() then
			Duel.BreakEffect()
			Duel.RuneSummon(tp,c)
		end
	end
end

--Condition: Must be Rune Summoned
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end

--Target: 1 Tuner in GY
function s.synfilter(c,e,tp)
    local mg=Group.FromCards(e:GetHandler(),c)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,mg,mg,2,2)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.synfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.synfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

--Operation: Special Summon Tuner and immediately Synchro Summon
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		--Immediately Synchro Summon
        local mg=Group.FromCards(c,tc)
        local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,mg,mg,2,2)
		if #g>0 then
			Duel.BreakEffect()
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			if sc then
				Duel.SynchroSummon(tp,sc,nil,mg,mg,2,2)
			end
		end
	end
end
