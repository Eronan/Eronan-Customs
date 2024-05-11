--Mystic Discovery
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={0xfe1}
function s.thcostfilter(c,tp)
	return c:IsType(TYPE_RUNE) and not c:IsPublic()
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.filter1(c)
    return c:IsSetCard(0xfe1) and c:IsAbleToHand()
end
function s.filter2(c,mc)
    return mc:ListsCode(c:GetCode()) and c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,c,tp)
        and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
    --Cost
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,c,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
    local tc=g:GetFirst()
    tc:CreateEffectRelation(e)
    e:SetLabelObject(tc)
    --Target Operations
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil,tc)
    if #g1==0 and #g2==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg1=g1:Select(tp,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg2=g2:Select(tp,1,1,nil)
    sg1:Merge(sg2)
    Duel.SendtoHand(sg1,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg1)
    --Place the revealed card on the bottom of your deck
    if tc:IsRelateToEffect(e) then
        Duel.BreakEffect()
        if tc:IsLocation(LOCATION_DECK) then
            Duel.ShuffleDeck(tp)
            Duel.MoveToDeckBottom(tc)
        else
            Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
        end
    end
    --Check for the Special Summon of a Ritual Monster
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.regop)
    e1:SetLabel(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    --Lose 2500 LP in the End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetCountLimit(1)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetLabelObject(e1)
    Duel.RegisterEffect(e2,tp)
end
--rune check
function s.runfilter(c,tp)
	return c:IsType(TYPE_RITUAL) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg and eg:IsExists(s.runfilter,1,nil,tp) then
		e:SetLabel(0)
	end
end
--lose 2500 lp
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local lp=Duel.GetLP(tp)
	Duel.SetLP(tp,lp-2500)
end