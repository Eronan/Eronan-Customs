--Litos Rift Colossus
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,0xfbf),1,1,Rune.STFunction(Card.IsFieldSpell),1,1,nil,s.exgroup,nil,nil,nil,nil,s.stage2)

    --------------------------------------------------
    --(1) Quick Effect: Activate 1 "Litos" Field Spell from Deck or Banished
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.fldtg)
    e1:SetOperation(s.fldop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    --(2) Quick Effect: Banish this card and 1 opponent monster until End Phase
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.banishtg)
    e2:SetOperation(s.banishop)
    c:RegisterEffect(e2)
end

s.listed_series={0xfbf}
s.listed_names={982018006} -- Divergent Boundary

--------------------------------------------------
-- Rune Summon condition: Control "Divergent Boundary"
--------------------------------------------------
function s.excondition(c)
    return c:IsFaceup() and c:IsCode(982018006)
end
function s.exfilter(c)
    return c:IsAbleToGrave() and c:IsSetCard(0xfbf)
end
function s.exgroup(tp,ex,c)
    if Duel.GetFlagEffect(tp,id) == 0 and  Duel.IsExistingMatchingCard(s.excondition,tp,LOCATION_FZONE,0,1,nil) then
        return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,ex)
    else
        return Group.CreateGroup()
    end
end
function s.stage2(sg,e,tp,eg,ep,ev,re,r,rp,pc)
    if sg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
end
--------------------------------------------------
-- (1) Quick Effect: Activate Field Spell from Deck/Banish
--------------------------------------------------
function s.fldfilter(c)
    return c:IsSetCard(0xfbf) and c:IsFieldSpell() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
function s.fldtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fldfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
end
function s.fldop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.fldfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil):GetFirst()
    if not tc then return end
    Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end

--------------------------------------------------
-- (2) Quick Effect: Banish self until End Phase, banish 1 opponent monster until End Phase
--------------------------------------------------
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(1,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_MZONE)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local ec=e:GetHandler()
    -- Permanently banish the targeted opponent monster
    if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
    -- Banish Rift Colossus itself until End Phase, then return to field
    if ec and ec:IsLocation(LOCATION_MZONE) then
        aux.RemoveUntil(ec,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
    end
end