package main

import geometry "./raytracer/geometry"
import render "./raytracer/render"
import scene "./raytracer/scene"
import utils "./raytracer/utils"

main :: proc() {
	// World
	world := scene.hittable_list()

	c1 := geometry.color(0.2, 0.3, 0.1)
	c2 := geometry.color(0.9, 0.9, 0.9)
	checker := new(scene.Texture)
	checker^ = scene.checker_texture(0.32, &c1, &c2)

	material_ground := scene.Material {
		data = scene.lambertian(checker),
	}
	scene.add_hittable_object(
		&world,
		scene.sphere(geometry.point3(0, -1000, 0), 1000, material_ground),
	)

	for a: f64 = -11; a < 11; a += 1 {
		for b: f64 = -11; b < 11; b += 1 {
			choose_mat := utils.random_double()
			center := geometry.point3(
				a + 0.9 * utils.random_double(),
				0.2,
				b + 0.9 * utils.random_double(),
			)

			if (geometry.length(geometry.sub(center, geometry.point3(4, 0.2, 0)))) > 0.9 {
				if choose_mat > 0.8 {
					// diffuse
					albedo := geometry.mul_vec(geometry.random(), geometry.random())
					sphere_material := scene.Material {
						data = scene.lambertian(albedo),
					}
					center2 := geometry.add(
						center,
						geometry.vec3(0, utils.random_double(0, 0.5), 0),
					)
					scene.add_hittable_object(
						&world,
						scene.sphere(center, center2, 0.2, sphere_material),
					)
				} else if choose_mat < 0.95 {
					// metal
					albedo := geometry.random(0.5, 1)
					fuzz := utils.random_double(0, 0.5)
					sphere_material := scene.Material {
						data = scene.metal(albedo, fuzz),
					}
					scene.add_hittable_object(&world, scene.sphere(center, 0.2, sphere_material))
				} else {
					// glass
					sphere_material := scene.Material {
						data = scene.dielectric(1.5),
					}
					scene.add_hittable_object(&world, scene.sphere(center, 0.2, sphere_material))
				}

			}
		}
	}

	material_1 := scene.Material {
		data = scene.dielectric(1.5),
	}
	scene.add_hittable_object(&world, scene.sphere(geometry.point3(0, 1, 0), 1, material_1))

	material_2 := scene.Material {
		data = scene.lambertian(geometry.color(0.4, 0.2, 0.1)),
	}
	scene.add_hittable_object(&world, scene.sphere(geometry.point3(-4, 1, 0), 1, material_2))

	material_3 := scene.Material {
		data = scene.metal(geometry.color(0.7, 0.6, 0.5), 0),
	}
	scene.add_hittable_object(&world, scene.sphere(geometry.point3(4, 1, 0), 1.0, material_3))

	world = scene.hittable_list(scene.bvh_node(&world))

	aspect_ratio := 16.0 / 9.0
	image_width := 400
	samples_per_pixel := 100
	max_depth := 50

	vfov := 20
	lookfrom := geometry.point3(12, 2, 3)
	lookat := geometry.point3(0, 0, 0)
	vup := geometry.vec3(0, 1, 0)

	defocus_angle := 0.6
	focus_dist := 10.0

	cam := render.initialize(
		aspect_ratio,
		image_width,
		samples_per_pixel,
		max_depth,
		vfov,
		lookfrom,
		lookat,
		vup,
		defocus_angle,
		focus_dist,
	)

	render.render(&cam, &world)
}
