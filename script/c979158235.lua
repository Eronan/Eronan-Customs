--Charjed Vanagandr
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Atk and Def Change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetLabelObject(e2)
	e3:SetCondition(s.atdfcon)
	e3:SetValue(3500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e4)
	--Attack All
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_ALL)
	e5:SetCondition(s.atkcon)
	e5:SetLabelObject(e2)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tpe=0
	local rce=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsType(TYPE_TUNER) then
			tpe=bit.bor(tpe,tc:GetType())
			rce=bit.bor(rce,tc:GetRace())
		end
		tc=g:GetNext()
	end
	e:SetLabel(tpe)
	e:GetLabelObject():SetLabel(rce)
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabel(),RACE_THUNDER)~=0
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
function s.atdfcon(e)
	return bit.band(e:GetLabelObject():GetLabel(),TYPE_NORMAL)~=0
end
function s.atkcon(e)
	return bit.band(e:GetLabelObject():GetLabel(),TYPE_EFFECT)~=0
end
