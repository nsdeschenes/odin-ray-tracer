package utils

import "core:math"
import math_rand "core:math/rand"

degrees_to_radians :: proc(degrees: f64) -> f64 {
	return degrees * math.PI / 180
}

@(private = "file")
random_double_no_args :: proc() -> f64 {
	// Returns a random real in [0,1)
	return math_rand.float64_range(0, 1)
}

@(private = "file")
random_double_args :: proc(min, max: f64) -> f64 {
	// Returns a random real in [min, max)
	return math_rand.float64_range(min, max)
}

random_double :: proc {
	random_double_args,
	random_double_no_args,
}

random_int :: proc(min, max: int) -> int {
	// Returns a random integer in [min,max].
	return cast(int)(random_double(cast(f64)min, cast(f64)max + 1))
}
