--Greenwood Behemoth
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--rune summon
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunction(nil),1,1)
	c:EnableReviveLimit()
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.runtg)
	e1:SetOperation(s.runop)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSpellTrap))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--remove
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandlerPlayer()~=e:GetHandlerPlayer() and e:GetHandler():IsRuneSummonable() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRuneSummonable() then return false end
	Duel.RuneSummon(tp,c)
end
function s.efilter(e,re)
	if e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return #g==0
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
