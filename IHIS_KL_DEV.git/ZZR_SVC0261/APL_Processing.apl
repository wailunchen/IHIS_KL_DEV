<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0261" Key="DZ11651766744580" Name="APL_Processing" Owner="D_WONG" Type="APL Code" encrypted="false" ver="6.0">
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

import apl.ZZR_SVC0261.APL_Common;
import apl.ZZ_CA_APL.APL_Constants;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;


string setCCUError(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: setCCUError()");
    debug("setCCUError.System Id:" + sysId);
    debug("setCCUError.Input: ccu = " + ccu);
    
    string route = ROUTE_WFB_RESPONSE;
    CCUData ccud = (CCUData) ccu.Data;
        
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    // set to deafult
    if (ccud.errorCode == "" || ccud.errorCode == null ) {
        ccud.errorCode = ERROR_CODE_1E999; 
        ccud.errorDesc = getErrorDesc(ccud.errorCode, null) ;
    }
        
    route = ROUTE_ECS;    
    ccud.isError = true;
    
    debug("setCCUError.Output: route = " + route);    
    return route;
}


synchronized boolean isAsyncRequest(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: isAsyncRequest()");
    debug("isAsyncRequest.System Id:" + sysId);
    debug("isAsyncRequest.Input: ccu = " + ccu);
    
    boolean async = true;
    CCUData ccud = (CCUData) ccu.Data;
    ccud.route = ROUTE_OUTBOUND_SIMPLE;
    //Creating async S4 ACK       
    WSCycle_cmoutbound wsc;
    wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    wsc.response = udrCreate(CmOutboundResponse);
    wsc.response.HEADER = udrCreate(HEADER);
    wsc.response.RESPONSE = udrCreate(RESPONSE);
    wsc.response.RESPONSE.RESPONSE_MSG = "OK";
    wsc.response.HEADER.STATUS = "S";
    
    wsc.response.HEADER = wsc.param.HEADER;
  
    if ((string)wsc.response.HEADER.NUM_REC_PROC == null && wsc.response.HEADER.NUM_REC_PROC == 0)
        wsc.response.HEADER.NUM_REC_PROC = 1;
    
    if ((string)wsc.response.HEADER.NUM_REC_ERR == null || wsc.response.HEADER.NUM_REC_ERR == 0) {
        wsc.response.HEADER.NUM_REC_ERR = 0;
    }
    
    if ((string)wsc.response.HEADER.NUM_REC_RCVD == null || wsc.response.HEADER.NUM_REC_RCVD == 0) {
         wsc.response.HEADER.NUM_REC_RCVD = 1;
    }
    
    if ((string)wsc.response.HEADER.NUM_REC_SUCC == null || wsc.response.HEADER.NUM_REC_SUCC == 0) {
        wsc.response.HEADER.NUM_REC_SUCC = 1;
    }
    ccud.wsc = wsc; 
    ccu.Data = ccud;
    ccud.isAsync = async;
    
    
    debug("isAsyncRequest.Output: async = " + async);
    return async;   
}

ConsumeCycleUDR handleECUProc(ErrorCycleUDR ecu) {
    debug("-------------------------");
    debug("Function Name: handleECUProc()");
    debug("handleECUProc.System Id:" + sysId);
    debug("handleECUProc.Input: ecu = " + ecu);
    
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) ecu.OriginalUDR;
    
    debug("handleECUProc.Output: ccu = " + ccu);    
    return ccu;
}

string getHeaderS4IntfID(ConsumeCycleUDR ccu)
{
    CCUData ccud = (CCUData) ccu.Data;
    
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    return (wsc.param.HEADER.S4INTFID);
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
