package scene

import geometry "../geometry"
import scene "../scene"
import utils "../utils"
import "core:math"

Lambertian :: struct {
	albedo: geometry.Color,
}

lambertian :: proc(albedo: geometry.Color) -> Lambertian {
	return Lambertian{albedo = albedo}
}


@(private = "file")
scatter_lambertian :: proc(
	mat: ^Lambertian,
	r_in: geometry.Ray,
	rec: ^scene.HitRecord,
	attenuation: ^geometry.Color,
	scattered: ^geometry.Ray,
) -> bool {
	scatter_direction := geometry.add(rec.normal, geometry.random_unit_vector())

	// Catch degenerate scatter direction
	if geometry.near_zero(scatter_direction) {
		scatter_direction = rec.normal
	}

	scattered^ = geometry.ray(rec.p, scatter_direction)
	attenuation^ = mat.albedo
	return true
}

Metal :: struct {
	albedo: geometry.Color,
	fuzz:   f64,
}

metal :: proc(albedo: geometry.Color, fuzz: f64) -> Metal {
	actual_fuzz := fuzz < 1 ? fuzz : 1
	return Metal{albedo = albedo, fuzz = actual_fuzz}
}

@(private = "file")
scatter_metal :: proc(
	mat: ^Metal,
	r_in: geometry.Ray,
	rec: ^scene.HitRecord,
	attenuation: ^geometry.Color,
	scattered: ^geometry.Ray,
) -> bool {
	reflected := geometry.reflect(r_in.dir, rec.normal)
	reflected = geometry.add(
		geometry.unit_vector(reflected),
		geometry.mul_scalar(geometry.random_unit_vector(), mat.fuzz),
	)
	scattered^ = geometry.ray(rec.p, reflected)
	attenuation^ = mat.albedo
	return geometry.dot(scattered.dir, rec.normal) > 0
}

Dielectric :: struct {
	// Refractive index in vacuum or air, or the ratio of the material's
	// refractive index over the refractive index of the enclosing media
	refraction_index: f64,
}

dielectric :: proc(refraction_index: f64) -> Dielectric {
	return Dielectric{refraction_index = refraction_index}
}

@(private = "file")
scatter_dielectric :: proc(
	mat: ^Dielectric,
	r_in: geometry.Ray,
	rec: ^scene.HitRecord,
	attenuation: ^geometry.Color,
	scattered: ^geometry.Ray,
) -> bool {
	attenuation^ = geometry.color(1.0, 1.0, 1.0)
	ri := rec.front_face ? (1.0 / mat.refraction_index) : mat.refraction_index

	unit_direction := geometry.unit_vector(r_in.dir)
	cos_theta := math.min(geometry.dot(geometry.neg(unit_direction), rec.normal), 1.0)
	sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)

	cannot_refract := ri * sin_theta > 1.0
	direction: geometry.Vec3
	if cannot_refract || dielectric_reflectance(cos_theta, ri) > utils.random_double() {
		direction = geometry.reflect(unit_direction, rec.normal)
	} else {
		direction = geometry.refract(unit_direction, rec.normal, ri)
	}

	scattered^ = geometry.ray(rec.p, direction)
	return true
}

@(private = "file")
dielectric_reflectance :: proc(cosine, refraction_index: f64) -> f64 {
	// Use Schlick's approximation for reflectance.
	r0 := (1 - refraction_index) / (1 + refraction_index)
	r0 = r0 * r0
	return r0 + (1 - r0) * math.pow((1 - cosine), 5)
}

MaterialData :: union {
	Lambertian,
	Metal,
	Dielectric,
}

Material :: struct {
	data: MaterialData,
}

scatter :: proc(
	mat: ^Material,
	r_in: geometry.Ray,
	rec: ^scene.HitRecord,
	attenuation: ^geometry.Color,
	scattered: ^geometry.Ray,
) -> bool {
	switch &m in mat.data {
	case Lambertian:
		return scatter_lambertian(&m, r_in, rec, attenuation, scattered)
	case Metal:
		return scatter_metal(&m, r_in, rec, attenuation, scattered)
	case Dielectric:
		return scatter_dielectric(&m, r_in, rec, attenuation, scattered)
	}

	return false
}
