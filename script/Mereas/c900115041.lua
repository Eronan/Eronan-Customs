--Medusozoa Mereas - Saqa of Aglaope
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()

local SET_MEREAS=0xff5
local CARD_MEDUSA_MEREAS=900115040
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.monmatfilter),1,1,Rune.STFunction(nil),2,99,nil,s.exgroup,nil,nil,nil,s.customop)

	--Must be Rune Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.runlimit)
	c:RegisterEffect(e0)

	--(1) Destruction replacement
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	c:RegisterEffect(e1)

	--(2) Rune Summoned / leaves field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.leavecon)
	c:RegisterEffect(e3)

	--(3) Mereas sent to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)

end
s.listed_series={SET_MEREAS}
s.listed_names={CARD_MEDUSA_MEREAS}

---------------------------------------------------
-- Rune Summon
---------------------------------------------------
function s.monmatfilter(c,rc,sumtyp,tp)
    return c:IsRace(RACE_FISH,rc,sumtyp,tp) and c:IsType(TYPE_RUNE,rc,sumtyp,tp)
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end

---------------------------------------------------
-- (1) Destruction Replacement
---------------------------------------------------

function s.repfilter(c,tp)
	return c:IsControler(tp)
		and c:IsOnField()
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end

function s.xyzmatfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:GetOverlayCount()>0
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.xyzmatfilter,tp,LOCATION_MZONE,0,1,nil)
	end

	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
		local g=Duel.SelectMatchingCard(tp,s.xyzmatfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local xc=g:GetFirst()
		if xc then
			xc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
			return true
		end
	end

	return false
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

---------------------------------------------------
-- (2) Summon Mereas Xyz
---------------------------------------------------

function s.medusafilter(c)
	return c:IsCode(CARD_MEDUSA_MEREAS)
end

function s.xyzfilter(c,e,tp)
	return c:IsSetCard(SET_MEREAS)
		and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.medusafilter,tp,LOCATION_GRAVE,0,1,nil) 
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end

    local mg=Duel.SelectTarget(tp,s.medusafilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	if not sc then return end

	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Overlay(sc,Group.FromCards(tc))

        -- Destroy at end of turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(sc)
        e1:SetLabel(sc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END,2)
        e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	if not sc or not sc:IsFaceup() then return end

	Duel.Destroy(sc,REASON_EFFECT)
end

function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

---------------------------------------------------
-- (3) Flip face-down
---------------------------------------------------

function s.posfilter(c)
	return c:IsSetCard(SET_MEREAS)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.posfilter,1,nil)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if not Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE) then return end

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end