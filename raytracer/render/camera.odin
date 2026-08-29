package render

import geometry "../geometry"
import utils "../utils"
import "core:math"

Camera :: struct {
	aspect_ratio:        f64, // Ratio of image width over height
	image_width:         int, // Rendered image width in pixel count
	image_height:        int, // Rendered image height
	samples_per_pixel:   int, // Count of random samples for each pixel
	pixel_samples_scale: f64, // Color scale factor for a sum of pixel samples
	max_depth:           int, // Maximum number of ray bounces into scene
	vfov:                int, // Vertical view angle (field of view)
	lookfrom:            geometry.Point3, // Point camera is looking from
	lookat:              geometry.Point3, // Point camera is looking at
	vup:                 geometry.Vec3, // Camera-relative "up" direction
	center:              geometry.Point3, // Camera center
	pixel00_loc:         geometry.Point3, // Location of pixel 0, 0
	pixel_delta_u:       geometry.Vec3, // Offset to pixel to the right
	pixel_delta_v:       geometry.Vec3, // Offset to pixel below
	u, v, w:             geometry.Vec3, // Camera frame basis vectors
}

initialize :: proc(
	aspect_ratio: f64 = 1.0,
	image_width: int = 100,
	samples_per_pixel: int = 10,
	max_depth: int = 10,
	vfov: int = 90,
	lookfrom: geometry.Point3,
	lookat: geometry.Point3,
	vup: geometry.Vec3,
) -> Camera {
	image_height := cast(int)(cast(f64)image_width / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height

	pixel_samples_scale := 1.0 / cast(f64)samples_per_pixel
	center := lookfrom

	// Determine viewport dimensions
	focal_length := geometry.length(geometry.sub(lookfrom, lookat))
	theta := utils.degrees_to_radians(cast(f64)vfov)
	h := math.tan(theta / 2)
	viewport_height := 2.0 * h * focal_length
	viewport_width := viewport_height * (cast(f64)image_width / cast(f64)image_height)

	// Calculate the u,v,w unit basis vectors for the camera coordinate frame.
	w := geometry.unit_vector(geometry.sub(lookfrom, lookat))
	u := geometry.unit_vector(geometry.cross(vup, w))
	v := geometry.cross(w, u)

	// Calculate the vectors across the horizontal and down the
	// vertical viewport edges
	viewport_u := geometry.mul_scalar(u, viewport_width) // Vector across viewport horizontal edge
	viewport_v := geometry.mul_scalar(geometry.neg(v), viewport_height) // Vector down viewport vertical edge

	// Calculate the horizontal and vertical delta vectors
	// from pixel to pixel
	pixel_delta_u := geometry.div(viewport_u, cast(f64)image_width)
	pixel_delta_v := geometry.div(viewport_v, cast(f64)image_height)

	// Calculate the location of the upper left panel
	viewport_upper_left := geometry.sub(
		geometry.sub(
			geometry.sub(center, geometry.mul_scalar(w, focal_length)),
			geometry.div(viewport_u, 2),
		),
		geometry.div(viewport_v, 2),
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
		max_depth = max_depth,
		vfov = vfov,
		center = center,
		pixel00_loc = pixel00_loc,
		pixel_delta_u = pixel_delta_u,
		pixel_delta_v = pixel_delta_v,
		lookat = lookat,
		lookfrom = lookfrom,
		vup = vup,
		u = u,
		v = v,
		w = w,
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
