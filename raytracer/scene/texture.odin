package scene

import geometry "../geometry"
import "core:math"

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

Checker_Texture :: struct {
	inv_scale: f64,
	even, odd: ^Texture,
}

@(private = "file")
checker_texture_texture :: proc(scale: f64, even, odd: ^Texture) -> Checker_Texture {
	return Checker_Texture{inv_scale = (1.0 / scale), even = even, odd = odd}
}

@(private = "file")
checker_texture_color :: proc(scale: f64, c1, c2: ^geometry.Color) -> Checker_Texture {
	s1 := new(Texture)
	s1^ = Solid_Color {
		albedo = c1^,
	}

	s2 := new(Texture)
	s2^ = Solid_Color {
		albedo = c2^,
	}

	return checker_texture_texture(scale, s1, s2)
}

checker_texture :: proc {
	checker_texture_texture,
    checker_texture_color,
}

Texture :: union {
	Solid_Color,
	Checker_Texture,
}

value :: proc(t: ^Texture, u, v: f64, p: ^geometry.Point3) -> geometry.Color {
	switch &obj in t {
	case Solid_Color:
		return obj.albedo
	case Checker_Texture:
		xInteger := cast(int)(math.floor(obj.inv_scale * geometry.x(p^)))
		yInteger := cast(int)(math.floor(obj.inv_scale * geometry.y(p^)))
		zInteger := cast(int)(math.floor(obj.inv_scale * geometry.z(p^)))

		isEven := (xInteger + yInteger + zInteger) % 2 == 0

		return isEven ? value(obj.even, u, v, p) : value(obj.odd, u, v, p)
	}
	unreachable()
}
