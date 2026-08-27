package render

import geometry "../geometry"
import "core:fmt"
import "core:math"
import "core:os"

linear_to_gamma :: proc(linear_component: f64) -> f64 {
	if linear_component > 0 {
		return math.sqrt(linear_component)
	}

	return 0
}

write_color :: proc(out: ^os.File, pixel_color: geometry.Color) {
	r := pixel_color.e[0]
	g := pixel_color.e[1]
	b := pixel_color.e[2]

    // Apply a linear to gamma transform for gamma 2
    r = linear_to_gamma(r)
    g = linear_to_gamma(g)
    b = linear_to_gamma(b)

	intensity := geometry.Interval {
		min = 0.000,
		max = 0.999,
	}
	r_byte := cast(i32)(256 * geometry.clamp(intensity, r))
	g_byte := cast(i32)(256 * geometry.clamp(intensity, g))
	b_byte := cast(i32)(256 * geometry.clamp(intensity, b))

	fmt.fprintfln(out, "%d %d %d", r_byte, g_byte, b_byte)
}
