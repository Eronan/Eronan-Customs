--Library of the Libricon
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --place in pendulum zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTarget(s.pctg)
    e1:SetOperation(s.pcop)
    c:RegisterEffect(e1)
    --immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.etarget)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    	--Fusion Summon
	local params={nil,aux.FilterBoolFunction(aux.NOT(Card.IsType),TYPE_EFFECT),nil,s.fextra}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
						if not e:GetHandler():IsRelateToEffect(e) then return end
						Fusion.SummonEffOP(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp)
					end)
	c:RegisterEffect(e3)
end
s.listed_series={0xfcc}
--place in pendulum zone
function s.pcfilter(c,e,tp)
    return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_PENDULUM) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.pcfilter(chkc,e,tp) end
	if chk==0 then return s.count_free_pendulum_zones(tp)>0 and eg:IsExists(s.pcfilter,1,nil,e,tp) end
    local ct=s.count_free_pendulum_zones(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=eg:FilterSelect(tp,s.pcfilter,1,ct,nil,e,tp)
	Duel.SetTargetCard(g)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    local ct=s.count_free_pendulum_zones(tp)
	if not e:GetHandler():IsRelateToEffect(e) or ct==0 then return end
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
    if #g>ct then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tg=g:Select(tp,1,ct)
        local gyg=g-tg
        Duel.SendToGrave(gyg,REASON_RULE)
        g=tg
    end
    for tc in aux.Next(g) do
        Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
function s.count_free_pendulum_zones(tp)
    local count = 0
    if Duel.CheckLocation(tp,LOCATION_PZONE,0) then
        count = count + 1
    end
    if Duel.CheckLocation(tp,LOCATION_PZONE,1) then
        count = count + 1
    end
    return count
end
--Immune
function s.etarget(e,c)
	return c:IsSetCard(0xfcc) and c:IsFaceup()
end
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--Fusion Summon
function s.fextra(e,tp,mg)
    return Duel.GetMatchingGroup(Card.IsAbleToGrave,e:GetHandlerPlayer(),LOCATION_PZONE,0,nil)
end