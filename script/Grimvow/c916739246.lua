--Curse of Grimvow Greed
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c)
	--negate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.chcon)
    e1:SetOperation(s.chop)
    c:RegisterEffect(e1)
    --Must be used as material
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_MUST_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetValue(REASON_FUSION|REASON_SYNCHRO|REASON_XYZ|REASON_LINK|REASON_RUNE)
    --Grant the above effect to the equipped monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(e,tc) return e:GetHandler():GetEquipTarget()==tc end)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
    --Equip Spell to opponent's monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end
--change effect to draw
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler()==e:GetHandler():GetEquipTarget()
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,rp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsPlayerCanDraw(rp,1) and Duel.IsPlayerCanDraw(1-rp,1)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
--Equip from GY to opponent's monster
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_EFFECT) and rp==1-tp)
        or (c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp))
end
function s.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function s.ecfilter(c,tp)
	return c:IsType(TYPE_EQUIP) and not c:IsCode(id)
        and Duel.IsExistingMatchingCard(s.tcfilter,tp,0,LOCATION_MZONE,1,nil,c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ecfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ecfilter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectTarget(tp,s.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local ec=g:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,ec,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetFirstTarget()
    if not ec or not ec:IsRelateToEffect(e) then return end
    local tc=Duel.SelectMatchingCard(tp,s.tcfilter,tp,0,LOCATION_MZONE,1,1,nil,ec):GetFirst()
    Duel.Equip(tp,ec,tc)
end
