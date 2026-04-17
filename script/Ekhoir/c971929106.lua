--Ekhoir Grand Rehearsal
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd

function s.initial_effect(c)
    --Activate from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    --act in hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCondition(s.handcon)
    c:RegisterEffect(e2)
end
function s.deckfilter(c,mg)
    return c:IsSetCard(SET_EKHOIR) and c:IsRuneSummonable(nil,mg,2,2)
end
function s.matfilter(c)
    return c:IsSetCard(SET_EKHOIR) and c:IsCanBeRuneMaterial()
end
function s.create_rune_location_effect(c,tp)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_RUNE_LOCATION)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EKHOIR))
    e1:SetTargetRange(LOCATION_DECK|LOCATION_GRAVE,0)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    Duel.RegisterEffect(e1,tp)
    return e1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local runloc_effect=s.create_rune_location_effect(c,tp)
    local deckmat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
    local deckok=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,deckmat)
    local handmat=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeRuneGroup,s.matfilter),tp,LOCATION_ONFIELD,0,c)
    local handok=Duel.IsExistingMatchingCard(Card.IsRuneSummonable,tp,LOCATION_HAND,0,1,nil,nil,handmat)
    if chk==0 then
        runloc_effect:Reset()
        return deckok or handok
    end
    local op=Duel.SelectEffect(tp,
		{deckok,aux.Stringid(id,0)},
		{handok,aux.Stringid(id,1)})
    e:SetLabel(op)
    if op==1 then e:SetOperation(s.activate1)
    elseif op==2 then e:SetOperation(s.activate2)
    else e:SetOperation(function () end) end
    runloc_effect:Reset()
end

function s.activate1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local e1=s.create_rune_location_effect(e:GetHandler(),tp)
    --Deck/GY summon
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
    local g=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,mg)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local rc=g:Select(tp,1,1,nil):GetFirst()
        Duel.RuneSummon(tp,rc,nil,mg,2,2)
        s.postop(e,rc)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetDescription(aux.Stringid(id,3))
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_RUNE_LOCATION)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        rc:RegisterEffect(e2)
    end
    e1:Reset()
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeRuneGroup,s.matfilter),tp,LOCATION_ONFIELD,0,e:GetHandler())
    local g=Duel.GetMatchingGroup(Card.IsRuneSummonable,tp,LOCATION_HAND,0,nil,nil,mg)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local rc=g:Select(tp,1,1,nil):GetFirst()
        Duel.RuneSummon(tp,rc,nil,mg)
        s.postop(e,rc)
    end
end
function s.postop(e,rc)
    --Keep Trap face-up and track summoned monster
    local c=e:GetHandler()
    c:CancelToGrave()
    if rc then
        c:SetCardTarget(rc)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
        e1:SetOperation(function(te,tp,eg,ep,ev,re,r,rp)
            c:SetCardTarget(rc) -- link monster to Trap
        end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        rc:RegisterEffect(e1)
        --When this card leaves the field, destroy that monster
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EVENT_LEAVE_FIELD_P)
        e2:SetOperation(function(te) te:SetLabel(te:GetHandler():IsDisabled() and 1 or 0) end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_LEAVE_FIELD)
        e3:SetLabelObject(e2)
        e3:SetOperation(s.mondesop)
        e3:SetLabelObject(e2)
        c:RegisterEffect(e3)
    end
end
function s.mondesop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then
        e:Reset()
        return
    end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
    e:Reset()
end
--Activation condition: only opponent controls monsters
function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
       and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end