package scene

import geometry "../geometry"
import scene "../scene"

Lambertian :: struct {
	albedo: geometry.Color,
}


MaterialData :: union {
	Lambertian,
}

Material :: struct {
	data: MaterialData,
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
	}

	return false
}
