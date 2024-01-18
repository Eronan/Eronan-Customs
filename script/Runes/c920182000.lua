--Snake-Eyes Pyrostellus Draco
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,1,Rune.STFunctionEx(Card.IsContinuousSpell),1,99,nil,s.exgroup)
	c:EnableReviveLimit()
    --Place a monster in the Spell/Trap Zone as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
function s.exfilter(c)
    return c:IsContinuousSpell() and c:IsFaceup()
end
function s.exgroup(tp,ex,rc)
	return Duel.GetMatchingGroup(s.exfilter,tp,0,LOCATION_ONFIELD,ex)
end
--place as Continuous Spell
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(p,LOCATION_SZONE)
		and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden())
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		--Treat it as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		tc:RegisterEffect(e1)
        --disable field
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetRange(LOCATION_SZONE)
        e2:SetCode(EFFECT_DISABLE_FIELD)
        e2:SetProperty(EFFECT_FLAG_REPEAT+EFFECT_FLAG_CLIENT_HINT)
        e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
        e2:SetOperation(s.disop)
        tc:RegisterEffect(e2)
	end
end
function s.disop(e,tp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	if Duel.CheckLocation(c:GetControler(),LOCATION_MZONE,seq) then
		return 0x1<<seq
	end
	return 0
end