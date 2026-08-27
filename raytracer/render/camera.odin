package render

import geometry "../geometry"
import utils "../utils"

Camera :: struct {
	aspect_ratio:        f64,
	image_width:         int,
	image_height:        int,
	samples_per_pixel:   int,
	pixel_samples_scale: f64,
	center:              geometry.Point3,
	pixel00_loc:         geometry.Point3,
	pixel_delta_u:       geometry.Vec3,
	pixel_delta_v:       geometry.Vec3,
}

initialize :: proc(aspect_ratio: f64, image_width: int, samples_per_pixel: int) -> Camera {
	pixel_samples_scale := 1.0 / cast(f64)samples_per_pixel

	image_height := cast(int)(cast(f64)image_width / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height
	center := geometry.point3(0, 0, 0)

	// Determine viewport dimensions
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (cast(f64)image_width / cast(f64)image_height)

	// Calculate the vectors across the horizontal and down the
	// vertical viewport edges
	viewport_u := geometry.vec3(viewport_width, 0, 0)
	viewport_v := geometry.vec3(0, -viewport_height, 0)

	// Calculate the horizontal and vertical delta vectors
	// from pixel to pixel
	pixel_delta_u := geometry.div(viewport_u, cast(f64)image_width)
	pixel_delta_v := geometry.div(viewport_v, cast(f64)image_height)

	// Calculate the location of the upper left panel
	viewport_upper_left := geometry.sub(
		geometry.sub(
			geometry.sub(center, geometry.vec3(0, 0, cast(f64)focal_length)),
			geometry.div(viewport_u, cast(f64)2),
		),
		geometry.div(viewport_v, cast(f64)2),
	)

	pixel00_loc := geometry.add(
		viewport_upper_left,
		geometry.mul_scalar(geometry.add(pixel_delta_u, pixel_delta_v), 0.5),
	)

	return Camera {
		aspect_ratio = aspect_ratio,
		image_width = image_width,
		image_height = image_height,
		samples_per_pixel = samples_per_pixel,
		pixel_samples_scale = pixel_samples_scale,
		center = center,
		pixel00_loc = pixel00_loc,
		pixel_delta_u = pixel_delta_u,
		pixel_delta_v = pixel_delta_v,
	}
}

get_ray :: proc(cam: Camera, i, j: int) -> geometry.Ray {
	// Construct a camera ray originating from the origin and directed at randomly sampled
	// point around the pixel location i, j.
	offset := sample_square()


	pixel_sample := geometry.add(
		cam.pixel00_loc,
		geometry.add(
			geometry.mul_scalar(cam.pixel_delta_u, (cast(f64)i + geometry.x(offset))),
			geometry.mul_scalar(cam.pixel_delta_v, (cast(f64)j + geometry.y(offset))),
		),
	)

	ray_origin := cam.center
	ray_direction := geometry.sub(pixel_sample, ray_origin)

	return geometry.ray(ray_origin, ray_direction)
}

sample_square :: proc() -> geometry.Vec3 {
	// Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
	return geometry.vec3(utils.random_double() - 0.5, utils.random_double() - 0.5, 0)
}
