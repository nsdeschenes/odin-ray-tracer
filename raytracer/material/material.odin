package material

import geometry "../geometry"
import scene "../scene"

Material :: struct {
	data:    rawptr,
	scatter: proc(
		data: rawptr,
		r_in: ^geometry.Ray,
		rec: ^scene.HitRecord,
		attenuation: ^geometry.Color,
		scattered: ^geometry.Ray,
	) -> bool,
}
