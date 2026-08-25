package geometry

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
