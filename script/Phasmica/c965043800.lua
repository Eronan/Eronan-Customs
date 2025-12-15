--Phasmica Keystone
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon from hand if opponent controls a face-up monster without a Level
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    --(1) You can also Rune Summon "Phasmica" Rune monsters from your GY, using this card as material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc1))
    e2:SetTargetRange(LOCATION_GRAVE,0)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetValue(s.restrict_rune)
    c:RegisterEffect(e2)
    --Add 1 "Phasmica" Spell/Trap from Deck when Normal or Special Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end
s.listed_series={0xfc1}

--Special Summon condition (opponent controls face-up monster without Level)
function s.nolevelfilter(c)
    return c:IsFaceup() and c:GetLevel()==0
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.nolevelfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end

--Restrict Rune summon to include this card as material
function s.restrict_rune(e,tp,sg,rc)
    local c=e:GetHandler()
    return sg and sg:IsContains(c)
end

--Search effect
function s.thfilter(c)
    return c:IsSetCard(0xfc1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
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
