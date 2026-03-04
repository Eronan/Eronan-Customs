--Litos Fault Line
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    --------------------------------------------------
    --(1) Activate 1 "Litos" Field Spell from Deck,
    --    then immediately Rune Summon 1 "Litos" monster from hand
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.fldtg)
    e1:SetOperation(s.fldop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    --(2) When opponent activates a monster effect,
    --    while you control a "Litos" Rune monster (Quick Effect):
    --    Return that monster to the hand. HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetCondition(s.bncon)
    e2:SetTarget(s.bntg)
    e2:SetOperation(s.bnop)
    c:RegisterEffect(e2)
end
s.listed_series={0xfbf}

--------------------------------------------------
-- Activation condition: no cards in your Field Zone,
-- allows activation from hand
--------------------------------------------------
function s.actcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)==0
end

--------------------------------------------------
-- (1) Activate Field Spell from Deck, then Rune Summon from hand
--------------------------------------------------
function s.fldfilter(c,tp)
    return c:IsSetCard(0xfbf) and c:IsFieldSpell()
end
function s.runfilter(c)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE) and c:IsRuneSummonable()
end
function s.fldtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.fldfilter,tp,LOCATION_DECK,0,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.fldop(e,tp,eg,ep,ev,re,r,rp)
    -- Activate Field Spell from deck
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local ftc=Duel.SelectMatchingCard(tp,s.fldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if not ftc then return end
    Duel.ActivateFieldSpell(ftc,e,tp,eg,ep,ev,re,r,rp)
    -- Immediately Rune Summon 1 "Litos" monster from hand
    local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_HAND,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local rg=g:Select(tp,1,1,nil)
        Duel.RuneSummon(tp,rg:GetFirst(),nil)
    end
end

--------------------------------------------------
-- (2) GY Quick Effect: bounce monster that activated effect to hand
--------------------------------------------------
function s.litosrunefilter(c)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
end
function s.bncon(e,tp,eg,ep,ev,re,r,rp)
    -- Opponent activates a monster effect
    return rp~=tp and re:IsActiveType(TYPE_MONSTER)
        and Duel.IsExistingMatchingCard(s.litosrunefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return rc:IsLocation(LOCATION_MZONE) and rc:IsAbleToHand() end
    e:SetLabel(rc:GetFieldID())
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,rc,1,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    -- Make sure the monster hasn't left the field and returned back to field, and is able to be returned to hand.
    if e:GetLabel()==rc:GetFieldID() and rc:IsLocation(LOCATION_MZONE) and rc:IsAbleToHand() then
        Duel.SendtoHand(rc,nil,REASON_EFFECT)
        Duel.ConfirmCards(tp,rc)
    end
end