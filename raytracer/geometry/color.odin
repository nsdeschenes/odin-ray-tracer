package geometry

Color :: Vec3

color :: proc(r, g, b: f64) -> Color {
	return Color{e = {r, g, b}}
}
