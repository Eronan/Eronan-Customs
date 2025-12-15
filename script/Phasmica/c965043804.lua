--Phasmica Luminous Conductor
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    --(1) Use this card in the Extra Deck as Rune material for Phasmica Rune Summons from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetOperation(s.extracon)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)
    if s.flagmap==nil then s.flagmap={} end
    if s.flagmap[c]==nil then s.flagmap[c]={} end

    --(2) If sent to GY: place in S/T zone as Continuous Spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.tfcon)
    e2:SetTarget(s.tftg)
    e2:SetOperation(s.tfop)
    c:RegisterEffect(e2)

    --(3) If Synchro Summoned: add 1 "Phasmica" monster from Deck to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

-- Extra material handlers
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
    return (not sg or sg:FilterCount(s.flagcheck,nil)<2)
end
function s.flagcheck(c)
    return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
    local c=e:GetHandler()
    if chk==0 then
        local tp,sc=...
        if summon_type~=SUMMON_TYPE_RUNE or Duel.GetFlagEffect(tp,id)>0 or not sc:IsLocation(LOCATION_HAND)
            or not sc:IsSetCard(0xfc1) then
            return Group.CreateGroup()
        else
            table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
            return Group.FromCards(c)
        end
    elseif chk==1 then
        local sg,sc,tp=...
        if summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 and Duel.GetFlagEffect(tp,id)==0 then
            Duel.Hint(HINT_CARD,tp,id)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    elseif chk==2 then
        for _,eff in ipairs(s.flagmap[c]) do
            eff:Reset()
        end
        s.flagmap[c]={}
    end
end

-- place in S/T zone when sent to GY
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        --Treat it as a Link Spell
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		c:RegisterEffect(e1)
    end
end

-- search on Synchro Summon
function s.thfilter(c)
    return c:IsSetCard(0xfc1) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
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
