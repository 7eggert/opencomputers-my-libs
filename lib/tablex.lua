local table=require("table") -- we augment it

-- join a number of tables into cone, flat-copying each key
-- later tables will override earlier ones
function table.join(...)
	local result = {}
	local i, t
	for i, t in ipairs({...}) do
		local k,v
		for k, v in pairs(t) do
			result[k]=v
		end
	end
	return result
end

-- recursively dump table
-- do not use on looping tables yet
function table.dump(tab, indent)
	if indent == nil then indent = "" end
	if type (tab) ~= "table" then
		print ("invoke with a table, you sent me a: ", type (tab) )
		return
	end
	for k, v in pairs (tab) do
		if 	type(k) == "table"
		then	k = tostring(k)
		end
		if type (v) == "table" then
			print (indent .. ">"..k, " <TABLE>")
			table.dump (v, indent.."-")
		else
			print (indent..">"..k," = ",v)
		end
	end
end

-- table.AutomagicTable
--  creates table with automatically instantiated
--  sub-tables, up to n leverls, or infinite if not n
do
	local auto, assign, mynext, mypairs, myipairs

	function auto(tab, key)
		local mt = getmetatable(tab)
		local val = mt.d[key]
		if	val
		then	return val
		end
		if	mt.n and mt.n < 1
		then	return nil
		end
		return setmetatable({}, {
			__index    = auto,
			__newindex = assign,
			__next     = mynext,
			__pairs    = mypairs,
			__ipairs   = myipairs,
			parent     = tab,
			key        = key,
			d          = {},
			n          = mt.n and mt.n - 1,
		})
	end
	
	function assign(tab, key, val)
		local mt = getmetatable(tab)
		if	type(val) == "table"
		and	next(val) == nil
		and	mt.n ~= 1
		then	val = nil
		end
		rawset(mt.d, key, val)
		rawset(tab, "_dummy", next(mt.d))
		-- ^tab is empty iff mt.d is empty
		if	mt.parent
		then	local pmt = getmetatable(mt.parent)
			if      next(mt.d) ~= nil
			then	pmt.__newindex(mt.parent, mt.key, tab)
			else	pmt.__newindex(mt.parent, mt.key, nil)
			end
		end
		return	val
	end
	
	function mynext(tab)
		local mt = getmetatable(tab)
		return next(mt.d, k)
	end

	function mypairs(tab)
		local mt = getmetatable(tab)
		return pairs(mt.d)
	end

	function myipairs(tab)
		local mt = getmetatable(tab)
		return ipairs(mt.d)
	end

	function table.AutomagicTable(n)
		return setmetatable({}, {
			__index    = auto,
			__newindex = assign,
			__next     = mynext,
			__pairs    = mypairs,
			__ipairs   = myipairs,
			d          = {}, -- <- data store
			n          = n
		})
	end
end

return table
