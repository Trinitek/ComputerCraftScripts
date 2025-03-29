
---@alias bignum table<integer>

local bignum = { }

local BASE = 0x100000000  -- 2^32

---Removes any excess leading zero words.
---@param bn bignum
---@return bignum
bignum.normalize = function(bn)
    ---@type bignum
    local A = { table.unpack(bn) }

    while #A > 1 and A[#A] == 0 do
        table.remove(A)
    end

    return A
end

---Makes a copy of a bignum.
---@param bn bignum
---@return bignum
bignum.copy = function(bn)
    ---@type bignum
    local copy = { }

    for i, v in ipairs(bn) do
        copy[i] = v
    end

    return copy
end

---Creates a bignum from a (small) Lua number.
---@param n number
---@return bignum
bignum.fromInt = function(n)
    ---@type bignum
    local result = { }

    if n == 0 then return { 0 } end

    while n > 0 do
        result[#result + 1] = n % BASE
        n = math.floor(n / BASE)
    end

    return bignum.normalize(result)
end

---Adds two bignums.
---@param a bignum
---@param b bignum
---@return bignum
bignum.add = function(a, b)
    ---@type bignum
    local result = { }
    local carry = 0
    local n = math.max(#a, #b)

    for i = 1, n do
        local ai = a[i] or 0
        local bi = b[i] or 0
        local sum = ai + bi + carry
        result[i] = sum % BASE
        carry = math.floor(sum / BASE)
    end

    if carry > 0 then
        result[n + 1] = carry
    end

    return bignum.normalize(result)
end

---Subtracts two bignums (assumes a >= b).
---@param a bignum
---@param b bignum
---@return bignum
bignum.sub = function(a, b)
    ---@type bignum
    local result = { }
    local borrow = 0
    local n = math.max(#a, #b)

    for i = 1, n do
        local ai = a[i] or 0
        local bi = b[i] or 0
        local diff = ai - bi - borrow

        if diff < 0 then
            diff = diff + BASE
            borrow = 1
        else
            borrow = 0
        end

        result[i] = diff
    end

    return bignum.normalize(result)
end

---Multiplies two bignums.
---@param a bignum
---@param b bignum
---@return bignum
bignum.mul = function(a, b)
    ---@type bignum
    local result = { }

    for i = 1, (#a + #b) do
        result[i] = 0
    end

    for i = 1, #a do
        local carry = 0
        for j = 1, #b do
            local index = i + j - 1
            local prod = a[i] * b[j] + result[index] + carry
            result[index] = prod % BASE
            carry = math.floor(prod / BASE)
        end
        result[i + #b] = result[i + #b] + carry
    end

    return bignum.normalize(result)
end

---Gets the bit length of a bignum.
---@param a bignum
---@return number
bignum.bitLength = function(a)
    a = bignum.normalize(a)

    local last = a[#a]
    local bits = (#a - 1) * 32

    while last > 0 do
        bits = bits + 1
        last = math.floor(last / 2)
    end

    return bits
end

---Left-shift a bignum by a given number of bits.
---@param a bignum
---@param bits number
---@return bignum
bignum.shl = function(a, bits)
    local words = math.floor(bits / 32)
    local rem = bits % 32
    local result = {}

    for i = 1, words do
        result[i] = 0
    end

    local carry = 0

    for i = 1, #a do
        local word = a[i]
        local newword = (word * 2^rem + carry) % BASE

        result[i + words] = newword
        carry = math.floor(word * 2^rem / BASE)
    end

    if carry > 0 then
        result[#a + words + 1] = carry
    end

    return bignum.normalize(result)
end

--- Right-shift a bignum by a given number of bits.
---@param a bignum
---@param bits number
---@return bignum
bignum.shr = function(a, bits)
    local rem = bits % 32
    local words = math.floor(bits / 32)
    local result = {}
    local len = #a

    if len <= words then
        return {0}
    end

    local carry = 0

    for i = len, words + 1, -1 do
        local word = a[i]
        local cur = word + carry * BASE
        local r = math.floor(cur / 2^rem)

        result[i - words] = r
        carry = cur % 2^rem
    end

    return bignum.normalize(result)
end

---Compares two bignums.
---@param a bignum
---@param b bignum
---@return number  -- 1 if a > b, -1 if a < b, 0 if equal.
bignum.cmp = function(a, b)
    a = bignum.normalize(a)
    b = bignum.normalize(b)

    if #a > #b then return 1
    elseif #a < #b then return -1 end

    for i = #a, 1, -1 do
        if a[i] > b[i] then
            return 1
        elseif a[i] < b[i] then
            return -1
        end
    end

    return 0
end

---Long division: returns quotient and remainder.
---@param a bignum
---@param m bignum
---@return bignum, bignum
bignum.divmod = function(a, m)
    local quotient = {0}
    local remainder = bignum.copy(a)
    local r_bits = bignum.bitLength(remainder)
    local m_bits = bignum.bitLength(m)

    for i = r_bits - m_bits, 0, -1 do
        local shifted = bignum.shl(m, i)

        if bignum.cmp(remainder, shifted) >= 0 then
            remainder = bignum.sub(remainder, shifted)
            local one = bignum.fromInt(1)
            local add = bignum.shl(one, i)
            quotient = bignum.add(quotient, add)
        end
    end

    return bignum.normalize(quotient), bignum.normalize(remainder)
end

---Compute `a mod m`.
---@param a bignum
---@param m bignum
---@return bignum
bignum.mod = function(a, m)
    local _, r = bignum.divmod(a, m)
    return r
end

---Modular exponentiation: returns `base^exp mod m`.
---@param base bignum
---@param exp bignum
---@param m bignum
---@return bignum
bignum.modexp = function(base, exp, m)
    local result = bignum.fromInt(1)

    base = bignum.mod(base, m)

    while bignum.cmp(exp, {0}) > 0 do
        if exp[1] % 2 == 1 then
            result = bignum.mod(bignum.mul(result, base), m)
        end
        exp = bignum.shr(exp, 1)
        base = bignum.mod(bignum.mul(base, base), m)
    end

    return result
end

---Modular inverse: returns the inverse of `a modulo m`.
---@param a bignum
---@param m bignum
---@return bignum
bignum.modinv = function(a, m)
    local m0 = bignum.copy(m)
    local x0 = {0}
    local x1 = {1}
    local a_copy = bignum.mod(bignum.copy(a), m)

    if bignum.cmp(m, {1}) == 0 then return {0} end

    while bignum.cmp(a_copy, {1}) > 0 do
        local q, r = bignum.divmod(a_copy, m)

        a_copy, m = m, r

        local t = bignum.copy(x0)

        x0 = bignum.sub(x1, bignum.mul(q, x0))
        x1 = t
    end

    if bignum.cmp(x1, {0}) < 0 then
        x1 = bignum.add(x1, m0)
    end

    return bignum.normalize(x1)
end

---Creates a bignum from a hexadecimal string.
---@param hex string
---@return bignum
bignum.fromHex = function(hex)
    hex = hex:gsub("^0[xX]", "")

    local result = bignum.fromInt(0)

    for i = 1, #hex do
        local digit = tonumber(hex:sub(i, i), 16)
        result = bignum.mul(result, bignum.fromInt(16))
        result = bignum.add(result, bignum.fromInt(digit))
    end

    return bignum.normalize(result)
end

---Converts a bignum to a hexadecimal string.
---@param a bignum
---@return string
bignum.toHex = function(a)
    a = bignum.normalize(a)

    local hex = ""

    for i = #a, 1, -1 do
        hex = hex .. string.format("%08X", a[i])
    end

    hex = hex:gsub("^0+", "")

    return "0x" .. (hex == "" and "0" or hex)
end

--- Convert a bignum into a big-endian byte string.
---@param bn bignum
---@param bytes_len? number  -- Optional length (in bytes) for zero-padding.
---@return string
bignum.toBytes = function(bn, bytes_len)
    local hex = bignum.toHex(bn):sub(3)  -- Remove the "0x" prefix.

    if #hex % 2 == 1 then hex = "0" .. hex end

    if bytes_len then
        local needed = bytes_len * 2 - #hex

        if needed > 0 then
            hex = string.rep("0", needed) .. hex
        end
    end

    local res = {}

    for i = 1, #hex, 2 do
        res[#res + 1] = string.char(tonumber(hex:sub(i, i+1), 16))
    end

    return table.concat(res)
end

---Converts a big-endian byte string into a bignum.
---@param s string
---@return bignum
bignum.fromBytes = function(s)
    local hex = {}

    for i = 1, #s do
        hex[#hex + 1] = string.format("%02X", s:byte(i))
    end

    return bignum.fromHex("0x" .. table.concat(hex))
end

return bignum