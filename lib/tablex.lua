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

-- append values to a table
function table.append(t, ...)
	local i, v
	for i, v in pairs{...}
	do	table.insert(t, v)
	end
	return t
end

-- print the pairs in the table
function table.printPairs(t,before, after)
	local	k,v
	if	before ~= nil
	then	print(before)
	end
	for	k,v in pairs(t)
	do	print(k, v)
	end
	if	after ~= nil
	then	print(after)
	end
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
	
	function mynext(tab, k)
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

do
	local rserialize
	function rserialize(r, ...)
		local t = {}
		local push_t = function()
			if	#t <= 0
			then	return
			end
			table.append(r, "s", #t, table.unpack(t))
			t={}
		end
		for	i, v in ipairs{...}
		do	if	type(v) == "table"
			then	push_t()
				table.append(r, "t")
				local k, vv
				for	k, vv in pairs(v)
				do	table.append(r, "k", k)
					if	type(vv) == "table"
					then	rserialize(r, vv)
					elseif	type(vv) == "function"
					then	table.append(r, "f")
					else	table.append(r, "v", vv)
					end
				end
				table.append(r, "n")
			elseif	type(v) == "function"
			then	push_t()
				table.append(r, "f")
			elseif  type(v) == "nil"
			then	push_t()
				table.append(r, "n")
			else	table.insert(t, v)
			end
		end
		push_t()
	end

	local error_unserialized
	function error_unserialized()
		error("calling unserialized function, serializing functions is unsupported")
	end

	local runserialize_table
	function runserialize_table(r, i, nn, arg)
		local t = {}
		while	arg[i] == 'k'
		do	local k = arg[i + 1]
			i = i + 2
			if	arg[i] == "v"
			then	local v = arg[i + 1]
				t[k] = v
				i = i + 2
			elseif	arg[i] == "f"
			then	t[k] = error_unserialized
				i = i + 1
			elseif	arg[i] == "t"
			then	local v = {}
				i = runserialize_table(v, i+1, 0, arg)
				t[k] = v[1]
			else	error("invalid list: barf in table on", i, arg[i])
			end
		end
		if	arg[i] == "n"
		then	i = i + 1
		else	error("invalid list: barf in table on", i, arg[i])
		end
		nn = nn + 1
		r[nn] = t
		return i, nn
	end

	local runserialize
	function runserialize(r, i, arg)
		local nn = 0
		while arg[i]
		do	if	not arg[i]
			then	errot("invalid list, barf on".. i)
			end
			local c = arg[i]
			if	c == "s"
			then	local j
				local jj = arg[i+1]
				for j = 1, jj
				do	local n = nn
					r[n+j] = arg[i+1+j]
				end
				nn = nn + jj
				i = i + jj + 2
			elseif	c == "f"
			then	nn = nn + 1
				r[nn] = error_unserialized
			elseif	c == "t"
			then	i, nn = runserialize_table(r, i+1, nn, arg)
			else
				error("invalid list: barf on".. i.. arg[i])
			end
		end
		return i, nn
	end

	-- serialize a list into a list not containing tables and functions
	-- tables can be restored, functions can't
	-- if a table is recursive, the result will be larger than the universe
	function table.lua_serialize(...)
		local r = {}
		rserialize(r, ...)
		return table.unpack(r)
	end

	-- unserializes the result of table.lua_serialize
	function table.lua_unserialize(...)
		local r = {}
		if	type((...)) == "table"
		then	runserialize(r, 1, ...)
		else	runserialize(r, 1, {...})
		end
		return table.unpack(r)
	end

end

return table
