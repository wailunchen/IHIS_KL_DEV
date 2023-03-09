<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="Default" Key="MZ1537934307988" Name="Tables_HL7" Owner="mzadmin" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="Administrator"/>
                <value value="Administrator"/>
                <value value="Administrator"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[// Mapping Tables for HL7

/////////////////////////////////////////
// Marital status
map<string, string> MAP_MaritalStatus = createMap_MaritalStatus();

map<string, string> createMap_MaritalStatus() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "A", "Separated");
    mapSet(theMap, "D", "Divorced");
    mapSet(theMap, "M", "Married");
    mapSet(theMap, "S", "Single");
    mapSet(theMap, "W", "Widowed");
    return theMap;
}

/////////////////////////////////////////
// Sex
map<string, string> MAP_Sex = createMap_Sex();

map<string, string> createMap_Sex() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "F", "Female");
    mapSet(theMap, "M", "Male");
    mapSet(theMap, "O", "Other");
    mapSet(theMap, "U", "Unknown");
    return theMap;
}

/////////////////////////////////////////
// Ambulatory Status
map<string, string> MAP_AmbulatoryStatus = createMap_AmbulatoryStatus();

map<string, string> createMap_AmbulatoryStatus() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "A0", "No functional limitations");
    mapSet(theMap, "A1", "Ambulates with assistive device");
    mapSet(theMap, "A2", "Wheelchair/stretcher bound");
    mapSet(theMap, "A3", "Comatose; non-responsive");
    mapSet(theMap, "A4", "Disoriented");
    mapSet(theMap, "A5", "Vision impaired");
    mapSet(theMap, "A6", "Hearing impaired");
    mapSet(theMap, "A7", "Speech impaired");
    mapSet(theMap, "A8", "Non-English speaking");
    mapSet(theMap, "A9", "Functional level unknown");
    mapSet(theMap, "B1", "Oxygen therapy");
    mapSet(theMap, "B2", "Special equipment (tubes, IVs, catheters)");
    mapSet(theMap, "B3", "Amputee");
    mapSet(theMap, "B4", "Mastectomy");
    mapSet(theMap, "B5", "Paraplegic");
    mapSet(theMap, "B6", "Pregnant");
    return theMap;
}

/////////////////////////////////////////
// Patient class
map<string, string> MAP_PatientClass = createMap_PatientClass();

map<string, string> createMap_PatientClass() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "E", "Emergency");
    mapSet(theMap, "I", "Inpatient");
    mapSet(theMap, "O", "Outpatient");
    mapSet(theMap, "P", "Preadmit");
    mapSet(theMap, "R", "Recurring patient");
    mapSet(theMap, "B", "Obstetrics");
    return theMap;
}

/////////////////////////////////////////
// Admit source
map<string, string> MAP_AdmitSource = createMap_AdmitSource();

map<string, string> createMap_AdmitSource() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "1", "Physician referral");
    mapSet(theMap, "2", "Clinic referral");
    mapSet(theMap, "3", "HMO referral");
    mapSet(theMap, "4", "Transfer from a hospital");
    mapSet(theMap, "5", "Transfer from a skilled nursing facility");
    mapSet(theMap, "6", "Transfer from another health care facility");
    mapSet(theMap, "7", "Emergency room");
    mapSet(theMap, "8", "Court/law enforcement");
    mapSet(theMap, "9", "Information not available");
    return theMap;
}

/////////////////////////////////////////
// Allergy type
map<string, string> MAP_AllergyType = createMap_AllergyType();

map<string, string> createMap_AllergyType() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "DA", "Drug allergy");
    mapSet(theMap, "FA", "Food allergy");
    mapSet(theMap, "MA", "Miscellaneous allergy");
    mapSet(theMap, "MC", "Miscellaneous contraindication");
    return theMap;
}

/////////////////////////////////////////
// Allergy severity
map<string, string> MAP_AllergySeverity = createMap_AllergySeverity();

map<string, string> createMap_AllergySeverity() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "SV", "Severe");
    mapSet(theMap, "MO", "Moderate");
    mapSet(theMap, "MI", "Mild");
    return theMap;
}

