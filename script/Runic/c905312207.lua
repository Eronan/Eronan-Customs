--Etherunetation - Runic Transmutation
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Search "Ever-Runic Incantation"
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={905312206}
--rune 
function s.mustbematerialsallowed(tp,mg)
	local pg=aux.GetMustBeMaterialGroup(tp,mg,tp,nil,nil,REASON_RUNE)
	if #pg>#mg then return false
	elseif #pg==#mg then return pg:Equal(mg)
	elseif #pg==0 then return true
	elseif #pg==1 then return mg:IsContains(pg:GetFirst())
	else return not mg:IsExists(function (c) return not pg:IsContains(c) end,1,nil) end
end
function s.filter1(c,e,tp)
	return s.mustbematerialsallowed(tp,Group.FromCards(c,e:GetHandler())) and c:IsFaceup() and c:IsType(TYPE_RUNE)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:ListsCode(mc:GetCode()) and c:IsType(TYPE_RUNE) and c:IsRuneCustomCheck(Group.FromCards(e:GetHandler(),mc),tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.relatefilter(c,e,tp)
	return c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local mg=Group.FromCards(tc,c):Filter(s.relatefilter,nil,e,tp)
	if not mg:IsContains(tc) or not s.mustbematerialsallowed(tp,mg) then
		mg:DeleteGroup()
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		Duel.SpecialSummon(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
		sc:CompleteProcedure()
	end
	mg:DeleteGroup()
end
--to hand
function s.thfilter(c)
	return c:IsCode(905312206) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end