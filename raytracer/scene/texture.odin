package scene

import geometry "../geometry"

Solid_Color :: struct {
	albedo: geometry.Color,
}

@(private = "file")
solid_color_albedo :: proc(albedo: geometry.Color) -> Solid_Color {
	return Solid_Color{albedo = albedo}
}

@(private = "file")
solid_color_rgb :: proc(red, green, blue: f64) -> Solid_Color {
	return Solid_Color{albedo = geometry.color(red, green, blue)}
}

solid_color :: proc {
	solid_color_albedo,
}

Texture :: union {
	Solid_Color,
}

value :: proc(t: ^Texture, u, v: f64, p: ^geometry.Point3) -> geometry.Color {
	switch &obj in t {
	case Solid_Color:
		return obj.albedo
	}
	unreachable()
}
