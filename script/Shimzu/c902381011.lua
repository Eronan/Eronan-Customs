--CelsiShimzu Delphinus Iruka
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(nil),2,99)
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
    --Destruction protection
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.immcon)
	e3:SetLabelObject(e1)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetTargetRange(LOCATION_ONFIELD,0)
	c:RegisterEffect(e4)
    --change effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.chcon)
	e5:SetTarget(s.chtg)
	e5:SetOperation(s.chop)
	c:RegisterEffect(e5)
    --immune
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_ONFIELD,0)
	e6:SetTarget(s.etarget)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
end
s.listed_names={902381003}
--Rune Summon
function s.monfilter(c,rc,sumtyp,tp)
    return c:IsAttribute(ATTRIBUTE_WIND,rc,sumtyp,tp) and c:IsType(TYPE_RUNE,rc,sumtyp,tp)
end
--prevent battle and effect destruction
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,902381003) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
--change effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.rmfilter(c)
	return c:IsAttackPos() and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.rmop)
end
--immune
function s.etarget(e,c)
	return (e:GetHandler():GetColumnGroup():IsContains(c) or c==e:GetHandler()) and c:IsSetCard(0xff1)
end
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
