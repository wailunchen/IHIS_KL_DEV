<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="Default" Key="DZ11651038020915" Name="ZZR_SVC0004_APL_Processing_Ext" Owner="D_AMIR" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.wfb;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;
import ultra.ZZR_CA_UFL.UFL_Audit;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
import ultra.ws.ZZR_SVC0004.PRF_WS_External.cycles;
import ultra.ws.ZZR_SVC0004.PRF_WS_External.ns1;
import ultra.ZZR_SVC0004.UFL_CM_OUTBOUND_Request_List_SVC0004;
import ultra.ZZR_SVC0004.UFL_CM_OUTBOUND_Response_List_SVC0004;


import apl.ZZC_CA_APL.APL_Common;
import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Common_Variables;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZC_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Audit_Constants;
import apl.ZZR_CA_APL.APL_Audit_Functions;
import apl.ZZR_SVC0004.APL_Common;

//Begin-Common error handling 
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Common_Variables;
import apl.ZZC_CA_APL.APL_Error_Functions;
//End-Common error handling

WSCycle_checkMCARequest extractExtUdr(ConsumeCycleUDR ccu, string PREV_AUDR_RECORD_TXN_ID, int resendCount) {
    debug("-------------------------");
    debug("Function Name: extractExtUdr()");
    debug("extractExtUdr.System Id:" + sysId);
    debug("extractExtUdr.Input: ccu = " + ccu);
    debug("extractExtUdr.Input: resendCount = " + resendCount);
    
    CCUData ccud = (CCUData) ccu.Data;
    //Begin-Inbound outbound retry mechanism
    ccud.reqResend = resendCount;    
    //End-Inbound outbound retry mechanism
    WSCycle_checkMCARequest extUdr = (WSCycle_checkMCARequest) ccud.extUdr; 
    ConsumeCycleUDR ccuExtUdr = (ConsumeCycleUDR) extUdr.context;
    updatePrevRecTxnId(ccuExtUdr, PREV_AUDR_RECORD_TXN_ID);
        
    debug("extractExtUdr.Output: ccud.extUdr = " + ccud.extUdr);    
    return (WSCycle_checkMCARequest) ccud.extUdr;
}

boolean mapWscToExtUdr(ConsumeCycleUDR ccu, int messageRunningNum) {
    debug("-------------------------");
    debug("Function Name: mapWscToExtUdr()");
    debug("mapWscToExtUdr.System Id:" + sysId);
    debug("mapWscToExtUdr.Input: ccu = " + ccu);
    debug("mapWscToExtUdr.Input: messageRunningNum = " + messageRunningNum);
    
    //return true;
    
    boolean isMapped = false;
    CCUData ccud = (CCUData) ccu.Data;    
    
    // for complex scenario case
    if (ccud.isCpForwarding) ccud.wsc = (WSCycle_cmoutbound) ccud.cpUdr;
    
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    string S4INTFID = wsc.param.HEADER.S4INTFID;    
    string smessagedatetime;
    dateToString(smessagedatetime, dateCreateNow(), "yyyyMMdd");
    
    if (!validateCheckMCARequest(ccu,S4INTFID,smessagedatetime))
        return isMapped;
    else {
        WSCycle_checkMCARequest extUdr = udrCreate(WSCycle_checkMCARequest);
        CheckMCARequest request = setRequest(messageRunningNum, ccud.rfcReq);
     
        if (request.UniqueTransactionID != null){
            isMapped = true;    
            extUdr.context = ccu;    
        }
        extUdr.param = request;
        ccud.extUdrType = extUdr.operation;
        ccud.extUdr = extUdr;
    }
    
    debug("mapWscToExtUdr.Output: isMapped = " + isMapped);
//sleep(3000);
//abort("mapWscToExtUdr.Output");
    return isMapped;
}

