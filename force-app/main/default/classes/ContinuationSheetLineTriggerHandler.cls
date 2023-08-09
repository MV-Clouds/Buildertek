/*
Developed By: Harika
Date:  25-jun-2018
*/
public class ContinuationSheetLineTriggerHandler {
    public static Boolean skip = false;
    public static Boolean blnSkipSheetLineTrigger = false;
    public static Boolean blnSkipconSheetLineUpdateTrigger = false;
    
    public static Boolean blnSkipAterInsertSheetLineTrigger = false;
    
    public void afterInsert(List<SOV_Continuation_Sheet_Lines__c> newconsheetline, Map<Id, SOV_Continuation_Sheet_Lines__c> consheetline){
        
        //  Payment app balance to finish field populate  Start
        list<String> ConSheetLineIds = new list<String> ();
        if(!newconsheetline.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c sheetLine : newconsheetline){
                ConSheetLineIds.add(sheetLine.Id);
            }
        }
        
        list<SOV_Continuation_Sheet_Lines__c> updateStatus = [select Id, Name,buildertek__SOV_Continuation_Sheet__c,buildertek__Balance_To_Finish__c from SOV_Continuation_Sheet_Lines__c where Id IN: ConSheetLineIds Limit 10000];
        List<String> conSheetIdList = new List<String>();
        if(!updateStatus.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : updateStatus){
                conSheetIdList.add(conSheet.buildertek__SOV_Continuation_Sheet__c);
            }
        }
        
        buildertek__SOV_Continuation__c conSheetList = [select Id, Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: conSheetIdList[0]];
        
        system.debug('conSheetList----->'+conSheetList);
        
        list<SOV_Continuation_Sheet_Lines__c>  AllConSheetLineIds = [select Id, Name, buildertek__SOV_Continuation_Sheet__c from SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c =:conSheetList.Id  Limit 10000];
        List<String> NewChildIds = new List<String>();
        
        if(!AllConSheetLineIds.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : AllConSheetLineIds){
                NewChildIds.add(conSheet.Id);
            }
        }        
        
        
        
        
        system.debug('NewChildIds------>'+NewChildIds);
        
        
        String payApp =  conSheetList.buildertek__SOV_Payment_Application__c;
        
        
        futureUpdatePayApp(payApp, NewChildIds);
        
     

       // update newPaymentApp;
        
    }  
    
    
    @future
    public static void futureUpdatePayApp(String payApp, List<String> NewChildIds){
                  
        buildertek__SOV_Payment_Application__c PaymentApp = [select Id, Name, buildertek__Total_Balance_To_Finish__c, buildertek__Total_Completed__c,buildertek__Total_Completed_From_Previous_App__c,buildertek__Net_Change_by_Change_Orders__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =: payApp  Limit 10000];
        List<buildertek__SOV_Payment_Application__c> newPaymentApp = [select Id, Name,buildertek__Application_Number__c, buildertek__Total_Balance_To_Finish__c, buildertek__Total_Completed__c,buildertek__Total_Completed_From_Previous_App__c,buildertek__Net_Change_by_Change_Orders__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c, RecordType.Name from buildertek__SOV_Payment_Application__c where Id =:PaymentApp.Id  Limit 10000];
        system.debug('new Payment App----->'+newPaymentApp);
        
        system.debug('PaymentApp------>'+PaymentApp);
        
        
        
        
        if(!newPaymentApp.isEmpty()){
            List<AggregateResult> result ;
            
            if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                result  = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN: NewChildIds AND buildertek__Budget_Grouping__c != 'Change Orders'];
            system.debug('********decodedPassword:' + result);
            }else{
                  result = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN: NewChildIds];
            system.debug('********decodedPassword:' + result);
            }
            
           
            
            
            for(AggregateResult agg : result){
                newPaymentApp[0].buildertek__Total_Balance_To_Finish__c = (decimal)agg.get('totalCost'); 
                newPaymentApp[0].buildertek__Total_Completed__c = (decimal)agg.get('totalCompleted'); 
                newPaymentApp[0].buildertek__Total_Completed_From_Previous_App__c = (decimal)agg.get('totalCompletedfromprevApp'); 
                
                newPaymentApp[0].buildertek__Total_Material_Stored_To_Date__c = (decimal)agg.get('totalMaterialStored');
                system.debug('cgiagciagc--> '+(decimal)agg.get('totalContractSum'));
                system.debug('change orders net--.> '+PaymentApp.buildertek__Net_Change_by_Change_Orders__c);
                if(newPaymentApp[0].RecordType.Name == 'AP'){
                    if((decimal)agg.get('totalVendorContractSum') != null){
                        if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                            newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalVendorContractSum');
                            
                        }else{
                            system.debug('netchange----k->'+PaymentApp.buildertek__Net_Change_by_Change_Orders__c);
                            newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalVendorContractSum')-PaymentApp.buildertek__Net_Change_by_Change_Orders__c;
                            
                        }
                    }
                }else{
                    if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                        newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalContractSum');
                        
                    }else{
                        newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalContractSum')-PaymentApp.buildertek__Net_Change_by_Change_Orders__c;
                        
                    }
                }
            }
            
            if (newPaymentApp.size() > 0){
                ContinuationSheetLineTriggerHandler.blnSkipconSheetLineUpdateTrigger = false;
                update newPaymentApp;
                
                
                system.debug('newPaymentApp[078]---->'+newPaymentApp[0].buildertek__Original_Contract_Sum__c);
                system.debug('newPaymentApp[1]98---->'+newPaymentApp[0].buildertek__Net_Change_by_Change_Orders__c);
                
                ContinuationSheetLineTriggerHandler.blnSkipconSheetLineUpdateTrigger = true;
                
                
                
            }
        }
        
    }
    
    
    public void afterUpdate(List<SOV_Continuation_Sheet_Lines__c> oldconsheetline, List<SOV_Continuation_Sheet_Lines__c> newconsheetline, Map<Id, SOV_Continuation_Sheet_Lines__c> oldconsheetlineMap, Map<Id, SOV_Continuation_Sheet_Lines__c> newconsheetlineMap){
        
        //  Payment app balance to finish field populate  Start
        list<String> ConSheetLineIds = new list<String> ();
        if(!newconsheetline.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c sheetLine : newconsheetline){
                ConSheetLineIds.add(sheetLine.Id);
            }
        }
        
        list<SOV_Continuation_Sheet_Lines__c> updateStatus = [select Id, Name,buildertek__SOV_Continuation_Sheet__c,buildertek__Balance_To_Finish__c from SOV_Continuation_Sheet_Lines__c where Id IN: ConSheetLineIds  Limit 10000];
        
        List<String> conSheetIdList = new List<String>();
        if(!updateStatus.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : updateStatus){
                conSheetIdList.add(conSheet.buildertek__SOV_Continuation_Sheet__c);
            }
        }
        
        List<buildertek__SOV_Continuation__c> conSheetList = [select Id, Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: conSheetIdList[0]  Limit 10000];
        
        system.debug( conSheetList);
        if(!conSheetList.isEmpty()){
            list<SOV_Continuation_Sheet_Lines__c>  AllConSheetLineIds = [select Id, Name, buildertek__SOV_Continuation_Sheet__c from SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c IN:conSheetList  Limit 10000];
            List<String> NewChildIds = new List<String>();
            if(!AllConSheetLineIds.isEmpty()){
                for(SOV_Continuation_Sheet_Lines__c conSheet : AllConSheetLineIds){
                    
                    NewChildIds.add(conSheet.Id);
                }
            }        
            
            buildertek__SOV_Payment_Application__c PaymentApp = [select Id, Name, buildertek__Total_Balance_To_Finish__c, buildertek__Total_Completed__c,buildertek__Net_Change_by_Change_Orders__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =: conSheetList[0].buildertek__SOV_Payment_Application__c  Limit 10000];
            
            List<buildertek__SOV_Payment_Application__c> newPaymentApp = [select Id,RecordType.Name, Name,buildertek__Application_Number__c, buildertek__Total_Balance_To_Finish__c,buildertek__Net_Change_by_Change_Orders__c, buildertek__Total_Completed__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =:PaymentApp.Id  Limit 10000];
           if(!newPaymentApp.isEmpty()){
               
            
            List<AggregateResult> result ;
            
            if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                result  = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN: NewChildIds AND buildertek__Budget_Grouping__c != 'Change Orders'];
            system.debug('********decodedPassword:' + result);
            }else{
                  result = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN: NewChildIds];
            system.debug('********decodedPassword:' + result);
            }
                for(AggregateResult agg : result){
                    newPaymentApp[0].buildertek__Total_Balance_To_Finish__c = (decimal)agg.get('totalCost'); 
                    newPaymentApp[0].buildertek__Total_Completed__c = (decimal)agg.get('totalCompleted'); 
                    newPaymentApp[0].buildertek__Total_Completed_From_Previous_App__c = (decimal)agg.get('totalCompletedfromprevApp'); 
                    
                    newPaymentApp[0].buildertek__Total_Material_Stored_To_Date__c = (decimal)agg.get('totalMaterialStored');
                    system.debug('cgiagciagc--> '+(decimal)agg.get('totalVendorContractSum'));
                    system.debug('change orders net--.> '+PaymentApp.buildertek__Net_Change_by_Change_Orders__c);
                    if(newPaymentApp[0].RecordType.Name == 'AP'){
                        if((decimal)agg.get('totalVendorContractSum') != null){
                            if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                                newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalVendorContractSum');
                                
                            }else{
                                newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalVendorContractSum')-PaymentApp.buildertek__Net_Change_by_Change_Orders__c;
                                
                            }
                        }
                    }else{
                        if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                            newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalContractSum');
                            
                        }else{
                            newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalContractSum')-PaymentApp.buildertek__Net_Change_by_Change_Orders__c;
                            
                        }
                    }
                }
                
                if (newPaymentApp.size() > 0){
                    ContinuationSheetLineTriggerHandler.blnSkipconSheetLineUpdateTrigger = false;
                    update newPaymentApp;
                    
                    System.debug('newPaymentApp ===> '+newPaymentApp);
                    system.debug('newPaymentApp[078]---->'+newPaymentApp[0].buildertek__Original_Contract_Sum__c);
                    system.debug('newPaymentApp[1]98---->'+newPaymentApp[0].buildertek__Net_Change_by_Change_Orders__c);
                    
                    ContinuationSheetLineTriggerHandler.blnSkipconSheetLineUpdateTrigger = true;
                    
                    
                    
                }
            }
            
            
            
            
            
            //  Payment app balance to finish field populate  Start
            List<buildertek__SOV_Continuation_Sheet_Lines__c> insertedSheetLinesList = [SELECT Id,
                                                                                        Name,
                                                                                        buildertek__Description_of_Work__c,
                                                                                        buildertek__Scheduled_Value__c,
                                                                                        buildertek__Work_Completed_from_Previous_Application__c,
                                                                                        buildertek__Work_Completed__c,
                                                                                        buildertek__Material_Presently_Stored__c,
                                                                                        buildertek__Total__c,
                                                                                        buildertek__New_G_C__c,
                                                                                        buildertek__Balance_To_Finish__c,
                                                                                        buildertek__SOV_Continuation_Sheet__c,
                                                                                        buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                                        FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                        WHERE Id IN: newconsheetlineMap.keySet()  Limit 10000];
            
            list<string> sheetIds = new list<string>();
            List<String> appIdsList = new List<String>();
            Map<String,String> sheetAppMap = new Map<String,String>();
            SET<Id> continuationSheetIds = new SET<Id>();
            SET<Id> paymentApplicationIds = new SET<Id>();
            Map<Id, Decimal> totalValue = new Map<Id, Decimal>();
            list<buildertek__SOV_Payment_Application__c> updateAppList = new list<buildertek__SOV_Payment_Application__c>();
            for(buildertek__SOV_Continuation_Sheet_Lines__c sId : insertedSheetLinesList){
                sheetIds.add(sId.buildertek__SOV_Continuation_Sheet__c);
                appIdsList.add(sId.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c);
                sheetAppMap.put(sId.buildertek__SOV_Continuation_Sheet__c,sId.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c);
                
            }
            
            List<buildertek__SOV_Payment_Application__c> paymentAppList = [select Id, buildertek__Retainage__c from buildertek__SOV_Payment_Application__c where Id IN: appIdsList  Limit 10000];
            
            List<AggregateResult> groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                                    SUM(buildertek__Work_Completed_from_Previous_Application__c) fromPrevApp,
                                                    SUM(buildertek__Work_Completed__c) workCompleted,
                                                    SUM(buildertek__Material_Presently_Stored__c) materialStored,
                                                    SUM(buildertek__Total__c) totalWork,
                                                    SUM(buildertek__New_G_C__c) gcTotal,
                                                    SUM(buildertek__Balance_To_Finish__c) balanceTotal,
                                                    buildertek__SOV_Continuation_Sheet__c,
                                                    buildertek__Grouping__c
                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                    WHERE buildertek__SOV_Continuation_Sheet__c IN: sheetIds
                                                    GROUP BY buildertek__SOV_Continuation_Sheet__c, buildertek__Grouping__c];
            
            Map<String,AggregateResult> sheetAndSheetLineAggregateMap = new Map<String,AggregateResult> ();
            for(AggregateResult item: groupedResults){
                system.debug((String)item.get('buildertek__SOV_Continuation_Sheet__c'));
                if((String)item.get('buildertek__Grouping__c') == 'Change Orders'){
                    
                }
                if(sheetAndSheetLineAggregateMap.get((String)item.get('buildertek__SOV_Continuation_Sheet__c'))!=null){
                    sheetAndSheetLineAggregateMap.put((String)item.get('buildertek__SOV_Continuation_Sheet__c'),item);                                        
                }else{
                    sheetAndSheetLineAggregateMap.put((String)item.get('buildertek__SOV_Continuation_Sheet__c'),item);                    
                } 
            }
            system.debug(paymentAppList);
            //list<buildertek__SOV_Payment_Application__c> updateAppList = new list<buildertek__SOV_Payment_Application__c>(); 
            List<String> updateAppIdList = new List<String>();
            for(buildertek__SOV_Payment_Application__c appItem: paymentAppList){
                buildertek__SOV_Payment_Application__c newapp = new buildertek__SOV_Payment_Application__c();
                system.debug(appItem.Id);
                for(String sheetIdItem: sheetAppMap.keySet()){
                    system.debug(sheetIdItem);
                    system.debug(sheetAndSheetLineAggregateMap.get(sheetIdItem));
                    system.debug(sheetAppMap.get(sheetIdItem) == appItem.Id);
                    if(sheetAppMap.get(sheetIdItem) == appItem.Id){
                        ContinuationDetails cd = new ContinuationDetails();
                        system.debug(sheetAndSheetLineAggregateMap.get(sheetIdItem));
                        cd.scheduleValueTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('scheduleValue'); 
                        cd.workFromPrevAppTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('fromPrevApp');
                        cd.workcompletedTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('workCompleted');
                        cd.materialsStoredTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('materialStored');
                        cd.totalCompletedStored = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('totalWork');
                        cd.gcTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('gcTotal');
                        cd.balanceTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('balanceTotal');
                        
                        newapp.Id = appItem.Id;
                        Double retainage = appItem.buildertek__Retainage__c;
                        if(cd.totalCompletedStored != null ) {
                            newapp.buildertek__Total_Completed_and_Stored_To_Date__c = cd.totalCompletedStored;
                        }
                        if(cd.workFromPrevAppTotal != null && retainage != null) {
                            newapp.buildertek__Retainage_of_Completed_Work__c = (retainage * (cd.workFromPrevAppTotal + cd.workcompletedTotal));
                        }
                        if(cd.materialsStoredTotal != null && retainage != null) {
                            newapp.buildertek__Retainage_of_Stored__c = (retainage * (cd.materialsStoredTotal ));                               
                        }
                        system.debug(newapp.Id);
                        if(updateAppIdList.indexOf(newapp.Id) < 0){
                            updateAppList.add(newapp);
                        }
                        System.debug('updateAppList=====>>>>>'+updateAppList);
                    }
                }
            }
            System.debug('updateAppList=====>>>>>'+updateAppList);
            
            if(updateAppList.Size()>0){
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
                update updateAppList;
                System.debug('IF updateAppList=====>>>>>'+updateAppList);
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false; 
            }
        }
    }
    
    public void changeOrdersTotal(){
        
    }
    
    public void afterDelete(List<SOV_Continuation_Sheet_Lines__c> oldconsheetline, List<SOV_Continuation_Sheet_Lines__c> newconsheetline, Map<Id, SOV_Continuation_Sheet_Lines__c> oldconsheetlineMap, Map<Id, SOV_Continuation_Sheet_Lines__c> newconsheetlineMap){
        system.debug(newconsheetlineMap);
        system.debug(oldconsheetlineMap);
        List<buildertek__SOV_Continuation_Sheet_Lines__c> updateCORecsList = [select Id,Name,buildertek__Change_Order__c
                                                                              from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                              where Id IN: oldconsheetlineMap.keySet()  Limit 10000
                                                                             ];
        
        List<buildertek__Change_Order__c> changeOrderIds = new List<buildertek__Change_Order__c>();
        if(!updateCORecsList.isEmpty()){
            for(buildertek__SOV_Continuation_Sheet_Lines__c csLine :updateCORecsList){
                buildertek__Change_Order__c newCO = new buildertek__Change_Order__c();
                newCO.buildertek__Is_CO_Imported__c = false;
                if(csLine.buildertek__Change_Order__c != null){
                    newCO.Id = csLine.buildertek__Change_Order__c;
                    changeOrderIds.add(newCO);
                }  
            }
        }
        
        if(!changeOrderIds.isEmpty()){
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
            update changeOrderIds;
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
        } 
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> insertedSheetLinesList = [SELECT Id,
                                                                                    Name,
                                                                                    buildertek__Description_of_Work__c,
                                                                                    buildertek__Scheduled_Value__c,
                                                                                    buildertek__Work_Completed_from_Previous_Application__c,
                                                                                    buildertek__Work_Completed__c,
                                                                                    buildertek__Material_Presently_Stored__c,
                                                                                    buildertek__Total__c,
                                                                                    buildertek__New_G_C__c,
                                                                                    buildertek__Balance_To_Finish__c,
                                                                                    buildertek__SOV_Continuation_Sheet__c,
                                                                                    buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                    WHERE Id IN: oldconsheetlineMap.keySet()  Limit 10000];
        list<string> sheetIds = new list<string>();
        list<string> appId = new list<string>();
        
        Map<String,String> sheetAppMap = new Map<String,String>();
        for(buildertek__SOV_Continuation_Sheet_Lines__c sId : oldconsheetline){
            system.debug(sId.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c);
            sheetIds.add(sId.buildertek__SOV_Continuation_Sheet__c);
        }
        
        List<buildertek__SOV_Continuation__c> sheetList = [Select Id,buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE Id IN:sheetIds  Limit 10000];
        for(buildertek__SOV_Continuation__c sheetItem : sheetList){
            system.debug(sheetItem.buildertek__SOV_Payment_Application__c);
            appId.add(sheetItem.buildertek__SOV_Payment_Application__c);
            sheetAppMap.put(sheetItem.Id,sheetItem.buildertek__SOV_Payment_Application__c);
        }
        
        List<buildertek__SOV_Payment_Application__c> paymentAppList = [select Id, buildertek__Retainage__c from buildertek__SOV_Payment_Application__c where Id IN: appId  Limit 10000];
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        if(sheetIds.Size() > 0){
            if(sheetIds.Size() == 1){
                groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                  SUM(buildertek__Work_Completed_from_Previous_Application__c) fromPrevApp,
                                  SUM(buildertek__Work_Completed__c) workCompleted,
                                  SUM(buildertek__Material_Presently_Stored__c) materialStored,
                                  SUM(buildertek__Total__c) totalWork,
                                  SUM(buildertek__New_G_C__c) gcTotal,
                                  SUM(buildertek__Balance_To_Finish__c) balanceTotal,
                                  buildertek__SOV_Continuation_Sheet__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c =: sheetIds[0]
                                  GROUP BY buildertek__SOV_Continuation_Sheet__c];
            }else{
                groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                  SUM(buildertek__Work_Completed_from_Previous_Application__c) fromPrevApp,
                                  SUM(buildertek__Work_Completed__c) workCompleted,
                                  SUM(buildertek__Material_Presently_Stored__c) materialStored,
                                  SUM(buildertek__Total__c) totalWork,
                                  SUM(buildertek__New_G_C__c) gcTotal,
                                  SUM(buildertek__Balance_To_Finish__c) balanceTotal,
                                  buildertek__SOV_Continuation_Sheet__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c IN: sheetIds
                                  GROUP BY buildertek__SOV_Continuation_Sheet__c];
            }
        }
        
        
        list<buildertek__SOV_Payment_Application__c> updateAppList = new list<buildertek__SOV_Payment_Application__c>();                 
        system.debug(groupedResults);
        system.debug(sheetIds);
        if(groupedResults.Size()>0){
            Map<String,AggregateResult> sheetAndSheetLineAggregateMap = new Map<String,AggregateResult> ();
            for(AggregateResult item: groupedResults){
                if(sheetAndSheetLineAggregateMap.get((String)item.get('buildertek__SOV_Continuation_Sheet__c'))!=null){
                    sheetAndSheetLineAggregateMap.put((String)item.get('buildertek__SOV_Continuation_Sheet__c'),item);                                        
                }else{
                    sheetAndSheetLineAggregateMap.put((String)item.get('buildertek__SOV_Continuation_Sheet__c'),item);                    
                }
            }
            
            List<String> updateAppIdList = new List<String>();
            for(buildertek__SOV_Payment_Application__c appItem: paymentAppList){
                buildertek__SOV_Payment_Application__c newapp = new buildertek__SOV_Payment_Application__c();
                system.debug(appItem.Id);
                for(String sheetIdItem: sheetAppMap.keySet()){
                    if(sheetAppMap.get(sheetIdItem) == appItem.Id){
                        ContinuationDetails cd = new ContinuationDetails();
                        system.debug(sheetAndSheetLineAggregateMap);
                        system.debug(sheetAndSheetLineAggregateMap.get(sheetIdItem));
                        cd.scheduleValueTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('scheduleValue'); 
                        cd.workFromPrevAppTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('fromPrevApp');
                        cd.workcompletedTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('workCompleted');
                        cd.materialsStoredTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('materialStored');
                        cd.totalCompletedStored = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('totalWork');
                        cd.gcTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('gcTotal');
                        cd.balanceTotal = (Decimal)sheetAndSheetLineAggregateMap.get(sheetIdItem).get('balanceTotal');
                        newapp.Id = appItem.Id;
                        Double retainage = appItem.buildertek__Retainage__c;
                        if(cd.totalCompletedStored != null ) {
                            newapp.buildertek__Total_Completed_and_Stored_To_Date__c = cd.totalCompletedStored;
                        }
                        if(cd.workFromPrevAppTotal != null && retainage != null) {
                            newapp.buildertek__Retainage_of_Completed_Work__c = (retainage * (cd.workFromPrevAppTotal + cd.workcompletedTotal));
                        }
                        if(cd.materialsStoredTotal != null && retainage != null) {
                            newapp.buildertek__Retainage_of_Stored__c = (retainage * (cd.materialsStoredTotal ));                               
                        }
                        system.debug(newapp.Id);
                        if(updateAppIdList.indexOf(newapp.Id) < 0){
                            updateAppList.add(newapp);
                        }
                    }
                }
            } 
        }
        
        if(updateAppList.Size()>0){
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
            update updateAppList;
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false; 
        }
        
        //  Payment app balance to finish field populate  Start
        list<String> ConSheetLineIds = new list<String> ();
        if(!oldconsheetline.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c sheetLine : oldconsheetline){
                ConSheetLineIds.add(sheetLine.Id);
            }
        }
        
        //   list<SOV_Continuation_Sheet_Lines__c> updateStatus = [select Id, Name,buildertek__SOV_Continuation_Sheet__c,buildertek__Balance_To_Finish__c from SOV_Continuation_Sheet_Lines__c where Id IN: ConSheetLineIds];
        
        List<String> conSheetIdList = new List<String>();
        if(!oldconsheetline.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : oldconsheetline){
                
                conSheetIdList.add(conSheet.buildertek__SOV_Continuation_Sheet__c);
            }
        }
        
        buildertek__SOV_Continuation__c conSheetList = [select Id, Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: conSheetIdList[0]  Limit 10000];

        
        list<SOV_Continuation_Sheet_Lines__c>  AllConSheetLineIds = [select Id, Name, buildertek__SOV_Continuation_Sheet__c from SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c =:conSheetList.Id Limit 10000 ];
        
        List<String> NewChildIds = new List<String>();
        
        if(!AllConSheetLineIds.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : AllConSheetLineIds){
                NewChildIds.add(conSheet.Id);
            }
        }        
        
        buildertek__SOV_Payment_Application__c PaymentApp = [select Id, Name,buildertek__Net_Change_by_Change_Orders__c, buildertek__Total_Balance_To_Finish__c, buildertek__Total_Completed__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =: conSheetList.buildertek__SOV_Payment_Application__c  Limit 10000];
        
        List<buildertek__SOV_Payment_Application__c> newPaymentApp = [select Id, Name,buildertek__Application_Number__c, buildertek__Total_Balance_To_Finish__c, buildertek__Total_Completed__c, buildertek__Total_Material_Stored_To_Date__c, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =:PaymentApp.Id  Limit 10000];
        
        if(!newPaymentApp.isEmpty()){
        
            List<AggregateResult> result ;
            
            if(newPaymentApp[0].buildertek__Application_Number__c == 1){
                result  = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                           WHERE Id IN: NewChildIds AND buildertek__Budget_Grouping__c != 'Change Orders'];
                system.debug('********decodedPassword:' + result);
            }else{
                result = [SELECT SUM(buildertek__Balance_To_Finish__c )totalCost,SUM(buildertek__Vendor_Scheduled_Value__c )totalVendorContractSum,SUM(buildertek__Work_Completed_from_Previous_Application__c)totalCompletedfromprevApp, SUM(buildertek__Work_Completed__c)totalCompleted, SUM(buildertek__Material_Presently_Stored__c)totalMaterialStored, SUM(buildertek__Scheduled_Value__c)totalContractSum  FROM SOV_Continuation_Sheet_Lines__c
                          WHERE Id IN: NewChildIds];
                system.debug('********decodedPassword:' + result);
            }
            

            for(AggregateResult agg : result){
                newPaymentApp[0].buildertek__Total_Balance_To_Finish__c = (decimal)agg.get('totalCost'); 
                newPaymentApp[0].buildertek__Total_Completed__c = (decimal)agg.get('totalCompleted'); 
                newPaymentApp[0].buildertek__Total_Completed_From_Previous_App__c = (decimal)agg.get('totalCompletedfromprevApp'); 
                
                newPaymentApp[0].buildertek__Total_Material_Stored_To_Date__c = (decimal)agg.get('totalMaterialStored');
                newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalContractSum') - PaymentApp.buildertek__Net_Change_by_Change_Orders__c ;
            }
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
            update newPaymentApp;
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
        }   
    }
    
    public static void updatePaymentApplication(List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLine){
        system.debug('sheetLinetodelete-->'+sheetLine);
        Set<Id> sheetId=new Set<Id>();
        Decimal total=0.0;
        Decimal negativeTotal = 0.0;
        for(buildertek__SOV_Continuation_Sheet_Lines__c sheetLine1:sheetLine){
            sheetId.add(sheetLine1.buildertek__SOV_Continuation_Sheet__c );
        }
        List<buildertek__SOV_Continuation_Sheet_Lines__c> continutonSheetLines=[SELECT Id, 
                                                                                Name,
                                                                                buildertek__Grouping__c,
                                                                                buildertek__Scheduled_Value__c,
                                                                                buildertek__Budget_Grouping__c,
                                                                                buildertek__Is_Created_In_This_App__c,
                                                                                buildertek__SOV_Continuation_Sheet__c
                                                                                FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                where buildertek__SOV_Continuation_Sheet__c in: sheetId and buildertek__Budget_Grouping__c='Change Orders' AND buildertek__Is_Created_In_This_App__c = true  Limit 10000 ];
        List<buildertek__SOV_Continuation__c> csheet=[SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c where id in : sheetId limit 1];
        if(!csheet.isEmpty()){
            List<buildertek__SOV_Payment_Application__c> paymentApp=[SELECT Id,
                                                                     Name, 
                                                                     buildertek__Change_Order_Additions__c, 
                                                                     buildertek__Change_Order_Decuctions__c 
                                                                     FROM buildertek__SOV_Payment_Application__c where id=:csheet[0].buildertek__SOV_Payment_Application__c limit 1];
           
            system.debug('paymentApp--------->'+paymentApp);
            if(!continutonSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c sl:continutonSheetLines){
                    if(sl.buildertek__Scheduled_Value__c != null){
                        if(sl.buildertek__Scheduled_Value__c >= 0){
                            total+=sl.buildertek__Scheduled_Value__c;   
                        }else{
                            negativeTotal+=sl.buildertek__Scheduled_Value__c;
                        }
                        
                    }
                }
            }
            if(!paymentApp.isEmpty()){
                for(buildertek__SOV_Payment_Application__c pa:paymentApp){
                    if(total>0){
                        pa.buildertek__Change_Order_Additions__c=total;
                        system.debug(total);
                    }else{
                        pa.buildertek__Change_Order_Decuctions__c= negativeTotal;
                        // pa.buildertek__Change_Order_Additions__c=total;
                    }
                }
            }
            
            system.debug('paymentApp---0--->'+paymentApp);
            
            if(!paymentApp.isEmpty()){
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
                update paymentApp;
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
            }
        }
    }
    
    // This method used to update payment app record status based on continuation sheet line records status
    public static void updatePaymentAppStatusBasedOnConSheetLinesStatusOnAfterUpdate(List<buildertek__SOV_Continuation_Sheet_Lines__c> conSheetLinesList, Map<Id, buildertek__SOV_Continuation_Sheet_Lines__c> conSheetLinesOldMap){
        List<Id> conSheetIds = New List<Id>();
        List<Id> paymentAppIds = New List<Id>();
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> IntparentSOVList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        for(buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine : conSheetLinesList){
            if(conSheetLine.buildertek__Status__c != conSheetLinesOldMap.get(conSheetLine.Id).buildertek__Status__c){
                if(conSheetLine.buildertek__SOV_Continuation_Sheet__c != null && (conSheetLine.buildertek__Status__c == 'Accepted' || conSheetLine.buildertek__Status__c == 'Rejected')){
                    conSheetIds.add(conSheetLine.buildertek__SOV_Continuation_Sheet__c);
                }
            }
        }
        if(!conSheetIds.isEmpty()){
            List<buildertek__SOV_Continuation_Sheet_Lines__c> conSheetLinesList2 = [SELECT Id,
                                                                                    buildertek__Status__c, 
                                                                                    buildertek__SOV_Continuation_Sheet__c,
                                                                                    buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                                    buildertek__Vendor_Work_Completed_This_Period__c,
                                                                                    buildertek__Vendor_Material_Presently_Stored__c,
                                                                                    buildertek__Vendor_Total__c,
                                                                                    buildertek__Vendor_G_C__c,
                                                                                    buildertek__Vendor_Balance_To_Finish__c,
                                                                                    buildertek__Vendor_Retainage__c,
                                                                                    buildertek__Scheduled_Value__c,
                                                                                    buildertek__Work_Completed_from_Previous_Application__c,
                                                                                    buildertek__Work_Completed__c,
                                                                                    buildertek__Material_Presently_Stored__c
                                                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__c IN: conSheetIds  Limit 10000];
            List<buildertek__SOV_Continuation__c> conSheetList = [SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE Id IN: conSheetIds  Limit 10000];
            if(!conSheetList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : conSheetList){
                    if(con.buildertek__SOV_Payment_Application__c != null){
                        paymentAppIds.add(con.buildertek__SOV_Payment_Application__c);
                    }
                }
                if(!paymentAppIds.isEmpty()){
                    List<buildertek__SOV_Payment_Application__c> paymentAppList = [SELECT Id, Name, RecordTypeId, RecordType.Name, buildertek__Status__c FROM buildertek__SOV_Payment_Application__c WHERE Id IN: paymentAppIds  Limit 10000];
                    Map<Id, List<String>> map1 = New Map<Id, List<String>>();
                    for(buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine : conSheetLinesList2){
                        if(!map1.containsKey(conSheetLine.buildertek__SOV_Continuation_Sheet__c)){
                            map1.put(conSheetLine.buildertek__SOV_Continuation_Sheet__c, New List<String>());
                        }
                        map1.get(conSheetLine.buildertek__SOV_Continuation_Sheet__c).add(conSheetLine.buildertek__Status__c);
                    }
                    
                    for(buildertek__SOV_Payment_Application__c paymentAppRec : paymentAppList){
                        if(paymentAppRec.RecordType.Name == 'AP'){
                            for(buildertek__SOV_Continuation__c conRec : conSheetList){
                                if(paymentAppRec.id == conRec.buildertek__SOV_Payment_Application__c ){
                                    if(map1.get(conRec.id).contains('Rejected')){
                                        paymentAppRec.buildertek__Status__c = 'Company Rejected';
                                    }else if(!map1.get(conRec.id).contains('Pending')  && !map1.get(conRec.id).contains('Vendor Submitted') && !map1.get(conRec.id).contains('N/A')){
                                        system.debug('113333');
                                        paymentAppRec.buildertek__Status__c = 'Company Accepted ';
                                    }  
                                }
                            }
                        }
                    }
                    if(!paymentAppList.isEmpty()){
                        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
                        update paymentAppList;
                        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
                    }   
                }
            }
        }
    }
    
    // This method used to update payment app record status based on continuation sheet line records status
    public static void updatePaymentAppStatusBasedOnConSheetLinesStatus(List<buildertek__SOV_Continuation_Sheet_Lines__c> conSheetLinesList){
        List<Id> conSheetIds = New List<Id>();
        List<Id> paymentAppIds = New List<Id>();
        
        for(buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine : conSheetLinesList){
            if(conSheetLine.buildertek__SOV_Continuation_Sheet__c != null && (conSheetLine.buildertek__Status__c == 'Accepted' || conSheetLine.buildertek__Status__c == 'Rejected')){
                conSheetIds.add(conSheetLine.buildertek__SOV_Continuation_Sheet__c);
            }
        }
        if(!conSheetIds.isEmpty()){
            List<buildertek__SOV_Continuation_Sheet_Lines__c> conSheetLinesList2 = [SELECT Id, buildertek__Status__c, buildertek__SOV_Continuation_Sheet__c FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__c IN: conSheetIds  Limit 10000];
            List<buildertek__SOV_Continuation__c> conSheetList = [SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE Id IN: conSheetIds  Limit 10000];
            if(!conSheetList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : conSheetList){
                    if(con.buildertek__SOV_Payment_Application__c != null){
                        paymentAppIds.add(con.buildertek__SOV_Payment_Application__c);
                    }
                }
                if(!paymentAppIds.isEmpty()){
                    List<buildertek__SOV_Payment_Application__c> paymentAppList = [SELECT Id, Name, RecordTypeId, RecordType.Name, buildertek__Status__c FROM buildertek__SOV_Payment_Application__c WHERE Id IN: paymentAppIds  Limit 10000];
                    Map<Id, List<String>> map1 = New Map<Id, List<String>>();
                    
                    for(buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine : conSheetLinesList2){
                        if(!map1.containsKey(conSheetLine.buildertek__SOV_Continuation_Sheet__c)){
                            map1.put(conSheetLine.buildertek__SOV_Continuation_Sheet__c, New List<String>());
                        }
                        map1.get(conSheetLine.buildertek__SOV_Continuation_Sheet__c).add(conSheetLine.buildertek__Status__c);
                    }
                    //  system.debug('map1---'+map1);
                    for(buildertek__SOV_Payment_Application__c paymentAppRec : paymentAppList){
                        if(paymentAppRec.RecordType.Name == 'AP'){
                            for(buildertek__SOV_Continuation__c conRec : conSheetList){
                                if(paymentAppRec.id == conRec.buildertek__SOV_Payment_Application__c ){
                                    if(map1.get(conRec.id).contains('Rejected')){
                                        system.debug('11');
                                        paymentAppRec.buildertek__Status__c = 'Company Rejected';
                                    }
                                    else if(!map1.get(conRec.id).contains('Pending')  && !map1.get(conRec.id).contains('Vendor Submitted') && !map1.get(conRec.id).contains('N/A')){
                                        system.debug('113333');
                                        paymentAppRec.buildertek__Status__c = 'Company Accepted ';
                                    }
                                }
                            }
                        }
                    }
                    if(!paymentAppList.isEmpty()){
                        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
                        update paymentAppList;
                        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
                    }
                }
            }
        }
        
        //  Code for giving permission to master sov for community
        List<buildertek__SOV_Continuation_Sheet_Lines__Share> rfqshareList=new List<buildertek__SOV_Continuation_Sheet_Lines__Share>();
        list<buildertek__SOV_Continuation_Sheet_Lines__c>  SOVRec  = [select Id, name, buildertek__SOV_Continuation_Sheet__c,
                                                                      buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name,
                                                                      buildertek__Vendor__c
                                                                      from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                      where Id IN: conSheetLinesList AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name = 'AP'  Limit 10000];
        
        set<Id> vendorIds = new set<Id>();
        map<Id,User> vendorUserMap = new map<Id,User>();
        
        string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
            'FROM User Where isPortalEnabled=true ';    
        list<User> usersList = Database.query(strQry);
        if(usersList.size() > 0){
            for(User usr: usersList){
                vendorUserMap.put(usr.AccountId,usr);
            }
        }
        
        for (buildertek__SOV_Continuation_Sheet_Lines__c rfqVendor : SOVRec){
            for(User usr1: usersList){
                if(rfqVendor.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name == 'AP'){
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId || rfqVendor.buildertek__Vendor__c == null){
                        buildertek__SOV_Continuation_Sheet_Lines__Share rfqshare=new buildertek__SOV_Continuation_Sheet_Lines__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__SOV_Continuation_Sheet_Lines__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                    } 
                }
            } 
        }
        if(rfqshareList.size()>0){
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
            ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
        }   
    }
    
    
    
    
    public static void updatePaymentApplicationbeforedelete(List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLine){
        system.debug('sheetLinetodelete-->'+sheetLine);
        Set<Id> sheetId=new Set<Id>();
        Decimal total=0.0;
        Decimal negativeTotal = 0.0;
        for(buildertek__SOV_Continuation_Sheet_Lines__c sheetLine1:sheetLine){
            sheetId.add(sheetLine1.buildertek__SOV_Continuation_Sheet__c );
        }
        
        system.debug('sheetId--------->'+sheetId);
        
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> continutonSheetLines=[SELECT Id, 
                                                                                Name,
                                                                                buildertek__Grouping__c,
                                                                                buildertek__Scheduled_Value__c,
                                                                                buildertek__Budget_Grouping__c,
                                                                                buildertek__SOV_Continuation_Sheet__c
                                                                                FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                where buildertek__SOV_Continuation_Sheet__c in: sheetId and buildertek__Budget_Grouping__c='Change Orders' Limit 10000 ];
        List<buildertek__SOV_Continuation__c> csheet=[SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c where id in : sheetId limit 1];
        
        system.debug('payappdelete--->'+csheet[0].buildertek__SOV_Payment_Application__c);
        if(!csheet.isEmpty()){
            List<buildertek__SOV_Payment_Application__c> paymentApp=[SELECT Id,
                                                                     Name, 
                                                                     buildertek__Change_Order_Additions__c, 
                                                                     buildertek__Change_Order_Decuctions__c 
                                                                     FROM buildertek__SOV_Payment_Application__c where id=:csheet[0].buildertek__SOV_Payment_Application__c limit 1];
            
            
            if(!continutonSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c sl:continutonSheetLines){
                    
                    if(sl.buildertek__Scheduled_Value__c >= 0){
                        total+=sl.buildertek__Scheduled_Value__c;   
                    }else{
                        negativeTotal+=sl.buildertek__Scheduled_Value__c;
                    }
                    
                    
                }
            }
            
            system.debug('tota-0---->'+total);
            
            if(!paymentApp.isEmpty()){
                for(buildertek__SOV_Payment_Application__c pa:paymentApp){
                    if(total>0){
                        pa.buildertek__Change_Order_Additions__c=total;
                        system.debug(total);
                    }else {
                        pa.buildertek__Change_Order_Additions__c = total;
                        pa.buildertek__Change_Order_Decuctions__c = total;
                        
                    }
                }
            }
            if(!paymentApp.isEmpty()){
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = true;
                update paymentApp;
                system.debug('paymentApp[0].buildertek__Change_Order_Additions__c--->'+paymentApp[0].buildertek__Change_Order_Additions__c);
                ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger = false;
            }
        }
    }
    
    
    
    
  
    public void isAllLinesCompleted(List<SOV_Continuation_Sheet_Lines__c> oldconsheetline, List<SOV_Continuation_Sheet_Lines__c> newconsheetline, Map<Id, SOV_Continuation_Sheet_Lines__c> oldconsheetlineMap, Map<Id, SOV_Continuation_Sheet_Lines__c> newconsheetlineMap){
        
        //  Payment app balance to finish field populate  Start
        list<String> ConSheetLineIds = new list<String> ();
        if(!newconsheetline.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c sheetLine : newconsheetline){
                ConSheetLineIds.add(sheetLine.Id);
            }
        }
        
        
        
        list<SOV_Continuation_Sheet_Lines__c> updateStatus = [select Id, Name,buildertek__SOV_Continuation_Sheet__c,buildertek__Balance_To_Finish__c from SOV_Continuation_Sheet_Lines__c where Id IN: ConSheetLineIds  Limit 10000];
        
        List<String> conSheetIdList = new List<String>();
        if(!updateStatus.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c conSheet : updateStatus){
                conSheetIdList.add(conSheet.buildertek__SOV_Continuation_Sheet__c);
            }
        }
        
        List<buildertek__SOV_Continuation__c> conSheetList = [select Id, Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: conSheetIdList[0]  Limit 10000];
        
         List<String> NewChildIds = new List<String>();
        
        system.debug( conSheetList);
        if(!conSheetList.isEmpty()){
            list<SOV_Continuation_Sheet_Lines__c>  AllConSheetLineIds = [select Id, Name, buildertek__SOV_Continuation_Sheet__c from SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c IN:conSheetList  Limit 10000];
           
            if(!AllConSheetLineIds.isEmpty()){
                for(SOV_Continuation_Sheet_Lines__c conSheet : AllConSheetLineIds){
                    
                    NewChildIds.add(conSheet.Id);
                }
            }
        }
        
        List<buildertek__SOV_Payment_Application__c> PaymentApp = new List<buildertek__SOV_Payment_Application__c>();
        
        if(!conSheetList.isEmpty()){
                     PaymentApp = [select Id, Name, buildertek__IsCompleted__c, recordtype.name  from buildertek__SOV_Payment_Application__c where Id =: conSheetList[0].buildertek__SOV_Payment_Application__c and recordtype.name = 'AP'  Limit 1];

        }
        
        
        
        
        List<SOV_Continuation_Sheet_Lines__c> NewContinuationSheetLineList = [select id,
                                                                              Name,
                                                                              buildertek__NewVendor_G_C__c,
                                                                              buildertek__Vendor_G_C__c
                                                                              from SOV_Continuation_Sheet_Lines__c
                                                                              where id IN: NewChildIds
                                                                             ];
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sovConLinesGCList = New List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        
        for(buildertek__SOV_Continuation_Sheet_Lines__c sovConLinesRec : NewContinuationSheetLineList){
            if(sovConLinesRec.buildertek__Vendor_G_C__c != 100){
                sovConLinesGCList.add(sovConLinesRec);
            }
        }
        
        if(!PaymentApp.isEmpty()){ 
            
            if(sovConLinesGCList.isEmpty()){ 
                PaymentApp[0].buildertek__IsCompleted__c = true;
            }else{
                PaymentApp[0].buildertek__IsCompleted__c = false; 
            }
            update PaymentApp;
        }
        
        
        
        
        
    }
    
  
    
    
    public class ContinuationDetails{
        @AuraEnabled public buildertek__SOV_Continuation__c continuationSheet;
        @AuraEnabled public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines;
        @AuraEnabled public buildertek__SOV_Payment_Application__c paymentapplication;
        @AuraEnabled public Decimal scheduleValueTotal;
        @AuraEnabled public Decimal workFromPrevAppTotal;
        @AuraEnabled public Decimal workcompletedTotal;
        @AuraEnabled public Decimal materialsStoredTotal;
        @AuraEnabled public Decimal totalCompletedStored;
        @AuraEnabled public Decimal gcTotal;
        @AuraEnabled public Decimal balanceTotal;
        @AuraEnabled public Boolean isApplication;
    }
}