package shapes

import interval "../interval"
import render "../render"
import vector "../vector"

HitRecord :: struct {
	p:          vector.Point3,
	normal:     vector.Vec3,
	t:          f64,
	front_face: bool,
}

set_face_normal :: proc(self: ^HitRecord, ray: render.Ray, outward_normal: vector.Vec3) {
	// Sets the hit record normal vector.
	// NOTE: the parameter `outward_normal` is assumed to have unit length.

	self.front_face = vector.dot(ray.dir, outward_normal) < 0
	self.normal = self.front_face ? outward_normal : vector.neg(outward_normal)
}

Hittable :: union {
	Sphere,
}

hit :: proc(h: Hittable, ray: render.Ray, ray_t: interval.Interval, rec: ^HitRecord) -> bool {
	switch obj in h {
	case Sphere:
		return hit_sphere(obj, ray, ray_t, rec)
	}

	return false
}
