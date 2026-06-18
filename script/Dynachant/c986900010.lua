--Dynachant Spectre, Gashaqa Medium
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()

--constants
local SET_DYNACHANT=0xfe5 --replace
local TOKEN_DYNACHANT_BEING=986900019
local CARD_DYNACHANT_SPECTRE=986900004

function s.initial_effect(c)

	--Rune Summon procedure (custom engine hook assumed)
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,SET_DYNACHANT),2,2,Rune.STFunction(Card.IsContinuousSpellTrap),2,99)

    --cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.runlimit)
	c:RegisterEffect(e0)

	--(1) protection if summoned using Spectre
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(s.protcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfcf))
	e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
    c:RegisterEffect(e3)

	--(2) token forced material effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.matcon)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)

	--(3) leave field nuke
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)

end
s.listed_names={TOKEN_DYNACHANT_BEING,CARD_DYNACHANT_SPECTRE}
s.listed_series={SET_DYNACHANT}
---------------------------------------------------
--(1) Protection if Spectre used
---------------------------------------------------
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end

-- Material Check
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,CARD_DYNACHANT_SPECTRE) then
		e:SetLabel(1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	else
		e:SetLabel(0)
	end
end

---------------------------------------------------
--(2) Token forces opponent material usage
---------------------------------------------------
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(Card.IsType,1,nil,TYPE_TOKEN)
end

function s.matfilter(c,ec)
	return c:IsFaceup() and not ec:IsHasCardTarget(c)
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_MZONE,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_MZONE,1,1,nil,c)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

    c:SetCardTarget(tc)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_MUST_BE_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCondition(s.matlimitcon)
    e1:SetTargetRange(1,0)
	e1:SetLabel(tc:GetControler())
    e1:SetValue(REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK+REASON_RUNE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
end

function s.matlimitcon(e)
	local ec=e:GetOwner()
    local tc=e:GetHandler()
	return ec and ec:IsHasCardTarget(tc)
		and tc:IsControler(e:GetLabel())
end
---------------------------------------------------
--(3) leave field nuke
---------------------------------------------------

function s.rmcfilter(c)
	return c:IsCode(TOKEN_DYNACHANT_BEING) and c:IsReleasable()
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmcfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.rmcfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local og=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    Duel.Remove(og,POS_FACEDOWN,REASON_EFFECT)
end