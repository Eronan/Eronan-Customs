--Sacred Ritic Circle
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,extrafil=s.extragroup,extraop=s.extraop,stage2=s.ritop,specificmatfilter=s.mfilter,forcedselection=s.ritcheck})
	c:RegisterEffect(e1)
	--Add card from deck to hand
	local e2=Effect.CreateEffect(c)
	e1:SetLabelObject(e2)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfe2}
function s.matfilter1(c)
	return c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.ritop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--
	e:GetLabelObject():SetLabelObject(tc)
	e:GetLabelObject():SetLabel(tc:GetFieldID())
end
function s.ritcheck(e,tp,g,sc)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.mfilter(c,rc,mg,tp)
	return c:IsAttribute(rc:GetAttribute()) and (not c:IsLocation(LOCATION_DECK) or rc:IsSetCard(0xfe2))
end
function s.cfilter(c,label)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c==label
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject() and eg:IsExists(s.cfilter,1,nil,e:GetLabelObject())
end
function s.thfilter(c,tc)
	return c:GetOriginalRace()==tc:GetOriginalRace() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabelObject()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=e:GetLabelObject()
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
	if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousLocation(POS_FACEUP) and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
