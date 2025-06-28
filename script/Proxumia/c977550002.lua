--Crown Proxumia - Myrheval
local s,id=GetID()
function s.initial_effect(c)
    --link summon
    Link.AddProcedure(c,nil,2,99,s.lcheck)
    c:EnableReviveLimit()
    --Allow linked monster as whole Tribute
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.rittg)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(Ritual.WholeLevelTributeValue(s.ritval))
	c:RegisterEffect(e1)
    --Control card opponent controls
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.ctcon)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    --Change to face-down Defense Position
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.poscon)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)

end
--Link Summon Check
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_RITUAL)
end
--Allow linked monster as whole Tribute
function s.rittg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.ritval(c,e)
    return c:IsControler(e:GetHandlerPlayer())
end
--Control monster that activated effect
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    local p,loct=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
    return loct==LOCATION_MZONE and re:IsMonsterEffect() and p==1-tp
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetLinkedZone()&ZONES_MMZ>0 end
    local tc=re:GetHandler()
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,tp,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsControler(1-tp)) then return end
    local zone=c:GetLinkedZone()&ZONES_MMZ
    Duel.GetControl(tc,tp,0,0,zone)
end
--Change to face-down Defense Position
function s.poscfilter(c)
    return c:IsRitualSummoned()
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.poscfilter,1,nil)
end
function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end