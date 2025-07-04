--Tempest, Emberwind Acolyte
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon
    c:EnableReviveLimit()
   --Search for "Maris, Aquamire Mystic"
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Place Nocidium Counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
s.listed_names={928302000,928302004}
s.counter_place_list={0x10fc}
--Rune Summon
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
--Search
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.thfilter(c)
	return (c:ListsCode(928302000) or c:IsCode(928302000))
		 and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
        local c=e:GetHandler()
        if c:IsLocation(LOCATION_HAND) then
            Duel.BreakEffect()
            Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
        end
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)
	end
end
--Place Nocidium Counters
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    --Count summons this turn
    local c=e:GetHandler()
    local ct=c:GetFlagEffect(id)
    if ct==0 and #eg>0 then
        --If the opponent summons 2 or more monsters, the latter effect cannot be used but it is counted.
        --If the opponent summons only 1 monster, only the next summon will gain a counter.
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
        return
    end

    --Place counter on exactly 1 face-up summoned monster
    if #eg~=1 then return end
	local tc=eg:GetFirst()
    if tc:IsFacedown() or tc:IsControler(tp) then return end
    tc:AddCounter(0x10fc,1)

    if tc:GetFlagEffect(0x10fc)~=0 then return end
    --destroy replace
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetTarget(s.reptg)
    e1:SetOperation(s.repop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    --disable
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.discon)
    e2:SetOperation(s.disop)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
    tc:RegisterFlagEffect(0x10fc,RESET_EVENT+RESETS_STANDARD,0,0)
end
--destroy replace
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE) and e:GetHandler():GetCounter(0x10fc)>0 end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():RemoveCounter(tp,0x10fc,1,REASON_EFFECT)
end
--disable
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()~=e:GetHandler() or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:GetHandler():GetCounter(0x10fc)>0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		e:GetHandler():RemoveCounter(tp,0x10fc,1,REASON_EFFECT)
	end
end