--Inphastice Vector
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local INPHASTICE_SETCODE=0xfbd

function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)
    --Rune Summon: 1 Effect monster + 1 "Inphastice" Spell/Trap
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_EFFECT),1,1,Rune.STFunctionEx(Card.IsSetCard,INPHASTICE_SETCODE),1,1,LOCATION_PZONE)

    --------------------------------------------------
    -- [Pendulum Effect P1]
    -- Quick Effect: Special Summon this card from Pendulum Zone. HOPT.
    --------------------------------------------------
    local ep1=Effect.CreateEffect(c)
    ep1:SetDescription(aux.Stringid(id,0))
    ep1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    ep1:SetType(EFFECT_TYPE_QUICK_O)
    ep1:SetCode(EVENT_FREE_CHAIN)
    ep1:SetRange(LOCATION_PZONE)
    ep1:SetCountLimit(1,id)
    ep1:SetTarget(s.ssptg)
    ep1:SetOperation(s.sspop)
    c:RegisterEffect(ep1)

    --------------------------------------------------
    -- [Monster Effect 1]
    -- Quick Effect: Place this card in Pendulum Zone; destroy 1 face-up S/T. HOPT.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- [Monster Effect 2]
    -- If Special Summoned: target 1 opponent monster;
    -- while on field, its controller cannot Fusion/Synchro/Xyz/Link/Rune Summon
    -- unless they use that monster as material. HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.locktg)
    e2:SetOperation(s.lockop)
    c:RegisterEffect(e2)
end

s.listed_series={INPHASTICE_SETCODE}

--------------------------------------------------
-- [P1] Special Summon from Pendulum Zone
--------------------------------------------------
function s.ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--------------------------------------------------
-- [Effect 1] Place in Pendulum Zone + destroy 1 face-up S/T
--------------------------------------------------
function s.stfilter(c)
    return c:IsFaceup() and (c:IsSpell() or c:IsTrap()) and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,0,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Move this card to Pendulum Zone
    local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local tc=g:Select(tp,1,1,nil)
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

--------------------------------------------------
-- [Effect 2] SS trigger: lock opponent to using target as material
--------------------------------------------------
function s.lockfilter(c)
    return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.locktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(s.lockfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.lockfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,0,g,1,0,0)
end
function s.lockop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
    -- Must be used as material.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_MUST_BE_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetTargetRange(1,0)
    e1:SetValue(REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK+REASON_RUNE)
    tc:RegisterEffect(e1)
end
