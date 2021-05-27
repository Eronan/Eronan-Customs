--Botnet Stealth Avatar
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),2,2,aux.FilterBoolFunction(Card.IsSetCard,0xfe7),2,2)
	--attack all
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82012319,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfe7}
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x24) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,1-tp)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp)
	local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,999999996,0,0x2fe7,1000,1500,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	local token=Duel.CreateToken(tp,999999996)
	if op==0 then Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	else Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP) end
end
