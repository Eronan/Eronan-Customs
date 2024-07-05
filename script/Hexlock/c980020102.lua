--Hexlock Disaster
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSummonType,SUMMON_TYPE_SPECIAL),1,1,Rune.STFunction(s.stfilter),1,1)
    c:EnableReviveLimit()
    --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
    --Lockdown face-down cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.lkcon)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.kop)
	c:RegisterEffect(e2)
end
--Rune Summon
function s.stfilter(c,rc,sumtype,tp)
    return c:IsSetCard(rc,sumtype,tp) and c:IsTrap()
end
--act limit
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    Duel.SetChainLimit(s.chainlm(g))
end
function s.chainlm(g)
    return function (e,rp,tp)
        return tp==rp and not g:IsContains(e:GetHandler())
    end
end
--Lockdown face-down cards
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFacedown() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
    Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,2,nil)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    for tc in aux.Next(g) do
        if tc:IsRelateToEffect(e) and tc:IsFacedown() then
            c:SetCardTarget(tc)
            --Cannot activate
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetCondition(s.ctcon)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            tc:RegisterEffect(e2)
            local e3=e1:Clone()
            e3:SetCode(EFFECT_CANNOT_RELEASE)
            tc:RegisterEffect(e3)
            local e4=e1:Clone()
            e4:SetCode(EFFECT_CANNOT_RELEASE)
            tc:RegisterEffect(e4)
            local e5=e1:Clone()
            e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
            e5:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION))
            e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            tc:RegisterEffect(e5)
        end
    end
end
function s.ctcon(e)
    local c=e:GetOwner()
    local h=e:GetHandler()
    return c:IsHasCardTarget(h)
end