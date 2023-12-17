--[[
--Strings
1175 = Rune Summon
--]]
--[[
--Copy the below for a Rune Monster
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
end
--]]
--Constants
TYPE_RUNE			= 0x80000000
MATERIAL_RUNE		= 0x20<<32
REASON_RUNE			= 0x80000000
SUMMON_TYPE_RUNE	= 0x42000001
EFFECT_RUNE_MAT_RESTRICTION		=73941492+TYPE_RUNE
EFFECT_CANNOT_BE_RUNE_MATERIAL	=500
EFFECT_RUNE_SUBSTITUTE	= 900001031

if not aux.RuneProcedure then
	aux.RuneProcedure = {}
	Rune = aux.RuneProcedure
end
if not Rune then
	Rune = aux.RuneProcedure
end
--Procedure Functions
function Rune.AddProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
	--monf is the monster Filter, stf is the S/T Filter
	--mmin, mmax are the minimums and maximums for the monsters
	--smin, smax are the minimums and maximums for the Spell/Trap cards
	--loc adds an additional location
	--group changes the 
	if not mmax then mmax=mmin end
	if not smax then smax=smin end
	if not loc then loc=0 end
	if c.rune_parameters==nil then
		local mt=c:GetMetatable()
		--mt.rune_monster_filter=function(c) end
		mt.rune_parameters={}
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc+LOCATION_HAND,group,condition,excondition,specialchk,customoperation,stage2})
	end
	
	local e1=Rune.CreateProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,specialchk,customoperation,stage2)
	c:RegisterEffect(e1)
	
	if loc then
		local e2=Rune.CreateSecondProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
		c:RegisterEffect(e2)
	end
end
function Rune.AddSecondProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
	--monf is the monster Filter, stf is the S/T Filter
	--mmin, mmax are the minimums and maximums for the monsters
	--smin, smax are the minimums and maximums for the Spell/Trap cards
	--loc adds an additional location
	--group changes the 
	if not mmax then mmax=mmin end
	if not smax then smax=smin end
	if c.rune_parameters==nil then
		local mt=c:GetMetatable()
		--mt.rune_monster_filter=function(c) end
		mt.rune_parameters={}
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2})
	else
		local mt=c:GetMetatable()
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2})
	end
	local e1=Rune.CreateSecondProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
	c:RegisterEffect(e1)
end
function Rune.CreateProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,specialchk,customoperation,stage2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1175)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition,nil,specialchk))
	e1:SetTarget(Rune.Target(monf,mmin,mmax,stf,smin,smax,group,nil,specialchk))
	e1:SetOperation(Rune.Operation(monf,mmin,mmax,stf,smin,smax,group,customoperation,stage2))
	e1:SetValue(SUMMON_TYPE_RUNE)
	return e1
end
function Rune.CreateSecondProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition,excondition,specialchk,customoperation,stage2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1175)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(loc)
	e1:SetCondition(Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition,excondition,specialchk))
	e1:SetTarget(Rune.Target(monf,mmin,mmax,stf,smin,smax,group,excondition,specialchk))
	e1:SetOperation(Rune.Operation(monf,mmin,mmax,stf,smin,smax,group,customoperation,stage2))
	e1:SetValue(SUMMON_TYPE_RUNE)
	return e1
end
--
function Rune.MonFunction(f)
	return	function(target,scard,sumtype,tp)
				return target:IsMonster() and (not f or f(target,scard,sumtype,tp)) and Rune.IsCanBeMaterial(target,scard,tp)
			end
end
function Rune.MonFunctionEx(f,val)
	return	function(target,scard,sumtype,tp)
				return target:IsMonster() and f(target,val,scard,sumtype,tp) and Rune.IsCanBeMaterial(target,scard,tp)
			end
end
function Rune.STFunction(f)
	return	function(target,scard,sumtype,tp)
				return target:IsSpellTrap() and (not f or f(target,scard,sumtype,tp)) and Rune.IsCanBeMaterial(target,scard,tp)
			end
