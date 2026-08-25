package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:thread"

import interval "./interval"
import render "./render"
import shapes "./shapes"
import vector "./vector"

THREAD_COUNT :: 8


ray_color :: proc(ray: render.Ray, world: shapes.HittableList) -> render.Color {
	rec: shapes.HitRecord
	if shapes.hit_hittable_list(world, ray, interval.interval(0, math.INF_F64), &rec) {
		return vector.mul_scalar(vector.add(render.color(1, 1, 1), rec.normal), 0.5)
	}

	unit_direction := vector.unit_vector(ray.dir)
	a := 0.5 * (vector.y(unit_direction) + 1.0)

	color_a := vector.mul_scalar(render.color(1, 1, 1), (1 - a))
	color_b := vector.mul_scalar(render.color(0.5, 0.7, 1), a)
	return vector.add(color_a, color_b)
}

main :: proc() {
	// Image
	aspect_ratio := 16.0 / 9.0
	image_width := 400

	// Calculate the image height, and ensure its at least 1.
	image_height := cast(int)(cast(f64)image_width / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height

	// World
	world := shapes.hittable_list()
	shapes.add_hittable_object(
		&world,
		shapes.Sphere{center = vector.point3(0, 0, -1), radius = 0.5},
	)
	shapes.add_hittable_object(
		&world,
		shapes.Sphere{center = vector.point3(0, -100.5, -1), radius = 100},
	)

	// Camera
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (cast(f64)image_width / cast(f64)image_height)
	camera_center := vector.point3(0, 0, 0)

	// Calculate the vectors across the horizontal and down the
	// vertical viewport edges
	viewport_u := vector.vec3(viewport_width, 0, 0)
	viewport_v := vector.vec3(0, -viewport_height, 0)

	// Calculate the horizontal and vertical delta vectors
	// from pixel to pixel
	pixel_delta_u := vector.div(viewport_u, cast(f64)image_width)
	pixel_delta_v := vector.div(viewport_v, cast(f64)image_height)

	// Calculate the location of the upper left panel
	viewport_upper_left := vector.sub(
		vector.sub(
			vector.sub(camera_center, vector.vec3(0, 0, cast(f64)focal_length)),
			vector.div(viewport_u, cast(f64)2),
		),
		vector.div(viewport_v, cast(f64)2),
	)


	// Renderer
	file, open_err := os.open("image.ppm", os.O_WRONLY | os.O_CREATE | os.O_TRUNC)

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

	pixel00_loc := vector.add(
		viewport_upper_left,
		vector.mul_scalar(vector.add(pixel_delta_u, pixel_delta_v), 0.5),
	)
	pixel_count := image_width * image_height
	pixels := make([]vector.Vec3, pixel_count)
	defer delete(pixels)

	jobs: [THREAD_COUNT]RenderJob
	threads: [THREAD_COUNT]^thread.Thread

	rows_per_thread := image_height / THREAD_COUNT

	for thread_index := 0; thread_index < THREAD_COUNT; thread_index += 1 {
		start_y := thread_index * rows_per_thread
		end_y := start_y + rows_per_thread

		// Last thread takes any remainder
		if thread_index == THREAD_COUNT - 1 {
			end_y = image_height
		}

		jobs[thread_index] = RenderJob {
			start_y       = start_y,
			end_y         = end_y,
			image_width   = image_width,
			pixels        = pixels,
			pixel00_loc   = pixel00_loc,
			pixel_delta_u = pixel_delta_u,
			pixel_delta_v = pixel_delta_v,
			camera_center = camera_center,
			world         = &world,
		}

		threads[thread_index] = thread.create_and_start_with_data(&jobs[thread_index], render_rows)
	}

	for t in threads {
		thread.join(t)
	}

	for t in threads {
		thread.destroy(t)
	}

	for j := 0; j < image_height; j += 1 {
		fmt.print("\rScanlines remaining: ", image_height - j, " ")
		for i := 0; i < image_width; i += 1 {
			index := j * image_width + i
			render.write_color(file, pixels[index])
		}
	}

	fmt.println("\rDone.                 ")
}

RenderJob :: struct {
	start_y:       int,
	end_y:         int,
	image_width:   int,
	pixels:        []vector.Vec3,
	pixel00_loc:   vector.Point3,
	pixel_delta_u: vector.Vec3,
	pixel_delta_v: vector.Vec3,
	camera_center: vector.Point3,
	world:         ^shapes.HittableList,
}

render_rows :: proc(data: rawptr) {
	job := cast(^RenderJob)data

	for j := job.start_y; j < job.end_y; j += 1 {
		for i := 0; i < job.image_width; i += 1 {
			pixel_center := vector.add(
				job.pixel00_loc,
				vector.add(
					vector.mul_scalar(job.pixel_delta_u, cast(f64)i),
					vector.mul_scalar(job.pixel_delta_v, cast(f64)j),
				),
			)

			ray_direction := vector.sub(pixel_center, job.camera_center)

			r := render.ray(job.camera_center, ray_direction)

			pixel_color := ray_color(r, job.world^)

			index := j * job.image_width + i
			job.pixels[index] = pixel_color
		}
	}
}
