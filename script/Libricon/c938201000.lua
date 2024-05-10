--Creator Libricon Serpent
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(aux.NOT(Card.IsType),TYPE_EFFECT),2)
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
    --act limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,1)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)
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
    local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--cannot activate monster effects on the field
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return rc:IsMonster() and rc:IsOnField()
end
