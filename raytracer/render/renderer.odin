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
ROWS_PER_JOB :: 8

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

	// Create worker pool
	pool: thread.Pool
	thread.pool_init(&pool, context.allocator, THREAD_COUNT)
	defer thread.pool_destroy(&pool)

	thread.pool_start(&pool)

	// Create jobs
	job_count := (camera.image_height + ROWS_PER_JOB - 1) / ROWS_PER_JOB
	jobs := make([]RenderJob, job_count)

    fmt.print("\rRunning thread pool")
	for job_index := 0; job_index < job_count; job_index += 1 {
		start_y := job_index * ROWS_PER_JOB
		end_y := min(start_y + ROWS_PER_JOB, camera.image_height)

		jobs[job_index] = RenderJob {
			start_y = start_y,
			end_y   = end_y,
			pixels  = pixels,
			world   = world,
			camera  = camera,
		}

		thread.pool_add_task(&pool, context.allocator, render_rows, &jobs[job_index], job_index)
	}

	// Wait for all jobs
	thread.pool_finish(&pool)
    fmt.print("\rPool finished.")

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
render_rows :: proc(task: thread.Task) {
	job := cast(^RenderJob)task.data

	for j := job.start_y; j < job.end_y; j += 1 {
		for i := 0; i < job.camera.image_width; i += 1 {
			pixel_color := geometry.color(0, 0, 0)
			for sample := 0; sample < job.camera.samples_per_pixel; sample += 1 {
				r := get_ray(job.camera, i, j)
				geometry.add_assign(&pixel_color, ray_color(r, job.camera.max_depth, job.world))
			}

			index := j * job.camera.image_width + i
			job.pixels[index] = geometry.mul_scalar(pixel_color, job.camera.pixel_samples_scale)
		}
	}
}

@(private)
ray_color :: proc(ray: geometry.Ray, depth: int, world: ^scene.HittableList) -> geometry.Color {
	// If we've exceeded the ray bounce limit, no more light is gathered.
	if depth <= 0 {
		return geometry.color(0, 0, 0)
	}

	rec: scene.HitRecord
	if scene.hit(world, ray, geometry.interval(0.001, math.INF_F64), &rec) {
		scattered: geometry.Ray
		attenuation: geometry.Color
		if scene.scatter(rec.mat, ray, &rec, &attenuation, &scattered) {
			return geometry.mul_vec(attenuation, ray_color(scattered, depth - 1, world))
		}
		return geometry.color(0, 0, 0)
	}

	unit_direction := geometry.unit_vector(ray.dir)
	a := 0.5 * (geometry.y(unit_direction) + 1.0)

	color_a := geometry.mul_scalar(geometry.color(1, 1, 1), (1 - a))
	color_b := geometry.mul_scalar(geometry.color(0.5, 0.7, 1), a)
	return geometry.add(color_a, color_b)
}
