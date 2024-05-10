--Shroudis Telepath
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
	c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xfd1),1)
	--special summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
    e1:SetCondition(function(e) return e:GetLabel()==1 and e:GetHandler():IsExtraLinked() end)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
    --Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfd1}
--Special Summon limit
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_RUNE,c,SUMMON_TYPE_LINK,e:GetHandlerPlayer()) then
		e:GetLabelObject():SetLabel(1)
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
    if not c:IsLocation(LOCATION_EXTRA) then return false end
	if c:IsMonster() then
		return not c:IsType(TYPE_LINK)
	else
		return not c:IsOriginalType(TYPE_LINK)
	end
end
--Add to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD|LOCATION_EXTRA)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0xfd1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end