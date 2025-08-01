--Skaldia Aurorascribe
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon procedure
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.mmtfilter),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc2),1,1,nil,s.exgroup)

	--Effect 1: Quick Rune Summon from hand during opponent's Main Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
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

	--Effect 2: Flip 1 Special Summoned monster face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc2}
function s.mmtfilter(c)
    return not c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_EFFECT)
end
function s.exgroup(tp,ex,c)
    if not Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil) then
        return Group.CreateGroup()
    end
    return Duel.GetMatchingGroup(Card.IsCanBeRuneMaterial,tp,LOCATION_HAND,0,nil,c)
end
--Condition: Opponent's Main Phase
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
--Cost: Pay 500 LP + reveal this card
function s.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and not e:GetHandler():IsPublic() end
	Duel.PayLPCost(tp,500)
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
--Send Skaldia Spell/Trap to GY
function s.tgfilter(c)
	return c:IsSetCard(0xfc2) and c:IsSpellTrap() and c:IsAbleToGrave()
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and c:IsRuneSummonable() then
			Duel.BreakEffect()
			Duel.RuneSummon(tp,c)
		end
	end
end

--Condition: Only during opponent's turn
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
--Target: 1 Special Summoned monster
function s.posfilter(c)
	return c:IsFaceup() and c:IsSpecialSummoned() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
--Operation: Change to face-down Defense Position
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
