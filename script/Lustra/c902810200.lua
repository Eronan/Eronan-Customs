--Lustra, the Radiant Naga
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsSummonableCard)),1,1,Rune.STFunction(Card.IsOnField),1,1,LOCATION_DECK,nil,nil,s.runchk)
    c:EnableReviveLimit()
    local sme,soe=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--Mandatory return
	sme:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	sme:SetTarget(s.mrettg)
	sme:SetOperation(s.retop)
    --Optional return
	soe:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	soe:SetTarget(s.orettg)
	soe:SetOperation(s.retop)
    --cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
    --remove from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    --temporary banish
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.trmtg)
	e4:SetOperation(s.trmop)
	c:RegisterEffect(e4)
end
--Spirit Return
function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.orettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,0) and s.tkcheck(e,tp) end
	Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.filter(c)
    return c:IsAbleToRemove() and c:IsSpellTrap()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_HAND) then
        local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
		if #g>0 then
            local tc=g:Select(tp,1,1,nil)
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
	end
end
--Lake of the Radiant One
function s.runchk(e,tp,chk,mg)
	if chk==0 then return Duel.IsPlayerAffectedByEffect(tp,902810203) and Duel.GetFlagEffect(tp,902810203)==0 end
	Duel.RegisterFlagEffect(tp,902810203,RESET_PHASE+PHASE_END,0,1)
	return true
end
--Banish Spell/Trap card
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.disfilter(c,tp)
    return c:IsDiscardable(REASON_EFFECT) and c:IsSpellTrap() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil,c:GetType())
end
function s.rmfilter(c,typ)
    return c:IsAbleToRemove() and c:GetType()==typ and c:ListsCode(id)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_HAND,0,nil,tp)
	if #hg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local tc=hg:Select(tp,1,1,nil):GetFirst()
    if Duel.SendtoGrave(tc,REASON_EFFECT|REASON_DISCARD)==0 then return end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil,tc:GetType())
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rmc=g:Select(tp,1,1,nil)
		Duel.Remove(rmc,POS_FACEUP,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
--temporary banish
function s.trmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.trmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		and Duel.IsExistingTarget(s.trmfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.trmfilter,tp,0,LOCATION_MZONE,1,1,nil)
    g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.trmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g
	if c:IsRelateToEffect(e) then
		g=Group.FromCards(c):Merge(tg)
	else
		g=tg
	end
    if #g>0 and Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        for tc in aux.Next(g) do
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(g)
		e1:SetCountLimit(1)
		e1:SetCondition(s.rmretcon)
		e1:SetOperation(s.rmretop)
		Duel.RegisterEffect(e1,tp)
		g:KeepAlive()
    end
end
function s.rmretcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local res=g:IsExists(function (c) return c:GetFlagEffect(id)~=0 end,1,nil)
	if res then return true end
    g:DeleteGroup()
	return false
end
function s.rmretop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	for tc in aux.Next(g) do
		Duel.ReturnToField(tc)
	end
	g:DeleteGroup()
end
