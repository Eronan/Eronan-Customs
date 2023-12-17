--IncantLeech Lure
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_series={0xfda}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.runfilter(c,tc,mg)
	return c:IsType(TYPE_RUNE) and c:IsSetCard(0xfda) and c:IsRuneSummonable(tc,mg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	--Negate Effect
	if not Duel.NegateEffect(ev) then return end
	--Rune Summmon
	Debug.Message(tc:IsCanBeRuneMaterial())
	local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil)
	mg:AddCard(tc)
	if tc:IsCanBeRuneMaterial() and tc:IsLocation(LOCATION_ONFIELD) and Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,tc,mg)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND,0,1,1,nil,tc,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,tc,mg)
		end
	end
end
function s.handcon(e)
    local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_CHAINING,true)
    if res then
		local ex1,tg1,tc1=Duel.GetOperationInfo(tev,CATEGORY_DISABLE)
		local ex2,tg2,tc2=Duel.GetOperationInfo(tev,CATEGORY_NEGATE)
        return (ex1 or ex2) and (tg1~=nil or tg2~=nil) and (tc1~=nil or tc2~=nil)
    end
end
