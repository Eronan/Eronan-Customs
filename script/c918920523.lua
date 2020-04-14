--Contaminet Ransomware
Duel.LoadScript("proc_rune.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1fe7),1,1,aux.FilterBoolFunction(Card.IsCode,912389041),1,nil,nil,s.getGroup)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
s.listed_series={0x1fe7}
s.listed_names={912389041}
function s.getGroup(tp,ex)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ex)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1fe7) and c:IsAbleToChangeControler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if Duel.GetLP(1-tp)>1500 then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(1-tp,1500) and Duel.SelectYesNo(1-tp,aux.Stringid(80764541,1)) then
		Duel.PayLPCost(1-tp,1500)
		if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
			return
		end
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
