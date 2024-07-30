--Grimvow Theatrics
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c,1)
    --negate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.chcon)
    e1:SetOperation(s.chop)
    c:RegisterEffect(e1)
    --Limit battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
    --Search
	local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(function(e) return c:IsLocation(LOCATION_GRAVE) and c:GetEquipTarget()~=nil end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.thcon)
    c:RegisterEffect(e4)
end
s.listed_series={0xfc6}
--redirect effect target
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler()==e:GetHandler():GetEquipTarget()
        and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,rp,0,LOCATION_DECK|LOCATION_EXTRA,1,nil)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,1-tp,LOCATION_EXTRA|LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT,PLAYER_NONE,1-tp)
	end
end
--Limit battle target
function s.atkval(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local _,val=g:GetMaxGroup(Card.GetAttack)
	return val
end
function s.atlimit(e,c)
    local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsControler(tp) and c:GetAttack()<s.atkval(tp)
end
--Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp
end
function s.thfilter(c)
	return c:IsSetCard(0xfc6) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