boolean validateCheckMCARequest(ConsumeCycleUDR ccu, string S4INTFID, string smessagedatetime) {
    debug("-------------------------");
    debug("Function Name: validCheckMCARequest()");
    debug("validCheckMCARequest Id:" + sysId);
    debug("validCheckMCARequest.Input: ccu = " + ccu);
    boolean isValidCheckMCARequest = false;
    FaultDetail fault;   
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    string instituition = wsc.param.HEADER.INST_CODE;
	debug("instituition instituition" + wsc.param.HEADER.INST_CODE);
	list<string> pvalist = null;
    pvalist = listCreate(string);
    listAdd(pvalist, "instId");
    debug("ccud.rfcReq " + ccu.Data);
    // outbound xml is undecodable 
	if(ccud.rfcReq == null)
    {
        debug("ccud.rfcReq is null");
		ccud.errorCode = ERROR_CODE_1E999;
        ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist);
        wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc); 
    }
    // outbound xml is decodable
    else
    {
    	if(S4INTFID == "I082") {
            isValidCheckMCARequest = validateRequest((Payload)ccud.rfcReq,instituition, ccu, S4INTFID, smessagedatetime);
    	//else if(S4INTFID == "Ixxx")
		}    	

    }
        
    debug("validCheckMCARequest.Output: validCheckMCARequest = " + isValidCheckMCARequest);
    return isValidCheckMCARequest;
}

boolean validateRequest(Payload payload,string inst, ConsumeCycleUDR ccu,string S4INTFID,string smessagedatetime) {
    debug("-------------------------");
    debug("Function Name: validateRequest()");
    debug("validateRequest.System Id:" + sysId);
    debug("validateRequest.Input: payload = " + payload);
    debug("validateRequest.Input: inst = " + inst);
    debug("validateRequest.Input: ccu = " + ccu);
    
    boolean isValid = true;
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    FaultDetail fault;   
    list<string> pvalist = null;
    pvalist = listCreate(string);
    listAdd(pvalist, "instId");
    
    //Codeset Validation for Request
  
     /*request is finally valid
    isValid = true; */
 
        for (int i = 0; i < listSize(payload.request); i++){
            RequestInList req = listGet(payload.request, i);
            if(!isNull(req.institution_id)){
                if(isNull(TransBTToLegacy(req.institution_id, "HE_CODE", S4INTFID, smessagedatetime))){
                    ccud.errorCode = ERROR_CODE_1E014;
                    ccud.errorDesc = getErrorDesc(ccud.errorCode, listCreate(string, "institution_id"));
                    wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
                    isValid = false;  
                }
            }
        }  
        
        for (int i = 0; i < listSize(payload.request); i++){
            RequestInList req = listGet(payload.request, i);
            if(!isNull(req.id_type)){
                if(isNull(TransBTToLegacy(req.id_type, "MEDICLAIM_ID_TYPE", S4INTFID, smessagedatetime))){
                    ccud.errorCode = ERROR_CODE_1E014;
                    ccud.errorDesc = getErrorDesc(ccud.errorCode, listCreate(string, "id_type"));
                    wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
                    isValid = false;  
                }
            }
        } 
        
        for (int i = 0; i < listSize(payload.request); i++){
            RequestInList req = listGet(payload.request, i);
            enquiry_type_itm enq= listGet(req.enquiry_type.enquiry_type_itm, i);
            if(!isNull(enq.enquiry_type)){
                if(isNull(TransBTToLegacy(enq.enquiry_type, "ENQUIRY_TYPE", S4INTFID, smessagedatetime))){
                    ccud.errorCode = ERROR_CODE_1E014;
                    ccud.errorDesc = getErrorDesc(ccud.errorCode, listCreate(string, "enquiry_type"));
                    wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
                    isValid = false;  
                }
            }
        } 
        
        
    
                  
    debug("validateRequest.Output: isValid = " + isValid);        
    return isValid;
}

CheckMCARequest setRequest(bigint messageRunningNum, any payload){
    debug("-------------------------");
    debug("Function Name: setRequest()");
    debug("setRequest.System Id:" + sysId);
    debug("setRequest.Input: messageRunningNum = " + messageRunningNum);
    debug("setRequest.Input: payload = " + payload);
    
    CheckMCARequest ccq = udrCreate(CheckMCARequest);
    Payload pl = (Payload) payload;
    list<RequestInList> reqItmlist = pl.request; //Only 1 request in request list for this web service
     for (int i = 0; i<listSize(reqItmlist); i++) {
    RequestInList req = listGet(reqItmlist, i);
    ccq.Institution = req.institution_id;
    ccq.SystemID = "BT";
    ccq.UniqueTransactionID = left_pad((string) messageRunningNum, "0", 50); //TODO: Check the mapping logic
    ccq.UserID = "TEST_USERID"; //TODO: MOH needs to provide once BT is onboarded. Just have to put any value for now.
//     ccq.EnquiryDate= req.enquiry_date;
    ccq.IDNumber=req.id_num;
    ccq.IDType=req.id_type;
    ccq.CPFAccountNumber=req.cpf_acc_num;
    ccq.AdditionalInfoIndicator=req.additional_info_indicator;
    ccq.CheckForConsent=req.check_for_consent;
  //  EnquiryTypes et = udrCreate(EnquiryTypes);
    list<enquiry_type_itm> eyi = req.enquiry_type.enquiry_type_itm;    
    
    for (int j = 0; j<listSize(eyi); j++)
        {
        //EnquiryTypes ets = udrCreate(EnquiryTypes);
        //ets.EnquiryType = listGet(eyi, j).enquiry_type;            
         ccq.EnquiryTypes = ccq.EnquiryTypes + listGet(eyi, j).enquiry_type + ",";   
        }
     
     if(strEndsWith(ccq.EnquiryTypes, ","))
     {
         ccq.EnquiryTypes= strSubstring(ccq.EnquiryTypes,0,strLength(ccq.EnquiryTypes)-1);
     }
     }
    debug("setRequest.Output: ccq = " + ccq);     
    return ccq;
}


