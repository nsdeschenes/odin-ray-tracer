package geometry

import "core:math"

Interval :: struct {
	min, max: f64,
}

@(private = "file")
interval_no_args :: proc() -> Interval {
	return Interval{min = -math.INF_F64, max = math.INF_F64}
}

@(private = "file")
interval_with_args :: proc(min: f64, max: f64) -> Interval {
	return Interval{min = min, max = max}
}

@(private = "file")
interval_from_intervals :: proc(a, b: Interval) -> Interval {
	// Create the interval tightly enclosing the two input intervals.

	min := a.min <= b.min ? a.min : b.min
	max := a.max >= b.max ? a.max : b.max

	return Interval{min = min, max = max}
}

interval :: proc {
	interval_no_args,
	interval_with_args,
	interval_from_intervals,
}

size :: proc(i: Interval) -> f64 {
	return i.max - i.min
}

contains :: proc(i: Interval, x: f64) -> bool {
	return i.min <= x && x <= i.max
}

surrounds :: proc(i: Interval, x: f64) -> bool {
	return i.min < x && x < i.max
}

clamp :: proc(interval: Interval, x: f64) -> f64 {
	if x < interval.min {
		return interval.min
	}

	if x > interval.max {
		return interval.max
	}

	return x
}

expand :: proc(i: Interval, delta: f64) -> Interval {
	padding := delta / 2
	return interval(i.min - padding, i.max + padding)
}
