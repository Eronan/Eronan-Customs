--Rumbling the Discharge Dynast
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),2,99,Rune.STFunction(nil),2,99)
	--effect gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then
		--remove
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_REMOVE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetTarget(s.remtg)
		e1:SetOperation(s.remop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
		--immune
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(s.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e2)
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		--remove
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTarget(s.rmtarget)
		e3:SetTargetRange(0xff,0xff)
		e3:SetValue(LOCATION_REMOVED)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e3)
		--
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(id)
		e4:SetRange(LOCATION_MZONE)
		e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e4:SetTargetRange(0xff,0xff)
		e4:SetTarget(s.checktg)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e4)
	end
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(1-tp,69832741) then
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,0x0e,1,nil)
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,0x1e,1,nil)
		end
	end
	if Duel.IsPlayerAffectedByEffect(1-tp,69832741) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0x0e)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0x1e)
	end
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	local sg=Group.CreateGroup()
	if #g1>0 and ((#g2==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	if #g2>0 and ((#sg==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,4))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	if #g3>0 and (#sg==0 or Duel.SelectYesNo(tp,aux.Stringid(id,5))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:RandomSelect(tp,1)
		sg:Merge(sg3)
	end
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function s.efilter(e,re,rp)
	if e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
function s.rmtarget(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.checktg(e,c)
	return not c:IsPublic()
end
