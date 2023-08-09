public without sharing class CreatePaymentApplicationForBudget {
    
    
    @AuraEnabled
    public static string getRfqTo(){
        return UserInfo.getDefaultCurrency();
    }
    
    @AuraEnabled
    public static Boolean getChangeOrderBtValue(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Get_Lines_From_CO__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Payment Application Configuration'];
        Boolean islien = false;
        if(adminInterfaceNodeConfigurations.buildertek__Get_Lines_From_CO__c == true){
            islien = true;
        }
        return islien;
    } 
    
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__SOV_Continuation_Sheet_Lines__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__ContinuationSheetLineFields')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__ContinuationSheetLineFields').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__SOV_Continuation_Sheet_Lines__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
        }
        return '[' + result + ']';
    }
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static BudgetClass getPaymentApplications(String budgetId){
        BudgetClass bc = new BudgetClass();
        buildertek__Budget__c budget = [select id, 
                                        Name, 
                                        buildertek__Project__c,
                                        (select Id,
                                         Name,
                                         buildertek__Cost_Code__c,
                                         buildertek__Cost_Code__r.Name,
                                         buildertek__Original_Budget__c,
                                         buildertek__Budget__r.Name
                                         from buildertek__Budget_Items__r)
                                        from buildertek__Budget__c where Id =: budgetId];
        
        List<buildertek__SOV_Payment_Application__c > ProjApps = [select Id,
                                                                  Name, 
                                                                  buildertek__Application__c, 
                                                                  buildertek__Period_To__c,
                                                                  buildertek__Owner_Name__c, 
                                                                  buildertek__Vendor__c,
                                                                  buildertek__Project__c,
                                                                  buildertek__Contract_For__c,
                                                                  buildertek__Architect__c,
                                                                  buildertek__Contract_Date__c  
                                                                  from buildertek__SOV_Payment_Application__c 
                                                                  where buildertek__Project__c =: budget.buildertek__Project__c
                                                                  Order By CreatedDate DESC];
        bc.budgetItems = budget.buildertek__Budget_Items__r;
        bc.paymentApplicationsList = ProjApps;
        bc.project = budget.buildertek__Project__c;
        return bc;
    }
    
    @AuraEnabled
    public static responseclass InsertApplication(buildertek__SOV_Payment_Application__c paymentApplicationsRecord, string applicationName, Date periodDate) {
        
        try{
            system.debug('werttttttttttttttttttttttttttttttttttttttt');
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            buildertek__SOV_Payment_Application__c newPaymentApplication = new buildertek__SOV_Payment_Application__c();
            if(applicationName != null){
                newPaymentApplication.Name = applicationName;    
            }else{
                newPaymentApplication.Name = paymentApplicationsRecord.Name;    
            }
            if(periodDate != null){
                newPaymentApplication.buildertek__Period_To__c = periodDate;    
            }else{
                newPaymentApplication.buildertek__Period_To__c = paymentApplicationsRecord.buildertek__Period_To__c;     
            }
            newPaymentApplication.buildertek__Application__c = String.valueOf(paymentApplicationsRecord.buildertek__Application__c);
            newPaymentApplication.buildertek__Architect__c = paymentApplicationsRecord.buildertek__Architect__c;
            newPaymentApplication.buildertek__Contract_Date__c = paymentApplicationsRecord.buildertek__Contract_Date__c;
            newPaymentApplication.buildertek__Vendor__c = paymentApplicationsRecord.buildertek__Vendor__c;
            newPaymentApplication.buildertek__Project__c = paymentApplicationsRecord.buildertek__Project__c;
            newPaymentApplication.buildertek__Contract_For__c = paymentApplicationsRecord.buildertek__Contract_For__c;
            insert newPaymentApplication;
            
            buildertek__SOV_Payment_Application__c mlistApp = [select id, 
                                                               Name,
                                                               owner.name,
                                                               owner.id, 
                                                               Owner_Name__c,
                                                               buildertek__Application__c,
                                                               buildertek__Period_To__c,
                                                               buildertek__Contract_Date__c
                                                               from buildertek__SOV_Payment_Application__c 
                                                               where id=:newPaymentApplication.Id ];
            mlistApp.Owner_Name__c = mlistApp.owner.name;
            update mlistApp;
            
            /*buildertek__SOV_Continuation__c continutionSheet = new buildertek__SOV_Continuation__c();
continutionSheet.Name =*/ 
            
            responseclass responseclassrec = new responseclass();
            responseclassrec.isSuccess = true;
            responseclassrec.SuccessMessage = mlistApp.Id;
            responseclassrec.ApplicationId = mlistApp.buildertek__Application__c;
            responseclassrec.paymentApplication = mlistApp;
            return responseclassrec;
        }
        catch(Exception e){
            responseclass responseclassrec = new responseclass();
            responseclassrec.isSuccess = false;
            responseclassrec.ErrorMessage = e.getMessage();
            return responseclassrec;
        }
    }
    
    @AuraEnabled
    public static responseclass insertContinuationSheet(buildertek__SOV_Continuation__c continuationSheet, String paymentApplicationId, String applicationNumber){
        system.debug('continuationSheet -------> '+continuationSheet);
        system.debug('paymentApplicationId -------> '+paymentApplicationId);
        system.debug('applicationNumber -------> '+applicationNumber);
        responseclass rc = new responseclass();
        try{
            continuationSheet.buildertek__Application__c = Integer.valueOf(applicationNumber);
            continuationSheet.buildertek__SOV_Payment_Application__c = paymentApplicationId;
            insert continuationSheet;
            rc.isSuccess = true;
            rc.SuccessMessage = continuationSheet.Id; 
        }catch(Exception exp){
            rc.isSuccess = false;
            rc.ErrorMessage = exp.getMessage();    
        }
        return rc;
    }
    
    @AuraEnabled
    public static responseclass createSheetLines(String sheetLines, String continuationId){
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLinesList = (List<buildertek__SOV_Continuation_Sheet_Lines__c>)System.JSON.deserialize(sheetLines, List<buildertek__SOV_Continuation_Sheet_Lines__c>.class);    
        responseclass rc = new responseclass();
        SET<Id> sheetLineIds = new SET<Id>();
        buildertek__SOV_Continuation__c sheetId = [select Id, name, buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =:continuationId LIMIT 1];
        try{
            for(buildertek__SOV_Continuation_Sheet_Lines__c csl : sheetLinesList){
                csl.buildertek__SOV_Continuation_Sheet__c = continuationId;
            }
            insert sheetLinesList;
            List<buildertek__SOV_Continuation_Sheet_Lines__c> insertedSheetLinesList = [SELECT Id,
                                                                                        Name,
                                                                                        buildertek__Description_of_Work__c,
                                                                                        buildertek__Scheduled_Value__c,
                                                                                        buildertek__Work_Completed_from_Previous_Application__c,
                                                                                        buildertek__Work_Completed__c,
                                                                                        buildertek__Material_Presently_Stored__c,
                                                                                        buildertek__Total__c,
                                                                                        buildertek__G_C__c,
                                                                                        buildertek__Balance_To_Finish__c
                                                                                        FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                        WHERE Id IN: sheetLinesList];
            rc.isSuccess = true;
            rc.sheetLines = insertedSheetLinesList;
        }catch(Exception exp){
            rc.ErrorMessage = exp.getMessage();     
        }
        return rc;
    }
    @AuraEnabled
    public static ContinuationDetails getContinuationSheetLines(String recordId){
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug('postel code'+ portalCode);
        System.debug('*******************************************');
        buildertek__SOV_Continuation__c continuationSheet;
        buildertek__SOV_Payment_Application__c paymentapplication;
        Boolean isApplication;
        system.debug('recordId'+recordId);
        system.debug(recordid+' '+Id.valueOf(recordId).getSObjectType().getDescribe().getName());
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__SOV_Payment_Application__c'){
            continuationSheet = [SELECT Id, 
                                 Name,
                                 buildertek__Application__c,
                                 buildertek__Application_Date__c,
                                 buildertek__Architect_Project_No__c,
                                 buildertek__Period_To__c,
                                 
                                 buildertek__SOV_Payment_Application__r.buildertek__Total_Completed__c  ,
                                 buildertek__SOV_Payment_Application__c,
                                 buildertek__SOV_Payment_Application__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Project__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Project__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Retainage__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Application__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Architect__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Period_To__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Architect__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Submission_Date__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c,
                                 buildertek__SOV_Payment_Application__r.RecordTypeId,
                                 buildertek__SOV_Payment_Application__r.recordtype.name
                                 FROM buildertek__SOV_Continuation__c 
                                 WHERE buildertek__SOV_Payment_Application__c =: recordId LIMIT 1];
            system.debug('continuationSheet'+continuationSheet.id);
            
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__SOV_Continuation__c'){
            continuationSheet = [SELECT Id, 
                                 Name,
                                 buildertek__Application__c,
                                 buildertek__Application_Date__c,
                                 buildertek__Architect_Project_No__c,
                                 buildertek__Period_To__c,
                                 buildertek__SOV_Payment_Application__c,
                                 
                                 buildertek__SOV_Payment_Application__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Project__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Project__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Retainage__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Application__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Architect__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Period_To__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Architect__r.Name,
                                 buildertek__SOV_Payment_Application__r.buildertek__Submission_Date__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                 buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c,
                                 buildertek__SOV_Payment_Application__r.RecordTypeId,
                                 buildertek__SOV_Payment_Application__r.recordtype.name
                                 FROM buildertek__SOV_Continuation__c
                                 WHERE Id =: recordId];   
            isApplication = false;
        }
        system.debug('contunitution sheet retainage' + continuationSheet);
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> insertedSheetLinesList = [SELECT Id,
                                                                                    Name,
                                                                                    buildertek__Description_of_Work__c,
                                                                                    buildertek__Scheduled_Value__c,
                                                                                    buildertek__Work_Completed_from_Previous_Application__c,
                                                                                    buildertek__Work_Completed__c,
                                                                                    buildertek__Material_Presently_Stored__c,
                                                                                    buildertek__Total__c,
                                                                                    buildertek__G_C__c,
                                                                                    buildertek__Balance_To_Finish__c,
                                                                                    buildertek__SOV_Continuation_Sheet__c,
                                                                                    buildertek__Grouping__c,
                                                                                    buildertek__Grouping2__c,buildertek__Status__c,
                                                                                    buildertek__Budget_Grouping__c,buildertek__Rejection_Reason__c,
                                                                                    //For Community User  - start
                                                                                    buildertek__Vendor_Scheduled_Value__c,
                                                                                    buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                                    buildertek__Vendor_Work_Completed_This_Period__c,
                                                                                    buildertek__Vendor_Material_Presently_Stored__c,
                                                                                    buildertek__Vendor_Total__c,
                                                                                    buildertek__Vendor_G_C__c,
                                                                                    buildertek__Vendor_Balance_To_Finish__c,
                                                                                    buildertek__Item_No__c,
                                                                                    buildertek__Vendor_Retainage__c,
                                                                                    buildertek__Change_Order__c
                                                                                    //For Community User  - end
                                                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                    WHERE buildertek__SOV_Continuation_Sheet__c =: continuationSheet.Id  ORDER BY buildertek__Item_No__c ASC];
        
        
        
        Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>> sheetLineGrpMap = new  Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>>();
        
        for(buildertek__SOV_Continuation_Sheet_Lines__c sheetLine : insertedSheetLinesList){

            System.debug('sheetLine===>'+sheetLine);
            
            if(sheetLine.buildertek__Grouping__c != null){
                if(sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c)!=null){
                    // system.debug(sheetLine);
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineList= sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c);
                    }else{
                        sheetLineList= sheetLineGrpMap.get('No Grouping');
                    }
                    sheetLineList.add(sheetLine); 
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList);                    
                    }else{
                        sheetLineGrpMap.put('No Grouping',sheetLineList);                    
                    }                                       
                }else{
                    // system.debug(sheetLine);
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    sheetLineList.add(sheetLine);
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList);                    
                    }else{
                        sheetLineGrpMap.put('No Grouping',sheetLineList);                    
                    }
                }
            }else{
                if(sheetLineGrpMap.get('No Grouping')!=null){
                    // system.debug(sheetLine);
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineList= sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c);
                    }else{
                        sheetLineList= sheetLineGrpMap.get('No Grouping');
                    }
                    sheetLineList.add(sheetLine); 
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList);                    
                    }else{
                        sheetLineGrpMap.put('No Grouping',sheetLineList);                    
                    }                                        
                }else{
                    // system.debug(sheetLine);
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    sheetLineList.add(sheetLine);
                    if(sheetLine.buildertek__Grouping__c != null){
                        sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList);                    
                    }else{
                        sheetLineGrpMap.put('No Grouping',sheetLineList);                    
                    }
                }
            }
        }
        
        system.debug(sheetLineGrpMap.keySet());
        list<buildertek__SOV_Continuation_Sheet_Lines__c> sortedSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        list<buildertek__SOV_Continuation_Sheet_Lines__c> changeOrderSortedSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        for(String grpName : sheetLineGrpMap.keySet()){
            system.debug(grpName);
            system.debug(sheetLineGrpMap.get(grpName).Size());
            if(grpName != 'No Grouping' && grpName != 'Change Orders'){
                sortedSheetLines.addAll(sheetLineGrpMap.get(grpName));
            }else if(grpName == 'Change Orders'){
                changeOrderSortedSheetLines.addAll(sheetLineGrpMap.get(grpName));
            }
        }
        
        system.debug(insertedSheetLinesList.Size());
        system.debug(sortedSheetLines.Size());
        
        if(sheetLineGrpMap.get('No Grouping') != null){
            if(sheetLineGrpMap.get('No Grouping').Size() > 0){
                sortedSheetLines.addAll(sheetLineGrpMap.get('No Grouping'));
            }    
        }   
        
        if(changeOrderSortedSheetLines.size() > 0){
            sortedSheetLines.addAll(changeOrderSortedSheetLines);
        }
        
        if(portalCode == 'true'){
            system.debug('community user');
            
            List<AggregateResult> groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                                    SUM(buildertek__Vendor_Work_Completed_from_Previous_Appl__c) fromPrevApp,
                                                    SUM(buildertek__Vendor_Work_Completed_This_Period__c) workCompleted,
                                                    SUM(buildertek__Vendor_Material_Presently_Stored__c) materialStored,
                                                    SUM(buildertek__Vendor_Total__c) totalWork,
                                                    SUM(buildertek__Vendor_G_C__c) gcTotal,
                                                    SUM(buildertek__Vendor_Balance_To_Finish__c) balanceTotal,
                                                    buildertek__SOV_Continuation_Sheet__c
                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                    WHERE buildertek__SOV_Continuation_Sheet__c =: continuationSheet.Id
                                                    GROUP BY buildertek__SOV_Continuation_Sheet__c];
            ContinuationDetails cd = new ContinuationDetails();
            cd.isApplication = isApplication;
            cd.continuationSheet = continuationSheet;
            if(groupedResults.size() > 0){
                cd.sheetLines =  sortedSheetLines;
                cd.sheetLines = insertedSheetLinesList;
                cd.scheduleValueTotal = (Decimal)groupedResults[0].get('scheduleValue'); 
                cd.workFromPrevAppTotal = (Decimal)groupedResults[0].get('fromPrevApp');
                cd.workcompletedTotal = (Decimal)groupedResults[0].get('workCompleted');
                cd.materialsStoredTotal = (Decimal)groupedResults[0].get('materialStored');
                cd.totalCompletedStored = (Decimal)groupedResults[0].get('totalWork');
                //  cd.gcTotal = (Decimal)groupedResults[0].get('gcTotal');
                cd.gcTotal = ( (Decimal)groupedResults[0].get('totalWork') / (Decimal)groupedResults[0].get('scheduleValue') ) * 100;
                cd.balanceTotal = (Decimal)groupedResults[0].get('balanceTotal');
                system.debug('cdcddddddddddddddddddddddddddddddd'+cd);
            }
            cd.projectId = continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c;
            return cd;
            
        }
        else{
            List<AggregateResult> groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                                    SUM(buildertek__Work_Completed_from_Previous_Application__c) fromPrevApp,
                                                    SUM(buildertek__Work_Completed__c) workCompleted,
                                                    SUM(buildertek__Material_Presently_Stored__c) materialStored,
                                                    SUM(buildertek__Total__c) totalWork,
                                                    SUM(buildertek__New_G_C__c) gcTotal,
                                                    SUM(buildertek__Balance_To_Finish__c) balanceTotal,
                                                    buildertek__SOV_Continuation_Sheet__c
                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                    WHERE buildertek__SOV_Continuation_Sheet__c =: continuationSheet.Id
                                                    GROUP BY buildertek__SOV_Continuation_Sheet__c];
        system.debug(groupedResults);
        system.debug([SELECT id , name from buildertek__SOV_Continuation_Sheet_Lines__c]);


            ContinuationDetails cd = new ContinuationDetails();
            cd.isApplication = isApplication;
            cd.continuationSheet = continuationSheet;
            if(groupedResults.size() > 0){
                cd.sheetLines =  sortedSheetLines;
                cd.sheetLines = insertedSheetLinesList;
                cd.scheduleValueTotal = (Decimal)groupedResults[0].get('scheduleValue'); 
                cd.workFromPrevAppTotal = (Decimal)groupedResults[0].get('fromPrevApp');
                cd.workcompletedTotal = (Decimal)groupedResults[0].get('workCompleted');
                cd.materialsStoredTotal = (Decimal)groupedResults[0].get('materialStored');
                cd.totalCompletedStored = (Decimal)groupedResults[0].get('totalWork');
                
                // cd.gcTotal = (Decimal)groupedResults[0].get('gcTotal');
                cd.gcTotal = ( (Decimal)groupedResults[0].get('totalWork') / (Decimal)groupedResults[0].get('scheduleValue') ) * 100;
                cd.balanceTotal = (Decimal)groupedResults[0].get('balanceTotal');
                system.debug('cdcddddddddddddddddddddddddddddddd'+cd);
            }
            cd.projectId = continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c;
            return cd;
        }
    
    }
    
    
    @AuraEnabled
    public static responseclass updateSheetLines(String sheetLines, String sheetId, String recordId){
        system.debug('sheetLines---------->'+sheetLines);
        
        buildertek__SOV_Payment_Application__c  ARPayAPP = [select Id, Name, recordtype.name from buildertek__SOV_Payment_Application__c where Id =: recordId];
        
        responseclass rc = new responseclass();
        try{
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLinesList = (List<buildertek__SOV_Continuation_Sheet_Lines__c>)System.JSON.deserialize(sheetLines, List<buildertek__SOV_Continuation_Sheet_Lines__c>.class);    
            
            system.debug('sheetLinesList----------->'+sheetLinesList);
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> newSheetLineItem = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            
            
            list<String> ConSheetLineIds = new list<String> ();
            if(!sheetLinesList.isEmpty()){
                for(SOV_Continuation_Sheet_Lines__c sheetLine : sheetLinesList){
                    ConSheetLineIds.add(sheetLine.Id);
                }
            }
            
            system.debug('ConSheetLineIds------->'+ConSheetLineIds);
            
            list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                         buildertek__SOV_Continuation_Sheet__c,
                                                                         buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                         from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                         Where Id IN: ConSheetLineIds ORDER BY buildertek__Item_No__c ASC];
            
            system.debug('lastSOV-------->'+lastSOV);
            integer itemInc = 100;
            
            
            if(lastSOV.size() > 0){
                
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c SV : lastSOV){
                    SV.buildertek__Item_No__c = Integer.valueOf(itemInc);
                    itemInc++;
                }
                
                
            }
            
            system.debug('sheetList==>'+sheetLinesList.Size());
            Integer totalLength = sheetLinesList.Size();
            for (Integer i = sheetLinesList.size()-1 ;i >= 0 ; --i) {
                //system.debug(i+' '+sheetLinesList[i]+' '+sheetLinesList[i].Id);
                if (sheetLinesList[i].Id == null) {
                    //system.debug('null=>'+sheetLinesList[i]);
                    if(sheetLinesList[i].buildertek__Description_of_Work__c != ''){
                        sheetLinesList[i].Name =   sheetLinesList[i].buildertek__Description_of_Work__c;
                    }else{
                        sheetLinesList[i].Name = String.valueOf(totalLength - newSheetLineItem.Size());
                    }
                    sheetLinesList[i].buildertek__SOV_Continuation_Sheet__c = sheetId;
                    system.debug('itemInc--------->'+itemInc);
                    if(ARPayAPP.recordtype.name == 'AR'){
                        sheetLinesList[i].buildertek__Status__c = 'Accepted';  
                    }else{
                        sheetLinesList[i].buildertek__Status__c = 'Pending';
                    }
                    
                    sheetLinesList[i].buildertek__Item_No__c = itemInc;
                    itemInc++;
                    newSheetLineItem.add(sheetLinesList[i]);
                    
                    sheetLinesList.remove(i); 
                }
            }
            
            system.debug('sheetLinesList -------> '+sheetLinesList);
            system.debug('newSheetLineItem--->'+newSheetLineItem+' '+newSheetLineItem.Size());
            update sheetLinesList; 
            //system.debug('Before==>'+newSheetLineItem+' '+newSheetLineItem.Size());
            if(newSheetLineItem.Size()>0){
                insert newSheetLineItem;
            }
            for(buildertek__SOV_Continuation_Sheet_Lines__c c:newSheetLineItem){
                system.debug(c);
            }
            
            rc.isSuccess = true;
        }
        catch(Exception exp){
            system.debug(exp.getMessage());
            rc.ErrorMessage = exp.getMessage();
        }   
        return rc;
    }
    
    @AuraEnabled
    public static List<buildertek__SOV_Continuation_Sheet_Lines__c> updateFormula(String sheetItemId,String sheetId,String fieldName, Integer fieldValue){
        //system.debug(fieldName+' '+fieldValue+' '+recordId);
        buildertek__SOV_Continuation_Sheet_Lines__c UpdateF = new buildertek__SOV_Continuation_Sheet_Lines__c();
        UpdateF = [Select buildertek__Work_Completed_from_Previous_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where Id =: sheetItemId];
        // system.debug(UpdateF);
        if(fieldName == 'buildertek__Work_Completed_from_Previous_Application__c'){
            system.debug(fieldValue);
            UpdateF.buildertek__Work_Completed_from_Previous_Application__c = fieldValue;
        }else if(fieldName == 'buildertek__Scheduled_Value__c'){
            UpdateF.buildertek__Scheduled_Value__c = fieldValue;
        }else if(fieldName == 'buildertek__Work_Completed__c'){
            UpdateF.buildertek__Work_Completed__c = fieldValue;
        }else if(fieldName == 'buildertek__Material_Presently_Stored__c'){
            UpdateF.buildertek__Material_Presently_Stored__c = fieldValue;
        }
        update UpdateF;
        UpdateF.recalculateFormulas();
        buildertek__SOV_Continuation__c continuationSheet;
        list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineItems =  [SELECT Id,Name,
                                                                             buildertek__Description_of_Work__c,
                                                                             buildertek__Scheduled_Value__c,
                                                                             buildertek__Work_Completed_from_Previous_Application__c,
                                                                             buildertek__Work_Completed__c,
                                                                             buildertek__Material_Presently_Stored__c,
                                                                             buildertek__Total__c,
                                                                             buildertek__G_C__c,
                                                                             buildertek__Balance_To_Finish__c,buildertek__Status__c,
                                                                             buildertek__SOV_Continuation_Sheet__c,buildertek__Rejection_Reason__c
                                                                             FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                             WHERE buildertek__SOV_Continuation_Sheet__c =: sheetId];
        return sheetLineItems;
    }    
    
    public class BudgetClass{
        @AuraEnabled public List<buildertek__Budget_Item__c> budgetItems;
        @AuraEnabled public List<buildertek__SOV_Payment_Application__c> paymentApplicationsList;
        @AuraEnabled public String project;
    }
    public class responseclass{
        @AuraEnabled public boolean isSuccess;
        @AuraEnabled public string SuccessMessage;
        @AuraEnabled public string ErrorMessage;
        @AuraEnabled public string ApplicationId;
        @AuraEnabled public buildertek__SOV_Payment_Application__c paymentApplication;
        @AuraEnabled public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines;
    }
    
    public class ContinuationDetails{
        @AuraEnabled public buildertek__SOV_Continuation__c continuationSheet;
        @AuraEnabled public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines;
        // @AuraEnabled public buildertek__SOV_Payment_Application__c paymentapplication;
        @AuraEnabled public Decimal scheduleValueTotal;
        @AuraEnabled public Decimal workFromPrevAppTotal;
        @AuraEnabled public Decimal workcompletedTotal;
        @AuraEnabled public Decimal materialsStoredTotal;
        @AuraEnabled public Decimal totalCompletedStored;
        @AuraEnabled public Decimal materialStroredFromPrev;
        @AuraEnabled public Decimal gcTotal;
        @AuraEnabled public Decimal balanceTotal;
        @AuraEnabled public Boolean isApplication;
        @AuraEnabled public String projectId;
    }
    
    
    @AuraEnabled
    public static string deletesheetline(List<String> sheetlineIds){
        list<buildertek__SOV_Continuation_Sheet_Lines__c> APConnLine;
        if(!sheetlineIds.isEmpty()){
            APConnLine = [select Id, Name,buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where Id =:sheetlineIds[0]];
        }
        
        string PayAppId = APConnLine[0].buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c;
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlineslist = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        for (string lineId : sheetlineIds){
            buildertek__SOV_Continuation_Sheet_Lines__c sheetlinerec = new buildertek__SOV_Continuation_Sheet_Lines__c();
            sheetlinerec.Id = lineId;
            sheetlineslist.add(sheetlinerec);
        }
        
        
        
        
        
        try{
            // if (buildertek__SOV_Continuation_Sheet_Lines__c.sObjectType.getDescribe().isDeletable()){
            delete sheetlineslist;
            
            
            
            list<buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetLines = [select Id, buildertek__Item_No__c,
                                                                               buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                               from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                               where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =:PayAppId ORDER BY buildertek__Item_No__c ASC];
            
            
            integer itemInc = 100;
            
            
            if(!ConSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c SV : ConSheetLines){
                    SV.buildertek__Item_No__c = Integer.valueOf(itemInc);
                    itemInc++;
                }
                update ConSheetLines;   
            }
            return 'success';
            
            
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static string acceptsheetline(List<String> sheetlineIds, String recordId){
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlineslist = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        for (string lineId : sheetlineIds){
            buildertek__SOV_Continuation_Sheet_Lines__c sheetlinerec = new buildertek__SOV_Continuation_Sheet_Lines__c();
            sheetlinerec.Id = lineId;
            sheetlinerec.buildertek__Rejection_Reason__c = '';
            sheetlinerec.buildertek__Status__c = 'Accepted';
            sheetlineslist.add(sheetlinerec);
        }
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> ARineslist = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        buildertek__SOV_Continuation_Sheet_Lines__c APConnLine = [select Id, Name, buildertek__Vendor_Sheet_line_Id__c,buildertek__Vendor_Work_Completed_This_Period__c,buildertek__Material_Presently_Stored__c, buildertek__Work_Completed__c, buildertek__Status__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c,buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name from buildertek__SOV_Continuation_Sheet_Lines__c where Id =:sheetlineIds[0]];
        
        system.debug('APConnLine----->'+APConnLine);
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlineslist1 = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        List<buildertek__SOV_Continuation_Sheet_Lines__c> ARPaymentappLine = [select Id, Name,buildertek__Rejection_Reason__c, buildertek__Vendor_Sheet_line_Id__c,buildertek__Vendor_Work_Completed_This_Period__c, buildertek__Work_Completed__c,buildertek__Material_Presently_Stored__c, buildertek__Status__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__Vendor_Sheet_line_Id__c =:sheetlineIds[0] AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name = 'AR'];
        system.debug('ARPaymentappLine--->'+ARPaymentappLine);
        for (buildertek__SOV_Continuation_Sheet_Lines__c lineId : ARPaymentappLine){
            buildertek__SOV_Continuation_Sheet_Lines__c sheetlinerec1 = new buildertek__SOV_Continuation_Sheet_Lines__c();
            sheetlinerec1.Id = lineId.Id;
            sheetlinerec1.buildertek__Rejection_Reason__c = '';
            sheetlinerec1.buildertek__Status__c = 'Pending';
            sheetlinerec1.buildertek__Work_Completed__c = APConnLine.buildertek__Work_Completed__c;
            sheetlinerec1.buildertek__Material_Presently_Stored__c = APConnLine.buildertek__Material_Presently_Stored__c;
            sheetlineslist1.add(sheetlinerec1);
        }
        system.debug('sheetlineslist1'+sheetlineslist1);
        
        if(!sheetlineslist1.isEmpty()){
            update sheetlineslist1;
        }
        system.debug('sheetlineslist2'+sheetlineslist1);
        
        try{
            update sheetlineslist;
            
            
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetLinesList = [select Id, Name, buildertek__Status__c,
                                                                                   buildertek__SOV_Continuation_Sheet__c,
                                                                                   buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                                   from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                   where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: recordId
                                                                                  ];
            
            
            boolean AllApproved = true;
            for(buildertek__SOV_Continuation_Sheet_Lines__c conl : ConSheetLinesList){
                if(conl.buildertek__Status__c != 'Accepted'){
                    AllApproved = false;
                }
            }
            
            buildertek__SOV_Payment_Application__c PayApp = [select Id, Name, buildertek__Status__c,RecordType.Name from buildertek__SOV_Payment_Application__c where Id =: recordId];
            
            if(PayApp.RecordType.Name == 'AP'){
                if(AllApproved == true){
                    PayApp.buildertek__Status__c = 'Company Accepted';
                    update PayApp;
                } 
            }
            
            
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static string rejectsheetline(List<String> sheetlineIds, string rejectreason){
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        
        
        
        system.debug('sheetlineIds--->'+sheetlineIds);
        system.debug('rejectreason'+rejectreason);
        list<id> sheetid= new list<id>();
        list<id> paymentids= new list<id>();
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlineslist = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        for (string lineId : sheetlineIds){
            buildertek__SOV_Continuation_Sheet_Lines__c sheetlinerec = new buildertek__SOV_Continuation_Sheet_Lines__c();
            sheetlinerec.Id = lineId;
            sheetlinerec.buildertek__Status__c = 'Rejected';
            sheetlinerec.buildertek__Rejection_Reason__c = rejectreason;
            system.debug('Yo'+sheetlinerec.buildertek__Rejection_Reason__c);
            sheetlineslist.add(sheetlinerec);
        }
        
        String ConLineId = String.ValueOf(sheetlineIds[0]);
        
        
        buildertek__SOV_Continuation_Sheet_Lines__c ConSheetLinesList = [select Id, buildertek__Status__c,
                                                                         buildertek__Rejection_Reason__c ,
                                                                         buildertek__SOV_Continuation_Sheet__c,
                                                                         buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name,
                                                                         buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                         from buildertek__SOV_Continuation_Sheet_Lines__c where Id =:ConLineId  ];
        
        String PayId = ConSheetLinesList.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c;
        
        
        if(ConSheetLinesList.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name  == 'AP'){
            
            ConSheetLinesList.buildertek__Status__c = 'Rejected';
            ConSheetLinesList.buildertek__Rejection_Reason__c = rejectreason;
            update ConSheetLinesList;
            
            
            
            buildertek__SOV_Payment_Application__c paymentlist = [select id,Name,buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id =:  PayId];
            
            paymentlist.buildertek__Status__c = 'Company Rejected';
            
            update paymentlist;
            
            
        }else{
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorsovlist1 = [select Id,buildertek__Vendor_Sheet_line_Id__c,buildertek__Payment_Application_Id__c, buildertek__Status__c, buildertek__Rejection_Reason__c  from buildertek__SOV_Continuation_Sheet_Lines__c where Id =:ConLineId  ];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            buildertek__SOV_Continuation_Sheet_Lines__c conSheetId = [select Id, name, buildertek__Vendor_Sheet_line_Id__c from buildertek__SOV_Continuation_Sheet_Lines__c where Id =: ConLineId];
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_Sheet_line_Id__c,buildertek__Payment_Application_Id__c, buildertek__Status__c, buildertek__Rejection_Reason__c  from buildertek__SOV_Continuation_Sheet_Lines__c where Id =:conSheetId.buildertek__Vendor_Sheet_line_Id__c ];
            
            set<Id> vendorsovlineids = new set<Id>();
            
            if(!vendorsovlist1.isEmpty()){
                list<buildertek__SOV_Continuation_Sheet_Lines__c> newVendorUpdateList = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                for(buildertek__SOV_Continuation_Sheet_Lines__c sov1 :vendorsovlist1){
                    buildertek__SOV_Continuation_Sheet_Lines__c newVendor = new buildertek__SOV_Continuation_Sheet_Lines__c();
                    
                    newVendor.buildertek__Status__c = 'Rejected';  
                    
                    newVendor.buildertek__Rejection_Reason__c = rejectreason;
                    if(sov1.buildertek__Vendor_Sheet_line_Id__c != null  & !vendorsovlineids.contains(sov1.buildertek__Vendor_Sheet_line_Id__c)){
                        vendorsovlineids.add(sov1.buildertek__Vendor_Sheet_line_Id__c);
                        newVendor.Id = sov1.buildertek__Vendor_Sheet_line_Id__c;
                        newVendorUpdateList.add(newVendor);
                    }                    
                }
                system.debug('newVendorUpdateList---->'+newVendorUpdateList);
                if(!newVendorUpdateList.isEmpty()){
                    update newVendorUpdateList;
                }
            }
            
            update sheetlineslist;
            system.debug('IOO'+sheetlineslist);
            list<buildertek__SOV_Continuation_Sheet_Lines__c> linelist = [select id,Name,buildertek__SOV_Continuation_Sheet__c from buildertek__SOV_Continuation_Sheet_Lines__c where Id IN: sheetlineslist];
            for(buildertek__SOV_Continuation_Sheet_Lines__c lineRec : linelist){
                system.debug('lineRec.buildertek__SOV_Continuation_Sheet__c'+lineRec.buildertek__SOV_Continuation_Sheet__c);
                if(lineRec.buildertek__SOV_Continuation_Sheet__c  != null){
                    sheetid.add(lineRec.buildertek__SOV_Continuation_Sheet__c);
                }
            }
            list<buildertek__SOV_Continuation__c> continuesheetlist = [select id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id IN: sheetid];
            for(buildertek__SOV_Continuation__c conRec: continuesheetlist){
                if(conRec.buildertek__SOV_Payment_Application__c != null){
                    paymentids.add(conRec.buildertek__SOV_Payment_Application__c);
                }
            }
            list<buildertek__SOV_Payment_Application__c> newpaymentlist = new list<buildertek__SOV_Payment_Application__c>();
            list<buildertek__SOV_Payment_Application__c> paymentlist = [select id,Name,buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id IN: paymentids];
            
            for(buildertek__SOV_Payment_Application__c paymentRec : paymentlist){
                buildertek__SOV_Payment_Application__c newpaymentRec = new buildertek__SOV_Payment_Application__c();
                
                newpaymentRec.Id = paymentRec.Id;
                newpaymentlist.add(newpaymentRec);
            }
            if(newpaymentlist.size() > 0){
                update newpaymentlist;
            }  
        }
        
        
        return 'success';
        
    }
    
    @AuraEnabled
    public static String insertSheetLine(String sheetLineToInsert, string recordId){
        
        
        
        buildertek__SOV_Payment_Application__c paymentAppl = [ SELECT Id,
                                                              buildertek__Status__c,
                                                              Name, RecordTypeId, recordtype.name,
                                                              buildertek__Total_Material_Stored_To_Date__c
                                                              FROM buildertek__SOV_Payment_Application__c where Id =: recordId];
        
        system.debug('sheetLineToInsert-------->'+sheetLineToInsert);
        buildertek__SOV_Continuation_Sheet_Lines__c sheetItemToInsert = (buildertek__SOV_Continuation_Sheet_Lines__c)JSON.deserialize(sheetLineToInsert, buildertek__SOV_Continuation_Sheet_Lines__c.class);
        system.debug('sheetItemToInsert--------->'+sheetItemToInsert);
        
        String payAppId = recordId;
        
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c ,buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                     from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                     where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: payAppId ORDER BY buildertek__Item_No__c DESC];
        
        
        
        
        insert sheetItemToInsert; 
        
        // String payAppId = sheetItemToInsert.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c;
        
        
        
        system.debug('payAppId---->'+recordId);
        if(payAppId != null){
            
            
            system.debug('sheetItemToInsert----->'+sheetItemToInsert);
            system.debug('lastSOV-------->'+lastSOV);
            integer itemInc = 100;
            
            if(lastSOV.size() > 0){
                
                if(lastSOV[0].buildertek__Item_No__c != null){
                    itemInc = Integer.valueOf(lastSOV[0].buildertek__Item_No__c)+1;
                }
            }
        
                    
                    if(paymentAppl.recordtype.name == 'AP'){
                        sheetItemToInsert.buildertek__Status__c = 'Pending'; 
                    }else{
                        sheetItemToInsert.buildertek__Status__c = 'Pending'; 
                    }
                    
                    sheetItemToInsert.buildertek__Item_No__c = itemInc;
                
                Update sheetItemToInsert;
                
            
            
        }
        
        
        system.debug('Inserted Submittal ------> '+sheetItemToInsert);
        return sheetItemToInsert.Id;
    }
    
    @AuraEnabled
    public static List<ApprovedCOClass> getApprovedCOs(String projectId, String commRecId, String sfRecId){
        
        
        
        String portalCode = '';
        String vendorId = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
            if(userRec[0].get('buildertek__Account_Id__c') != null){
                vendorId = userRec[0].get('buildertek__Account_Id__c').toString();
            }
            
        }
        buildertek__SOV_Payment_Application__c PApp = new buildertek__SOV_Payment_Application__c (); 
        
        if(portalCode == 'true'){
            PApp = [select id, Name, buildertek__Owner_Account__c from buildertek__SOV_Payment_Application__c where Id =:commRecId ];
        }else{
            PApp = [select id, Name, buildertek__Owner_Account__c from buildertek__SOV_Payment_Application__c where Id =:sfRecId ];  
        }
        
        system.debug('projectId----->'+projectId);
        List<ApprovedCOClass> approvedCOList = new List<ApprovedCOClass>();
        List<buildertek__Change_Order__c> changeOrdersList;
        
        
        if(portalCode == 'true'){
            changeOrdersList = [SELECT Id,
                                Name,
                                buildertek__Project__c,
                                buildertek__Project__r.Name,
                                buildertek__Description__c,
                                buildertek__Is_CO_Imported__c,
                                FORMAT( convertCurrency( buildertek__Total_Amount_Tax__c))
                                FROM buildertek__Change_Order__c
                                WHERE buildertek__Status__c = 'Approved'
                                AND RecordType.Name = 'Vendor'
                                AND buildertek__Project__c =: projectId 
                                AND buildertek__Is_CO_Imported__c = false
                                AND buildertek__Vendor__c =: PApp.buildertek__Owner_Account__c
                                ORDER BY Name ASC];
        }else{
            changeOrdersList = [SELECT Id,
                                Name,
                                buildertek__Project__c,
                                buildertek__Project__r.Name,
                                buildertek__Description__c,
                                buildertek__Is_CO_Imported__c,
                                FORMAT( convertCurrency( buildertek__Total_Amount_Tax__c))
                                FROM buildertek__Change_Order__c
                                WHERE (buildertek__Status__c = 'Approved' OR buildertek__Status__c = 'Customer Approved')
                                AND buildertek__Project__c =: projectId
                                AND buildertek__Is_CO_Imported__c = false
                                ORDER BY Name ASC]; 
        }
        
        
        // AND buildertek__Is_CO_Imported__c = false
        
        system.debug(changeOrdersList);
        for(buildertek__Change_Order__c CO : changeOrdersList){
            ApprovedCOClass approvedCO = new ApprovedCOClass(); 
            approvedCO.coRecord = CO;
            approvedCO.coCheck = false;
            approvedCOList.add(approvedCO);
        }
        system.debug(approvedCOList);
        return approvedCOList;
        
    }
    
    @AuraEnabled
    public static List<buildertek__SOV_Payment_Application__c> getVendorSubmittedPaymentApps(String projectId,string recordId){
        
        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id,
                                                             Name,
                                                             buildertek__Application__c
                                                             FROM buildertek__SOV_Payment_Application__c
                                                             WHERE Id=:recordId];
        
        List<buildertek__SOV_Payment_Application__c> paymentList = [SELECT Id,
                                                                    buildertek__Status__c,
                                                                    Name,
                                                                    buildertek__Application__c,
                                                                    buildertek__Project__c,
                                                                    buildertek__Project__r.Name,
                                                                    buildertek__Original_Contract_Sum__c,
                                                                    buildertek__Net_Change_by_Change_Orders__c,
                                                                    buildertek__Owner_Account__c,
                                                                    buildertek__Owner_Account__r.Name,
                                                                    buildertek__PA_Type__c,
                                                                    RecordTypeId, recordtype.name,
                                                                    buildertek__Total_Material_Stored_To_Date__c
                                                                    FROM buildertek__SOV_Payment_Application__c
                                                                    Where buildertek__Project__c =:projectId 
                                                                    AND buildertek__Status__c ='Company Accepted'
                                                                    AND recordtype.name = 'AP'
                                                                    AND buildertek__Application__c =:paymentApp.buildertek__Application__c
                                                                    AND buildertek__Is_Imported__c = false]; 
        
        return paymentList;
    }
    @AuraEnabled
    public static void importContinuationLines(List<String> PAIds,  String recordId){ 
        
        
        buildertek__SOV_Payment_Application__c NewPa = [select Id, Name, buildertek__Is_Pay_App_Created_For__c from buildertek__SOV_Payment_Application__c where Id =: recordId];
        
        system.debug('NewPa----------->'+NewPa.buildertek__Is_Pay_App_Created_For__c);
        
        if(NewPa.buildertek__Is_Pay_App_Created_For__c == 'NEWPAYAPP'){
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
            
            
            // to check is community true
            String portalCode = '';
            string userName = userInfo.getUserId();
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            
            
            List<buildertek__SOV_Payment_Application__c> payList = [select id,Name,buildertek__Original_Contract_Sum__c,buildertek__Net_Change_by_Change_Orders__c,buildertek__Total_Completed__c,buildertek__Total_Material_Stored_To_Date__c from buildertek__SOV_Payment_Application__c where Id IN:PAIds];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> existSheetLines = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =:recordId];
            
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorConList = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN:PAIds];
            
            
            List<String> ExistSheetSovIds = new List<String>();
            set<String> vendorAddedCsLineIds = new set<String>();
            
            set<String> newClonedIdsList = new set<String>();
            
            if(!existSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c csline : existSheetLines){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+csline.buildertek__Vendor_SOV_Line_Id__c);
                    if(csline.buildertek__Vendor_SOV_Line_Id__c != null && csline.buildertek__Vendor_SOV_Line_Id__c != '' ){
                        ExistSheetSovIds.add(csline.buildertek__Vendor_SOV_Line_Id__c);   
                    }
                }
            }
            
            system.debug('ExistSheetSovIds-------->'+ExistSheetSovIds);
            
            if(!VendorConList.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vcsline : VendorConList){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+Vcsline.buildertek__Vendor_SOV_Line_Id__c);
                    if(Vcsline.buildertek__Vendor_SOV_Line_Id__c == null || Vcsline.buildertek__Vendor_SOV_Line_Id__c == '' ){
                        vendorAddedCsLineIds.add(Vcsline.Id);  
                    }
                }
            }
            
            
            system.debug('vendorAddedCsLineIds-------->'+vendorAddedCsLineIds);
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorAddedSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            
            if(!vendorAddedCsLineIds.isEmpty()){
                vendorAddedSheetLineList = [SELECT ID,
                                            buildertek__G_C__c,
                                            buildertek__Balance_To_Finish__c,
                                            buildertek__Budget_Grouping__c,
                                            Name,buildertek__Item_No__c,
                                            buildertek__Description_of_Work__c,
                                            buildertek__Material_Presently_Stored__c,
                                            buildertek__Rejection_Reason__c,
                                            buildertek__Retainage__c,
                                            buildertek__Scheduled_Value__c,
                                            buildertek__Status__c,
                                            buildertek__Work_Completed_from_Previous_Application__c,
                                            buildertek__Work_Completed__c,
                                            buildertek__Vendor_Sheet_line_Id__c,
                                            buildertek__Vendor_SOV_Line_Id__c,
                                            buildertek__Change_Order__c
                                            FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN:vendorAddedCsLineIds];
            }
            
            system.debug('vendorAddedSheetLineList--------->'+vendorAddedSheetLineList);
            
            
            Decimal originalcontract = 0;
            Decimal totalCompleted = 0;
            Decimal Totalmaterialstored = 0;
            for(buildertek__SOV_Payment_Application__c pay:payList){
                if(pay.buildertek__Original_Contract_Sum__c != null){
                    originalcontract += pay.buildertek__Original_Contract_Sum__c - pay.buildertek__Net_Change_by_Change_Orders__c; 
                    system.debug('originalcontract.....'+originalcontract);
                }
                if(pay.buildertek__Total_Completed__c != null){
                    totalCompleted += pay.buildertek__Total_Completed__c;  
                }
                if(pay.buildertek__Total_Material_Stored_To_Date__c != null){
                    Totalmaterialstored += pay.buildertek__Total_Material_Stored_To_Date__c;  
                }
                
            }
            
            buildertek__SOV_Payment_Application__c paymentRec = [select id,Name,buildertek__PA_Type__c,RecordTypeId, recordtype.name,buildertek__Imported_Payment_IDs__c,buildertek__Old_PA_Ids__c,buildertek__Original_Contract_Sum__c,
                                                                 buildertek__Total_Completed__c,buildertek__Net_Change_by_Change_Orders__c,
                                                                 buildertek__Total_Material_Stored_To_Date__c
                                                                 from buildertek__SOV_Payment_Application__c where Id =: recordId];
            
            
            buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
            payRec.buildertek__Imported_Payment_IDs__c= paymentRec.buildertek__Imported_Payment_IDs__c;
            if(paymentRec.buildertek__Original_Contract_Sum__c != null){
            payRec.buildertek__Original_Contract_Sum__c = paymentRec.buildertek__Original_Contract_Sum__c -paymentRec.buildertek__Net_Change_by_Change_Orders__c ;
            }
            payRec.buildertek__Total_Completed__c = paymentRec.buildertek__Total_Completed__c;
            payRec.buildertek__Total_Material_Stored_To_Date__c = paymentRec.buildertek__Total_Material_Stored_To_Date__c;
            payRec.id = recordId;
            Integer i = 1;
            string ImportedPaymentIds = '';
            
            system.debug('PAIds-->'+PAIds.size());
            for(string paId : PAIds){
                
                //payRec.buildertek__Imported_Payment_IDs__c =  payRec.buildertek__Imported_Payment_IDs__c+','+paId;
                ImportedPaymentIds += paId+',';
                if(PAIds.size() == 1){
                    payRec.buildertek__Old_PA_Ids__c = paId;
                }else if(i==1){
                    payRec.buildertek__Old_PA_Ids__c = paId+'_';
                    i++;
                }else if(PAIds.size() == i && i > 1){
                    payRec.buildertek__Old_PA_Ids__c += paId;
                }else{
                    payRec.buildertek__Old_PA_Ids__c += paId+'_';
                    i++;
                }
                
            }
            system.debug('@@@@@@@@@@@@'+ImportedPaymentIds);
            system.debug('*****************'+payRec.buildertek__Imported_Payment_IDs__c);
            if(payRec.buildertek__Imported_Payment_IDs__c != null){
                system.debug('not null');
                payRec.buildertek__Imported_Payment_IDs__c += ImportedPaymentIds;
            }else{
                system.debug('--- null');
                payRec.buildertek__Imported_Payment_IDs__c = ImportedPaymentIds;
                
            }
            
            if(payRec.buildertek__Original_Contract_Sum__c != null){
                payRec.buildertek__Original_Contract_Sum__c += originalcontract;  
            }
            else{
                payRec.buildertek__Original_Contract_Sum__c = originalcontract; 
            }
            
            if(payRec.buildertek__Total_Completed__c != null){
                payRec.buildertek__Total_Completed__c += totalCompleted;  
            }
            else{
                payRec.buildertek__Total_Completed__c = totalCompleted; 
            }
            
            if(payRec.buildertek__Total_Material_Stored_To_Date__c != null){
                payRec.buildertek__Total_Material_Stored_To_Date__c += Totalmaterialstored;
            }
            else{
                payRec.buildertek__Total_Material_Stored_To_Date__c = Totalmaterialstored;
            }
            
            Update payRec;
            
            Set<string> ContSheetLineIds = new Set<string>();
            buildertek__SOV_Continuation__c ContSheetRec   = [SELECT Id,
                                                              buildertek__SOV_Payment_Application__c
                                                              FROM buildertek__SOV_Continuation__c
                                                              WHERE buildertek__SOV_Payment_Application__c=:recordId limit 1];
            
            List<buildertek__SOV_Continuation__c> ContSheetRecList   = [SELECT Id,
                                                                        buildertek__SOV_Payment_Application__c
                                                                        FROM buildertek__SOV_Continuation__c
                                                                        WHERE buildertek__SOV_Payment_Application__c IN:PAIds];
            
            system.debug('&&&&&&'+ContSheetRecList);
            if(!ContSheetRecList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : ContSheetRecList){
                    ContSheetLineIds.add(con.Id);
                }
            } 
            system.debug('&&&&&&'+ContSheetLineIds);
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ClonesheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>(); 
            if(!ContSheetLineIds.isEmpty()){
                
                sheetlinesList = [SELECT ID,
                                  buildertek__G_C__c,
                                  buildertek__Balance_To_Finish__c,
                                  buildertek__Balance_to_Pay__c,
                                  buildertek__Budget_Grouping__c,
                                  Name,
                                  buildertek__Cost_Code__c,
                                  buildertek__Description_of_Work__c,
                                  buildertek__Grouping__c,
                                  buildertek__Grouping2__c,
                                  buildertek__Sheet_Item_No__c,
                                  buildertek__Item_No__c,
                                  buildertek__less10_hold_back__c,
                                  buildertek__Material_Presently_Stored__c,
                                  buildertek__percent1__c,
                                  buildertek__percent2__c,
                                  buildertek__percent3__c,
                                  buildertek__Rejection_Reason__c,
                                  buildertek__Retainage__c,
                                  buildertek__Scheduled_Value__c,
                                  buildertek__Status__c,
                                  buildertek__Total__c,
                                  buildertek__Vendor__c,
                                  buildertek__Work_Completed_from_Previous_Application__c,
                                  buildertek__Work_Completed__c,
                                  buildertek__Vendor_Sheet_line_Id__c,
                                  buildertek__Vendor_SOV_Line_Id__c,
                                  buildertek__Change_Order__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c IN:ContSheetLineIds]; 
            } 
            system.debug('&&&&&&'+sheetlinesList);
            
            if(!ExistSheetSovIds.isEmpty()){
                map<String, String> SOVSheetLineMap = new map<String, String>();
                map<String, buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetRecMap = new map<String, buildertek__SOV_Continuation_Sheet_Lines__c>();
                
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : existSheetLines){
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        SOVSheetLineMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin.Id);
                    }
                    
                }
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    system.debug('extSLin.Id------>'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    ConSheetRecMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin);
                }
                
                List<buildertek__SOV_Continuation_Sheet_Lines__c> NewConSheetImpList =  new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    buildertek__SOV_Continuation_Sheet_Lines__c newSheetLine =  new buildertek__SOV_Continuation_Sheet_Lines__c();
                    system.debug('existes----->'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    newClonedIdsList.add(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        system.debug('existessov lines----->'+SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                        if(SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c) != null){
                            newSheetLine.Id = SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                            if(extSLin.buildertek__Change_Order__c != null){
                                newSheetLine.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            newSheetLine.buildertek__Item_No__c=itemInc;
                            newSheetLine.buildertek__Description_of_Work__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Description_of_Work__c;
                            newSheetLine.buildertek__Status__c = 'Pending';
                            newSheetLine.buildertek__Work_Completed__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Work_Completed__c;
                            newSheetLine.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            system.debug('1133newSheetLine-->'+newSheetLine);
                            itemInc++;
                            newClonedIdsList.add(extSLin.Id);
                            NewConSheetImpList.add(newSheetLine);
                        }  else{
                            buildertek__SOV_Continuation_Sheet_Lines__c cloneline = extSLin.clone(false,true,true,false);
                            cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                            cloneline.buildertek__Budget_Grouping__c = extSLin.buildertek__Budget_Grouping__c;
                            cloneline.buildertek__Is_Imported__c = true;
                            cloneline.buildertek__Status__c = 'Pending';
                            cloneline.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            cloneline.buildertek__Item_No__c=itemInc;
                            if(extSLin.buildertek__Change_Order__c != null){
                                cloneline.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            itemInc++;
                            system.debug(newClonedIdsList.contains(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                            //if(!newClonedIdsList.contains(extSLin.buildertek__Vendor_SOV_Line_Id__c)){
                            ClonesheetlinesList.add(cloneline);
                            // }
                            system.debug('line.Id-------87-->'+extSLin.Id);
                            newClonedIdsList.add(extSLin.Id);
                            
                        }
                    }
                    
                }
                
                if(!NewConSheetImpList.isEmpty()){
                    update NewConSheetImpList;
                }
                
            }else{
                if(!sheetlinesList.isEmpty()){
                    system.debug('callinnnggggggg------->');
                    for(buildertek__SOV_Continuation_Sheet_Lines__c line:sheetlinesList){
                        buildertek__SOV_Continuation_Sheet_Lines__c cloneline = line.clone(false,true,true,false);
                        cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                        cloneline.buildertek__Budget_Grouping__c = line.buildertek__Budget_Grouping__c;
                        cloneline.buildertek__Is_Imported__c = true;
                        cloneline.buildertek__Status__c = 'Pending';
                        cloneline.buildertek__Vendor_Sheet_line_Id__c = line.Id;
                        cloneline.buildertek__Item_No__c=itemInc;
                        if(line.buildertek__Change_Order__c != null){
                            cloneline.buildertek__Change_Order__c = line.buildertek__Change_Order__c;
                        }
                        itemInc++;
                        ClonesheetlinesList.add(cloneline);
                        system.debug('line.Id-------87-->'+line.Id);
                        newClonedIdsList.add(line.Id);
                    }
                }  
            }
            
            if(!vendorAddedSheetLineList.isEmpty()){
                system.debug('callinnnggggggg Vendor added');
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vline:vendorAddedSheetLineList){
                    buildertek__SOV_Continuation_Sheet_Lines__c cloneline = Vline.clone(false,true,true,false);
                    cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                    cloneline.buildertek__Budget_Grouping__c = Vline.buildertek__Budget_Grouping__c;
                    cloneline.buildertek__Is_Imported__c = true;
                    cloneline.buildertek__Description_of_Work__c = Vline.buildertek__Description_of_Work__c;
                    cloneline.buildertek__Status__c = 'Pending';
                    cloneline.buildertek__Vendor_Sheet_line_Id__c = Vline.Id;
                    cloneline.buildertek__Item_No__c=itemInc;
                    if(Vline.buildertek__Change_Order__c != null){
                        cloneline.buildertek__Change_Order__c = Vline.buildertek__Change_Order__c;
                    }
                    itemInc++;
                    system.debug('Vline.Id--------->'+Vline.Id);
                    if(!newClonedIdsList.contains(Vline.Id)){
                        ClonesheetlinesList.add(cloneline);
                    }
                }
            }
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> DeleteSheetLines = [SELECT Id,Name
                                                                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                  WHERE buildertek__SOV_Continuation_Sheet__c =:ContSheetRec.Id AND buildertek__Is_Imported__c = false];
            if(!DeleteSheetLines.isEmpty()){
                //  delete DeleteSheetLines;
            }
            
            if(!ClonesheetlinesList.isEmpty()){
                insert ClonesheetlinesList; 
            } 
            List<buildertek__SOV_Payment_Application__c> payappList = new List<buildertek__SOV_Payment_Application__c>();
            
            List<buildertek__SOV_Payment_Application__c> paymentApps = [SELECT Id,
                                                                        buildertek__Is_Imported__c
                                                                        FROM buildertek__SOV_Payment_Application__c
                                                                        WHERE Id IN:PAIds];
            for(buildertek__SOV_Payment_Application__c pay:paymentApps){
                pay.buildertek__Is_Imported__c = true; 
                
            }
            update paymentApps;
            
        }
        else if(NewPa.buildertek__Is_Pay_App_Created_For__c == 'FORVENDORPAYAPPS'){
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
            
            
            // to check is community true
            String portalCode = '';
            string userName = userInfo.getUserId();
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            
            
            List<buildertek__SOV_Payment_Application__c> payList = [select id,Name,buildertek__Original_Contract_Sum__c,buildertek__Net_Change_by_Change_Orders__c,buildertek__Total_Completed__c,buildertek__Total_Material_Stored_To_Date__c from buildertek__SOV_Payment_Application__c where Id IN:PAIds];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> existSheetLines = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =:recordId];
            
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorConList = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN:PAIds];
            
            
            List<String> ExistSheetSovIds = new List<String>();
            set<String> vendorAddedCsLineIds = new set<String>();
            
            set<String> newClonedIdsList = new set<String>();
            
            if(!existSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c csline : existSheetLines){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+csline.buildertek__Vendor_SOV_Line_Id__c);
                    if(csline.buildertek__Vendor_SOV_Line_Id__c != null && csline.buildertek__Vendor_SOV_Line_Id__c != '' ){
                        ExistSheetSovIds.add(csline.buildertek__Vendor_SOV_Line_Id__c);   
                    }
                }
            }
            
            system.debug('ExistSheetSovIds-------->'+ExistSheetSovIds);
            
            if(!VendorConList.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vcsline : VendorConList){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+Vcsline.buildertek__Vendor_SOV_Line_Id__c);
                    if(Vcsline.buildertek__Vendor_SOV_Line_Id__c == null || Vcsline.buildertek__Vendor_SOV_Line_Id__c == '' ){
                        vendorAddedCsLineIds.add(Vcsline.Id);  
                    }
                }
            }
            
            
            system.debug('vendorAddedCsLineIds-------->'+vendorAddedCsLineIds);
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorAddedSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            
            if(!vendorAddedCsLineIds.isEmpty()){
                vendorAddedSheetLineList = [SELECT ID,
                                            buildertek__G_C__c,
                                            buildertek__Balance_To_Finish__c,
                                            buildertek__Budget_Grouping__c,
                                            Name,buildertek__Item_No__c,
                                            buildertek__Description_of_Work__c,
                                            buildertek__Material_Presently_Stored__c,
                                            buildertek__Rejection_Reason__c,
                                            buildertek__Retainage__c,
                                            buildertek__Scheduled_Value__c,
                                            buildertek__Status__c,
                                            buildertek__Work_Completed_from_Previous_Application__c,
                                            buildertek__Work_Completed__c,
                                            buildertek__Vendor_Sheet_line_Id__c,
                                            buildertek__Vendor_SOV_Line_Id__c,
                                            buildertek__Change_Order__c
                                            FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN:vendorAddedCsLineIds];
            }
            
            system.debug('vendorAddedSheetLineList--------->'+vendorAddedSheetLineList);
            
            
            Decimal originalcontract = 0;
            Decimal totalCompleted = 0;
            Decimal Totalmaterialstored = 0;
            for(buildertek__SOV_Payment_Application__c pay:payList){
                if(pay.buildertek__Original_Contract_Sum__c != null){
                    originalcontract += pay.buildertek__Original_Contract_Sum__c-pay.buildertek__Net_Change_by_Change_Orders__c;
                    system.debug('originalcontract.....'+originalcontract);
                }
                if(pay.buildertek__Total_Completed__c != null){
                    totalCompleted += pay.buildertek__Total_Completed__c;  
                }
                if(pay.buildertek__Total_Material_Stored_To_Date__c != null){
                    Totalmaterialstored += pay.buildertek__Total_Material_Stored_To_Date__c;  
                }
                
            }
            
            buildertek__SOV_Payment_Application__c paymentRec = [select id,Name,buildertek__PA_Type__c,RecordTypeId, recordtype.name,buildertek__Imported_Payment_IDs__c,buildertek__Old_PA_Ids__c,buildertek__Original_Contract_Sum__c,buildertek__Net_Change_by_Change_Orders__c,
                                                                 buildertek__Total_Completed__c,
                                                                 buildertek__Total_Material_Stored_To_Date__c
                                                                 from buildertek__SOV_Payment_Application__c where Id =: recordId];
            
            
            buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
            payRec.buildertek__Imported_Payment_IDs__c= paymentRec.buildertek__Imported_Payment_IDs__c;
            if(paymentRec.buildertek__Original_Contract_Sum__c != null){
                payRec.buildertek__Original_Contract_Sum__c = paymentRec.buildertek__Original_Contract_Sum__c-paymentRec.buildertek__Net_Change_by_Change_Orders__c;
            }
            payRec.buildertek__Total_Completed__c = paymentRec.buildertek__Total_Completed__c;
            payRec.buildertek__Total_Material_Stored_To_Date__c = paymentRec.buildertek__Total_Material_Stored_To_Date__c;
            payRec.id = recordId;
            Integer i = 1;
            string ImportedPaymentIds = '';
            
            system.debug('PAIds-->'+PAIds.size());
            for(string paId : PAIds){
                
                //payRec.buildertek__Imported_Payment_IDs__c =  payRec.buildertek__Imported_Payment_IDs__c+','+paId;
                ImportedPaymentIds += paId+',';
                if(PAIds.size() == 1){
                    payRec.buildertek__Old_PA_Ids__c = paId;
                }else if(i==1){
                    payRec.buildertek__Old_PA_Ids__c = paId+'_';
                    i++;
                }else if(PAIds.size() == i && i > 1){
                    payRec.buildertek__Old_PA_Ids__c += paId;
                }else{
                    payRec.buildertek__Old_PA_Ids__c += paId+'_';
                    i++;
                }
                
            }
            system.debug('@@@@@@@@@@@@'+ImportedPaymentIds);
            system.debug('*****************'+payRec.buildertek__Imported_Payment_IDs__c);
            if(payRec.buildertek__Imported_Payment_IDs__c != null){
                system.debug('not null');
                payRec.buildertek__Imported_Payment_IDs__c += ImportedPaymentIds;
            }else{
                system.debug('--- null');
                payRec.buildertek__Imported_Payment_IDs__c = ImportedPaymentIds;
                
            }
            
            if(payRec.buildertek__Original_Contract_Sum__c != null){
                payRec.buildertek__Original_Contract_Sum__c += originalcontract;  
            }
            else{
                payRec.buildertek__Original_Contract_Sum__c = originalcontract; 
            }
            
            if(payRec.buildertek__Total_Completed__c != null){
                payRec.buildertek__Total_Completed__c += totalCompleted;  
            }
            else{
                payRec.buildertek__Total_Completed__c = totalCompleted; 
            }
            
            if(payRec.buildertek__Total_Material_Stored_To_Date__c != null){
                payRec.buildertek__Total_Material_Stored_To_Date__c += Totalmaterialstored;
            }
            else{
                payRec.buildertek__Total_Material_Stored_To_Date__c = Totalmaterialstored;
            }
            
            Update payRec;
            
            Set<string> ContSheetLineIds = new Set<string>();
            buildertek__SOV_Continuation__c ContSheetRec   = [SELECT Id,
                                                              buildertek__SOV_Payment_Application__c
                                                              FROM buildertek__SOV_Continuation__c
                                                              WHERE buildertek__SOV_Payment_Application__c=:recordId limit 1];
            
            List<buildertek__SOV_Continuation__c> ContSheetRecList   = [SELECT Id,
                                                                        buildertek__SOV_Payment_Application__c
                                                                        FROM buildertek__SOV_Continuation__c
                                                                        WHERE buildertek__SOV_Payment_Application__c IN:PAIds];
            
            system.debug('&&&&&&'+ContSheetRecList);
            if(!ContSheetRecList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : ContSheetRecList){
                    ContSheetLineIds.add(con.Id);
                }
            } 
            system.debug('&&&&&&'+ContSheetLineIds);
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ClonesheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>(); 
            if(!ContSheetLineIds.isEmpty()){
                
                sheetlinesList = [SELECT ID,
                                  buildertek__G_C__c,
                                  buildertek__Balance_To_Finish__c,
                                  buildertek__Balance_to_Pay__c,
                                  buildertek__Budget_Grouping__c,
                                  Name,
                                  buildertek__Cost_Code__c,
                                  buildertek__Description_of_Work__c,
                                  buildertek__Grouping__c,
                                  buildertek__Grouping2__c,
                                  buildertek__Sheet_Item_No__c,
                                  buildertek__Item_No__c,
                                  buildertek__less10_hold_back__c,
                                  buildertek__Material_Presently_Stored__c,
                                  buildertek__percent1__c,
                                  buildertek__percent2__c,
                                  buildertek__percent3__c,
                                  buildertek__Rejection_Reason__c,
                                  buildertek__Retainage__c,
                                  buildertek__Scheduled_Value__c,
                                  buildertek__Status__c,
                                  buildertek__Total__c,
                                  buildertek__Vendor__c,
                                  buildertek__Work_Completed_from_Previous_Application__c,
                                  buildertek__Work_Completed__c,
                                  buildertek__Vendor_Sheet_line_Id__c,
                                  buildertek__Vendor_SOV_Line_Id__c,
                                  buildertek__Change_Order__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c IN:ContSheetLineIds]; 
            } 
            system.debug('&&&&&&'+sheetlinesList);
            
            if(!ExistSheetSovIds.isEmpty()){
                map<String, String> SOVSheetLineMap = new map<String, String>();
                map<String, buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetRecMap = new map<String, buildertek__SOV_Continuation_Sheet_Lines__c>();
                
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : existSheetLines){
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        SOVSheetLineMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin.Id);
                    }
                    
                }
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    system.debug('extSLin.Id------>'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    ConSheetRecMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin);
                }
                
                List<buildertek__SOV_Continuation_Sheet_Lines__c> NewConSheetImpList =  new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    buildertek__SOV_Continuation_Sheet_Lines__c newSheetLine =  new buildertek__SOV_Continuation_Sheet_Lines__c();
                    system.debug('existes----->'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    newClonedIdsList.add(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        system.debug('existessov lines----->'+SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                        if(SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c) != null){
                            newSheetLine.Id = SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                            if(extSLin.buildertek__Change_Order__c != null){
                                newSheetLine.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            newSheetLine.buildertek__Item_No__c=itemInc;
                            newSheetLine.buildertek__Description_of_Work__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Description_of_Work__c;
                            newSheetLine.buildertek__Status__c = 'Pending';
                            newSheetLine.buildertek__Work_Completed__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Work_Completed__c;
                            newSheetLine.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            system.debug('1133newSheetLine-->'+newSheetLine);
                            itemInc++;
                            newClonedIdsList.add(extSLin.Id);
                            NewConSheetImpList.add(newSheetLine);
                        }  else{
                            buildertek__SOV_Continuation_Sheet_Lines__c cloneline = extSLin.clone(false,true,true,false);
                            cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                            cloneline.buildertek__Budget_Grouping__c = extSLin.buildertek__Budget_Grouping__c;
                            cloneline.buildertek__Is_Imported__c = true;
                            cloneline.buildertek__Status__c = 'Pending';
                            cloneline.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            cloneline.buildertek__Item_No__c=itemInc;
                            if(extSLin.buildertek__Change_Order__c != null){
                                cloneline.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            itemInc++;
                            system.debug(newClonedIdsList.contains(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                            if(!newClonedIdsList.contains(extSLin.buildertek__Vendor_SOV_Line_Id__c)){
                                ClonesheetlinesList.add(cloneline);
                            }
                            system.debug('line.Id-------87-->'+extSLin.Id);
                            newClonedIdsList.add(extSLin.Id);
                            
                        }
                    }
                    
                }
                
                if(!NewConSheetImpList.isEmpty()){
                    update NewConSheetImpList;
                }
                
            }else{
                if(!sheetlinesList.isEmpty()){
                    system.debug('callinnnggggggg------->');
                    for(buildertek__SOV_Continuation_Sheet_Lines__c line:sheetlinesList){
                        buildertek__SOV_Continuation_Sheet_Lines__c cloneline = line.clone(false,true,true,false);
                        cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                        cloneline.buildertek__Budget_Grouping__c = line.buildertek__Budget_Grouping__c;
                        cloneline.buildertek__Is_Imported__c = true;
                        cloneline.buildertek__Status__c = 'Pending';
                        cloneline.buildertek__Vendor_Sheet_line_Id__c = line.Id;
                        cloneline.buildertek__Item_No__c=itemInc;
                        if(line.buildertek__Change_Order__c != null){
                            cloneline.buildertek__Change_Order__c = line.buildertek__Change_Order__c;
                        }
                        itemInc++;
                        ClonesheetlinesList.add(cloneline);
                        system.debug('line.Id-------87-->'+line.Id);
                        
                        newClonedIdsList.add(line.Id);
                    }
                }  
            }
            
            if(!vendorAddedSheetLineList.isEmpty()){
                system.debug('callinnnggggggg Vendor added');
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vline:vendorAddedSheetLineList){
                    buildertek__SOV_Continuation_Sheet_Lines__c cloneline = Vline.clone(false,true,true,false);
                    cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                    cloneline.buildertek__Budget_Grouping__c = Vline.buildertek__Budget_Grouping__c;
                    cloneline.buildertek__Is_Imported__c = true;
                    cloneline.buildertek__Description_of_Work__c = Vline.buildertek__Description_of_Work__c;
                    cloneline.buildertek__Status__c = 'Pending';
                    cloneline.buildertek__Vendor_Sheet_line_Id__c = Vline.Id;
                    cloneline.buildertek__Item_No__c=itemInc;
                    if(Vline.buildertek__Change_Order__c != null){
                        cloneline.buildertek__Change_Order__c = Vline.buildertek__Change_Order__c;
                    }
                    itemInc++;
                    system.debug('Vline.Id--------->'+Vline.Id);
                    if(!newClonedIdsList.contains(Vline.Id)){
                        ClonesheetlinesList.add(cloneline);
                    }
                }
            }
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> DeleteSheetLines = [SELECT Id,Name
                                                                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                  WHERE buildertek__SOV_Continuation_Sheet__c =:ContSheetRec.Id AND buildertek__Is_Imported__c = false];
            if(!DeleteSheetLines.isEmpty()){
                //  delete DeleteSheetLines;
            }
            
            if(!ClonesheetlinesList.isEmpty()){
                insert ClonesheetlinesList; 
            } 
            List<buildertek__SOV_Payment_Application__c> payappList = new List<buildertek__SOV_Payment_Application__c>();
            
            List<buildertek__SOV_Payment_Application__c> paymentApps = [SELECT Id,
                                                                        buildertek__Is_Imported__c
                                                                        FROM buildertek__SOV_Payment_Application__c
                                                                        WHERE Id IN:PAIds];
            for(buildertek__SOV_Payment_Application__c pay:paymentApps){
                pay.buildertek__Is_Imported__c = true; 
                
            }
            update paymentApps;
            
        }
        else if(NewPa.buildertek__Is_Pay_App_Created_For__c == 'FORCUSTOMERSOV'){
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
            
            
            // to check is community true
            String portalCode = '';
            string userName = userInfo.getUserId();
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            
            
            List<buildertek__SOV_Payment_Application__c> payList = [select id,Name,buildertek__Original_Contract_Sum__c,buildertek__Net_Change_by_Change_Orders__c,buildertek__Total_Completed__c,buildertek__Total_Material_Stored_To_Date__c from buildertek__SOV_Payment_Application__c where Id IN:PAIds];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> existSheetLines = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,buildertek__Item_No__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =:recordId ORDER BY buildertek__Item_No__c];
            
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorConList = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c, buildertek__Item_No__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN:PAIds ORDER BY buildertek__Item_No__c];
            
            
            List<String> ExistSheetSovIds = new List<String>();
            set<String> vendorAddedCsLineIds = new set<String>();
            
            set<String> newClonedIdsList = new set<String>();
            
            if(!existSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c csline : existSheetLines){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+csline.buildertek__Vendor_SOV_Line_Id__c);
                    if(csline.buildertek__Vendor_SOV_Line_Id__c != null && csline.buildertek__Vendor_SOV_Line_Id__c != '' ){
                        ExistSheetSovIds.add(csline.buildertek__Vendor_SOV_Line_Id__c);   
                    }
                }
            }
            
            system.debug('ExistSheetSovIds-------->'+ExistSheetSovIds);
            
            set<String> VendorLineIds = new set<String>();
            
            if(!VendorConList.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vcsline : VendorConList){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+Vcsline.buildertek__Vendor_SOV_Line_Id__c);
                    
                    vendorAddedCsLineIds.add(Vcsline.Id);  
                    /*  if(Vcsline.buildertek__Vendor_SOV_Line_Id__c == null || Vcsline.buildertek__Vendor_SOV_Line_Id__c == '' ){
} */
                }
            }
            
            
            
            system.debug('vendorAddedCsLineIds-------->'+vendorAddedCsLineIds);
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorAddedSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            
            if(!vendorAddedCsLineIds.isEmpty()){
                vendorAddedSheetLineList = [SELECT ID,
                                            buildertek__G_C__c,
                                            buildertek__Balance_To_Finish__c,
                                            buildertek__Budget_Grouping__c,
                                            Name,buildertek__Item_No__c,
                                            buildertek__Description_of_Work__c,
                                            buildertek__Material_Presently_Stored__c,
                                            buildertek__Rejection_Reason__c,
                                            buildertek__Retainage__c,
                                            buildertek__Scheduled_Value__c,
                                            buildertek__Status__c,
                                            buildertek__Work_Completed_from_Previous_Application__c,
                                            buildertek__Work_Completed__c,
                                            buildertek__Vendor_Sheet_line_Id__c,
                                            buildertek__Vendor_SOV_Line_Id__c,
                                            buildertek__Change_Order__c
                                            FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN:vendorAddedCsLineIds];
            }
            
            system.debug('vendorAddedSheetLineList--------->'+vendorAddedSheetLineList);
            
            
            Decimal originalcontract = 0;
            Decimal totalCompleted = 0;
            Decimal Totalmaterialstored = 0;
            for(buildertek__SOV_Payment_Application__c pay:payList){
                if(pay.buildertek__Original_Contract_Sum__c != null){
                    originalcontract += pay.buildertek__Original_Contract_Sum__c- pay.buildertek__Net_Change_by_Change_Orders__c; 
                    system.debug('originalcontract......'+originalcontract);
                }
                if(pay.buildertek__Total_Completed__c != null){
                    totalCompleted += pay.buildertek__Total_Completed__c;  
                }
                if(pay.buildertek__Total_Material_Stored_To_Date__c != null){
                    Totalmaterialstored += pay.buildertek__Total_Material_Stored_To_Date__c;  
                }
                
            }
            
            buildertek__SOV_Payment_Application__c paymentRec = [select id,Name,buildertek__PA_Type__c,RecordTypeId, recordtype.name,buildertek__Imported_Payment_IDs__c,buildertek__Old_PA_Ids__c,buildertek__Original_Contract_Sum__c,
                                                                 buildertek__Total_Completed__c,buildertek__Net_Change_by_Change_Orders__c,
                                                                 buildertek__Total_Material_Stored_To_Date__c
                                                                 from buildertek__SOV_Payment_Application__c where Id =: recordId];
            
            
            buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
            payRec.buildertek__Imported_Payment_IDs__c= paymentRec.buildertek__Imported_Payment_IDs__c;
            if(paymentRec.buildertek__Original_Contract_Sum__c != null){
            payRec.buildertek__Original_Contract_Sum__c = paymentRec.buildertek__Original_Contract_Sum__c-paymentRec.buildertek__Net_Change_by_Change_Orders__c;
            }
            payRec.buildertek__Total_Completed__c = paymentRec.buildertek__Total_Completed__c;
            payRec.buildertek__Total_Material_Stored_To_Date__c = paymentRec.buildertek__Total_Material_Stored_To_Date__c;
            payRec.id = recordId;
            Integer i = 1;
            string ImportedPaymentIds = '';
            
            system.debug('PAIds-->'+PAIds.size());
            for(string paId : PAIds){
                
                //payRec.buildertek__Imported_Payment_IDs__c =  payRec.buildertek__Imported_Payment_IDs__c+','+paId;
                ImportedPaymentIds += paId+',';
                if(PAIds.size() == 1){
                    payRec.buildertek__Old_PA_Ids__c = paId;
                }else if(i==1){
                    payRec.buildertek__Old_PA_Ids__c = paId+'_';
                    i++;
                }else if(PAIds.size() == i && i > 1){
                    payRec.buildertek__Old_PA_Ids__c += paId;
                }else{
                    payRec.buildertek__Old_PA_Ids__c += paId+'_';
                    i++;
                }
                
            }
            system.debug('@@@@@@@@@@@@'+ImportedPaymentIds);
            system.debug('*****************'+payRec.buildertek__Imported_Payment_IDs__c);
            if(payRec.buildertek__Imported_Payment_IDs__c != null){
                system.debug('not null');
                payRec.buildertek__Imported_Payment_IDs__c += ImportedPaymentIds;
            }else{
                system.debug('--- null');
                payRec.buildertek__Imported_Payment_IDs__c = ImportedPaymentIds;
                
            }
            
            if(payRec.buildertek__Original_Contract_Sum__c != null){
                payRec.buildertek__Original_Contract_Sum__c += originalcontract;  
            }
            else{
                payRec.buildertek__Original_Contract_Sum__c = originalcontract; 
            }
            
            if(payRec.buildertek__Total_Completed__c != null){
                payRec.buildertek__Total_Completed__c += totalCompleted;  
            }
            else{
                payRec.buildertek__Total_Completed__c = totalCompleted; 
            }
            
            if(payRec.buildertek__Total_Material_Stored_To_Date__c != null){
                payRec.buildertek__Total_Material_Stored_To_Date__c += Totalmaterialstored;
            }
            else{
                payRec.buildertek__Total_Material_Stored_To_Date__c = Totalmaterialstored;
            }
            
            Update payRec;
            
            Set<string> ContSheetLineIds = new Set<string>();
            buildertek__SOV_Continuation__c ContSheetRec   = [SELECT Id,
                                                              buildertek__SOV_Payment_Application__c
                                                              FROM buildertek__SOV_Continuation__c
                                                              WHERE buildertek__SOV_Payment_Application__c=:recordId limit 1];
            
            List<buildertek__SOV_Continuation__c> ContSheetRecList   = [SELECT Id,
                                                                        buildertek__SOV_Payment_Application__c
                                                                        FROM buildertek__SOV_Continuation__c
                                                                        WHERE buildertek__SOV_Payment_Application__c IN:PAIds];
            
            system.debug('&&&&&&'+ContSheetRecList);
            if(!ContSheetRecList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : ContSheetRecList){
                    ContSheetLineIds.add(con.Id);
                }
            } 
            system.debug('&&&&&&'+ContSheetLineIds);
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ClonesheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>(); 
            if(!ContSheetLineIds.isEmpty()){
                
                sheetlinesList = [SELECT ID,
                                  buildertek__G_C__c,
                                  buildertek__Balance_To_Finish__c,
                                  buildertek__Balance_to_Pay__c,
                                  buildertek__Budget_Grouping__c,
                                  Name,
                                  buildertek__Cost_Code__c,
                                  buildertek__Description_of_Work__c,
                                  buildertek__Grouping__c,
                                  buildertek__Grouping2__c,
                                  buildertek__Sheet_Item_No__c,
                                  buildertek__Item_No__c,
                                  buildertek__less10_hold_back__c,
                                  buildertek__Material_Presently_Stored__c,
                                  buildertek__Vendor_Material_Presently_Stored__c,  
                                  buildertek__percent1__c,
                                  buildertek__percent2__c,
                                  buildertek__percent3__c,
                                  buildertek__Rejection_Reason__c,
                                  buildertek__Retainage__c,
                                  buildertek__Scheduled_Value__c,
                                  buildertek__Status__c,
                                  buildertek__Total__c,
                                  buildertek__Vendor__c,
                                  buildertek__Work_Completed_from_Previous_Application__c,
                                  buildertek__Work_Completed__c,
                                  buildertek__Vendor_Sheet_line_Id__c,
                                  buildertek__Vendor_SOV_Line_Id__c,
                                  buildertek__Change_Order__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c IN:ContSheetLineIds]; 
            } 
            system.debug('&&&&&&'+sheetlinesList);
            
            system.debug('ExistSheetSovIds----45--->'+ExistSheetSovIds);
            if(!ExistSheetSovIds.isEmpty()){
                map<String, String> SOVSheetLineMap = new map<String, String>();
                map<String, buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetRecMap = new map<String, buildertek__SOV_Continuation_Sheet_Lines__c>();
                
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : existSheetLines){
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        SOVSheetLineMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin.Id);
                    }
                    
                }
                
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    system.debug('extSLin.Id------>'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    ConSheetRecMap.put(extSLin.buildertek__Vendor_SOV_Line_Id__c , extSLin);
                }
                system.debug('sheetlinesList--9----->'+sheetlinesList);
                List<buildertek__SOV_Continuation_Sheet_Lines__c> NewConSheetImpList =  new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                for(buildertek__SOV_Continuation_Sheet_Lines__c extSLin : sheetlinesList){
                    buildertek__SOV_Continuation_Sheet_Lines__c newSheetLine =  new buildertek__SOV_Continuation_Sheet_Lines__c();
                    system.debug('existes----->'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    newClonedIdsList.add(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    system.debug('vendorsovlineId-----45-->'+extSLin.buildertek__Vendor_SOV_Line_Id__c);
                    if(extSLin.buildertek__Vendor_SOV_Line_Id__c != null){
                        system.debug('existessov lines----->'+SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                        if(SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c) != null){
                            system.debug('test 1--->');
                            newSheetLine.Id = SOVSheetLineMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c);
                            
                            if(extSLin.buildertek__Change_Order__c != null){
                                newSheetLine.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            newSheetLine.buildertek__Item_No__c=itemInc;
                            newSheetLine.buildertek__Description_of_Work__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Description_of_Work__c;
                            newSheetLine.buildertek__Status__c = 'Pending';
                            newSheetLine.buildertek__Work_Completed__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Work_Completed__c;
                            newSheetLine.buildertek__Material_Presently_Stored__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Material_Presently_Stored__c;
                            newSheetLine.buildertek__Vendor_Material_Presently_Stored__c = ConSheetRecMap.get(extSLin.buildertek__Vendor_SOV_Line_Id__c).buildertek__Vendor_Material_Presently_Stored__c;
                            
                            newSheetLine.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            system.debug('1133newSheetLine-->'+newSheetLine);
                            
                            newClonedIdsList.add(extSLin.Id);
                            NewConSheetImpList.add(newSheetLine);
                            itemInc++;
                        }  else{
                             system.debug('test 2--->');
                            system.debug('elsepartentering----->');
                            buildertek__SOV_Continuation_Sheet_Lines__c cloneline = extSLin.clone(false,true,true,false);
                            cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                            cloneline.buildertek__Budget_Grouping__c = extSLin.buildertek__Budget_Grouping__c;
                            cloneline.buildertek__Is_Imported__c = true;
                            cloneline.buildertek__Status__c = 'Pending';
                            system.debug('existline ids--->'+extSLin.Id);
                            cloneline.buildertek__Vendor_Sheet_line_Id__c = extSLin.Id;
                            cloneline.buildertek__Item_No__c=itemInc;
                            if(extSLin.buildertek__Change_Order__c != null){
                                cloneline.buildertek__Change_Order__c = extSLin.buildertek__Change_Order__c;
                            }
                            //  itemInc++;
                            system.debug(newClonedIdsList.contains(extSLin.buildertek__Vendor_SOV_Line_Id__c));
                            if(!newClonedIdsList.contains(extSLin.Id)){
                                ClonesheetlinesList.add(cloneline);
                            }
                            system.debug('line.Id-------87-->'+extSLin.Id);
                            newClonedIdsList.add(extSLin.Id);
                            
                        }
                    }
                    
                }
                
                if(!NewConSheetImpList.isEmpty()){
                    update NewConSheetImpList;
                }
                
            }else{
                system.debug('sheetlinesList.isEmpty()=--------->'+sheetlinesList.isEmpty());
                if(!sheetlinesList.isEmpty()){
                    system.debug('callinnnggggggg------->');
                    for(buildertek__SOV_Continuation_Sheet_Lines__c line:sheetlinesList){
                        buildertek__SOV_Continuation_Sheet_Lines__c cloneline = line.clone(false,true,true,false);
                        cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                        cloneline.buildertek__Budget_Grouping__c = line.buildertek__Budget_Grouping__c;
                        cloneline.buildertek__Is_Imported__c = true;
                        cloneline.buildertek__Status__c = 'Pending';
                        cloneline.buildertek__Vendor_Sheet_line_Id__c = line.Id;
                        cloneline.buildertek__Item_No__c=itemInc;
                        if(line.buildertek__Change_Order__c != null){
                            cloneline.buildertek__Change_Order__c = line.buildertek__Change_Order__c;
                        }
                        itemInc++;
                        ClonesheetlinesList.add(cloneline);
                        system.debug('line.Id-------87-->'+line.Id);
                        newClonedIdsList.add(line.Id);
                    }
                }  
            }
            
            system.debug('vendorAddedSheetLineList.isEmpty()){------->'+vendorAddedSheetLineList.isEmpty());
            if(!vendorAddedSheetLineList.isEmpty()){
                system.debug('callinnnggggggg Vendor added');
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vline:vendorAddedSheetLineList){
                    buildertek__SOV_Continuation_Sheet_Lines__c cloneline = Vline.clone(false,true,true,false);
                   cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                    cloneline.buildertek__Budget_Grouping__c = Vline.buildertek__Budget_Grouping__c;
                    cloneline.buildertek__Is_Imported__c = true;
                    cloneline.buildertek__Description_of_Work__c = Vline.buildertek__Description_of_Work__c;
                    cloneline.buildertek__Status__c = 'Pending';
                    cloneline.buildertek__Vendor_Sheet_line_Id__c = Vline.Id;
                    cloneline.buildertek__Item_No__c=itemInc; 
                    if(Vline.buildertek__Change_Order__c != null){
                        cloneline.buildertek__Change_Order__c = Vline.buildertek__Change_Order__c;
                    }
                    itemInc++;
                    system.debug('Vline.Id--------->'+Vline.Id);
                    if(!newClonedIdsList.contains(Vline.Id)){
                        ClonesheetlinesList.add(cloneline);
                    }
                }
            }
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> DeleteSheetLines = [SELECT Id,Name
                                                                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                  WHERE buildertek__SOV_Continuation_Sheet__c =:ContSheetRec.Id AND buildertek__Is_Imported__c = false];
            if(!DeleteSheetLines.isEmpty()){
                //  delete DeleteSheetLines;
            }
            
            if(!ClonesheetlinesList.isEmpty()){
                insert ClonesheetlinesList; 
            } 
            
            /*-------------------------------------------------------*/       
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> InsertedConList = New List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<String> InsertedConLinesIds = New List<String>();
            if(!ClonesheetlinesList.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c insCon : ClonesheetlinesList){
                    InsertedConLinesIds.add(insCon.Id);
                }
            }
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> newlastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                            buildertek__SOV_Continuation_Sheet__c,
                                                                            buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                            from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                            where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: recordId ORDER BY buildertek__Item_No__c ASC];
            
            
            integer newItemNumber = 100;
            
            
            /*  if(newlastSOV.size() > 0){
if(newlastSOV[0].buildertek__Item_No__c != null){
newItemNumber = Integer.valueOf(newlastSOV[0].buildertek__Item_No__c)+1;
}
} 


if(!InsertedConLinesIds.isEmpty()){
InsertedConList = [Select id, name, buildertek__Item_No__c from buildertek__SOV_Continuation_Sheet_Lines__c Where Id IN:InsertedConLinesIds ORDER BY buildertek__Item_No__c ASC];
}*/
            
            if(!newlastSOV.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c newCON : newlastSOV){
                    newCON.buildertek__Item_No__c = newItemNumber;
                    newItemNumber++;
                    
                } 
                
                Update newlastSOV;
            }
            
            /*-------------------------------------------------------*/   
            
            List<buildertek__SOV_Payment_Application__c> payappList = new List<buildertek__SOV_Payment_Application__c>();
            
            List<buildertek__SOV_Payment_Application__c> paymentApps = [SELECT Id,
                                                                        buildertek__Is_Imported__c
                                                                        FROM buildertek__SOV_Payment_Application__c
                                                                        WHERE Id IN:PAIds];
            for(buildertek__SOV_Payment_Application__c pay:paymentApps){
                pay.buildertek__Is_Imported__c = true; 
                
            }
            update paymentApps;
        }
        else if(NewPa.buildertek__Is_Pay_App_Created_For__c == 'FORVENDORSOV'){
            
            
            
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
            
            
            // to check is community true
            String portalCode = '';
            string userName = userInfo.getUserId();
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            
            
            List<buildertek__SOV_Payment_Application__c> payList = [select id,Name,buildertek__Original_Contract_Sum__c,buildertek__Net_Change_by_Change_Orders__c,buildertek__Total_Completed__c,buildertek__Total_Material_Stored_To_Date__c from buildertek__SOV_Payment_Application__c where Id IN:PAIds];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> existSheetLines = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c,buildertek__Budget_Grouping__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =:recordId and buildertek__Budget_Grouping__c = 'Change Orders'];
            
            
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorConList = [select Id, Name, buildertek__Vendor_SOV_Line_Id__c,  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c, buildertek__Budget_Grouping__c from buildertek__SOV_Continuation_Sheet_Lines__c where  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN:PAIds  and buildertek__Budget_Grouping__c = 'Change Orders'];
            
            
            List<String> ExistSheetSovIds = new List<String>();
            set<String> vendorAddedCsLineIds = new set<String>();
            
            set<String> newClonedIdsList = new set<String>();
            
            if(!existSheetLines.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c csline : existSheetLines){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+csline.buildertek__Vendor_SOV_Line_Id__c);
                    if(csline.buildertek__Vendor_SOV_Line_Id__c != null && csline.buildertek__Vendor_SOV_Line_Id__c != '' ){
                        ExistSheetSovIds.add(csline.buildertek__Vendor_SOV_Line_Id__c);   
                    }
                }
            }
            
            system.debug('ExistSheetSovIds-------->'+ExistSheetSovIds);
            
            if(!VendorConList.isEmpty()){
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vcsline : VendorConList){
                    system.debug('buildertek__Vendor_SOV_Line_Id__c------->'+Vcsline.buildertek__Vendor_SOV_Line_Id__c);
                    if(Vcsline.buildertek__Vendor_SOV_Line_Id__c == null || Vcsline.buildertek__Vendor_SOV_Line_Id__c == '' ){
                        vendorAddedCsLineIds.add(Vcsline.Id);  
                    }
                }
            }
            
            
            system.debug('vendorAddedCsLineIds-------->'+vendorAddedCsLineIds);
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> vendorAddedSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            
            if(!vendorAddedCsLineIds.isEmpty()){
                vendorAddedSheetLineList = [SELECT ID,
                                            buildertek__G_C__c,
                                            buildertek__Balance_To_Finish__c,
                                            buildertek__Budget_Grouping__c,
                                            Name,buildertek__Item_No__c,
                                            buildertek__Description_of_Work__c,
                                            buildertek__Material_Presently_Stored__c,
                                            buildertek__Rejection_Reason__c,
                                            buildertek__Retainage__c,
                                            buildertek__Scheduled_Value__c,
                                            buildertek__Status__c,
                                            buildertek__Work_Completed_from_Previous_Application__c,
                                            buildertek__Work_Completed__c,
                                            buildertek__Vendor_Sheet_line_Id__c,
                                            buildertek__Vendor_SOV_Line_Id__c,
                                            buildertek__Change_Order__c
                                            FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                            WHERE Id IN:vendorAddedCsLineIds];
            }
            
            system.debug('vendorAddedSheetLineList--------->'+vendorAddedSheetLineList);
            
            
            Decimal originalcontract = 0;
            Decimal totalCompleted = 0;
            Decimal Totalmaterialstored = 0;
            for(buildertek__SOV_Payment_Application__c pay:payList){
                if(pay.buildertek__Original_Contract_Sum__c != null){
                    originalcontract += pay.buildertek__Original_Contract_Sum__c - pay.buildertek__Net_Change_by_Change_Orders__c;
                    system.debug('originalcontract.....'+originalcontract);
                }
                if(pay.buildertek__Total_Completed__c != null){
                    totalCompleted += pay.buildertek__Total_Completed__c;  
                }
                if(pay.buildertek__Total_Material_Stored_To_Date__c != null){
                    Totalmaterialstored += pay.buildertek__Total_Material_Stored_To_Date__c;  
                }
                
            }
            
            buildertek__SOV_Payment_Application__c paymentRec = [select id,Name,buildertek__PA_Type__c,RecordTypeId, recordtype.name,buildertek__Imported_Payment_IDs__c,buildertek__Old_PA_Ids__c,buildertek__Original_Contract_Sum__c,
                                                                 buildertek__Total_Completed__c,buildertek__Net_Change_by_Change_Orders__c,
                                                                 buildertek__Total_Material_Stored_To_Date__c
                                                                 from buildertek__SOV_Payment_Application__c where Id =: recordId];
            
            
            buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
            payRec.buildertek__Imported_Payment_IDs__c= paymentRec.buildertek__Imported_Payment_IDs__c;
            if(paymentRec.buildertek__Original_Contract_Sum__c != null){
            payRec.buildertek__Original_Contract_Sum__c = paymentRec.buildertek__Original_Contract_Sum__c-paymentRec.buildertek__Net_Change_by_Change_Orders__c;
            }
            payRec.buildertek__Total_Completed__c = paymentRec.buildertek__Total_Completed__c;
            payRec.buildertek__Total_Material_Stored_To_Date__c = paymentRec.buildertek__Total_Material_Stored_To_Date__c;
            payRec.id = recordId;
            Integer i = 1;
            string ImportedPaymentIds = '';
            
            system.debug('PAIds-->'+PAIds.size());
            for(string paId : PAIds){
                
                //payRec.buildertek__Imported_Payment_IDs__c =  payRec.buildertek__Imported_Payment_IDs__c+','+paId;
                ImportedPaymentIds += paId+',';
                if(PAIds.size() == 1){
                    payRec.buildertek__Old_PA_Ids__c = paId;
                }else if(i==1){
                    payRec.buildertek__Old_PA_Ids__c = paId+'_';
                    i++;
                }else if(PAIds.size() == i && i > 1){
                    payRec.buildertek__Old_PA_Ids__c += paId;
                }else{
                    payRec.buildertek__Old_PA_Ids__c += paId+'_';
                    i++;
                }
                
            }
            system.debug('@@@@@@@@@@@@'+ImportedPaymentIds);
            system.debug('*****************'+payRec.buildertek__Imported_Payment_IDs__c);
            if(payRec.buildertek__Imported_Payment_IDs__c != null){
                system.debug('not null');
                payRec.buildertek__Imported_Payment_IDs__c += ImportedPaymentIds;
            }else{
                system.debug('--- null');
                payRec.buildertek__Imported_Payment_IDs__c = ImportedPaymentIds;
                
            }
            
            if(payRec.buildertek__Original_Contract_Sum__c != null){
                payRec.buildertek__Original_Contract_Sum__c += originalcontract;  
            }
            else{
                payRec.buildertek__Original_Contract_Sum__c = originalcontract; 
            }
            
            if(payRec.buildertek__Total_Completed__c != null){
                payRec.buildertek__Total_Completed__c += totalCompleted;  
            }
            else{
                payRec.buildertek__Total_Completed__c = totalCompleted; 
            }
            
            if(payRec.buildertek__Total_Material_Stored_To_Date__c != null){
                payRec.buildertek__Total_Material_Stored_To_Date__c += Totalmaterialstored;
            }
            else{
                payRec.buildertek__Total_Material_Stored_To_Date__c = Totalmaterialstored;
            }
            
            Update payRec;
            
            Set<string> ContSheetLineIds = new Set<string>();
            buildertek__SOV_Continuation__c ContSheetRec   = [SELECT Id,
                                                              buildertek__SOV_Payment_Application__c
                                                              FROM buildertek__SOV_Continuation__c
                                                              WHERE buildertek__SOV_Payment_Application__c=:recordId limit 1];
            
            List<buildertek__SOV_Continuation__c> ContSheetRecList   = [SELECT Id,
                                                                        buildertek__SOV_Payment_Application__c
                                                                        FROM buildertek__SOV_Continuation__c
                                                                        WHERE buildertek__SOV_Payment_Application__c IN:PAIds];
            
            system.debug('&&&&&&'+ContSheetRecList);
            if(!ContSheetRecList.isEmpty()){
                for(buildertek__SOV_Continuation__c con : ContSheetRecList){
                    ContSheetLineIds.add(con.Id);
                }
            } 
            system.debug('&&&&&&'+ContSheetLineIds);
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ClonesheetlinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>(); 
            if(!ContSheetLineIds.isEmpty()){
                
                sheetlinesList = [SELECT ID,
                                  buildertek__G_C__c,
                                  buildertek__Balance_To_Finish__c,
                                  buildertek__Balance_to_Pay__c,
                                  buildertek__Budget_Grouping__c,
                                  Name,
                                  buildertek__Cost_Code__c,
                                  buildertek__Description_of_Work__c,
                                  buildertek__Grouping__c,
                                  buildertek__Grouping2__c,
                                  buildertek__Sheet_Item_No__c,
                                  buildertek__Item_No__c,
                                  buildertek__less10_hold_back__c,
                                  buildertek__Material_Presently_Stored__c,
                                  buildertek__percent1__c,
                                  buildertek__percent2__c,
                                  buildertek__percent3__c,
                                  buildertek__Rejection_Reason__c,
                                  buildertek__Retainage__c,
                                  buildertek__Scheduled_Value__c,
                                  buildertek__Status__c,
                                  buildertek__Total__c,
                                  buildertek__Vendor__c,
                                  buildertek__Work_Completed_from_Previous_Application__c,
                                  buildertek__Work_Completed__c,
                                  buildertek__Vendor_Sheet_line_Id__c,
                                  buildertek__Vendor_SOV_Line_Id__c,
                                  buildertek__Change_Order__c
                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                  WHERE buildertek__SOV_Continuation_Sheet__c IN:ContSheetLineIds]; 
            } 
            system.debug('&&&&&&'+sheetlinesList);
            
            
            
            if(!vendorAddedSheetLineList.isEmpty()){
                system.debug('callinnnggggggg Vendor added');
                for(buildertek__SOV_Continuation_Sheet_Lines__c Vline:vendorAddedSheetLineList){
                    buildertek__SOV_Continuation_Sheet_Lines__c cloneline = Vline.clone(false,true,true,false);
                    cloneline.buildertek__SOV_Continuation_Sheet__c  = ContSheetRec.Id;
                    cloneline.buildertek__Budget_Grouping__c = Vline.buildertek__Budget_Grouping__c;
                    cloneline.buildertek__Is_Imported__c = true;
                    cloneline.buildertek__Description_of_Work__c = Vline.buildertek__Description_of_Work__c;
                    cloneline.buildertek__Status__c = 'Pending';
                    cloneline.buildertek__Vendor_Sheet_line_Id__c = Vline.Id;
                    cloneline.buildertek__Item_No__c=itemInc;
                    if(Vline.buildertek__Change_Order__c != null){
                        cloneline.buildertek__Change_Order__c = Vline.buildertek__Change_Order__c;
                    }
                    itemInc++;
                    system.debug('Vline.Id--------->'+Vline.Id);
                    if(!newClonedIdsList.contains(Vline.Id)){
                        ClonesheetlinesList.add(cloneline);
                    }
                }
            }
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> DeleteSheetLines = [SELECT Id,Name
                                                                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                  WHERE buildertek__SOV_Continuation_Sheet__c =:ContSheetRec.Id AND buildertek__Is_Imported__c = false];
            if(!DeleteSheetLines.isEmpty()){
                //  delete DeleteSheetLines;
            }
            
            if(!ClonesheetlinesList.isEmpty()){
                insert ClonesheetlinesList; 
            } 
            List<buildertek__SOV_Payment_Application__c> payappList = new List<buildertek__SOV_Payment_Application__c>();
            
            List<buildertek__SOV_Payment_Application__c> paymentApps = [SELECT Id,
                                                                        buildertek__Is_Imported__c
                                                                        FROM buildertek__SOV_Payment_Application__c
                                                                        WHERE Id IN:PAIds];
            for(buildertek__SOV_Payment_Application__c pay:paymentApps){
                pay.buildertek__Is_Imported__c = true; 
                
            }
            update paymentApps;
            
            
            
            
            
            
        }
        
        
    }
    
    
    @AuraEnabled
    public static ResponseWrapper createSheetLinesNew(List<String> coIds, String recordId){
        
        
        
        
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
        
        
        
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Get_Lines_From_CO__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Payment Application Configuration'];
        Boolean islien = false;
        if(adminInterfaceNodeConfigurations.buildertek__Get_Lines_From_CO__c == true){
            islien = true;
        }
        
        buildertek__SOV_Payment_Application__c PayAppType = [select Id, Name, buildertek__Application__c,recordtype.name  from buildertek__SOV_Payment_Application__c where Id =: recordId];
        
        system.debug('paymentappId-------->'+recordId);
        
        
        
        List<buildertek__Change_Order__c> COListToUpdate = [SELECT Id,
                                                            Name,
                                                            buildertek__Payment_Application_G702__c,
                                                            buildertek__Is_CO_Imported__c,
                                                            buildertek__isARCO__c,
                                                            buildertek__Payment_Application_G702__r.RecordType.Name
                                                            FROM buildertek__Change_Order__c
                                                            WHERE Id IN: coIds];
        List<buildertek__Change_Order__c> CORecList = new List<buildertek__Change_Order__c>();
        
        if(COListToUpdate.size() > 0){
            
            for(buildertek__Change_Order__c CO : COListToUpdate){
                CO.buildertek__Is_CO_Imported__c = true;
                if(PayAppType.recordtype.name == 'AR'){
                    CO.buildertek__isARCO__c = true;  
                }
                CORecList.add(CO);
            }
        }
        if(CORecList.size() > 0){
            update CORecList;
        }
        
        
        
        //    Start Change order bt value enable---------------------------
        //    
        
        Map<String,String> COPAYAPPTracMap = new  Map<String,String>();
        Map<String,String> COandCOLineMap = new  Map<String,String>();        
        if(islien == true){
            
            List<buildertek__Change_Order__c> coList1 = [SELECT Id,
                                                         Name,buildertek__Payment_Application_G702__c
                                                         FROM buildertek__Change_Order__c
                                                         WHERE Id IN: coIds];
            
            System.debug('coList1---->'+coList1);
            
            
            List<buildertek__Change_Order_Item__c> COLineList = [select Id, Name, buildertek__Total__c, buildertek__Change_Order__c from buildertek__Change_Order_Item__c where buildertek__Change_Order__c IN:coIds ];
            
            system.debug('COLineList------>'+COLineList);
            
            List<buildertek__Change_Order__c> PaymentAppCOList1 = new List<buildertek__Change_Order__c>();
            
            if(coList1.size() > 0){
                for(buildertek__Change_Order__c coItem : coList1){
                    buildertek__Change_Order__c PACO = new buildertek__Change_Order__c();
                    PACO.Id = coItem.Id;
                    PACO.buildertek__Payment_Application_G702__c = recordId;
                    PaymentAppCOList1.add(PACO);
                }
                
                system.debug('PaymentAppCOList1------>'+PaymentAppCOList1);
                if(PaymentAppCOList1.size() > 0){
                    update PaymentAppCOList1;
                }
            }
            
            
            List<buildertek__BT_Change_Order_Payment_Tracking__c> COPayAppTrackRecs = new List<buildertek__BT_Change_Order_Payment_Tracking__c>();
            
            if(coList1.size() > 0){
                for(buildertek__Change_Order__c CORec : coList1){
                    buildertek__BT_Change_Order_Payment_Tracking__c COPATrac = new buildertek__BT_Change_Order_Payment_Tracking__c();
                    COPATrac.Name = PayAppType.Name +' - '+ PayAppType.buildertek__Application__c ;
                    COPATrac.buildertek__Change_Order__c = CORec.Id;
                    COPATrac.buildertek__Payment_Application_G702__c = recordId;
                    //  COandCOLineMap.put(COPATrac.buildertek__Change_Order__c,CORec.Id);
                    COPayAppTrackRecs.add(COPATrac);
                    
                }
                
                system.debug('COPayAppTrackRecs------>'+COPayAppTrackRecs);
                if(COPayAppTrackRecs.size() > 0){
                    Insert COPayAppTrackRecs;
                }
                
            }
            
            List<String> COPayAppTraKIds = new List<String>();
            
            if(COPayAppTrackRecs.size() > 0){
                for(buildertek__BT_Change_Order_Payment_Tracking__c COPaymentTrackRecs : COPayAppTrackRecs){
                    COPayAppTraKIds.add(COPaymentTrackRecs.Id);
                }
            }
            
            system.debug('COPayAppTraKIds------------->'+COPayAppTraKIds);
            List<buildertek__BT_Change_Order_Payment_Tracking__c> COTracRecs = [select Id, Name, buildertek__Change_Order__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id IN:COPayAppTraKIds ];
            
            system.debug('COTracRecs-------->'+COTracRecs);
            
            if(COTracRecs.size() > 0){
                for(buildertek__BT_Change_Order_Payment_Tracking__c COPATRec : COTracRecs){
                    COPAYAPPTracMap.put(COPATRec.buildertek__Change_Order__c, COPATRec.Id);
                }
            }     
            
            system.debug('COPAYAPPTracMap---->'+COPAYAPPTracMap);
            
            List<buildertek__Change_Order_Payment_Tracking_Line__c> COPayAppTrackLineRecs = new List<buildertek__Change_Order_Payment_Tracking_Line__c>();
            
            if(COLineList.size() > 0){
                for(buildertek__Change_Order_Item__c COItem : COLineList){
                    buildertek__Change_Order_Payment_Tracking_Line__c COPATracLine = new buildertek__Change_Order_Payment_Tracking_Line__c();
                    COPATracLine.Name = COItem.Name;
                    COPATracLine.buildertek__Scheduled_Value__c = COItem.buildertek__Total__c;
                    COPATracLine.buildertek__Description__c = COItem.Name;
                    COPATracLine.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(COItem.buildertek__Change_Order__c);
                    
                    COPayAppTrackLineRecs.add(COPATracLine);
                }
            }
            
            system.debug('COPayAppTrackLineRecs------>'+COPayAppTrackLineRecs);
            if(COPayAppTrackLineRecs.size() > 0){
                Insert COPayAppTrackLineRecs;
            }
            
            
        }
        
        
        //   END  Change order bt value  --------------------------------------------
        //   
        
        
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }        
        system.debug('postel code'+ portalCode);
        
        ResponseWrapper RC = new ResponseWrapper();
        try{
            List<buildertek__SOV_Continuation_Sheet_Lines__c> continuationSheetLinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            List<buildertek__Change_Order_Item__c> coLinesList = [SELECT Id,
                                                                  Name, 
                                                                  buildertek__Total__c,
                                                                  buildertek__Change_Order__r.Name
                                                                  FROM buildertek__Change_Order_Item__c
                                                                  WHERE buildertek__Change_Order__c IN: coIds];
            
            /*BC Added on 11/6.  It was not using the CO details which lincluded the Tax*/                                                      
            List<buildertek__Change_Order__c> coList = [SELECT Id,
                                                        Name, 
                                                        buildertek__Total_Amount_Tax__c,buildertek__Payment_Application_G702__c
                                                        FROM buildertek__Change_Order__c
                                                        WHERE buildertek__Change_Order__c.Id IN: coIds]; 
            system.debug(coList);
            if(coList.size() > 0){
                system.debug(coList.size());
                buildertek__SOV_Continuation__c sheetId = [select Id, name, buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =:recordId LIMIT 1];
                
                
                if(portalCode == 'true'){
                    
                    for(buildertek__Change_Order__c coItem : coList){
                        buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLines = new buildertek__SOV_Continuation_Sheet_Lines__c();
                        continuationSheetLines.Name = coItem.Name;
                        continuationSheetLines.buildertek__Description_of_Work__c = coItem.Name;
                        continuationSheetLines.buildertek__SOV_Continuation_Sheet__c = sheetId.Id;
                        continuationSheetLines.buildertek__Scheduled_Value__c = coItem.buildertek__Total_Amount_Tax__c;
                        continuationSheetLines.buildertek__Budget_Grouping__c = 'Change Orders';
                        continuationSheetLines.buildertek__Work_Completed_from_Previous_Application__c = 0;
                        continuationSheetLines.buildertek__Work_Completed__c = 0;
                        continuationSheetLines.buildertek__Change_Order__c = coItem.Id;
                        if(islien == true){
                            continuationSheetLines.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(coItem.Id);
                        }
                        if(PayAppType.recordtype.name == 'AP'){
                            continuationSheetLines.buildertek__Status__c = 'Pending';
                        }
                        continuationSheetLines.buildertek__Material_Presently_Stored__c = 0;
                        continuationSheetLines.buildertek__Item_No__c=itemInc;
                        continuationSheetLines.buildertek__Is_Created_In_This_App__c = true;
                        continuationSheetLinesList.add(continuationSheetLines);
                        itemInc++;
                        system.debug(continuationSheetLinesList);
                    }
                    if(continuationSheetLinesList.size() > 0){
                        system.debug(continuationSheetLinesList.size());
                        insert continuationSheetLinesList;
                        system.debug('&&'+continuationSheetLinesList);
                    }
                    RC.Status = 'Success';
                    RC.Message = 'Continuation Sheet Lines added successfully';
                    
                }
                else{
                    for(buildertek__Change_Order__c coItem : coList){
                        buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLines = new buildertek__SOV_Continuation_Sheet_Lines__c();
                        continuationSheetLines.Name = coItem.Name;
                        continuationSheetLines.buildertek__Description_of_Work__c = coItem.Name;
                        continuationSheetLines.buildertek__SOV_Continuation_Sheet__c = sheetId.Id;
                        continuationSheetLines.buildertek__Scheduled_Value__c = coItem.buildertek__Total_Amount_Tax__c;
                        continuationSheetLines.buildertek__Budget_Grouping__c = 'Change Orders';
                        continuationSheetLines.buildertek__Work_Completed_from_Previous_Application__c = 0;
                        continuationSheetLines.buildertek__Work_Completed__c = 0;
                        system.debug('coItem.Id--------->'+coItem.Id);
                        continuationSheetLines.buildertek__Change_Order__c = coItem.Id;
                        if(islien == true){
                            system.debug('COPAYAPPTracMap.get(coItem.Id)---------->'+COPAYAPPTracMap.get(coItem.Id));
                            continuationSheetLines.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(coItem.Id);
                        }
                        if(PayAppType.recordtype.name == 'AR'){
                            continuationSheetLines.buildertek__Status__c = 'Pending';
                        }
                        continuationSheetLines.buildertek__Material_Presently_Stored__c = 0;
                        continuationSheetLines.buildertek__Item_No__c=itemInc;
                        continuationSheetLines.buildertek__Is_Created_In_This_App__c = true;
                        continuationSheetLinesList.add(continuationSheetLines);
                        itemInc++;
                        system.debug(continuationSheetLinesList);
                    }
                    if(continuationSheetLinesList.size() > 0){
                        system.debug(continuationSheetLinesList.size());
                        insert continuationSheetLinesList;
                        system.debug('&&'+continuationSheetLinesList);
                    }
                    
                    
                    
                    
                    RC.Status = 'Success';
                    RC.Message = 'Continuation Sheet Lines added successfully';  
                }
                
            }    
        }catch(exception exp){
            RC.Status = 'Error';
            RC.Message = exp.getMessage();
        }
        return RC;
    }
    
    
    
    // To Get community user
    @AuraEnabled 
    public static User getCommUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    
    @AuraEnabled
    public static String submitPAForView(String recordId,date todayDate){
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> coslist = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        buildertek__SOV_Payment_Application__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id =:recordId];
        buildertek__SOV_Continuation__c continuationsheetRec = [select id,Name from buildertek__SOV_Continuation__c 
                                                                where buildertek__SOV_Payment_Application__c =: updateStatus.id LIMIT 1];
        list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinelist = [select id,Name,buildertek__Status__c,buildertek__SOV_Continuation_Sheet__c from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                           where buildertek__SOV_Continuation_Sheet__c =: continuationsheetRec.id ];
        if(updateStatus.buildertek__Status__c ==  'Company Rejected'){
            for(buildertek__SOV_Continuation_Sheet_Lines__c sheetRec : sheetlinelist){
                if(sheetRec.buildertek__Status__c == 'Rejected'){
                    sheetRec.buildertek__Status__c = 'Vendor Submitted';
                    coslist.add(sheetRec);
                }else if(sheetRec.buildertek__Status__c == 'Pending'){
                    sheetRec.buildertek__Status__c = 'Vendor Submitted';
                    coslist.add(sheetRec);
                }
            }
        }else if(updateStatus.buildertek__Status__c ==  'Pending'){
            for(buildertek__SOV_Continuation_Sheet_Lines__c sheetRec : sheetlinelist){
                sheetRec.buildertek__Status__c = 'Vendor Submitted';
                coslist.add(sheetRec);
            }
        }
        if(coslist.size() > 0){
            update coslist;
        }
        updateStatus.buildertek__Status__c = 'Vendor Submitted';
        updateStatus.buildertek__Submission_Date__c = todayDate;
        update updateStatus;
        return 'success';
   
    }
    @AuraEnabled
    public static String getreason(String recordid){
        buildertek__SOV_Continuation_Sheet_Lines__c cslrec = [select id,Name,buildertek__Rejection_Reason__c
                                                              from buildertek__SOV_Continuation_Sheet_Lines__c where id =: recordid];
        return cslrec.buildertek__Rejection_Reason__c;
    }
    @AuraEnabled
    public static String getstatus(String recordid){
        buildertek__SOV_Continuation_Sheet_Lines__c cslrec = [select id,Name,buildertek__Status__c from buildertek__SOV_Continuation_Sheet_Lines__c where id =: recordid];
        return cslrec.buildertek__Status__c;
    }
    
    @AuraEnabled
    public static buildertek__SOV_Payment_Application__c isSovSubmitted(String recordId){
        system.debug('*****************');
        system.debug(recordId);
        buildertek__SOV_Payment_Application__c updateStatus = [select Id, Name, buildertek__Status__c,buildertek__PA_Type__c, RecordTypeId, recordtype.name from buildertek__SOV_Payment_Application__c where Id =:recordId];
        system.debug(updateStatus);
        
        system.debug('updates status ------> '+ updateStatus);
        return updateStatus;
    }
    
    
    
    
    public class ApprovedCOClass{
        @AuraEnabled
        public buildertek__Change_Order__c coRecord;
        @AuraEnabled
        public Boolean coCheck;
    }  
    
    public class ResponseWrapper{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
    @AuraEnabled
    public static String getPaymentAppStatus(String recordId){
        string paystatus='';
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__SOV_Payment_Application__c'){
            buildertek__SOV_Payment_Application__c sov = [select id,buildertek__Status__c from buildertek__SOV_Payment_Application__c where id =:recordId];
            paystatus = sov.buildertek__Status__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__SOV_Continuation__c'){
            buildertek__SOV_Continuation__c sov = [select id,buildertek__SOV_Payment_Application__r.buildertek__Status__c from buildertek__SOV_Continuation__c where id=:recordId];
            paystatus =  sov.buildertek__SOV_Payment_Application__r.buildertek__Status__c;
        }
        return paystatus;
    }
    @AuraEnabled
    public static Boolean getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Require_Vendor_to_Sign_Lien_Release__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Payment Application Configuration'];
        Boolean islien = false;
        if(adminInterfaceNodeConfigurations.buildertek__Require_Vendor_to_Sign_Lien_Release__c == true){
            islien = true;
        }
        return islien;
    }  
    @AuraEnabled
    public static string saveSign(String recId, String base64Data, String contentType, string signName, String LienTest){
        try {
            string conversn;
            system.debug('lien Text'+ LienTest);
            system.debug('signature string --------->'+base64Data);
            
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            system.debug('decoded utf 8string --------->'+base64Data );
            
            system.debug('final  string --------->'+EncodingUtil.base64Decode(base64Data));
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'LienReleaseSignature.png'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'signName'; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            system.debug('*******conVer*******' + conVer);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
            conversn = [SELECT Id, VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
            //system.debug('conversn[0].Id ='+conversn[0].Id);
            system.debug('conversn'+conversn);
            
            String signId = conVer.Id;
            
            getStockQuotes( LienTest,  signId, recId);
            
            
            /*  transient ContentVersion conVers = new ContentVersion();
conVers.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
conVers.PathOnClient = 'Purchase Order Lien.pdf'; // The files name, extension is very important here which will help the file in preview.
conVers.Title = 'Purchase Order Lien';
conVers.VersionData = pdfPageBlob;  // converting your binary string to Blog
insert conVers;


Id conDocu = [SELECT ContentDocumentId
FROM ContentVersion
WHERE Id = :conVers.Id].ContentDocumentId;
//create ContentDocumentLink  record
transient ContentDocumentLink conDocuLink = New ContentDocumentLink();
conDocuLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
conDocuLink.ContentDocumentId = conDocu;  //ContentDocumentId Id from ContentVersion
conDocuLink.shareType = 'I';
conDocuLink.Visibility = 'AllUsers';
insert conDocuLink;*/
            
            
            return 'success';
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return e.getMessage();
        }
        
        
        /*    if (base64Data.length() > 1696 || Test.isRunningTest()){
base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
system.debug('stringbase64'+LienTest);
system.debug('testtestetst'+EncodingUtil.base64Decode(base64Data));
ContentVersion conVer = new ContentVersion();
conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
conVer.PathOnClient = 'LienReleaseSignature.png'; // The files name, extension is very important here which will help the file in preview.
conVer.Title = 'signName'; // Display name of the files
conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
insert conVer;    //Insert ContentVersion
system.debug('*******conVer*******' + conVer);
// First get the Content Document Id from ContentVersion Object
Id conDoc = [SELECT ContentDocumentId
FROM ContentVersion
WHERE Id = :conVer.Id].ContentDocumentId;
//create ContentDocumentLink  record
ContentDocumentLink conDocLink = New ContentDocumentLink();
conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
conDocLink.shareType = 'I';
insert conDocLink;
conversn = [SELECT Id, VersionData
FROM ContentVersion
WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
//system.debug('conversn[0].Id ='+conversn[0].Id);
system.debug('conversn'+conversn);
return conversn;
} else{
String message = 'NoImage';
return message;
} */
    }
    
    
    
    @future(callout=true)
    public static void getStockQuotes(string LienTest, String signId, String recId)
    {   
        try{
        List<buildertek__BT_Payment_App_Sign_Url__c> paymentAppSignUrl = [select Name__c, buildertek__Site_Url__c from buildertek__BT_Payment_App_Sign_Url__c limit 1];
        
        system.debug('111111111111111111');
        system.debug('signId'+signId);
        PageReference pagePdf = new PageReference(paymentAppSignUrl[0].buildertek__Site_Url__c+'/apex/PALienReleaseSignature'); 
        pagePdf.getParameters().put('LienText', LienTest);
        pagePdf.getParameters().put('ImageId', signId);
        system.debug('333333333333333333');
        blob pdfPageBlob = pagePdf.getContentAsPDF();
        system.debug('pdfPageBlob'+pdfPageBlob);
        
        Attachment attachmentPDF = new Attachment();
        attachmentPdf.parentId = recId;
        attachmentPdf.name =  'Lien Release Signature.pdf';
        attachmentPdf.body = pdfPageBlob;
        insert attachmentPDF;  
        }catch(Exception e){
        }
        
    }
    
    
    
    public static string saveSignature(String recId, String base64Data, String contentType, string signName, String LienTest){
        Attachment attachmentPDF = new Attachment();
        attachmentPdf.parentId = recId;
        attachmentPdf.name =  'sample.pdf';
        attachmentPdf.body = blob.toPDF(LienTest);
        insert attachmentPDF;
        return 'success';
    }
    
    @AuraEnabled
    public static string getLienRelease(String recordId){
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con;
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
            con = [select id, Email
                   from Contact
                   where email != null
                   order by createddate desc
                   limit 1];
        }
        String[] toaddres;
        toaddres = new String[]{con.email};
            Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        EmailTemplate theTemplate;
        if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
            theTemplate = [SELECT Id, folder.name, body
                           FROM EmailTemplate
                           WHERE name = 'Send Lien Release'];
        }
        system.debug('theTemplate'+theTemplate);
        /* email.setTemplateId(theTemplate);
email.setWhatId(recordId);
email.setTargetObjectId(con.Id);
email.setSaveAsActivity(true);
email.setToAddresses(toaddres);
msgList.add(email);

Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
Database.rollback(sp);
for (Messaging.SingleEmailMessage emailNew : msgList){
templateBody1 = emailNew.getHTMLBody();
}


Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
string theTemplate1 = [SELECT Id
FROM EmailTemplate
WHERE Name = 'BT Proposal Images'].Id;
email1.setTemplateId(theTemplate1);
email1.setWhatId(recordId);
email1.setTargetObjectId(con.Id);
email1.setSaveAsActivity(true);
email1.setToAddresses(toaddres);
msgList1.add(email1); 
Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
System.debug('Email Results isSuccess = ' + r1[0].IsSuccess());
Database.rollback(sp); 
for (Messaging.SingleEmailMessage emailNew1 : msgList1){
templateBody2 = emailNew1.getHTMLBody();
}
system.debug('templateBody 2 ----------> ' + templateBody2);
templateBody = templateBody1 + templateBody2;
system.debug('Final templateBody ----------> ' + templateBody);*/
        return theTemplate.body;
    }
    
    
    @AuraEnabled
    public static String AceptConnLines(String recordId){
        list<buildertek__SOV_Continuation_Sheet_Lines__c> coslist = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        buildertek__SOV_Payment_Application__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id =:recordId];
        buildertek__SOV_Continuation__c continuationsheetRec = [select id,Name from buildertek__SOV_Continuation__c 
                                                                where buildertek__SOV_Payment_Application__c =: updateStatus.id];
        list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlinelist = [select id,Name,buildertek__Status__c,buildertek__SOV_Continuation_Sheet__c,buildertek__Material_Presently_Stored__c,buildertek__Vendor_Sheet_line_Id__c, buildertek__Vendor_Work_Completed_This_Period__c from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                           where buildertek__SOV_Continuation_Sheet__c =: continuationsheetRec.id ];
        
        system.debug('sheetlinelist---->'+sheetlinelist);
        list<String> ConSheetLineIds = new list<String> ();
        if(!sheetlinelist.isEmpty()){
            for(SOV_Continuation_Sheet_Lines__c sheetLine : sheetlinelist){
                ConSheetLineIds.add(sheetLine.Id);
            }
        }
        
        system.debug('ConSheetLineIds---->'+ConSheetLineIds);
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> APConnLine = [select Id, Name, buildertek__Vendor_Sheet_line_Id__c,buildertek__Material_Presently_Stored__c,buildertek__Vendor_Work_Completed_This_Period__c, buildertek__Work_Completed__c, buildertek__Status__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c,buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name from buildertek__SOV_Continuation_Sheet_Lines__c where Id IN:ConSheetLineIds];
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetlineslist1 = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        List<buildertek__SOV_Continuation_Sheet_Lines__c> ARPaymentappLine = [select Id, Name,buildertek__Rejection_Reason__c, buildertek__Material_Presently_Stored__c,buildertek__Vendor_Sheet_line_Id__c,buildertek__Vendor_Work_Completed_This_Period__c, buildertek__Work_Completed__c, buildertek__Status__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c,buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__Vendor_Sheet_line_Id__c IN: ConSheetLineIds AND  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name = 'AR'];
        
        system.debug('ARPaymentappLine--------->'+ARPaymentappLine);
        
        Map<String,Decimal> vendorLineWorkCompletedMap = new  Map<String,Decimal>();
         Map<String,Decimal> vendorLinematerialStored = new  Map<String,Decimal>();
        for(buildertek__SOV_Continuation_Sheet_Lines__c sheetRec : sheetlinelist){
            sheetRec.buildertek__Rejection_Reason__c = '';
                sheetRec.buildertek__Status__c = 'Accepted'; 
            coslist.add(sheetRec);
            vendorLineWorkCompletedMap.put(sheetRec.Id,sheetRec.buildertek__Vendor_Work_Completed_This_Period__c);
            vendorLinematerialStored.put(sheetRec.Id,sheetRec.buildertek__Material_Presently_Stored__c);
        }
        
        system.debug('vendorLineWorkCompletedMap------>'+vendorLineWorkCompletedMap);
        if(coslist.size() > 0){
            update coslist;
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> ARineslist = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            system.debug('ARPaymentappLine--->'+ARPaymentappLine);
            for (buildertek__SOV_Continuation_Sheet_Lines__c lineId : ARPaymentappLine){
                buildertek__SOV_Continuation_Sheet_Lines__c sheetlinerec1 = new buildertek__SOV_Continuation_Sheet_Lines__c();
                sheetlinerec1.Id = lineId.Id;
                sheetlinerec1.buildertek__Rejection_Reason__c = '';
                if(lineId.buildertek__Status__c == 'Pending' || lineId.buildertek__Status__c == 'Rejected'){
                sheetlinerec1.buildertek__Status__c = 'Pending';
                }
                sheetlinerec1.buildertek__Material_Presently_Stored__c = lineId.buildertek__Material_Presently_Stored__c;
                sheetlinerec1.buildertek__Material_Presently_Stored__c = vendorLinematerialStored.get(lineId.buildertek__Vendor_Sheet_line_Id__c);
                
                system.debug('sheetlinerec1.buildertek__Vendor_Sheet_line_Id__c'+lineId.buildertek__Vendor_Sheet_line_Id__c);
                system.debug('vendorLineWorkCompletedMap.get(sheetlinerec1.buildertek__Vendor_Sheet_line_Id__c)'+vendorLineWorkCompletedMap.get(lineId.buildertek__Vendor_Sheet_line_Id__c));
                sheetlinerec1.buildertek__Work_Completed__c = vendorLineWorkCompletedMap.get(lineId.buildertek__Vendor_Sheet_line_Id__c);
                sheetlineslist1.add(sheetlinerec1);
            }
            system.debug('sheetlineslist1'+sheetlineslist1);
            if(!sheetlineslist1.isEmpty()){
                update sheetlineslist1;
            }
            system.debug('sheetlineslist2'+sheetlineslist1);
        }
        
        return 'success';
    }
    
    @AuraEnabled
    public static buildertek__SOV_Payment_Application__c getPaymentRecord(String recordId){
        if(recordId != null){
            buildertek__SOV_Payment_Application__c paymentList = [SELECT Id,
                                                                  buildertek__Status__c,
                                                                  Name,
                                                                  buildertek__Project__c,
                                                                  buildertek__Project__r.Name,
                                                                  buildertek__Is_Imported__c
                                                                  FROM buildertek__SOV_Payment_Application__c
                                                                  Where Id =:recordId];
            return paymentList;
        }
        else{
            return null;
        }
    }
    
    
    
    @AuraEnabled
    public static buildertek__SOV_Payment_Application__c checkPeriodTo(String recordId){
        if(recordId != null){
            buildertek__SOV_Payment_Application__c paymentList = [SELECT Id,
                                                                  buildertek__Period_To__c,buildertek__Retainage__c
                                                                  FROM buildertek__SOV_Payment_Application__c
                                                                  Where Id =:recordId];
            return paymentList;
        }
        else{
            return null;
        }
    }
    
    
}