package scene

import geometry "../geometry"
import scene "../scene"
import "core:slice"

BVH_Node :: struct {
	left:  ^Hittable,
	right: ^Hittable,
	bbox:  AABB,
}

@(private = "file")
bvh_node_hittable_list :: proc(list: ^HittableList) -> BVH_Node {
	return bvh_node_dynamic_list(list.objects[:], 0, len(list.objects[:]))
}

@(private = "file")
bvh_node_dynamic_list :: proc(objects: []Hittable, start: int, end: int) -> BVH_Node {
	// Build the bounding box of the span of source objects.
	bbox := aabb()
	for object_index := start; object_index < end; object_index += 1 {
		bbox = aabb(bbox, bounding_box(objects[object_index]))
	}

	axis := longest_axis(bbox)

	comparator := box_x_compare

	if axis == 1 {
		comparator = box_y_compare
	} else if axis == 2 {
		comparator = box_z_compare
	}

	object_span := end - start


	left := new(Hittable)
	right := new(Hittable)

	if object_span == 1 {
		left^ = objects[start]
		right^ = objects[start]
	} else if object_span == 2 {
		left^ = objects[start]
		right^ = objects[start + 1]
	} else {
		slice.sort_by(objects[start:end], comparator)

		mid := start + object_span / 2

		left^ = bvh_node(objects, start, mid)
		right^ = bvh_node(objects, mid, end)
	}

	return BVH_Node{left = left, right = right, bbox = bbox}
}

bvh_node :: proc {
	bvh_node_hittable_list,
	bvh_node_dynamic_list,
}

@(private)
hit_bvh_node :: proc(
	b: ^BVH_Node,
	r: geometry.Ray,
	ray_t: ^geometry.Interval,
	rec: ^scene.HitRecord,
) -> bool {
	bbox_ray_t := ray_t^

	if !hit(&b.bbox, r, ray_t) {
		return false
	}

	hit_left := hit(b.left, r, ray_t, rec)

	right_ray_t := geometry.interval(bbox_ray_t.min, hit_left ? rec.t : bbox_ray_t.max)
	hit_right := hit(b.right, r, &right_ray_t, rec)

	return hit_left || hit_right
}

box_compare :: proc(a, b: Hittable, axis_index: int) -> bool {
	a_axis_interval := axis_interval(bounding_box(a), axis_index)
	b_axis_interval := axis_interval(bounding_box(b), axis_index)
	return a_axis_interval.min < b_axis_interval.min
}

box_x_compare :: proc(a, b: Hittable) -> bool {
	return box_compare(a, b, 0)
}

box_y_compare :: proc(a, b: Hittable) -> bool {
	return box_compare(a, b, 1)
}

box_z_compare :: proc(a, b: Hittable) -> bool {
	return box_compare(a, b, 2)
}
