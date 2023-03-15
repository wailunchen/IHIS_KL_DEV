<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="ZZR_SVC0001" Key="DZ11640844270194" Name="APL_Processing_Ext" Owner="D_LIEW" Type="APL Code" encrypted="false" ver="6.0">
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

import ultra.ZZR_SVC0001.UFL_CM_OUTBOUND_Request_I038;
import ultra.ZZR_SVC0001.UFL_PostInvoiceToNeFRFile;

import apl.ZZC_CA_APL.APL_Common; //left_pad()
import apl.ZZC_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Functions;
import apl.ZZR_CA_APL.APL_Common_Constants;
import apl.ZZR_CA_APL.APL_Audit_Constants;
import apl.ZZR_CA_APL.APL_Audit_Functions;

import apl.ZZR_SVC0001.APL_Common;
//import apl.ZZR_SVC0001.APL_Common_Functions;

import apl.ZZR_CA_APL.APL_Common_Variables;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;


/* not used
void clearExtUdrCharge(WSCycle_charge extUdr) {
    if (extUdr.fault_FaultDetail != null)
        extUdr.fault_FaultDetail = null;
    if (extUdr.response != null)
        extUdr.response = null;
    if (extUdr.errorMessage != null)
        extUdr.errorMessage = null;
}*/

boolean mapWscToExtUdr(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: mapWscToExtUdr()");
    debug("mapWscToExtUdr.System Id:" + sysId);
    debug("mapWscToExtUdr.Input: ccu = " + ccu);
    
    boolean isMapped = false;
    CCUData ccud = (CCUData) ccu.Data;    
    
    //ccud.wsc = (WSCycle_cmoutbound) ccud.cpUdr;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    //boolean isValid = validateRequest ( ccu );
    boolean isValid = true;
    
    if ( !isValid )
        return isMapped;
    
    I_PatientBillData extUdr = udrCreate(I_PatientBillData);

   // PriceMasterHeader_TI header = createHeader(ccud.udrInfo);
    list<I_Bill> record = createRecord(ccud.rfcReq);
    ccud.udrInfo.IN_RECORD_COUNT = listSize(record);
  //  PriceMasterTrailer_TI trailer = createTrailer(ccud.udrInfo);
    
   // if (record.chargingDate != null) {
        isMapped = true;
    //}
   // extUdr.header  = header;
    extUdr.Bill  = record;
   // extUdr.trailer = trailer;
    
    ccud.extUdrType = EXT_UDR_TYPE_CHARGE_FILE;
    ccud.extUdr = extUdr;
    
    // set the route 
//     if (isComplexType(wsc))
//         ccud.route = ROUTE_OUTBOUND_COMPLEX;
//     else
    ccud.route = ROUTE_OUTBOUND_SIMPLE;
        
    debug("mapWscToExtUdr.Output: isMapped = " + isMapped);         
    return isMapped;
}

