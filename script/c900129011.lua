--IncantLeech Dragonbee
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,99,Rune.STFunction(nil),1,1)
	--inactivatable
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.effectfilter)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.effectfilter)
    c:RegisterEffect(e2)
	--rune summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.runcon)
	e3:SetTarget(s.runtg)
	e3:SetOperation(s.runop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfda}
function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and (loc&LOCATION_ONFIELD)~=0 and tc:IsFaceup() and tc:IsSetCard(0xfda)
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
