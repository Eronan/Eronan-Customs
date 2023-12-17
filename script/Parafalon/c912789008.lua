--Rising of the Parafalon
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=nil,extrafil=nil,extraop=nil,customoperation=s.ritop,matfilter=s.forcedgroup,location=LOCATION_HAND|LOCATION_GRAVE})
	c:RegisterEffect(e1)
	--To Hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={912789003}
function s.forcedgroup(c,e,tp)
    return c:IsType(TYPE_FLIP) or not c:IsLocation(LOCATION_HAND)
end
function s.ritop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	tc:SetMaterial(mat)
	Duel.ReleaseRitualMaterial(mat)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	tc:CompleteProcedure()
end
function s.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCode(912789003)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.thcfilter,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,s.thcfilter,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0xfec) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
