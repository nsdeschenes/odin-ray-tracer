package scene

import geometry "../geometry"
import scene "../scene"

BVH_Node :: struct {
	left:  ^Hittable,
	right: ^Hittable,
	bbox:  AABB,
}

@(private = "file")
bvh_node_hittable_list :: proc(list: ^HittableList) -> BVH_Node {
	return bvh_node_dynamic_list(list.objects[:], 0, size_of(list.objects[:]))
}

@(private = "file")
bvh_node_dynamic_list :: proc(objects: []Hittable, start: int, end: int) -> BVH_Node {
	return BVH_Node{}
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
