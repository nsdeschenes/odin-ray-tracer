package geometry

Ray :: struct {
	orig: Point3,
	dir:  Vec3,
}

ray :: proc(origin: Point3, direction: Vec3) -> Ray {
	return Ray{orig = origin, dir = direction}
}

origin :: proc(r: Ray) -> Point3 {
	return r.orig
}

direction :: proc(r: Ray) -> Vec3 {
	return r.dir
}

at :: proc(r: Ray, t: f64) -> Point3 {
	return add(r.orig, mul_scalar(r.dir, t))
}
