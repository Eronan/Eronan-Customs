-- Skaldia Sigil
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (hand activation condition)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Activate from hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e2:SetCondition(s.actcon)
    c:RegisterEffect(e2)
    --Extra Material
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	e3:SetTarget(s.sendloc)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc2}
-- Activation condition: You can activate this card from your hand during opponent's turn if you control no cards
function s.actcon(e)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

-- (1) Target 1 monster your opponent controls
function s.runfilter(c,mg)
    return c:IsSetCard(0xfc2) and Card.IsRuneSummonable(c,mg,mg,2,2)
end
function s.mtfilter(c,e,tp)
    local mg=Group.FromCards(c,e:GetHandler())
    return c:IsFaceup() and Duel.IsExistingMatchingCard(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,1,nil,mg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.mtfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.mtfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
    local g=Duel.SelectTarget(tp,s.mtfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end

-- (1) Operation: Rune Summon 1 "Skaldia" monster using this card + target monster as materials
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsFacedown() then return end

    -- Check if you can Rune Summon a Skaldia monster using only these two cards
    local mg=Group.FromCards(c,tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    
    -- Get the possible Skaldia monsters you can Rune Summon
    local rg=Duel.GetMatchingGroup(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,nil,mg)
    if #rg==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=rg:Select(tp,1,1,nil):GetFirst()

    c:CancelToGrave()
    
    -- Rune Summon procedure, usually proc_rune.lua provides RuneSummon function
    Duel.RuneSummon(tp,rc,mg,mg,2,2)
end
-- Extra Material Effect
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
		if summon_type~=SUMMON_TYPE_RUNE or  not sc:IsSetCard(0xfc2) then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end
function s.sendloc(c,e,tp,sg,ug,rc,chk)
	return LOCATION_REMOVED
end
