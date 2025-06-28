--Proxumia Aeromant - Mantrassid
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL),1,1)
    c:EnableReviveLimit()
	--You can only Special Summon once per turn
    c:SetSPSummonOnce(id)
	--Apply the effects of a  1 Ritual Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(s.applycost)
	e1:SetCondition(s.applycon)
	e1:SetTarget(s.applytg)
	e1:SetOperation(s.applyop)
	c:RegisterEffect(e1)
    --Allow linked monster as whole Tribute
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.rittg)
    e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(Ritual.WholeLevelTributeValue(s.ritval))
	c:RegisterEffect(e2)
end
s.listed_series={0xfc3}
--Apply the effects of a  1 Ritual Spell
function s.applycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.applyfilter(c)
	return c:IsRitualSpell() and not c:IsPublic() and c:CheckActivateEffect(true,true,false)~=nil
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.applyfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.applyfilter,tp,LOCATION_HAND,0,1,nil) end
	--Reveal card in hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.applyfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
	-- Ritual Summon Target
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end
--Allow linked monster as whole Tribute
function s.rittg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.ritval(c,e)
    return c:IsSetCard(0xfc3) and c:IsControler(e:GetHandlerPlayer())
end