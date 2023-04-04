<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0261" Key="DZ11651739804212" Name="APL_Common" Owner="D_WONG" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.wfb;
import ultra.FNT;
										   
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
import ultra.ZZR_CA_UFL.UFL_CCU_Data;
import ultra.ZZR_SVC0261.UFL_postEpisodicReportFile;

import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Variables;

// import 2 S4 decoder
import ultra.ZZR_SVC0261.UFL_CM_OUTBOUND_Request_SVC0261;

import apl.ZZC_CA_APL.APL_Common;
import apl.ZZC_CA_APL.APL_Error_Functions;

final string SVC0261_DT_FORMAT = "yyyyMMDDHHmmss";
final string SVC0261_DATE_FORMAT = "YYYYMMDD";
final string DT_SAP_FORMAT = "yyyyMMdd";
final string DT_EXT_FORMAT = "yyyy-MM-dd";
final string INTF_ID_SVC0261 = "SVC0261";

final string PRF_EXR = "ZZR_SVC0261.PRF_EXR";
					
FaultDetail createErrorDetail(string key, string message, WSCycle_cmoutbound wsc) {
    debug("-------------------------");
    debug("Function Name: createErrorDetail()");
    debug("createErrorDetail.System Id:" + sysId);
    debug("createErrorDetail.Input: key = " + key);
    debug("createErrorDetail.Input: message = " + message);
    
    FaultDetail fault = udrCreate(FaultDetail);
    
    fault.HEADER = udrCreate(HEADER);
    fault.HEADER = wsc.param.HEADER;
    fault.HEADER.STATUS = "E";
    
    fault.ERRORTABLE = listCreate(ERRORTABLE);
    ERRORTABLE err = mapErrorCodeToS4Error(key, message);
    
    listAdd(fault.ERRORTABLE, err);
    
    debug("createErrorDetail.Output: fault = " + fault);
    return fault;   
}

// new for audit
string getFaultMessage(ConsumeCycleUDR ccu) {  
    debug("-------------------------");
    debug("Function Name: getFaultMessage()");
    debug("getFaultMessage.System Id:" + sysId);
    debug("getFaultMessage.Input: ccu = " + ccu);
    
    string faultMsg;
    
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc; 
    
    if (wsc.fault_FaultDetail.ERRORTABLE != null) {
        if(listSize(wsc.fault_FaultDetail.ERRORTABLE) >= 1 ) {
            ERRORTABLE err = listGet(wsc.fault_FaultDetail.ERRORTABLE,0);
            faultMsg = err.MESSAGE;
        }
    }
    debug("getFaultMessage.Output: faultMsg = " + faultMsg);        
    return faultMsg;   
}

PayloadI625 extractOutboundS4Request( string hexString) {
    //ResponseHeader_Payload rfcResponse = udrCreate(ResponseHeader_Payload);
    debug("-------------------------");
    debug("Function Name: extractOutboundS4Request_I625( string hexString)");
    debug("extractOutboundS4Request_I625.Input: hexString = " + hexString);
    //bytearray decodingBA = hexStringToBytearray(hexString);
    bytearray decodingBA = replaceXMLElement(hexString);
    debug ("decodingBA " + decodingBA  );

    list<PayloadI625> reqList = listCreate(PayloadI625); 
    string result= udrDecode("SVC0261_Request_Decoder",reqList ,decodingBA);
    debug ("result " + result  );
    if (result == null) {
        debug("length of reqList", (string) listSize(reqList));
        return listGet(reqList,0);
        //return null;
    } else {
        debug("extractOutboundS4Request.Output: decode failed!" );
        return null;   
    }
}
//Check outFilenameList present
boolean checkOutFilenameList (ConsumeCycleUDR ccu){
    debug("-------------------------");
    debug("Function Name: isReprocessCp()");
    debug("checkOutFilenameList.System Id:" + sysId);
    debug("checkOutFilenameList.Input: ccu = " + ccu);

    CCUData ccud = (CCUData) ccu.Data;

    debug("checkOutFilenameList.Output: ccud.outFilenameList= " + udrIsPresent(ccud.outFilenameList));
    return udrIsPresent(ccud.outFilenameList);
}

// synchronized void setFilenameDate() {
//     dateToString(filenameDate, dateCreateNow(), "yyyyMMdd");
// }

