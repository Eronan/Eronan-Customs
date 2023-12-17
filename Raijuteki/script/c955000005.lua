--Raijuteki Binate Bolt
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Gemini
	Gemini.AddProcedure(c)
	--pendulum summon
    Pendulum.AddProcedure(c,false)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(1160)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.reg)
    c:RegisterEffect(e1)
	--destroy and set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)--DUEL is normal due to glitch with card numbers >900000000
	e2:SetCondition(s.thcon)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--place
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
s.listed_series={0xffa,0xfff}
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_RUNE)
    local tc=g:GetFirst()
    if tc then
        Duel.ShuffleDeck(tp)
        Duel.MoveSequence(tc,0)
        Duel.ConfirmDecktop(tp,1)
		Duel.BreakEffect()
		--Draw
		if Duel.IsPlayerCanDraw(tp,1) and (tc:IsSetCard(0xffa) or tc:IsSetCard(0xfff)) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
    end
end
function s.tffilter(c,tp)
	return c:IsContinuousTrap()
		and (c:IsSetCard(0xffa) or c:IsSetCard(0xfff)) and not c:IsForbidden()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end