package render

import "core:fmt"
import "core:os"

import vector "../vector"

Color :: vector.Vec3

color :: proc(r, g, b: f64) -> Color {
	return Color{e = {r, g, b}}
}

write_color :: proc(out: ^os.File, pixel_color: Color) {
	r := pixel_color.e[0]
	g := pixel_color.e[1]
	b := pixel_color.e[2]

	r_byte := cast(i32)(255.999 * r)
	g_byte := cast(i32)(255.999 * g)
	b_byte := cast(i32)(255.999 * b)

	fmt.fprintfln(out, "%d %d %d", r_byte, g_byte, b_byte)
}
