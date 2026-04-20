const std = @import("std");
pub const Size = struct {
    width: usize,
    height: usize,

    pub fn init(width: usize, height: usize) Size {
        return Size{
            .width = width,
            .height = height,
        };
    }
};
