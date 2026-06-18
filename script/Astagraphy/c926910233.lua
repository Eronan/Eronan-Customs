--CelsiAstagraphy Sagittarius Eoh
if not Rune then Duel.LoadScript("proc_rune.lua") end
local SET_ASTAGRAPHY=0xfef
local CARD_ASTRAGRAPHY_EOH=926910232
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon procedure
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_RUNE),1,1,Rune.MonFunction(Card.IsTrap),2,99)
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.runlimit)
	c:RegisterEffect(e0)
	--(1) Add Astagraphy from GY when Trap activated
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetOperation(aux.chainreg)
	c:RegisterEffect(e1b)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)

	--(2) Activate Continuous Traps from hand or same turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsTrapMonster))
	c:RegisterEffect(e3)

	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e3b:SetTargetRange(LOCATION_SZONE,0)
	e3b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e3b)

	--(3a) Cannot be Tributed
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)

	local e4b=e4:Clone()
	e4b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4b)

	--(3b) Unaffected by non-targeting activated effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
end
s.listed_series={SET_ASTAGRAPHY}
s.listed_names={CARD_ASTRAGRAPHY_EOH}
--Check if Trap activated
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect() and e:GetHandler():GetFlagEffect(1)>0
end
function s.thfilter(c)
	return c:IsSetCard(SET_ASTAGRAPHY) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
--Material Check
function s.valcheck(e,c)
    local te=e:GetLabelObject()
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,CARD_ASTRAGRAPHY_EOH) then
		te:SetCountLimit(3)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	else
		te:SetCountLimit(1,id)
	end
end
--Immunity filter
function s.efilter(e,te)
    if not te:IsActivated() then return false end
    if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return not g:IsContains(e:GetHandler())
end