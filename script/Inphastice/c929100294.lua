--Inphastice Aethersaqa Vector
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_INPHASTICE=0xfbd
local CARD_VECTOR=929100292 -- Inphastice Vector passcode

function s.initial_effect(c)
    --Pendulum Summon from Extra Deck
    Pendulum.AddProcedure(c)
    --Rune Summon: 2+ "Inphastice" monsters + 1+ Spell/Trap; also from Extra Deck
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,SET_INPHASTICE),2,99,Rune.STFunction(nil),1,99,LOCATION_EXTRA)

    --Summon Limit
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.runlimit)
    c:RegisterEffect(e0)

    --------------------------------------------------
    -- [Pendulum Effect],tp
    -- If another "Inphastice" monster is Special Summoned:
    -- Target 1 opponent monster; change to face-down DEF. HOPT.
    --------------------------------------------------
    local ep1=Effect.CreateEffect(c)
    ep1:SetDescription(aux.Stringid(id,0))
    ep1:SetCategory(CATEGORY_POSITION)
    ep1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    ep1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ep1:SetRange(LOCATION_PZONE)
    ep1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    ep1:SetCountLimit(1,id)
    ep1:SetCondition(s.pcon)
    ep1:SetTarget(s.ptg)
    ep1:SetOperation(s.pop)
    c:RegisterEffect(ep1)

    --------------------------------------------------
    -- [Monster Effect 1]
    -- Quick Effect: Place this card in Pendulum Zone;
    -- Special Summon 1 "Inphastice Vector" from GY, face-up Extra Deck, or Pendulum Zone. HOPT.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.vectg)
    e1:SetOperation(s.vecop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- [Monster Effect 2]
    -- If card(s) added from Deck to opponent's hand except by drawing:
    -- Declare 1 card name; negate effects of face-up cards with that name this turn. HOPT.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.addcon)
    e2:SetTarget(s.addtg)
    e2:SetOperation(s.addop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_INPHASTICE}
s.listed_names={CARD_VECTOR}

--------------------------------------------------
-- [Pendulum Effect] Another "Inphastice" Special Summoned → flip-down opponent monster
--------------------------------------------------
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return eg:IsExists(function(tc)
        return tc:IsSetCard(SET_INPHASTICE) and tc:IsSummonPlayer(tp) and tc~=c
    end,1,nil)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsCanTurnSet() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end

--------------------------------------------------
-- [Effect 1] Place in Pendulum Zone + SS Inphastice Vector
--------------------------------------------------
function s.vecfilter(c,e,tp)
    if c:IsLocation(LOCATION_EXTRA) and (Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)==0 or c:IsFacedown()) then return false end
    return c:IsCode(CARD_VECTOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.vectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local loc=LOCATION_EXTRA
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if e:GetHandler():GetSequence()<5 then ft=ft+1 end
        if ft>0 then loc=loc|LOCATION_GRAVE|LOCATION_PZONE end
        return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.vecfilter,tp,loc,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_PZONE)
end
function s.vecop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Move this card to Pendulum Zone
    if c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
        local loc=LOCATION_EXTRA
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_PZONE|LOCATION_GRAVE end
        -- Special Summon 1 "Inphastice" from Deck or face-up Extra Deck in DEF
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.vecfilter,tp,loc,0,1,1,nil,e,tp)
        if #g>0 then
           Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
end

--------------------------------------------------
-- [Effect 2] Cards added to opponent's hand from deck except draw → declare name + negate
--------------------------------------------------
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    -- Must have been added from deck (not by drawing)
    return eg:IsExists(function(c) return not c:IsReason(REASON_RULE) end,1,nil)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- Declare a card name
    local code=Duel.AnnounceCard(tp)
    e:SetLabel(code)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetLabel()
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.distg)
    e1:SetLabel(code)
    e1:SetReset(RESET_PHASE|PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetCondition(s.discon)
    e2:SetOperation(s.disop)
    e2:SetLabel(code)
    e2:SetReset(RESET_PHASE|PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
end
function s.distg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsMonsterEffect() and (code1==code or code2==code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
