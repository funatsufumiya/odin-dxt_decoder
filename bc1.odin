package dxt_decoder

decode_bc1 :: proc(image_data: []u8, width: int, height: int, allocator := context.allocator) -> []u8 {
	rgba_len := width * height * 4
	rgba := make([]u8, rgba_len, allocator)
	height_4 := height / 4
	width_4 := width / 4
	offset := 0

	for h in 0..<height_4 {
		for w in 0..<width_4 {
			c0 := get_u16_le(image_data, offset)
			c1 := get_u16_le(image_data, offset + 2)
			color_values := interpolate_color_values(c0, c1, true, allocator)
			defer delete(color_values)
			color_indices := get_u32_le(image_data, offset + 4)

			for y in 0..<4 {
				for x in 0..<4 {
					pixel_index := (3 - x) + (y * 4)
					rgba_index := (h * 4 + 3 - y) * width * 4 + (w * 4 + x) * 4
					color_index := (color_indices >> uint(2 * (15 - pixel_index))) & 0x03
					for i in 0..<4 {
						rgba[rgba_index + i] = color_values[int(color_index * 4) + i]
					}
				}
			}
			offset += 8
		}
	}
	return rgba
}