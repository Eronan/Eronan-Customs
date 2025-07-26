--Knight of the Ashened City
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Rune Summon Procedure: DARK monster + Spell/Trap card
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Rune.STFunction(nil),1,1,nil,s.exgroup,nil,nil,nil,s.customop)

    --(1) Add "Ashened" card if sent to GY during opp turn or from hand during your turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --(2) Quick: Discard to draw when negation is activated in response to Ashened
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCost(s.register_cost)
    e2:SetOperation(s.register_operation)
    c:RegisterEffect(e2)
end
s.listed_names={CARD_VEIDOS_ERUPTION_DRAGON}
--Rune Summon conditions
function s.condition_filter(c)
    return c:IsFaceup() and c:IsCode(CARD_VEIDOS_ERUPTION_DRAGON)
end
function s.exgroup(tp,ex,c)
    if Duel.IsExistingMatchingCard(s.condition_filter,tp,0,LOCATION_MZONE,1,nil) then
        return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
    else
        return Group.CreateGroup()
    end
end

function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end

--(1) Search condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp or e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end

function s.thfilter(c)
    return c:IsSetCard(SET_ASHENED) and c:IsAbleToHand() -- Ashened archetype
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--(2) Setup trigger for conditional draw
function s.register_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.register_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Register chaining monitor
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.regcon)
    e1:SetOperation(s.regop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    -- e2: Draw once after chain ends if flagged
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_END)
    e2:SetCondition(function(e,tp) return Duel.GetFlagEffect(tp,id)>0 end)
    e2:SetOperation(function(e,tp) Duel.Draw(tp,1,REASON_EFFECT) end)
    Duel.RegisterEffect(e2,tp)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    local chainlink=Duel.GetCurrentChain(true)-1
    if not (chainlink>0 and ep==1-tp) then return false end
    local trig_p,setcodes=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_SETCODES)
    if not trig_p==tp then return false end
    for _,set in ipairs(setcodes) do
        if (SET_ASHENED&0xfff)==(set&0xfff) and (SET_ASHENED&set)==SET_ASHENED then return true end
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end