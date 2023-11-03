--Pyrosprite of the Forest
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	--add material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.matcon)
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--activate cost
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_ACTIVATE_COST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(0,1)
	e3:SetCondition(s.costcon)
	e3:SetTarget(s.costtg)
    e3:SetCost(s.costchk)
    e3:SetOperation(s.costop)
    c:RegisterEffect(e3)
	--accumulate
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(id)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(0,1)
    c:RegisterEffect(e4)
end
s.listed_names={928190100}
--attach as material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.matfilter(c)
	return not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.matfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
--special summon "Vesta of Parasitic Bloom"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(928190100) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableGeminiStatus()
	end
	Duel.SpecialSummonComplete()
end
--pay cost for graveyard effects
function s.costcon(e,te)
	return e:GetHandler():GetOverlayCount()>0
end
function s.costtg(e,te,tp)
	return te:GetActivateLocation()&LOCATION_GRAVE>0
end
function s.costchk(e,te,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return te:GetActivateLocation()~=LOCATION_GRAVE or Duel.CheckLPCost(tp,ct*600)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,600)
end