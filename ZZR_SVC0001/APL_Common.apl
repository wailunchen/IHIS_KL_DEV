<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0001" Key="DZ11640761091560" Name="APL_Common" Owner="D_LIEW" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="All"/>
                <value value="All"/>
                <value value="All"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[    import ultra.wfb;
    import ultra.FNT;									   
    import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.cycles;
    import ultra.ws.ZZC_RFC.PRF_WS_CM_OUTBOUND.x1;
    import ultra.ZZR_CA_UFL.UFL_CCU_Data;
    import ultra.ZZR_SVC0001.UFL_PostInvoiceToNeFRFile;
    import ultra.ZZR_SVC0001.UFL_CM_OUTBOUND_Request_I038;
    import apl.ZZR_CA_APL.APL_Common_Functions;
    import apl.ZZR_CA_APL.APL_Common_Variables;
    //import ultra.ZZR_SVC0017.UFL_CM_OUTBOUND_Request_SVC0017;
    // import 2 S4 decoder
    //import ultra.ZZR_SVC0017.UFL_CM_OUTBOUND_Request_List_I036;
    import apl.ZZC_CA_APL.APL_Common;
    import apl.ZZC_CA_APL.APL_Error_Functions;
    final string PRF_EXR_SVC0001 = "ZZR_SVC0001.PRF_EXR";
    final string SVC0001_DT_FORMAT = "yyyyMMDDHHmmss";
    final string SVC0001_DATE_FORMAT = "YYYYMMDD";
    /*
    final string SVC0238_INVALID_LENGTH_IE = "IE2001";
    final string SVC0238_INVALID_DATATYPE_IE = "IE2002";
    final string SVC0238_MISSING_MANDATORY_IE = "IE2003";
    final string SVC0238_INVALID_CODESET_IE = "IE2004";
    final string SVC0238_INVALID_DATE_FORMAT_IE = "IE2005";
    final string SVC0238_INVALID_TIME_FORMAT_IE = "IE2013";
    final string SVC0238_INVALID_PERIOD_FORMAT_IE = "IE2014";
    final string SVC0238_CONNECT_SAP_ERROR = "IE1001";
    final string SVC0238_CONNECT_ESB_ERROR = "IE1003";
    final string SVC0238_INVALID_XML_FORMAT_IE = "IE1004";
    final string SVC0238_CONNECT_ESB_TO_CM_ERROR = "EE1001";
    final string SVC0238_OTHER_ERROR = "IE2999";
    */
    persistent map<string,int> instAdditionalCodeMap = mapCreate(string, int);
    persistent date additionalNumResetTime;
    final string INTF_ID_SVC0001 = "SVC0001";
   // string Aud_filename;
    					
    FaultDetail createErrorDetail(string key, string message, WSCycle_cmoutbound wsc) {
        /*debug("-------------------------");
        debug("Function Name: createErrorDetail()");
        debug("createErrorDetail.System Id:" + sysId);
        debug("createErrorDetail.Input: key = " + key);
        debug("createErrorDetail.Input: message = " + message);*/
        
        FaultDetail fault = udrCreate(FaultDetail);
        
        fault.HEADER = udrCreate(HEADER);
        fault.HEADER = wsc.param.HEADER;
        fault.HEADER.STATUS = "E";
        fault.ERRORTABLE = listCreate(ERRORTABLE);
        ERRORTABLE err = mapErrorCodeToS4Error(key, message);
        
        listAdd(fault.ERRORTABLE, err);
        
        //debug("createErrorDetail.Output: fault = " + fault);    
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
        
        //if (wsc.fault_ErrorDetail != null) {
          //  ErrorDetail fault = wsc.fault_ErrorDetail;
            //faultMsg = fault.message; 
        //}
        
        if (wsc.fault_FaultDetail.ERRORTABLE != null) {
            if(listSize(wsc.fault_FaultDetail.ERRORTABLE) >= 1 ) {
                ERRORTABLE err = listGet(wsc.fault_FaultDetail.ERRORTABLE,0);
                faultMsg = err.MESSAGE;
            }
        }
        debug("getFaultMessage.Output: faultMsg = " + faultMsg);        
        return faultMsg;   
    }
    
    
    PayloadI038 extractOutboundS4Request_I038( string hexString) {
        //ResponseHeader_Payload rfcResponse = udrCreate(ResponseHeader_Payload);
        debug("-------------------------");
        debug("Function Name: extractOutboundS4Request_I038( string hexString)");
        debug("extractOutboundS4Request_I038.Input: hexString = " + hexString);
        bytearray decodingBA = hexStringToBytearray(hexString);
        debug ("decodingBA " + decodingBA  );
        list<PayloadI038> reqList = listCreate(PayloadI038); 
        string result = udrDecode("SVC0001_Request_Decoder",reqList ,decodingBA);
        
        debug ("result " + result  );
        if (result == null) {  
            debug("length of reqList", (string) listSize(reqList));
            return listGet(reqList,0);
            //return null;
        } else {
            debug("extractOutboundS4Request_I003.Output: decode failed!" );
            return null;   
        } 
        
    // return null;
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
              
    
MultiForwardingUDR createPostInvoiceToNeFRFile(ConsumeCycleUDR ccu, string intfID, string filename,int startPoint, int endPoint, map<string,string> prefixMap) { 
        debug("-------------------------");
        debug("Function Name: createPostInvoiceToNeFRFile()");
        debug("createPostInvoiceToNeFRFile.System Id:" + sysId);
        debug("createPostInvoiceToNeFRFile.Input: ccu = " + ccu);
        
        
    CCUData ccud = (CCUData) ccu.Data;
    I_PatientBillData extUdr = (I_PatientBillData) ccud.extUdr; //ccud.extUdr = subvPatientDetails;
    //I_Bill req = listGet(extUdr.Bill, 0);
    bytearray content = baCreate(0);
    bytearray IT_content = baCreate(0);
    boolean contentAvailable = false;
    string headerStr = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<PatientBillData>\n";
    string footerStr = "</PatientBillData>";   
    bytearray header;
    bytearray footer;   
    string prefix = listGet(extUdr.Bill, startPoint).Institution; 
    debug("IN Loop - Startpoint = " + startPoint + " EndPoint = "+ endPoint);
    
    UdrInfo udrInfo = ccud.udrInfo;
    string INTF_TXN_ID =  udrInfo.INTF_TXN_ID;
    
        if(extUdr.Bill != null) {

        for(int i = startPoint; i <endPoint; i++) {
            I_Bill rec = listGet(extUdr.Bill, i);
            bytearray ba = udrEncode("PostInvoiceToNeFR_Bill_Encoder", rec);
      
            IT_content = baAppend(IT_content, ba);
            debug("createPostInvToNEFRFile_content: " + IT_content);
          //  count++;
        }
        strToBA(header,headerStr);
        strToBA(footer,footerStr);
       
            string req_str = baToStr(IT_content);
            string replaceUTF = "<\\?xml version=\"1.0\" encoding=\"ISO-8859-1\"\\?>\n";
            string newcont = strREReplaceAll(req_str, replaceUTF, "");
            debug("newcont:" + newcont);
            string replaceXmlns = " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"";
            bytearray ba_Final;
            newcont = strREReplaceAll(newcont, replaceXmlns, "");
            //string remove_tab = "  ";
            //newcont = strREReplaceAll(newcont, remove_tab, "");
            strToBA(ba_Final, newcont);
            
        ba_Final = baAppend(header, ba_Final);
        content = baAppend(ba_Final,footer);
        contentAvailable = true;
        
    } else {
        contentAvailable = true;
        content = udrEncode("PostInvoiceToNeFR_Encoder", extUdr);
    }
    
    debug("contentAvailable = " + contentAvailable);
    
    if (contentAvailable)
    {
        string sDate, NewPath;
        dateToString(sDate, dateCreateNow(), "yyyyMMdd"); 
        string institutionCode = setFilenamePrefix(prefix, prefixMap);
        string systemName = "BT";//req.SystemID;
       // string additionalCharacter = getRunningNumber(institutionCode);
        
        string Filename = institutionCode + "_BT_in" + sDate + left_pad(filename, "0", 5) + ".xml";
        if(INTF_TXN_ID != null && INTF_TXN_ID != "")
            Filename = Filename + "_" + INTF_TXN_ID;
        NewPath = intfID + "/Output";
        debug("createPostInvoiceToNeFRFile.Output: createMfUdr()");
        
        return createMfUdr(NewPath, Filename, content);
    }
    else
    {
        debug("createPostInvoiceToNeFRFile.Output: Failed to create MultiForwarding UDR");
        
        return null;
    } 
        
}
    
    
string getRunningNumber(string institutionCode){
    debug("-------------------------");
    debug("Function Name: getRunningNumber()");
    debug("getRunningNumber.System Id:" + sysId);
    debug("getRunningNumber.Input: institutionCode = " + institutionCode);
    
    int counter;
    
    //reset map
    debug("resetTime: " + additionalNumResetTime);
    debug("dateDiff(dateCreateNow(), resetTime): " + dateDiff(dateCreateNow(), additionalNumResetTime));
    if(dateDiff(dateCreateNow(), additionalNumResetTime) >= 0){
        mapClear(instAdditionalCodeMap);
        additionalNumResetTime = getNextResetTimeAdditionalNum();
        debug("map cleared");
    }
    debug(instAdditionalCodeMap);
    if(!mapContains(instAdditionalCodeMap, institutionCode)){
        counter = 1;
        mapSet(instAdditionalCodeMap, institutionCode, counter);
    }else{
        counter = mapGet(instAdditionalCodeMap, institutionCode) + 1;
        
        if(counter > 99999){
            counter = 1;
        }
        
        mapSet(instAdditionalCodeMap, institutionCode, counter);
    }
    
    string additionalCharacter = left_pad((string) counter, "0", 5);
    return additionalCharacter;
}

date getNextResetTimeAdditionalNum(){
    date nextResetTime = dateCreateNow();
    dateAddDays(nextResetTime, 1);
    dateSetTime(nextResetTime, 0, 0, 0); 
    
    return nextResetTime;
}

int getEndPosition(CCUData ccud, int position){
    debug("-------------------------");
    debug("Function Name: getEndPosition()");
    debug("getEndPosition.Input: key = " + position);
    
    I_PatientBillData extUdr = (I_PatientBillData) ccud.extUdr;
    
    int batchSize;
    int currentCount = 1;
    strToInt(batchSize, externalReferenceGet("ZZR_SVC0001.PRF_EXR", "SVC0001_BATCH_SIZE"));
    string currentKey = listGet(extUdr.Bill, position).Institution;
    int i = position;
    for(; i<listSize(extUdr.Bill); i++){
        string key = listGet(extUdr.Bill, i).Institution;
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
    
}

string createPostInvoiceToNeFRFileFn(ConsumeCycleUDR ccu, string Filename) {
    debug("-------------------------");
    debug("Function Name: createPFSReportFileFn()");
    debug("createPFSReportFileFn.System Id:" + sysId);
    debug("createPFSReportFileFn.Input: ccu = " + ccu);
    
    CCUData ccud = (CCUData) ccu.Data;
    //PFSReportFile_Int extUdr = (PFSReportFile_Int) ccud.extUdr;
    
    string filename = Filename; 

    debug("createPostInvoiceToNeFRFileFn.Output: FILENAME = " + filename);     
    return filename;
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
