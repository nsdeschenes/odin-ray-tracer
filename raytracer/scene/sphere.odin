package scene

import geometry "../geometry"
import "core:math"

Sphere :: struct {
	center: geometry.Ray,
	radius: f64,
	mat:    Material,
	bbox:   AABB,
}

@(private = "file")
stationary_sphere :: proc(center: geometry.Point3, radius: f64, mat: Material) -> Sphere {

	rvec := geometry.vec3(radius, radius, radius)
	return Sphere {
		center = geometry.ray(center, geometry.vec3(0, 0, 0)),
		radius = math.max(radius, 0),
		mat = mat,
		bbox = aabb(geometry.sub(center, rvec), geometry.add(center, rvec)),
	}
}

@(private = "file")
moving_sphere :: proc(
	center1: geometry.Point3,
	center2: geometry.Point3,
	radius: f64,
	mat: Material,
) -> Sphere {

	center := geometry.ray(center1, geometry.sub(center2, center1))
	rvec := geometry.vec3(radius, radius, radius)
	box1 := aabb(
		geometry.sub(geometry.at(center, 0), rvec),
		geometry.add(geometry.at(center, 0), rvec),
	)
	box2 := aabb(
		geometry.sub(geometry.at(center, 1), rvec),
		geometry.add(geometry.at(center, 1), rvec),
	)


	return Sphere {
		center = center,
		radius = math.max(radius, 0),
		mat = mat,
		bbox = aabb(box1, box2),
	}
}


sphere :: proc {
	stationary_sphere,
	moving_sphere,
}

@(private)
hit_sphere :: proc(
	sphere: ^Sphere,
	r: geometry.Ray,
	ray_t: geometry.Interval,
	rec: ^HitRecord,
) -> bool {
	current_center := geometry.at(sphere.center, r.tm)
	oc := geometry.sub(current_center, r.orig)
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
	outward_normal := geometry.div(geometry.sub(rec.p, current_center), sphere.radius)
	set_face_normal(rec, r, outward_normal)
	rec.mat = &sphere.mat


	return true
}
