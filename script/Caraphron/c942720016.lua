--Caraphron Sovereign Carapace
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Equip procedure
    aux.AddEquipProcedure(c)

    --(1) Equip bonus: +800 ATK/DEF and unaffected by opponent's activated effects that do not target this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(800)
    e1:SetCondition(s.eqcon)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.eqcon)
	e3:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() end)
	c:RegisterEffect(e3)

    --(2) Destroy this card instead of equipped monster
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
    e4:SetTarget(s.replacetg)
    e4:SetOperation(s.replaceop)
    c:RegisterEffect(e4)

    --(3) If sent to GY because equipped monster sent to GY: Special Summon 1 Caraphron Rune monster from GY
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end

s.listed_series={0xfc0}

--==========================
--Effect (1) filter: immune to opponent effects that do not target the equip spell
--==========================
function s.eqcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0xfc0)
end

--==========================
--Effect (2) destroy substitute
--==========================
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsReason(REASON_EFFECT|REASON_BATTLE) and not ec:IsReason(REASON_REPLACE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end

--==========================
--Effect (3) Special Summon from GY
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