package shapes

import "core:math"

import render "../render"
import vector "../vector"

Sphere :: struct {
	center: vector.Point3,
	radius: f64,
}

hit_sphere :: proc(
	sphere: Sphere,
	r: render.Ray,
	ray_tmin: f64,
	ray_tmax: f64,
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
	if root <= ray_tmin || ray_tmax <= root {
		root = (h + sqrtd) / a
		if root <= ray_tmin || ray_tmax <= root {
			return false
		}
	}

	rec.t = root
	rec.p = render.at(r, rec.t)
	outward_normal := vector.div(vector.sub(rec.p, sphere.center), sphere.radius)
	set_face_normal(rec, r, outward_normal)

	return true
}
