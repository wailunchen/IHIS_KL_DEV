<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0261" Key="DZ11651742737583" Name="APL_ECS" Owner="D_WONG" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.wfb;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;
import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZR_SVC0261.APL_Common;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Variables;

void setECS(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: setECS()");
    debug("setECS.System Id:" + sysId);
    debug("setECS.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
        
    if (ccud.errorCode == ERROR_CODE_1E002) {
//         udrAddError(ccu, INTF_ID_SVC0261 + "_" + ERROR_CODE_1E002, ccud.errorDesc); 
        udrAddError(ccu, "SVC0261" + "_" + "1E002", ccud.errorDesc); //Temp fix for MZ8.3 Bug
    } else if (ccud.errorCode == ERROR_CODE_1E024) {
//         udrAddError(ccu, INTF_ID_SVC0261 + "_" + ERROR_CODE_1E024, ccud.errorDesc);
        udrAddError(ccu, "SVC0261" + "_" + "1E024", ccud.errorDesc);//Temp fix for MZ8.3 Bug
    } else if (ccud.errorCode == ERROR_CODE_1E999) {
//         udrAddError(ccu, INTF_ID_SVC0261 + "_" + ERROR_CODE_1E999, ccud.errorDesc);
        udrAddError(ccu, "SVC0261" + "_" + "1E999", ccud.errorDesc);//Temp fix for MZ8.3 Bug
    } 
    
    debug("setECS.Output: ref ccu = " + ccu);    
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
