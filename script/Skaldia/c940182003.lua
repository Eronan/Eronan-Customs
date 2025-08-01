--Skaldia Aether Guardian
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon procedure
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.mmtfilter),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc2),1,1,nil,s.exgroup,nil,nil,nil,s.customop)

	--Effect 1: Quick Rune Summon from hand during opponent's Main Phase, can use GY materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hdcon)
	e1:SetCost(s.hdcost)
	e1:SetTarget(s.hdtg)
	e1:SetOperation(s.hdop)
	c:RegisterEffect(e1)

	--Effect 2: Bounce itself and 1 opponent's card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.bouncetg)
	e2:SetOperation(s.bounceop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc2}

--Material filter: must be non-LIGHT Effect Monster
function s.mmtfilter(c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_EFFECT)
end

--Extra materials: allow hand if opponent controls Special Summoned monster
function s.exgroup(tp,ex,c)
	if not Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil) then
        return Group.CreateGroup()
    end
    return Duel.GetMatchingGroup(Card.IsCanBeRuneMaterial,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,c)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--Condition: Opponent's Main Phase
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end

--Cost: Pay 500 LP + reveal this card
function s.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

--Target: Rune Summon from hand (may use GY)
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRuneSummonable(nil,nil,nil,nil,LOCATION_HAND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsRuneSummonable(nil,nil,nil,nil,LOCATION_HAND) then
		Duel.RuneSummon(tp,c)
	end
end

--Effect 2: Bounce itself and opponent's card
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
