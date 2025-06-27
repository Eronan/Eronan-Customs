--Over-Storm Elysiance Lord
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c,true)
    c:EnableReviveLimit()
    --Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --scale
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.excon)
	e2:SetValue(13)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
    --to hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.excon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --When a monster effect activated from hand or field resolves, they must Tribute that monster or the effect is negated
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_CHAIN_SOLVING)
    e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.relcon)
    e5:SetOperation(s.relop)
    c:RegisterEffect(e5)
    --place in pendulum zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_DECK)
    e6:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e6:SetCondition(s.pccon)
	e6:SetTarget(s.pctg)
	e6:SetOperation(s.pcop)
	c:RegisterEffect(e6)
end
--special summon condition
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--pendulum scale
function s.excon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)<=7
end
--to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
        and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--activate cost
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,ep=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_PLAYER)
	return (trig_loc&(LOCATION_MZONE|LOCATION_HAND)>0 and re:IsMonsterEffect()) and Duel.GetFieldGroupCount(ep,LOCATION_EXTRA,0)>7
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
    local te,ep,chain_id=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_CHAIN_ID)
	if chain_id==s[0] then return end
    s[0]=chain_id
	local tc=te:GetHandler()
    if tc:IsReleasable() and Duel.SelectYesNo(ep,aux.Stringid(id,1)) then
        Duel.Release(tc,REASON_EFFECT)
        Duel.BreakEffect()
    else Duel.NegateEffect(ev) end
end
--place in pendulum zone
function s.pccon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end