ConsumeCycleUDR setCCUResponse(WSCycle_checkMCARequest extUdr) {

    debug("-------------------------");
    debug("Function Name: setCCUResponse()");
    debug("setCCUResponse.System Id:" + sysId);
    debug("setCCUResponse.Input: extUdr = " + extUdr);
           
    string route = null;   
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) extUdr.context;
    extUdr.context = null;
    CCUData ccud = (CCUData) ccu.Data; 
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    string s4intfid = wsc.param.HEADER.S4INTFID;
    string smessagedatetime;
    dateToString(smessagedatetime, dateCreateNow(), "yyyyMMdd");
    list<string> pvalist = null;
    pvalist = listCreate(string);
    listAdd(pvalist, "instId");
    
    // error at transport level
    if (extUdr.errorMessage != null) 
    {
        debug("extUdr.errorMessage = " + extUdr.errorMessage);
        
        if (extUdr.errorMessage == "failed") {
            ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist)+ " " + extUdr.errorMessage;  //getIntErrorDesc(SVC0003_OTHER_ERROR) + ":" + extUdr.errorMessage;     
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);//createErrorDetail(intfIdExt(getExtErrorCode(SVC0003_OTHER_ERROR)), ccud.errorDesc, wsc);
        }
        else if (strREContains(extUdr.errorMessage, "ConnectException")) {
            ccud.errorCode = ERROR_CODE_1E001; //intfIdExt(SVC0003_CONNECT_ESB_ERROR);
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist)+ " " + extUdr.errorMessage; //getIntErrorDesc(SVC0003_CONNECT_ESB_ERROR) + ":" + extUdr.errorMessage;
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);//createErrorDetail(intfIdExt(getExtErrorCode(SVC0003_CONNECT_ESB_ERROR)), ccud.errorDesc, wsc);            
        }
        else if (strREContains(extUdr.errorMessage, "Timeout")) {
            ccud.errorCode = ERROR_CODE_1E001; //intfIdExt(SVC0003_CONNECT_ESB_ERROR);
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist) + " " + extUdr.errorMessage; //getIntErrorDesc(SVC0003_CONNECT_ESB_ERROR) + ":" + extUdr.errorMessage;
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);//createErrorDetail(intfIdExt(getExtErrorCode(SVC0003_CONNECT_ESB_ERROR)), ccud.errorDesc, wsc);
        }
        else if (strREContains(extUdr.errorMessage, "Response message did not contain proper response data")) {
            ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ccud.errorCode , pvalist) + " " + extUdr.errorMessage; //getIntErrorDesc(SVC0003_OTHER_ERROR) + ":" + extUdr.errorMessage;
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);//createErrorDetail(intfIdExt(getExtErrorCode(SVC0003_OTHER_ERROR)), ccud.errorDesc, wsc);
        }
        
        wsc.response = udrCreate(CmOutboundResponse);
        wsc.response.HEADER = udrCreate(HEADER);
        wsc.response.HEADER.STATUS = "E";
    }
    else
    {
        // Set response and mapping
         wsc.response = setResult(extUdr.response,wsc,ccud.rfcReq); 
        
         //validate response
        if(!isNull(extUdr.response.IDType) && isNull(TransLegacyToBT(extUdr.response.IDType, "MEDICLAIM_ID_TYPE", s4intfid, smessagedatetime))){
            listAdd(pvalist, "MEDICLAIM_ID_TYPE");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        }else if (extUdr.response.EnquiryTypes != null && listSize(extUdr.response.EnquiryTypes.EnquiryTypes) > 0/* && isNull(TransLegacyToBT(extUdr.response.EnquiryTypes.EnquiryType, "ENQUIRY_TYPE", s4intfid, smessagedatetime))*/){
            
            for (int j = 0; j<listSize(extUdr.response.EnquiryTypes.EnquiryTypes); j++) {
                
                TEnquiryTypes$EnquiryTypes enquiryType = listGet(extUdr.response.EnquiryTypes.EnquiryTypes, j);  
                
            }
            
            listAdd(pvalist, "ENQUIRY_TYPE");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(extUdr.response.EnquiryTypes.SelfAuthorisationForInsuranceStatus) && isNull(TransLegacyToBT(extUdr.response.EnquiryTypes.SelfAuthorisationForInsuranceStatus, "MCAFM_AUTHORISE_STATUS", s4intfid, smessagedatetime))){
            listAdd(pvalist, "MCAFM_AUTHORISE_STATUS");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(extUdr.response.EnquiryTypes.SelfAuthorisationForInsuranceInstitutionLastChange) && isNull(TransLegacyToBT(extUdr.response.EnquiryTypes.SelfAuthorisationForInsuranceInstitutionLastChange, "HE_CODE", s4intfid, smessagedatetime))){
            listAdd(pvalist, "HE_CODE");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(extUdr.response.Status.StatusCode) && isNull(TransLegacyToBT(extUdr.response.Status.StatusCode, "GETMCAFM_STATUS_CODE", s4intfid, smessagedatetime))){
            listAdd(pvalist, "GETMCAFM_STATUS_CODE");
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.response.HEADER.STATUS = "E";
        } 
        //Validate payer authorisations
        payer_authorisations ppi;
        for (payer_authorisations_itm pp : ppi.payer_authorisations_itm)
        {
         if (!isNull(pp.status_code) && isNull(TransLegacyToBT(pp.status_code, "CPF_STATUS_CODE", s4intfid, smessagedatetime))){
         listAdd(pvalist, "CPF_STATUS_CODE");
         ccud.errorCode = ERROR_CODE_1E014;
         ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
         wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
         wsc.response.HEADER.STATUS = "E";  
         }else if (!isNull(pp.id_type) && isNull(TransLegacyToBT(pp.id_type, "MEDICLAIM_ID_TYPE", s4intfid, smessagedatetime))){
          listAdd(pvalist, "MEDICLAIM_ID_TYPE");
          ccud.errorCode = ERROR_CODE_1E014;
          ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
          wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
          wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(pp.relation_to_payer) && isNull(TransLegacyToBT(pp.relation_to_payer, "PAT_RELATIONSHIP_PAY", s4intfid, smessagedatetime))){
          listAdd(pvalist, "PAT_RELATIONSHIP_PAY");
          ccud.errorCode = ERROR_CODE_1E014;
          ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
          wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
          wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(pp.type_of_consent) && isNull(TransLegacyToBT(pp.type_of_consent, "CONSENT_TYPE", s4intfid, smessagedatetime))){
          listAdd(pvalist, "CONSENT_TYPE");
          ccud.errorCode = ERROR_CODE_1E014;
          ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
          wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
          wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(pp.current_auth_status) && isNull(TransLegacyToBT(pp.current_auth_status, "MCAFM_AUTHORISE_STATUS", s4intfid, smessagedatetime))){
          listAdd(pvalist, "MCAFM_AUTHORISE_STATUS");
          ccud.errorCode = ERROR_CODE_1E014;
          ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
          wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
          wsc.response.HEADER.STATUS = "E";
        }else if (!isNull(pp.institution_lastchange) && isNull(TransLegacyToBT(pp.institution_lastchange, "HE_CODE", s4intfid, smessagedatetime))){
          listAdd(pvalist, "HE_CODE");
          ccud.errorCode = ERROR_CODE_1E014;
          ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
          wsc.fault_FaultDetail = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
          wsc.response.HEADER.STATUS = "E";
        }
        }
        
    }
    
    if (wsc.fault_FaultDetail != null) {
        ccud.isError = true;
    }
    
    ccud.route = route;
    
    debug("setCCUResponse.Output: ccu = " + ccu);     
    return ccu;   
}

