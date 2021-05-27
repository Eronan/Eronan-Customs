--Botnet Commander
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,s.MonMatFilter,1,1,aux.FilterBoolFunction(Card.IsSetCard,0xfe7),1,1)
	--cannot change position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1)
	--swap2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(2)
	e2:SetTarget(s.adtg)
	e2:SetOperation(s.adop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfe7}
function s.MonMatFilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefenseAbove(0) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefenseAbove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsDefenseAbove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SWAP_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SWAP_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
