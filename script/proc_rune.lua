--[[
Strings
1175 = Rune Summon
]]
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
function Rune.AddProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition)
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
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc+LOCATION_HAND,group,condition})
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1175)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition))
	e1:SetTarget(Rune.Target(monf,mmin,mmax,stf,smin,smax,group))
	e1:SetOperation(Rune.Operation(monf,mmin,mmax,stf,smin,smax,group))
	e1:SetValue(SUMMON_TYPE_RUNE)
	c:RegisterEffect(e1)
	
	if loc then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetDescription(1175)
		e2:SetCode(EFFECT_SPSUMMON_PROC)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(loc)
		e2:SetCondition(Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition))
		e2:SetTarget(Rune.Target(monf,mmin,mmax,stf,smin,smax,group))
		e2:SetOperation(Rune.Operation(monf,mmin,mmax,stf,smin,smax,group))
		e2:SetValue(SUMMON_TYPE_RUNE)
		c:RegisterEffect(e2)
	end
end
function Rune.AddSecondProcedure(c,monf,mmin,mmax,stf,smin,smax,loc,group,condition)
	--monf is the monster Filter, stf is the S/T Filter
	--mmin, mmax are the minimums and maximums for the monsters
	--smin, smax are the minimums and maximums for the Spell/Trap cards
	--loc adds an additional location
	--group changes the 
	if not max1 then max1=min1 end
	if not max2 then max2=min2 end
	if c.rune_parameters==nil then
		local mt=c:GetMetatable()
		--mt.rune_monster_filter=function(c) end
		mt.rune_parameters={}
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc,group,condition})
	else
		local mt=c:GetMetatable()
		table.insert(mt.rune_parameters,{monf,mmin,mmax,stf,smin,smax,loc,group,condition})
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1175)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(loc)
	e1:SetCondition(Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition))
	e1:SetTarget(Rune.Target(monf,mmin,mmax,stf,smin,smax,group))
	e1:SetOperation(Rune.Operation(monf,mmin,mmax,stf,smin,smax,group))
	e1:SetValue(SUMMON_TYPE_RUNE)
	c:RegisterEffect(e1)
