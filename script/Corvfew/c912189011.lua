--Heartholdritch Corvfew Mastermind
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()

local SET_CORVFEW=0xfbb
local CARD_TRESYLLT=912189010
local CARD_CORVFEW_PIECES=912189012

function s.initial_effect(c)
	-- Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsLevelBelow,6),1,1,Rune.STFunctionEx(Card.IsRuneCode,CARD_CORVFEW_PIECES),1,1)
	Rune.AddSecondProcedure(c,Rune.MonFunction(s.tyrfilter),1,1,Rune.STFunctionEx(Card.IsRuneCode,CARD_CORVFEW_PIECES),1,1,LOCATION_GRAVE)

	-- Place "Hearthold Corvfew Pieces" during the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function (e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)

	-- Replace opponent's activated effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_CORVFEW}
s.listed_names={CARD_TRESYLLT}

function s.tyrfilter(c)
	return c:IsCode(CARD_TRESYLLT)
end

--------------------------------------------------
-- (1) Place "Hearthold Corvfew Pieces"
--------------------------------------------------

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.tfcon)
	e1:SetOperation(s.tfop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.tffilter(c,tp)
	return c:IsCode(CARD_CORVFEW_PIECES) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and not c:IsType(TYPE_FIELD)
end

function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end

function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

--------------------------------------------------
-- (2) Replace opponent's activated effect
--------------------------------------------------
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return not tg or not tg:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_ONFIELD)
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local ct=0
	if tg then ct=#tg end
	if chk==0 then
		if ct==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		elseif ct>0 then return true
		else return false end
	 end

	-- The original effect is replaced by our custom operation.
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,0,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tg,0,0,0)
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Get the targets of the activated effect.
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local ct=0
	if tg then ct=#tg end

	if ct==0 then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.rmop)
	elseif ct>0 then
		Duel.ChangeChainOperation(ev,s.desregop)
	end

end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	aux.RemoveUntil(g,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,nil,RESET_PHASE|PHASE_END,1)
end

function s.desregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg then return end
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		-- Register the original operation to resolve during the End Phase.
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetDescription(aux.Stringid(id,3))
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetCountLimit(1)
		de:SetCondition(s.descon)
		de:SetOperation(function ()
			local rg=g:Filter(Card.GetFlagEffect,nil,id)
			Duel.Hint(HINT_CARD,0,id)
			Duel.Destroy(rg,REASON_EFFECT)
		end)
		de:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(de,tp)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.GetFlagEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,id)
end