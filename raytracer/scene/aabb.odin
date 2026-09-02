package scene

import geometry "../geometry"
import "core:math"

AABB :: struct {
	x, y, z: geometry.Interval,
}

@(private = "file")
aabb_no_args :: proc() -> AABB {
    empty := geometry.interval(math.INF_F64, -math.INF_F64)
	return AABB{x = empty, y = empty, z = empty}
}

@(private = "file")
aabb_intervals :: proc(x, y, z: geometry.Interval) -> AABB {
	return AABB{x = x, y = y, z = z}
}

@(private = "file")
aabb_points :: proc(a, b: geometry.Vec3) -> AABB {
	x := (a.e[0] <= b.e[0]) ? geometry.interval(a.e[0], b.e[0]) : geometry.interval(b.e[0], a.e[0])
	y := (a.e[1] <= b.e[1]) ? geometry.interval(a.e[1], b.e[1]) : geometry.interval(b.e[1], a.e[1])
	z := (a.e[2] <= b.e[2]) ? geometry.interval(a.e[2], b.e[2]) : geometry.interval(b.e[2], a.e[2])

	return AABB{x = x, y = y, z = z}
}

@(private = "file")
aabb_boxes :: proc(box0, box1: AABB) -> AABB {
	x := geometry.interval(box0.x, box1.x)
	y := geometry.interval(box0.y, box1.y)
	z := geometry.interval(box0.z, box1.z)

	return AABB{x = x, y = y, z = z}
}

aabb :: proc {
	aabb_no_args,
	aabb_intervals,
	aabb_points,
	aabb_boxes,
}

axis_interval :: proc(aabb: AABB, n: int) -> geometry.Interval {
	if n == 1 {
		return aabb.y
	}

	if n == 2 {
		return aabb.z
	}

	return aabb.x
}

@(private)
hit_aabb :: proc(a: ^AABB, r: geometry.Ray, ray_t: ^geometry.Interval) -> bool {
	ray_origin := r.orig
	ray_dir := r.dir

	for axis := 0; axis < 3; axis += 1 {
		ax := axis_interval(a^, axis)
		adinv := 1.0 / ray_dir.e[axis]

		t0 := (ax.min - ray_origin.e[axis]) * adinv
		t1 := (ax.max - ray_origin.e[axis]) * adinv

		if t0 < t1 {
			if t0 > ray_t.min {ray_t.min = t0}
			if t1 < ray_t.max {ray_t.max = t1}
		} else {
			if t1 > ray_t.min {ray_t.min = t1}
			if t0 < ray_t.max {ray_t.max = t0}
		}

		if ray_t.max <= ray_t.min {
			return false
		}
	}

	return true
}

longest_axis :: proc(aabb: AABB) -> int {
	// Returns the index of the longest axis of the bounding box.
	if geometry.size(aabb.x) > geometry.size(aabb.y) {
		return geometry.size(aabb.x) > geometry.size(aabb.z) ? 0 : 2
	} else {
		return geometry.size(aabb.y) > geometry.size(aabb.z) ? 1 : 2
	}
}
