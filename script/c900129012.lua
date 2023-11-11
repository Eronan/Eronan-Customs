--IncantLeech Dragonfly
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunction(nil),1,99)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfda))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--rune summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.runcon)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfda}
function s.efilter(e,te)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return g and #g>0
end
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.runfilter(c,must,mg)
	return c:IsType(TYPE_RUNE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRuneSummonable(must,mg)
end
function s.mtfilter(tc,c,tp)
	local must=Group.FromCards(c,tc)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	mg:AddCard(must)
	return tc:IsFaceup() and tc:IsCanBeRuneMaterial() and Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,must,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.mtfilter(chkc,e:GetHandler(),tp) end
	if chk==0 then return Duel.IsExistingTarget(s.mtfilter,tp,0,LOCATION_ONFIELD,1,nil,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.mtfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local must=Group.FromCards(c,tc)
		local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
		mg:AddCard(must)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND,0,1,1,nil,must,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,must,mg)
		end
	end
end
