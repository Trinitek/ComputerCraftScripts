
---@class Sha256
Sha256 = { }

-----------------------------------------------
-- SHA-256 IMPLEMENTATION
-----------------------------------------------

--- Compute SHA-256 digest of a message.
---@param msg string
---@return string  -- 32-byte binary digest.
Sha256.hash = function(msg)
    local bytes = {}

    for i = 1, #msg do
        bytes[i] = msg:byte(i)
    end

    local msg_len = #bytes
    local bit_len = msg_len * 8

    bytes[msg_len + 1] = 0x80

    while ((#bytes * 8) % 512) ~= 448 do
        bytes[#bytes + 1] = 0
    end

    for i = 1, 8 do
        local shifted = bit32.rshift(bit_len, 8 * (8 - i))

        bytes[#bytes + 1] = bit32.band(shifted, 0xFF)
    end

    local k = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,
        0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,
        0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,
        0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,
        0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,
        0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,
        0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,
        0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,
        0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }

    local h = {
        0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
        0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
    }

    local function rotr(x, n)
        return bit32.band(bit32.bor(bit32.rshift(x, n), bit32.lshift(x, 32 - n)), 0xFFFFFFFF)
    end
    local function shr(x, n)
        return bit32.rshift(x, n)
    end
    local function bsig0(x)
        return bit32.bxor(rotr(x, 2), bit32.bxor(rotr(x, 13), rotr(x, 22)))
    end
    local function bsig1(x)
        return bit32.bxor(rotr(x, 6), bit32.bxor(rotr(x, 11), rotr(x, 25)))
    end
    local function ssig0(x)
        return bit32.bxor(rotr(x, 7), bit32.bxor(rotr(x, 18), shr(x, 3)))
    end
    local function ssig1(x)
        return bit32.bxor(rotr(x, 17), bit32.bxor(rotr(x, 19), shr(x, 10)))
    end
    local function ch(x, y, z)
        return bit32.bxor(bit32.band(x, y), bit32.band(bit32.bnot(x), z))
    end
    local function maj(x, y, z)
        return bit32.bxor(bit32.bxor(bit32.band(x, y), bit32.band(x, z)), bit32.band(y, z))
    end

    for chunkStart = 1, #bytes, 64 do
        local w = {}
        for i = 0, 15 do
            local j = chunkStart + i * 4

            w[i + 1] = bit32.bor(
                bit32.lshift((bytes[j] or 0), 24),
                bit32.lshift((bytes[j+1] or 0), 16),
                bit32.lshift((bytes[j+2] or 0), 8),
                (bytes[j+3] or 0))
        end

        for i = 17, 64 do
            w[i] = bit32.band(ssig1(w[i-2]) + w[i-7] + ssig0(w[i-15]) + w[i-16], 0xFFFFFFFF)
        end

        local a,b,c,d,e,f,g,hh = table.unpack(h)

        for i = 1, 64 do
            local T1 = bit32.band(hh + bsig1(e) + ch(e, f, g) + k[i] + w[i], 0xFFFFFFFF)
            local T2 = bit32.band(bsig0(a) + maj(a, b, c), 0xFFFFFFFF)
            hh = g
            g = f
            f = e
            e = bit32.band(d + T1, 0xFFFFFFFF)
            d = c
            c = b
            b = a
            a = bit32.band(T1 + T2, 0xFFFFFFFF)
        end

        h[1] = bit32.band(h[1] + a, 0xFFFFFFFF)
        h[2] = bit32.band(h[2] + b, 0xFFFFFFFF)
        h[3] = bit32.band(h[3] + c, 0xFFFFFFFF)
        h[4] = bit32.band(h[4] + d, 0xFFFFFFFF)
        h[5] = bit32.band(h[5] + e, 0xFFFFFFFF)
        h[6] = bit32.band(h[6] + f, 0xFFFFFFFF)
        h[7] = bit32.band(h[7] + g, 0xFFFFFFFF)
        h[8] = bit32.band(h[8] + hh, 0xFFFFFFFF)
    end

    local digest = {}
    for i = 1, 8 do
        digest[#digest + 1] = string.char(
            bit32.band(bit32.rshift(h[i], 24), 0xFF),
            bit32.band(bit32.rshift(h[i], 16), 0xFF),
            bit32.band(bit32.rshift(h[i], 8), 0xFF),
            bit32.band(h[i], 0xFF))
    end

    return table.concat(digest)
end
