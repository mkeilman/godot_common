class_name CollectionUtils

static var rnd = RandomNumberGenerator.new()

static func remove_all(to_erase: Array, from: Array) -> void:
	var indices: Array[int]
	for item in to_erase:
		if from.has(item):
			indices.append(from.find(item))
	indices.sort()
	indices.reverse()
	for idx in indices:
		from.remove_at(idx)

static func random_indices_for_array_of_size(size: int) -> Array[int]:
	var arr: Array[int]
	arr.assign(range(size))
	arr.shuffle()
	return arr
