package dxt_decoder

DxtDecodeError :: enum {
    OK,
    UNKNOWN_DXT_FORMAT
}

DxtFormat :: enum {
	DXT1,
	DXT2,
	DXT3,
	DXT4,
	DXT5,
}

decode :: proc(image_data: []u8, width: int, height: int, format: DxtFormat, allocator := context.allocator) -> ([]u8, DxtDecodeError) {
	switch format {
		case .DXT1:
			return decode_bc1(image_data, width, height, allocator), nil
		case .DXT2:
			return decode_bc2(image_data, width, height, true, allocator), nil
		case .DXT3:
			return decode_bc2(image_data, width, height, false, allocator), nil
		case .DXT4:
			return decode_bc3(image_data, width, height, true, allocator), nil
		case .DXT5:
			return decode_bc3(image_data, width, height, false, allocator), nil
	}
	return {}, .UNKNOWN_DXT_FORMAT
}
