package scene

import geometry "../geometry"


HitRecord :: struct {
	p:          geometry.Point3,
	normal:     geometry.Vec3,
	mat:        ^Material,
	t:          f64,
	front_face: bool,
}

set_face_normal :: proc(rec: ^HitRecord, ray: geometry.Ray, outward_normal: geometry.Vec3) {
	// Sets the hit record normal vector.
	// NOTE: the parameter `outward_normal` is assumed to have unit length.

	rec.front_face = geometry.dot(ray.dir, outward_normal) < 0
	rec.normal = rec.front_face ? outward_normal : geometry.neg(outward_normal)
}

Hittable :: union {
	Sphere,
}

@(private)
hit_hittable :: proc(
	h: ^Hittable,
	ray: geometry.Ray,
	ray_t: geometry.Interval,
	rec: ^HitRecord,
) -> bool {
	switch &obj in h {
	case Sphere:
		return hit(&obj, ray, ray_t, rec)
	}

	return false
}

bounding_box :: proc(h: Hittable) -> AABB {
	switch obj in h {
	case Sphere:
		return obj.bbox
	}

	return {}
}
