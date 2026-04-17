--Inphastice Amber
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_INPHASTICE=0xfbd

function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)
    --Rune Summon: 1 Pendulum monster + 1 "Inphastice" Spell/Trap
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_PENDULUM),1,1,Rune.STFunctionEx(Card.IsSetCard,SET_INPHASTICE),1,1,LOCATION_PZONE)

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
    -- Quick Effect: Place this card in Pendulum Zone;
    -- negate effects of 1 opponent monster until End Phase. HOPT.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- [Monster Effect 2]
    -- If Special Summoned: target 1 card you control and 1 opponent controls; destroy both.
    -- If Rune Summoned, banish the destroyed cards opponent owned. HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_INPHASTICE}

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
-- [Effect 1] Place in Pendulum Zone + negate opponent monster effects
--------------------------------------------------
function s.negfilter(c)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,0,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Move this card to Pendulum Zone
    local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
            local tc=g:Select(tp,1,1,nil):GetFirst()
            tc:NegateEffects(e:GetHandler(),RESETS_STANDARD_PHASE_END,true)
    end
end

--------------------------------------------------
-- [Effect 2] SS trigger: destroy 1 card each, banish if Rune Summoned
--------------------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsDestructable() end
    if chk==0 then
        return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    -- Select 1 you control
    local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
    -- Select 1 opponent controls
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    local g=g1+g2
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #sg==0 then return end
    -- If Rune Summoned, banish destroyed cards opponent owned
    if Duel.Destroy(sg,REASON_EFFECT) and c:IsSummonType(SUMMON_TYPE_RUNE) then
        local bg=sg:Filter(Card.IsOwner,nil,1-tp)
        Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
    end
end