MultiForwardingUDR createPostEpisodicReportFile(ConsumeCycleUDR ccu, string intfID, string filename,int startPoint, int endPoint) {
    debug("-------------------------");
    debug("Function Name: createPostEpisodicReportFile()");
    debug("createPostEpisodicReportFile.System Id:" + sysId);
    //debug("createPostEpisodicReportFile.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    episodicSubsidyRequest_Int extUdr = (episodicSubsidyRequest_Int) ccud.extUdr;
    
    int contentCount=0;
    bytearray content;
    bytearray header = udrEncode("SVC0261_Record_Encoder", extUdr.header);
    bytearray footer;
    string prefix = getHealthcareFacility(listGet(extUdr.record, startPoint).HealthcareFacility);
    string Date;
    dateToString(Date, dateCreateNow(), "yyyyMMdd"); 
    debug("IN Loop - Startpoint = " + startPoint + " EndPoint = "+ endPoint);
    for(int i = startPoint; i <endPoint; i++){
        EpisodicSubsidyRequest_TI rec = listGet(extUdr.record, i);
        debug("HealthCareFacility = " + rec.HealthcareFacility);
        bytearray ba = udrEncode("SVC0261_Record_Encoder", rec);
        string recStr = baToStr(ba);
        recStr = strREReplaceAll(recStr, "\\n", "");//Remove \n (Newline) from string
        recStr = strREReplaceAll(recStr, "^.*(<EpisodicSubsidyRequest.*)", "$1") + "\n";
        recStr = strREReplaceAll(recStr, " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"", "");
        recStr = strREReplaceAll(recStr, "  ", "");//Remove tab
        strToBA(ba, recStr);
        content = baAppend(content, ba);
        contentCount++;
    }
    
    extUdr.footer.num_of_detail_records = left_pad((string)contentCount, "0", 6);
    footer = udrEncode("SVC0261_Record_Encoder", extUdr.footer);
    content = baAppend(header, content);
    content = baAppend(content, footer);
    
    filename = prefix + "_BT_in" + Date + left_pad(filename, "0", 5) + ".txt";
    
    // Start - 29/6/2022 - Outbound filename enhancement to include audit txn id
    UdrInfo udrInfo = ccud.udrInfo;
    string INTF_TXN_ID =  udrInfo.INTF_TXN_ID;
    if(INTF_TXN_ID != null && INTF_TXN_ID != "")
        filename = filename + "_" + INTF_TXN_ID;
    // End
    
    debug("Filename = " + filename);
    debug("Content = " + content);
    return createMfUdr(intfID+"/Output", filename, content);
}

int getEndPosition(CCUData ccud, int position){
    debug("-------------------------");
    debug("Function Name: getEndPosition()");
    debug("getEndPosition.Input: key = " + position);
    
    episodicSubsidyRequest_Int extUdr = (episodicSubsidyRequest_Int) ccud.extUdr;
    
    int batchSize;
    int currentCount = 1;
    strToInt(batchSize, externalReferenceGet("ZZR_SVC0261.PRF_EXR", "SVC0261_BATCH_SIZE"));
    string currentKey = listGet(extUdr.record, position).HealthcareFacility;
    int i = position;
    for(; i<listSize(extUdr.record); i++){
        string key = listGet(extUdr.record, i).HealthcareFacility;
        debug("Current Key = " + currentKey + " key = " + key);
        if(currentKey != key ){
            debug("getEndPosition.output: key = " + i);
            return i-1;
        }else if(batchSize<=currentCount ){
            debug("getEndPosition.output: key = " + i);
            return i;
        }
        currentCount++;
    }
    //no match or lopp until end of the list;
    debug("getEndPosition.output: key = " + i);
    return i-1;
}

list<string> getCcudOutFileList (ConsumeCycleUDR  ccu ) {
    debug("-------------------------");
    debug("Function Name: getCcudOutFileList()");
    CCUData ccud = (CCUData) ccu.Data;
    
    if (udrIsPresent(ccud.outFilenameList) && listSize(ccud.outFilenameList) > 0 ){    
        debug("getCcudOutFileList.Output: ccud.outFilenameList = " + ccud.outFilenameList);
        return ccud.outFilenameList;
    } else {
        debug("getCcudOutFileList.Output: ccud.errorDesc = null");
        return null;
    }
    
};

string createPostEpisodicReportFileFn(ConsumeCycleUDR ccu, string Filename) {
    debug("-------------------------");
    debug("Function Name: createPostEpisodicReportFileFn()");
    debug("createPostEpisodicReportFileFn.System Id:" + sysId);
    debug("createPostEpisodicReportFileFn.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    
    string filename = Filename; 

    debug("createPostEpisodicReportFileFn.Output: FILENAME = " + filename);     
    return filename;
}

bytearray replaceXMLElement (string input){
    debug("-------------------------");
    debug("Function Name: replaceXMLElement");
    debug("replaceXMLElement.Input: " + input);
    
    bytearray content = hexStringToBytearray(input);
    string tmpString = baToStr(content);
    
    tmpString = strREReplaceAll(tmpString, "<date>", "<Date>");
    tmpString = strREReplaceAll(tmpString, "</date>", "</Date>");
    strToBA(content, tmpString);
    
    debug("replaceXMLElement.Onput: " + content);
    return content;
}

string getHealthcareFacility(string healthcareCode){
    debug("-------------------------");
    debug("Function Name: getHealthcareFacility()");
    debug("getHealthcareFacility.Input: healthcareCode = " + healthcareCode);
    debug("getHealthcareFacility.ServiceMap =" + serviceMap );
    if (mapContains(serviceMap, healthcareCode)){
        debug("Matched = " + healthcareCode + " value = " + mapGet(serviceMap, healthcareCode));
        healthcareCode = mapGet(serviceMap, healthcareCode);
    }
    else{
        debug("No match");
    }
    debug("getHealthcareFacility.Output: healthcareCode = " + healthcareCode);
    return healthcareCode;
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
