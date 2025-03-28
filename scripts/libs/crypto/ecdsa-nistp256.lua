
require("libs.crypto.sha256")
require("libs.crypto.hmacsha256")

-----------------------------------------------
-- Type Aliases and Class Definitions
-----------------------------------------------
--- Alias for a “bignum” representation: a little‑endian array of numbers (32‑bit words)
---@alias bignum table<integer>

--- A point on the elliptic curve.
---@class ECPoint
---@field x bignum
---@field y bignum
---@field infinity? boolean  -- true if point is at infinity

--- The elliptic curve parameters (NIST P‑256)
---@class ECCurve
---@field p bignum
---@field a bignum
---@field b bignum
---@field G ECPoint
---@field n bignum

-----------------------------------------------
-- BIG NUMBER ARITHMETIC FUNCTIONS
-----------------------------------------------

local BASE = 0x100000000  -- 2^32

--- Remove any excess leading zero words.
---@param a bignum
---@return bignum
local function bn_normalize(a)
  local A = {table.unpack(a)}
  while #A > 1 and A[#A] == 0 do
    table.remove(A)
  end
  return A
end

--- Make a copy of a bignum.
---@param a bignum
---@return bignum
local function bn_copy(a)
  local copy = {}
  for i, v in ipairs(a) do
    copy[i] = v
  end
  return copy
end

