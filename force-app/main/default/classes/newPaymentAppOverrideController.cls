public class newPaymentAppOverrideController {
    
    @AuraEnabled
    public static string getRfqTo1(){
        return UserInfo.getDefaultCurrency();
    }
    
    @AuraEnabled
    public static buildertek__SOV_Continuation__c GetSheetid(String recordId){
        buildertek__SOV_Continuation__c sheetId = [select Id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__r.Id =: recordId ];
        return sheetId;
    }
    @AuraEnabled
    public static string Getadmindetails(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_SOV__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'SOV Configuration'];
        return adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
    }
    @AuraEnabled
    public static string GetadmindetailsforPA(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_PA__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Payment Application Configuration'];
        return adminInterfaceNodeConfigurations.buildertek__Default_Account_for_PA__c;
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
    
    @AuraEnabled
    public static buildertek__SOV_Payment_Application__c saveCommunityUserId(String recordId, String commUserId){
        
        buildertek__SOV_Payment_Application__c sheetId = [select Id,Name,buildertek__isCommunityUser__c from buildertek__SOV_Payment_Application__c where Id =: recordId ];
        
        sheetId.buildertek__isCommunityUser__c = commUserId;
        update sheetId;
        return sheetId;
    }
    
    @AuraEnabled
    public static string createlinesnewApp(String payData){
        buildertek__SOV_Payment_Application__c app = (buildertek__SOV_Payment_Application__c)JSON.deserialize(payData,buildertek__SOV_Payment_Application__c.Class);
        
        insert app;
        return app.Id;
    }
    @AuraEnabled
    public static void deleteline(String recId){
        system.debug(recId);
        if(recId != '' && recId != null){
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLinesList = [select Id,Name,buildertek__SOV_Continuation_Sheet__c,
                                                                                buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                                from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: recId];
            system.debug('@@@@@sheetLinesList'+sheetLinesList);
            if(sheetLinesList.size() > 0){
                delete sheetLinesList;
            }
        }
        
    }
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Schedule_of_Values__c' and Name='All'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static buildertek__Schedule_of_Values__c updateSubmittedDate(String recordId){
        
        buildertek__Schedule_of_Values__c sheetId = [select Id,Name,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id =: recordId ];
        
        sheetId.buildertek__Date_Submitted__c = Date.Today();
        update sheetId;
        return sheetId;
    } 
    
    
    @AuraEnabled
    public static String isSovSubmitted(String recordId){
        system.debug(recordId);
        if(recordId != null){
            buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id =:recordId];
            system.debug(updateStatus);
            
            return updateStatus.buildertek__Status__c;
        }
        return null;
    }
    
    
    
    @AuraEnabled
    public static string CheckSovType(String recordId){
        system.debug(recordId);
        if(recordId != null){
            buildertek__Schedule_of_Values__c sovRec = [select Id, Name, OwnerId from buildertek__Schedule_of_Values__c where Id =:recordId];
            List<User> userList = [Select Id, AccountId FROM User WHERE Id =: sovRec.OwnerId AND AccountId != null];
            if(!userList.isEmpty()){
                return 'PortalUser';
            }
            else{
                return 'SalesforceUser';
            }
        }
        return null;
    }
    
    
    
    
    
    @AuraEnabled
    public static buildertek__SOV_Payment_Application__c createlines(String recordId,string projectId, String RecordTypeId){
        buildertek__SOV_Payment_Application__c paymentRec = new buildertek__SOV_Payment_Application__c();
        paymentRec.Name = 'Payment Application';
        paymentRec.buildertek__Application__c = '1';
        paymentRec.RecordTypeId = RecordTypeId;
        paymentRec.buildertek__Period_To__c = Null;
        if(projectId != '' && projectId != null){
            paymentRec.buildertek__Project__c = projectId;
        }
        insert paymentRec;
        return paymentRec;
    }
    @AuraEnabled
    public static List<buildertek__SOV_Payment_Application__c> getVendorPaymentApps(string projectId){
        system.debug('***'+projectId);
        List<buildertek__SOV_Payment_Application__c> paymentRec = new List<buildertek__SOV_Payment_Application__c>();
        if(projectId == '' || projectId == null){
            system.debug('***true');
            paymentRec = [select id,
                          buildertek__Status__c,Name,buildertek__Owner_Account__c, buildertek__Owner_Account__r.Name,buildertek__Original_Contract_Sum__c,buildertek__Total_Material_Stored_To_Date__c,buildertek__Project__c,buildertek__Project__r.Name
                          from buildertek__SOV_Payment_Application__c
                          where buildertek__Status__c='Company Accepted' AND buildertek__Is_Imported__c = false];
        }else {
            system.debug('***false');
            paymentRec = [select id,
                          buildertek__Status__c,Name,buildertek__Owner_Account__c, buildertek__Owner_Account__r.Name,buildertek__Original_Contract_Sum__c,buildertek__Total_Material_Stored_To_Date__c,buildertek__Project__c,buildertek__Project__r.Name
                          from buildertek__SOV_Payment_Application__c
                          where buildertek__Status__c='Company Accepted' And buildertek__Project__c =:projectId AND buildertek__Is_Imported__c = false];
        }
        system.debug('paymentRec '+paymentRec);
        return paymentRec;
    }
    
    
    @AuraEnabled
    public static list<buildertek__SOV_Continuation_Sheet_Lines__c>  importScheduleOfValueItems(List<String> Id,  String recordId,boolean isCommunity){
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        
        
        
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
        
        system.debug(sheetId);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+Id);
        system.debug('sheetId'+sheetId);
        system.debug('sheet'+sheetId.ID);
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c, buildertek__Total_Costs__c from buildertek__Schedule_of_Values__c where Id IN: Id];
        
        List<String> sovIdList = new List<String>();
        
        
        //  Code for  aggrigate total sum from SOV into payment app original contract   --  start
        List<buildertek__SOV_Payment_Application__c> newPaymentApp = [select Id, Name, buildertek__Original_Contract_Sum__c from buildertek__SOV_Payment_Application__c where Id =:recordId limit 1];
        system.debug('new Payment App----->'+newPaymentApp);
        
        List<AggregateResult> result = [SELECT SUM(buildertek__Total_Costs__c)totalCost FROM buildertek__Schedule_of_Values__c
                                        WHERE Id IN: Id];
        system.debug('********decodedPassword:' + result);
        if(!newPaymentApp.isEmpty()){
            for(AggregateResult agg : result){
                newPaymentApp[0].buildertek__Original_Contract_Sum__c = (decimal)agg.get('totalCost'); 
            }
            
            update newPaymentApp;
        }
        
        
        //  Code for  aggrigate total sum from SOV into payment app original contract   --  end
        
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
                         WHERE buildertek__Schedule_of_Values__c IN :Id AND buildertek__Status__c = 'Approved'];
        system.debug(masterRFQList);
        system.debug(masterRFQList.size());
        list<buildertek__Schedule_of_Value_Lines__c> masterRFQListClone = new list<buildertek__Schedule_of_Value_Lines__c>(); 
        System.debug('<<<<<======= masterRFQList =====>>>>>>'+masterRFQList);
        for(buildertek__Schedule_of_Value_Lines__c pc:masterRFQList){
            system.debug(pc);
            if(Id.contains(pc.buildertek__Schedule_of_Values__c)){
                system.debug(pc.Id);
                masterRFQListClone.add(pc);
            }
        }                  
        
        for (buildertek__Schedule_of_Value_Lines__c masterRFQItem : masterRFQListClone){
            system.debug(masterRFQItem.buildertek__Description_of_Work__c);
            buildertek__SOV_Continuation_Sheet_Lines__c rfqItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
            if(masterRFQItem.buildertek__Description_of_Work__c != null){
                rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                rfqItem.Name =masterRFQItem.buildertek__Description_of_Work__c;
            }else{
                rfqItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                rfqItem.Name = 'Continuation Sheet Lines';
            }
            if(portalCode == 'true'){
                rfqItem.buildertek__Scheduled_Value__c = masterRFQItem.buildertek__Scheduled_Value__c ;
            }
            else{
                rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
            }
            
            system.debug('2222222222222222->'+masterRFQItem.Id);
            
            rfqItem.buildertek__Vendor_SOV_Line_Id__c = masterRFQItem.Id;  
            
            
            rfqItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
            rfqItem.buildertek__Item_No__c= Integer.ValueOf( masterRFQItem.buildertek__Item__c );
            masterRFQItemToInsert.add(rfqItem);
           // itemInc++;
        }
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
        return masterRFQItemToInsert;
    }
    @AuraEnabled
    public static RfqDataTableWrapper getmasterScheduleOValues(Integer pageNumber, Integer pageSize){
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        
        
        
        
        
        objDT.recordList = [SELECT Id, Name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Project__c,buildertek__Project__r.Name
                            FROM buildertek__Schedule_of_Values__c
                            WHERE recordtype.name = 'Master' ORDER BY Name 
                            LIMIT :pageSize
                            OFFSET :offset];  
        
        
        
        return objDT;
        
    }
    @AuraEnabled
    public static List<buildertek__Schedule_of_Values__c> getCompanyApprovedScheduleOValues(string projectId){
        
        system.debug('projectId----------->'+projectId);
        
        List<buildertek__Schedule_of_Values__c> CASOVsList = new  List<buildertek__Schedule_of_Values__c>();
        
        List<buildertek__Schedule_of_Values__c> companyApprovedSOVs  = new List<buildertek__Schedule_of_Values__c> (); 
        
        if(projectId != null && projectId != ''){
           companyApprovedSOVs  = [SELECT Id,Name,
                                buildertek__Project__c,
                                buildertek__Status__c,
                                buildertek__Type__c,
                                RecordTypeId, recordtype.name,
                                buildertek__Total_Costs__c,
                                buildertek__Project__r.Name
                                FROM buildertek__Schedule_of_Values__c
                                WHERE buildertek__Project__c =:projectId
                               ]; 
        }else{
          companyApprovedSOVs  = [SELECT Id,Name,
                                buildertek__Project__c,
                                buildertek__Status__c,
                                buildertek__Type__c,
                                RecordTypeId, recordtype.name,
                                buildertek__Total_Costs__c,
                                buildertek__Project__r.Name
                                FROM buildertek__Schedule_of_Values__c
                               ];  
        }
        
        
        for(buildertek__Schedule_of_Values__c sov : companyApprovedSOVs){
            if((sov.buildertek__Status__c == 'Company Approved' || sov.buildertek__Status__c == 'Customer Approved')){
                CASOVsList.add(sov);
            }
        }                                                             
        return CASOVsList;
        
        
    }
    
    
    @AuraEnabled
    public static List<buildertek__Schedule_of_Values__c> getCustomerApprovedScheduleOValues(string projectId){
        
        List<buildertek__Schedule_of_Values__c> CASOVsList = new  List<buildertek__Schedule_of_Values__c>();
        
        List<buildertek__Schedule_of_Values__c> companyApprovedSOVs = [SELECT Id,Name,
                                                                       buildertek__Project__c,
                                                                       buildertek__Status__c,
                                                                       buildertek__Type__c,
                                                                       RecordTypeId, recordtype.name,
                                                                       buildertek__Project__r.Name
                                                                       FROM buildertek__Schedule_of_Values__c
                                                                       WHERE buildertek__Project__c =:projectId
                                                                      ];
        for(buildertek__Schedule_of_Values__c sov : companyApprovedSOVs){
            if(sov.buildertek__Status__c == 'Customer Approved' &&  sov.recordtype.name == 'Standard' ){
                CASOVsList.add(sov);
            }
        }                                                             
        return CASOVsList;
        
        
    }
    
    
 @AuraEnabled
    public static string importCompanyApprovedSOVLines(List<String> Id,string recordId){
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                     buildertek__SOV_Continuation_Sheet__c,
                                                                     buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                     from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                     Where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: recordId ORDER BY buildertek__Item_No__c DESC];
      
        
       
        
        
        system.debug('lastSOV-------->'+lastSOV);
        integer itemInc = 100;
      
        system.debug('Id---------->'+Id);
        buildertek__SOV_Continuation__c sheetId = [select Id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__r.Id =: recordId limit 1];
        system.debug(Id);
        system.debug('sheetId'+sheetId);
        system.debug('sheet'+sheetId.ID);
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id IN: Id];
        buildertek__Schedule_of_Values__c newscheduleRec = new buildertek__Schedule_of_Values__c();
        
        List<String> Stat = new List<String>();
        String rectype = '';
        List<buildertek__Schedule_of_Values__c> schStatList = [select Id, RecordType.Name from buildertek__Schedule_of_Values__c where Id IN: Id];
        
        for(buildertek__Schedule_of_Values__c SV : schStatList){
            Stat.add(SV.RecordType.Name);
        }
        
        if(Stat.contains('Standard')){
            rectype = 'Standard';
        }else{
            rectype = 'Vendor';
        }
        
        
         buildertek__SOV_Payment_Application__c NewPa = [select Id, Name, buildertek__Is_Pay_App_Created_For__c from buildertek__SOV_Payment_Application__c where Id =: recordId];
        
        if(rectype == 'Standard'){
            NewPa.buildertek__Is_Pay_App_Created_For__c = 'FORCUSTOMERSOV';
        }else if(rectype == 'Vendor'){
            NewPa.buildertek__Is_Pay_App_Created_For__c = 'FORVENDORSOV';
        }
        
        
        
        update NewPa;
        
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> masterRFQItemToInsert = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        
        list<buildertek__SOV_Continuation_Sheet_Lines__c> masterConnSheetRecInsert = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        

        list<buildertek__Schedule_of_Value_Lines__c> masterRFQList;
        
        
        if(rectype == 'Standard'){
            masterRFQList = [SELECT Id,
                         Name,
                         buildertek__Description_of_Work__c,
                         buildertek__Schedule_of_Values__c,
                         buildertek__Scheduled_Value__c,
                         buildertek__Item__c,buildertek__Status__c,
                         buildertek__Schedule_of_Values__r.Name,
                         buildertek__Schedule_of_Values__r.RecordType.Name,
                         buildertek__Vendor_SOV_Line__c,
                         buildertek__Old_Sov_Line_Ids_From_Project__c
                         FROM buildertek__Schedule_of_Value_Lines__c
                         WHERE buildertek__Schedule_of_Values__c IN :Id AND (buildertek__Status__c = 'Pending' or buildertek__Status__c = 'Customer Approved') AND buildertek__Schedule_of_Values__r.RecordType.Name =:rectype ORDER BY buildertek__Item__c ASC];
        
        }else{
          masterRFQList = [SELECT Id,
                         Name,
                         buildertek__Description_of_Work__c,
                         buildertek__Schedule_of_Values__c,
                         buildertek__Scheduled_Value__c,
                         buildertek__Item__c,buildertek__Status__c,
                         buildertek__Schedule_of_Values__r.Name,
                         buildertek__Schedule_of_Values__r.RecordType.Name,
                         buildertek__Vendor_SOV_Line__c,
                         buildertek__Old_Sov_Line_Ids_From_Project__c
                         FROM buildertek__Schedule_of_Value_Lines__c
                         WHERE buildertek__Schedule_of_Values__c IN :Id AND (buildertek__Status__c = 'Approved' or buildertek__Status__c = 'Customer Approved') AND buildertek__Schedule_of_Values__r.RecordType.Name =:rectype ORDER BY buildertek__Item__c ASC];
          
        }
        
        
        set<String> sovLineIds = new set<String>();
        set<String> StandardsovLineIds = new set<String>();
        set<string> consolidatedIds = new set<string>();
        
        for (buildertek__Schedule_of_Value_Lines__c sovlineList : masterRFQList){
            if(sovlineList.buildertek__Old_Sov_Line_Ids_From_Project__c != null){
                if(sovlineList.buildertek__Old_Sov_Line_Ids_From_Project__c.contains(',')){
                    List<String> newList1 = sovlineList.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                    for(String s:newList1 ){
                        consolidatedIds.add(s);
                    }
                    
                }else{
                    sovLineIds.add(sovlineList.Id); 
                }
            } else{
                sovLineIds.add(sovlineList.Id);
                
            }
            
            if(sovlineList.buildertek__Vendor_SOV_Line__c != null){
                if(sovlineList.buildertek__Old_Sov_Line_Ids_From_Project__c == null){
                    StandardsovLineIds.add(sovlineList.buildertek__Vendor_SOV_Line__c);
                }
            }
        }
        map<string,string> stdsovLineconMap = new map<string,string>();
        if(!consolidatedIds.isEmpty()){
            list<buildertek__Schedule_of_Value_Lines__c> consolesovlist = [select Id, Name,buildertek__Vendor_SOV_Line__c from buildertek__Schedule_of_Value_Lines__c where Id IN: consolidatedIds ORDER BY buildertek__Item__c ASC];
            
            for (buildertek__Schedule_of_Value_Lines__c conl : consolesovlist){
                if(conl.buildertek__Vendor_SOV_Line__c != null){
                    StandardsovLineIds.add(conl.buildertek__Vendor_SOV_Line__c);
                   
                    stdsovLineconMap.put(conl.id,conl.buildertek__Vendor_SOV_Line__c);
                }
            }   
        }

        List<buildertek__SOV_Continuation_Sheet_Lines__c> SovConSheetLines = new  List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        if(rectype == 'Approved'){
            SovConSheetLines = [select Id, Name,
                                buildertek__Description_of_Work__c,
                                buildertek__Scheduled_Value__c,
                                buildertek__Item_No__c,
                                buildertek__SOV_Continuation_Sheet__c,
                                buildertek__Vendor_SOV_Line_Id__c,
                                buildertek__Vendor_Sheet_line_Id__c,
                                buildertek__Vendor_Work_Completed_This_Period__c,
                                buildertek__Work_Completed__c,
                                buildertek__Material_Presently_Stored__c,
                                buildertek__Vendor_Material_Presently_Stored__c,
                                buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Is_Pay_App_Created_For__c
                                from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__Vendor_SOV_Line_Id__c IN:sovLineIds AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c != null ORDER BY buildertek__Item_No__c ASC];
        }else{
            SovConSheetLines = [select Id, Name,
                                buildertek__Description_of_Work__c,
                                buildertek__Scheduled_Value__c,
                                buildertek__Item_No__c,
                                buildertek__SOV_Continuation_Sheet__c,
                                buildertek__Vendor_SOV_Line_Id__c,
                                buildertek__Vendor_Sheet_line_Id__c,
                                buildertek__Vendor_Work_Completed_This_Period__c,
                                buildertek__Work_Completed__c,
                                 buildertek__Material_Presently_Stored__c,
                                buildertek__Vendor_Material_Presently_Stored__c,
                                buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Is_Pay_App_Created_For__c
                                from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__Vendor_SOV_Line_Id__c IN:StandardsovLineIds AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c != null ORDER BY buildertek__Item_No__c ASC];
        }
         system.debug('SovConSheetLines---------->'+SovConSheetLines);
        
        
        
         List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorAddedConSheetLines = new  List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        
        
        
         
        set<String> sovImportedIds = new set<String>();
        map<string,buildertek__SOV_Continuation_Sheet_Lines__c> sovConMap = new map<string,buildertek__SOV_Continuation_Sheet_Lines__c>();
        system.debug('sovConMap-------->'+sovConMap);
        
        map<string,string> isSovInConMap = new map<string,string>();

        
        for (buildertek__SOV_Continuation_Sheet_Lines__c ConSheetLineList : SovConSheetLines){
            sovImportedIds.add(ConSheetLineList.buildertek__Vendor_SOV_Line_Id__c);
            sovConMap.put(ConSheetLineList.buildertek__Vendor_SOV_Line_Id__c,ConSheetLineList);
            isSovInConMap.put(ConSheetLineList.buildertek__Vendor_SOV_Line_Id__c, ConSheetLineList.Id);
 
        }
        system.debug('sovImportedIds-------->'+sovImportedIds);  

        set<String> newList = new set<String>();
        
        for (buildertek__Schedule_of_Value_Lines__c masterRFQItem : masterRFQList){
            buildertek__SOV_Continuation_Sheet_Lines__c rfqItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
            if(masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c == null){
                if(sovImportedIds.contains(masterRFQItem.buildertek__Vendor_SOV_Line__c)){
                   if(masterRFQItem.buildertek__Description_of_Work__c != null){
                        rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                        rfqItem.Name =masterRFQItem.buildertek__Description_of_Work__c;
                    }else{
                        rfqItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                        rfqItem.Name = 'Continuation Sheet Lines';
                    }
                    if(masterRFQItem.buildertek__Vendor_SOV_Line__c != null){
                        rfqItem.buildertek__Vendor_SOV_Line_Id__c = masterRFQItem.buildertek__Vendor_SOV_Line__c;
                    }
                    rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
                    rfqItem.buildertek__Item_No__c = itemInc;
                    rfqItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
                    masterRFQItemToInsert.add(rfqItem); 
                    itemInc++;

                }
                else{
                    if(masterRFQItem.buildertek__Description_of_Work__c != null){
                        rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                        rfqItem.Name =masterRFQItem.buildertek__Description_of_Work__c;
                    }else{
                        rfqItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                        rfqItem.Name = 'Continuation Sheet Lines';
                    }
                    if(masterRFQItem.buildertek__Vendor_SOV_Line__c != null){
                        rfqItem.buildertek__Vendor_SOV_Line_Id__c = masterRFQItem.buildertek__Vendor_SOV_Line__c;
                    }
                    rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
                    rfqItem.buildertek__Item_No__c = itemInc;
                    rfqItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
                    masterRFQItemToInsert.add(rfqItem); 
                    itemInc++;
                }
            }  else if(masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c != null ){
                system.debug('masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c9999999999>'+masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c);
                set<string> conLinelist = new set<string>();
                if(masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c.contains(',')){
                    List<String> newList1 = masterRFQItem.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                    for(String s:newList1 ){
                        conLinelist.add(s);
                    }
                }
                system.debug('conLinelist-------->'+conLinelist);
                for(string conl : conLinelist){
                    
                    buildertek__SOV_Continuation_Sheet_Lines__c conItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
                    
                    
                    string str1 = stdsovLineconMap.get(conl);
                    system.debug('sovConMap.get(str1)---------->'+sovConMap.get(str1));
                    if(sovConMap.get(str1) != null){
                        if(sovConMap.get(str1).buildertek__Description_of_Work__c != null){
                            conItem.buildertek__Description_of_Work__c =sovConMap.get(str1).buildertek__Description_of_Work__c;
                            conItem.Name =sovConMap.get(str1).buildertek__Description_of_Work__c;
                        }  else{
                            conItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                            conItem.Name = 'Continuation Sheet Lines';
                        } 
                    } 
                    system.debug('isSovInConMap.get(str1)---------->'+isSovInConMap.get(str1));
                    
                    
                    if(isSovInConMap.get(str1) != null){
                        conItem.buildertek__Work_Completed__c = sovConMap.get(str1).buildertek__Vendor_Work_Completed_This_Period__c;
                         conItem.buildertek__Material_Presently_Stored__c = sovConMap.get(str1).buildertek__Vendor_Material_Presently_Stored__c;
                        conItem.buildertek__Scheduled_Value__c=sovConMap.get(str1).buildertek__Scheduled_Value__c ; 
                    }
                    
                    conItem.buildertek__Vendor_SOV_Line_Id__c = isSovInConMap.get(str1);
                    conItem.buildertek__Vendor_Sheet_line_Id__c = isSovInConMap.get(str1);
                    
                    conItem.buildertek__Item_No__c = itemInc;
                    conItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
                    
                    if(!newList.contains(conItem.buildertek__Vendor_SOV_Line_Id__c)){
                        masterRFQItemToInsert.add(conItem); 
                        newList.add(conItem.buildertek__Vendor_SOV_Line_Id__c);
                        
                        system.debug('conItem--------->'+conItem);
                    }
                    itemInc++;
                    
                }
            }
            
            system.debug('masterRFQItemToInsert--------------------->'+masterRFQItemToInsert);
            system.debug('newList--------------->'+newList);
        }
        system.debug('masterRFQItemToInsert----------------->'+masterRFQItemToInsert);
        if (masterRFQItemToInsert.size() > 0){
            
            List<String> checkListIds = new List<String>();
            
            for(buildertek__SOV_Continuation_Sheet_Lines__c conSh : masterRFQItemToInsert){
                system.debug('conSh-------->'+conSh);
                buildertek__SOV_Continuation_Sheet_Lines__c conLine =  new buildertek__SOV_Continuation_Sheet_Lines__c();
                if(!checkListIds.contains(conSh.buildertek__Vendor_SOV_Line_Id__c) && conSh.buildertek__Vendor_SOV_Line_Id__c != null ){
                    system.debug('conSh1-------->'+conSh);
                    conLine = conSh;
                    masterConnSheetRecInsert.add(conLine);
                    checkListIds.add(conSh.buildertek__Vendor_SOV_Line_Id__c);
                }else if(String.isBlank(conSh.buildertek__Vendor_SOV_Line_Id__c)){
                    system.debug('conSh2-------->'+conSh);
                     conLine = conSh;
                     masterConnSheetRecInsert.add(conLine);
                }
            }
            
            insert masterConnSheetRecInsert;
            System.debug('returned List : '+masterRFQItemToInsert);
        }
        return 'success';
        
    }
    
    @AuraEnabled
    public static string importCustomerApprovedSOVLines(List<String> Id,string recordId){
        try{
            buildertek__SOV_Continuation__c sheetId = [select Id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__r.Id =: recordId limit 1];
            system.debug(Id);
            system.debug('sheetId'+sheetId);
            system.debug('sheet'+sheetId.ID);
            list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id IN: Id];
            buildertek__Schedule_of_Values__c newscheduleRec = new buildertek__Schedule_of_Values__c();
            
            list<buildertek__SOV_Continuation_Sheet_Lines__c> masterRFQItemToInsert = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
            list<buildertek__Schedule_of_Value_Lines__c> masterRFQList;
            masterRFQList = [SELECT Id,
                             Name,
                             buildertek__Description_of_Work__c,
                             buildertek__Schedule_of_Values__c,
                             buildertek__Scheduled_Value__c,
                             buildertek__Item__c,buildertek__Status__c,
                             buildertek__Schedule_of_Values__r.Name
                             FROM buildertek__Schedule_of_Value_Lines__c
                             WHERE buildertek__Schedule_of_Values__c IN :Id AND buildertek__Status__c = 'Customer Approved'];
            system.debug('@@@masterRFQList'+masterRFQList);
            for (buildertek__Schedule_of_Value_Lines__c masterRFQItem : masterRFQList){
                buildertek__SOV_Continuation_Sheet_Lines__c rfqItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
                rfqItem.buildertek__Status__c = 'Accepted';
                if(masterRFQItem.buildertek__Description_of_Work__c != null){
                    rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                    rfqItem.Name =masterRFQItem.buildertek__Description_of_Work__c;
                }else{
                    rfqItem.buildertek__Description_of_Work__c = 'Continuation Sheet Lines';
                    rfqItem.Name = 'Continuation Sheet Lines';
                }
                rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
                // rfqItem.buildertek__Item__c=masterRFQItem.buildertek__Item__c;
                rfqItem.buildertek__SOV_Continuation_Sheet__c = sheetId.ID;
                masterRFQItemToInsert.add(rfqItem);
            }
            if (masterRFQItemToInsert.size() > 0){
                insert masterRFQItemToInsert;
            }
            return 'success';
        }catch(exception exp){
            return 'error';
        }
        //return masterRFQItemToInsert;
        
    }
     
    @AuraEnabled
    public static RfqDataTableWrapper getapprovedScheduleOfValue(Integer pageNumber, Integer pageSize,string recordId){
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        buildertek__SOV_Payment_Application__c pa = [select id,buildertek__Project__c from buildertek__SOV_Payment_Application__c where id=:recordId];
        List<buildertek__Schedule_of_Values__c> approvedIdList = new List<buildertek__Schedule_of_Values__c>();
        List<buildertek__Schedule_of_Values__c> sov = [SELECT Id, Name, buildertek__Type__c, RecordTypeId, recordtype.name, buildertek__Project__c,buildertek__Status__c,buildertek__Project__r.Name, buildertek__Total_Costs__c
                                                       FROM buildertek__Schedule_of_Values__c where buildertek__Project__c =:pa.buildertek__Project__c];
        for(buildertek__Schedule_of_Values__c sc:sov){
            system.debug('app '+sc.id);
            if(sc.buildertek__Status__c == 'Company Approved'){
                system.debug('app '+sc.id);
                approvedIdList.add(sc);
            } 
        }
        
        objDT.recordList =approvedIdList;
        return objDT;
        
    }
    
    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<buildertek__Schedule_of_Values__c> recordList{ get; set; }
        
    }
    
    
    @AuraEnabled
    public static List<ListView> getListViews1() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__SOV_Payment_Application__c' and Name='All'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static String getParentProject(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    
   @AuraEnabled
    public static string importPaymentApps(List<string> idList,string paymentId){
        list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                     buildertek__SOV_Continuation_Sheet__c,
                                                                     buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c ,buildertek__Change_Order_Payment_Tracking__c
                                                                     from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                     Where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: paymentId ORDER BY buildertek__Item_No__c DESC];
        
        
        buildertek__SOV_Payment_Application__c NewPa = [select Id, Name, buildertek__Is_Pay_App_Created_For__c from buildertek__SOV_Payment_Application__c where Id =: paymentId];
        NewPa.buildertek__Is_Pay_App_Created_For__c = 'FORVENDORPAYAPPS';
        
        update NewPa; 
        
        
        
        system.debug('lastSOV-------->'+lastSOV);
        integer itemInc = 100;
        
        system.debug('lastSOV.size()--------->'+lastSOV.size());
        if(lastSOV.size() > 0){
            if(lastSOV[0].buildertek__Item_No__c != null){
                itemInc = Integer.valueOf(lastSOV[0].buildertek__Item_No__c)+1;
            }else if(lastSOV[1].buildertek__Item_No__c != null){
                itemInc = Integer.valueOf(lastSOV[1].buildertek__Item_No__c)+1;
            }
        }
        
        buildertek__SOV_Payment_Application__c paymentRec = [select id,Name,RecordType.Name, buildertek__Old_PA_Ids__c,
                                                             buildertek__Imported_Payment_IDs__c,
                                                             buildertek__Original_Contract_Sum__c,
                                                             buildertek__Total_Completed__c,
                                                             buildertek__Total_Material_Stored_To_Date__c
                                                             from buildertek__SOV_Payment_Application__c where Id =: paymentId];
        
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.buildertek__Imported_Payment_IDs__c= paymentRec.buildertek__Imported_Payment_IDs__c;
        payRec.buildertek__Original_Contract_Sum__c = paymentRec.buildertek__Original_Contract_Sum__c;
        payRec.buildertek__Total_Completed__c = paymentRec.buildertek__Total_Completed__c;
        payRec.buildertek__Total_Material_Stored_To_Date__c = paymentRec.buildertek__Total_Material_Stored_To_Date__c;
        payRec.id = paymentId;
        string ImportedPaymentIds = '';
        Integer i = 1;
        system.debug('idListsize-->'+idList.size());
        List<buildertek__SOV_Payment_Application__c> payList = [select id,Name,buildertek__Original_Contract_Sum__c,buildertek__Total_Completed__c,buildertek__Total_Material_Stored_To_Date__c from buildertek__SOV_Payment_Application__c where Id IN:idList];
        Decimal originalcontract = 0;
        Decimal totalCompleted = 0;
        Decimal Totalmaterialstored = 0;
        for(buildertek__SOV_Payment_Application__c pay:payList){
            if(pay.buildertek__Original_Contract_Sum__c != null){
                originalcontract += pay.buildertek__Original_Contract_Sum__c; 
            }
            if(pay.buildertek__Total_Completed__c != null){
                totalCompleted += pay.buildertek__Total_Completed__c;  
            }
            if(pay.buildertek__Total_Material_Stored_To_Date__c != null){
                Totalmaterialstored += pay.buildertek__Total_Material_Stored_To_Date__c;  
            }
        }

        for(string paId : idList){
            ImportedPaymentIds += paId+',';
            if(idList.size() == 1){
                payRec.buildertek__Old_PA_Ids__c = paId;
            }else if(i==1){
                payRec.buildertek__Old_PA_Ids__c = paId+'_';
                i++;
            }else if(idList.size() == i && i > 1){
                payRec.buildertek__Old_PA_Ids__c += paId;
            }else{
                payRec.buildertek__Old_PA_Ids__c += paId+'_';
                i++;
            }
            
        }
        if(payRec.buildertek__Imported_Payment_IDs__c != null){
            payRec.buildertek__Imported_Payment_IDs__c += ImportedPaymentIds;
        }else{
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
        List<buildertek__SOV_Continuation_Sheet_Lines__c> sovpList = [select Id,buildertek__SOV_Continuation_Sheet__c,
                                                                      buildertek__Description_of_Work__c,buildertek__Scheduled_Value__c,
                                                                      buildertek__Work_Completed_from_Previous_Application__c,
                                                                      buildertek__Work_Completed__c,buildertek__Material_Presently_Stored__c,
                                                                      buildertek__Total__c,buildertek__G_C__c, buildertek__Status__c,
                                                                      buildertek__Budget_Grouping__c,buildertek__Grouping__c,buildertek__Grouping2__c,
                                                                      buildertek__Vendor_Sheet_line_Id__c,buildertek__Change_Order_Payment_Tracking__c,
                                                                      buildertek__Change_Order__c
                                                                      from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                      where buildertek__Status__c = 'Accepted' and buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN: idList];
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> newLines = sovpList.clone();
        System.debug('newLines========>>>>>>'+newLines);
        buildertek__SOV_Continuation__c newSheetId = [select Id,buildertek__SOV_Payment_Application__c 
                                                      from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =:paymentId];
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> newSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        if(newLines.size()>0){
            for(buildertek__SOV_Continuation_Sheet_Lines__c lines : newLines){
                system.debug('lines.Id'+lines.Id);
                lines.buildertek__SOV_Continuation_Sheet__c = newSheetId.Id;
                lines.buildertek__Status__c = 'Pending';
                lines.buildertek__Budget_Grouping__c = lines.buildertek__Budget_Grouping__c;
                lines.buildertek__Is_Imported__c = true;
                lines.Name = lines.buildertek__Description_of_Work__c;
                lines.buildertek__Vendor_Sheet_line_Id__c = lines.Id;
                lines.buildertek__Item_No__c = itemInc;
                lines.buildertek__Change_Order_Payment_Tracking__c = lines.buildertek__Change_Order_Payment_Tracking__c;
                lines.buildertek__Change_Order__c = lines.buildertek__Change_Order__c;
                lines.id = null;
                newSheetLines.add(lines);
                itemInc++;
            }
            List<buildertek__SOV_Continuation_Sheet_Lines__c> DeleteSheetLines = [SELECT Id,Name
                                                                                  FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                  WHERE buildertek__SOV_Continuation_Sheet__c =:newSheetId.Id AND buildertek__Is_Imported__c = false];
            if(!DeleteSheetLines.isEmpty()){
                delete DeleteSheetLines;
            }
            insert newSheetLines;
        }
        List<buildertek__SOV_Payment_Application__c> paymentApps = [SELECT Id,
                                                                    buildertek__Is_Imported__c
                                                                    FROM buildertek__SOV_Payment_Application__c
                                                                    WHERE Id IN:idList];
        for(buildertek__SOV_Payment_Application__c pay:paymentApps){
            pay.buildertek__Is_Imported__c = true; 
            
        }
        update paymentApps;

        return 'Success';
    }
        
    
    @AuraEnabled
    public static List<ListView> getPaymentListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__SOV_Payment_Application__c'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    
    @AuraEnabled
    public static string GivingSharingForMasterSov(string recordId) {
        List<buildertek__Schedule_of_Values__Share> rfqshareList=new List<buildertek__Schedule_of_Values__Share>();
        list<buildertek__Schedule_of_Values__c> SOVRec = [Select id, Name, buildertek__Type__c,RecordTypeId, recordtype.name,buildertek__Status__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id =:recordId AND (recordtype.name = 'Master' OR buildertek__Status__c = 'Company Approved') limit 1];
        system.debug('SOV Rec  ----> '+ SOVRec);
        
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
        
        system.debug('vendorUserMap'+vendorUserMap);
        system.debug('usersList--------------->'+ usersList);
        
        if(!SOVRec.isEmpty()){
            for(User usr1: usersList){
                system.debug('usrrec--->'+usersList ); 
                if(SOVRec[0].recordtype.name == 'Master' || SOVRec[0].buildertek__Status__c == 'Company Approved'){
                    if(SOVRec[0].buildertek__Vendor__c == usr1.AccountId || SOVRec[0].buildertek__Vendor__c == null){
                        buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                        rfqshare.ParentId= SOVRec[0].Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                    
                }
            } 
        }
        
        //  User usrrec = vendorUserMap.get(SOVRec.buildertek__Vendor__c);

        system.debug('rfqshareList -------> '+rfqshareList);
        if(rfqshareList.size()>0){
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
        }
        return 'success';
    }
    
    
    
    @AuraEnabled
    public static List<buildertek__Schedule_of_Values__c> getVendorSovList(String recordId){
        buildertek__Schedule_of_Values__c bsc = [select id,buildertek__Project__c from buildertek__Schedule_of_Values__c where id=:recordId];
        List<buildertek__Schedule_of_Values__c> vendorSOVList = [SELECT Id, Name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Project__c,buildertek__Project__r.Name,buildertek__Status__c
                                                                 FROM buildertek__Schedule_of_Values__c
                                                                 WHERE buildertek__Project__c =:bsc.buildertek__Project__c AND recordtype.name = 'Vendor'  AND (buildertek__Status__c = 'Vendor Submitted' OR buildertek__Status__c ='Company Approved') ORDER BY Name]; 
        if(!vendorSOVList.isEmpty()){
            return vendorSOVList;
        }else{
            return null;
        } 
    }
    
    
    @AuraEnabled
    public static String getRecordTypeName(String recTypeId){
        RecordType sovRecordType = [select Id,Name from RecordType where Id =: recTypeId];
        return sovRecordType.Name;
    }
    
    
    @AuraEnabled
    public static String getSovType(){
        RecordType recTypeId = [select Id,Name from RecordType where sObjectType ='buildertek__SOV_Payment_Application__c' AND RecordType.Name = 'AP'];
        return recTypeId.Id;
    }
    
    
    @AuraEnabled
    public static String getARSovType(){
        RecordType recTypeId = [select Id,Name from RecordType where sObjectType ='buildertek__SOV_Payment_Application__c' AND RecordType.Name = 'AR'];
        return recTypeId.Id;
    }
    
    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
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
    public static buildertek__SOV_Payment_Application__c getPARecord(String recordId){
        
        buildertek__SOV_Payment_Application__c a = [select id from buildertek__SOV_Payment_Application__c where id =:recordId];
        return a;
    }

    @AuraEnabled
    public static buildertek__Admin_Interface_Node_Configuration__c getPaymentTypeDetails(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id, 
                                                                                                    buildertek__New_Payment_Application__c,
                                                                                                    buildertek__Import_Company_Accepted_Vendor_Payment_A__c, 
                                                                                                    buildertek__Import_Approved_SOV_s_Payment_Apps__c
                                                                                                    FROM buildertek__Admin_Interface_Node_Configuration__c 
                                                                                                    WHERE Name=:'Payment Application Configuration'];
        return adminInterfaceNodeConfigurations;
    }
    
}