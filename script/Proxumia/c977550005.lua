-- Proxumia Riftmind - Ethamyre
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Extra Material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetCondition(s.extracon)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)
    if s.flagmap==nil then
        s.flagmap={}
    end
    if s.flagmap[c]==nil then
        s.flagmap[c] = {}
    end
    -- Link Summon or Special Summon Token
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
    e2:SetTarget(s.regtg)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.matcon)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetRange(LOCATION_MZONE+LOCATION_HAND)
    e4:SetCondition(s.spcon)
    c:RegisterEffect(e4)
end
s.listed_series={0xfc3}
s.TOKEN_PROXUMIA=977550009
s.FLAG_EXTRA = id
s.FLAG_LINK = id+1
s.FLAG_TOKEN = s.TOKEN_PROXUMIA
--Extra Link Material
function s.extrafilter(c,tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not sg or sg:FilterCount(s.flagcheck,nil)<2
end
function s.flagcheck(c)
    return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
    local c=e:GetHandler()
    if chk==0 then
        local tp,sc=...
        if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(0xfc3) or Duel.GetFlagEffect(tp,s.FLAG_EXTRA)>0 then
            return Group.CreateGroup()
        else
            table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
            return Group.FromCards(c)
        end
    elseif chk==1 then
        local sg,sc,tp=...
        if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
            Duel.Hint(HINT_CARD,tp,id)
            Duel.RegisterFlagEffect(tp,s.FLAG_EXTRA,RESET_PHASE+PHASE_END,0,1)
        end
    elseif chk==2 then
        for _,eff in ipairs(s.flagmap[c]) do
            eff:Reset()
        end
        s.flagmap[c]={}
    end
end
-- Link Summon or Special Summon Token
---- Condition: Used as material for Link Summon of "Proxumia" monster
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfc3)
end
---- Condition: Opponent Special Summon from Extra
function s.cfilter(c,tp)
    return c:IsControler(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
-- Choose Effect
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local can_link = s.linksptg(e,tp,eg,ep,ev,re,r,rp,0)
    local can_token = s.tktg(e,tp,eg,ep,ev,re,r,rp,0)
    if chk==0 then return can_link or can_token end
    if can_link and can_token then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
        local opt = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if opt == 0 then
            s.linksptg(e,tp,eg,ep,ev,re,r,rp,1)
            e:SetLabel(0)
        else
            s.tktg(e,tp,eg,ep,ev,re,r,rp,1)
            e:SetLabel(1)
        end
    elseif can_link then
        s.linksptg(e,tp,eg,ep,ev,re,r,rp,1)
        e:SetLabel(0)
    else
        s.tktg(e,tp,eg,ep,ev,re,r,rp,1)
        e:SetLabel(1)
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        s.linkspop(e,tp,eg,ep,ev,re,r,rp)
    else
        s.tkop(e,tp,eg,ep,ev,re,r,rp)
    end
end
-- Link Summon
function s.linkfilter(c)
	return c:IsSetCard(0xfc3) and c:IsLinkSummonable()
end
function s.linksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,s.FLAG_LINK)==0 and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.RegisterFlagEffect(tp,s.FLAG_LINK,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
	end
end
-- Special Summon Token
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFlagEffect(tp,s.FLAG_TOKEN)==0
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,s.TOKEN_PROXUMIA,0xfc3,TYPES_TOKEN,0,0,1,RACE_ILLUSION,ATTRIBUTE_WIND)
    end
    Duel.RegisterFlagEffect(tp,s.FLAG_TOKEN,RESET_PHASE+PHASE_END,0,1)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,s.TOKEN_PROXUMIA,0xfc3,TYPES_TOKEN,0,0,1,RACE_ILLUSION,ATTRIBUTE_WIND) then return end
    local token=Duel.CreateToken(tp,s.TOKEN_PROXUMIA)
    if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        token:RegisterEffect(e1,true)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        token:RegisterEffect(e2,true)
    end
    Duel.SpecialSummonComplete()
end