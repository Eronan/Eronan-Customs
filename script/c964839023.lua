--Sylph Dancer of Everunic Winds
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunction(s.MNMatFilter),1,1,Rune.STFunction(s.STMatFilter),1,1,nil,s.exgroup,nil,nil,s.exchk)
	c:EnableReviveLimit()
	--must rune summon
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
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.immcon)
	e3:SetValue(s.efilter)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--activate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.tfcon)
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)
	--Send 1 monster from your extra deck to GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.actcon)
	e5:SetOperation(s.actop)
	c:RegisterEffect(e5)
end
s.listed_names={964839022}
function s.MNMatFilter(c,rc,sumtype,tp)
	return c:IsRace(RACE_FAIRY,rc,sumtype,tp) and not c:IsSummonableCard()
end
function s.STMatFilter(c,rc,sumtyp,tp)
	return (c:GetType(rc,sumtyp,tp)&TYPE_TRAP+TYPE_CONTINUOUS)==TYPE_TRAP+TYPE_CONTINUOUS
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(aux.NOT(Card.IsType),tp,LOCATION_EXTRA,0,ex,TYPE_EFFECT)
end
function s.exchk(sg,c,r,tp)
	return sg:Filter(aux.NOT(Card.IsType),nil,TYPE_EFFECT):FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,964839022) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function s.efilter(e,re,rp)
	if e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.tffilter(c,tp)
	return c:IsContinuousSpell() and not c:IsForbidden()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:GetActivateLocation()==LOCATION_HAND
		and Duel.IsTurnPlayer(tp)
end
--Prevent activation from hand
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,1),nil)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
