--The Great Coiling
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(function (_) return Duel.IsMainPhase() end)
    e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
    --immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.immtg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
    --Place this card in your Spell & Trap Zones
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCondition(s.tfcon)
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)
end
s.listed_names={902810200}
--Rune Summon
function s.runfilter(c,mg)
	return c:IsCode(902810200) and c:IsRuneSummonable(nil,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,0x3ff~LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local exg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #exg>0 then Duel.ConfirmCards(tp,exg) end
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil):Merge(exg)
	Duel.Hint(HINT_SELECTMSG,tp,1175)
	local g=Duel.GetMatchingGroup(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,nil,mg)
	if #g>0 then
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,nil,mg)
		end
	end
end
--immune
function s.efilter(e,re,rp)
	return re:GetHandlerPlayer()~=e:GetHandlerPlayer()
		and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
function s.immtg(e,c)
	return c:IsCode(902810200) or c:ListsCode(902810200)
end
--Place in Spell & Trap Zone
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():CheckUniqueOnField(tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