CmOutboundResponse setResult(CheckMCAResponse MCAR, WSCycle_cmoutbound wsc, any request ) {
    debug("-------------------------");
    debug("Function Name: setResult()");
    debug("setResult.System Id:" + sysId);
    debug("setResult.Input: cr = " + MCAR);
    
    CmOutboundResponse ir = udrCreate(CmOutboundResponse);
    
    if (MCAR.Status != null) {
        ir.HEADER =  wsc.param.HEADER;
        ir.HEADER.STATUS = "S";
        ir.RESPONSE = udrCreate(RESPONSE);
        
        //Set Response hexString
        string hexString = "";
     
        hexString = baToHexStringWithTransformApos(udrEncode("Response_Encoder", mapResponse(request, MCAR)));
        ir.RESPONSE.RESPONSE_MSG = hexString;
    }
    
    debug("setResult.Output: ir = " + ir);     
    return ir;
}
// 
response mapResponse (any request, CheckMCAResponse MCAR) {
    debug("-------------------------");
    debug("Function Name: mapResponse()");
    debug("mapResponse.System Id:" + sysId);
    debug("mapResponse.Input: MCAR = " + MCAR); 

    response r1 = udrCreate(response);
    r1.response_itm = listCreate(ResponseInList);

        debug("entering response mapping");  
        ResponseInList response = udrCreate(ResponseInList);
        response.authorization_data = udrCreate(authorization_data);
        response.status = udrCreate(status);
        response.authorization_data.authorization_data_itm = listCreate(authorization_data_itm);
        
        
        //status mapping
        response.status.status_code = MCAR.Status.StatusCode;
        response.status.status_description=MCAR.Status.StatusDescription;
        response.status.unique_transaction_id=MCAR.Status.UniqueTransactionID;
        
        //Authorisation Data item mapping
        authorization_data_itm adt = udrCreate(authorization_data_itm);
        adt.id_number=MCAR.IDNumber;
        adt.id_type=MCAR.IDType;
        adt.name=MCAR.Name;
        adt.enquiry_type=MCAR.EnquiryTypes.EnquiryType;
        adt.age_qualifier=MCAR.EnquiryTypes.AgeQualifier;
        adt.appeal_status=MCAR.EnquiryTypes.AppealStatus;
        adt.used_amnt=MCAR.EnquiryTypes.UtilisedAmount;
        adt.unused_amnt=MCAR.EnquiryTypes.UnutilisedAmount;
        dateToString(adt.unused_amnt_dat,MCAR.EnquiryTypes.UnutilisedAmountApplicableDate,SVC0004_REQ_DATETIME_FORMAT);
        adt.unused_amnt_statuscode=MCAR.EnquiryTypes.UnutilisedAmountStatusCode;
        adt.acp_next_treat_cycle=MCAR.EnquiryTypes.ACPNextTreatmentCycle;
        adt.coverage=MCAR.EnquiryTypes.InsuranceCoverage;
        adt.exclusions=MCAR.EnquiryTypes.InsuranceExclusions;
        adt.ipinsurer=MCAR.EnquiryTypes.IPInsurer;
        adt.ipplantype=MCAR.EnquiryTypes.IPPlanType;
        adt.self_auth_status=MCAR.EnquiryTypes.SelfAuthorisationForInsuranceStatus;
        adt.self_auth_inst_lastchanged=MCAR.EnquiryTypes.SelfAuthorisationForInsuranceInstitutionLastChange;
        dateToString(adt.self_auth_dat_lastchanged,MCAR.EnquiryTypes.SelfAuthorisationForInsuranceDateLastChange,SVC0004_REQ_DATETIME_FORMAT);
        adt.self_auth_proxy_idnum=MCAR.EnquiryTypes.SelfAuthorisationForInsuranceProxyIDNumber;
        adt.self_auth_proxy_name=MCAR.EnquiryTypes.SelfAuthorisationForInsuranceProxyName;
        dateToString(adt.self_auth_start_date,MCAR.EnquiryTypes.SelfAuthorisationForInsuranceStartDate,SVC0004_REQ_DATETIME_FORMAT);
        dateToString(adt.self_auth_end_date,MCAR.EnquiryTypes.SelfAuthorisationForInsuranceEndDate,SVC0004_REQ_DATETIME_FORMAT);
        rider_ipplantype RidePlan = udrCreate(rider_ipplantype);
        if(udrIsPresent(MCAR.EnquiryTypes.AssociatedRiderPlans)){
        if(listSize(MCAR.EnquiryTypes.AssociatedRiderPlans.AssociatedRiderPlan) > 0)
        RidePlan = getRidePlan(MCAR.EnquiryTypes.AssociatedRiderPlans);
        }
        payer_authorisations payAuth = udrCreate(payer_authorisations);
        if(udrIsPresent(MCAR.EnquiryTypes.PayerAuthorisations)){
        if(listSize(MCAR.EnquiryTypes.PayerAuthorisations.PayerAuthorisation) > 0)               
        payAuth = getpayAuthPlan(MCAR.EnquiryTypes.PayerAuthorisations);
        }
        listAdd(response.authorization_data.authorization_data_itm,adt);
        listAdd(r1.response_itm, response);
        
    debug("mapResponse.Output: Response = " + r1); 
    return r1 ;
}