end
function Rune.MonsterFilter(c,f,rc,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsLocation(LOCATION_SZONE) and (not f or f(c,rc,SUMMON_TYPE_RUNE,tp))
		and c:IsCanBeRuneMaterial(nil,tp)
end
function Rune.STFilter(c,f,rc,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (not f or f(c,rc,SUMMON_TYPE_RUNE,tp))
		and c:IsCanBeRuneMaterial(nil,tp)
end
--Check if Usable as Material at all
function Rune.ConditionFilter(c,monf,stf,rc,tp)
	return Rune.MonsterFilter(c,monf,rc,tp) or Rune.STFilter(c,stf,rc,tp)
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
function Rune.CheckRecursive(c,mg,sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	--Check Filters
	local mon=Rune.MonsterFilter(c,monf,rc,tp)
	local st=Rune.STFilter(c,stf,rc,tp)

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
		res=aux.CheckValidExtra(c,tp,sg,mg,rc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	
	--Check Recursive and Increment Count based on Type
	local res=false
	if mon and st then
		res=Rune.CheckGoal(mct,sct,bct+1,mmin,smin,tmin,tmax) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	elseif mon then
		res=Rune.CheckGoal(mct+1,sct,bct,mmin,smin,tmin,tmax) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	elseif st then
		res=Rune.CheckGoal(mct,sct+1,bct,mmin,smin,tmin,tmax) or
			mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
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
function Rune.CheckRecursive2(c,mg,sg,csg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	--Check Filters
	local mon=Rune.MonsterFilter(c,monf,rc,tp)
	local st=Rune.STFilter(c,stf,rc,tp)

	--Count Maximums
	if #sg>=tmax then return Rune.CheckGoal(mct,sct,bct,mmin,smin,tmin,tmax) end --If the total count exceeds maximum
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
	local oldfilt=(table.unpack(filt))
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3]) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,rc,emt,filt)
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
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
			elseif mon then
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
			elseif st then
				res=mg:IsExists(Rune.CheckRecursive,1,sg,mg,sg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
			end
			sg:RemoveCard(c)
			return res
		else
			local res=Auxiliary.CheckGoal(mct,sct,bct,mmin,smin,tmin,tmax)
			sg:RemoveCard(c)
			return res
		end
	end
	
	--Self-Recursion
	if mon and st then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct,sct,bct+1,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	elseif mon then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct+1,sct,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
	elseif st then
		res=Rune.CheckRecursive2((csg-sg):GetFirst(),mg,sg,csg,mct,sct+1,bct,monf,mmin,mmax,stf,smin,smax,tmin,tmax,rc,tp,og,emt,filt)
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
function Rune.Condition(monf,mmin,mmax,stf,smin,smax,group,condition)
	return	function(e,c,must,g,min,max)
				if c==nil then return true end
				if condition and not condition(e,c) then return false end
				local tp=c:GetControler()
				--get usable group
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
				end
				--no extra materials if effect is negated
				if group and not c:IsDisabled() then
					g:Merge(group(tp,nil,c))
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
				local mg=g:Filter(Rune.ConditionFilter,c,monf,stf,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_RUNE)
				if must then mustg:Merge(must) end
				if #mustg>max or mustg:IsExists(aux.NOT(Rune.ConditionFilter),1,nil,monf,stf,c,tp) then return false end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_RUNE)
				local res=(mg+tg):Includes(mustg) and #mustg<=max
				if res then
					if #mustg==max then
						local sg=Group.CreateGroup()
						res=mustg:IsExists(Rune.CheckRecursive,1,sg,mg+tg,sg,0,0,0,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt)
					elseif #mustg<max then
						local sg=mustg
						local mct=sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_SPELL+TYPE_TRAP)
						local sct=sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_MONSTER)
						if mct>mmax or sct>smax then return false end
						res=(mg+tg):IsExists(Rune.CheckRecursive,1,sg,mg+tg,sg,mct,sct,#sg-mct-sct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt)
					end
				end
				aux.DeleteExtraMaterialGroups(emt)
				return res
			end
end
function Rune.Target(monf,mmin,mmax,stf,smin,smax,group)
	return 	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				--get usable group
				if not og then g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
				else g=og:Clone() end
				--no extra materials if effect is negated
				if group and not c:IsDisabled() then
					g:Merge(group(tp,nil,c))
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
				local mg=g:Filter(Rune.ConditionFilter,c,monf,stf,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_RUNE)
				if must then mustg:Merge(must) end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_RUNE)
				--Rune Summon
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<max do
					local sct=sg:FilterCount(aux.NOT(Rune.MonsterFilter),nil,monf,c,tp)
					local mct=sg:FilterCount(aux.NOT(Rune.STFilter),nil,stf,c,tp)
					local bct=#sg-mct-sct
					--Filters
					local filters={}
					if #sg>0 then
						Rune.CheckRecursive2(sg:GetFirst(),mg+tg,Group.CreateGroup(),sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters)
					end
					
					--Get Selectable Cards
					local cg=(mg+tg):Filter(Rune.CheckRecursive,sg,mg+tg,sg,mct,sct,bct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters)
					if #cg==0 then break end
					
					--Cancellable
					finish=Rune.CheckGoal(mct,sct,bct,mmin,smin,min,max)
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
				local sct=sg:FilterCount(aux.NOT(Rune.MonsterFilter),nil,monf,c,tp)
				local mct=sg:FilterCount(aux.NOT(Rune.STFilter),nil,stf,c,tp)
				if Rune.CheckGoal(mct,sct,#sg-mct-sct,mmin,smin,min,max) then
					local filters={}
					Rune.CheckRecursive2(sg:GetFirst(),(mg+tg),Group.CreateGroup(),sg,mct,sct,#sg-mct-sct,monf,mmin,mmax,stf,smin,smax,min,max,c,tp,mg,emt,filters)
					sg:KeepAlive()
					local reteff=Effect.GlobalEffect()
					reteff:SetTarget(function() return sg,filters,emt end)
					e:SetLabelObject(reteff)
					return true
				else
					aux.DeleteExtraMaterialGroups(emt)
					return false
				end
			end
end
function Rune.Operation(monf,mmin,mmax,stf,smin,smax,group)
	return 	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=e:GetLabelObject():GetTarget()()
				e:GetLabelObject():Reset()
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
				end
				if thgroup then
					g:Sub(thgroup)
					Duel.Remove(thgroup,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
				end
				--[[
				local gycards=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				if gycards:GetCount()>0 then
					g:Sub(gycards)
					Duel.Remove(gycards,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
				end
				--]]
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_RUNE)
				g:DeleteGroup()
				aux.DeleteExtraMaterialGroups(emt)
			end
end
function Rune.UsedExtraMaterials(mg,eg)
	return eg:Match(function(c,g) return g:IsContains(c) end,nil,mg)
end
--Extension Functions
function Card.IsCanBeRuneMaterial(c,runc,tp)
	tp=tp or c:GetControler()
	
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
	
	--Non-Rune Monsters
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
function Duel.RuneSummon(tp,c,must,materials,tmin,tmax)
	return Duel.ProcedureSummon(tp,c,SUMMON_TYPE_RUNE,must,materials,tmin,tmax)
end
function Card.IsRuneCode(c,code,rc,sumtype,tp)
	if c:IsCode(code) then return true end
	local effs = {c:GetCardEffect(EFFECT_RUNE_SUBSTITUTE)}
	for _,te in ipairs(effs) do
		local tcon=te:GetOperation()
		if not tcon or tcon(te,rc,sumtype,tp) then return true end
	end
	return false
end
