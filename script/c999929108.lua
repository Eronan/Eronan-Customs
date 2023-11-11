--Deicid, Runic Devouring Chimera
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunction(nil),3,99,Rune.STFunction(nil),2,2,nil,s.exgroup)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
	--check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	--Banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetLabelObject(e2)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Co-linked monsters you control are unaffected by opponent's activated monster effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetValue(s.efilter)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(35952884,1))
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
--rune summon functions
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,ex)
end
function s.rccheck(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
function s.rune_custom_check(g,rc,sumtype,tp)
	local rccheck=0
	for mc in Group.Iter(g) do
		if not mc:IsOnField() then return false end
		if s.rccheck(mc,tp) then rccheck=rccheck+1 end
		if rccheck>1 then return false end
	end
	return rccheck==1
end
--material check
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local usedrune=0
	if g:IsExists(Card.IsType,1,nil,TYPE_RUNE) then
		usedrune=1
	end
	local att=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		att=(att|tc:GetOriginalAttribute())
	end
	for _,str in aux.GetAttributeStrings(att) do
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,str)
	end
	e:SetLabelObject({usedrune,att})
end
--remove
function s.rmcon(e,c)
	local usedrune,att=table.unpack(e:GetLabelObject():GetLabelObject())
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
		and usedrune==1
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
--Functions for immunity from effects
function s.efilter(e,te)
	local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
	local usedrune,att=table.unpack(e:GetLabelObject():GetLabelObject())
	return te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()==1-te:GetHandlerPlayer()
		and te:GetHandler():IsAttribute(att)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
