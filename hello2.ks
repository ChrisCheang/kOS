LOCK northVec TO  SHIP:NORTH:FOREVECTOR.
LOCK upVec TO SHIP:UP:VECTOR.
LOCK eastVec TO VCRS(upVec,northVec).

LOCK northSpeed TO VDOT(northVec,SHIP:VELOCITY:SURFACE).
LOCK upSpeed TO VDOT(upVec,SHIP:VELOCITY:SURFACE).
LOCK eastSpeed TO VDOT(eastVec,SHIP:VELOCITY:SURFACE).


until false {
	CLEARSCREEN.
	PRINT "Bearing = " + round(ship:BEARING+90,2) + " deg".
	PRINT "North Velocity = " + round(northSpeed,2) + " m/s".
	PRINT "East Velocity = " + round(eastSpeed,2) + " m/s".
	PRINT "Up Velocity = " + round(upSpeed,2) + " m/s".
}

