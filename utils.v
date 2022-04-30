module bio


pub struct RangeInt {
	start int
	stop int
	step int = 1
}

// pub struct RangeFloat {
// 	start f32 = 1.0
// 	stop f32 
// 	step f32 = 1.0
// }


pub fn int_range(range RangeInt) []int {
	mut iter_arr := []int{}
	if range.step == 0 {
		panic('Range Error: step cannot be zero.')
	}
	if range.start > range.stop {
		if range.step <= -1 {
			for i := range.start; i > range.stop; i += range.step {
				iter_arr << i
			}
		}
	}
	for i := range.start; i < range.stop; i += range.step {
		iter_arr << i
	}
	return iter_arr
}