list<I_Bill> createRecord(any rec) {
    debug("-------------------------");
    debug("Function Name: createRecord()");
    debug("createRecord.System Id:" + sysId);
    debug("createRecord.Input: wsc = " + rec);
        
    
    PayloadI038 pl = (PayloadI038) rec;    
    

    date billDate, DOB, visitDate, disChargeDate, InstalEndDate,InstalStartDate;
    list<I_Bill> recordList = listCreateSync(I_Bill);
    list<Request_Itm> RequestItmlist = pl.request_itm;
    listSort(RequestItmlist, bill_head.institution, ascending);
    for (int i = 0; i<listSize(RequestItmlist); i++) {
            
        Request_Itm RequestItm = listGet(RequestItmlist, i);
        I_Bill record = udrCreate(I_Bill);
                    
        record.Action = RequestItm.bill_head.action;
        record.Institution = RequestItm.bill_head.institution;
        record.InstitutionBillID = RequestItm.bill_head.inst_bill_id;
        
        record.BillDate = convertDateTimeFormat(RequestItm.bill_head.bill_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
        
        record.UniqueTransactionID = RequestItm.bill_head.uniq_txn_id;
        
       if (record.Action != "D") {
        I_BillBreakdown BillBreakdown = udrCreate(I_BillBreakdown);
        I_BillCharacteristics BillCharacteristics = udrCreate(I_BillCharacteristics);
        I_PatientBioData PatientBioData = udrCreate(I_PatientBioData);
        I_ResidentialAddress ResidentialAddress = udrCreate(I_ResidentialAddress);
         
        // PatientBioData
        PatientBioData.PatientName =RequestItm.pat_bio_data.patient_name;
        PatientBioData.IDNumber = RequestItm.pat_bio_data.patient_id_no;
        PatientBioData.IDType = RequestItm.pat_bio_data.patient_id_type;
        
        if(udrIsPresent(RequestItm.pat_bio_data.date_of_birth) && !isNull(RequestItm.pat_bio_data.date_of_birth))
            PatientBioData.DateOfBirth = convertDateTimeFormat(RequestItm.pat_bio_data.date_of_birth, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
       
        PatientBioData.Nationality = RequestItm.pat_bio_data.nationality;
        PatientBioData.Race = RequestItm.pat_bio_data.race;
        PatientBioData.Gender = RequestItm.pat_bio_data.gender;
        PatientBioData.Telephone = RequestItm.pat_bio_data.tel_number;
        PatientBioData.Email = RequestItm.pat_bio_data.email;
       
        record.PatientBioData = PatientBioData;
       
        // ResidentialAddress
        ResidentialAddress.BlockNumber = RequestItm.pat_res_addr.block;
        ResidentialAddress.BuildingName = RequestItm.pat_res_addr.building;
        ResidentialAddress.CountryCode = RequestItm.pat_res_addr.country;
        ResidentialAddress.FloorNumber = RequestItm.pat_res_addr.floor;
        ResidentialAddress.PostalCode = RequestItm.pat_res_addr.postal_code;
        ResidentialAddress.StreetName = RequestItm.pat_res_addr.street;
        ResidentialAddress.UnitNumber = RequestItm.pat_res_addr.unit; 
         
        record.ResidentialAddress = ResidentialAddress;   
        
        //BillCharacteristics
        BillCharacteristics.ServiceType = RequestItm.bill_char.visit_info.service_type;
        
        if(udrIsPresent(RequestItm.bill_char.visit_info.visit_date) && !isNull(RequestItm.bill_char.visit_info.visit_date))       
            BillCharacteristics.AdmissionVisitDate =convertDateTimeFormat(RequestItm.bill_char.visit_info.visit_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
        
        BillCharacteristics.AdmissionVisitTime = RequestItm.bill_char.visit_info.visit_time;
        BillCharacteristics.BillTypeIndicator = RequestItm.bill_char.visit_info.bill_type_ind;
        
        if(udrIsPresent(RequestItm.bill_char.visit_info.discharge_date) && !isNull(RequestItm.bill_char.visit_info.discharge_date))
            BillCharacteristics.DischargeDate = convertDateTimeFormat(RequestItm.bill_char.visit_info.discharge_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
        
        BillCharacteristics.DischargeDestinationInstitution = RequestItm.bill_char.visit_info.discharge_des_inst;
        BillCharacteristics.DischargeDestinationType = RequestItm.bill_char.visit_info.discharge_des_type;
        
        if(udrIsPresent(RequestItm.bill_char.visit_info.discharge_time) && !isNull(RequestItm.bill_char.visit_info.discharge_time))
            BillCharacteristics.DischargeTime = RequestItm.bill_char.visit_info.discharge_time;
            
        BillCharacteristics.DischargeWardType = RequestItm.bill_char.visit_info.discharge_ward_type;
        BillCharacteristics.MTSubsidyRate = RequestItm.bill_char.visit_info.mt_sub_band;
        BillCharacteristics.NeonateMotherIDNumber = RequestItm.bill_char.visit_info.mother_id_no;
        BillCharacteristics.PatientClassAdmission = RequestItm.bill_char.visit_info.pat_class_admission;
        BillCharacteristics.PatientClassDischarge = RequestItm.bill_char.visit_info.pat_class_discharge;
        BillCharacteristics.PrimaryDiagnosisCode = RequestItm.bill_char.visit_info.pri_diag_code;
        BillCharacteristics.ReferralSourceType = RequestItm.bill_char.visit_info.ref_source_type;
        BillCharacteristics.ReferringSourceInstitution = RequestItm.bill_char.visit_info.ref_source_inst;       
        

 
        I_SecondaryDiagnosisCodes SecondaryDiagnosisCodes = udrCreate(I_SecondaryDiagnosisCodes);
        SecondaryDiagnosisCodes.SecondaryDiagnosisCode = listCreate(string); 
        I_OperationCodes OperationCodes = udrCreate(I_OperationCodes);
        OperationCodes.OperationCode = listCreate(string);
        
        list<Mt_Subs_Info_Itm> MtSubsInfoItmList = listCreate(Mt_Subs_Info_Itm); 
        MtSubsInfoItmList = RequestItm.bill_char.mt_subs_info.mt_subs_info_itm;
         
        if (MtSubsInfoItmList != null) {
           I_MTSubsidies MTSubsidies = udrCreate(I_MTSubsidies);
           list<I_MTSubsidy> MTSubsidyList = listCreate(I_MTSubsidy);
                                    
            for (int j = 0; j < listSize(MtSubsInfoItmList); j++) {
        
                Mt_Subs_Info_Itm MtSubsInfoItm = listGet(MtSubsInfoItmList, j);    
                I_MTSubsidy MTSubsidy = udrCreate(I_MTSubsidy);
                
                MTSubsidy.MTBand = MtSubsInfoItm.mt_band;
                MTSubsidy.MTScheme = MtSubsInfoItm.mt_scheme;
                
                listAdd(MTSubsidyList,MTSubsidy);
            }                     
            MTSubsidies.MTSubsidy = MTSubsidyList;
            BillCharacteristics.MTSubsidies  = MTSubsidies;                                  
        
        }
                                                                                                                                                                                                                              
       listAdd(SecondaryDiagnosisCodes.SecondaryDiagnosisCode, RequestItm.bill_char.visit_info.sec_diag_code);
       BillCharacteristics.SecondaryDiagnosisCodes  = SecondaryDiagnosisCodes;
       
       listAdd(OperationCodes.OperationCode, RequestItm.bill_char.visit_info.operation_code);
       BillCharacteristics.OperationCodes  = OperationCodes;
        
       record.BillCharacteristics = BillCharacteristics;
       
           //BillBreakdown
    I_TotalChargeBeforeSubsidy TotalChargeBeforeSubsidy  = udrCreate(I_TotalChargeBeforeSubsidy);
    I_GovernmentSubsidy GovernmentSubsidy = udrCreate(I_GovernmentSubsidy);
    I_GST GST = udrCreate(I_GST);
    I_SpecificSubsidySchemesNonGovs SpecificSubsidySchemesNonGovs = udrCreate(I_SpecificSubsidySchemesNonGovs);
    list<I_SpecificSubsidySchemeNonGov> SpecificSubsidySchemeNonGovList = listCreate(I_SpecificSubsidySchemeNonGov);
    I_SpecificSubsidySchemesGovs SpecificSubsidySchemesGovs = udrCreate(I_SpecificSubsidySchemesGovs);
    list<I_SpecificSubsidySchemeGov> SpecificSubsidySchemeGovList = listCreate(I_SpecificSubsidySchemeGov);
    I_ThirdPartyPayers ThirdPartyPayers= udrCreate(I_ThirdPartyPayers);
    list<I_ThirdPartyPayer> ThirdPartyPayerList = listCreate(I_ThirdPartyPayer);
    I_Insurances Insurances = udrCreate(I_Insurances);
    list<I_Insurance> InsuranceList = listCreate(I_Insurance);
    I_Medisaves Medisaves = udrCreate(I_Medisaves);
    list<I_Medisave> MedisaveList = listCreate(I_Medisave);
    I_DiscretionaryFANonGovernments DiscretionaryFANonGovernments = udrCreate(I_DiscretionaryFANonGovernments);
    list<I_DiscretionaryFANonGovernment> DiscretionaryFANonGovernmentList = listCreate(I_DiscretionaryFANonGovernment);
    I_DiscretionaryFAGovernments DiscretionaryFAGovernments = udrCreate(I_DiscretionaryFAGovernments);
    list<I_DiscretionaryFAGovernment> DiscretionaryFAGovernmentList = listCreate(I_DiscretionaryFAGovernment);
    I_OtherBillPaymentInformation OtherBillPaymentInformation = udrCreate(I_OtherBillPaymentInformation);

    TotalChargeBeforeSubsidy.Total = RequestItm.bill_breakdown.tot_charge_subs.tot_charge;
	TotalChargeBeforeSubsidy.TransferredCharges = RequestItm.bill_breakdown.tot_charge_subs.trans_charges;
	TotalChargeBeforeSubsidy.AE = RequestItm.bill_breakdown.tot_charge_subs.ae;
	TotalChargeBeforeSubsidy.Packages = RequestItm.bill_breakdown.tot_charge_subs.packages;
	TotalChargeBeforeSubsidy.RoomCharges = RequestItm.bill_breakdown.tot_charge_subs.room_charges;
	TotalChargeBeforeSubsidy.TreatmentProcedures = RequestItm.bill_breakdown.tot_charge_subs.treat_proced;
	TotalChargeBeforeSubsidy.ConsultProfessionalFee = RequestItm.bill_breakdown.tot_charge_subs.prof_fees;
	TotalChargeBeforeSubsidy.AlliedHealthServices = RequestItm.bill_breakdown.tot_charge_subs.alied_health_serv;
	TotalChargeBeforeSubsidy.SurgeonFee = RequestItm.bill_breakdown.tot_charge_subs.surgeon_fee;
	TotalChargeBeforeSubsidy.SurgeryFacility = RequestItm.bill_breakdown.tot_charge_subs.surgery_facility;
	TotalChargeBeforeSubsidy.AnaesthetistFee = RequestItm.bill_breakdown.tot_charge_subs.anaesthtic_fee;
	TotalChargeBeforeSubsidy.Implants = RequestItm.bill_breakdown.tot_charge_subs.implants;
	TotalChargeBeforeSubsidy.Devices = RequestItm.bill_breakdown.tot_charge_subs.devices;
	TotalChargeBeforeSubsidy.DrugsSDL = RequestItm.bill_breakdown.tot_charge_subs.drugs_sdl;
	TotalChargeBeforeSubsidy.DrugsSDL2 = RequestItm.bill_breakdown.tot_charge_subs.drugs_sdl;
	TotalChargeBeforeSubsidy.DrugsMAF = RequestItm.bill_breakdown.tot_charge_subs.drugs_maf;
	TotalChargeBeforeSubsidy.DrugsOtherNS = RequestItm.bill_breakdown.tot_charge_subs.drugs_ons;
	TotalChargeBeforeSubsidy.InvestigationsRadiology = RequestItm.bill_breakdown.tot_charge_subs.invest_radiology;
	TotalChargeBeforeSubsidy.InvestigationsLaboratory = RequestItm.bill_breakdown.tot_charge_subs.invest_laboratory;
	TotalChargeBeforeSubsidy.InvestigationsSpecialised = RequestItm.bill_breakdown.tot_charge_subs.invest_specialised;
	TotalChargeBeforeSubsidy.Consumables = RequestItm.bill_breakdown.tot_charge_subs.other_consumables;
	TotalChargeBeforeSubsidy.Transport = RequestItm.bill_breakdown.tot_charge_subs.transport;
	TotalChargeBeforeSubsidy.Others = (udrIsPresent(RequestItm.bill_breakdown.tot_charge_subs.others))?zeroDecimalPointPadding(RequestItm.bill_breakdown.tot_charge_subs.others,2):0.00;

	TotalChargeBeforeSubsidy.Vaccines = RequestItm.bill_breakdown.tot_charge_subs.vaccines;

    BillBreakdown.TotalChargeBeforeSubsidy = TotalChargeBeforeSubsidy;

    GovernmentSubsidy.Total = RequestItm.bill_breakdown.gov_subs.tot_charge;
	GovernmentSubsidy.AE = RequestItm.bill_breakdown.gov_subs.ae;
	GovernmentSubsidy.Packages = RequestItm.bill_breakdown.gov_subs.packages;
	GovernmentSubsidy.RoomCharges = RequestItm.bill_breakdown.gov_subs.room_charges;
	GovernmentSubsidy.TreatmentProcedures = RequestItm.bill_breakdown.gov_subs.treat_proced;
	GovernmentSubsidy.ConsultProfessionalFee = RequestItm.bill_breakdown.gov_subs.prof_fees;
	GovernmentSubsidy.AlliedHealthServices = RequestItm.bill_breakdown.gov_subs.alied_health_serv;
	GovernmentSubsidy.SurgeonFee = RequestItm.bill_breakdown.gov_subs.surgeon_fee;
	GovernmentSubsidy.SurgeryFacility = RequestItm.bill_breakdown.gov_subs.surgery_facility;
	GovernmentSubsidy.AnaesthetistFee = RequestItm.bill_breakdown.gov_subs.anaesthtic_fee;
	GovernmentSubsidy.Implants = RequestItm.bill_breakdown.gov_subs.implants;
	GovernmentSubsidy.Devices = RequestItm.bill_breakdown.gov_subs.devices;
	GovernmentSubsidy.DrugsSDL = RequestItm.bill_breakdown.gov_subs.drugs_sdl;
	GovernmentSubsidy.DrugsSDL2 = RequestItm.bill_breakdown.gov_subs.drugs_sdl;
	GovernmentSubsidy.DrugsMAF = RequestItm.bill_breakdown.gov_subs.drugs_maf;
	GovernmentSubsidy.DrugsOtherNS = RequestItm.bill_breakdown.gov_subs.drugs_ons;
	GovernmentSubsidy.InvestigationsRadiology = RequestItm.bill_breakdown.gov_subs.invest_radiology;
	GovernmentSubsidy.InvestigationsLaboratory = RequestItm.bill_breakdown.gov_subs.invest_laboratory;
	GovernmentSubsidy.InvestigationsSpecialised = RequestItm.bill_breakdown.gov_subs.invest_specialised;
	GovernmentSubsidy.Consumables = RequestItm.bill_breakdown.gov_subs.other_consumables;
	GovernmentSubsidy.Transport = RequestItm.bill_breakdown.gov_subs.trans_charges;
	GovernmentSubsidy.Others = (udrIsPresent(RequestItm.bill_breakdown.gov_subs.others))?zeroDecimalPointPadding(RequestItm.bill_breakdown.gov_subs.others,2):0.00;

	GovernmentSubsidy.Vaccines = RequestItm.bill_breakdown.gov_subs.vaccines;

    BillBreakdown.GovernmentSubsidy = GovernmentSubsidy;
    
    GST.AmountAbsorbed = (udrIsPresent(RequestItm.bill_breakdown.gst_amount.amount_absorbed))?(string)zeroDecimalPointPadding(RequestItm.bill_breakdown.gst_amount.amount_absorbed,2):null;
    GST.AmountCharged = (udrIsPresent(RequestItm.bill_breakdown.gst_amount.amount_charged))?(string)zeroDecimalPointPadding(RequestItm.bill_breakdown.gst_amount.amount_charged,2):null;
    //RequestItm.bill_breakdown.gst_amount.amount_charged;
     
    BillBreakdown.GST = GST;
    
    
    list<Nongov_Subs_Scheme_Itm> NongovSubsSchemeItmList = listCreate(Nongov_Subs_Scheme_Itm);
    NongovSubsSchemeItmList = RequestItm.bill_breakdown.nongov_subs_scheme.nongov_subs_scheme_itm;
    
    if (NongovSubsSchemeItmList != null) {
        I_SpecificSubsidySchemeNonGov SpecificSubsidySchemeNonGov = udrCreate(I_SpecificSubsidySchemeNonGov);                         
        for (int j = 0; j < listSize(NongovSubsSchemeItmList); j++) {
        
            Nongov_Subs_Scheme_Itm NongovSubsSchemeItm = listGet(NongovSubsSchemeItmList, j);    
            
            SpecificSubsidySchemeNonGov.SpecificSubsidySchemeNonGovAmount = NongovSubsSchemeItm.amount;
            SpecificSubsidySchemeNonGov.SpecificSubsidySchemeNonGovType = NongovSubsSchemeItm.type;
            
            listAdd(SpecificSubsidySchemeNonGovList, SpecificSubsidySchemeNonGov);
         }                     
       
    SpecificSubsidySchemesNonGovs.SpecificSubsidySchemeNonGov  = SpecificSubsidySchemeNonGovList;                                  
    }
    BillBreakdown.SpecificSubsidySchemesNonGovs  = SpecificSubsidySchemesNonGovs;

        
   
    list<Gov_Subs_Scheme_Itm> GovSubsSchemeItmList = listCreate(Gov_Subs_Scheme_Itm);
    GovSubsSchemeItmList = RequestItm.bill_breakdown.gov_subs_scheme.gov_subs_scheme_itm;
    
    if (GovSubsSchemeItmList != null) {
         I_SpecificSubsidySchemeGov SpecificSubsidySchemeGov = udrCreate(I_SpecificSubsidySchemeGov);                         
        for (int j = 0; j < listSize(GovSubsSchemeItmList); j++) {
        
            Gov_Subs_Scheme_Itm GovSubsSchemeItm = listGet(GovSubsSchemeItmList, j);    
            
            SpecificSubsidySchemeGov.SpecificSubsidySchemeGovAmount = GovSubsSchemeItm.amount;
            SpecificSubsidySchemeGov.SpecificSubsidySchemeGovType = GovSubsSchemeItm.type;
            
            listAdd(SpecificSubsidySchemeGovList, SpecificSubsidySchemeGov);
         }                     
       
    SpecificSubsidySchemesGovs.SpecificSubsidySchemeGov  = SpecificSubsidySchemeGovList;                                  
    }
    BillBreakdown.SpecificSubsidySchemesGovs  = SpecificSubsidySchemesGovs;


    
    list<Third_Party_Payor_Itm> ThirdPartyPayorItmList = listCreate(Third_Party_Payor_Itm);
    ThirdPartyPayorItmList = RequestItm.bill_breakdown.third_party_payor.third_party_payor_itm;
    
    if (ThirdPartyPayorItmList != null) {
        I_ThirdPartyPayer ThirdPartyPayer = udrCreate(I_ThirdPartyPayer);                         
        for (int j = 0; j < listSize(ThirdPartyPayorItmList); j++) {
        
            Third_Party_Payor_Itm ThirdPartyPayorItm = listGet(ThirdPartyPayorItmList, j);    
            
            ThirdPartyPayer.ThirdPartyPayerAmount = ThirdPartyPayorItm.amount;
            ThirdPartyPayer.ThirdPartyPayerType = ThirdPartyPayorItm.type;
            
            listAdd(ThirdPartyPayerList, ThirdPartyPayer);
         }                     
       
    ThirdPartyPayers.ThirdPartyPayer  = ThirdPartyPayerList;                                  
    }
    BillBreakdown.ThirdPartyPayers  = ThirdPartyPayers;


    I_Insurance Insurance = udrCreate(I_Insurance);

    Insurance_Itm InsuranceItm = udrCreate(Insurance_Itm);
    InsuranceItm = RequestItm.bill_breakdown.insurance.insurance_itm;
    
  
            
            Insurance.InsuranceAmount = InsuranceItm.amount;
            Insurance.InsuranceType = InsuranceItm.type;
            
            listAdd(InsuranceList, Insurance);
                    
       
    Insurances.Insurance  = InsuranceList;                                  

    BillBreakdown.Insurances  = Insurances;



    list<Medisave_Itm> MedisaveItmList = listCreate(Medisave_Itm);
    MedisaveItmList = RequestItm.bill_breakdown.medisave.medisave_itm;
    
    if (MedisaveItmList != null) {
        I_Medisave Medisave = udrCreate(I_Medisave);                         
        for (int j = 0; j < listSize(MedisaveItmList); j++) {
        
            Medisave_Itm MedisaveItm = listGet(MedisaveItmList, j);    
            
            Medisave.MedisaveClaimableAmount = MedisaveItm.claim_amount;
            Medisave.MedisaveNRIC = MedisaveItm.nric;
            Medisave.MedisaveRelationship = MedisaveItm.relationship;
            
            listAdd(MedisaveList, Medisave);
         }                     
       
    Medisaves.Medisave  = MedisaveList;                                  
    }
    BillBreakdown.Medisaves  = Medisaves;


    
    list<Nongov_Fin_Ass_Itm> NongovFinAssItmList = listCreate(Nongov_Fin_Ass_Itm);
    NongovFinAssItmList = RequestItm.bill_breakdown.nongov_fin_ass.nongov_fin_ass_itm;
    
    if (NongovFinAssItmList != null) {
        I_DiscretionaryFANonGovernment DiscretionaryFANonGovernment = udrCreate(I_DiscretionaryFANonGovernment);                         
        for (int j = 0; j < listSize(NongovFinAssItmList); j++) {
        
            Nongov_Fin_Ass_Itm NongovFinAssItm = listGet(NongovFinAssItmList, j);    
            
            DiscretionaryFANonGovernment.DiscretionaryFANonGovernmentAmount = NongovFinAssItm.amount;
            DiscretionaryFANonGovernment.DiscretionaryFANonGovernmentType = NongovFinAssItm.type;
            
            listAdd(DiscretionaryFANonGovernmentList, DiscretionaryFANonGovernment);
         }                     
       
    DiscretionaryFANonGovernments.DiscretionaryFANonGovernment  = DiscretionaryFANonGovernmentList;                                  
    }
    BillBreakdown.DiscretionaryFANonGovernments  = DiscretionaryFANonGovernments;


    
    list<Gov_Fin_Ass_Itm> GovFinAssItmList = listCreate(Gov_Fin_Ass_Itm);
    GovFinAssItmList = RequestItm.bill_breakdown.gov_fin_ass.gov_fin_ass_itm;
    
    if (GovFinAssItmList != null) {
        I_DiscretionaryFAGovernment DiscretionaryFAGovernment = udrCreate(I_DiscretionaryFAGovernment);                         
        for (int j = 0; j < listSize(GovFinAssItmList); j++) {
        
            Gov_Fin_Ass_Itm GovFinAssItm = listGet(GovFinAssItmList, j);    
            
            DiscretionaryFAGovernment.DiscretionaryFAGovernmentAmount = GovFinAssItm.amount;
            DiscretionaryFAGovernment.DiscretionaryFAGovernmentType = GovFinAssItm.type;
            
            listAdd(DiscretionaryFAGovernmentList, DiscretionaryFAGovernment);
         }                     
       
    DiscretionaryFAGovernments.DiscretionaryFAGovernment  = DiscretionaryFAGovernmentList;                                   
    }
    BillBreakdown.DiscretionaryFAGovernments  = DiscretionaryFAGovernments;
    
    if (udrIsPresent(RequestItm.bill_breakdown.self_payer.others)) {
        bigdec selfpayerOthers;
        strToBigDec(selfpayerOthers,RequestItm.bill_breakdown.self_payer.others);    
        BillBreakdown.Others = zeroDecimalPointPadding(selfpayerOthers,2);
    }
    else
        BillBreakdown.Others = 0.00;
        
    BillBreakdown.SelfPayerPaidIncDeposit = (udrIsPresent(RequestItm.bill_breakdown.self_payer.paid_amount))?zeroDecimalPointPadding(RequestItm.bill_breakdown.self_payer.paid_amount,2):0.00;
    
    if (udrIsPresent(RequestItm.bill_breakdown.self_payer.outstanding)) {
        bigdec selfpayerOutstanding;
        strToBigDec(selfpayerOutstanding,RequestItm.bill_breakdown.self_payer.outstanding);    
        BillBreakdown.SelfPayerOutstanding = zeroDecimalPointPadding(selfpayerOutstanding,2);
    }
    else
        BillBreakdown.SelfPayerOutstanding = 0.00;

    if (udrIsPresent(RequestItm.bill_breakdown.self_payer.bad_debt)) {
        bigdec selfpayerBadDebt;
        strToBigDec(selfpayerBadDebt,RequestItm.bill_breakdown.self_payer.bad_debt);    
        BillBreakdown.SelfPayerBadDebtWriteoff = zeroDecimalPointPadding(selfpayerBadDebt,2);
    }
    else
        BillBreakdown.SelfPayerBadDebtWriteoff = 0.00;    
            
    OtherBillPaymentInformation.DepositCollected = RequestItm.bill_breakdown.other_bill_pay_info.deposit_collected;

    if(udrIsPresent(RequestItm.bill_breakdown.other_bill_pay_info.install_end_date) && !isNull(RequestItm.bill_breakdown.other_bill_pay_info.install_end_date))
        OtherBillPaymentInformation.InstalmentEndDate = convertDateTimeFormat(RequestItm.bill_breakdown.other_bill_pay_info.install_end_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
    
    OtherBillPaymentInformation.InstalmentFrequency = RequestItm.bill_breakdown.other_bill_pay_info.install_frequency;
    OtherBillPaymentInformation.InstalmentIndicator = RequestItm.bill_breakdown.other_bill_pay_info.install_ind;
    OtherBillPaymentInformation.InstalmentQuantum = RequestItm.bill_breakdown.other_bill_pay_info.install_quantum;
    
    if(udrIsPresent(RequestItm.bill_breakdown.other_bill_pay_info.install_start_date) && !isNull(RequestItm.bill_breakdown.other_bill_pay_info.install_start_date))
        OtherBillPaymentInformation.InstalmentStartDate = convertDateTimeFormat(RequestItm.bill_breakdown.other_bill_pay_info.install_start_date, DATETIME_FORMAT_YYYYMMDD, DATETIME_FORMAT_YYYY_MM_DD);
    
    record.BillBreakdown = BillBreakdown;
    
    }
if ( i!= 0 )debug ( "recordList " + recordList );
        debug ( "record " + record );
        listAdd(recordList, record);
    } 
    

    debug("createRecord.Output: record = " + recordList);    
    return recordList;
}
/*
PriceMasterTrailer_TI createTrailer(UdrInfo udrInfo) {
    debug("-------------------------");
    debug("Function Name: createHeader()");
    debug("createHeader.System Id:" + sysId);
    debug("createHeader.Input: udrInfo = " + udrInfo);
        
    PriceMasterTrailer_TI trailer = udrCreate(PriceMasterTrailer_TI);
       
    trailer.recordCount = (string) udrInfo.IN_RECORD_COUNT;
    dateToString(trailer.batchFileGenerationDate, dateCreateNow(), "yyyyMMddHHmmss");
    
    debug("createTrailer.Output: trailer = " + trailer);      
    return trailer;
}

*/
// WSCycle_postPriceMaster extractExtUdr(ConsumeCycleUDR ccu, string PREV_AUDR_RECORD_TXN_ID) {
//     debug("-------------------------");
//     debug("Function Name: extractExtUdr()");
//     debug("extractExtUdr.System Id:" + sysId);
//     debug("extractExtUdr.Input: ccu = " + ccu);
//     
//     CCUData ccud = (CCUData) ccu.Data;
//     WSCycle_postPriceMaster extUdr = (WSCycle_postPriceMaster) ccud.extUdr; 
//     ConsumeCycleUDR ccuExtUdr = (ConsumeCycleUDR) extUdr.context;
//     updatePrevRecTxnId(ccuExtUdr, PREV_AUDR_RECORD_TXN_ID);
//         
//     debug("extractExtUdr.Output: ccud.extUdr = " + ccud.extUdr);    
//     return (WSCycle_postPriceMaster) ccud.extUdr;
// }



/*
boolean codeTableLookup(string code, string tableNum) {
    debug("-------------------------");
    debug("Function Name: codeTableLookup()");
    debug("codeTableLookup.System Id:" + sysId);
    debug("codeTableLookup.Input: code = " + code);
    
    boolean check = false;
    table sharedTable = tableCreateShared(PRF_ST_SERIVCEMASTER_CODE_TABLE);
    table codeTable = tableLookup(sharedTable, "Code_Table", "=", tableNum);
    table codes = tableLookup(codeTable, "CODE", "=", code);


    if(tableRowCount(codeTable) > 0){
        if(tableRowCount(codes) > 0){
            check = true;
        }
    }
    
    
    debug("codeTableLookup.Output: " + check);
    return check;
}*/

/*
boolean validateRequest(ConsumeCycleUDR ccu) {
    debug("-------------------------");
    debug("Function Name: validateRequest()");
    debug("validateRequest.System Id:" + sysId);
    debug("validateRequest.Input: ccu = " + ccu);
	
	boolean valid = true;
    FaultDetail fault;   
    CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    //Request req = (Request)ccud.rfcReq;
	
	string S4INTFID = wsc.param.HEADER.S4INTFID;
	
	// xml is undecodable 
	if(ccud.rfcReq == null) {
		ccud.errorCode = ERROR_CODE_1E999;
        ccud.errorDesc = getErrorDesc(ccud.errorCode, null);
        fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
        wsc.fault_FaultDetail = fault;
        valid = false; 
	} else {
	   if(S4INTFID == "I003") {
    		valid = validateRequestI003((PayloadI003)ccud.rfcReq, ccu);
    	} else {
    		ccud.errorCode = ERROR_CODE_1E999;
            ccud.errorDesc = getErrorDesc(ERROR_CODE_1E999, null);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false; 
    	}
    }
	debug("validateRequest.Output: valid = " + valid);        
    return valid;
}


boolean validateRequestI003(PayloadI003 payload, ConsumeCycleUDR ccu) {
	debug("-------------------------");
    debug("Function Name: validateRequestI003()");
    debug("validateRequestI003.System Id:" + sysId);
    debug("validateRequestI003.Input: payload = " + payload);
	CCUData ccud = (CCUData) ccu.Data;
    WSCycle_cmoutbound wsc = (WSCycle_cmoutbound) ccud.wsc;
    FaultDetail fault;
	boolean valid = true;
       
    PayloadI003 pl = (PayloadI003) payload;
        
    list<priceMaster_itm> priceMasterItmList        = pl.pricemaster.priceMasterItmList;

	for (int i = 0; i < listSize(priceMasterItmList);i++) {
            
        priceMaster_itm priceMasterItm = listGet(priceMasterItmList, i);
          
        if (isNull(priceMasterItm.instituteid)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "instituteid"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
        } else if (isNull(priceMasterItm.serviceid)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "serviceid"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
        } else if (isNull(priceMasterItm.validfrom)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "validfrom"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;     
        } else if (isNull(priceMasterItm.validto)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "validto"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;     
        } else if (isNull(priceMasterItm.createdat)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "createdat"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
        } else if (isNull(priceMasterItm.createdby)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "createdby"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;    
        } else if (isNull(priceMasterItm.changedat)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "changedat"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;                  
        } else if (isNull(priceMasterItm.changedby)) {
            list<string> pvalist = null;
            pvalist = listCreate(string);
            listAdd(pvalist, "changedby"); 
            ccud.errorCode = ERROR_CODE_1E013;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, pvalist);
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
        } 
        
        //Codeset validation
      
        if(!codeTableLookup(priceMasterItm.baseuom, "Code_Table_14")){
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, null) + ":" + "HEADER.INST_CODE";
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
            debug("validateRequestI003.Output: valid = " + valid);   
            return valid;
        } else  if(!codeTableLookup(priceMasterItm.marginuom, "Code_Table_14")){
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, null) + ":" + "HEADER.INST_CODE";
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
            debug("validateRequestI003.Output: valid = " + valid);   
            return valid;
        } else  if(!codeTableLookup(priceMasterItm.priceuom, "Code_Table_14")){
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, null) + ":" + "HEADER.INST_CODE";
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
            debug("validateRequestI003.Output: valid = " + valid);   
            return valid;

        } else  if(!codeTableLookup(priceMasterItm.pricetype, "Code_Table_14")){
            ccud.errorCode = ERROR_CODE_1E014;
            ccud.errorDesc = getErrorDesc(ccud.errorCode, null) + ":" + "HEADER.INST_CODE";
            fault = createErrorDetail(ccud.errorCode, ccud.errorDesc, wsc);
            wsc.fault_FaultDetail = fault;
            valid = false;
            debug("validateRequestI003.Output: valid = " + valid);   
            return valid;
        }
        
    }   
	
	debug("validateRequestI003.Output: valid = " + valid);   
	return valid;
}
 */]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
