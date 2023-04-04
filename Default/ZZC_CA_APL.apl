<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="Default" Key="MZ1627626119717" Name="ZZC_CA_APL" Owner="mzadmin" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="Administrator"/>
                <value value="Administrator"/>
                <value value="Administrator"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[
// Replacing baToHexString to handle XML-Encoded hexstring for character-escape requirement for Apostrophe(')
// Example: hexStrRequest = baToHexStringWithTransformApos(udrEncode("PayloadRequest_Encoder", requestPayload));
string baToHexStringWithTransformApos (bytearray BA) {
    string input = baToHexString(BA);
    string out;
    int len = strLength(input);
    
    //escape and return
    if (strREIndexOf(input,"27") < 0) {
        // save the effort
        return input;
    }
    // scanning
    // search for apos (hex string : 27) 
    
    string checkStr;
    for (int i = 0 ; i < len-1; i = i +2  ) {
        checkStr = strSubstring(input, i, i + 2);  // extract word, 2 hexstring, 1 byte
        
        if (checkStr == "27") {
            checkStr = strREReplaceAll(checkStr, "27", "2661706f733b");
        }
        
        out = out + checkStr;   // reconstruct     
    }
    
    return out;
}
]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
