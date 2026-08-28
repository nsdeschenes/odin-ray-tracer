package main

import geometry "./raytracer/geometry"
import render "./raytracer/render"
import scene "./raytracer/scene"

main :: proc() {
	// World
	world := scene.hittable_list()

	material_ground := scene.Material {
		data = scene.lambertian(geometry.color(0.8, 0.8, 0.0)),
	}
	material_center := scene.Material {
		data = scene.lambertian(geometry.color(0.1, 0.2, 0.5)),
	}
	material_left := scene.Material {
		data = scene.dielectric(1.00 / 1.33),
	}
	material_right := scene.Material {
		data = scene.metal(geometry.color(0.8, 0.6, 0.2), 1.0),
	}

	scene.add_hittable_object(
		&world,
		scene.sphere(geometry.point3(0.0, -100.5, -1.0), 100.0, material_ground),
	)
	scene.add_hittable_object(
		&world,
		scene.sphere(geometry.point3(0.0, 0.0, -1.2), 0.5, material_center),
	)
	scene.add_hittable_object(
		&world,
		scene.sphere(geometry.point3(-1.0, 0.0, -1.0), 0.5, material_left),
	)
	scene.add_hittable_object(
		&world,
		scene.sphere(geometry.point3(1.0, 0.0, -1.0), 0.5, material_right),
	)

	aspect_ratio := 16.0 / 9.0
	image_width := 400
	samples_per_pixel := 100
	max_depth := 50
	cam := render.initialize(aspect_ratio, image_width, samples_per_pixel, max_depth)

	render.render(cam, &world)
}
