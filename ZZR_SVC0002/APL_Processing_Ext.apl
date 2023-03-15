<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0002" Key="DZ11636355546724" Name="APL_Processing_Ext" Owner="A_SHIDI" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
import ultra.ws.ZZR_SVC0002.PRF_WS_External.cycles;
import ultra.ws.ZZR_SVC0002.PRF_WS_External.ns1;

import ultra.wfb;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;
import ultra.ZZR_CA_UFL.UFL_Audit;

import ultra.ZZR_SVC0002.UFL_CM_OUTBOUND_Request_List_SVC0002;
import ultra.ZZR_SVC0002.UFL_CM_OUTBOUND_Response_SVC0002;

import apl.ZZC_CA_APL.APL_Common; //left_pad()
import apl.ZZC_CA_APL.APL_Common_Functions; //isNull(), date conversion
import apl.ZZC_CA_APL.APL_Common_Constants; //Date Conversion, error handling 
import apl.ZZC_CA_APL.APL_Error_Functions; //error handling 

import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Audit_Constants;
import apl.ZZR_CA_APL.APL_Audit_Functions;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZR_SVC0002.APL_Common;
import apl.ZZR_CA_APL.APL_Common_Variables;



WSCycle_checkConsent extractExtUdr(ConsumeCycleUDR ccu, string PREV_AUDR_RECORD_TXN_ID, int resendCount) {
    debug("-------------------------");
    debug("Function Name: extractExtUdr()");
    debug("extractExtUdr.System Id:" + sysId);
    debug("extractExtUdr.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    ccud.reqResend = resendCount;  //retry mechanism
    WSCycle_checkConsent extUdr = (WSCycle_checkConsent) ccud.extUdr; 
    ConsumeCycleUDR ccuExtUdr = (ConsumeCycleUDR) extUdr.context;
    updatePrevRecTxnId(ccuExtUdr, PREV_AUDR_RECORD_TXN_ID);
        
    debug("extractExtUdr.Output: ccud.extUdr = " + ccud.extUdr);    
    return (WSCycle_checkConsent) ccud.extUdr;
}


boolean mapWscToExtUdr(ConsumeCycleUDR ccu, bigint messageRunningNum) {
    debug("-------------------------");
    debug("Function Name: mapWscToExtUdr()");
    debug("mapWscToExtUdr.System Id:" + sysId);
    debug("mapWscToExtUdr.Input: ccu = " + ccu);
    debug("mapWscToExtUdr.Input: messageRunningNum = " + messageRunningNum);
    
    boolean isMapped = false;
    CCUData ccud = (CCUData) ccu.Data;   
    
    if (ccud.isCpForwarding) {
        // for complex scenario case
        ccud.wsc = (WSCycle_cmoutbound) ccud.cpUdr;
    }
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    string s4intfid = wsc.param.HEADER.S4INTFID;
    string smessagedatetime;
    dateToString(smessagedatetime, dateCreateNow(), "yyyyMMdd"); 
    
    if(!validateGlobalConsentRequest((Payload)ccud.rfcReq, ccu, s4intfid, smessagedatetime)){
        return isMapped;
    }else{
        WSCycle_checkConsent extUdr = udrCreate(WSCycle_checkConsent);    
        CheckConsent checkConsentRequest = setRequest(messageRunningNum, ccud.rfcReq, s4intfid, smessagedatetime);
        
        if (checkConsentRequest.UniqueTransactionID != null){
            isMapped = true;    
            extUdr.context = ccu;    
        }
    
        extUdr.param = checkConsentRequest;
        extUdr.param.IDNumber= checkConsentRequest.IDNumber;
        extUdr.param.Institution = checkConsentRequest.Institution;
        extUdr.param.SystemID = checkConsentRequest.SystemID;
        extUdr.param.UniqueTransactionID = checkConsentRequest.UniqueTransactionID;
        extUdr.param.UserID = checkConsentRequest.UserID;
        
        ccud.extUdrType = extUdr.operation;
        ccud.extUdr = extUdr;
    }

    logInformation("mapWscToExtUdr: " + ccud.extUdr);
    debug("mapWscToExtUdr.Output: isMapped = " + isMapped);    
    return isMapped;
}

boolean validateGlobalConsentRequest(Payload payload, ConsumeCycleUDR ccu, string s4intfid, string smessagedatetime){
    debug("-------------------------");
    debug("Function Name: validateGlobalConsentRequest()");
    debug("validateGlobalConsentRequest.System Id:" + sysId);
    debug("validateGlobalConsentRequest.Input: ccu = " + ccu);
    boolean isValidRequest = true;
    FaultDetail fault;   
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    // xml is undecodable 
	if(ccud.rfcReq == null) {
        ccud.errorCode = ERROR_CODE_1E999;
        ccud.errorDesc = getErrorDesc(ccud.errorCode, null);
        wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
        isValidRequest = false; 
	} else {
        for (int i = 0; i < listSize(payload.request); i++){
            RequestInList req = listGet(payload.request, i);
            /*if(!isNull(req.institution_id)){
                if(isNull(TransBTToLegacy(req.institution_id, "HE_CODE", s4intfid, smessagedatetime))){
                    ccud.errorCode = ERROR_CODE_1E014;
                    ccud.errorDesc = getErrorDesc(ccud.errorCode, listCreate(string, "institution_id"));
                    wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
                    isValidRequest = false;  
                }
            }*/
        }    
    }
    
    debug("validateBillOutstandingARRequest.Output: isValidRequest = " + isValidRequest);
    return isValidRequest;
}

CheckConsent setRequest(bigint messageRunningNum, any payload, string s4intfid, string smessagedatetime){
    debug("-------------------------");
    debug("Function Name: setRequest()");
    debug("setRequest.System Id:" + sysId);
    debug("setRequest.Input: messageRunningNum = " + messageRunningNum);
    debug("setRequest.Input: payload = " + payload);
    
    CheckConsent ccq = udrCreate(CheckConsent);
    Payload pl = (Payload) payload;
    RequestInList req = listGet(pl.request,0); //Only 1 request in request list for this web service
    
    ccq.IDNumber = req.patient_mrn;
    //ccq.Institution = TransBTToLegacy(req.institution_id, "HE_CODE", s4intfid, smessagedatetime);
    ccq.Institution = req.institution_id;
    ccq.SystemID = "BT";
    ccq.UniqueTransactionID = left_pad((string) messageRunningNum, "0", 50); //TODO: Check the mapping logic
    ccq.UserID = "TEST_USERID"; //TODO: MOH needs to provide once BT is onboarded. Just have to put any value for now.
    
    debug("setRequest.Output: ccq = " + ccq);     
    return ccq;
}

ConsumeCycleUDR setCCUResponse(WSCycle_checkConsent extUdr) {
    //Response from ws request
    debug("-------------------------");
    debug("Function Name: setCCUResponse()");
    debug("setCCUResponse.System Id:" + sysId);
    debug("setCCUResponse.Input: extUdr = " + extUdr);
           
    string route = null; 
    string startDate;
    string endDate;
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) extUdr.context;
    //extUdr.context = null;
    CCUData ccud = (CCUData) ccu.Data; 
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    string s4intfid = wsc.param.HEADER.S4INTFID;
    string smessagedatetime;
    dateToString(smessagedatetime, dateCreateNow(), "yyyyMMdd"); 
    list<string> pvalist = null;
    pvalist = listCreate(string);
    
    // error at transport level, external server is not responding
    if (extUdr.errorMessage != null) {
        
        debug("extUdr.errorMessage = " + extUdr.errorMessage);
        
        if(extUdr.errorMessage == "failed"){
            ccud.errorCode = ERROR_CODE_1E001;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);    
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
        }else if (strREContains(extUdr.errorMessage, "ConnectException")) {
            ccud.errorCode = ERROR_CODE_1E001; 
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist)+ " " + extUdr.errorMessage; 
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);           
        }
        else if (strREContains(extUdr.errorMessage, "Timeout")) {
            ccud.errorCode = ERROR_CODE_1E024; 
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist) + " " + extUdr.errorMessage; 
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
        }
        else if (strREContains(extUdr.errorMessage, "Response message did not contain proper response data")) {
            ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist) + " " + extUdr.errorMessage;
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
        }
        
        wsc.response = udrCreate(CmOutboundResponse);
        wsc.response.HEADER = udrCreate(HEADER);
        wsc.response.HEADER.STATUS = "E";   
        
        extUdr.response = udrCreate(CheckConsentResponse);
        extUdr.response.Status = udrCreate(CheckConsentResponse$Status);
        extUdr.response.Status.StatusCode = ccud.errorCode;
        extUdr.response.Status.StatusDescription = ccud.errorDesc;
        
    }else {
        //wsc.response = setResult(extUdr.response, wsc, s4intfid, smessagedatetime);
        wsc.response = setResult(extUdr, wsc, s4intfid, smessagedatetime);  
        
        //validate response
//         if(!isNull(extUdr.response.ConsentLevel) && isNull(TransLegacyToBT(extUdr.response.ConsentLevel, "CONSENT_LEVEL", s4intfid, smessagedatetime))){
//             listAdd(pvalist, "ConsentLevel");
//             ccud.errorCode = ERROR_CODE_1E014;
//             ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
//             wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
//             wsc.response.HEADER.STATUS = "E";
//         }else if (!isNull(extUdr.response.ReasonForNoConsent) && isNull(TransLegacyToBT(extUdr.response.ReasonForNoConsent, "CONSENT_REASON", s4intfid, smessagedatetime))){
//             listAdd(pvalist, "ReasonForNoConsent");
//             ccud.errorCode = ERROR_CODE_1E014;
//             ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
//             wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
//             wsc.response.HEADER.STATUS = "E";
//         }else if (!isNull(extUdr.response.InstitutionLastChange) && isNull(TransLegacyToBT(extUdr.response.InstitutionLastChange, "HE_CODE", s4intfid, smessagedatetime))){
//             listAdd(pvalist, "InstitutionLastChange");
//             ccud.errorCode = ERROR_CODE_1E014;
//             ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
//             wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
//             wsc.response.HEADER.STATUS = "E";
//         }
        /*else if (isNull(TransLegacyToBT(extUdr.response.Status.StatusCode, "GETGLOBAL_STATUS_CODE", s4intfid, smessagedatetime))){
            listAdd(pvalist, "StatusCode");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        }else if (!dateToString(startDate, extUdr.response.StartDate, SVC0002_DATE_FORMAT)){
            listAdd(pvalist, "StartDate");
            ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        } else if (!dateToString(endDate, extUdr.response.EndDate, SVC0002_DATE_FORMAT)){
            listAdd(pvalist, "EndDate");
            ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        } */
    }
    
    if (wsc.fault_FaultDetail != null) {
        ccud.isError = true;
    }
    
    ccud.route = route;
    
    debug("setCCUResponse.Output: ccu = " + ccu);     
    return ccu;       
}

