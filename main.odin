package main

import "core:fmt"
import "core:math"
import "core:os"

import r "./render"
import v "./vector"

hit_sphere :: proc(center: v.Point3, radius: f64, ray: r.Ray) -> f64 {
	oc := v.sub(center, ray.orig)
	a := v.dot(ray.dir, ray.dir)
	b := -2.0 * v.dot(ray.dir, oc)
	c := v.dot(oc, oc) - radius * radius
	discriminant := b * b - 4 * a * c

	if discriminant < 0 {
		return -1.0
	}

	return (-b - math.sqrt_f64(discriminant)) / (2.0 * a)
}

ray_color :: proc(ray: r.Ray) -> r.Color {
	t := hit_sphere(v.point3(0, 0, -1), 0.5, ray)
	if t > 0.0 {
		N := v.unit_vector(v.sub(r.at(ray, t), v.vec3(0, 0, -1)))
		return v.mul_scalar(r.color(v.x(N) + 1, v.y(N) + 1, v.z(N) + 1), 0.5)
	}

	unit_direction := v.unit_vector(ray.dir)
	a := 0.5 * (v.y(unit_direction) + 1.0)

	color_a := v.mul_scalar(r.color(1, 1, 1), (1 - a))
	color_b := v.mul_scalar(r.color(0.5, 0.7, 1), a)
	return v.add(color_a, color_b)
}

main :: proc() {
	// Image
	aspect_ratio := 16.0 / 9.0
	image_width := 400

	// Calculate the image height, and ensure its at least 1.
	image_height := cast(int)(cast(f64)image_width / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height

	// Camera
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (cast(f64)image_width / cast(f64)image_height)
	camera_center := v.point3(0, 0, 0)

	// Calculate the vectors across the horizontal and down the
	// vertical viewport edges
	viewport_u := v.vec3(viewport_width, 0, 0)
	viewport_v := v.vec3(0, -viewport_height, 0)

	// Calculate the horizontal and vertical delta vectors
	// from pixel to pixel
	pixel_delta_u := v.div(viewport_u, cast(f64)image_width)
	pixel_delta_v := v.div(viewport_v, cast(f64)image_height)

	// Calculate the location of the upper left panel
	viewport_upper_left := v.sub(
		v.sub(
			v.sub(camera_center, v.vec3(0, 0, cast(f64)focal_length)),
			v.div(viewport_u, cast(f64)2),
		),
		v.div(viewport_v, cast(f64)2),
	)


	pixel00_loc := v.add(
		viewport_upper_left,
		v.mul_scalar(v.add(pixel_delta_u, pixel_delta_v), 0.5),
	)

	// Renderer
	file, open_err := os.open("image.ppm", os.O_WRONLY)

	if open_err != nil {
		fmt.println("Failed to open file")
		return
	}
	defer os.close(file)

	_, header_err := os.write_strings(
		file,
		"P3\n",
		fmt.tprintf("%d", image_width),
		" ",
		fmt.tprintf("%d", image_height),
		"\n255\n",
	)

	if header_err != nil {
		fmt.println("Failed to write file header info")
		return
	}

	for j := 0; j < image_height; j += 1 {
		fmt.print("\rScanlines remaining: ", image_height - j, " ")
		for i := 0; i < image_width; i += 1 {
			pixel_center := v.add(
				pixel00_loc,
				v.add(
					v.mul_scalar(pixel_delta_u, cast(f64)i),
					v.mul_scalar(pixel_delta_v, cast(f64)j),
				),
			)
			ray_direction := v.sub(pixel_center, camera_center)
			ray := r.ray(camera_center, ray_direction)

			pixel_color := ray_color(ray)
			r.write_color(file, pixel_color)
		}
	}

	fmt.println("\rDone.                 ")
}
