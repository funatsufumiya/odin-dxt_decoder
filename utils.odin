package dxt_decoder

lerp :: proc(v1: f32, v2: f32, r: f32) -> f32 {
	return v1 * (1.0 - r) + v2 * r
}

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

get_u16_le :: proc(data: []u8, offset: int) -> u16 {
	return u16(data[offset]) | (u16(data[offset+1]) << 8)
}

get_u32_le :: proc(data: []u8, offset: int) -> u32 {
	return u32(data[offset]) | (u32(data[offset+1]) << 8) | (u32(data[offset+2]) << 16) | (u32(data[offset+3]) << 24)
}

@(private)
append_color :: proc(buf: ^[dynamic]u8, col: Color){
    append(buf, col.r)
    append(buf, col.g)
    append(buf, col.b)
}

interpolate_color_values :: proc (first_val: u16, second_val: u16, is_dxt1: bool, allocator := context.allocator) -> []u8 {
	first_color := convert_565_to_rgb(first_val)
	second_color := convert_565_to_rgb(second_val)
	color_values := new([dynamic]u8, allocator)
	append_color(color_values, first_color)
	append(color_values, 255)
	append_color(color_values, second_color)
	append(color_values, 255)

	if is_dxt1 && first_val <= second_val {
		append(color_values, u8((first_color.r + second_color.r) / 2))
		append(color_values, u8((first_color.g + second_color.g) / 2))
		append(color_values, u8((first_color.b + second_color.b) / 2))
		append(color_values, 255)
        lst : [4]u8
        lst = {u8(0), u8(0), u8(0), u8(0)}
        for v in lst {
		    append(color_values, v)
        }
	} else {
		append(color_values, u8(lerp(f32(first_color.r), f32(second_color.r), 1.0/3.0)))
		append(color_values, u8(lerp(f32(first_color.g), f32(second_color.g), 1.0/3.0)))
		append(color_values, u8(lerp(f32(first_color.b), f32(second_color.b), 1.0/3.0)))
		append(color_values, 255)
		append(color_values, u8(lerp(f32(first_color.r), f32(second_color.r), 2.0/3.0)))
		append(color_values, u8(lerp(f32(first_color.g), f32(second_color.g), 2.0/3.0)))
		append(color_values, u8(lerp(f32(first_color.b), f32(second_color.b), 2.0/3.0)))
		append(color_values, 255)
	}
	return color_values[:]
}