/////////////////////////////////////////
// ADT Trigger Event
map<string, string> MAP_ADTTriggerEvent = createMap_ADTTriggerEvent();

map<string, string> createMap_ADTTriggerEvent() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "A01", "Admit/visit notification");
    mapSet(theMap, "A02", "Transfer a patient");
    mapSet(theMap, "A03", "Discharge/end visit");
    mapSet(theMap, "A04", "Register a patient");
    mapSet(theMap, "A05", "Pre-admit a patient");
    mapSet(theMap, "A06", "Change an outpatient to an inpatient");
    mapSet(theMap, "A07", "Change an inpatient to an outpatient");
    mapSet(theMap, "A08", "Update patient information");
    mapSet(theMap, "A09", "Patient departing - tracking");
    mapSet(theMap, "A10", "Patient arriving - tracking");
    mapSet(theMap, "A11", "Cancel admit/visit notification");
    mapSet(theMap, "A12", "Cancel transfer");
    mapSet(theMap, "A13", "Cancel discharge/end visit");
    mapSet(theMap, "A14", "Pending admit");
    mapSet(theMap, "A15", "Pending transfer");
    mapSet(theMap, "A16", "Pending discharge");
    mapSet(theMap, "A17", "Swap patients");
    mapSet(theMap, "A18", "Merge patient information");
    mapSet(theMap, "A20", "Bed status update");
    mapSet(theMap, "A21", "Patient goes on a \"leave of absence\"");
    mapSet(theMap, "A22", "Patient returns from a \"leave of absence\"");
    mapSet(theMap, "A23", "Delete a patient record");
    mapSet(theMap, "A24", "Link patient information");
    mapSet(theMap, "A25", "Cancel pending discharge");
    mapSet(theMap, "A26", "Cancel pending transfer");
    mapSet(theMap, "A27", "Cancel pending admit");
    mapSet(theMap, "A28", "Add person information");
    mapSet(theMap, "A29", "Delete person information");
    mapSet(theMap, "A30", "Merge person information");
    mapSet(theMap, "A31", "Update person information");
    mapSet(theMap, "A32", "Cancel patient arriving - tracking");
    mapSet(theMap, "A33", "Cancel patient departing - tracking");
    mapSet(theMap, "A34", "Merge patient information - patient id only");
    mapSet(theMap, "A35", "Merge patient information - account number only");
    mapSet(theMap, "A36", "Merge patient information - patient id and account number");
    mapSet(theMap, "A37", "Unlink patient information");
    mapSet(theMap, "A38", "Cancel pre-admit");
    mapSet(theMap, "A39", "Merge person - patient id");
    mapSet(theMap, "A40", "Merge patient - patient identifier list");
    mapSet(theMap, "A41", "Merge account - patient account number");
    mapSet(theMap, "A42", "Merge visit - visit number");
    mapSet(theMap, "A43", "Move patient information - patient identifier list");
    mapSet(theMap, "A44", "Move account information - patient account number");
    mapSet(theMap, "A45", "Move visit information - visit number");
    mapSet(theMap, "A46", "Change patient id (for backward compatibility only)");
    mapSet(theMap, "A47", "Change patient identifier list");
    mapSet(theMap, "A48", "Change alternate patient id");
    mapSet(theMap, "A49", "Change patient account number");
    mapSet(theMap, "A50", "Change visit number");
    mapSet(theMap, "A51", "Change alternate visit id");
    mapSet(theMap, "A53", "Cancel patient returns from a leave of absence");
    mapSet(theMap, "A54", "Change attending doctor");
    mapSet(theMap, "A55", "Cancel change attending doctor");
    mapSet(theMap, "A60", "Update allergy information");
    mapSet(theMap, "A61", "Change consulting doctor");
    mapSet(theMap, "A62", "Cancel change consulting doctor");
    return theMap;
}

/* Template
/////////////////////////////////////////
// xxx
map<string, string> MAP_xxx = createMap_xxx();

map<string, string> createMap_xxx() {
    map<string, string> theMap = mapCreate(string, string);
    mapSet(theMap, "", "");
    return theMap;
}
*/]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
