--Decree of Caraphron
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Equip procedure
    aux.AddEquipProcedure(c)

    --(1) Cannot activate cards/effects during battle of equipped monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
    --chain limit
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCode(EVENT_CHAINING)
    e4:SetCondition(s.chcon)
    e4:SetOperation(s.chop)
    c:RegisterEffect(e4)

    --(3) If sent to GY because equipped monster sent to GY: Special Summon 1 Caraphron Rune monster from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc0}

--==========================
--Effect 1: Restrict opponent activation during battle
--==========================
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function s.actcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc:IsType(TYPE_RUNE) and Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
--==========================
--Effect 2: Opponent cannot respond to equipped monster's effects
--==========================
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return re:GetHandler()==ec and ec:IsSetCard(0xfc0) and ec:IsType(TYPE_RUNE)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
    return ep==tp
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