--Armored Grimvow Golem
local s,id=GetID()
function s.initial_effect(c)
    aux.AddUnionProcedure(c,nil,false)
    --Set itself from GY
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE|LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_series={0xfc6}
s.listed_names={938201010}
function s.eqfilter(c,ec)
	return c:IsFaceup() and ec:CheckUnionTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
    Duel.Equip(tp,c,tc)
    aux.SetUnionState(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetCondition(s.splimitcon)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end
function s.splcfilter(c)
    return c:IsSetCard(0xfc6) or c:IsCode(938201010)
end
function s.splimitcon(e)
    local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(s.splcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
end
