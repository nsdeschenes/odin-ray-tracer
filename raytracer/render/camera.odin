package render

import geometry "../geometry"

Camera :: struct {
	aspect_ratio:  f64,
	image_width:   int,
	image_height:  int,
	center:        geometry.Point3,
	pixel00_loc:   geometry.Point3,
	pixel_delta_u: geometry.Vec3,
	pixel_delta_v: geometry.Vec3,
}

initialize :: proc(aspect_ration: f64, image_width: int) -> Camera {
	camera := Camera{aspect_ratio=aspect_ration, image_width=image_width}

	camera.image_height = cast(int)(cast(f64)camera.image_width / camera.aspect_ratio)
	camera.image_height = (camera.image_height < 1) ? 1 : camera.image_height
	center := geometry.point3(0, 0, 0)

	// Determine viewport dimensions
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width :=
		viewport_height * (cast(f64)camera.image_width / cast(f64)camera.image_height)

	// Calculate the vectors across the horizontal and down the
	// vertical viewport edges
	viewport_u := geometry.vec3(viewport_width, 0, 0)
	viewport_v := geometry.vec3(0, -viewport_height, 0)

	// Calculate the horizontal and vertical delta vectors
	// from pixel to pixel
	camera.pixel_delta_u = geometry.div(viewport_u, cast(f64)camera.image_width)
	camera.pixel_delta_v = geometry.div(viewport_v, cast(f64)camera.image_height)

	// Calculate the location of the upper left panel
	viewport_upper_left := geometry.sub(
		geometry.sub(
			geometry.sub(center, geometry.vec3(0, 0, cast(f64)focal_length)),
			geometry.div(viewport_u, cast(f64)2),
		),
		geometry.div(viewport_v, cast(f64)2),
	)

	camera.pixel00_loc = geometry.add(
		viewport_upper_left,
		geometry.mul_scalar(geometry.add(camera.pixel_delta_u, camera.pixel_delta_v), 0.5),
	)

	return camera
}
