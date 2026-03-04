--Litos Caldera Serpent
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfbf),1,1,nil,s.exgroup,nil,nil,nil,nil,s.stage2)
	--(1) Reveal; activate Field Spell from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fldcost)
	e1:SetTarget(s.fldtg)
	e1:SetOperation(s.fldop)
	c:RegisterEffect(e1)

	--(2) Quick Rune after opponent activation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rncon)
	e2:SetTarget(s.rntg)
	e2:SetOperation(s.rnop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfbf}
s.listed_names={982018005} -- Litos Convergent Boundary
--------------------------------------------------
-- Rune Summon condition: Control "Convergent Boundary"
--------------------------------------------------
function s.excondition(c)
    return c:IsFaceup() and c:IsCode(982018005) -- Litos Convergent Boundary
end
function s.exfilter(c)
    return c:IsAbleToGrave() and c:IsSetCard(0xfbf)
end
function s.exgroup(tp,ex,c)
    if Duel.GetFlagEffect(tp,id) == 0 and Duel.IsExistingMatchingCard(s.excondition,tp,LOCATION_FZONE,0,1,nil) then
        return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,ex)
    else
        return Group.CreateGroup()
    end
end
function s.stage2(sg,e,tp,eg,ep,ev,re,r,rp,pc)
	if sg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
--------------------------------------------------
-- (1) Reveal → Activate Field Spell
--------------------------------------------------
function s.fldcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.fldfilter(c,tp)
	return c:IsSetCard(0xfbf) and c:IsFieldSpell()
end
function s.fldtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fldfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end

function s.fldop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not tc then return end

	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)

	-- Then bottom deck 1 card from hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end

--------------------------------------------------
-- (2) Quick Rune on Opponent Activation
--------------------------------------------------

function s.rncon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end

function s.rnfilter(c,e)
	return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
		and c:IsRuneSummonable(e:GetHandler())
end
function s.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rnfilter,tp,0x3ff-LOCATION_MZONE,0,1,nil,e) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff-LOCATION_MZONE)
end
function s.rnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.rnfilter,tp,0x3ff-LOCATION_MZONE,0,1,1,nil,e):GetFirst()
	if not tc then return end
    Duel.RuneSummon(tp,tc,c)
end