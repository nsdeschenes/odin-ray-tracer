package scene

import geometry "../geometry"

Material :: struct {
	data:    rawptr,
	scatter: proc(
		data: rawptr,
		r_in: ^geometry.Ray,
		rec: ^HitRecord,
		attenuation: ^geometry.Color,
		scattered: ^geometry.Ray,
	) -> bool,
}
