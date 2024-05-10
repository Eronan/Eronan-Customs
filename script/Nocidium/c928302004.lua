--Emberstorm Invocation
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon
	local e1=Ritual.AddProcGreater({
        handler=c,
        filter=s.ritualfil,
        lv=s.rituallvl
    })
	-- Add 1 banished Ritual or Rune monster to the hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={928302001}
s.counter_list={0x10fc}
--Ritual Summon
function s.ritualfil(c)
    return c:ListsCode(928302001) or c:IsCode(928302001)
end
function s.rituallvl(c)
    local ct=Duel.GetCounter(c:GetControler(),1,1,0x10fc)
    return c:GetLevel() - ((ct>3 and 3) or 0)
end
--Add 1 of your banished Ritual or Rune monsters
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.thfilter(c)
    return c:IsMonster() and (c:IsType(TYPE_RUNE) or c:IsType(TYPE_RITUAL)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end