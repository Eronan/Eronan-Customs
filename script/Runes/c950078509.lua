--Shadow of Chaining Vines
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,1,Rune.STFunctionEx(Card.IsRuneCode,50078509),1,1,nil,s.exgroup)
    c:EnableReviveLimit()
    --Perform Rune Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_CHAIN_DISABLED)
    e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
    e1:SetCost(s.rncost)
    e1:SetTarget(s.rntg)
    e1:SetOperation(s.rnop)
    c:RegisterEffect(e1)
    --Destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
    --Destroy
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE|LOCATION_GRAVE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,50078509))
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_names={50078509}
--Rune Material
function s.mfilter(c)
    return c:IsType(TYPE_EFFECT) and not c:IsSummonableCard()
end
function s.exfilter(c,tp)
    return c:IsControler(1-tp) and c:IsType(TYPE_MONSTER)
end
function s.exgroup(tp,ex,c)
    local fg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ex,50078509)
    local mg=Group.CreateGroup()
    for tc in aux.Next(fg) do
        mg:AddCard(tc:GetCardTarget())
    end
	return mg:Filter(s.exfilter,nil,tp)
end
--Perform Rune Summon
function s.rncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.runfilter(c)
	return c:IsType(TYPE_RUNE) and c:IsAbleToHand() and c:IsRuneSummonable(nil,nil,nil,nil,LOCATION_HAND)
end
function s.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.rnop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		
		--Rune Summon
		local rc=g:GetFirst()
		if rc:IsRuneSummonable() then
			Duel.RuneSummon(tp,rc)
		end
	end
end
--Destroy Replace
function s.repfilter(c,e)
	return c:IsFaceup() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
--Destroy "Fiendish Chain" targeted monsters
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
