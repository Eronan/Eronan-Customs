--Proxumia Channelroot - Aetherel
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
	--You can only Special Summon once per turn
    c:SetSPSummonOnce(id)
    --search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Allow linked monster as whole Tribute
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.rittg)
    e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(Ritual.WholeLevelTributeValue(s.ritval))
	c:RegisterEffect(e2)
end
s.listed_series={0xfc3}
--Link
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0xfc3,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
--Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return c:IsSetCard(0xfc3) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Allow linked monster as whole Tribute
function s.rittg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.ritval(c,e)
    return c:IsSetCard(0xfc3) and c:IsControler(e:GetHandlerPlayer())
end