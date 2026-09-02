package scene

import geometry "../geometry"

AABB :: struct {
	x, y, z: geometry.Interval,
}

@(private = "file")
aabb_no_args :: proc() -> AABB {
	return AABB{}
}

@(private = "file")
aabb_intervals :: proc(x, y, z: geometry.Interval) -> AABB {
	return AABB{x = x, y = y, z = z}
}

@(private = "file")
aabb_points :: proc(a, b: ^geometry.Point3) -> AABB {
	x := (a.e[0] <= b.e[0]) ? geometry.interval(a.e[0], b.e[0]) : geometry.interval(b.e[0], a.e[0])
	y := (a.e[1] <= b.e[1]) ? geometry.interval(a.e[1], b.e[1]) : geometry.interval(b.e[1], a.e[1])
	z := (a.e[2] <= b.e[2]) ? geometry.interval(a.e[2], b.e[2]) : geometry.interval(b.e[2], a.e[2])

	return AABB{x = x, y = y, z = z}
}

aabb :: proc {
	aabb_no_args,
	aabb_intervals,
	aabb_points,
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
