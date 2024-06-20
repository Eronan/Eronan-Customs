--Eternal Sovereign of Zerunic Tides
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,1,Rune.STFunctionEx(Card.IsType,TYPE_FIELD),2,99,nil,s.exgroup,nil,nil,nil,s.customop)
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
    --activate limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(s.accon)
	e5:SetValue(s.aclimit)
	c:RegisterEffect(e5)
    --activate from banished
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMING_MAIN_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetTarget(s.acttg)
	e6:SetOperation(s.actop)
	c:RegisterEffect(e6)
end
s.listed_series={0xfe3}
--Rune Summon
function s.mfilter(c,rc,sumtyp,tp)
    return c:IsType(TYPE_RUNE,rc,sumtyp,tp) and c:IsAttribute(ATTRIBUTE_WATER)
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
    return c:IsRace(RACE_FISH) and c:IsSetCard(0xfe3)
end
function s.matcheck(e,c)
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
function s.accon(e)
	return Duel.IsBattlePhase() or Duel.IsPhase(PHASE_MAIN2)
end
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
--Activate from banished
function s.actfilter(c,e,tp)
	return c:IsFaceup() and c:IsFieldSpell() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.actfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.actfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
    local tc=Duel.GetFirstTarget()
    Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end