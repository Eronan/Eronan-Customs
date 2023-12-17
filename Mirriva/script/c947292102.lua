--Lights in Illusion
local s,id=GetID()
function s.initial_effect(c)
	-- Ritual Summon
	Ritual.AddProcGreater({
		handler=c,
		filter=s.ritualfil,
		lv=9,
		extrafil=s.extramat,
		extratg=s.extratg,
		forcedselection=s.ritcheck,
		stage2=s.stage2
	})
	--Add 1 "Mirriva, Veiled Conjurer" from deck and this card from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={947292100}
s.fit_monster={947292100} --should be removed in hardcode overhaul
function s.ritualfil(c)
	return c:IsCode(947292100) and c:IsRitualMonster()
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_EXTRA,0,nil)
end
function s.matfilter1(c)
	return c:IsAbleToRemove() and c:IsLevelAbove(1)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendToGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
function s.ritcheck(e,tp,g,sc)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--immune
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.efilter)
	tc:RegisterEffect(e1)
end
--immune
function s.efilter(e,re,rp)
	if e:GetHandlerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and rp==1-tp
end
function s.srchfilter(c)
	return (c:IsCode(947292100) or c:ListsCode(947292100)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.srchfilter,tp,LOCATION_DECK,0,1,nil)
		and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
	--Add 1 "Lunalight" spell/trap from deck
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.srchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
