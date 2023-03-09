<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="Default" Key="MZ1537948756173" Name="Tables_SOM" Owner="jont" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="Administrator"/>
                <value value="Administrator"/>
                <value value="Administrator"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[// Mapping Tables for SOM (from HL7)

/////////////////////////////////////////
// Marital status
map<string, string> Map_SOMMaritalStatus = createMap_SOMMaritalStatus();

map<string, string> createMap_SOMMaritalStatus() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "A", "5");   // Separated
    mapSet(theMap, "D", "3");   // Divorced
    mapSet(theMap, "M", "1");   // Married
    mapSet(theMap, "S", "0");   // Single
    mapSet(theMap, "W", "2");   // Widowed
    return theMap;
}

/////////////////////////////////////////
// Sex
map<string, string> Map_SOMSex = createMap_SOMSex();

map<string, string> createMap_SOMSex() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "F", "1");   // Female
    mapSet(theMap, "M", "2");   // Male
    mapSet(theMap, "O", "");    // Other
    mapSet(theMap, "U", "0");    // Unknown
    return theMap;
}

/////////////////////////////////////////
// Country
map<string, string> Map_SOMCountry = createMap_SOMCountry();

map<string, string> createMap_SOMCountry() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "CHINA",     "CN");
    mapSet(theMap, "INDONESIA", "ID");
    mapSet(theMap, "INDIA",     "IN");
    mapSet(theMap, "MALAYSIA",  "MY");
    mapSet(theMap, "SINGAPORE", "SG");
    return theMap;
}

/////////////////////////////////////////
// Nationality
map<string, string> Map_SOMNationality = createMap_SOMNationality();

map<string, string> createMap_SOMNationality() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "CHINESE",       "CN");
    mapSet(theMap, "INDONESIAN",    "ID");
    mapSet(theMap, "INDIAN",        "IN");
    mapSet(theMap, "MALAYSIAN",     "MY");
    mapSet(theMap, "SINGAPOREAN",   "SG");
    return theMap;
}

/////////////////////////////////////////
// Sales Organization
map<string, string> Map_SOMSalesOrg = createMap_SOMSalesOrg();

map<string, string> createMap_SOMSalesOrg() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "SGH",  "O 50000005");
    mapSet(theMap, "NUH",  "O 50000027");
    mapSet(theMap, "NTF",  "O 50001268");
    mapSet(theMap, "JCH",  "O 50001268");
    mapSet(theMap, "NUP",  "O 50001268");
    return theMap;
}

/////////////////////////////////////////
// Citizenship
map<string, string> Map_SOMCitizenship = createMap_SOMCitizenship();

map<string, string> createMap_SOMCitizenship() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "SGP", "SG");
    mapSet(theMap, "SPR", "PR");      // Permanent Resident
    mapSet(theMap, "SDP", "DP");      // Dependent Pass
    mapSet(theMap, "FGN", "FR");      // Foreigner
    return theMap;
}

/////////////////////////////////////////
// MT Band  (Not used. Use raw/original)
map<string, string> Map_SOMMTBand = createMap_SOMMTBand();

map<string, string> createMap_SOMMTBand() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "NMTS1",    "1");
    mapSet(theMap, "NMTS2",    "2");
    mapSet(theMap, "NMTS3",    "3");
    return theMap;
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