--- Create a bignum from a (small) Lua number.
---@param n number
---@return bignum
local function bn_fromInt(n)
  local result = {}
  if n == 0 then return {0} end
  while n > 0 do
    result[#result + 1] = n % BASE
    n = math.floor(n / BASE)
  end
  return bn_normalize(result)
end

--- Add two bignums.
---@param a bignum
---@param b bignum
---@return bignum
local function bn_add(a, b)
  local result = {}
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
  return bn_normalize(result)
end

--- Subtract two bignums (assumes a >= b).
---@param a bignum
---@param b bignum
---@return bignum
local function bn_sub(a, b)
  local result = {}
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
  return bn_normalize(result)
end

--- Multiply two bignums.
---@param a bignum
---@param b bignum
---@return bignum
local function bn_mul(a, b)
  local result = {}
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
  return bn_normalize(result)
end

--- Get the bit length of a bignum.
---@param a bignum
---@return number
local function bn_bit_length(a)
  a = bn_normalize(a)
  local last = a[#a]
  local bits = (#a - 1) * 32
  while last > 0 do
    bits = bits + 1
    last = math.floor(last / 2)
  end
  return bits
end

--- Left-shift a bignum by a given number of bits.
---@param a bignum
---@param bits number
---@return bignum
local function bn_shl(a, bits)
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
  return bn_normalize(result)
end

--- Right-shift a bignum by a given number of bits.
---@param a bignum
---@param bits number
---@return bignum
local function bn_shr(a, bits)
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
  return bn_normalize(result)
end

--- Compare two bignums.
---@param a bignum
---@param b bignum
---@return number  -- 1 if a > b, -1 if a < b, 0 if equal.
local function bn_cmp(a, b)
  a = bn_normalize(a)
  b = bn_normalize(b)
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

--- Long division: returns quotient and remainder.
---@param a bignum
---@param m bignum
---@return bignum, bignum
local function bn_divmod(a, m)
  local quotient = {0}
  local remainder = bn_copy(a)
  local r_bits = bn_bit_length(remainder)
  local m_bits = bn_bit_length(m)
  for i = r_bits - m_bits, 0, -1 do
    local shifted = bn_shl(m, i)
    if bn_cmp(remainder, shifted) >= 0 then
      remainder = bn_sub(remainder, shifted)
      local one = bn_fromInt(1)
      local add = bn_shl(one, i)
      quotient = bn_add(quotient, add)
    end
  end
  return bn_normalize(quotient), bn_normalize(remainder)
end

--- Compute a mod m.
---@param a bignum
---@param m bignum
---@return bignum
local function bn_mod(a, m)
  local _, r = bn_divmod(a, m)
  return r
end

--- Modular exponentiation: returns base^exp mod m.
---@param base bignum
---@param exp bignum
---@param m bignum
---@return bignum
local function bn_modexp(base, exp, m)
  local result = bn_fromInt(1)
  base = bn_mod(base, m)
  while bn_cmp(exp, {0}) > 0 do
    if exp[1] % 2 == 1 then
      result = bn_mod(bn_mul(result, base), m)
    end
    exp = bn_shr(exp, 1)
    base = bn_mod(bn_mul(base, base), m)
  end
  return result
end

--- Modular inverse: returns the inverse of a modulo m.
---@param a bignum
---@param m bignum
---@return bignum
local function bn_modinv(a, m)
  local m0 = bn_copy(m)
  local x0 = {0}
  local x1 = {1}
  local a_copy = bn_mod(bn_copy(a), m)
  if bn_cmp(m, {1}) == 0 then return {0} end
  while bn_cmp(a_copy, {1}) > 0 do
    local q, r = bn_divmod(a_copy, m)
    a_copy, m = m, r
    local t = bn_copy(x0)
    x0 = bn_sub(x1, bn_mul(q, x0))
    x1 = t
  end
  if bn_cmp(x1, {0}) < 0 then
    x1 = bn_add(x1, m0)
  end
  return bn_normalize(x1)
end

--- Create a bignum from a hexadecimal string.
---@param hex string
---@return bignum
local function bn_fromHex(hex)
  hex = hex:gsub("^0[xX]", "")
  local result = bn_fromInt(0)
  for i = 1, #hex do
    local digit = tonumber(hex:sub(i, i), 16)
    result = bn_mul(result, bn_fromInt(16))
    result = bn_add(result, bn_fromInt(digit))
  end
  return bn_normalize(result)
end

--- Convert a bignum to a hexadecimal string.
---@param a bignum
---@return string
local function bn_toHex(a)
  a = bn_normalize(a)
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
local function bn_to_bytes(bn, bytes_len)
  local hex = bn_toHex(bn):sub(3)  -- Remove the "0x" prefix.
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

--- Convert a big-endian byte string into a bignum.
---@param s string
---@return bignum
local function bn_from_bytes(s)
  local hex = {}
  for i = 1, #s do
    hex[#hex + 1] = string.format("%02X", s:byte(i))
  end
  return bn_fromHex("0x" .. table.concat(hex))
end

-----------------------------------------------
-- ELLIPTIC CURVE (NIST P-256) OPERATIONS
-----------------------------------------------

---@type ECCurve
local curve = {
    p = bn_fromHex("0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF"),
    a = bn_fromHex("0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC"),
    b = bn_fromHex("0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B"),
    G = {
        x = bn_fromHex("0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296"),
        y = bn_fromHex("0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5")
    },
    n = bn_fromHex("0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551"),
}

--- Elliptic curve point doubling.
---@param P ECPoint
---@return ECPoint
local function ec_double(P)
    if P.infinity then return P end
    local p = curve.p
    local lambda = bn_mod(
      bn_mul(bn_add(bn_mul(bn_fromInt(3), bn_mul(P.x, P.x)), curve.a),
             bn_modinv(bn_mul(bn_fromInt(2), P.y), p)), p)
    local x_r = bn_mod(bn_sub(bn_mul(lambda, lambda), bn_mul(bn_fromInt(2), P.x)), p)
    local y_r = bn_mod(bn_sub(bn_mul(lambda, bn_sub(P.x, x_r)), P.y), p)
    return {x = x_r, y = y_r}
end

--- Elliptic curve point addition.
---@param P ECPoint
---@param Q ECPoint
---@return ECPoint
local function ec_add(P, Q)
  if P.infinity then return Q end
  if Q.infinity then return P end
  local p = curve.p
  if bn_cmp(P.x, Q.x) == 0 then
    local temp = bn_mod(bn_add(P.y, Q.y), p)
    if bn_cmp(temp, {0}) == 0 then
      return {infinity = true}  -- P and Q are inverses.
    else
      return ec_double(P)  -- P == Q.
    end
  end
  local lambda = bn_mod(bn_mul(bn_sub(Q.y, P.y), bn_modinv(bn_sub(Q.x, P.x), p)), p)
  local x_r = bn_mod(bn_sub(bn_sub(bn_mul(lambda, lambda), P.x), Q.x), p)
  local y_r = bn_mod(bn_sub(bn_mul(lambda, bn_sub(P.x, x_r)), P.y), p)
  return {x = x_r, y = y_r}
end

--- Elliptic curve scalar multiplication (double-and-add).
---@param P ECPoint
---@param d bignum
---@return ECPoint
local function ec_scalar_mul(P, d)
  local result = {infinity = true}  -- point at infinity.
  local addend = P
  while bn_cmp(d, {0}) > 0 do
    if d[1] % 2 == 1 then
      if result.infinity then
        result = addend
      else
        result = ec_add(result, addend)
      end
    end
    d = bn_shr(d, 1)
    addend = ec_double(addend)
  end
  return result
end

-----------------------------------------------
-- KEY GENERATION
-----------------------------------------------

--- Generate an elliptic curve keypair.
---@return bignum priv, ECPoint pub
local function generate_keypair()
  local priv = {}
  for i = 1, 8 do
    priv[i] = math.random(0, 0xFFFFFFFF)
  end
  priv = bn_mod(priv, curve.n)
  local pub = ec_scalar_mul(curve.G, priv)
  return priv, pub
end

--- Convert a binary string to a hexadecimal representation.
---@param s string
---@return string
local function tohex(s)
    return (s:gsub(".", function(c)
        return string.format("%02x", c:byte())
    end))
end

-----------------------------------------------
-- DER ENCODING/DECODING FOR ECDSA SIGNATURES
-----------------------------------------------

--- DER-encode an INTEGER from a bignum (minimally encoded).
---@param bn bignum
---@return string
local function der_encode_integer(bn)
  local bytes = bn_to_bytes(bn)
  local i = 1
  while i < #bytes and bytes:byte(i) == 0 do
    i = i + 1
  end
  bytes = bytes:sub(i)
  if bytes:byte(1) and bytes:byte(1) > 0x7F then
    bytes = "\0" .. bytes
  end
  return string.char(0x02) .. string.char(#bytes) .. bytes
end

--- DER-encode an ECDSA signature from r and s.
---@param r bignum
---@param s bignum
---@return string
local function der_encode_signature(r, s)
  local r_enc = der_encode_integer(r)
  local s_enc = der_encode_integer(s)
  local seq = r_enc .. s_enc
  return string.char(0x30) .. string.char(#seq) .. seq
end

--- Decode a DER-encoded ECDSA signature into r and s.
---@param sig string
---@return bignum, bignum
local function der_decode_signature(sig)
  local pos = 1
  assert(sig:byte(pos) == 0x30, "Not a DER sequence")
  pos = pos + 1
  local seq_len = sig:byte(pos)
  pos = pos + 1
  assert(sig:byte(pos) == 0x02, "Expected integer marker for r")
  pos = pos + 1
  local r_len = sig:byte(pos)
  pos = pos + 1
  local r_bytes = sig:sub(pos, pos + r_len - 1)
  pos = pos + r_len
  assert(sig:byte(pos) == 0x02, "Expected integer marker for s")
  pos = pos + 1
  local s_len = sig:byte(pos)
  pos = pos + 1
  local s_bytes = sig:sub(pos, pos + s_len - 1)
  local r = bn_from_bytes(r_bytes)
  local s = bn_from_bytes(s_bytes)
  return r, s
end

-----------------------------------------------
-- AES-128 IMPLEMENTATION (CBC mode with PKCS#7 padding)
-----------------------------------------------

-- AES S-box and inverse S-box (fixed as per the AES standard)
local sbox = {
    0x63,0x7C,0x77,0x7B,0xF2,0x6B,0x6F,0xC5,0x30,0x01,0x67,0x2B,0xFE,0xD7,0xAB,0x76,
    0xCA,0x82,0xC9,0x7D,0xFA,0x59,0x47,0xF0,0xAD,0xD4,0xA2,0xAF,0x9C,0xA4,0x72,0xC0,
    0xB7,0xFD,0x93,0x26,0x36,0x3F,0xF7,0xCC,0x34,0xA5,0xE5,0xF1,0x71,0xD8,0x31,0x15,
    0x04,0xC7,0x23,0xC3,0x18,0x96,0x05,0x9A,0x07,0x12,0x80,0xE2,0xEB,0x27,0xB2,0x75,
    0x09,0x83,0x2C,0x1A,0x1B,0x6E,0x5A,0xA0,0x52,0x3B,0xD6,0xB3,0x29,0xE3,0x2F,0x84,
    0x53,0xD1,0x00,0xED,0x20,0xFC,0xB1,0x5B,0x6A,0xCB,0xBE,0x39,0x4A,0x4C,0x58,0xCF,
    0xD0,0xEF,0xAA,0xFB,0x43,0x4D,0x33,0x85,0x45,0xF9,0x02,0x7F,0x50,0x3C,0x9F,0xA8,
    0x51,0xA3,0x40,0x8F,0x92,0x9D,0x38,0xF5,0xBC,0xB6,0xDA,0x21,0x10,0xFF,0xF3,0xD2,
    0xCD,0x0C,0x13,0xEC,0x5F,0x97,0x44,0x17,0xC4,0xA7,0x7E,0x3D,0x64,0x5D,0x19,0x73,
    0x60,0x81,0x4F,0xDC,0x22,0x2A,0x90,0x88,0x46,0xEE,0xB8,0x14,0xDE,0x5E,0x0B,0xDB,
    0xE0,0x32,0x3A,0x0A,0x49,0x06,0x24,0x5C,0xC2,0xD3,0xAC,0x62,0x91,0x95,0xE4,0x79,
    0xE7,0xC8,0x37,0x6D,0x8D,0xD5,0x4E,0xA9,0x6C,0x56,0xF4,0xEA,0x65,0x7A,0xAE,0x08,
    0xBA,0x78,0x25,0x2E,0x1C,0xA6,0xB4,0xC6,0xE8,0xDD,0x74,0x1F,0x4B,0xBD,0x8B,0x8A,
    0x70,0x3E,0xB5,0x66,0x48,0x03,0xF6,0x0E,0x61,0x35,0x57,0xB9,0x86,0xC1,0x1D,0x9E,
    0xE1,0xF8,0x98,0x11,0x69,0xD9,0x8E,0x94,0x9B,0x1E,0x87,0xE9,0xCE,0x55,0x28,0xDF,
    0x8C,0xA1,0x89,0x0D,0xBF,0xE6,0x42,0x68,0x41,0x99,0x2D,0x0F,0xB0,0x54,0xBB,0x16,
}
local inv_sbox = {
    0x52,0x09,0x6A,0xD5,0x30,0x36,0xA5,0x38,0xBF,0x40,0xA3,0x9E,0x81,0xF3,0xD7,0xFB,
    0x7C,0xE3,0x39,0x82,0x9B,0x2F,0xFF,0x87,0x34,0x8E,0x43,0x44,0xC4,0xDE,0xE9,0xCB,
    0x54,0x7B,0x94,0x32,0xA6,0xC2,0x23,0x3D,0xEE,0x4C,0x95,0x0B,0x42,0xFA,0xC3,0x4E,
    0x08,0x2E,0xA1,0x66,0x28,0xD9,0x24,0xB2,0x76,0x5B,0xA2,0x49,0x6D,0x8B,0xD1,0x25,
    0x72,0xF8,0xF6,0x64,0x86,0x68,0x98,0x16,0xD4,0xA4,0x5C,0xCC,0x5D,0x65,0xB6,0x92,
    0x6C,0x70,0x48,0x50,0xFD,0xED,0xB9,0xDA,0x5E,0x15,0x46,0x57,0xA7,0x8D,0x9D,0x84,
    0x90,0xD8,0xAB,0x00,0x8C,0xBC,0xD3,0x0A,0xF7,0xE4,0x58,0x05,0xB8,0xB3,0x45,0x06,
    0xD0,0x2C,0x1E,0x8F,0xCA,0x3F,0x0F,0x02,0xC1,0xAF,0xBD,0x03,0x01,0x13,0x8A,0x6B,
    0x3A,0x91,0x11,0x41,0x4F,0x67,0xDC,0xEA,0x97,0xF2,0xCF,0xCE,0xF0,0xB4,0xE6,0x73,
    0x96,0xAC,0x74,0x22,0xE7,0xAD,0x35,0x85,0xE2,0xF9,0x37,0xE8,0x1C,0x75,0xDF,0x6E,
    0x47,0xF1,0x1A,0x71,0x1D,0x29,0xC5,0x89,0x6F,0xB7,0x62,0x0E,0xAA,0x18,0xBE,0x1B,
    0xFC,0x56,0x3E,0x4B,0xC6,0xD2,0x79,0x20,0x9A,0xDB,0xC0,0xFE,0x78,0xCD,0x5A,0xF4,
    0x1F,0xDD,0xA8,0x33,0x88,0x07,0xC7,0x31,0xB1,0x12,0x10,0x59,0x27,0x80,0xEC,0x5F,
    0x60,0x51,0x7F,0xA9,0x19,0xB5,0x4A,0x0D,0x2D,0xE5,0x7A,0x9F,0x93,0xC9,0x9C,0xEF,
    0xA0,0xE0,0x3B,0x4D,0xAE,0x2A,0xF5,0xB0,0xC8,0xEB,0xBB,0x3C,0x83,0x53,0x99,0x61,
    0x17,0x2B,0x04,0x7E,0xBA,0x77,0xD6,0x26,0xE1,0x69,0x14,0x63,0x55,0x21,0x0C,0x7D,
}
local Rcon = {
    0x01000000,0x02000000,0x04000000,0x08000000,
    0x10000000,0x20000000,0x40000000,0x80000000,
    0x1B000000,0x36000000
}

--- Convert 4 bytes into a 32-bit word.
---@param b1 integer
---@param b2 integer
---@param b3 integer
---@param b4 integer
---@return integer
local function bytesToWord(b1, b2, b3, b4)
    return (
            (b1 * 0x1000000)
            + (b2 * 0x10000)
            + (b3 * 0x100)
            + b4)
        % 0x100000000
end

--- Convert a 32-bit word to 4 bytes.
---@param word integer
---@return integer, integer, integer, integer
local function wordToBytes(word)
    local b1 = math.floor(word / 0x1000000) % 256
    local b2 = math.floor(word / 0x10000) % 256
    local b3 = math.floor(word / 0x100) % 256
    local b4 = word % 256

    return b1, b2, b3, b4
end

--- Rotate a word (cyclic left-shift by one byte).
---@param word integer
---@return integer
local function rotWord(word)
    local b1, b2, b3, b4 = wordToBytes(word)
    return bytesToWord(b2, b3, b4, b1)
end

--- Substitute each byte in the word using the AES S-box.
---@param word integer
---@return integer
local function subWord(word)
    local b1, b2, b3, b4 = wordToBytes(word)

    b1 = sbox[b1 + 1]
    b2 = sbox[b2 + 1]
    b3 = sbox[b3 + 1]
    b4 = sbox[b4 + 1]

    return bytesToWord(b1, b2, b3, b4)
end

--- Expand a 16-byte AES key into round keys.
---@param key string  -- 16-byte key.
---@return string[]   -- array of 16-byte round keys.
local function aes128_key_expansion(key)
  local key_bytes = { key:byte(1, #key) }
  local Nk = 4; local Nb = 4; local Nr = 10;
  local w = {}
  for i = 1, Nk do
    w[i] = bytesToWord(key_bytes[4*(i-1)+1], key_bytes[4*(i-1)+2], key_bytes[4*(i-1)+3], key_bytes[4*(i-1)+4])
  end
  for i = Nk + 1, Nb * (Nr + 1) do
    local temp = w[i - 1]
    if ((i - 1) % Nk) == 0 then
      temp = bit32.bxor(subWord(rotWord(temp)), Rcon[((i - 1) / Nk)])
    end
    w[i] = bit32.bxor(w[i - Nk], temp)
  end
  local round_keys = {}
  for r = 0, Nr do
    local block = {}
    for i = 1, 4 do
      local word = w[r*4 + i]
      local b1, b2, b3, b4 = wordToBytes(word)
      block[#block+1] = string.char(b1, b2, b3, b4)
    end
    round_keys[r+1] = table.concat(block)
  end
  return round_keys
end

--- Add the round key to the state.
---@param state number[]  -- 16-byte state as an array of numbers.
---@param roundKey string -- 16-byte round key.
local function addRoundKey(state, roundKey)
    for i = 1, 16 do
        state[i] = bit32.bxor(state[i], roundKey:byte(i))
    end
end

--- Substitute bytes in the state using the AES S-box.
---@param state number[]  -- in/out array of 16 numbers.
local function subBytes_state(state)
    for i = 1, 16 do
        state[i] = sbox[state[i] + 1]
    end
end

--- Shift the rows of the state as per AES specification.
---@param state number[]
local function shiftRows(state)
    local t = {}

    t[1] = state[1]
    t[2] = state[6]
    t[3] = state[11]
    t[4] = state[16]
    t[5] = state[5]
    t[6] = state[10]
    t[7] = state[15]
    t[8] = state[4]
    t[9] = state[9]
    t[10] = state[14]
    t[11] = state[3]
    t[12] = state[8]
    t[13] = state[13]
    t[14] = state[2]
    t[15] = state[7]
    t[16] = state[12]

    for i = 1, 16 do state[i] = t[i] end
end

--- Mix the columns of the state.
---@param state number[]
local function mixColumns(state)
    for c = 0, 3 do
        local i = c * 4 + 1

        local s0 = state[i]
        local s1 = state[i + 1]
        local s2 = state[i + 2]
        local s3 = state[i + 3]

        ---Multiply by 2 in GF(2^8)
        ---@param x integer
        local function mult2(x)
            local r = x * 2;
            if r >= 256 then
                r = bit32.bxor(r % 256, 0x1B)
            end
            return r
        end

        ---Multiply by 3 using `mult2(x) XOR x`
        ---@param x integer
        local function mult3(x)
            return bit32.bxor(mult2(x), x)
        end

        local t0 = bit32.bxor(
            mult2(s0),
            mult3(s1),
            s2,
            s3)

        local t1 = bit32.bxor(
            s0,
            mult2(s1),
            mult3(s2),
            s3)

        local t2 = bit32.bxor(
            s0,
            s1,
            mult2(s2),
            mult3(s3))

        local t3 = bit32.bxor(
            mult3(s0),
            s1,
            s2,
            mult2(s3))

        state[i], state[i+1], state[i+2], state[i+3] = t0, t1, t2, t3
    end
end

--- Encrypt a single 16-byte block using AES-128.
---@param block string  -- 16-byte plaintext block.
---@param round_keys string[]  -- Round keys from aes128_key_expansion.
---@return string  -- 16-byte ciphertext block.
local function aes128_encrypt_block(block, round_keys)
  local state = { block:byte(1,16) }
  addRoundKey(state, round_keys[1])
  for round = 2, 10 do
    subBytes_state(state)
    shiftRows(state)
    mixColumns(state)
    addRoundKey(state, round_keys[round])
  end
  subBytes_state(state)
  shiftRows(state)
  addRoundKey(state, round_keys[11])
  local out = {}
  for i = 1, 16 do out[i] = string.char(state[i]) end
  return table.concat(out)
end

--- Inverse shift rows.
---@param state number[]
local function invShiftRows(state)
    local t = {}
    t[1] = state[1]
    t[2] = state[14]
    t[3] = state[11]
    t[4] = state[8]
    t[5] = state[5]
    t[6] = state[2]
    t[7] = state[15]
    t[8] = state[12]
    t[9] = state[9]
    t[10] = state[6]
    t[11] = state[3]
    t[12] = state[16]
    t[13] = state[13]
    t[14] = state[10]
    t[15] = state[7]
    t[16] = state[4]

    for i = 1, 16 do
        state[i] = t[i]
    end
end

--- Inverse substitute bytes in the state using the inverse AES S-box.
---@param state number[]
local function invSubBytes_state(state)
  for i = 1, 16 do
    state[i] = inv_sbox[state[i] + 1]
  end
end

--- Multiply two numbers in GF(2^8).
---@param a number
---@param b number
---@return number
local function mul(a, b)
    local p = 0

    for i = 1, 8 do
        if (b % 2) == 1 then
            p = bit32.bxor(p, a)
        end

        local hi = a & 0x80

        a = (a * 2) & 0xFF

        if hi ~= 0 then
            a = bit32.bxor(a, 0x1B)
        end

        b = math.floor(b / 2)
    end

    return p
end

--- Inverse mix columns.
---@param state number[]
local function invMixColumns(state)
  for c = 0, 3 do
    local i = c * 4 + 1
    local a0, a1, a2, a3 = state[i], state[i+1], state[i+2], state[i+3]
    local b0 = bit32.bxor(mul(a0,0x0e), mul(a1,0x0b), mul(a2,0x0d), mul(a3,0x09))
    local b1 = bit32.bxor(mul(a0,0x09), mul(a1,0x0e), mul(a2,0x0b), mul(a3,0x0d))
    local b2 = bit32.bxor(mul(a0,0x0d), mul(a1,0x09), mul(a2,0x0e), mul(a3,0x0b))
    local b3 = bit32.bxor(mul(a0,0x0b), mul(a1,0x0d), mul(a2,0x09), mul(a3,0x0e))
    state[i], state[i+1], state[i+2], state[i+3] = b0, b1, b2, b3
  end
end

--- Decrypt a single 16-byte block using AES-128.
---@param block string  -- 16-byte ciphertext block.
---@param round_keys string[]
---@return string  -- 16-byte plaintext block.
local function aes128_decrypt_block(block, round_keys)
  local state = { block:byte(1,16) }
  addRoundKey(state, round_keys[11])
  for round = 10, 2, -1 do
    invShiftRows(state)
    invSubBytes_state(state)
    addRoundKey(state, round_keys[round])
    invMixColumns(state)
  end
  invShiftRows(state)
  invSubBytes_state(state)
  addRoundKey(state, round_keys[1])
  local out = {}
  for i = 1, 16 do out[i] = string.char(state[i]) end
  return table.concat(out)
end

--- Apply PKCS#7 padding.
---@param data string
---@return string
local function pkcs7_pad(data)
  local block_size = 16
  local pad_len = block_size - (#data % block_size)
  return data .. string.rep(string.char(pad_len), pad_len)
end

--- Remove PKCS#7 padding.
---@param data string
---@return string
local function pkcs7_unpad(data)
  local pad_len = data:byte(-1)
  return data:sub(1, #data - pad_len)
end

--- Encrypt data using AES-128 in CBC mode.
---@param plaintext string
---@param key string    -- 16-byte AES key.
---@param iv string     -- 16-byte IV.
---@return string      -- Ciphertext (multiple of 16 bytes).
local function aes_cbc_encrypt(plaintext, key, iv)
    local padded = pkcs7_pad(plaintext)
    local round_keys = aes128_key_expansion(key)
    local encrypted = {}
    local prev = iv

    for i = 1, #padded, 16 do
        local block = padded:sub(i, i + 15)
        local xored = {}

        for j = 1, 16 do
            local b = block:byte(j)
            local iv_byte = prev:byte(j)
            xored[j] = string.char(bit32.bxor(b, iv_byte))
        end

        local xored_str = table.concat(xored)

        local cipher_block = aes128_encrypt_block(xored_str, round_keys)

        encrypted[#encrypted + 1] = cipher_block
        prev = cipher_block
    end

    return table.concat(encrypted)
end

--- Decrypt AES-128 in CBC mode ciphertext.
---@param ciphertext string
---@param key string    -- 16-byte AES key.
---@param iv string     -- 16-byte IV.
---@return string      -- Plaintext.
local function aes_cbc_decrypt(ciphertext, key, iv)
    local round_keys = aes128_key_expansion(key)
    local decrypted = {}
    local prev = iv

    for i = 1, #ciphertext, 16 do
        local block = ciphertext:sub(i, i + 15)
        local plain_block = aes128_decrypt_block(block, round_keys)
        local xored = {}

        for j = 1, 16 do
            local p = plain_block:byte(j)
            local ivb = prev:byte(j)

            xored[j] = string.char(bit32.bxor(p, ivb))
        end

        decrypted[#decrypted+1] = table.concat(xored)
        prev = block
    end

    local joined = table.concat(decrypted)

    return pkcs7_unpad(joined)
end

-----------------------------------------------
-- ECIES-STYLE ENCRYPTION/DECRYPTION USING AES-CBC + HMAC
-----------------------------------------------

--- Encrypt a plaintext message using an ECIES-like scheme.
---@param pub ECPoint
---@param plaintext string
---@return string  -- Returns: R.x (32 bytes) || R.y (32 bytes) || IV (16 bytes) || MAC (32 bytes) || ciphertext.
local function ecies_encrypt(pub, plaintext)
  local k = {}
  for i = 1, 8 do
    k[i] = math.random(0, 0xFFFFFFFF)
  end
  k = bn_mod(k, curve.n)
  local R = ec_scalar_mul(curve.G, k)
  local S = ec_scalar_mul(pub, k)
  local key_material = Sha256.hash(bn_to_bytes(S.x, 32))  -- 32-byte key material.
  local aes_key = key_material:sub(1, 16)
  local hmac_key = key_material:sub(17, 32)
  -- Generate a random 16-byte IV.
  local iv = ""
  for i = 1, 16 do
    iv = iv .. string.char(math.random(0, 255))
  end
  local ciphertext = aes_cbc_encrypt(plaintext, aes_key, iv)
  local mac = HmacSha256.hash(hmac_key, iv .. ciphertext)
  local R_bytes = bn_to_bytes(R.x, 32) .. bn_to_bytes(R.y, 32)
  return R_bytes .. iv .. mac .. ciphertext
end

--- Decrypt a ciphertext blob using an ECIES-like scheme.
---@param priv bignum
---@param blob string  -- Format: R.x (32 bytes)||R.y (32 bytes)||IV (16 bytes)||MAC (32 bytes)||ciphertext.
---@return string     -- Decrypted plaintext.
local function ecies_decrypt(priv, blob)
  local R_x_bytes = blob:sub(1, 32)
  local R_y_bytes = blob:sub(33, 64)
  local R = {
    x = bn_from_bytes(R_x_bytes),
    y = bn_from_bytes(R_y_bytes)
  }
  local iv = blob:sub(65, 80)
  local mac = blob:sub(81, 112)
  local ciphertext = blob:sub(113)
  local S = ec_scalar_mul(R, priv)
  local key_material = Sha256.hash(bn_to_bytes(S.x, 32))
  local aes_key = key_material:sub(1, 16)
  local hmac_key = key_material:sub(17, 32)
  local expected_mac = HmacSha256.hash(hmac_key, iv .. ciphertext)
  assert(mac == expected_mac, "Invalid MAC! Decryption failed.")
  local plaintext = aes_cbc_decrypt(ciphertext, aes_key, iv)
  return plaintext
end

-----------------------------------------------
-- EXAMPLE USAGE
-----------------------------------------------

local priv, pub = generate_keypair()
local message = "Hello from Lua & C#!"

local ciphertext = ecies_encrypt(pub, message)
print("Ciphertext (hex):", tohex(ciphertext))

local decrypted = ecies_decrypt(priv, ciphertext)
print("Decrypted text:", decrypted)
