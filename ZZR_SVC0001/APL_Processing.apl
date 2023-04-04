<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0001" Key="DZ11640766239745" Name="APL_Processing" Owner="D_LIEW" Type="APL Code" encrypted="false" ver="6.0">
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

import apl.ZZR_SVC0001.APL_Common;
import apl.ZZ_CA_APL.APL_Constants;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;

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
    // set to deafult
     if (ccud.errorCode == "" || ccud.errorCode == null ) {
        ccud.errorCode = ERROR_CODE_1E009; 
        ccud.errorDesc = getErrorDesc(ccud.errorCode, null) ;
    }
    
    route = ROUTE_ECS;    
    ccud.isError = true;
    
    debug("setCCUError.Output: route = " + route);    
    return route;
}

/*
ConsumeCycleUDR setCCUResponse(WSCycle_postPayorMaster extUdr) {
    //Response from ws request
    debug("-------------------------");
    debug("Function Name: setCCUResponse()");
    debug("setCCUResponse.System Id:" + sysId);
    debug("setCCUResponse.Input: extUdr = " + extUdr);
           
    string route = null;   
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) extUdr.context;
    extUdr.context = null;
    CCUData ccud = (CCUData) ccu.Data; 
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    //Request req = (Request)ccud.rfcReq;
    
    // error at transport level
    //TODO: Change the error message after Funtional finalized it
    if (extUdr.errorMessage != null || extUdr.errorMessage == "failed") {
        ccud.errorCode = intfIdExt(INT_ERROR_CODE_IE003);
        ccud.errorDesc = getIntErrorDesc(INT_ERROR_CODE_IE003) + " " + extUdr.errorMessage;     
        ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1.FaultDetail faultED = createErrorDetail(intfIdExt(getExtErrorCode(INT_ERROR_CODE_IE003)),
            getExtErrorDesc(INT_ERROR_CODE_IE003),wsc);
        wsc.fault_FaultDetail = faultED;
        
    }else {
        wsc.response = setResult(extUdr.response,wsc,ccud.rfcReq);
        if(extUdr.response == null){
            ccud.errorCode = intfIdExt(SVC0021_MISSING_MANDATORY_IE);
            ccud.errorDesc = getIntErrorDesc(SVC0021_MISSING_MANDATORY_IE)+ ";;" + "Missing Response Content";
            ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1.FaultDetail faultED = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = faultED;
            wsc.response.HEADER.STATUS = "E";
            }
        // validate response
        if(!codeTableLookup(extUdr.response.status.status, "Code_Table_22")){
            ccud.errorCode = intfIdExt(SVC0021_INVALID_CODESET_IE);
            ccud.errorDesc = getIntErrorDesc(SVC0021_INVALID_CODESET_IE) + ":" + "Invalid response status";
            ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1.FaultDetail faultED = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = faultED;
            wsc.response.HEADER.STATUS = "E"; 
        }
        
        
        if(!validPostPayorMasterResponse(extUdr.response, ccud)){
            wsc.response.HEADER.STATUS = "E";
            ccud.isError = true;      
        }
                 
    }
    
    if (wsc.fault_FaultDetail != null) {
        ccud.isError = true;
    }
    
    ccud.route = route;
    
    debug("setCCUResponse.Output: ccu = " + ccu);     
    return ccu;       
}*/

/*
void setCCUResponse(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: setCCUResponse()");
    debug("setCCUResponse.System Id:" + sysId);
    debug("setCCUResponse.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    CmOutboundResponse ir = udrCreate(CmOutboundResponse);
    ir.HEADER =  wsc.param.HEADER;
    ir.HEADER.STATUS = "S";
    ir.HEADER.NUM_REC_PROC = 1;
    ir.HEADER.NUM_REC_ERR = 0;
    ir.HEADER.NUM_REC_RCVD = 1;
    ir.HEADER.NUM_REC_SUCC = 1;
    //ir.RESPONSE = udrCreate(RESPONSE);
    //string hexString = baToHexStringWithTransformApos(udrEncode("SVC0021_List_Response_Encoder",mapResponsePayload(pmr, pmr.status)));
    //string hexString = baToHexStringWithTransformApos(("SVC0021_List_Response_Encoder",mapResponsePayload(pmr, pmr.status)));
    //ir.RESPONSE.RESPONSE_MSG = hexString;
            
    //wsc.response = "OK";
    
    debug("setCCUResponse.Output: ref ccu = " + ccu);    
}*/

/*
CmOutboundResponse setResult(PostPayorMasterResponse pmr, WSCycle_cmoutbound wsc, any request ) {
    debug("-------------------------");
    debug("Function Name: setResult()");
    debug("setResult.System Id:" + sysId);
    debug("setResult.Input: cr = " + pmr);
    
    CmOutboundResponse ir = udrCreate(CmOutboundResponse);
    
    //TODO: set response for CmOutboundResponse
    if (pmr.status != null) {
        ir.HEADER =  wsc.param.HEADER;
        ir.HEADER.STATUS = "S";
        ir.RESPONSE = udrCreate(RESPONSE);
        
        //Set RESPONSE
        string hexString = baToHexStringWithTransformApos(udrEncode("SVC0021_List_Response_Encoder",mapResponsePayload(pmr, pmr.status)));
        ir.RESPONSE.RESPONSE_MSG = hexString;
    } 
    
    debug("setResult.Output: ir = " + ir);     
    return ir;
}*/

synchronized boolean isAsyncRequest(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: isAsyncRequest()");
    debug("isAsyncRequest.System Id:" + sysId);
    debug("isAsyncRequest.Input: ccu = " + ccu);
    
    boolean async = true;
    CCUData ccud = (CCUData) ccu.Data;
            
    //Creating async S4 ACK       
    WSCycle_cmoutbound wsc;
    wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    wsc.response = udrCreate(CmOutboundResponse);
    wsc.response.HEADER = udrCreate(HEADER);
    wsc.response.RESPONSE = udrCreate(RESPONSE);
    wsc.response.RESPONSE.RESPONSE_MSG = "OK";
    wsc.response.HEADER.STATUS = "S";
    
    wsc.response.HEADER = wsc.param.HEADER;
    
    wsc.param.HEADER.STATUS = "S";
   
    if ( wsc.response.HEADER.NUM_REC_PROC == 0)
        wsc.response.HEADER.NUM_REC_PROC = 1;
    
    if ( wsc.response.HEADER.NUM_REC_ERR == 0)    
        wsc.response.HEADER.NUM_REC_ERR = 0;
        
    if ( wsc.response.HEADER.NUM_REC_RCVD == 0)
        wsc.response.HEADER.NUM_REC_RCVD = 1;
        
    if ( wsc.response.HEADER.NUM_REC_SUCC == 0)
        wsc.response.HEADER.NUM_REC_SUCC = 1;
    
    ccud.wsc = wsc; 
    ccu.Data = ccud;
    ccud.isAsync = async;
    
    
    debug("isAsyncRequest.Output: async = " + async);
    return async;   
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