CmOutboundResponse setResult(WSCycle_checkConsent extUdr, WSCycle_cmoutbound wsc, string s4intfid, string smessagedatetime) {
    debug("-------------------------");
    debug("Function Name: setResult()");
    debug("setResult.System Id:" + sysId);
    debug("setResult.Input: WSCycle_checkConsent extUdr = " + extUdr);
    
    CmOutboundResponse ir = udrCreate(CmOutboundResponse);
    
    if (extUdr.response.Status.StatusCode != null) {
        ir.HEADER =  wsc.param.HEADER;
        ir.HEADER.STATUS = "S";
        ir.RESPONSE = udrCreate(RESPONSE);
        
        //Set RESPONSE
        string hexString = baToHexStringWithTransformApos(udrEncode("Response_List_Encoder",mapResponsePayload(extUdr, s4intfid, smessagedatetime)));
        ir.RESPONSE.RESPONSE_MSG = hexString;
    } 
    
    debug("setResult.Output: ir = " + ir);     
    return ir;
}

Payload_Response mapResponsePayload(WSCycle_checkConsent extUdr, string s4intfid, string smessagedatetime) {
    debug("-------------------------");
    debug("Function Name: mapResponsePayload()");
    debug("mapResponsePayload.System Id:" + sysId);
    debug("mapResponsePayload.Input: WSCycle_checkConsent extUdr = " + extUdr);    
      
    Payload_Response pr = udrCreate(Payload_Response);
    pr.response_itm = listCreate(Response_Itm);
    Response_Itm respItm = udrCreate(Response_Itm);
    
    // mapping to payload  
    if(!isNull(extUdr.response.ConsentLevel)){
        //respItm.consent_level = TransLegacyToBT(extUdr.response.ConsentLevel, "CONSENT_LEVEL", s4intfid, smessagedatetime);
        respItm.consent_level = extUdr.response.ConsentLevel;
    }
            
    if(extUdr.response.StartDate != null){
        string strDate;
        dateToString(strDate, extUdr.response.StartDate, DATETIME_FORMAT_YYYY_MM_DD); 
        respItm.start_date = convertDateTimeFormat(strDate, DATETIME_FORMAT_YYYY_MM_DD, DATETIME_FORMAT_YYYYMMDD);
    }
    
    if(extUdr.response.EndDate != null){
        string strDate;
        dateToString(strDate, extUdr.response.EndDate, DATETIME_FORMAT_YYYY_MM_DD);
        respItm.end_date = convertDateTimeFormat(strDate, DATETIME_FORMAT_YYYY_MM_DD, DATETIME_FORMAT_YYYYMMDD);
    }
    
    if(!isNull(extUdr.response.InstitutionLastChange)){
        //respItm.institution_last_change = TransLegacyToBT(extUdr.response.InstitutionLastChange, "HE_CODE", s4intfid, smessagedatetime);
        respItm.institution_last_change = extUdr.response.InstitutionLastChange;
    }
    
    if(!isNull(extUdr.response.OBF_IDNumber)){
        respItm.on_behalf_of_patiend_id = extUdr.response.OBF_IDNumber;
    }
    
    if(!isNull(extUdr.response.OBF_Name)){
        respItm.on_behalf_of_patient_name = extUdr.response.OBF_Name;
    }
    
    if(!isNull(extUdr.response.IDNumber)){
        respItm.patient_mrn = extUdr.response.IDNumber;
    }
    
    if(!isNull(extUdr.response.Name)){
        respItm.patient_name = extUdr.response.Name;
    }
    
    if(!isNull(extUdr.response.ReasonForNoConsent)){
        //respItm.reason_for_no_consent = TransLegacyToBT(extUdr.response.ReasonForNoConsent, "CONSENT_REASON", s4intfid, smessagedatetime);
        respItm.reason_for_no_consent = extUdr.response.ReasonForNoConsent;
    }

    //pr.status_code = TransLegacyToBT(extUdr.response.Status.StatusCode, "GETGLOBAL_STATUS_CODE", s4intfid, smessagedatetime);
    respItm.status_code = extUdr.response.Status.StatusCode;
    respItm.status_desc = extUdr.response.Status.StatusDescription;      
    respItm.transaction_id = extUdr.response.Status.UniqueTransactionID;
    
    listAdd(pr.response_itm, respItm);
    debug("mapResponsePayload.Output: pr = " + pr);
    return pr;
}

boolean enterResendLoop(WSCycle_checkConsent extUdr) {
    debug("-------------------------");
    debug("Function Name: enterResendLoop()");
    debug("enterResendLoop.System Id:" + sysId);
    debug("enterResendLoop.Input: extUdr = " + extUdr);
           
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) extUdr.context;
    CCUData ccud = (CCUData) ccu.Data; 
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;    
    boolean needResend=false;    
    // Identify connection error for resending the request
    if (ccud.reqResend>0 && extUdr.errorMessage!=null && (strREContains(extUdr.errorMessage, WS_CONNECTION_ERROR) || strIndexOf(extUdr.errorMessage, "timed out", 0) > 0)) {
        ccud.reqResend=ccud.reqResend-1;
        wsc.errorMessage=null;        
        needResend = true;    
    }   
    debug("enterResendLoop.Output: needResend = " + needResend);     
    return needResend;       
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
