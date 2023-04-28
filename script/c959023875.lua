--Botnet Stream
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--To Hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfe7,0x2fe7}
function s.matfilter(c,tp,sg,lvl)
	local csg=sg:Clone()
	csg:AddCard(c)
	if (lvl-c:GetLevel())==0 then return c:IsFaceup() and c:IsSetCard(0xfe7)
	elseif c:GetLevel()<lvl then return c:IsFaceup() and c:IsSetCard(0xfe7) and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,csg,tp,csg,lvl-c:GetLevel())
	else return false end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2fe7) and c:IsType(TYPE_RUNE) and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,Group.CreateGroup(),c:GetLevel()) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,Group.CreateGroup(),tc:GetLevel())
		local mg=Group.CreateGroup()
		while mg:GetSum(Card.GetLevel)<tc:GetLevel() do
			local sg=g:Filter(s.matfilter,mg,tp,mg,tc:GetLevel()-mg:GetSum(Card.GetLevel))
			local mt=Group.SelectUnselect(sg,mg,tp,false,false)
			if not mg:IsContains(mt) then mg:AddCard(mt)
			else mg:RemoveCard(mt) end
			mt=nil
			--Debug.Message("Count: " .. tostring(mg:GetCount()) .. " | " .. tostring(mg:GetSum(Card.GetLevel)))
		end
		mg:AddCard(e:GetHandler())
		tc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.thfil(c)
	return c:IsSetCard(0x2fe7) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and s.thfil(chkc) and Duel.IsExistingTarget(s.thfil,tp,LOCATION_DECK,0,1,nil) end
	if chk==0 then return Duel.IsExistingTarget(s.thfil,tp,LOCATION_DECK,0,1,nil) end
	local sg=Duel.SelectTarget(tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