end
function Rune.STFunctionEx(f,val)
	return	function(target,scard,sumtype,tp)
				if not target:IsSpellTrap() or not Rune.IsCanBeMaterial(target,scard,tp) then return false end
				--Pendulum Spell card workaround
				if f==Card.IsType and val==TYPE_PENDULUM then return target:IsSpellTrap() and f(target,val)
				else return f(target,val,scard,sumtype,tp) end
			end
end
--Check if Usable as Material at all
function Rune.ConditionFilter(c,monf,stf,rc,tp)	
	return monf(c,rc,SUMMON_TYPE_RUNE,tp) or stf(c,rc,SUMMON_TYPE_RUNE,tp)
end
function Rune.IsCanBeMaterial(c,runc,tp)
	if c==runc then return false end
	
	--Search Effects
	local effs={c:GetCardEffect(EFFECT_CANNOT_BE_RUNE_MATERIAL)}
	for _,te in ipairs(effs) do
		if type(te:GetValue())=='function' and te:GetValue()(te,runc,tp) or te:GetValue() then return false end
	end
	
	--Cannot be Material
	effs={c:GetCardEffect(EFFECT_CANNOT_BE_MATERIAL)}
	for _,te in ipairs(effs) do
		if type(te:GetValue())=='function' and te:GetValue()(te,runc,SUMMON_TYPE_RUNE,tp) or te:GetValue() then return false end
	end
	
	return true
