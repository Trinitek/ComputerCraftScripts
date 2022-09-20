
---@meta

---Represents a terminal surface to which text and colors can be drawn.
---The original name for this type in the CC:Tweaked documentation is "Redirect";
---see https://tweaked.cc/module/term.html#ty:Redirect.
---@class CCTermSurface
CCTermSurface = {
    ---Writes text at the current cursor position, moving the cursor to the end of the text.
    ---Unlike `print`, this does not wrap the text; it simply copies the text to the current terminal line.
    ---@param text any
    write = function(text) end,

    ---Moves all positions up or down by the given number of lines.
    ---@param y number The number of lines by which to move. Can be negative.
    scroll = function(y) end,

    ---Gets the position of the cursor.
    ---@return number x The x position of the cursor.
    ---@return number y The y position of the cursor.
    getCursorPos = function() end,

    ---Sets the position of the cursor. Calls to `write` will begin from this position.
    ---@param x number The new x position of the cursor.
    ---@param y number The new y position of the cursor.
    setCursorPos = function(x, y) end,

    ---Returns true if the cursor is currently set to blink.
    ---@return boolean blink True if the cursor is set to blink.
    getCursorBlink = function() end,

    ---Sets whether the cursor should be visible and blinking at the current cursor position.
    ---@param blink boolean True if the cursor should blink.
    setCursorBlink = function(blink) end,

    ---Gets the size of the terminal.
    ---@return number width The terminal's width.
    ---@return number height The terminal's height.
    getSize = function() end,

    ---Clears the terminal, filling it with the current background color.
    clear = function() end,

    ---Clears the line on which the cursor is currently set, filling it with the current background color.
    clearLine = function() end,

    ---Gets the color in which new text will be written.
    ---@return number color The current text color.
    getTextColor = function() end,

    ---Gets the color in which the new text will be written.
    ---@param color number The new text color.
    setTextColor = function(color) end,

    ---Gets the current background color. This is used when writing text and clearing the terminal.
    ---See `write`, `clear`, and `clearLine`.
    ---@return number color The current background color.
    getBackgroundColor = function() end,

    ---Sets the current background color. This is used when writing text and clearing the terminal.
    ---See `write`, `clear`, and `clearLine`.
    ---@param color number The new background color.
    setBackgroundColor = function(color) end,

    ---Returns true if the terminal supports color.
    ---Terminals which do not support color will still allow writing colored text and backgrounds,
    ---but they will be displayed in grayscale.
    isColor = function() end,

    ---Writes `text` to the terminal with the specific foreground and background characters.
    ---As with `write`, the text will be written at the current cursor location, with the cursor moving to the
    ---end of the text.
    ---
    ---For `textColor` and `backgroundColor` there must be exactly one hex digit for every character in `text`.
    ---
    ---Example: `term.blit("Hello world!", "01234456789ab", "0000000000000")`
    ---@param text string The text to write.
    ---@param textColor string The corresponding text colors.
    ---@param backgroundColor string The corresponding background colors.
    blit = function(text, textColor, backgroundColor) end,

    ---Sets the palette for a specific color.
    ---@param index number The color whose palette should be changed.
    ---@param color number A 24-bit integer representing the RGB value of the color, like `0xff0000`.
    ---@diagnostic disable-next-line: duplicate-index
    setPaletteColor = function(index, color) end,

    ---Sets the palette for a specific color.
    ---@param index number The color whose palette should be changed.
    ---@param r number The intensity of the red channel, between 0 and 1 inclusive.
    ---@param g number The intensity of the green channel, between 0 and 1 inclusive.
    ---@param b number The intensity of the blue channel, between 0 and 1 inclusive.
    ---@diagnostic disable-next-line: duplicate-index
    setPaletteColor = function(index, r, g, b) end,

    ---Gets the current palette for a specific color index.
    ---@param color number The color whose palette should be fetched.
    ---@return number r The red channel, between 0 and 1 inclusive.
    ---@return number g The green channel, between 0 and 1 inclusive.
    ---@return number b The blue channel, between 0 and 1 inclusive.
    getPaletteColor = function(color) end
}

---@type CCTermSurface
term = {
    ---Gets the default palette value for a color.
    ---@param color number The color whose palette should be fetched.
    ---@return number r The red channel, between 0 and 1 inclusive.
    ---@return number g The green channel, between 0 and 1 inclusive.
    ---@return number b The blue channel, between 0 and 1 inclusive.
    ---Throws an exception when an invalid color is given.
    nativePaletteColor = function(color) end,

    ---Redirects terminal output to a monitor, a `window`, or any other custom terminal object that
    ---implements `CCRedirect`. Once the redirect is performed, any calls to a `term` function, or
    ---to a function that consumes `term` functions like `print`, will instead operate with the new
    ---terminal object.
    ---
    ---A redirect can be undone by redirecting to the previous terminal object.
    ---@param target CCTermSurface The terminal redirect to whcih the `term` API will draw.
    ---@return CCTermSurface previous The previous redirect object that is being replaced, as returned by `term.current`.
    redirect = function(target) end,

    ---Returns the current terminal object.
    ---@return CCTermSurface current The current terminal object.
    current = function() end,

    ---Gets the native terminal object of the computer.
    ---
    ---It is generally recommended that you do not use this function. In a multitasked environment, `term.native`
    ---will not be the current terminal object, and so drawing on the surface that is returned by this function
    ---may interfere with other programs.
    ---@return CCTermSurface native The native terminal redirect.
    native = function() end
}
