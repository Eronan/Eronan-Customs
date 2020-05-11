--Duplicity Summoning Circle
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={0xfe8}
function s.plyrfilter(c,e)
	return c:IsSetCard(0xfe8) and c:IsRuneSummonable(e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=Duel.IsExistingMatchingCard(s.plyrfilter,tp,LOCATION_HAND,0,1,nil,e)
	local b2=true
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else 
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1 
	end
	if op==0 then
		e:SetOperation(s.plyroperation)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetOperation(s.oppoperation)
	end
end
function s.plyroperation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.plyrfilter,tp,LOCATION_HAND,0,1,nil,e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.plyrfilter,tp,LOCATION_HAND,0,1,1,nil,e)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		Duel.RuneSummon(tp,sc,e:GetHandler())
	end
end
function s.exfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.oppfilter(c,e,tp,exg)
	local dfg=Rune.DefaultGroup(c,1-tp)
	if dfg then
		return c:IsRuneSummonable(e:GetHandler(),dfg+exg)
	else return false end
end
function s.oppoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	if Duel.IsExistingMatchingCard(s.oppfilter,tp,0,0x3ff~LOCATION_MZONE,1,nil,e,tp,exg)
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
		--Summon
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(1-tp,s.oppfilter,tp,0,0x3ff~LOCATION_MZONE,1,1,nil,e,tp,exg)
		if g:GetCount()>0 then
			local sc=g:GetFirst()
			local dfg=Rune.DefaultGroup(sc,1-tp)
			Duel.RuneSummon(1-tp,sc,e:GetHandler(),exg+dfg)
		end
	else
		--Send to the Grave
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
