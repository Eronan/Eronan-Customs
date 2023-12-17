--Binate MalNet Overload
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum summon
	Pendulum.AddProcedure(c)
	--Gemini
	Gemini.AddProcedure(c)
	--Change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetValue(912389041)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e4:SetCondition(Gemini.EffectStatusCondition)
	e4:SetTarget(s.runtg)
	e4:SetOperation(s.runop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfe7}
s.listed_names={912389041}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then return end
	local token=Duel.CreateToken(tp,999999996)
	if Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP) and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		e:GetHandler():EnableGeminiState()
	end
end
function s.runfilter(c,mg)
	return c:IsType(TYPE_RUNE) and c:IsRuneSummonable(nil,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil):Merge(Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil,0xfe7))
	if chk==0 then return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
		mg:Merge(Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsCanBeRuneGroup),tp,0,LOCATION_ONFIELD,nil,0xfe7))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,nil,mg)
		end
	end
end
