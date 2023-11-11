--Primordial Beast Tamer Avem Awaken
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRuneCode,902245100),1,1,Rune.STFunction(nil),2,99)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
	--material check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--immune reg
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={902245100}
function s.nmfilter(c)
	return c:GetOriginalType()==TYPE_SPELL or c:GetOriginalType()==TYPE_TRAP
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local types=0
	if g:IsExists(s.nmfilter,1,nil) then types=types+TYPE_NORMAL end
	if g:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then types=types+TYPE_RITUAL end
	if g:IsExists(Card.IsType,1,nil,TYPE_CONTINUOUS) then types=types+TYPE_CONTINUOUS end
	if g:IsExists(Card.IsType,1,nil,TYPE_QUICKPLAY) then types=types+TYPE_QUICKPLAY end
	if g:IsExists(Card.IsType,1,nil,TYPE_FIELD) then types=types+TYPE_FIELD end
	if g:IsExists(Card.IsType,1,nil,TYPE_EQUIP) then types=types+TYPE_EQUIP end
	if g:IsExists(Card.IsType,1,nil,TYPE_COUNTER) then types=types+TYPE_COUNTER end
	if g:IsExists(Card.IsType,1,nil,TYPE_PENDULUM) then types=types+TYPE_PENDULUM end
	e:SetLabel(types)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ=e:GetLabelObject():GetLabel()
	if typ&TYPE_NORMAL~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3)) end
	if typ&TYPE_RITUAL~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4)) end
	if typ&TYPE_CONTINUOUS~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5)) end
	if typ&TYPE_QUICKPLAY~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6)) end
	if typ&TYPE_FIELD~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,7)) end
	if typ&TYPE_EQUIP~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,8)) end
	if typ&TYPE_COUNTER~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,9)) end
	if typ&TYPE_PENDULUM~=0 then c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,10)) end
	--pendulum
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	e1:SetLabel(typ)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--cannot activate
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
	e2:SetLabel(typ)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)
end
function s.filter(c,label)
	if not label or c:IsFacedown() or not c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsDisabled() then return false end
	if s.nmfilter(c) then return (label&TYPE_NORMAL)==TYPE_NORMAL
	elseif c:IsType(TYPE_CONTINUOUS) then return (label&TYPE_CONTINUOUS) --Unknown Issue that causes Continuous Spell/Traps to not count face-up
	else return c:GetType()&(label-TYPE_NORMAL)>0 end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,e:GetLabel()) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil,e:GetLabel())
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.aclimit(e,re,tp)
	local label=e:GetLabel()
	if not label or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if s.nmfilter(re:GetHandler()) then return (label&TYPE_NORMAL)==TYPE_NORMAL
	else return re:GetActiveType()&(label-TYPE_NORMAL) end
end
