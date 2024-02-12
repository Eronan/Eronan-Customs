--Divine Magus of Zerunic Radiance
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,1,Rune.STFunction(s.stfilter),2,99,nil,s.exgroup,nil,nil,nil,s.customop)
	c:EnableReviveLimit()
	--Summon Limit
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
    --Cannot be Tributed
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
    e3:SetCondition(s.tgcon)
	e3:SetValue(1)
    e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
    --cannot be target
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
    --activate limit
    s.divine_magus_table={}
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_PZONE)
	e6:SetOperation(s.aclimit)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_PZONE)
	e7:SetTargetRange(1,1)
	e7:SetValue(s.elimit)
	c:RegisterEffect(e7)
    --set to field
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,id)
	e8:SetTarget(s.fgtg)
	e8:SetOperation(s.fgop)
	c:RegisterEffect(e8)
end
s.listed_series={0xfe3}
--Rune Summon
function s.mfilter(c,rc,sumtyp,tp)
    return c:IsType(TYPE_RUNE,rc,sumtyp,tp) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.stfilter(c,rc,sumtyp,tp)
    local typ=c:GetOriginalType()
    return typ==TYPE_SPELL or typ==TYPE_TRAP
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--material check
function s.mchkfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0xfe3)
end
function s.matcheck(e,c)
    s.divine_magus_table={}
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(s.mchkfilter,1,nil) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
--cannot be tribute or targeted
function s.tgcon(e)
	return e:GetLabelObject():GetLabel()~=0
end
--activate limit
function s.aclimit(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandlerPlayer()~=tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
        or not re:GetActiveType()==TYPE_SPELL or not re:GetActiveType()==TYPE_TRAP then return end
	s.divine_magus_table[re:GetHandler():GetCode()]=true
end
function s.elimit(e,te,tp)
    return te:GetHandlerPlayer()~=tp or s.divine_magus_table[te:GetHandler():GetCode()]
end
--set to field
function s.filter(c)
	return c:GetType()==(TYPE_TRAP) or c:GetType()==(TYPE_SPELL) and c:IsSSetable()
end
function s.fgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
end
function s.fgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)>0 then
		--Cannot be activated unless you control a Fiend monster
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
