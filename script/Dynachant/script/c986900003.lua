--Dynachanter Priestess
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_EFFECT),1,1,Rune.STFunctionEx(Card.IsRuneCode,986900000),1,1)
	--Search spell/trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.con)
	e2:SetValue(s.tglimit)
	c:RegisterEffect(e2)
	--cannot be effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tglimit)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.listed_names={986900000}
--If a monster is special summoned to its zones
function s.descfilter(c,tp)
	return c:IsControler(tp) and not c:IsType(TYPE_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.descfilter,1,nil,tp)
end
function s.desgroup(eg,tp)
	local desg=Group.CreateGroup()
	for c in aux.Next(eg) do
		desg:AddCard(c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp))
	end
	return desg
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=s.desgroup(eg,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=s.desgroup(eg,tp)
	if #dg>0 then
		local dc=dg:Select(tp,1,1,nil)
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
function s.cfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
