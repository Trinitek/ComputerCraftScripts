
---@meta

colors = {
    white = 1,
    orange = 2,
    magenta = 4,
    lightBlue = 8,
    yellow = 16,
    lime = 32,
    pink = 64,
    gray = 128,
    lightGray = 256,
    cyan = 512,
    purple = 1024,
    blue = 2048,
    brown = 4096,
    green = 8192,
    red = 16384,
    black = 32768,

    ---Combines a set of colors (or sets of colors) inot a larger set. Useful for Bundled Cables.
    ---@param ... number The colors to combine.
    ---@return number color The union of the color sets.
    combine = function(...) end,

    ---Removes one or more colors (or sets of colors) from an initial set. Useful for Bundled Cables.
    ---Each paramter beyond the first may be a single color or may be a set of colors.
    ---In the latter case, all colors in the set are removed from the original set.
    ---@param colors number The color from which to subtract.
    ---@param ... number The colors to subtract.
    ---@return number color The resulting color.
    subtract = function(colors, ...) end,

    ---Tests whether `color` is contained within `colors`. Useful for Bundled Cables.
    ---@param colors number A color or color set. To combine colors, see `combine`.
    ---@param color number A color or set of colors that `colors` should contain.
    ---@return boolean containsAll True if `colors` contains all colors within `color`.
    test = function(colors, color) end,

    ---Combine a three-color RGB value into one hexadecimal representation.
    ---@param r number The red channel, between 0 and 1 inclusive.
    ---@param g number The green channel, between 0 and 1 inclusive.
    ---@param b number The blue channel, between 0 and 1 inclusive.
    packRGB = function(r, g, b) end,

    ---Separate a hexadecimal RGB color into its three constitutent channels.
    ---Example: `colors.unpackRGB(0xb23399)` -> `0.7, 0.2, 0.6`
    ---@param rgb number The combined hexadecimal color.
    ---@return number r The red channel, between 0 and 1 inclusive.
    ---@return number g The green channel, between 0 and 1 inclusive.
    ---@return number b The blue channel, between 0 and 1 inclusive.
    unpackRGB = function(rgb) end,

    ---Converts the given color to a paint/blit hex character (0-9a-f).
    ---This is equivalent to converting `floor(log_2(color))` to hexadecimal.
    ---@param color number The color to convert.
    ---@return string hexCode The blit hex code of the color.
    toBlit = function(color) end
}
