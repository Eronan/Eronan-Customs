--Raijuteki Static
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--disable field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetProperty(EFFECT_FLAG_REPEAT)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0xffa}
function s.disop(e,tp)
	local c=e:GetHandler()
	local zone = c:GetColumnZone(LOCATION_ONFIELD)
	local cg=c:GetColumnGroup()
	for tc in aux.Next(cg) do
		local dz = tc:IsLocation(LOCATION_MZONE) and 1 or (1 << 8)
		if tc:IsSequence(5,6) then
			dz1 = tc:IsControler(tp) and (dz << tc:GetSequence()) or (dz << (16 + tc:GetSequence()))
			dz2 = tc:IsControler(tp) and (dz << (16 + (11 - tc:GetSequence()))) or (dz << (11 - tc:GetSequence()))
			dz = dz1|dz2
		else
			dz = tc:IsControler(tp) and (dz << tc:GetSequence()) or (dz << (16 + tc:GetSequence()))
		end
		zone = zone &~dz
	end
	return zone
end
--[[
function s.disop(e)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local nseq=4-seq
	if c:GetControler()==1 then seq,nseq=nseq,seq end
	local flag=0
	if Duel.CheckLocation(0,LOCATION_MZONE,seq) then flag=flag+(2^seq) end
	if Duel.CheckLocation(0,LOCATION_SZONE,seq) then flag=flag+((2^seq)<<8) end
	if Duel.CheckLocation(1,LOCATION_MZONE,nseq) then flag=flag+((2^nseq)<<16) end
	if Duel.CheckLocation(1,LOCATION_SZONE,nseq) then flag=flag+((2^nseq)<<24) end
	if seq==1 and Duel.CheckLocation(0,LOCATION_MZONE,5) then flag=flag+(2^5) end
	if seq==3 and Duel.CheckLocation(0,LOCATION_MZONE,6) then flag=flag+(2^6) end
	return flag
	return e:GetHandler():GetColumnZone(LOCATION_ONFIELD)
end
--]]
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter(c)
	return c:IsSetCard(0xffa) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
