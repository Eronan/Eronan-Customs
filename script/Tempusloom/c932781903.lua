--Tempusloom Lunaeon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunctionEx(Card.IsType,TYPE_CONTINUOUS),1,1)
    c:EnableReviveLimit()
    --All effects change to apply during the End Phas
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.chcon)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
    --immune
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e2:SetCondition(s.immcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --destroy all cards your opponent controls and in hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfcd}
--Rune Summon
function s.monfilter(c,rc,sumtyp,tp)
    return c:IsType(TYPE_RUNE,rc,sumtyp,tp) and c:IsSetCard(0xfcd)
end
--replace effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetOperation() or Duel.IsPhase(PHASE_END) then return false end
    local retype=re:GetActiveType()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) then
        return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (retype==TYPE_SPELL or retype==TYPE_TRAP or re:IsActiveType(TYPE_QUICKPLAY))
    else
        return (re:GetActivateLocation()&(LOCATION_ONFIELD|LOCATION_GRAVE))>0
    end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.repop(re))
end
function s.repop(te)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        if g then
            g=g:Filter(Card.IsRelateToEffect,nil,e)
            g:KeepAlive()
        end
        local condition=function (ne,ntp,neg,nep,nev,nre,nr,nrp) return not te:GetTarget() or te:GetTarget()(ne,tp,eg,ep,ev,re,r,rp,0) end
        local operation=function (ne,ntp,neg,nep,nev,nre,nr,nrp)
            Duel.Hint(HINT_CARD,1-te:GetHandlerPlayer(),te:GetHandler():GetCode())
            Duel.SetTargetPlayer(p)
            Duel.SetTargetParam(d)
            ne:GetHandler():CreateEffectRelation(ne)
            if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and g then
                Duel.SetTargetCard(g)
            end
            te:GetOperation()(ne,tp,eg,ep,ev,re,r,rp)
        end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabel(te:GetLabel())
        e1:SetLabelObject(te:GetLabelObject())
        e1:SetCondition(condition)
        e1:SetOperation(operation)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,te:GetHandlerPlayer())
    end
end
--Immune
function s.immcon(e)
    return Duel.IsPhase(PHASE_END)
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
--destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)
        and Duel.GetTurnPlayer()~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
    if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end