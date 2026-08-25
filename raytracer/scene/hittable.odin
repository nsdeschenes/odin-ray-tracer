package scene

import geometry "../geometry"

HitRecord :: struct {
	p:          geometry.Point3,
	normal:     geometry.Vec3,
	t:          f64,
	front_face: bool,
}

set_face_normal :: proc(self: ^HitRecord, ray: geometry.Ray, outward_normal: geometry.Vec3) {
	// Sets the hit record normal vector.
	// NOTE: the parameter `outward_normal` is assumed to have unit length.

	self.front_face = geometry.dot(ray.dir, outward_normal) < 0
	self.normal = self.front_face ? outward_normal : geometry.neg(outward_normal)
}

Hittable :: union {
	Sphere,
}

@(private)
hit_hittable :: proc(
	h: Hittable,
	ray: geometry.Ray,
	ray_t: geometry.Interval,
	rec: ^HitRecord,
) -> bool {
	switch obj in h {
	case Sphere:
		return hit(obj, ray, ray_t, rec)
	}

	return false
}
