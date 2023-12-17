--Knight Virutalia
local s,id=GetID()
function s.initial_effect(c)
	--Change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_SZONE)
	e1:SetValue(910283020)
	c:RegisterEffect(e1)
	--A ritual monster using this card cannot be targeted by opponent's card effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
	--ritual summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.ritcost)
	e3:SetTarget(s.rittg)
	e3:SetOperation(s.ritop)
	c:RegisterEffect(e3)
end
s.listed_names={910283020}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_RITUAL
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local rc=eg:GetFirst()
    for rc in aux.Next(eg) do
        if rc:GetFlagEffect(id)==0 then
			--immune to non-targeting effects
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetLabel(ep)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
    end
end
function s.tgval(e,re,rp)
    return rp==1-e:GetLabel()
end
function s.efilter(e,re,rp)
	if e:GetLabel()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
function s.ritfilter(c)
    return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
    return true
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        local tg=te:GetTarget()
        return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then
        if e:GetLabel()==0 then return false end
        e:SetLabel(0)
        return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    e:SetLabel(0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local te=g:GetFirst():CheckActivateEffect(true,true,false)
    e:SetLabelObject(te)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetProperty(te:GetProperty())
    local tg=te:GetTarget()
    if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
    Duel.ClearOperationInfo(0)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if not te then return end
    local op=te:GetOperation()
    if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
