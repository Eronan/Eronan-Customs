--Catenicorum Circle
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	--rune summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.runcon)
	e3:SetTarget(s.runtg)
	e3:SetOperation(s.runop)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.tfcon)
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfcf}
--activate from hand
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
--rune summon
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsBattlePhase()
end
function s.runfilter(c,deckcon,mg)
	if deckcon then return c:IsSetCard(0xfcf) and c:IsRuneSummonable(nil,mg,2,2)
	else return c:IsSetCard(0xfcf) and c:IsRuneSummonable() end
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local deckcon = not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
	local c=e:GetHandler()
	if chk==0 then
		if Duel.GetFlagEffect(tp,id)>0 then return false end
		if deckcon then
			local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneMaterial,tp,LOCATION_DECK,0,nil)
			return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,deckcon,mg)
		else
			return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,deckcon)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then
		local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneMaterial,tp,LOCATION_DECK,0,nil)
		local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_HAND,0,nil,true,mg)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.RuneSummon(tp,sc,nil,mg,2,2)
		end
	else
		local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_HAND,0,nil,false)
		if e:GetHandler():IsRelateToEffect(e) and g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=g:Select(tp,1,1,nil)
			local sc=tg:GetFirst()
			Duel.RuneSummon(tp,sc)
		end
	end
end
--place on field
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
