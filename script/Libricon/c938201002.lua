--Libricon of the Outer World
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,2,nil,nil,99)
    --pendulum attributes
    Pendulum.AddProcedure(c,false)
    --place in pendulum zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_PZONE)
    e1:SetTarget(s.pctg)
    e1:SetOperation(s.pcop)
    c:RegisterEffect(e1)
    --activate check and limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(s.aclimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.aclimit2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetCondition(s.econ)
	e4:SetValue(s.elimit)
	c:RegisterEffect(e4)
end
--place in pendulum zone
function s.pcfilter(c,e,tp)
    return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_PENDULUM) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.pcfilter(chkc,e,tp) end
	if chk==0 then return Duel.CheckPendulumZones(tp) and eg:IsExists(s.pcfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=eg:FilterSelect(tp,s.pcfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--activate limit
function s.aclimit(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) or re:GetActivateLocation()&LOCATION_MZONE==0 then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_CONTROL|RESET_PHASE|PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) or re:GetActivateLocation()&LOCATION_MZONE==0 then return end
	e:GetHandler():ResetFlagEffect(id)
end
function s.econ(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.elimit(e,te,tp)
	return te:IsActiveType(TYPE_MONSTER) and te:GetActivateLocation()&LOCATION_MZONE==LOCATION_MZONE
end
