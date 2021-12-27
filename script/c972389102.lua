--Contaminet DDos
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1fe7),1,1,aux.FilterBoolFunction(Card.IsCode,912389041),2,nil,nil,s.getGroup)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.distarget)
	c:RegisterEffect(e2)
	--disable effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--disable trap monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.distarget)
	c:RegisterEffect(e4)
end
s.listed_series={0x1fe7}
s.listed_names={912389041}
function s.getGroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,ex)
end
function s.distarget(e,c)
	return c:IsFaceup() and c:IsCode(912389041)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler():IsCode(912389041) and re:GetHandler():GetControler()~=e:GetHandler():GetControler() then
		Duel.NegateEffect(ev)
	end
end
