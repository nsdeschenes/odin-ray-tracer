package shapes

import render "../render"
import vector "../vector"

HitRecord :: struct {
	p:      vector.Point3,
	normal: vector.Vec3,
	t:      f64,
}

Hittable :: struct {
	hit: proc(self: rawptr, r: render.Ray, ray_tmin: f64, ray_tmax: f64, rec: ^HitRecord) -> bool,
}
