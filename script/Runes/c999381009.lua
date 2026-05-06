--Greenwood Warden
local s,id=GetID()
local SET_ETHERUNE=0xfe1
function s.initial_effect(c)

	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),3,2)
	c:EnableReviveLimit()

	--(1) Search Rune + hand lock
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

	--(2) Rune Summon
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost)
    e2:SetTarget(s.runetg)
	e2:SetOperation(s.runeop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

    --(3) Attach from Extra Deck + copy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.cost)
    e3:SetTarget(s.attachtg)
    e3:SetOperation(s.attachop)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end

--generic detach cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--(1) search Rune
function s.thfilter(c)
	return c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end

    --cannot activate monster effects in hand
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end

function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_HAND)
end

--(2) Rune Summon (custom hook)
function s.runematfilter(c)
    return c:IsSpellTrap() and c:IsCanBeRuneMaterial()
end
function s.runefilter(c,e,mg)
	return c:IsType(TYPE_RUNE) and c:IsLevelBelow(9)
        and c:IsRuneSummonable(e:GetHandler(),mg,2,2)
end
function s.runetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(s.runematfilter,tp,LOCATION_HAND,0,nil)
        mg:AddCard(e:GetHandler())
        return #mg>0 and Duel.IsExistingMatchingCard(s.runefilter,tp,LOCATION_HAND,0,1,nil,e,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--Get Rune Summonable cards
    local mg=Duel.GetMatchingGroup(s.runematfilter,tp,LOCATION_HAND,0,nil)
    mg:AddCard(c)
	local g=Duel.GetMatchingGroup(s.runefilter,tp,LOCATION_HAND,0,nil,e,mg)
    if #g==0 then return end
    --Rune Summon monster
    local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
    Duel.RuneSummon(tp,tc,c,mg,2,2)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.Overlay(c,Group.FromCards(tc))
    --change name
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(tc:GetCode())
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    --change attribute
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetValue(tc:GetAttribute())
    c:RegisterEffect(e2)

    --change type
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetValue(tc:GetRace())
    c:RegisterEffect(e3)
end