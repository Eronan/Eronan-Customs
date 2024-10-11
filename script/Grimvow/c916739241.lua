--Judgment of the Grimvow
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsOnField),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc6),1,1,LOCATION_GRAVE)
    c:EnableReviveLimit()
    --Take control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
    --activate cost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ACTIVATE_COST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1)
    e2:SetTarget(s.costtg)
    e2:SetCost(s.costchk)
    e2:SetOperation(s.costop)
    c:RegisterEffect(e2)
    --accumulate
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(id)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(0,1)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc6}
--Take control of opponent's monster
function s.ctfilter(c)
    return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
        and not tc:IsImmuneToEffect(e) then
        c:SetCardTarget(tc)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_CONTROL)
        e1:SetValue(tp)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetCondition(s.ctcon)
        tc:RegisterEffect(e1)
    end
end
function s.ctcon(e)
    local c=e:GetOwner()
    local h=e:GetHandler()
    return c:IsHasCardTarget(h)
end
--Activate cost
function s.costtg(e,te,tp)
    return te:IsHasCategory(CATEGORY_REMOVE) or te:IsHasCategory(CATEGORY_DESTROY)
end
function s.costchk(e,te,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD|LOCATION_HAND,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEDOWN,REASON_COST)
    end
end