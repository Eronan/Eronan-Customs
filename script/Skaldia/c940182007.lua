-- Skaldia [Synchro Monster Name]
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_RUNE),1,99)
    c:EnableReviveLimit()

    -- (1) Unaffected by opponent's activated effects that do not target
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc2))
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- (2) ATK reduction if LP lower
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atkcond)
    e2:SetValue(-1500)
    c:RegisterEffect(e2)

    -- (3) Search 1 "Skaldia" card on Synchro Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc2}

-- (1) Immune to opponent's activated effects that do not target
function s.efilter(e,te)
    if te:GetHandlerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
    -- If it has the property EFFECT_FLAG_CARD_TARGET, it targets
    if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return #g==0
end

-- (2) LP check for ATK drop
function s.atkcond(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end

-- (3) Search Skaldia card
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c)
    return c:IsSetCard(0xfc2) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
