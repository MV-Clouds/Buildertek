public class ChangeOrderTrackingController {

     @AuraEnabled
    public static string getcurrency(){
        return UserInfo.getDefaultCurrency();
    }
    
     @AuraEnabled
    public static SOVLinesWrapperClass getVendorSOVLines(String SOVId) {
        system.debug('@@@@@@@@@@@@@'+SOVId);

            
        SOVLinesWrapperClass  wc = new SOVLinesWrapperClass();
        
        List<buildertek__Change_Order_Payment_Tracking_Line__c> sovLineListreturn = new List<buildertek__Change_Order_Payment_Tracking_Line__c>();
        List<buildertek__Change_Order_Payment_Tracking_Line__c> sovLineList = [SELECT Id,
                                                                               Name,
                                                                               buildertek__Description__c,
                                                                               buildertek__Scheduled_Value__c,
                                                                               buildertek__Work_Completed_From_Previous_App__c,
                                                                               buildertek__Work_Completed_This_Period__c,
                                                                               buildertek__Change_Order_Payment_Tracking__c,
                                                                               buildertek__Balance_To_Finish__c
                                                                               FROM buildertek__Change_Order_Payment_Tracking_Line__c
                                                                               WHERE buildertek__Change_Order_Payment_Tracking__c =: SOVId ORDER BY buildertek__Description__c ASC ];
        if(!sovLineList.isEmpty()){
            wc.VendorSOVLinesList=sovLineList;
        }else{
            wc.VendorSOVLinesList=sovLineListreturn;
        }
        
        
        
        return wc;
    }
    
    public class SOVLinesWrapperClass{
        @AuraEnabled
        public List<buildertek__Change_Order_Payment_Tracking_Line__c> VendorSOVLinesList {get;set;}
        @AuraEnabled
        public String sovName {get; set;}
        @AuraEnabled 
        public boolean isChecked=false; 
        @AuraEnabled 
        public Integer ApprovedSOVLinesCount {get; set;}
    }
    
     @AuraEnabled
    public static String updateLines(String recordId, List<buildertek__Change_Order_Payment_Tracking_Line__c> LinesList) {
        system.debug('LinesList--------->'+LinesList);
		List<buildertek__Change_Order_Payment_Tracking_Line__c> TrackLineList = new List<buildertek__Change_Order_Payment_Tracking_Line__c>();
        
        if(!LinesList.isEmpty()){
            
            for(buildertek__Change_Order_Payment_Tracking_Line__c tracL : LinesList){
                buildertek__Change_Order_Payment_Tracking_Line__c TL = new buildertek__Change_Order_Payment_Tracking_Line__c();
                TL.Id = tracL.Id;
                TL.Name = tracL.Name;
                TL.buildertek__Description__c = tracL.buildertek__Description__c;
                TL.buildertek__Work_Completed_From_Previous_App__c = tracL.buildertek__Work_Completed_From_Previous_App__c;
                TL.buildertek__Scheduled_Value__c = tracL.buildertek__Scheduled_Value__c;
                TL.buildertek__Work_Completed_This_Period__c = tracL.buildertek__Work_Completed_This_Period__c;                
                TrackLineList.add(TL);
            }
            
            if(!TrackLineList.isEmpty()){
                Update TrackLineList;
            }
            
        }
        
        system.debug('TrackLineList------------>'+TrackLineList);
        
        
        buildertek__BT_Change_Order_Payment_Tracking__c COTrac = [select Id, Name, buildertek__Last_Updated_Date__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id =: recordId];
        
        system.debug('COTrac--------->'+COTrac);
        
        system.debug('system.now()------------>'+system.now());
        
        COTrac.buildertek__Last_Updated_Date__c = system.now();
        
        update COTrac;
        
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        
        
        buildertek__BT_Change_Order_Payment_Tracking__c COPayTrac = [select Id, Name, buildertek__Work_Completed_From_Previous_App__c, buildertek__Work_Completed_This_Period__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id =: recordId];
        
        system.debug('COPayTrac--------->'+COPayTrac);
        
        List<String> conLineIds = new List<String>();
        
        system.debug('TrackLineList last list'+TrackLineList);
        
         if(!TrackLineList.isEmpty()){
             for(buildertek__Change_Order_Payment_Tracking_Line__c cop :TrackLineList ){
                 system.debug('workPeriod---->'+cop.buildertek__Work_Completed_This_Period__c);
                 conLineIds.add(cop.Id);
             }
            }
        
        system.debug('conLineIds--->'+conLineIds);
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> ConLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        system.debug('COPayTrac.Id------>'+COPayTrac.Id);
        
         buildertek__SOV_Continuation_Sheet_Lines__c ConSheetLineList = [select Id, Name, buildertek__Work_Completed_from_Previous_Application__c, buildertek__Work_Completed__c, buildertek__Change_Order_Payment_Tracking__c from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__Change_Order_Payment_Tracking__c =:COPayTrac.Id ];
        
        system.debug('ConSheetLineList-------->'+ConSheetLineList);

        if(portalCode == 'true'){
            ConSheetLineList.buildertek__Vendor_Work_Completed_from_Previous_Appl__c = COPayTrac.buildertek__Work_Completed_From_Previous_App__c;
            ConSheetLineList.buildertek__Vendor_Work_Completed_This_Period__c = COPayTrac.buildertek__Work_Completed_This_Period__c;
        }
        else{
            ConSheetLineList.buildertek__Work_Completed_from_Previous_Application__c = COPayTrac.buildertek__Work_Completed_From_Previous_App__c;
            ConSheetLineList.buildertek__Work_Completed__c = COPayTrac.buildertek__Work_Completed_This_Period__c;
        }
         
               
        System.debug('ConSheetLineList ==> '+ConSheetLineList);
        
        update ConSheetLineList;

        System.debug('ConSheetLineList 2 ==> '+ConSheetLineList);

        
        return 'success';
    }


 @AuraEnabled
    public static String getPaymentAppDetails(String recordId) {
      
        buildertek__BT_Change_Order_Payment_Tracking__c tracrec = [select Id, Name, buildertek__Payment_Application_G702__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id =: recordId];
        
        return tracrec.Name;
    }

    
}