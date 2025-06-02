--Mithosigil Space
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
    --activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.runop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
    --Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
    --Negate effect and flip face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_names={932038020}
s.listed_series={0xfc4}
--Rune Summon
function s.runfilter(c,mg)
	return c:IsSetCard(0xfc4) and c:IsRuneSummonable(nil,mg,2,2)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) or Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>1 then return end
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_HAND,0,nil,mg)
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.RuneSummon(tp,sc,nil,mg,2,2)
	end
end
--Can be activated from the hand
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
--Negate and flip face-down
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(932038020)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
        and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rc=re:GetHandler()
	if chk==0 then return s.disfilter(rc) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,rc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,rc,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if s.disfilter(tc) then
        Duel.NegateRelatedChain(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
        Duel.BreakEffect()
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end