--Inphastice Sealing
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_INPHASTICE=0xfbd

function s.initial_effect(c)
    --------------------------------------------------
    -- (1) Counter Trap: When opponent would Normal or Special Summon a monster(s)
    -- while you control an "Inphastice" Rune monster:
    -- Negate the Summon and shuffle into Deck.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SUMMON)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON)
    c:RegisterEffect(e1b)

    
    --Extra Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon)
	e2:SetValue(s.extraval)
	e2:SetTarget(s.sendloc)
	c:RegisterEffect(e2)
end

s.listed_series={SET_INPHASTICE}

--------------------------------------------------
-- (1) Negate Summon
--------------------------------------------------
function s.runefilter(c)
    return c:IsSetCard(SET_INPHASTICE) and c:IsType(TYPE_RUNE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain(true)==0 and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(s.runefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,#eg,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
--------------------------------------------------
-- (2) Banish this card as rune material
--------------------------------------------------
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not sg or sg:FilterCount(s.flagcheck,nil)<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(SET_INPHASTICE) then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end
function s.sendloc(c,e,tp,sg,ug,rc,chk)
	return LOCATION_REMOVED
end
