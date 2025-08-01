--Skaldia Brand of Subjugation
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Equip limit
	aux.AddEquipProcedure(c)

	--(1) Take control + disable effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetValue(s.ctval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_CANNOT_TRIGGER)
    c:RegisterEffect(e2)

	--(2) Rune Summon from GY or banishment using this + equipped monster
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_RUNE_LOCATION)
    e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc2))
    e3:SetTargetRange(LOCATION_GRAVE|LOCATION_REMOVED,0)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetValue(s.restrict_rune)
    c:RegisterEffect(e3)

	--(3) GY trigger: Equip to opponent's monster on Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end

s.listed_series={0xfc2}

--(1) Control is always to owner of this equip card
function s.ctval(e)
	return e:GetHandlerPlayer()
end

-- (2) Rune Summon from GY or banishment
function s.restrict_rune(e,tp,sg,rc)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    return sg:IsContains(c)
        and ec and sg:IsContains(ec)
end

--(3) GY trigger — opponent Special Summons
function s.eqfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsFaceup()
        and c:IsCanBeEffectTarget(e)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqfilter,1,nil,e,tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.eqfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(s.eqfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=eg:FilterSelect(tp,s.eqfilter,1,1,nil,e,tp)
    Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
