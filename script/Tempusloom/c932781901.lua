--Tempusloom Sorcerer
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunction(nil),1,1)
    c:EnableReviveLimit()
    --Change effect to apply during End Phase
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_MZONE|LOCATION_HAND)
	e1:SetCondition(s.chcon)
	e1:SetCost(s.chcost)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
    --Place Continuous Spell Trap face-up
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.regcon)
    e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
end
--Change to End Phase effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&(LOCATION_ONFIELD|LOCATION_GRAVE))~=0 and re:IsActiveType(TYPE_MONSTER)
        and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and not Duel.IsPhase(PHASE_END)
end
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
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
--Place Continuous Spell/Trap in Spell & Trap Zone
function s.regcon(e,c)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
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
    e1:SetTarget(s.tftg)
    e1:SetOperation(s.tfop)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.tffilter(c,tp)
	return c:IsSpellTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and c:IsType(TYPE_CONTINUOUS)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
