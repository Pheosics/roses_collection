--@ module=true

info = {}
info["REACTION"] = [===[ TODO ]===]

--===============================================================================================--
--== REACTION CLASSES ===========================================================================--
--===============================================================================================--
local REACTION = defclass(REACTION) -- references <building>
function getReaction(reaction) return REACTION(reaction) end

--===============================================================================================--
--== REACTION FUNCTIONS =========================================================================--
--===============================================================================================--
function REACTION:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(REACTION,key) then return rawget(REACTION,key) end
	return self._reaction[key]
end
function REACTION:init(reaction)
	if reaction._type == df.reaction then
		self._reaction = reaction
	else
		for _,r in pairs(df.global.world.raws.reactions.reactions) do
			if r.code == reaction then
				self._reaction = r
				break
			end
		end
		if not self._reaction then return nil end
	end
	self.Token = self._reaction.code
	self.code = self._reaction.code
	self.name = self._reaction.name
	self.skill = df.job_skill[self._reaction.skill]
end

