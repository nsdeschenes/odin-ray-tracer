package render

import v "../vector"

Ray :: struct {
	orig: v.Point3,
	dir:  v.Vec3,
}

ray :: proc(origin: v.Point3, direction: v.Vec3) -> Ray {
	return Ray{orig = origin, dir = direction}
}

origin :: proc(r: Ray) -> v.Point3 {
	return r.orig
}

direction :: proc(r: Ray) -> v.Vec3 {
	return r.dir
}

at :: proc(r: Ray, t: f64) -> v.Point3 {
	return v.add(r.orig, v.mul_scalar(r.dir, t))
}
