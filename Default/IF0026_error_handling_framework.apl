<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<mz:configuration format-version="1.0">
    <mz:data>
        <dr.Configuration:dr.Configuration Folder="Default" Key="DZ11639475207102" Name="IF0026_error_handling_framework" Owner="A_KAMALPRIT" Type="APL Code" encrypted="false" ver="6.0">
            <STRING:Access_Groups_-----.read_-----.write_-----.execute>
                <value value="Z_ACN_Developer"/>
                <value value="Z_ACN_Developer"/>
                <value value="Z_ACN_Developer"/>
            </STRING:Access_Groups_-----.read_-----.write_-----.execute>
            <null:Auxiliary_Data/>
            <dr.APLProfileData:Data ver="1.0">
                <Definition><![CDATA[import ultra.ZZ_CA_UFL.UFL_ECS;
import ultra.ZZ_SVC0011.UFL_SVC0011_FileLevel_Records;
import ultra.ZZ_CA_UFL.UFL_Audit;

//Begin-Common error handling  
import apl.ZZ_CA_APL.APL_Constants;
import apl.ZZC_CA_APL.APL_Common_Constants;
import apl.ZZC_CA_APL.APL_Error_Functions;
//End-Common error handling  

string headerValidation(Header_Internal headerUdr){
    string error_message;
    string headerDate = strTrim(headerUdr.BatchFileGenerationDate);
    date dateVal;
    
    if ( headerDate == null || headerDate == "" )
    {
        error_message = "Null values received in 'Batch File Generatation Date'";
    }
    else if (strLength(headerDate) > 14)
    {
        error_message = "Length of 'Batch File Generation Date' must not be greater than maximum length of 14 allowed";
    }
    else if (!strToDate(dateVal, headerDate, "yyyyMMddHHmmss"))
    {
        error_message = "Date/Datetime format provided in Header does not match the specification";
    }
    
    debug("------ Function Name: headerValidation ------");
    debug("Input: headerUdr=" + headerUdr);
    debug("Output: error_message=" + error_message);
    return error_message;
}

string trailerValidation(Trailer_Internal trailerUdr, boolean isIds)
{
    string error_message;
    string trailerRecordCount = strTrim(trailerUdr.recordCount);
    int trailer_rec_count;
    int recMaxLength;
    
    // cater to different rec max length
    if (isIds) recMaxLength = 6;
    else recMaxLength = 4;
    
    if ( trailerRecordCount == null || trailerRecordCount == "" )
    {
        error_message = "Null values received in trailer record count";
    }
    else if (strLength(trailerRecordCount) > recMaxLength) 
    {
        error_message = "Length of trailer record count must not be greater than maximum length of " + recMaxLength + " allowed";
    }
    else if (!strToInt(trailer_rec_count, trailerRecordCount)) 
    {
        error_message = "Trailer record count is not an integer";
    }    

    debug("------ Function Name: trailerValidation ------");
    debug("Input: trailerUdr=" + trailerUdr);
    debug("Input: isIds=" + isIds);
    debug("Output: error_message=" + error_message);
    
    return error_message;        
}

/****************************************************************************
 * function name : errorFileECSHandling
 * function purpose : To construct ECS UDR for file-level error and then initiate cancelBatch
 * 
 ****************************************************************************/
//Begin-Common error handling
//void errorFileECSHandling (string error_message, ECS_Error_Int udrError, int errorType)
void errorFileECSHandlingNew (ECS_Error_Int udrError, string errorCode, string error_message, list<string> pvalist)
{
    // 1 - Header Validation Failed
    // 2 - Undecodable/corrupted file
    // 3 - Header count and record count mismatch
   if (error_message==null) 
       error_message = getErrorDesc(errorCode, pvalist);
    switch (errorCode)
    {
        
        //Begin-Common error handling  
        //case 1 { udrAddError ( udrError, "BATCH_ECS0001", error_message ); }
        //case 2 { udrAddError ( udrError, "BATCH_ECS0002", error_message ); }
        //case 3 { udrAddError ( udrError, "BATCH_ECS0003", error_message ); }
        case ERROR_CODE_1E021 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E021, error_message );}
        case ERROR_CODE_1E012 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E012, error_message );}
        case ERROR_CODE_1E020 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E020, error_message );}
        case ERROR_CODE_1E022 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E022, error_message );}
        case ERROR_CODE_1E013 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E013, error_message );}
        case ERROR_CODE_1E999 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E999, error_message );}
        case ERROR_CODE_1E011 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E011, error_message );}
        case ERROR_CODE_1E015 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E015, error_message );}
        case ERROR_CODE_1E029 { udrAddError ( udrError, INTF_ID_IF0026 + "_"+ERROR_CODE_1E029, error_message );}
        case ERROR_CODE_1E021 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E021, error_message );}
        case ERROR_CODE_1E012 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E012, error_message );}
        case ERROR_CODE_1E020 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E020, error_message );}
        case ERROR_CODE_1E022 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E022, error_message );}
        case ERROR_CODE_1E013 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E013, error_message );}
        case ERROR_CODE_1E999 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E999, error_message );}
        case ERROR_CODE_1E011 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E011, error_message );}
        case ERROR_CODE_1E015 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E015, error_message );}
        case ERROR_CODE_1E029 { udrAddError ( udrError, INTF_ID_IF0037 + "_"+ERROR_CODE_1E029, error_message );}
        /*case 1 { udrAddError ( udrError, "BATCH_ECS0001", error_message ); }
        case 2 { udrAddError ( udrError, "BATCH_ECS0002", error_message ); }
        case 3 { udrAddError ( udrError, "BATCH_ECS0003", error_message ); }
        case 4 { udrAddError ( udrError, "BATCH_IE2008", error_message ); }
        case 5 { udrAddError ( udrError, "BATCH_IE2002", error_message ); }
        case 6 { udrAddError ( udrError, "BATCH_IE2007", error_message ); }
        case 7 { udrAddError ( udrError, "BATCH_IE2009", error_message ); }
        case 8 { udrAddError ( udrError, "BATCH_IE2003", error_message ); }
        case 9 { udrAddError ( udrError, "BATCH_IE2999", error_message ); }
        case 10 { udrAddError ( udrError, "BATCH_IE2001", error_message ); }
        case 11 { udrAddError ( udrError, "BATCH_IE2005", error_message ); }
        case 12 { udrAddError ( udrError, "BATCH_IE2017", error_message ); }*/
        
        //End-Common error handling  
        else { }
    }
    debug("------ Function Name: errorFileECSHandling ------");
    debug("Input: errorCode="+ errorCode);
    debug("Input: error_message="+ error_message);
    debug("Input: pvalist="+pvalist);
    debug("Output: void (cancelBatch will be invoked)");
    
    cancelBatch(error_message, udrError);
}
//End-Common error handling]]></Definition>
            </dr.APLProfileData:Data>
            <documentation value=""/>
            <parameters value=""/>
            <Current_Comment/>
        </dr.Configuration:dr.Configuration>
    </mz:data>
    <mz:referenced-data/>
</mz:configuration>
