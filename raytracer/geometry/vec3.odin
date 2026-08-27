package geometry

import utils "../utils"
import "core:math"

Vec3 :: struct {
	e: [3]f64,
}

Point3 :: Vec3

vec3 :: proc(x: f64 = 0, y: f64 = 0, z: f64 = 0) -> Vec3 {
	return Vec3{e = {x, y, z}}
}

point3 :: proc(x: f64 = 0, y: f64 = 0, z: f64 = 0) -> Point3 {
	return Point3{e = {x, y, z}}
}

x :: proc(v: Vec3) -> f64 {
	return v.e[0]
}

y :: proc(v: Vec3) -> f64 {
	return v.e[1]
}

z :: proc(v: Vec3) -> f64 {
	return v.e[2]
}

neg :: proc(v: Vec3) -> Vec3 {
	return vec3(-v.e[0], -v.e[1], -v.e[2])
}

add_assign :: proc(v: ^Vec3, other: Vec3) {
	v.e[0] += other.e[0]
	v.e[1] += other.e[1]
	v.e[2] += other.e[2]
}

mul_assign :: proc(v: ^Vec3, t: f64) {
	v.e[0] *= t
	v.e[1] *= t
	v.e[2] *= t
}

div_assign :: proc(v: ^Vec3, t: f64) {
	mul_assign(v, 1 / t)
}

length_squared :: proc(v: Vec3) -> f64 {
	return v.e[0] * v.e[0] + v.e[1] * v.e[1] + v.e[2] * v.e[2]
}

@(private = "file")
random_no_args :: proc() -> Vec3 {
	return vec3(utils.random_double(), utils.random_double(), utils.random_double())
}

@(private = "file")
random_with_args :: proc(min, max: f64) -> Vec3 {
	return vec3(
		utils.random_double(min, max),
		utils.random_double(min, max),
		utils.random_double(min, max),
	)
}

random :: proc {
	random_no_args,
	random_with_args,
}

length :: proc(v: Vec3) -> f64 {
	return math.sqrt(length_squared(v))
}

add :: proc(u, v: Vec3) -> Vec3 {
	return vec3(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2])
}

sub :: proc(u, v: Vec3) -> Vec3 {
	return vec3(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2])
}

mul_vec :: proc(u, v: Vec3) -> Vec3 {
	return vec3(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2])
}

mul_scalar :: proc(v: Vec3, t: f64) -> Vec3 {
	return vec3(v.e[0] * t, v.e[1] * t, v.e[2] * t)
}

div :: proc(v: Vec3, t: f64) -> Vec3 {
	return mul_scalar(v, 1 / t)
}

dot :: proc(u, v: Vec3) -> f64 {
	return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2]
}

cross :: proc(u, v: Vec3) -> Vec3 {
	return vec3(
		u.e[1] * v.e[2] - u.e[2] * v.e[1],
		u.e[2] * v.e[0] - u.e[0] * v.e[2],
		u.e[0] * v.e[1] - u.e[1] * v.e[0],
	)
}

unit_vector :: proc(v: Vec3) -> Vec3 {
	return div(v, length(v))
}

random_unit_vector :: proc() -> Vec3 {
	for true {
		p := random(-1, 1)
		lensq := length_squared(p)
		if 1e-160 < lensq && lensq <= 1 {
			return div(p, math.sqrt(lensq))
		}
	}
	unreachable()
}

random_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
	on_unit_sphere := random_unit_vector()
	if dot(on_unit_sphere, normal) > 0.0 {
		return on_unit_sphere
	}
	return neg(on_unit_sphere)
}
