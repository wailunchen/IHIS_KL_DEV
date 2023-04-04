<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0002" Key="DZ11636098478406" Name="APL_Common" Owner="A_SHIDI" Type="APL Code" encrypted="false" ver="6.0">
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

import apl.ZZR_CA_APL.APL_Common_Variables;

import ultra.ZZR_SVC0002.UFL_CM_OUTBOUND_Request_List_SVC0002;
import apl.ZZC_CA_APL.APL_Common;
import apl.ZZC_CA_APL.APL_Error_Functions;


final string SVC0002_DATE_FORMAT = "YYYY-MM-DD"; //EndDate, StartDate

final string PRF_EXR_SVC0002 = "ZZR_SVC0002.PRF_EXR";
final string SVC0002_SVC_ID = "SVC0002";

FaultDetail createErrorDetail(string key, string message, WSCycle_cmoutbound wsc) {
    debug("-------------------------");
    debug("Function Name: createErrorDetail()");
    debug("createErrorDetail.System Id:" + sysId);
    debug("createErrorDetail.Input: key = " + key);
    debug("createErrorDetail.Input: message = " + message);
    
    FaultDetail fault = udrCreate(FaultDetail);
    
    fault.HEADER = udrCreate(HEADER);
    fault.HEADER = wsc.param.HEADER;
    
    //Populate Status for error
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

Payload extractOutboundS4Request( string hexString) {
    debug("-------------------------");
    debug("Function Name: extractOutboundS4Request( string hexString)");
    debug("extractOutboundS4Request.Input: hexString = " + hexString);
    bytearray decodingBA = hexStringToBytearray(hexString);
    
    list<Payload> reqList = listCreate(Payload);
    string result= udrDecode("Payload_List_Decoder",reqList ,decodingBA);
    
    if (result == null) {
        debug("length of reqList", (string) listSize(reqList));
        return listGet(reqList,0);
    } else {
        debug("extractOutboundS4Request.Output: decode failed!" );
        return null;   
    }
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
