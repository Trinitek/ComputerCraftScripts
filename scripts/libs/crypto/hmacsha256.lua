
require("libs.crypto.sha256")

---@class HmacSha256
HmacSha256 = { }

---Computes the HMAC of the given data using the SHA256 algorithm.
---@param key immutableBytes
---@param data immutableBytes
---@return immutableBytes  -- 32-byte MAC
HmacSha256.hash = function(key, data)
    local blockSize = 64

    if #key > blockSize then key = Sha256.hash(key) end

    key = key .. string.rep("\0", blockSize - #key)

    local o_key_pad = { }
    local i_key_pad = { }

    for i = 1, blockSize do
        local k = key:byte(i)

        o_key_pad[i] = string.char(bit32.bxor(k, 0x5c))
        i_key_pad[i] = string.char(bit32.bxor(k, 0x36))
    end

    local o_key_pad_str = table.concat(o_key_pad)
    local i_key_pad_str = table.concat(i_key_pad)

    return Sha256.hash(o_key_pad_str .. Sha256.hash(i_key_pad_str .. data))
end

return HmacSha256
