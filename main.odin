package main

import geometry "./raytracer/geometry"
import render "./raytracer/render"
import scene "./raytracer/scene"

main :: proc() {
	// World
	world := scene.hittable_list()
	scene.add_hittable_object(
		&world,
		scene.Sphere{center = geometry.point3(0, 0, -1), radius = 0.5},
	)
	scene.add_hittable_object(
		&world,
		scene.Sphere{center = geometry.point3(0, -100.5, -1), radius = 100},
	)

	aspect_ratio := 16.0 / 9.0
	image_width := 400
	samples_per_pixel := 100
	cam := render.initialize(aspect_ratio, image_width, samples_per_pixel)

	render.render(cam, &world)
}
