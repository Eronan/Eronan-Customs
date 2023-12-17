--Binate Sentinel of Vesta
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
    Pendulum.AddProcedure(c)
	Gemini.AddProcedure(c)
end
