--Shroudis Spectrum
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.runtg)
	e1:SetOperation(s.runop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
    --Treat Link Spell as Link monster for Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfd1}
--Rune Summon a 'Shroudis' monster from deck
function s.runfilter(c,mg)
	return c:IsSetCard(0xfd1) and c:IsRuneSummonable(nil,mg,nil,nil,LOCATION_HAND)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
		local exg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_LINK)
		return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_DECK,0,1,nil,(mg+exg))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local matg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
    local exg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_LINK)
    local mg=(matg+exg)
	local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_DECK,0,nil,mg)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=g:Select(tp,1,1,nil):GetFirst()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT) then
        Duel.ConfirmCards(1-tp,tc)
		if tc:IsRuneSummonable(nil,mg) then
			Duel.RuneSummon(tp,tc,nil,mg)
		end
    end
end
--Treat Link Spell as Link monster for Link Summon
function s.lkfilter(c)
	return c:IsFaceup() and c:IsLinkSpell()
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.lkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lkfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.SelectTarget(tp,s.lkfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	--Treat as Link Monster for Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.extraval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetOperation(aux.TRUE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetCondition(s.addtypecon)
	e2:SetValue(TYPE_MONSTER|TYPE_LINK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			local c=e:GetHandler()
			c:RegisterFlagEffect(tp,id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==2 then
		e:GetHandler():ResetFlagEffect(id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
