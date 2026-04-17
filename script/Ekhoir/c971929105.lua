--Ekhoir Sacred Silence
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd

function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Activation condition: control an Ekhoir monster or reveal one in hand
function s.cfilter(c)
    return c:IsSetCard(SET_EKHOIR) and c:IsType(TYPE_RUNE)
end
function s.handfilter(c)
    return c:IsSetCard(SET_EKHOIR) and c:IsMonster() and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,SET_EKHOIR)
    local b2=Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil)
    if chk==0 then return b1 or b2 end
    if not b2 then return end
    if b1 and not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
end

--Target all monsters your opponent controls when activated
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end

--Operation: disable the targeted monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:CancelToGrave()
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        c:SetCardTarget(tc)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetLabelObject(c)
        e1:SetCondition(s.discon)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end

    --Destroy during opponent's End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetLabelObject()
    return ec:HasFlagEffect(id) and ec:IsHasCardTarget(e:GetHandler())
end
--Destroy this card during opponent's End Phase
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end