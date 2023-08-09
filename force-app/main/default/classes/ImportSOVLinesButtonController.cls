public class ImportSOVLinesButtonController {
    @AuraEnabled
    public static List<buildertek__Schedule_of_Values__c> getSOVData(String recordId){
    system.debug(recordId);
        List<buildertek__SOV_Payment_Application__c> payment = [select id,buildertek__Project__c from buildertek__SOV_Payment_Application__c where id=:recordId];
        system.debug(payment);
        List<buildertek__Schedule_of_Values__c> approvedIdList = new List<buildertek__Schedule_of_Values__c>();
        if(payment.size() > 0){
            List<buildertek__Schedule_of_Values__c> sovlist = [SELECT Id, Name, buildertek__Type__c,buildertek__Date_Submitted__c, buildertek__Project__c,buildertek__Status__c,buildertek__Project__r.Name
                                                               FROM buildertek__Schedule_of_Values__c where buildertek__Project__c =:payment[0].buildertek__Project__c];
        
            system.debug('@@@'+sovlist);
            for(buildertek__Schedule_of_Values__c sc:sovlist){
                system.debug('app '+sc.buildertek__Status__c);
             
                if(sc.buildertek__Status__c == 'Company Approved'){
                    system.debug('app '+sc.id);
                  system.debug('dateSubmitted------>'+sc.buildertek__Date_Submitted__c);
                    approvedIdList.add(sc);
                     
                } 
            }
        }
        return approvedIdList;
    }
    
    
    @AuraEnabled
    public static list<buildertek__SOV_Continuation_Sheet_Lines__c>  importScheduleOfValueItems(List<String> selectedId,  String recordId,boolean isCommunity){
        
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                     buildertek__SOV_Continuation_Sheet__c,
                                                                     buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                     from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                     where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: recordId ORDER BY buildertek__Item_No__c DESC];
        
        system.debug('lastSOV-------->'+lastSOV);
        integer itemInc = 100;
        
        system.debug('lastSOV.size()--------->'+lastSOV.size());
        if(lastSOV.size() > 0){
            
            if(lastSOV[0].buildertek__Item_No__c != null){
                itemInc = Integer.valueOf(lastSOV[0].buildertek__Item_No__c)+1;
            }
            
        }
        
        buildertek__SOV_Continuation__c sheetId = [select Id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__r.Id =: recordId limit 1];
        system.debug(selectedId);
        system.debug('sheetId'+sheetId);
        system.debug('sheet'+sheetId.ID);
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id IN: selectedId];
        buildertek__Schedule_of_Values__c newscheduleRec = new buildertek__Schedule_of_Values__c();
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> masterRFQItemToInsert = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        list<buildertek__Schedule_of_Value_Lines__c> masterRFQList;
        masterRFQList = [SELECT Id,
                         Name,
                         buildertek__Description_of_Work__c,
                         buildertek__Schedule_of_Values__c,
                         buildertek__Scheduled_Value__c,
                         buildertek__Item__c,buildertek__Status__c,
                         buildertek__Schedule_of_Values__r.Name,
                         buildertek__Vendor_SOV_Line__c
                         FROM buildertek__Schedule_of_Value_Lines__c
                         WHERE buildertek__Schedule_of_Values__c IN :selectedId AND buildertek__Status__c = 'Approved'];
        system.debug('@@@masterRFQList'+masterRFQList);
        for (buildertek__Schedule_of_Value_Lines__c masterRFQItem : masterRFQList){
            buildertek__SOV_Continuation_Sheet_Lines__c rfqItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
            if(masterRFQItem.buildertek__Description_of_Work__c != null){
                rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                rfqItem.Name =masterRFQItem.buildertek__Description_of_Work__c;
            }else{
                rfqItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                rfqItem.Name = 'Continuation Sheet Lines';
            }
            
            rfqItem.buildertek__Vendor_SOV_Line_Id__c = masterRFQItem.Id;
            
            rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
            // rfqItem.buildertek__Vendor_Sheet_line_Id__c=masterRFQItem.Id ;
            // rfqItem.buildertek__Item__c=masterRFQItem.buildertek__Item__c;
            rfqItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
            rfqItem.buildertek__Item_No__c=itemInc;
            masterRFQItemToInsert.add(rfqItem);
             itemInc++;
        }
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
        return masterRFQItemToInsert;
    }
    @AuraEnabled
    public static innerclass getApplicationValue(String recordId){
        
        if(recordId != null){
            
            
            buildertek__SOV_Payment_Application__c app = [select id,buildertek__Application__c,buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id=:recordId];
            
            List<buildertek__SOV_Continuation__c> conSheet = [select id, buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =:recordId limit 1];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLinesList = [select id, buildertek__SOV_Continuation_Sheet__c from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c =:conSheet[0].id];
         
            system.debug('sheetLinesList---->'+ sheetLinesList);
           
            innerclass inn = new innerclass();
            
            if(sheetLinesList.size() > 0){
                inn.isSheetLinesAvailable = true;
            }
            else{
                inn.isSheetLinesAvailable = false;
            }
            
            if(app.buildertek__Application__c == '1'){
                inn.isApplication1 = true;
                inn.status = app.buildertek__Status__c;
                 system.debug('Inn---->'+ inn);
                return inn;
            }else{
                inn.isApplication1 = false;
                inn.status = app.buildertek__Status__c;
                 system.debug('Inn---->'+ inn);
                return inn;
            }
            
           
            
        }
        return null;

    }
    public class innerclass{
        @AuraEnabled
        public boolean isApplication1;
        
        @AuraEnabled
        public string status;
        
        @AuraEnabled
        public boolean isSheetLinesAvailable;
        
    }
    
}