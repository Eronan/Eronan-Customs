--Warden of Elysiance Harmony
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
    --Add banished card to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e4:SetCondition(s.excon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --special summon cost
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SPSUMMON_COST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(1,1)
	e5:SetCost(s.costchk)
	e5:SetOperation(s.costop)
	c:RegisterEffect(e5)
    --destroy replace
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_DESTROY_REPLACE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTarget(s.desreptg)
    e6:SetValue(s.desrepval)
    e6:SetOperation(s.desrepop)
    c:RegisterEffect(e6)
end
--special summon condition
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--pendulum scale
function s.excon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)<=7
end
--add to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToHand() end
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,nil) and c:IsAbleToHand() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT) and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
--special summon cost
function s.costchk(e,te,tp,sumtyp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)<=7 or Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_EXTRA|LOCATION_HAND,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)<=7 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_EXTRA|LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end
--destroy replace
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
    return c:IsControler(tp) and c:IsDestructable(e)
        and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and g:IsExists(s.desfilter,1,nil,e,tp) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
        local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
        e:SetLabelObject(sg:GetFirst())
        Duel.HintSelection(sg)
        sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
        return true
    else return false end
end
function s.desrepval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
    Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end