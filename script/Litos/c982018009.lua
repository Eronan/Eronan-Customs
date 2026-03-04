--Litos Zmeysaqa Colossus
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local CARD_RIFT_COLOSSUS=982018003 -- Litos Rift Colossus passcode
local CARD_DIVERGENT_BOUNDARY=982018006 -- Litos Divergent Boundary passcode
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 1 "Litos" Rune monster + 3+ "Litos" Spell/Trap cards
    -- Banished "Litos" cards can be shuffled back to Deck as materials
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(s.stfilter),3,99,nil,s.exgroup,nil,nil,s.exchk,s.customop)

    --Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)

    --------------------------------------------------
    --(1) Unaffected by opponent's card effects that do not target it
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.immuneval)
    c:RegisterEffect(e2)

    --------------------------------------------------
    --(2) If card(s) added to opponent's hand by a card effect:
    --    Banish 1 random card from their hand. HOPT.
    --------------------------------------------------
    --Banish 1 random card from your opponent's hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.handrmcon)
	e3:SetTarget(s.handrmtg)
	e3:SetOperation(s.handrmop)
	c:RegisterEffect(e3)

    --------------------------------------------------
    --(3) Quick Effect: Target 1 opponent monster; banish it.
    --    If Rift Colossus was used as Rune material: permanent.
    --    Otherwise: until End Phase. HOPT.
    --------------------------------------------------
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetTarget(s.rmtg)
    e5:SetOperation(s.rmop)
    c:RegisterEffect(e5)
end

s.listed_series={0xfbf}
s.listed_names={CARD_RIFT_COLOSSUS}

--------------------------------------------------
-- Rune Summon material filters
--------------------------------------------------
-- Monster material: any "Litos" Rune monster
function s.monfilter(c,rc,sumtype,tp)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
end
-- Spell/Trap materials: any "Litos" Spell/Trap
function s.stfilter(c,rc,sumtype,tp)
    return c:IsSetCard(0xfbf) and (c:IsSpell() or c:IsTrap())
end
function s.exfilter(c)
    return c:IsFaceup() and c:IsAbleToDeck()
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_REMOVED,0,ex)
end
function s.exchkfilter(c)
    return c:IsCode(CARD_RIFT_COLOSSUS) or c:IsCode(CARD_DIVERGENT_BOUNDARY)
end
function s.exchk(sg,tp,ex,c)
    return not sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
        or sg:IsExists(s.exchkfilter,1,nil)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_RUNE)
end

--------------------------------------------------
-- (1) Immune to opponent's non-targeting effects
--------------------------------------------------
function s.immuneval(e,te)
    if te:GetHandlerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end

--------------------------------------------------
-- (2) Card added to opponent's hand by card effect → banish random
--------------------------------------------------
-- function s.handrmconfilter(c,opp)
-- 	return c:IsPreviousControler(opp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsControler(opp)
-- end
function s.handrmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re ~= nil and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.handrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.handrmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------
-- (3) Quick Effect: target 1 opponent monster; banish it
--    Permanent if Rift Colossus was material, else until End Phase
--------------------------------------------------
--Remove Effect
function s.rmfilter(c)
    return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- Permanent banish
    Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end