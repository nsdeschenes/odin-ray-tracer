package interval

import "core:math"

Interval :: struct {
	min, max: f64,
}

@(private)
interval_no_args :: proc() -> Interval {
	return Interval{min = -math.INF_F64, max = math.INF_F64}
}

@(private)
interval_with_args :: proc(min: f64, max: f64) -> Interval {
	return Interval{min = min, max = max}
}

interval :: proc {
	interval_no_args,
	interval_with_args,
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
