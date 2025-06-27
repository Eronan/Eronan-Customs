--Celsitial Hydra of Domination
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_RUNE),2,99,Rune.STFunction(nil),1,1)
    c:EnableReviveLimit()
    --immune effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
    --Control or Special Summon
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCode(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    --Rune Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={918100320}
--immune effect
function s.efilter(e,re,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--material check
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,918100320) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
--Control or Special Summon
function s.tgfilter(c,e,tp,lc)
	return c:IsType(TYPE_RUNE)
		and (c:IsAbleToChangeControler() or (lc>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsOnField()) and chkc:IsControler(1-tp) and s.tgfilter(chkc,e,tp,lc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,e,tp,lc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil,e,tp,lc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
    local tc=g:GetFirst()
    if tc:IsOnField() then
        Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,g,1,1-tp,LOCATION_GRAVE)
    else
        Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,1-tp,LOCATION_GRAVE)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local b1=tc:IsAbleToChangeControler()
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if not op then return end
	if op==1 then
		Duel.GetControl(tc,tp,PHASE_END,1)
	elseif op==2 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
    if tc and tc:IsOnField() then
        --Destroy it during your opponent's next End Phase
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetCountLimit(1)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.descon)
        e1:SetOperation(s.desop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,4))
        Duel.RegisterEffect(e1,tp)
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and e:GetLabelObject():GetFlagEffect(id)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	Duel.Destroy(sc,REASON_EFFECT)
end
--Rune Summon
function s.thfilter(c)
	return c:IsCode(918100320) and c:IsType(TYPE_RUNE) and c:IsAbleToHand()
		and c:IsRuneSummonable(nil,nil,nil,nil,LOCATION_HAND)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsRuneSummonable(nil,nil,2,99) then
			Duel.RuneSummon(tp,tc)
		end
	end
end