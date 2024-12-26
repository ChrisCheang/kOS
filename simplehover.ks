// simplehover - goal is to keep altitude only.


// https://ksp-kos.github.io/KOS/tutorials/pidloops.html
// https://electronics.stackexchange.com/questions/624607/how-to-add-a-constant-to-a-control-system-block-diagram
// https://ksp-kos.github.io/KOS/structures/misc/pidloop.html

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

STAGE.

// Defining variables
SET thrott TO 0.7.
set targetalt to 10. // the setpoint

LOCK STEERING TO UP.  // simple method of locking steering for now


// Gains

// 0.5, 0.3, 0.5 works well with 1.38 TWR

SET Kp TO 0.5.
SET Ki TO 0.3.
SET Kd TO 0.5.
SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1).
SET PID:SETPOINT TO targetalt.


LOCK THROTTLE TO thrott.

until false {
	set thrott to PID:UPDATE(TIME:SECONDS, alt:radar).
	PRINT "Current throttle = " + round(thrott,3) + ", Alt = " + round(alt:radar,2).
	// pid:update() is given the input time and input (alt:radar here) and returns the output.
}

// Notes: Increasing Kd too much creates oscillations which make it unstable (haven't done pole analysis yet, but due to gravitational offset and controlling pos using accel, the system is unlikely to be linear (affine?) 
// Once in hovering position, stable through increasing TWR from 1.4 to 2 ish at burnout, BUT not when ascending from ground
