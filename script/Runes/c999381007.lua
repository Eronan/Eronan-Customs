--Greenwood Discovery
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
    return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_RUNE)
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.setfilter(c,rc)
    return c:IsSSetable() and rc:ListsCode(c:GetCode())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
    local rc=g:GetFirst()
    e:SetLabel(rc:GetFieldID())
    e:SetLabelObject(rc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetLabelObject()
    local c=e:GetHandler()
	c:CancelToGrave(true)
    if not rc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if #g>0 then
		Duel.SSet(tp,g)
	end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_SZONE)
    e1:SetOperation(s.checkop)
    e1:SetLabel(e:GetLabel())
    e1:SetLabelObject(rc)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsSummonType(SUMMON_TYPE_RUNE) then
		Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
        local rc=e:GetLabelObject()
        if rc:GetFieldID()==e:GetLabel() and rc:IsLocation(LOCATION_REMOVED) then
            Duel.SendtoHand(rc,tp,REASON_EFFECT)
        end
	end
end
