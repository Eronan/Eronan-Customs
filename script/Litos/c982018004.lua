--Litos Fault Tyrant
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfbf),1,1,nil,s.exgroup,nil,nil,nil,nil,s.stage2)

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
    --(2) When a monster you control except this card is sent to the GY (Quick Effect):
    --    Destroy all opponent monsters
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series={0xfbf}
s.listed_names={982018007} -- Litos Transform Boundary

--------------------------------------------------
-- Rune Summon material filter: non-Token that cannot be Normal Summoned/Set
--------------------------------------------------
function s.monfilter(c,rc,sumtype,tp)
    return not c:IsSummonableCard() and not c:IsType(TYPE_TOKEN)
end

--------------------------------------------------
-- Rune Summon condition: Control "Transform Boundary"
--------------------------------------------------
function s.excondition(c)
    return c:IsFaceup() and c:IsCode(982018007)
end
function s.exfilter(c)
    return c:IsAbleToGrave() and c:IsSetCard(0xfbf)
end
function s.exgroup(tp,ex,c)
    if Duel.GetFlagEffect(tp,id) == 0 and Duel.IsExistingMatchingCard(s.excondition,tp,LOCATION_FZONE,0,1,nil) then
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
-- (2) When a monster you control except this card is sent to GY:
--     Destroy all opponent monsters
--------------------------------------------------
function s.descfilter(c,tp)
    return c:IsMonster() and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return eg:IsExists(s.descfilter,1,c,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0 end
    local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end