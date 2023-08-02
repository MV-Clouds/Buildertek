public class importSOVController {
 @AuraEnabled
    public static string insertData(String strfromle, string recordId, string vendorName){
        system.debug('recordId'+recordId);
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        
        list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ORDER BY buildertek__Item__c DESC];
        
        
        integer itemInc = 100;
        
        if(lastSOV.size() > 0){
            itemInc = Integer.valueOf(lastSOV[0].buildertek__Item__c)+1;
        }
        
        
        
        String returnresponse ='';
        List<buildertek__Schedule_of_Value_Lines__c> AccoutnListtoInsert = new List<buildertek__Schedule_of_Value_Lines__c>();
        system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        system.debug('datalist = ' + datalist);
        //system.debug('datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist){
            system.debug('desc of work' + wrapper.DescriptionofWork);
            buildertek__Schedule_of_Value_Lines__c acc =new  buildertek__Schedule_of_Value_Lines__c();
            acc.buildertek__Description_of_Work__c = wrapper.DescriptionofWork;
            
            if(portalCode != null && portalCode != ''){
                if(boolean.valueof(portalCode) == true){
                    acc.buildertek__Vendor_Scheduled_Value__c = wrapper.ScheduledValue;
                }else{
                    acc.buildertek__Scheduled_Value__c = wrapper.ScheduledValue;
                }
            }
            
            
            acc.buildertek__Item__c = String.valueOf(itemInc);
           acc.buildertek__Vendor__c = vendorName;
            acc.buildertek__Schedule_of_Values__c = recordId;
            
            AccoutnListtoInsert.add(acc);  
            itemInc++;
        }
        
        if(AccoutnListtoInsert.size() > 0){

            insert AccoutnListtoInsert;
            returnresponse = 'SUCCESS';
        }else{
            return null;
        }

        return returnresponse;
    }
    
    public class fieldWrapper{        
        public String DescriptionofWork;        
        public Decimal ScheduledValue;        
        public String ItemNo;
        
    } 
    
    @AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    

}