--Runic Instantation
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c0)
	e1:SetTarget(s.runtg)
	e1:SetOperation(s.runop)
	c:RegisterEffect(e1)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRuneSummonable,tp,0x3ff~LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsRuneSummonable,tp,0x3ff~LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.ProcedureSummon(0,sc,SUMMON_TYPE_RUNE)
	end
end
