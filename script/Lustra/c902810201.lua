--Radiance of Lustra
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
   --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Limit activations
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
    --Special Summon 1 monster from your Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    --Place this card in your Spell & Trap Zones
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
--Cannot activate in response
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if rc:ListsCode(902810200) and rc:IsOnField() and rc:IsControler(tp) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
--Special Summon a monster from the Extra Deck
function s.spcfilter(c)
    if not c:IsLocation(LOCATION_GRAVE) then return false end
    local rc=c:GetReasonCard()
	return rc:IsSummonType(SUMMON_TYPE_RUNE) and rc:IsCode(902810200)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spcfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spfilter(c,e,tp,lg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and lg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,lg)
    local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,lg)
	if #spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=spg:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.ShuffleExtra(1-tp)
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
