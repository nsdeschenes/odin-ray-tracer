package shapes

import render "../render"

HittableList :: struct {
	objects: [dynamic]Hittable,
}

hittable_list :: proc() -> HittableList {
	return {}
}

hittable_list_with_data :: proc(object: Hittable) -> HittableList {
	list := HittableList{}
	add_hittable_object(&list, object)

	return list
}

add_hittable_object :: proc(list: ^HittableList, hittable: Hittable) {
	append(&list.objects, hittable)
}

clear_hittable_list :: proc(list: ^HittableList) {
	clear(&list.objects)
}

hit_hittable_list :: proc(
	list: HittableList,
	ray: render.Ray,
	ray_tmin: f64,
	ray_tmax: f64,
	rec: ^HitRecord,
) -> bool {
	temp_rec: HitRecord
	hit_anything := false
	closest_so_far := ray_tmax

	for object in list.objects {
		if (hit(object, ray, ray_tmin, closest_so_far, &temp_rec)) {
			hit_anything = false
			closest_so_far = temp_rec.t
			rec^ = temp_rec
		}
	}

	return hit_anything
}
