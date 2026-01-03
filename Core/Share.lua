local _, MS = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function MS:ExportSavedVariables()
    local profileData = { global = MS.db.global }
    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    EncodedInfo = "!MS" .. EncodedInfo
    return EncodedInfo
end

function MS:ImportSavedVariables(EncodedInfo)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo:sub(4))
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, data = Serialize:Deserialize(DecompressedInfo)
    if not success or type(data) ~= "table" then
        MS:Print("Import Failed. Invalid Data String.")
        return
    end

    if success and type(data.global) == "table" then
        for key, value in pairs(data.global) do
            MS.db.global[key] = value
        end
        MS:Print("Import Successful...")
        MS:UpdateAll()
    end
end

function MSG:ExportSavedVariables()
    local profileData = { global = MS.db.global }
    local SerializedInfo = Serialize:Serialize(profileData)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    EncodedInfo = "!MS" .. EncodedInfo
    return EncodedInfo
end

function MSG:ImportSavedVariables(EncodedInfo)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo:sub(4))
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, data = Serialize:Deserialize(DecompressedInfo)
    if not success or type(data) ~= "table" then
        MSG:Print("Import Failed. Invalid Data String.")
        return
    end

    if success and type(data.global) == "table" then
        for key, value in pairs(data.global) do
            MS.db.global[key] = value
        end
        MS:Print("Import Successful...")
        MS:UpdateAll()
    end
end