--Zephyra, CelsiPhasmica Phantom of Ara
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(s.rfilter),1,1,Rune.STFunction(Card.IsContinuousSpellTrap),2,2)
    Rune.AddSecondProcedure(c,Rune.MonFunctionEx(s.rfilter),1,1,Rune.STFunction(Card.IsContinuousSpellTrap),2,2,LOCATION_GRAVE,nil,nil,nil,s.runchk)
    --Summon Limit
    local rlim=Effect.CreateEffect(c)
    rlim:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    rlim:SetType(EFFECT_TYPE_SINGLE)
    rlim:SetCode(EFFECT_SPSUMMON_CONDITION)
    rlim:SetValue(aux.runlimit)
    c:RegisterEffect(rlim)

    --(1) Quick Effect: Send this card to GY; set all opponent's monsters face-down
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)

    --(2) Quick Effect: Shuffle 1 opponent's card into the Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    --(3) If this card leaves the field → place up to 2 "Phasmica" monsters as Continuous Spells
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetTarget(s.cstg)
    e3:SetOperation(s.csop)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc1}
s.listed_names={965043801} -- "Phasmica Shade Zephyra"

--Rune material filter
function s.rfilter(c)
    return c:IsSetCard(0xfc1) and c:IsType(TYPE_RUNE)
end

--GY Rune Summon check: requires "Phasmica Shade Zephyra" in the materials
function s.runchk(sg,c,r,tp)
    return sg:FilterCount(Card.IsCode,nil,965043801)>=1 -- "Phasmica Shade Zephyra"
end

--(1) Cost: send this card to GY
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

--(1) Target/Operation: set all opponent's monsters face-down
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end

--(2) Shuffle opponent's card
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

--(3) Place up to 2 "Phasmica" monsters as Continuous Spells
function s.csfilter(c)
    return c:IsSetCard(0xfc1) and c:IsType(TYPE_MONSTER)
end
function s.cstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingTarget(s.csfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_SZONE))
    local g=Duel.SelectTarget(tp,s.csfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
end
function s.csop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    if #g>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        g=g:Select(tp,ft,ft,nil)
    end
    for tc in aux.Next(g) do
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end
