--Ekhoir Harmonic Dragon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd
function s.initial_effect(c)
	--Add 1 "Ekhoir" monster from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--Use 1 "Ekhoir" Spell/Trap from Deck as Rune material
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_DECK)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_DECK,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
end
s.listed_series={SET_EKHOIR}
-------------------------------------------------
--Effect (1): Search
-------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_EKHOIR) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-------------------------------------------------
--Effect (2): Deck Spell/Trap Rune material
-------------------------------------------------
function s.eftg(e,c)
	return c:IsSetCard(SET_EKHOIR) and c:IsSpellTrap() and c:IsCanBeRuneMaterial()
end
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.excfilter(c)
	return c:IsCode(id) and not c:IsDisabled()
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then return true end
	if c==rc then return false end
	local ct=sg:FilterCount(s.flagcheck,nil)
	return Duel.GetFlagEffect(tp,id)==0 and sg:Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(s.excfilter,1,og) and ct<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(SET_EKHOIR) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			s.flagmap[c]=c:RegisterFlagEffect(id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 and Duel.GetFlagEffect(tp,id)==0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap[c] then
			s.flagmap[c]:Reset()
			s.flagmap[c]=nil
		end
	end
end