package render

import vector "../vector"

Ray :: struct {
	orig: vector.Point3,
	dir:  vector.Vec3,
}

ray :: proc(origin: vector.Point3, direction: vector.Vec3) -> Ray {
	return Ray{orig = origin, dir = direction}
}

origin :: proc(r: Ray) -> vector.Point3 {
	return r.orig
}

direction :: proc(r: Ray) -> vector.Vec3 {
	return r.dir
}

at :: proc(r: Ray, t: f64) -> vector.Point3 {
	return vector.add(r.orig, vector.mul_scalar(r.dir, t))
}
