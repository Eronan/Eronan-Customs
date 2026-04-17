--Inphastice Cascade
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_INPHASTICE=0xfbd

function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)

    --------------------------------------------------
    -- [Pendulum Effect P1]
    -- You cannot Pendulum Summon monsters except Rune monsters. Cannot be negated.
    --------------------------------------------------
    local ep1=Effect.CreateEffect(c)
    ep1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    ep1:SetType(EFFECT_TYPE_FIELD)
    ep1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ep1:SetRange(LOCATION_PZONE)
    ep1:SetTargetRange(1,0)
    ep1:SetTarget(s.pendlimit)
    ep1:SetValue(1)
    c:RegisterEffect(ep1)

    --------------------------------------------------
    -- [Monster Effect 1]
    -- If you control no monsters, can Normal Summon without Tribute. HOPT.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.nscon)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- [Monster Effect 2]
    -- If Normal or Special Summoned: place up to 2 "Inphastice" in Pendulum Zone. HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.pztg)
    e2:SetOperation(s.pzop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    --------------------------------------------------
    -- [Monster Effect 3]
    -- Quick Effect: Immediately Rune Summon 1 "Inphastice" from hand or Pendulum Zone. HOPT.
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.rntg)
    e3:SetOperation(s.rnop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_INPHASTICE}

--------------------------------------------------
-- Pendulum limit: block non-Rune Pendulum Summons
--------------------------------------------------
function s.pendlimit(e,c,sump,sumtype,tp)
    return sumtype==SUMMON_TYPE_PENDULUM and not c:IsType(TYPE_RUNE)
end

--------------------------------------------------
-- [Effect 1] No-tribute Normal Summon condition
--------------------------------------------------
function s.nscon(e)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end

--------------------------------------------------
-- [Effect 2] Place up to 2 "Inphastice" in Pendulum Zone
--------------------------------------------------
function s.pzfilter(c,e,tp)
    return c:IsSetCard(SET_INPHASTICE) and c:IsType(TYPE_PENDULUM)
        and not c:IsForbidden()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.CheckPendulumZones(tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local lscale=Duel.CheckLocation(tp,LOCATION_PZONE,0)
    local rscale=Duel.CheckLocation(tp,LOCATION_PZONE,1)
    if not lscale and not rscale then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local max=2
    if not lscale or not rscale then max=1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_DECK,0,1,max,nil,e,tp)
    for tc in aux.Next(g) do
        Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

--------------------------------------------------
-- [Effect 3] Quick Rune Summon from hand or Pendulum Zone
--------------------------------------------------
function s.rnfilter(c,e,tp)
    return c:IsSetCard(SET_INPHASTICE) and c:IsRuneSummonable(e:GetHandler())
end
function s.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rnfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_PZONE)
end
function s.rnop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.rnfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    Duel.RuneSummon(tp,tc,c)
end
