package shapes

import "core:math"

import render "../render"
import vector "../vector"
import interval "../interval"

Sphere :: struct {
	center: vector.Point3,
	radius: f64,
}

@(private)
hit_sphere :: proc(
	sphere: Sphere,
	r: render.Ray,
	ray_t: interval.Interval,
	rec: ^HitRecord,
) -> bool {
	oc := vector.sub(sphere.center, r.orig)
	a := vector.length_squared(r.dir)
	h := vector.dot(r.dir, oc)
	c := vector.length_squared(oc) - sphere.radius * sphere.radius

	discriminant := h * h - a * c
	if discriminant < 0 {
		return false
	}

	sqrtd := math.sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range.
	root := (h - sqrtd) / a
	if !interval.surrounds(ray_t, root) {
		root = (h + sqrtd) / a
		if !interval.surrounds(ray_t, root) {
			return false
		}
	}

	rec.t = root
	rec.p = render.at(r, rec.t)
	outward_normal := vector.div(vector.sub(rec.p, sphere.center), sphere.radius)
	set_face_normal(rec, r, outward_normal)

	return true
}
