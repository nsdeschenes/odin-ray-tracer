package render

import geometry "../geometry"
import scene "../scene"
import "core:fmt"
import "core:math"
import "core:os"
import "core:thread"

@(private)
THREAD_COUNT :: 8

@(private)
RenderJob :: struct {
	start_y: int,
	end_y:   int,
	pixels:  []geometry.Vec3,
	world:   ^scene.HittableList,
	camera:  Camera,
}

render :: proc(camera: Camera, world: ^scene.HittableList) {
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
		fmt.tprintf("%d", camera.image_width),
		" ",
		fmt.tprintf("%d", camera.image_height),
		"\n255\n",
	)

	if header_err != nil {
		fmt.println("Failed to write file header info")
		return
	}

	pixel_count := camera.image_width * camera.image_height
	pixels := make([]geometry.Vec3, pixel_count)
	defer delete(pixels)

	jobs: [THREAD_COUNT]RenderJob
	threads: [THREAD_COUNT]^thread.Thread

	rows_per_thread := camera.image_height / THREAD_COUNT

	for thread_index := 0; thread_index < THREAD_COUNT; thread_index += 1 {
		start_y := thread_index * rows_per_thread
		end_y := start_y + rows_per_thread

		// Last thread takes any remainder
		if thread_index == THREAD_COUNT - 1 {
			end_y = camera.image_height
		}

		jobs[thread_index] = RenderJob {
			start_y = start_y,
			end_y   = end_y,
			pixels  = pixels,
			world   = world,
			camera  = camera,
		}

		threads[thread_index] = thread.create_and_start_with_data(&jobs[thread_index], render_rows)
	}

	for t in threads {
		thread.join(t)
	}

	for t in threads {
		thread.destroy(t)
	}

	for j := 0; j < camera.image_height; j += 1 {
		fmt.print("\rScanlines remaining: ", camera.image_height - j, " ")
		for i := 0; i < camera.image_width; i += 1 {
			index := j * camera.image_width + i
			write_color(file, pixels[index])
		}
	}

	fmt.println("\rDone.                 ")
}

@(private)
render_rows :: proc(data: rawptr) {
	job := cast(^RenderJob)data

	for j := job.start_y; j < job.end_y; j += 1 {
		for i := 0; i < job.camera.image_width; i += 1 {
			pixel_center := geometry.add(
				job.camera.pixel00_loc,
				geometry.add(
					geometry.mul_scalar(job.camera.pixel_delta_u, cast(f64)i),
					geometry.mul_scalar(job.camera.pixel_delta_v, cast(f64)j),
				),
			)

			ray_direction := geometry.sub(pixel_center, job.camera.center)

			pixel_color := geometry.color(0, 0, 0)
			for sample := 0; sample < job.camera.samples_per_pixel; sample += 1 {
				r := get_ray(job.camera, i, j)
				geometry.add_assign(&pixel_color, ray_color(r, job.world^))
			}

			index := j * job.camera.image_width + i
			job.pixels[index] = geometry.mul_scalar(pixel_color, job.camera.pixel_samples_scale)
		}
	}
}

@(private)
ray_color :: proc(ray: geometry.Ray, world: scene.HittableList) -> geometry.Color {
	rec: scene.HitRecord
	if scene.hit(world, ray, geometry.interval(0, math.INF_F64), &rec) {
		return geometry.mul_scalar(geometry.add(geometry.color(1, 1, 1), rec.normal), 0.5)
	}

	unit_direction := geometry.unit_vector(ray.dir)
	a := 0.5 * (geometry.y(unit_direction) + 1.0)

	color_a := geometry.mul_scalar(geometry.color(1, 1, 1), (1 - a))
	color_b := geometry.mul_scalar(geometry.color(0.5, 0.7, 1), a)
	return geometry.add(color_a, color_b)
}
