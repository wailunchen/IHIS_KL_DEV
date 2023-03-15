<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0002" Key="DZ11636552937144" Name="APL_Processing" Owner="A_SHIDI" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.wfb;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;

import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Variables;
import apl.ZZR_CA_APL.APL_Audit_Constants;
import apl.ZZR_CA_APL.APL_Processing_Functions;

import apl.ZZR_SVC0002.APL_Common;

//Begin-Common error handling    
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;
//End-Common error handling

ConsumeCycleUDR handleECUProc(ErrorCycleUDR ecu) {
    debug("-------------------------");
    debug("Function Name: handleECUProc()");
    debug("handleECUProc.System Id:" + sysId);
    debug("handleECUProc.Input: ecu = " + ecu);
    
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) ecu.OriginalUDR;
    
    debug("handleECUProc.Output: ccu = " + ccu);    
    return ccu;
}

string setCCUError(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: setCCUError()");
    debug("setCCUError.System Id:" + sysId);
    debug("setCCUError.Input: ccu = " + ccu);
    
    string route = ROUTE_WFB_RESPONSE;
    CCUData ccud = (CCUData) ccu.Data;
        
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    if (ccud.errorCode == null || ccud.errorCode == "") {
        list<string> pvalist = null;
        ccud.errorCode = ERROR_CODE_1E009; 
        ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
        FaultDetail fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc); 
        wsc.fault_FaultDetail = fault;
    }
    
    if (ccud.isAsync) {
        route = ROUTE_ECS;
    }
    ccud.isError = true;
    
    debug("setCCUError.Output: route = " + route);    
    return route;
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
