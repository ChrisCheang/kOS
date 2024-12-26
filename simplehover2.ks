// simplehover2 - goal is to keep x y position using kos cooked control (more inbuilt functionality)


// https://ksp-kos.github.io/KOS/tutorials/pidloops.html
// https://ksp-kos.github.io/KOS/structures/misc/pidloop.html
// https://electronics.stackexchange.com/questions/624607/how-to-add-a-constant-to-a-control-system-block-diagram
// https://ksp-kos.github.io/KOS/commands/flight/cooked.html#don-t-wait-or-run-slow-script-code-during-cooked-control-calculation

// https://www.reddit.com/r/Kos/comments/bwy79n/clarifications_on_shipvelocitysurface/
// https://ksp-kos.github.io/KOS/math/ref_frame.html#raw-orientation

// 

CLEARSCREEN.

STAGE.

SET thrott TO 0.7.
set targetalt to 90. // the setpoint


// Orientation
// Idea: two PID loops, one for east-west pos and north-south pos each. PIDoutputs for these will be fed into a function to create a heading for the vehicle to lock steering to, bearing by arctangent of the two pid outputs, pitch by magnitude.

SET padlat TO -0.096702349581434.
SET padlng TO -74.5531988452273.
SET spot TO lATLNG(padlat, padlng). // coordinates of a bit off the pad

LOCK lat TO SHIP:GEOPOSITION:LAT.
LOCK lng TO SHIP:GEOPOSITION:LNG.

LOCK northVec TO  SHIP:NORTH:FOREVECTOR.
LOCK upVec TO SHIP:UP:VECTOR.
LOCK eastVec TO VCRS(upVec,northVec).

LOCK northSpeed TO VDOT(northVec,SHIP:VELOCITY:SURFACE).
LOCK upSpeed TO VDOT(upVec,SHIP:VELOCITY:SURFACE).
LOCK eastSpeed TO VDOT(eastVec,SHIP:VELOCITY:SURFACE).


SET EASTPID TO PIDLOOP(0.5,0.001,1).
SET NORTHPID TO PIDLOOP(0.5,0.001,1).
SET EASTPID:SETPOINT TO padlng.
SET NORTHPID:SETPOINT TO padlat.

SET eastPIDUpdate TO 0.
SET northPIDUpdate TO 0.
SET targetHeading TO 0.


// LOCK STEERING TO UP.


LOCK pitch TO 90 - 100*ABS(lat - padlat) - 100*ABS(lng-padlng).
//LOCK pitch TO 90-ABS(500*eastPIDUpdate)-ABS(500*northPIDUpdate).

LOCK STEERING TO HEADING(targetHeading, pitch).







// Drawing an debug arrow in 3D space at the spot where the GeoCoordinate
// "spot" is:
// It starts at a position 100m above the ground altitude and is aimed down
// at the spot on the ground:
SET VD TO VECDRAWARGS(
              { return spot:ALTITUDEPOSITION(targetalt+100). },
              { return spot:POSITION - spot:ALTITUDEPOSITION(targetalt+100). },
              red, "THIS IS THE SPOT", 1, true).



// Altitude controller - Gains

// 0.5, 0.3, 0.5 works well with 1.38 TWR

SET Kp TO 0.5.
SET Ki TO 0.3.
SET Kd TO 0.5.
SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1).
SET PID:SETPOINT TO targetalt.

LOCK THROTTLE TO thrott.

until false {
	set thrott to PID:UPDATE(TIME:SECONDS, ALTITUDE).
	set eastPIDUpdate to EASTPID:UPDATE(TIME:SECONDS, lng).
	set northPIDUpdate to NORTHPID:UPDATE(TIME:SECONDS, lat).
	set targetHeading to MOD(arctan2(eastPIDUpdate,northPIDUpdate) + 360, 360). //https://stackoverflow.com/questions/1311049/how-to-map-atan2-to-degrees-0-360
	// note: switching north and east around in arctan2 is a quick fix to address the (y,x) input of atan2

	CLEARSCREEN.
	PRINT "throttle = " + round(thrott,3) + ", alt = " + round(ALTITUDE,2).
	PRINT "Bearing = " + round(MOD(360-ship:BEARING, 360),2) + " deg".
	PRINT "North Velocity = " + round(northSpeed,2) + " m/s".
	PRINT "East Velocity = " + round(eastSpeed,2) + " m/s".
	PRINT "Up Velocity = " + round(upSpeed,2) + " m/s".
	PRINT  "Latitude dif  = " + (lat - padlat).
	PRINT  "Longitude dif = " + (lng - padlng).
	PRINT "eastPIDUpdate = " + eastPIDUpdate.
	PRINT "northPIDUpdate = " + northPIDUpdate.
	PRINT "Target heading = " + targetHeading.
	PRINT "Pitch = " + pitch + " deg".
}

// Notes: This iteration uses HEADING to set the steering orientation: the PID loop cannot be implemented into the pitch control set angle which compromises settling behaviour. Try locking steering to point towards a position vector (say spot:ALTITUDEPOSITION(1000) as a base) then offset that in lat and lng with the two PID loops.
