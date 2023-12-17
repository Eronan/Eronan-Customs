--Avilia, Subshifter
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Invocation" to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
end
s.listed_series={0xfd4}
function s.thfilter(c)
	return c:IsType(TYPE_RUNE) and c:IsSetCard(0xfd4) and c:IsAbleToHand()
		and c:IsRuneSummonable(nil,nil,nil,nil,LOCATION_HAND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0xfd4)}
	local fustg=Fusion.SummonEffTG(table.unpack(params))
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.runop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
		fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		
		--Rune Summon
		local rc=g:GetFirst()
		Duel.RuneSummon(tp,rc)
	end
end
