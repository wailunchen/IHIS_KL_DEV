<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0261" Key="DZ11651740300052" Name="APL_Collection" Owner="D_WONG" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
import ultra.wfb;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;

// import 2 S4 decoder
import ultra.ZZR_SVC0261.UFL_CM_OUTBOUND_Request_SVC0261;


import apl.ZZC_CA_APL.APL_Common_Functions;

import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Audit_Constants;

import apl.ZZR_CA_APL.APL_Common_Variables;
import apl.ZZR_SVC0261.APL_Common;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;
													   
// for debug
import apl.ZZ_CA_APL.APL_Common_Functions;

// for audit
import apl.ZZ_CA_APL.APL_Audit_Functions;

//TODO: Mapping based on S4 Request sysId

void setSysIdWsc( WSCycle_cmoutbound wsc) {
    sysId = wsc.param.HEADER.BATCH_ID;
    setGlobalOrigFn(sysId); // to batch wfl
}

WSCycle_cmoutbound extractWsc(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: extractWsc()");
    debug("extractWsc.System Id:" + sysId);
    debug("extractWsc.Input: ccu = " + ccu);
        
    CCUData ccud = (CCUData) ccu.Data;
    
    debug("extractWsc.Output: ccud.wsc = " + ccud.wsc);     
    return (WSCycle_cmoutbound) ccud.wsc;
}


//UdrInfo createUdrInfo(Request req, WSCycle_cmoutbound wsc) {
UdrInfo createUdrInfo(WSCycle_cmoutbound wsc) {
    debug("-------------------------");
    debug("Function Name: createUdrInfo()");
    debug("createUdrInfo.System Id:" + sysId);
    debug("createUdrInfo.Input: req = " + wsc);
    
    UdrInfo udrInfo = udrCreate(UdrInfo);
    
    udrInfo.INTF_TXN_ID = AUD_PREFIX + createUUID();
    udrInfo.SVC_ID = AUD_SVC_ID;
    udrInfo.INTF_ID = AUD_INTF_ID;
    udrInfo.INST_ID = wsc.param.HEADER.INST_CODE;
    udrInfo.SOURCE_TXN_ID = wsc.param.HEADER.BATCH_ID; // to do: Map based on S4 request
    udrInfo.IN_RECORD_COUNT = 1; //assuming now only with 1 record
    udrInfo.SOURCE_SYS = wsc.param.HEADER.SOURCE_SYS;

    debug("createUdrInfo.Output: udrInfo = " + udrInfo);    
    return udrInfo;
}

void createCCUData(ConsumeCycleUDR ccu, WSCycle_cmoutbound wsc) {
    debug("-------------------------");
    debug("Function Name: createCCUData()");
    debug("createCCUData.System Id:" + sysId);
    debug("createCCUData.Input: ccu = " + ccu);
    debug("createCCUData.Input: wsc = " + wsc);
    
    CCUData ccud = udrCreate(CCUData);
    /*TODO: After S4 Mapping
    ccud.udrInfo = createUdrInfo(req);*/
    //Request rfcRequest = extractOutboundS4Request(wsc.param.REQUEST);

        PayloadI625 rfcRequest = extractOutboundS4Request(wsc.param.REQUEST);
        ccud.rfcReq = rfcRequest;


    ccud.udrInfo = createUdrInfo(wsc);
    ccud.wscType = wsc.operation;
    ccud.wsc = wsc;
    //ccud.rfcReq = rfcRequest;
    
    ccu.Data = ccud;
    
    debug("createCCUData.Output: ref ccu = " + ccu);     
}


WSCycle_cmoutbound createWscRespond(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: createWscRespond()");
    debug("createWscRespond.System Id:" + sysId);
    debug("createWscRespond.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    debug("createWscRespond.Output: wsc = " + wsc);  
    
    //response payload
    wsc.context = ccu;
       
    return wsc;    
}

WSCycle_cmoutbound createWscErrorRespond(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: createWscErrorRespond()");
    debug("createWscErrorRespond.System Id:" + sysId);
    debug("createWscErrorRespond.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    ccud.errorCode = ERROR_CODE_1E005;
    ccud.errorDesc = getErrorDesc(ERROR_CODE_1E005, null);
    FaultDetail fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
    
    wsc.fault_FaultDetail = fault;
    //wsc.response = udrCreate(CmOutboundResponse);
    //wsc.response.HEADER = udrCreate(HEADER);
    wsc.fault_FaultDetail.HEADER.STATUS = "E";
    wsc.fault_FaultDetail.HEADER.NUM_REC_RCVD = 1;
    wsc.fault_FaultDetail.HEADER.NUM_REC_ERR = 1;
    debug("createWscErrorRespond.Output: wsc = " + wsc);     
    return wsc;    
}

// new for audit
bytearray getWscParamResp(ConsumeCycleUDR ccu, string type) {
    debug("-------------------------");
    debug("Function Name: getWscParamResp()");
    debug("getWscParamResp.System Id:" + sysId);
    debug("getWscParamResp.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    bytearray msgContent;
    
     if (type == LOGFILE_TYPE_REQ) {
        //strToBA(msgContent,udrToString(wsc.param));    
        msgContent = wsc.OriginalData;
    } else if (type == LOGFILE_TYPE_RESP) {
        if (udrIsPresent(wsc.fault_FaultDetail)) {
            strToBA(msgContent,udrToString(wsc.fault_FaultDetail));
        } else {			
            strToBA(msgContent,udrToString(wsc.response));
        }
    }
    
    debug("getWscParamResp.Output: msgContent = " + baToHexString(msgContent)); 
    return msgContent;  
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
