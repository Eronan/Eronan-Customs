--Inphastice Siren
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_INPHASTICE=0xfbd

function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)
    --Rune Summon: 1 Pendulum monster + 1 Spell/Trap
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(nil),1,1,LOCATION_PZONE)

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
    -- [Monster Effect]
    -- Quick Effect: Place this card in Pendulum Zone; Special Summon 1 "Inphastice" from Deck/face-up Extra Deck in DEF.
    -- Rest of turn: cannot SS from Extra Deck except "Inphastice". HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE|LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function (_) return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 end)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e2:SetTarget(s.pztg)
    e2:SetOperation(s.pzop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_INPHASTICE}

--------------------------------------------------
-- Rune material filter: Pendulum monster
--------------------------------------------------
function s.monfilter(c,rc,sumtype,tp)
    return c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_TOKEN)
end

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
-- [Monster Effect] Place in Pendulum Zone → SS "Inphastice" from Deck/Extra
--------------------------------------------------
function s.spfilter(c,e,tp)
    if c:IsLocation(LOCATION_EXTRA) and (Duel.GetLocationCountFromEx(tp,tp,mc,c)==0 or c:IsFacedown()) then return false end
    return c:IsSetCard(SET_INPHASTICE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local loc=LOCATION_EXTRA
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if e:GetHandler():GetSequence()<5 then ft=ft+1 end
        if ft>0 then loc=loc|LOCATION_DECK end
        return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Move this card to Pendulum Zone
    if c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
        local loc=LOCATION_EXTRA
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_DECK end
        -- Special Summon 1 "Inphastice" from Deck or face-up Extra Deck in DEF
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
        if #g>0 then
           Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
        -- Restrict Extra Deck SS for rest of turn
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(s.rstval)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.rstval(e,c,sump,sumtype,tp)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_INPHASTICE)
end
