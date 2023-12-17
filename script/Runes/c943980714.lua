--Runic Instantation
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.runtg)
	e1:SetOperation(s.runop)
	c:RegisterEffect(e1)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=nil
		if Duel.GetCurrentChain()>0 then mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil):AddCard(e:GetHandler()) end
		return Duel.IsExistingMatchingCard(Card.IsRuneSummonable,tp,0x3ff~LOCATION_MZONE,0,1,nil,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsRuneSummonable,tp,0x3ff~LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.RuneSummon(tp,sc)
	end
end
