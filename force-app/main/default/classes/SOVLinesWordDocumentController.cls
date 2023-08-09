public class SOVLinesWordDocumentController { 
    public String getWrapList() {
        return null;
    } 

   
    public List<buildertek__Schedule_of_Value_Lines__c> SOVLineList{get;set;}
    public buildertek__Schedule_of_Values__c SOV{get;set;}
    public buildertek__MSA_Settings__c MSASettings{get;set;}
    public integer recIndex{get;set;}
    public List<integer> index{get;set;}
    public Id reportid{get;set;}
    public Decimal scheduleValueTotal{get;set;}
    
      public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public SOVLinesWordDocumentController() {
        Decimal scheduleValue=0.0;
        reportid = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        
        recIndex = 0;
        
        SOV=[SELECT Id, Name, buildertek__Type__c, RecordTypeId, recordtype.name,buildertek__Project__c, buildertek__Date_Submitted__c,
             buildertek__Status__c, buildertek__Total_Costs__c, buildertek__Due_Date__c, buildertek__Vendor__c, 
             buildertek__Created_SOV_Line_Ids_From_Project__c, buildertek__Project__r.Name,
             buildertek__Vendor__r.Name,
             buildertek__Vendor__r.BillingStreet,
             buildertek__Vendor__r.BillingCity,
             buildertek__Vendor__r.BillingState,
             buildertek__Vendor__r.BillingCountry,
             buildertek__Project__r.Auto_Number__c
             FROM buildertek__Schedule_of_Values__c where id=:reportid];
        MSASettings=[SELECT Id, Name, buildertek__Company_Name__c, buildertek__Company_Full_Name__c,buildertek__MSA_Email__c,
            buildertek__State__c, buildertek__Street__c, buildertek__City__c, buildertek__Phone__c,buildertek__Site_URL__c,buildertek__Website__c 
            FROM buildertek__MSA_Settings__c];
        if(SOV.recordtype.name == 'Standard'){
            SOVLineList = [SELECT Id,
                       Name,
                       buildertek__Description_of_Work__c,
                       buildertek__Item__c,
                       buildertek__Item_New__c,
                       buildertek__Scheduled_Value__c,
                       buildertek__Schedule_of_Values__r.buildertek__Status__c,
                       buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,
                       buildertek__Schedule_of_Values__c,
                       buildertek__Vendor__c,
                       buildertek__Status__c,
                       buildertek__Rejection_Reason__c,
                       buildertek__Vendor__r.Name,
                       buildertek__Vendor_Item_Number_New__c
                       FROM buildertek__Schedule_of_Value_Lines__c
                       WHERE buildertek__Schedule_of_Values__c =:reportid AND (buildertek__Status__c = 'Pending' or buildertek__Status__c = 'Customer Approved') AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, Name ASC];
        }else{
            SOVLineList = [SELECT Id,
                       Name,
                       buildertek__Description_of_Work__c,
                       buildertek__Item__c,
                       buildertek__Item_New__c,
                       buildertek__Scheduled_Value__c,
                       buildertek__Schedule_of_Values__r.buildertek__Status__c,
                       buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,
                       buildertek__Schedule_of_Values__c,
                       buildertek__Vendor__c,
                       buildertek__Status__c,
                       buildertek__Rejection_Reason__c,
                       buildertek__Vendor__r.Name,
                       buildertek__Vendor_Item_Number_New__c
                       FROM buildertek__Schedule_of_Value_Lines__c
                       WHERE buildertek__Schedule_of_Values__c =:reportid AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, Name ASC];
        }
        
        
        if(SOVLineList.size()>0){
            for(buildertek__Schedule_of_Value_Lines__c sovline : SOVLineList){
                
                if(sovline.buildertek__Scheduled_Value__c!=null){                    
                    scheduleValue +=sovline.buildertek__Scheduled_Value__c;                    
                }
            } 
            scheduleValueTotal=scheduleValue;
        }
        
    }
}