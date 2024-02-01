--Tempusloom Seeressa
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,0xfcd),1,1,Rune.STFunctionEx(Card.IsType,TYPE_CONTINUOUS),1,1)
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
    e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.immcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.regcon)
	e3:SetTarget(s.regtg)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfcd}
--replace effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:IsActiveType(TYPE_MONSTER) and (re:GetActivateLocation()&(LOCATION_ONFIELD|LOCATION_GRAVE))>0
        and not Duel.IsPhase(PHASE_END)
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
            if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and g then
                Duel.SetTargetCard(g)
            end
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
--Immune
function s.immcon(e)
    return Duel.IsPhase(PHASE_END)
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
--Special Summon
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and rp==1-tp
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,nil,e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,1,nil,e,0,tp,false,false)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end