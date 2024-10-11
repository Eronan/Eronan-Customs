--Arctic Elysiance Moth
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c,true)
    c:EnableReviveLimit()
    --Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --scale
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.excon)
	e2:SetValue(13)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
    --Place 1 pendulum monster from extra deck into pendulum zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e4:SetCondition(s.excon)
	e4:SetTarget(s.pctg)
	e4:SetOperation(s.pcop)
	c:RegisterEffect(e4)
    --activate cost
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_ACTIVATE_COST)
    e5:SetRange(LOCATION_MZONE)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetTargetRange(0,1)
    e5:SetTarget(s.costtg)
    e5:SetCost(s.costchk)
    e5:SetOperation(s.costop)
    c:RegisterEffect(e5)
    --accumulate
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(id)
    e6:SetRange(LOCATION_MZONE)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetTargetRange(0,1)
    c:RegisterEffect(e6)
    --immune
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_ONFIELD,0)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc5))
	e7:SetValue(s.efilter)
	c:RegisterEffect(e7)
end
s.listed_series={0xfc5}
--special summon condition
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--pendulum scale
function s.excon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)<=7
end
--place in pendulum zone
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not Duel.SendtoHand(c,nil,REASON_EFFECT) then return end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--Activate cost
function s.costtg(e,te,tp)
    return te:IsSpellTrapEffect() and te:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)>7
end
function s.costfilter(c)
    return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end
function s.costchk(e,te,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end
--immune effect
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return #g==0
end