package tests

import "core:testing"
import dxt_decoder ".."

@(test)
test_decode_dxt1 :: proc(t: ^testing.T) {
    data := make([]u8, 8)
    result, err := dxt_decoder.decode(data, 4, 4, .DXT1)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
}

@(test)
test_decode_dxt3 :: proc(t: ^testing.T) {
    data := make([]u8, 16)
    result, err := dxt_decoder.decode(data, 4, 4, .DXT3)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
}

@(test)
test_decode_dxt5 :: proc(t: ^testing.T) {
    data := make([]u8, 16)
    result, err := dxt_decoder.decode(data, 4, 4, .DXT5)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
}

@(test)
test_dxt1_solid_color :: proc(t: ^testing.T) {
    data := [8]u8{0x1f, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00}
    result, err := dxt_decoder.decode(data[:], 4, 4, .DXT1)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
    for i in 0..<16 {
        r := result[i*4+0]
        g := result[i*4+1]
        b := result[i*4+2]
        a := result[i*4+3]
        testing.expect_value(t, r, 0)
        testing.expect_value(t, g, 0)
        testing.expect_value(t, b, 255)
        testing.expect_value(t, a, 255)
    }
}

@(test)
test_dxt3_alpha_all_zero :: proc(t: ^testing.T) {
    data := [16]u8{
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    }
    result, err := dxt_decoder.decode(data[:], 4, 4, .DXT3)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
    for i in 0..<16 {
        a := result[i*4+3]
        testing.expect_value(t, a, 0)
    }
}

@(test)
test_dxt3_alpha_all_opaque :: proc(t: ^testing.T) {
    data := [16]u8{
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0x00, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    }
    result, err := dxt_decoder.decode(data[:], 4, 4, .DXT3)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
    for i in 0..<16 {
        a := result[i*4+3]
        testing.expect_value(t, a, 255)
    }
}

@(test)
test_dxt5_alpha_all_zero_rgb_check_first_pixel :: proc(t: ^testing.T) {
    data := [16]u8{
        0x00, 0x00, // alpha0=0, alpha1=0
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // alpha indices all 0
        0x1f, 0x00, // color0: 0x001f (B=31,G=0,R=0) => (0,0,255)
        0x1f, 0x00, // color1: 0x001f (same)
        0x00, 0x00, 0x00, 0x00 // color indices all 0
    }
    result, err := dxt_decoder.decode(data[:], 4, 4, .DXT5)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
    for i in 0..<16 {
        a := result[i*4+3]
        testing.expect_value(t, a, 0)
    }
    r := result[0]
    g := result[1]
    b := result[2]
    testing.expect_value(t, r, 0)
    testing.expect_value(t, g, 0)
    testing.expect_value(t, b, 255)
}

@(test)
test_dxt5_alpha_all_opaque_rgb_check_first_pixel :: proc(t: ^testing.T) {
    data := [16]u8{
        0xff, 0xff, // alpha0=255, alpha1=255
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // alpha indices all 0
        0x1f, 0x00, // color0: 0x001f (B=31,G=0,R=0) => (0,0,255)
        0x1f, 0x00, // color1: 0x001f (same)
        0x00, 0x00, 0x00, 0x00 // color indices all 0
    }
    result, err := dxt_decoder.decode(data[:], 4, 4, .DXT5)
	defer delete(result)
    testing.expect_value(t, err, nil)
    testing.expect_value(t, len(result), 4 * 4 * 4)
    for i in 0..<16 {
        a := result[i*4+3]
        testing.expect_value(t, a, 255)
    }
    r := result[0]
    g := result[1]
    b := result[2]
    testing.expect_value(t, r, 0)
    testing.expect_value(t, g, 0)
    testing.expect_value(t, b, 255)
}