end
--[[Parameters Details for Recursives
g = All Usable Materials
sg = Selected Group (All Materials)
mct = COunt of cards that are monsters
sct = Count of cards that are Spells/Traps
bct = Count of cards that can be used for both
monf & stf = Monster Filter and S/T Filter respectively
mmin & mmax = Minimum and Maximum for Monsters
smin & smax = Minmum and Maximum for Spells/Traps
tmin & tmax = The min/max material requirements from an Effect
og = All Usable Materials without Extra Materials
emt = Extra Material Table
]]
function Rune.CheckRecursive(c,mg,sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	--Check Filters
	local mon=monf(c,rc,SUMMON_TYPE_RUNE,tp)
	local st=stf(c,rc,SUMMON_TYPE_RUNE,tp)

	--Count Maximums
	if #sg>=tmax then return false end --If the total count exceeds maximum
	if not st and mct>=mmax then return false end --If cannot be used as S/T Material and Monster Max is full
	if not mon and sct>=smax then return false end --If cannot be used as Monster Material and S/T Max is full
	
	--Check for Material Restrictions
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_RUNE_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_RUNE_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			--Check if Unusable Material Exists
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
			--Remove unusable cards
			local mg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(mg2)
			mg:Sub(mg2)
		end
	end
	--Materials with Restriction Effect
	local rmg=sg:Filter(Card.IsHasEffect,nil,EFFECT_RUNE_MAT_RESTRICTION)
	if #rmg>0 then
		local tc=rmg:GetFirst()
		while tc do
			local eff={tc:GetCardEffect(EFFECT_RUNE_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=rmg:GetNext()
		end
	end
	
	--Start Filter Checking
	sg:AddCard(c)
	
	--Check for Valid Extra Materials
	filt=filt or {}
	local oldfilt={table.unpack(filt)}
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3]) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		local res=aux.CheckValidExtra(c,tp,sg,mg,rc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	
	--Check Recursive and Increment Count based on Type
	local res=false
	if mon and st then
		res=(Rune.CheckGoal(mct,sct,bct+1,mmin,smin,tmin,tmax) and (not runechk or runechk(sg,rc,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp))) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	elseif mon then
		res=(Rune.CheckGoal(mct+1,sct,bct,mmin,smin,tmin,tmax) and (not runechk or runechk(sg,rc,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp))) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	elseif st then
		res=(Rune.CheckGoal(mct,sct+1,bct,mmin,smin,tmin,tmax) and (not runechk or runechk(sg,rc,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp))) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	end
	
	if rc:IsLocation(LOCATION_EXTRA) then
		res=res and Duel.GetLocationCountFromEx(tp,tp,sg,rc)>0
	else
		res = res and Duel.GetMZoneCount(tp,sg,tp)>0
	end
	
	--Reset all Values (Groups, Filters, etc)
	sg:RemoveCard(c)
	mg:Merge(rg)
	filt={table.unpack(oldfilt)}
	return res
end
--csg represents the cards already chosen in the Target Function: Current SG
--Function Sets up Filters
function Rune.CheckRecursive2(c,mg,sg,csg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	--Check Filters
	local mon=monf(c,rc,SUMMON_TYPE_RUNE,tp)
	local st=stf(c,rc,SUMMON_TYPE_RUNE,tp)
	
	--Count Maximums
	if #sg>=tmax then return Rune.CheckGoal(mct,sct,bct,mmin,smin,tmin,tmax) and (not runechk or runechk(sg,rc,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp)) end --If the total count exceeds maximum
	if not st and mct>=mmax then return false end --If cannot be used as S/T Material and Monster Max is full
	if not mon and sct>=smax then return false end --If cannot be used as Monster Material and S/T Max is full
	
	--Check for Material Restrictions
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_RUNE_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_RUNE_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			--Check if Unusable Material Exists
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
			--Remove unusable cards
			local mg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(mg2)
			mg:Sub(mg2)
		end
	end
	--Materials with Restriction Effect
	local rmg=mg:Filter(Card.IsHasEffect,nil,EFFECT_RUNE_MAT_RESTRICTION)
	if #rmg>0 then
		local tc=rmg:GetFirst()
		while tc do
			local eff={tc:GetCardEffect(EFFECT_RUNE_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=rmg:GetNext()
		end
	end
	
	--Start Filter Checking
	sg:AddCard(c)
	
	--Check for Valid Extra Materials
	filt=filt or {}
	local oldfilt={table.unpack(filt)}
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3],tp,sg,mg,rc,filt[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		local res=aux.CheckValidExtra(c,tp,sg,mg,rc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	
	local res=false
	if #(csg-sg)==0 then
		if mg and #mg>0 then
			if mon and st then
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
			elseif mon then
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
			elseif st then
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
			end
			sg:RemoveCard(c)
			return res
		else
			local res=Rune.CheckGoal(mct,sct,bct,mmin,smin,tmin,tmax)
			sg:RemoveCard(c)
			return res
		end
	end
	
	--Self-Recursion
	if mon and st then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	elseif mon then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	elseif st then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt,runechk)
	end
	
	--Reset all Values (Groups, Filters, etc)
	sg:RemoveCard(c)
	return res
end
function Rune.CheckGoal(mnct,stct,bothct,mmin,smin,tmin,tmax)
	return (mnct+stct+bothct)>=tmin and mnct+bothct>=mmin
		and stct+bothct>=smin
		and mnct+stct+bothct<=tmax
end
function Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition,excondition,specialchk)
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if condition and not condition(e,c) then return false end
				if excondition and not excondition(e,e:GetHandlerPlayer(),0) then return false end
				local tp=c:GetControler()
				--get usable group
				local g
				if not og then g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
				else g=og:Clone() end
				--no extra materials if effect is negated
				if group and not c:IsDisabled() then
					g:Merge(group(tp,nil,c))
				end
				--Get Material Check function
				local matchk=specialchk
				if specialchk and c.rune_custom_check then
					matchk=aux.AND(c.rune_custom_check,specialchk)
				elseif c.rune_custom_check then
					matchk=c.rune_custom_check
				end
				--There is a bug in the IsProcedureSummonable Condition where nil becomes 0 for max if min has been set
				--if max==0 and min>0 then max=nil end
				--Determine if Minimum and Maximum is Possible
				if min and min > mmax+smax then return false end
				if max and max < mmin+smin then return false end
				--Get Higher or Lower Value
				if not min or min < mmin+smin then min=mmin+smin end
				if not max or max > mmax+smax then max=mmax+smax end
				--]]
				local mg=g:Filter(Rune.ConditionFilter,nil,monf,stf,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_RUNE)
				if must then mustg:Merge(must) end
				if #mustg>max or mustg:IsExists(aux.NOT(Rune.ConditionFilter),1,nil,monf,stf,c,tp) then return false end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_RUNE)
				--Remove cards that go to the Graveyard at the end of the Chain
				local res=(mg+tg):Includes(mustg) and #mustg<=max
				if res then
					if #mustg==max then
						local sg=Group.CreateGroup()
						res=mustg:IsExists(Rune.CheckRecursive,1,sg,mg+tg,sg,0,0,0,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,nil,matchk)
					elseif #mustg<max then
						local sg=mustg
						local mct=sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_SPELL+TYPE_TRAP)
						local sct=sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_MONSTER)
						if mct>mmax or sct>smax then return false end
						res=(mg+tg):IsExists(Rune.CheckRecursive,1,sg,mg+tg,sg,mct,sct,#sg-mct-sct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,nil,matchk)
					end
				end
				aux.DeleteExtraMaterialGroups(emt)
				return res
			end
end
function Rune.Target(monf,mmin,mmax,stf,smin,smax,group,excondition,specialchk)
	return 	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				--get usable group
				local g
				if not og then g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
				else g=og:Clone() end
				--no extra materials if effect is negated
				if group and not c:IsDisabled() then
					g:Merge(group(tp,nil,c))
				end
				--Get Material Check function
				local matchk=specialchk
				if specialchk and c.rune_custom_check then
					matchk=aux.AND(c.rune_custom_check,specialchk)
				elseif c.rune_custom_check then
					matchk=c.rune_custom_check
				end
				--There is a bug in the IsProcedureSummonable Condition where nil becomes 0 for max if min has been set
				--if max==0 and min>0 then max=nil end
				--Minimums and Maximums
				if min and min > mmax+smax then return false end
				if max and max < mmin+smin then return false end
				--Get Higher or Lower Value
				if not min or min < mmin+smin then min=mmin+smin end
				if not max or max > mmax+smax then max=mmax+smax end
				--Variable Set Up
				local mg=g:Filter(Rune.ConditionFilter,nil,monf,stf,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_RUNE)
				if must then mustg:Merge(must) end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_RUNE)
				--Rune Summon
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<max do
					local sct=sg:FilterCount(aux.NOT(monf),nil,c,SUMMON_TYPE_RUNE,tp)
					local mct=sg:FilterCount(aux.NOT(stf),nil,c,SUMMON_TYPE_RUNE,tp)
					local bct=#sg-mct-sct
					--Filters
					local filters={}
					if #sg>0 then
						Rune.CheckRecursive2(sg:GetFirst(),mg+tg,Group.CreateGroup(),sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters,matchk)
					end
					
					--Get Selectable Cards
					local cg=(mg+tg):Filter(Rune.CheckRecursive,sg,mg+tg,sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters,matchk)
					if #cg==0 then break end
					
					--Cancellable
					finish=Rune.CheckGoal(mct,sct,bct,mmin,smin,min,max) and (not matchk or matchk(sg,c,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp))
					cancel=not og and Duel.IsSummonCancelable()
					
					--Select a Card
					--Debug.Message("Cards to Select: "..tostring(#cg)..", Selected: "..tostring(#sg))--..", Selected Card: "..tostring(tc))
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel)
					if not tc then break end
					--Execute Selection
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				local sct=sg:FilterCount(aux.NOT(monf),nil,c,SUMMON_TYPE_RUNE,tp)
				local mct=sg:FilterCount(aux.NOT(stf),nil,c,SUMMON_TYPE_RUNE,tp)
				if Rune.CheckGoal(mct,sct,#sg-mct-sct,mmin,smin,min,max) and (not matchk or matchk(sg,c,SUMMON_TYPE_RUNE|MATERIAL_RUNE,tp))then
					local filters={}
					Rune.CheckRecursive2(sg:GetFirst(),(mg+tg),Group.CreateGroup(),sg,0,0,0,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters,matchk)
					sg:KeepAlive()
					e:SetLabelObject({sg,filters,emt})
					if excondition then excondition(e,tp,1,sg) end
					return true
				else
					aux.DeleteExtraMaterialGroups(emt)
					return false
				end
			end
end
function Rune.Operation(monf,mmin,mmax,stf,smin,smax,group,customoperation,stage2)
	return 	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=table.unpack(e:GetLabelObject())
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_RUNE,ex[3],ex[1]&g,c,tp)
					end
				end
				c:SetMaterial(g)
				local rmgroup
				local tdgroup
				local thgroup
				for _,ex in ipairs(emt) do
					local te=ex[3]
					local ug=Rune.UsedExtraMaterials(g,ex[1])
					local locfunc=te:GetTarget()
					if locfunc and #ug>0 then
						local toloc=locfunc(te:GetHandler(),te,tp,g,ug,c,0)
						
						if toloc==LOCATION_REMOVED then
							if rmgroup then rmgroup:AddCard(ug)
							else rmgroup=ug end
						end
						if toloc==LOCATION_DECK then
							if tdgroup then tdgroup:AddCard(ug)
							else tdgroup=ug end
						end
						if toloc==LOCATION_HAND then
							if tdgroup then thgroup:AddCard(ug)
							else thgroup=ug end
						end
					end
				end
				if rmgroup then
					g:Sub(rmgroup)
					Duel.Remove(rmgroup,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
				end
				if tdgroup then
					g:Sub(tdgroup)
					Duel.Remove(tdgroup,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
					Duel.SendtoDeck(tdgroup,nil,SEQ_DECKBOTTOM,REASON_MATERIAL+REASON_RUNE)
				end
				if thgroup then
					g:Sub(thgroup)
					Duel.SendtoHand(thgroup,nil,REASON_MATERIAL+REASON_RUNE)
				end
				if not customoperation then
					Duel.SendtoGrave(g,REASON_MATERIAL+REASON_RUNE)
					
					if stage2 then
						stage2(g,e,tp,eg,ep,ev,re,r,rp,tc)
					end
				else
					customoperation(g:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
				end
				g:DeleteGroup()
				e:GetLabelObject(nil)
				aux.DeleteExtraMaterialGroups(emt)
			end
end
function Rune.UsedExtraMaterials(mg,eg)
	return eg:Filter(function(c,g) return g:IsContains(c) end,nil,mg)
end
--Extension Functions
function Card.IsCanBeRuneMaterial(c,runc,tp)
	tp=tp or c:GetControler()
	if not Rune.IsCanBeMaterial(c,runc,tp) then return false end
	--Check if can be Material for Rune Monster
	if not runc then
		return true
	else
		if not runc:IsOriginalType(TYPE_MONSTER) or c:IsStatus(STATUS_FORBIDDEN) then return false end
		local mt=runc:GetMetatable()
		if not mt.rune_parameters then return false end
		local usable=false
		for _,rune_table in ipairs(mt.rune_parameters) do
			local mnf=rune_table[1]
			local stf=rune_table[4]
			if not c:IsType(TYPE_MONSTER) then
				usable=usable or (not stf or stf(c,runc,SUMMON_TYPE_RUNE,tp))
			elseif not c:IsType(TYPE_SPELL+TYPE_TRAP) then
				usable=usable or (not mnf or mnf(c,runc,SUMMON_TYPE_RUNE,tp))
			else
				usable=usable or (not mnf or mnf(c,runc,SUMMON_TYPE_RUNE,tp)) or (not stf or stf(c,runc,SUMMON_TYPE_RUNE,tp))
			end
		end
		return usable
	end
end
--sp_summon condition for link monster
function Auxiliary.runlimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_RUNE)(e,se,sp,st)
end
--Checks if a Rune Monster can Rune Summoned from a specific Location
function Card.IsRuneSummonable(c,must,materials,tmin,tmax,fromloc)
	if fromloc then
		if not c:IsType(TYPE_RUNE) or not Duel.IsPlayerCanSpecialSummonMonster(c:GetControler(),c:GetOriginalCode(),{c:GetOriginalSetCard()},c:GetOriginalType(),c:GetBaseAttack(),c:GetBaseDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute(),POS_FACEUP,c:GetControler(),SUMMON_TYPE_RUNE) then return false end
		local mt=c:GetMetatable()
		if not mt.rune_parameters then return false end
		--if not materials then materials=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil) end
		local summonable=false
		for _,rune_table in ipairs(mt.rune_parameters) do
			if (fromloc&rune_table[7])==fromloc and Rune.Condition(rune_table[1],rune_table[2],rune_table[3],rune_table[4],rune_table[5],rune_table[6],rune_table[8],rune_table[9])(e,c,must,materials,tmin,tmax) then
				summonable=true
			end
		end
		return summonable
	else
		--Remove Brackets if it doesn't work
		return c:IsProcedureSummonable(TYPE_RUNE,SUMMON_TYPE_RUNE,must,materials,tmin,tmax)
	end
end
--Gets the Minimum Number of Rune Materials necessary to Summon a Rune Monster
function Card.GetMinimumRuneMaterials(c,fromloc)
	if not c:IsType(TYPE_RUNE) then return nil end
	local mt=c:GetMetatable()
	fromloc=fromloc or c:GetLocation()
	if not mt.rune_parameters then return nil end
	for _,rune_table in ipairs(mt.rune_parameters) do
		if (fromloc&rune_table[7])==fromloc then return rune_table[2]+rune_table[5] end
	end
	return nil
end
--Duel.RuneSummon for Duel.ProcedureSummon
function Duel.RuneSummon(tp,c,must,materials,tmin,tmax)
	return Duel.ProcedureSummon(tp,c,SUMMON_TYPE_RUNE,must,materials,tmin,tmax)
end
--Checks if Card be counted as a Mentioned Card
function Card.IsRuneCode(c,code,rc,sumtype,tp)
	if c:IsCode(code) then return true end
	local effs = {c:GetCardEffect(EFFECT_RUNE_SUBSTITUTE)}
	for _,te in ipairs(effs) do
		local tcon=te:GetOperation()
		if not tcon or tcon(te,rc,sumtype,tp) then return true end
	end
	return false
end
--Checks if a card is treated as a Type for the Rune Summon of a Card
--[[
if not Rune.BaseCardIsType then
	Rune.BaseCardIsType = Card.IsType
	
	function Card.IsType(c,ctype,scard,sumtype,playerid)
		if not sumtype then sumtype = 0 end
		if not playerid then playerid = PLAYER_NONE end
		if sumtype&SUMMON_TYPE_RUNE == 0 then return Rune.BaseCardIsType(c,ctype,scard,sumtype,playerid) end
		local rte = c:GetCardEffect(EFFECT_RUNE_TYPE)
		
		local effs = {c:GetCardEffect(EFFECT_RUNE_TYPE)}
		for _,te in ipairs(effs) do
			local etg = te:GetTarget()
			local eval = te:GetValue()
			if etg or not teg(scard) then
				if (type(val)=='function' and val(rte,scard,sumtype,playerid)&ctype>0)
					or (type(val) == 'int' and val&ctype>0) then
					return true
				end
			end
		end
		
		return Rune.BaseCardIsType(c,ctype,scard,sumtype,playerid)
	end
end
--]]
--Checks the Rune Custom Check for Cards in cases where Monsters are not being Rune Summoned normally
function Card.IsRuneCustomCheck(c,mg,tp)
	if c.rune_custom_check then return c.rune_custom_check(mg,c,SUMMON_TYPE_RUNE,tp)
	else return true end
end
--Only for use in the Operation Procedure when Rune Summoning using a special Group of Materials
---Filters out cards that would be sent to the graveyard upon resolution of Duel.RuneSummon Function
function Card.IsCanBeRuneGroup(c,chain)
	if not chain then chain=Duel.GetCurrentChain() end
	return c:IsFaceup() and (chain~=1 or not c:IsStatus(STATUS_LEAVE_CONFIRMED))
end
