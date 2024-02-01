--Tempusloom Companion
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Add Rune monster to hand
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.regtg)
	e1:SetOperation(s.regop)
    c:RegisterEffect(e1)
    --Change effect to apply during End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(s.chcon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
    return c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&(LOCATION_ONFIELD|LOCATION_GRAVE))~=0 and re:IsActiveType(TYPE_MONSTER)
        and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and not Duel.IsPhase(PHASE_END)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.repop(re))
end
function s.repop(te)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        local condition=function (ne,ntp,neg,nep,nev,nre,nr,nrp) return not te:GetTarget() or te:GetTarget()(ne,tp,eg,ep,ev,re,r,rp,0) end
        local operation=function (ne,ntp,neg,nep,nev,nre,nr,nrp)
            Duel.Hint(HINT_CARD,1-te:GetHandlerPlayer(),te:GetHandler():GetCode())
            Duel.SetTargetPlayer(p)
            Duel.SetTargetParam(d)
            ne:GetHandler():CreateEffectRelation(ne)
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