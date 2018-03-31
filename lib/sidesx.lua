local sidesx = require("sides") -- we augment it

-- returns the number of left turns needed
-- to face a certail side (NSWE), starting from south
function sidesx.side2Turns(side)
	if	side == sidesx.north
	then	return 2
	elseif	side == sidesx.west
	then	return 3
	elseif	side == sidesx.south
	then	return 0
	elseif  side == sidesx.east
	then	return 1
	else	error("illegal side")
end	end


-- returns the side we reach if starting from side, we do leftTurns
do
local sidesx_turnSideLeft_sides = {
	[1] = { [sidesx.north] = sidesx.west,  [sidesx.west]  = sidesx.south,
	          [sidesx.south] = sidesx.east, [sidesx.east] = sidesx.north },
	[2] = { [sidesx.north] = sidesx.south, [sidesx.south] = sidesx.north,
	          [sidesx.west]  = sidesx.east, [sidesx.east] = sidesx.west },
	[3] = { [sidesx.north] = sidesx.east,  [sidesx.east]  = sidesx.south,
	          [sidesx.south] = sidesx.west, [sidesx.west] = sidesx.north }
}
function sidesx.turnSideLeft(side, leftTurns)
	if	side == nil
	or	side == sidesx.up
	or	side == sidesx.down
	then	return side
	end
	leftTurns = math.floor(leftTurns) % 4
	if	leftTurns == 0
	then	return side
	else	return sidesx_turnSideLeft_sides[leftTurns][side]
	end
end
end -- do

-- the opposite side
function sidesx.inverseSide(dir)
	if	dir == sidesx.top
	then	return sidesx.bottom
	elseif	dir == sidesx.bottom
	then	return sidesx.top
	elseif	dir == sidesx.left
	then	return sidesx.right
	elseif	dir == sidesx.right
	then	return sidesx.left
	elseif	dir == sidesx.front
	then	return sidesx.back
	else	return sidesx.front
end	end



----------------------------------------------
-- coordinates from side or number of turns --
----------------------------------------------

-- returns a matrix xf, xl, zf, zl
--  if   (front, left) is a relative vector,
--  and the robot is facing towards side
--  then (xf * front + xl * left, zf * front + zl * left) are the turned coordinates
function sidesx.LF2XZ_vect(side)
	if	not side
	then	return nil, nil
	end
	if	side == sidesx.north
	then	return 0, -1, -1, 0
	elseif	side == sidesx.south
	then	return 0, 1, 1, 0
	elseif	side == sidesx.west
	then	return -1, 0, 0, 1
	elseif	side == sidesx.east
	then	return 1, 0, 0, -1
	else	return nil, "invalid side"
	end
end

-- same as sidesx.LF2XZ_vect, but for turns
function sidesx.T2XZ_vect(turns)
	if	not turns
	then	return nil, nil
	end
	print("there", turns)
	turns = turns % 4
	if	turns == 2
	then	return 0, -1, -1, 0
	elseif	turns == 0
	then	return 0, 1, 1, 0
	elseif	turns == 3
	then	return -1, 0, 0, 1
	elseif	turns == 1
	then	return 1, 0, 0, -1
	else	return nil, "invalid turns count"
	end
end


-- returns relative x and z according to side
--  e.g. robot is facing west:
--  geolyzed = ...geolyzer(sidesx.LF2XZ(sidesx.west, 0, 2)
--  will scan the second block in front
function sidesx.LF2XZ(side, left, front)
	local xf, xl, zf, zl = sidesx.LF2XZ_vect(side)
	if	not xf
	then	return xf, xl -- result, reason
	end
	return	xf * front + xl * left, zf * front + zl * left
end

-- returns relative x and z according to number of turns
--  not equal to sidesx.LF2XZ
--  since the number of turns realtive to facing north may be unknown
function sidesx.T2XZ(turns, left, front)
	local xf, xl, zf, zl = sidesx.T2XZ_vect(turns)
	if	not xf
	then	return xf, xl -- result, reason
	end
	return	xf * front + xl * left, zf * front + zl * left
end

-- like sidesx.T2XYZ, but with y value
function sidesx.T2XYZ(turns, left, front, up)
	local xf, xl, zf, zl = sidesx.T2XZ_vect(turns)
	if	not xf
	then	return xf, xl -- result, reason
	end
	return	xf * front + xl * left, up, zf * front + zl * left
end

-- returns the relative coordinates of the side, considering turnsLeft
function sidesx.side2XZ(dir, turnsLeft)
	if	turnsLeft
	then	dir = sidesx.turnSideLeft(dir, turnsLeft)
	end
	if	dir == sidesx.front
	then	return 0, 1
	elseif	dir == sidesx.back
	then	return 0, -1
	elseif	dir == sidesx.left
	then	return 1, 0
	elseif	dir == sidesx.right
	then	return -1, 0
	else	return nil
	end
end

-- like sidesx.side2XZ, but with y value
function sidesx.side2XYZ(dir, turnsLeft)
	if	dir == sidesx.up
	then	return 0, 1, 0
	elseif	dir == sidesx.down
	then	return 0, -1, 0
	end
	local x, z = sidesx.side2XZ(dir, turnsLeft)
	return x, 0, z
end

return sidesx