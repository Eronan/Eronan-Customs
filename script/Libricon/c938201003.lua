--Libricon of the Dungeon
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
	c:EnableReviveLimit()
    Link.AddProcedure(c,aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOKEN)),1,4,s.lcheck)
    --pendulum attributes
    Pendulum.AddProcedure(c,false)
    --Special Summon a card from the Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
    --destroy or to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.dhcon)
	e2:SetTarget(s.dhtg)
	e2:SetOperation(s.dhop)
	c:RegisterEffect(e2)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_EFFECT,lc,sumtype,tp)
end
--Place in Pendulum Zone
function s.penfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.penfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.SelectTarget(tp,s.penfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--destroy or to hand
function s.dhcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.dhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local pc=(pg-c):GetFirst()
	if chk==0 then return pc end
end
function s.dhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local pc=(pg-c):GetFirst()
	if not pc or not c:IsRelateToEffect(e) then return end
	local b1=pc:IsAbleToHand()
    local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{true,aux.Stringid(id,3)})
    if op==1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
