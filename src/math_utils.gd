class_name MathUtils

static var rnd = RandomNumberGenerator.new()

static func poisson(lambda: float) -> float:
	var x: float = 0.0
	var p: float = exp(-lambda)
	var s: float = p
	var u: float = rnd.randf()
	while true:
		x += 1.0
		p *= lambda / x
		s += p
		if u <= s:
			break
	return x

# enums are passed as Dictionaries
static func rand_enum(enum_type: Variant, exclude_vals: Array[Variant]=[]) -> Variant:
	var v: Array[Variant] = enum_type.values()
	if exclude_vals.is_empty():
		return rand_item(v)
	return rand_item(v.filter(func (x: Variant): return ! exclude_vals.has(x)))

static func rand_int_below(high: int) -> int:
	return rand_int(0, high)

static func rand_int(low: int = 0, high: int = 100) -> int:
	return rnd.randi_range(low, high)

static func rand_item(list: Array[Variant]) -> Variant:
	return list.pick_random()

static func rand_hex_color() -> String:
	var DIGITS := "0123456789abcdef".split()
	var h: String = "#"
	for i in range(1, 7):
		h += rand_item(DIGITS)
	return h

# All distribution functions should take varargs, where the 1st parameter
# is understood to be the input value
static func distribution(f: Callable, dist_params: Array) -> float:
	#DebugUtils.debug_println("CALLING {f} WITH {dist_params}".format({"f": f, "dist_params": dist_params}))
	return f.callv(dist_params)

#static func gaussian(x: float, mean_stddev: Array) -> float:
static func gaussian(...dist_params) -> float:
	
	var x: float = dist_params[0]
	var mean: float = dist_params[1]
	var stddev: float = dist_params[2]
	
	var c: float = 1.0 / sqrt(2.0 * PI * stddev * stddev)
	var e: float = (x - mean) / stddev
	return c * exp(-0.5 * e * e)

#static func uniform(_x: float, _mean_stddev: Array) -> float:
static func uniform(..._dist_params) -> float:
	return 1.0

static func box_mueller_gaussian(mean_stddev: Array[float]) -> float:
	var mean: float = mean_stddev[0]
	var stddev: float = mean_stddev[1]
	var u1: float = 1.0 - rnd.randf()
	var u2: float = 1.0 - rnd.randf()
	return mean + stddev * sqrt(-2.0 * log(u1)) * sin(2.0 * PI * u2)

# We will use "get" for single values and "sample" for arrays of values
static func get_from_distribution(dist: Callable, min_val: float, max_val: float, num_bins: int, dist_params: Array[float]=[]) -> float:
	return get_from_cumulative(cumulative_distribution(dist, min_val, max_val, num_bins, dist_params), min_val, max_val)

static func get_from_cumulative(cumulative: Array[float], min_val: float, max_val: float) -> float:
	var step: float = abs((max_val - min_val) / cumulative.size())

	var num_tries: int = 0
	const max_tries: int = 10
	while num_tries < max_tries:
		# var 0 - 1
		var x: float = rnd.randf()
		for i in range(cumulative.size() - 1):
			if x >= cumulative[i] && x <= cumulative[i + 1]:
				return min_val + float(i) * step
		# try again
		num_tries += 1
		#DebugUtils.debug_println("TRY NUM {num_tries} LAST TRY {x}".format({"num_tries": num_tries, "x": x}))
	#DebugUtils.debug_println("NO MORE TRIES!!")
	return 0.0

static func sample_cumulative(cumulative: Array[float], min_val: float, max_val: float, num_samples: int) -> Dictionary:
	var bins: Dictionary = {}

	for i in range(1, num_samples + 1):
		var r: float = get_from_cumulative(cumulative, min_val, max_val)
		if ! bins.has(r):
			bins[r] = 0
		bins[r] += 1
	return bins

static func sample_cumulative_from(dist: Callable, min_val: float, max_val: float, num_bins: int, num_samples: int, dist_params: Array[float]) -> Dictionary:
	#DebugUtils.debug_println("SAMPLE CUM PARAMS {dist_params} {n}".format({"dist_params": dist_params, "n": dist_params.size()})) 
	return sample_cumulative(
		cumulative_distribution(dist, min_val, max_val, num_bins, dist_params),
		min_val,
		max_val,
		num_samples
	)

static func cumulative_distribution(dist: Callable, min_val: float, max_val: float, num_bins: int, dist_params: Array[float]) -> Array[float]:
	var cumulative: Array[float] = []
	#DebugUtils.debug_println("CUMULATIVE N {num_bins}".format({"num_bins": num_bins}))
	cumulative.resize(num_bins)
	var step: float = abs((max_val - min_val) / num_bins)

	# value of the distribution in the 1st bin
	#cumulative[0] = dist.call(min_val, dist_params)
	cumulative[0] = distribution(dist, [min_val] + dist_params)
	#DebugUtils.debug_println("CUMULATIVE INIT VAL {c0}".format({"c0": cumulative[0]}))

	for i in range(1, num_bins):
		var next: float = min_val + i * step
		#cumulative[i] = cumulative[i - 1] + dist.call(next, dist_params)
		cumulative[i] = cumulative[i - 1] + distribution(dist, [next] + dist_params)
		#DebugUtils.debug_println("CUMULATIVE {i} VAL {ci}".format({"i": i, "ci": cumulative[i]}))

	# another loop to normalize by final bin
	for i in range(num_bins):
		cumulative[i] /= cumulative[num_bins - 1]

	#DebugUtils.debug_println("GOT CUMULATIVE {cumulative}".format({"cumulative": cumulative}))
	return cumulative

static func get_from_gaussian(min_val: float, max_val: float, num_bins: int, mean: float, stddev: float) -> float:
	# here a stdDev of 0 means the result is always the mean
	return mean if stddev == 0 else get_from_distribution(gaussian, min_val, max_val, num_bins, [mean, stddev])

static func sample_uniform(min_val: float, max_val: float, num_bins: int) -> float:
	return get_from_distribution(uniform, min_val, max_val, num_bins)
