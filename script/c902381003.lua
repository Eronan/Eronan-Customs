--Shimzu Iruka
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--rune
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunctionEx(Card.IsSetCard,0xff1),1,1)
	--Non-tuner
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	c:RegisterEffect(e1)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(s.slevel)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.etarget)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
function s.monfilter(c,rc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,rc,sumtyp,tp) and c:IsLevelBelow(4)
end
function s.slevel(e,c)
	local lv=e:GetHandler():GetLevel()
	return 4*65536+lv
end
function s.etarget(e,c)
	return (e:GetHandler():GetColumnGroup():IsContains(c) or c==e:GetHandler()) and c:IsSetCard(0xff1)
end
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
