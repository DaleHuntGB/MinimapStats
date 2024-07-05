local _, MS = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function MS:ExportSavedVariables()
    local SerializedInfo = Serialize:Serialize(MSDB.global)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function MS:ImportSavedVariables(EncodedInfo)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local InformationDecoded, InformationTable = Serialize:Deserialize(DecompressedInfo)
    if InformationDecoded then
        MSDB.global = InformationTable
        print(MS.ADDON_NAME .. ": Import Successful!")
    else
        print(MS.ADDON_NAME .. ": Failed To Import Profile!")
    end
end