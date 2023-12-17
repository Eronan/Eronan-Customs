--Binate Dynachanter of Storm
local s,id=GetID()
function s.initial_effect(c)
    --pendulum summon
    Pendulum.AddProcedure(c)
    --spsummon
    local params = {nil,Fusion.OnFieldMat,s.fextra}
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
    e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    c:RegisterEffect(e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
    -- Set 1 "Tainted Treasure" Spell/Trap directly from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={0xfff, 0xfe5}
function s.exfilter(c)
    return c:IsAbleToGrave() and (c:IsSetCard(0xfe5) or c:IsSetCard(0xfff))
end
function s.fextra(e,tp,mg)
    if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==2 then
        return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_PZONE,0,nil)
    end
end
function s.spfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.setfilter(c)
	return (c:IsSetCard(0xfff) or c:IsSetCard(0xfe5)) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,986900019,0xfe5,TYPES_TOKEN,500,1850,3,RACE_FAIRY,ATTRIBUTE_FIRE) then
		local token=Duel.CreateToken(tp,986900019)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
