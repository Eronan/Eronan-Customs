--Caraphron Sigmoth
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon procedure
    c:EnableReviveLimit()
    -- Assuming you have Rune.AddProcedure defined in your scripts
    -- 1 Insect monster + 1 Equip Spell card
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRace,RACE_INSECT),1,1,Rune.STFunction(Card.IsEquipSpell),1,1)
    --(1) ATK of opponent's monsters equipped with Caraphron cards becomes 0
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(0)
    e1:SetTarget(s.atktg)
    c:RegisterEffect(e1)

	--If a Link Monster you control would be used as Link Material for a "Caraphron" monster, this card in your hand can also be used as material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetRange(LOCATION_HAND)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)
	if s.flagmap1==nil then
		s.flagmap1={}
	end
	if s.flagmap1[c]==nil then
		s.flagmap1[c] = {}
	end
    --(3) When sent to GY: equip 1 Caraphron Equip Spell from GY to an appropriate monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc0}
--==========================
--Effect 1: ATK 0
--==========================
function s.atktg(e,c)
    return c:IsFaceup() and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0xfc0)
end

--==========================
--Effect 2: Can be used from hand
--==========================
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return sg:FilterCount(Card.HasFlagEffect,nil,id)<2
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(0xfc0) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap1[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,0,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap1[c]) do
			eff:Reset()
		end
		s.flagmap1[c]={}
	end
end

--==========================
--Effect 3: Equip from GY
--==========================
function s.gyfilter(c)
	return c:IsSetCard(0xfc0) and c:IsSSetable()
end
function s.eqfilter(c,ec)
    return ec:CheckEquipTarget(c)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tg=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=tg:GetFirst()
    if tc:IsEquipSpell() then Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,g,1,0,0) end
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	if tc:IsEquipSpell() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        --Equip to an appropriate monster instead
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
		Duel.Equip(tp,tc,ec:GetFirst())
	else
        -- Set to the field
		Duel.SSet(tp,tc)
	end
end