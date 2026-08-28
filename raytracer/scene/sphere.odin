package scene

import geometry "../geometry"
import "core:math"

Sphere :: struct {
	center: geometry.Point3,
	radius: f64,
	mat:    Material,
}

sphere :: proc(center: geometry.Point3, radius: f64, mat: Material) -> Sphere {
	return Sphere{center = center, radius = radius, mat = mat}
}

@(private)
hit_sphere :: proc(
	sphere: ^Sphere,
	r: geometry.Ray,
	ray_t: geometry.Interval,
	rec: ^HitRecord,
) -> bool {
	oc := geometry.sub(sphere.center, r.orig)
	a := geometry.length_squared(r.dir)
	h := geometry.dot(r.dir, oc)
	c := geometry.length_squared(oc) - sphere.radius * sphere.radius

	discriminant := h * h - a * c
	if discriminant < 0 {
		return false
	}

	sqrtd := math.sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range.
	root := (h - sqrtd) / a
	if !geometry.surrounds(ray_t, root) {
		root = (h + sqrtd) / a
		if !geometry.surrounds(ray_t, root) {
			return false
		}
	}

	rec.t = root
	rec.p = geometry.at(r, rec.t)
	outward_normal := geometry.div(geometry.sub(rec.p, sphere.center), sphere.radius)
	set_face_normal(rec, r, outward_normal)
	rec.mat = &sphere.mat


	return true
}
