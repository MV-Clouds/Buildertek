public class SubmitCOToOwnerController {

       public static List<string> sovLineStatus = new List<string> {'Approved','Vendor Submitted'};
    
     @AuraEnabled 
    public static User  getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        System.debug(userRec[0]);
         return  userRec[0] ;
    }
    
    
    
    @AuraEnabled
    public static String submitSOVForView(String recordId, date todayDate, string vendor){
        system.debug(recordId);
        system.debug('date'+todayDate);
        system.debug('todayDate'+System.now());
        try{
          /*  buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Project__c,buildertek__Type__c,RecordTypeId, recordtype.name,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id =:recordId];
            system.debug(updateStatus);
            updateStatus.buildertek__Status__c = 'Vendor Submitted';
            updateStatus.recordtype.name = 'Vendor';
            updateStatus.buildertek__Date_Submitted__c = todayDate;
            updateStatus.buildertek__Vendor__c = vendor;
            update updateStatus;
            system.debug('updates status ------> '+ updateStatus);  
            
            list<buildertek__Schedule_of_Value_Lines__c> sovLines = [select id,buildertek__Status__c,buildertek__Vendor__c,buildertek__Rejection_Reason__c, buildertek__Schedule_of_Values__r.buildertek__Vendor__c, buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId AND buildertek__Status__c NOT IN: sovLineStatus  ];
           system.debug(sovLines.size()+'<--sovLines --->'+sovLines );
            list<buildertek__Schedule_of_Value_Lines__c> sovlineslist = new list<buildertek__Schedule_of_Value_Lines__c>();
            for(buildertek__Schedule_of_Value_Lines__c bc :sovLines){
                if(bc.buildertek__Status__c != 'Approved' && bc.buildertek__Status__c != 'Vendor Submitted'){
                    bc.buildertek__Status__c = 'Vendor Submitted'; 
                    bc.buildertek__Rejection_Reason__c = ''; 
                    bc.buildertek__Vendor__c = bc.buildertek__Schedule_of_Values__r.buildertek__Vendor__c;
                }
                
                sovlineslist.add(bc);
            }
            if(sovlineslist.size()>0){
                update sovlineslist;
            }
            system.debug('updated sovlineslist'+sovlineslist);
            return 'success';
            
            //------------------------------*/
            
            buildertek__Change_Order__c updateStatus = [select Id, Name,buildertek__Status__c,buildertek__Vendor__c from buildertek__Change_Order__c where  Id =:recordId];
              updateStatus.buildertek__Status__c = 'Vendor Submitted';
          //  updateStatus.recordtype.name = 'Vendor';
          //  updateStatus.buildertek__Vendor__c = vendor;
            update updateStatus;
            
          
               return 'success';
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    
    @AuraEnabled
    public static String isSovSubmitted(String recordId){
        system.debug(recordId);
        buildertek__Change_Order__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Change_Order__c where Id =:recordId];
        system.debug(updateStatus);
        //  updateStatus.buildertek__Status__c = 'Vendor Submitted';
        system.debug('updates status ------> '+ updateStatus);
        return updateStatus.buildertek__Status__c;
    }
    
}