--Greenwood Appearance
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.matfilter(c,tp,mg)
	local nmg=mg:Clone()
	nmg:AddCard(c)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,c,nmg)
end
function s.thfilter1(c,mc,mg)
	return c:IsType(TYPE_RUNE) and c:IsAbleToHand() and mc:IsCanBeRuneMaterial(c,tp)-- and c:GetMinimumRuneMaterials(LOCATION_HAND)>=3
		and c:IsRuneSummonable(mc,mg,3,nil,LOCATION_HAND)
end
function s.thfilter2(c,mg)
	return c:IsType(TYPE_RUNE) and c:IsAbleToHand() and c:IsRuneSummonable(nil,mg,nil,nil,LOCATION_HAND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
	local b1=Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_ONFIELD,1,nil,tp,mg)
	mg:AddCard(e:GetHandler())
	local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,mg)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.thop1)
		Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp,mg)
	else
		e:SetOperation(s.thop2)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		mg:AddCard(tc)
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tc,mg)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,g)
			
			--Rune Summon
			local rc=g:GetFirst()
			if rc:IsRuneSummonable(tc,mg,3,99) then
				Duel.RuneSummon(tp,rc,tc,mg,3,99)
			end
		end
	end
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:CancelToGrave(true)
	if not Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		
		--Rune Summon
		local rc=g:GetFirst()
		if rc:IsRuneSummonable() then
			local ge1=Effect.CreateEffect(c)
			ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
			ge1:SetRange(LOCATION_SZONE)
			ge1:SetOperation(s.checkop)
			ge1:SetLabelObject(rc)
			ge1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(ge1)
			
			Duel.RuneSummon(tp,rc)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local lc=e:GetLabelObject()
	if tc and lc and tc==lc and tc:IsSummonType(SUMMON_TYPE_RUNE) then
		Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
	end
end
