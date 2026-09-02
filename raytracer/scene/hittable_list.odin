package scene

import geometry "../geometry"

HittableList :: struct {
	objects: [dynamic]Hittable,
	bbox:    AABB,
}

@(private)
hittable_list_no_data :: proc() -> HittableList {
	return {}
}

@(private)
hittable_list_with_data :: proc(object: Hittable) -> HittableList {
	list := HittableList{}
	add_hittable_object(&list, object)

	return list
}

hittable_list :: proc {
	hittable_list_no_data,
	hittable_list_with_data,
}

add_hittable_object :: proc(list: ^HittableList, hittable: Hittable) {
	append(&list.objects, hittable)
	list.bbox = aabb(list.bbox, bounding_box(hittable,))
}

clear_hittable_list :: proc(list: ^HittableList) {
	clear(&list.objects)
}

@(private)
hit_hittable_list :: proc(
	list: ^HittableList,
	ray: geometry.Ray,
	ray_t: ^geometry.Interval,
	rec: ^HitRecord,
) -> bool {
	temp_rec: HitRecord
	hit_anything := false
	closest_so_far := ray_t.max
    candidate_ray_t := geometry.interval(ray_t^.min, closest_so_far)

	for &object in list.objects {
		if (hit(&object, ray, &candidate_ray_t, &temp_rec)) {
			hit_anything = true
			closest_so_far = temp_rec.t
			rec^ = temp_rec
		}
	}

	return hit_anything
}
