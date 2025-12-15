package dxt_decoder

@(private)
lerp :: proc(v1: f32, v2: f32, r: f32) -> f32 {
	return v1 * (1.0 - r) + v2 * r
}

@(private)
convert_565_to_rgb :: proc(val: u16) -> Color {
	r := ((val >> 11) & 31)
	g := ((val >> 5) & 63)
	b := (val & 31)

	return Color {
		r = u8(f32(r) * (255.0 / 31.0) + 0.5),
		g = u8(f32(g) * (255.0 / 63.0) + 0.5),
		b = u8(f32(b) * (255.0 / 31.0) + 0.5),
    }
}

@(private)
get_u16_le :: proc(data: []u8, offset: int) -> u16 {
	return u16(data[offset]) | (u16(data[offset+1]) << 8)
}

@(private)
get_u32_le :: proc(data: []u8, offset: int) -> u32 {
	return u32(data[offset]) | (u32(data[offset+1]) << 8) | (u32(data[offset+2]) << 16) | (u32(data[offset+3]) << 24)
}

@(private)
append_color :: proc(buf: ^[dynamic]u8, col: Color){
    append(buf, col.r)
    append(buf, col.g)
    append(buf, col.b)
}

@(private)
extract_bits_from_u16_array :: proc(arr: []u16, shift: int, length: int) -> u32 {
	height := len(arr)
	heightm1 := height - 1
	width := 16
	row_s := shift / width
	row_e := (shift + length - 1) / width
	if row_s == row_e {
		shift_s := uint(shift % width)
		return u32(arr[heightm1 - row_s] >> shift_s) & ((1 << uint(length)) - 1)
	} else {
		shift_s := uint(shift % width)
		shift_e := width - int(shift_s)
		result := (arr[heightm1 - row_s] >> shift_s) & ((1 << uint(length)) - 1)
		result += (arr[heightm1 - row_e] & ((1 << uint(length - shift_e)) - 1)) << uint(shift_e)
		return u32(result)
	}
}

@(private)
interpolate_color_values :: proc (first_val: u16, second_val: u16, is_dxt1: bool, allocator := context.allocator) -> []u8 {
	first_color := convert_565_to_rgb(first_val)
	second_color := convert_565_to_rgb(second_val)
	color_values := make([dynamic]u8, allocator)
	append_color(&color_values, first_color)
	append(&color_values, 255)
	append_color(&color_values, second_color)
	append(&color_values, 255)

	if is_dxt1 && first_val <= second_val {
		append(&color_values, u8((first_color.r + second_color.r) / 2))
		append(&color_values, u8((first_color.g + second_color.g) / 2))
		append(&color_values, u8((first_color.b + second_color.b) / 2))
		append(&color_values, 255)
        lst : [4]u8
        lst = {u8(0), u8(0), u8(0), u8(0)}
        for v in lst {
		    append(&color_values, v)
        }
	} else {
		append(&color_values, u8(lerp(f32(first_color.r), f32(second_color.r), 1.0/3.0)))
		append(&color_values, u8(lerp(f32(first_color.g), f32(second_color.g), 1.0/3.0)))
		append(&color_values, u8(lerp(f32(first_color.b), f32(second_color.b), 1.0/3.0)))
		append(&color_values, 255)
		append(&color_values, u8(lerp(f32(first_color.r), f32(second_color.r), 2.0/3.0)))
		append(&color_values, u8(lerp(f32(first_color.g), f32(second_color.g), 2.0/3.0)))
		append(&color_values, u8(lerp(f32(first_color.b), f32(second_color.b), 2.0/3.0)))
		append(&color_values, 255)
	}
	return color_values[:]
}

@(private)
interpolate_alpha_values :: proc(first_val: u8, second_val: u8, allocator := context.allocator) -> []u8 {
    alpha_values := make([dynamic]u8, allocator)
	append(&alpha_values, first_val)
	append(&alpha_values, second_val)
	if first_val > second_val {
		for i in 1..<7 {
			append(&alpha_values, u8(f32(first_val) * (1.0 - f32(i)/7.0) + f32(second_val) * (f32(i)/7.0)))
		}
	} else {
		for i in 1..<5 {
			append(&alpha_values, u8(f32(first_val) * (1.0 - f32(i)/5.0) + f32(second_val) * (f32(i)/5.0)))
		}
		append(&alpha_values, 0)
		append(&alpha_values, 255)
	}
	return alpha_values[:]
}

@(private)
multiply :: proc(component: u8, multiplier: f32) -> u8 {
	if multiplier == 0.0 {
		return 0
	}
	return u8(f32(component) * multiplier + 0.5)
}
