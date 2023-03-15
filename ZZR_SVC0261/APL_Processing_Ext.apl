<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0261" Key="DZ11651768306865" Name="APL_Processing_Ext" Owner="D_WONG" Type="APL Code" encrypted="false" ver="6.0">
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
import ultra.ZZR_CA_UFL.UFL_Audit;

import ultra.ZZR_SVC0261.UFL_CM_OUTBOUND_Request_SVC0261;
import ultra.ZZR_SVC0261.UFL_postEpisodicReportFile;
import apl.ZZC_CA_APL.APL_Common; 
import apl.ZZC_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Audit_Constants;
import apl.ZZR_CA_APL.APL_Audit_Functions;
import apl.ZZR_SVC0261.APL_Common;
import apl.ZZR_CA_APL.APL_Common_Variables;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;


//20211207 - Code table requirement
import apl.ZZC_CA_APL.APL_Common_Functions;
import apl.ZZC_CA_APL.APL_Common_Constants;

//2021-12-20 - Common error handling
import apl.ZZC_CA_APL.APL_Error_Functions;
import apl.ZZ_CA_APL.APL_Common_Functions;

boolean mapWscToExtUdr(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: mapWscToExtUdr()");
    debug("mapWscToExtUdr.System Id:" + sysId);
    debug("mapWscToExtUdr.Input: ccu = " + ccu);
    
    boolean isMapped = false;
    CCUData ccud = (CCUData) ccu.Data;    
       
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    boolean isValid = true;
        
    episodicSubsidyRequest_Int extUdr = udrCreate(episodicSubsidyRequest_Int);
   
    extUdr.header = createHeader(ccud.rfcReq);
    extUdr.footer = createFooter(ccud.rfcReq);
    list<EpisodicSubsidyRequest_TI> record = createRecord(ccud.rfcReq);
    ccud.udrInfo.IN_RECORD_COUNT = listSize(record);
    
    
        isMapped = true;

    extUdr.record = record;
    
    ccud.extUdrType = EXT_UDR_TYPE_CHARGE_FILE;
    ccud.extUdr = extUdr;
    ccud.outFilenameList = listCreate(string);
    ccud.route = ROUTE_OUTBOUND_SIMPLE;
        
    debug("mapWscToExtUdr.Output: isMapped = " + isMapped);         
    return isMapped;
}
/*
boolean strToDate(date dateVar, string stringValue, string format)
{
    debug("-------------------------");
    debug("Function Name: strToDate()");
    debug("strToDate.System Id:" + sysId);
    debug("strToDate.Input: stringValue = " + stringValue);
    StringValue = 
    stringValue = 
    Resultdate 
}
*/

Header_TI createHeader(any rec) {
    debug("-------------------------");
    debug("Function Name: createHeader()");
    debug("createHeader.System Id:" + sysId);
    debug("createHeader.Input: udrInfo = " + rec);

    PayloadI625 pl = (PayloadI625) rec;
    Header_TI header = udrCreate(Header_TI);
    
    header.header_id = pl.header_id;
    header.Date = pl.Date;
    header.time = pl.time;
    
    debug("NewcreateHeader.Output: header = " + header);      
    return header;
}

Footer_TI createFooter(any rec) {
    debug("-------------------------");
    debug("Function Name: createHeader()");
    debug("createFooter.System Id:" + sysId);
    debug("createFooter.Input: udrInfo = " + rec);
    
    PayloadI625 pl = (PayloadI625) rec;
    Footer_TI footer = udrCreate(Footer_TI);
    footer.trailer_identifier = pl.trailer_identifier;
    
    debug("createFooter.Output: header = " + footer);      
    return footer;
}

list<EpisodicSubsidyRequest_TI> createRecord(any rec) { 
    debug("-------------------------");
    debug("Function Name: createRecord()");
    debug("createRecord.System Id:" + sysId);
    debug("createRecord.Input: wsc = " + rec);
        
    
    PayloadI625 pl = (PayloadI625) rec;
    string currentDate; dateToString(currentDate, dateCreateNow(), "yyyyMMdd");
    list<EpisodicSubsidyRequest_TI> recordList = listCreate(EpisodicSubsidyRequest_TI);
    
    list<details_itm> details_itm = pl.Details.details_itm;
    listSort(details_itm, healthcare_facility, ascending);
    for (int i = 0; i<listSize(details_itm); i++) {
        details_itm  Details_itm= listGet(details_itm, i);
        
        EpisodicSubsidyRequest_TI record = udrCreate(EpisodicSubsidyRequest_TI);
        debug("SUBSIDY = " + Details_itm );
        debug("SUBSIDY scheme = "+ Details_itm.subsidy_scheme);
        
        subsidy_scheme test001 = udrCreate(subsidy_scheme);
        record.UniqueTransactionID = Details_itm.unique_transaction_id;
        record.HealthcareFacility = Details_itm.healthcare_facility;
        record.UserID = Details_itm.user_id; // From CM table ????
        record.UIN = Details_itm.nric;
        record.CitizenshipStatus = Details_itm.citizenship_status;
        record.DateOfBirth = convertDateTimeFormat(Details_itm.date_of_birth, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
        record.Setting = Details_itm.setting;
        record.EpisodicUpdateCategory = Details_itm.episodic_update_category;
        if(Details_itm.episodic_update_category == "EUC001"){
            record.EpisodicReasonCode = TransBTToLegacy (Details_itm.episodic_reason_code, MT_EXEMPT_REASON, "", currentDate);
        }else if(Details_itm.episodic_update_category == "EUC002"){
            record.EpisodicReasonCode = TransBTToLegacy (Details_itm.episodic_reason_code, SUBSIDY_DEVIATION_REASON, "", currentDate);
            record.SubsidySchemes = udrCreate(SubsidySchemes);
            record.SubsidySchemes.SubsidyScheme = listCreate(SubsidyScheme);
            
            for(int j = 0; j<listSize(Details_itm.subsidy_scheme.subsidy_scheme_itm); j++){
                SubsidyScheme SubsidyScheme = udrCreate(SubsidyScheme);
                SubsidyScheme.SchemeCode = listGet(Details_itm.subsidy_scheme.subsidy_scheme_itm, j).scheme_code;
                SubsidyScheme.OriginalSubsidyBand = listGet(Details_itm.subsidy_scheme.subsidy_scheme_itm, j).original_sub_band;
                SubsidyScheme.DeviatedSubsidyBand = listGet(Details_itm.subsidy_scheme.subsidy_scheme_itm, j).deviated_sub_band;
                listAdd(record.SubsidySchemes.SubsidyScheme, SubsidyScheme);
            }
        }
        record.ApprovalDate = convertDateTimeFormat(Details_itm.approval_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);;
        record.Remarks = Details_itm.remarks;
        record.AVTier = Details_itm.av_tier;
        
        record.PCHI = (int)Details_itm.pchi;
        if(record.PCHI == 0){
            udrUnsetPresent(record.PCHI);
        }
        
        record.PCFI = (int)Details_itm.pcfi;
        if(record.PCFI == 0){
            udrUnsetPresent(record.PCFI);
        }
        
        record.PAN = Details_itm.pan_episodic_ref_id;
        record.SubmissionDate = convertDateTimeFormat(Details_itm.submission_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
        listAdd(recordList, record);
    }
    
    debug("createRecord.Output: record = " + recordList);    
    return recordList;
}]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
