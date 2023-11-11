--Chantress of the Runic Risen
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunction(s.STMatFilter),1,1)
	--Set Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.setcon1)
	e1:SetTarget(s.settg1)
	e1:SetOperation(s.setop1)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.cost)
	e2:SetCondition(s.setcon2)
	e2:SetTarget(s.settg2)
	e2:SetOperation(s.setop2)
	c:RegisterEffect(e2)
end
function s.STMatFilter(c,rc,sumtyp,tp)
	return (c:GetOriginalType()==TYPE_SPELL or c:GetOriginalType()==TYPE_TRAP)
end
function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.mgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetMaterial()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and mg:FilterCount(s.mgfilter,nil)>0 end
end
function s.setop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if mg:FilterCount(s.mgfilter,nil)>0 then
		local tc=mg:FilterSelect(c:GetControler(),s.mgfilter,1,1,nil)
		Duel.SSet(tp,tc)
		--Duel.ConfirmCards(1-tp,tc)
	end
end
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsLocation(LOCATION_GRAVE) and c:GetControler()==1-tp and c:IsSSetable()
end
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e:GetHandlerPlayer())
end
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(e:GetHandlerPlayer(),LOCATION_SZONE)>0 and eg:IsExists(s.filter,1,nil,e:GetHandlerPlayer()) end
end
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(c:GetControler(),LOCATION_SZONE)<=0 then return end
	local g=eg:Filter(s.filter,nil,c:GetControler())
	if g:GetCount()>0 then
		local tc=g:Select(c:GetControler(),1,1,nil)
		Duel.SSet(tp,tc)
		--Duel.ConfirmCards(1-tp,tc)
	end
end
