--Mithosigil, Bringer of Storm
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
	--Send 1 card from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
    --Banish 1 face card the opponent controls, face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCondition(s.rmcon1)
	c:RegisterEffect(e3)
    --Extra Material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_HAND)
	e4:SetCode(EFFECT_EXTRA_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetOperation(s.extracon)
	e4:SetValue(s.extraval)
	c:RegisterEffect(e4)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	
end
s.listed_series={0xfc4}
--Send 1 card from the Deck to the GY
function s.tgfilter(c)
	return c:IsSetCard(0xfc4) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--Banish card
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsTributeSummoned()
end
function s.rmvfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmvfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmvfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
--Extra Material
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	return (not sg or sg:FilterCount(s.flagcheck,nil)<2)
		and rc~=c
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfc4) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
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