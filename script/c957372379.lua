--Cyroglyphic Freeze
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,1,s.tgfilter)
	--Special Summon Limitation
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.sumlimit)
	c:RegisterEffect(e1)
	--Destroy
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
	--Extra Material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	c:RegisterEffect(e3)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	--act in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.handcon)
	c:RegisterEffect(e4)
end
function s.tgfilter(c)
	return c:IsType(TYPE_FUSION|TYPE_RITUAL|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK|TYPE_RUNE)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if not tc then return false end
	local tctype=tc:GetType()&(TYPE_FUSION|TYPE_RITUAL|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK|TYPE_RUNE)
	return not c:IsType(tctype) and c:GetType()&(TYPE_FUSION|TYPE_RITUAL|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK|TYPE_RUNE)~=0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
    local tc=c:GetFirstCardTarget()
    return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(), REASON_EFFECT)
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	return (not sg or sg:FilterCount(s.flagcheck,nil)<2)
		and rc~=c and (e:GetHandler()~=c or Duel.GetCurrentChain()~=1)
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfeb) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end
function s.handcfilter(c,tp)
	return c:IsOriginalType(TYPE_MONSTER) and c:IsSummonPlayer(1-tp)
end
function s.handcon(e)
    local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
    if res then
        return teg:IsExists(s.handcfilter,1,nil,e:GetHandlerPlayer())
    end
end