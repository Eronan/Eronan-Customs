--Grimvow Contract of Souls
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c,nil,nil,nil,nil,s.eqlimtg)
    --activate cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
    e1:SetTarget(function (e,te) return te:GetHandler()==c:GetEquipTarget() end)
	e1:SetCost(s.costchk)
	e1:SetOperation(s.costop)
	c:RegisterEffect(e1)
    --accumulate
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(id)
    c:RegisterEffect(e2)
    --Activation limitation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
    --Equip "Grimvow" to opponent's monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfc6}
--equip
function s.eqlimtg(e,tp,eg,ep,ev,re,r,rp,ec)
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
        Duel.SetChainLimit(s.limit(ec))
    end
end
function s.limit(ec)
    return    function (e,lp,tp)
                return e:GetHandler()~=ec
            end
end
--Activate cost
function s.costchk(e,te,tp,sumtyp)
    local ec=e:GetHandler():GetEquipTarget()
    local ct=#{ec:GetCardEffect(id)}
    return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,ec:GetControler(),LOCATION_EXTRA,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    if not ec then return end
    local ectp=ec:GetControler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(ectp,Card.IsAbleToRemoveAsCost,ectp,LOCATION_EXTRA,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEDOWN,REASON_COST)
    end
end
--Prevent activation
function s.actcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
--Equip from Deck
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_EFFECT) and rp==1-tp)
        or (c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp))
end
function s.eqspfilter(c,ec)
	return c:IsSetCard(0xfc6) and c:IsEquipSpell()
        and c:CheckEquipTarget(ec)
end
function s.eqfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqspfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
    local ec=Duel.GetFirstTarget()
    if not ec or not ec:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local sc=Duel.SelectMatchingCard(tp,s.eqspfilter,tp,LOCATION_DECK,0,1,1,nil,ec):GetFirst()
    if not sc then return end
    Duel.HintSelection(ec,true)
    Duel.Equip(tp,sc,ec)
end