rider_ipplantype getRidePlan(TEnquiryTypes$EnquiryTypes$AssociatedRiderPlans rp) {
    rider_ipplantype as = udrCreate(rider_ipplantype);
    
//     list<Assistance_Scheme_Item> asi = listCreate(Assistance_Scheme_Item);
//     for (OtherAssistanceScheme s : assistanceSchems.OtherAssistanceScheme) {
    list<rider_ipplantype_itm> rpi = listCreate(rider_ipplantype_itm);
    for (TEnquiryTypes$EnquiryTypes$AssociatedRiderPlans$AssociatedRiderPlan arp : rp.AssociatedRiderPlan) { 
        rider_ipplantype_itm item = udrCreate(rider_ipplantype_itm);
        item.rider_ipplantype=arp.RiderIPPlanType;
        listAdd(rpi, item);
        
  }
    
    as.rider_ipplantype_itm = rpi;
    
    return as;
}

payer_authorisations getpayAuthPlan(TEnquiryTypes$EnquiryTypes$PayerAuthorisations pa) {
      payer_authorisations payAuth = udrCreate(payer_authorisations);
    

    list<payer_authorisations_itm> pai = listCreate(payer_authorisations_itm);
    for (TEnquiryTypes$EnquiryTypes$PayerAuthorisations$PayerAuthorisation epay : pa.PayerAuthorisation) { 
        payer_authorisations_itm item = udrCreate(payer_authorisations_itm);
        item.payer_age_qualifer=epay.PayerAgeQualifer;
        item.availlable_amnt=epay.AvailableAmount;
        dateToString(item.available_amnt_date,epay.AvailableAmountApplicableDate,SVC0004_REQ_DATETIME_FORMAT);
        item.status_code=epay.StatusCode;
        item.available_amnt_msg=epay.AvailableAmountMessage;
        item.id_num=epay.IDNumber;
        item.id_type=epay.IDType;
        item.cpf_acc_num=epay.CPFAccountNumber;
        item.name=epay.Name;
        item.relation_to_payer=epay.PatientRelationshipToPayer;
        dateToString(item.payer_dob,epay.PayerDOB,SVC0004_REQ_DATETIME_FORMAT);
        item.type_of_consent=epay.TypeOfConsent;
        item.current_auth_status=epay.CurrentAuthorisationStatus;
        item.institution_lastchange=epay.InstitutionLastChange;
        dateToString(item.date_lastchange,epay.DateLastChange,SVC0004_REQ_DATETIME_FORMAT);
        item.proxy_idnum=epay.ProxyIDNumber;
        item.proxy_name=epay.ProxyName;
        dateToString(item.start_date,epay.StartDate,SVC0004_REQ_DATETIME_FORMAT);
        dateToString(item.end_date,epay.EndDate,SVC0004_REQ_DATETIME_FORMAT);
        listAdd(pai, item);
        
  }
    
    payAuth.payer_authorisations_itm = pai;
    
    return payAuth;
}



//Begin-Inbound outbound retry mechanism
boolean enterResendLoop(WSCycle_checkMCARequest extUdr) {
    debug("-------------------------");
    debug("Function Name: enterResendLoop()");
    debug("enterResendLoop.System Id:" + sysId);
    debug("enterResendLoop.Input: extUdr = " + extUdr);
    
    boolean needResend = false;
    
    ConsumeCycleUDR ccu = (ConsumeCycleUDR) extUdr.context;
    CCUData ccud = (CCUData) ccu.Data; 
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    
    // Identify connection error for resending the request
    if (ccud.reqResend>0 && extUdr.errorMessage != null && strREContains(extUdr.errorMessage, WS_CONNECTION_ERROR)) {
        ccud.reqResend = ccud.reqResend-1;
        //wsc.errorMessage = null;
        extUdr.errorMessage = null;
        needResend = true;    
    }
    
    debug("enterResendLoop.Output: needResend = " + needResend);     
    return needResend;       
}
//End-Inbound outbound retry mechanism]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
