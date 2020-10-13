--@ module=true

info = {}
info["JOB"] = [===[ TODO ]===]

--===============================================================================================--
--== JOB CLASSES ===========================================================================--
--===============================================================================================--
local JOB = defclass(JOB) -- references <building>
function getJob(job) return JOB(job) end

--===============================================================================================--
--== JOB FUNCTIONS =========================================================================--
--===============================================================================================--
function JOB:__index(key)
	if rawget(self,key) then return rawget(self,key) end
	if rawget(JOB,key) then return rawget(JOB,key) end
	if dfhack.job[key] then 
		return function(...) 
			return dfhack.job[key](self._job,...) 
		end
	end
	return self._job[key]
end
function JOB:init(job)
-- Should we also be finding job by id? -ME
	self._job = job
	self.type = df.job_type[job.job_type]
end

function JOB:delay(delay) -- This should be a persistent delay -ME
	if not delay or delay <= 0 then
		self._job.completion_timer = 1 -- Should this actually set to 1, or let DF take over? -ME
		return
	end
	if self._job.completion_timer == -1 then
		dfhack.timeout(1,'ticks',function () self:delay(delay) end)
	else
		delay = delay - 1
		self._job.completion_timer = 10 -- Should this set to 10 or 100 or some other number? -ME
		dfhack.timeout(1,'ticks',function () self:delay(delay) end)
	end
end
