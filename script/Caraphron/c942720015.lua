--Caraphron Cocoon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c)
    --(1) Continuous: Allow Rune Summon from GY or Banished using this card + equipped monster
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.runeloctg)
    e2:SetTargetRange(LOCATION_GRAVE|LOCATION_REMOVED,0)
    e2:SetValue(s.runelocmat)
    e2:SetOperation(s.runelocop)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s,function()
		s[0]={}
        s[1]={}
		local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_TURN_END)
        ge:SetOperation(function()
            s[0] = {} -- reset the table
            s[1] = {} -- reset the table
        end)
        Duel.RegisterEffect(ge,0)
	end)

    --(2) Quick Effect: Rune Summon 1 Caraphron from hand, GY, or banished using this card as material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e2:SetCondition(function (e) return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 end)
    e2:SetTarget(s.runtg)
    e2:SetOperation(s.runop)
    c:RegisterEffect(e2)

    --(3) If sent to GY because equipped monster sent to GY: Special Summon 1 Caraphron Rune monster from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc0}

--==========================
--Effect 1 helper: Check Rune Summon condition
--==========================
function s.runeloctg(e,tc)
    return tc:IsSetCard(0xfc0) and not s[tc:GetControler()][tc:GetCode()]
end
function s.runelocmat(e,tp,sg,rc)
    --Materials include this card and its equipped monster
    return e:GetHandler():GetEquipTarget()
        and sg:IsContains(e:GetHandler()) and sg:IsContains(e:GetHandler():GetEquipTarget())
end
function s.runelocop(sg,e,tp,eg,ep,ev,re,r,rp,pc)
    local c=e:GetHandler()
    s[tp][c:GetCode()]=1
end

--==========================
--Effect 2: Quick Rune Summon
--==========================
function s.runfilter(c,e,tp)
    return c:IsSetCard(0xfc0) and c:IsRuneSummonable(e:GetHandler())
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.RuneSummon(tp,g:GetFirst(),e:GetHandler())
    end
end

--==========================
--Effect 3: Special Summon from GY when this card sent to GY
--==========================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
    return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xfc0) and c:IsType(TYPE_RUNE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
