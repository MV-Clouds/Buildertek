public class ViewVendorPaymentApplicationController {
    
    
    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
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
    public static InnerClass getUser(){
        Boolean currencyEnable = UserInfo.isMultiCurrencyOrganization();
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        
        system.debug('postel code'+ portalCode);
        InnerClass inn = new InnerClass();
        inn.userRecord = userRec[0];
        inn.isCurrencyEnabled = currencyEnable;
        return  inn ;
    }
     public class InnerClass{
        @AuraEnabled
        public User userRecord {get;set;}
        @AuraEnabled
        public Boolean isCurrencyEnabled {get;set;}
        
    } 
    
    @AuraEnabled
    public static ResponseWrapper createSheetLines(list<buildertek__Schedule_of_Value_Lines__c> SovLineValues, String recordId, String vendorId){
    
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_SOV__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'SOV Configuration'];
        
        buildertek__Schedule_of_Values__c stndSOV = [select Id, Name, recordtype.name,buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id =:recordId ];
        
        list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c, buildertek__Vendor_Scheduled_Value__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ];
        
        integer itemInc = 100;
      
        
        ResponseWrapper RC = new ResponseWrapper();
        
        // to check is community true
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug('SovLineValues---->'+SovLineValues);
        
        Set<Id> SOVId=new Set<Id>();
        List<Id> sovLineIds = new List<Id> ();
        for(buildertek__Schedule_of_Value_Lines__c lines: lastSOV){
            SOVId.add(lines.buildertek__Schedule_of_Values__c);
            sovLineIds.add(lines.Id);
        }
        
        integer  ItNumber = 100;
       
        Boolean isNew = false;
        
        List<buildertek__Schedule_of_Value_Lines__c> sovLinesList = new  List<buildertek__Schedule_of_Value_Lines__c>();
       
            sovLinesList=[SELECT Id, Name,buildertek__Scheduled_Value__c, buildertek__Description_of_Work__c, 
                          buildertek__Schedule_of_Values__c, buildertek__Item__c,buildertek__Vendor_Scheduled_Value__c, 
                          buildertek__Schedule_of_Values__r.buildertek__Vendor__c,
                          buildertek__Status__c, buildertek__Vendor__c 
                          FROM buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId and buildertek__Status__c = 'Approved'];
        
        system.debug('sovLinesList-->'+sovLinesList);
        //try{
            List<buildertek__Schedule_of_Value_Lines__c> continuationSheetLinesList = new List<buildertek__Schedule_of_Value_Lines__c>();
            
            list<buildertek__Schedule_of_Values__c> sovStatus = new list<buildertek__Schedule_of_Values__c>();
            
        system.debug('SovLineValues------------->'+SovLineValues);
            for(buildertek__Schedule_of_Value_Lines__c coItem : SovLineValues){
                
                buildertek__Schedule_of_Value_Lines__c continuationSheetLines = new buildertek__Schedule_of_Value_Lines__c();
                
                continuationSheetLines.Id = coItem.Id;
                continuationSheetLines.buildertek__Description_of_Work__c = coItem.buildertek__Description_of_Work__c;
                
                if(portalCode == 'true'){
                    continuationSheetLines.buildertek__Vendor__c = vendorId;
                }
                if(coItem.buildertek__Schedule_of_Values__c == null){
                    continuationSheetLines.buildertek__Schedule_of_Values__c = recordId;
                }
                
                if(portalCode == 'true'){
                    
                    if(coItem.buildertek__Vendor_Scheduled_Value__c != null){
                        continuationSheetLines.buildertek__Vendor_Scheduled_Value__c = coItem.buildertek__Vendor_Scheduled_Value__c;
                    } else{
                        continuationSheetLines.buildertek__Vendor_Scheduled_Value__c = null;
                    }
                   
                    continuationSheetLines.buildertek__Item__c = String.valueOf(itemInc);
                    itemInc++;
                    system.debug('tttttttttttttt->'+continuationSheetLines);
                    system.debug('qqqqqqqqqqqqqqqqqqqqqq->'+continuationSheetLines.buildertek__Item__c);
                    
                }else{
                    system.debug('coItem.buildertek__Scheduled_Value__c--->'+coItem.buildertek__Scheduled_Value__c);
                    if(coItem.buildertek__Scheduled_Value__c != null){
                        continuationSheetLines.buildertek__Scheduled_Value__c = coItem.buildertek__Scheduled_Value__c;
                    } else{
                        continuationSheetLines.buildertek__Scheduled_Value__c = null;
                    }
                    if(coItem.buildertek__Item__c ==null || coItem.buildertek__Item__c  == '' ){
                        if(ItNumber == 100){
                            continuationSheetLines.buildertek__Item__c = String.valueOf(ItNumber);
                            
                        }else{
                            continuationSheetLines.buildertek__Item__c = String.valueOf(ItNumber+1);
                            
                        }
                        isNew = true;
                    } 
                    if(isNew){
                        continuationSheetLines.buildertek__Item__c = String.valueOf(itemInc);
                    }

                    system.debug('nullitem num-------->'+coItem.buildertek__Item__c);                    
                   if(coItem.buildertek__Item__c != null && coItem.buildertek__Item__c  != ''){
                        ItNumber = integer.valueOf(coItem.buildertek__Item__c); 
                    }
                    itemInc++;
                    system.debug('vendorname-------------->'+coItem.buildertek__Schedule_of_Values__r.buildertek__Vendor__c);
                    
                    if(coItem.buildertek__Schedule_of_Values__r.buildertek__Vendor__c != null){
                    continuationSheetLines.buildertek__Vendor__c = coItem.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name;
                    }
                    else{
                       
                            if(stndSOV.RecordType.Name == 'Standard'){
                                continuationSheetLines.buildertek__Vendor__c = adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
                            }
                      
                    }
                }
                
                if(portalCode == 'true'){
                    if(coItem.buildertek__Status__c != 'Approved' && coItem.buildertek__Status__c != 'Vendor Submitted'){
                        continuationSheetLinesList.add(continuationSheetLines);
                    }
                }
                
                else{
                    continuationSheetLinesList.add(continuationSheetLines);
                }
               
                system.debug(continuationSheetLinesList);
            }
        
        
        system.debug('sovLinesList------------------->'+sovLinesList);
        if(stndSOV.RecordType.Name ==  'Standard'){
            if(!sovLinesList.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c csItem : sovLinesList){
                    csItem.buildertek__Item__c = String.valueOf(itemInc);
                    itemInc++;
                    continuationSheetLinesList.add(csItem);
                }
            }
        }
        
        
        
        
            system.debug('continuationSheetLinesList.size----'+continuationSheetLinesList);
            if(continuationSheetLinesList.size() > 0){
                system.debug(continuationSheetLinesList.size());
                upsert continuationSheetLinesList;
                system.debug('&&'+continuationSheetLinesList);
            }
            RC.Status = 'Success';
            RC.Message = 'Schedule Of Value Lines added successfully';
            
        
        //}
        /*catch(exception exp){
            RC.Status = 'Error';
            RC.Message = exp.getMessage();
        } */
        return RC;
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
    
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Schedule_of_Values__c' and Name='All'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    
    @AuraEnabled
    public static List<buildertek__Schedule_of_Value_Lines__c> getSovLines(string recordId) {
        string insertedSOVLinesString = '';
        string currentStatus = 'Pending';
        string approvedStatus = 'Customer Approved';
        buildertek__Schedule_of_Values__c bsc = [SELECT Id,buildertek__Type__c, RecordTypeId, recordtype.name  from buildertek__Schedule_of_Values__c where id=:recordId];
        if(bsc.recordtype.name == 'Standard'){
            if(UserInfo.isMultiCurrencyOrganization()){  
                insertedSOVLinesString = 'SELECT Id,Name,CurrencyIsoCode,buildertek__Description_of_Work__c,LastModifiedDate ,buildertek__Vendor_Scheduled_Value__c, buildertek__Item__c,buildertek__Item_New__c,buildertek__Scheduled_Value__c,buildertek__Schedule_of_Values__r.buildertek__Status__c,buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,buildertek__Schedule_of_Values__c,buildertek__Vendor__c,buildertek__Status__c,buildertek__Rejection_Reason__c,buildertek__Vendor__r.Name,buildertek__Vendor_Item_Number_New__c, buildertek__Schedule_of_Values__r.buildertek__Vendor_Total_CostsTotal_Costs__c  FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: recordId AND (buildertek__Status__c =:currentStatus or buildertek__Status__c =:approvedStatus) AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, buildertek__Vendor__r.Name ASC ';
            }else{
                insertedSOVLinesString = 'SELECT Id,Name,buildertek__Description_of_Work__c, LastModifiedDate ,buildertek__Item__c,buildertek__Vendor_Scheduled_Value__c,buildertek__Item_New__c,buildertek__Scheduled_Value__c,buildertek__Schedule_of_Values__r.buildertek__Status__c,buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,buildertek__Schedule_of_Values__c,buildertek__Vendor__c,buildertek__Status__c,buildertek__Rejection_Reason__c,buildertek__Vendor__r.Name,buildertek__Vendor_Item_Number_New__c, buildertek__Schedule_of_Values__r.buildertek__Vendor_Total_CostsTotal_Costs__c FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: recordId AND buildertek__Status__c =:currentStatus or buildertek__Status__c =:approvedStatus) AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, buildertek__Vendor__r.Name ASC';
                
            }
            
        }else{
            if(UserInfo.isMultiCurrencyOrganization()){  
                insertedSOVLinesString = 'SELECT Id,Name,CurrencyIsoCode,buildertek__Description_of_Work__c, LastModifiedDate ,buildertek__Vendor_Scheduled_Value__c, buildertek__Item__c,buildertek__Item_New__c,buildertek__Scheduled_Value__c,buildertek__Schedule_of_Values__r.buildertek__Status__c,buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,buildertek__Schedule_of_Values__c,buildertek__Vendor__c,buildertek__Status__c,buildertek__Rejection_Reason__c,buildertek__Vendor__r.Name,buildertek__Vendor_Item_Number_New__c, buildertek__Schedule_of_Values__r.buildertek__Vendor_Total_CostsTotal_Costs__c  FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: recordId AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, buildertek__Vendor__r.Name ASC';
            }else{
                insertedSOVLinesString = 'SELECT Id,Name,buildertek__Description_of_Work__c,buildertek__Item__c, LastModifiedDate , buildertek__Vendor_Scheduled_Value__c,buildertek__Item_New__c,buildertek__Scheduled_Value__c,buildertek__Schedule_of_Values__r.buildertek__Status__c,buildertek__Schedule_of_Values__r.buildertek__Total_Costs__c,buildertek__Schedule_of_Values__c,buildertek__Vendor__c,buildertek__Status__c,buildertek__Rejection_Reason__c,buildertek__Vendor__r.Name,buildertek__Vendor_Item_Number_New__c, buildertek__Schedule_of_Values__r.buildertek__Vendor_Total_CostsTotal_Costs__c FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: recordId AND buildertek__isConsolidated__c = false ORDER BY buildertek__Item__c ASC, buildertek__Vendor__r.Name ASC';
                
            }
        }
        
        //List<buildertek__Schedule_of_Value_Lines__c> insertedSOVLines = new List<buildertek__Schedule_of_Value_Lines__c>();
        
        
        List<buildertek__Schedule_of_Value_Lines__c> insertedSOVLines = Database.query(insertedSOVLinesString);
        system.debug('insertedSOVLines--'+insertedSOVLines);
        return insertedSOVLines;
    }
    
    
    
    @AuraEnabled
    public static string deletesheetline(List<String> sheetlineIds, String recordId){
        List<buildertek__Schedule_of_Value_Lines__c> sheetlineslist = new List<buildertek__Schedule_of_Value_Lines__c>();
        for (string lineId : sheetlineIds){
            buildertek__Schedule_of_Value_Lines__c sheetlinerec = new buildertek__Schedule_of_Value_Lines__c();
            sheetlinerec.Id = lineId;
            sheetlineslist.add(sheetlinerec);
        }
        try{
            // if (buildertek__SOV_Continuation_Sheet_Lines__c.sObjectType.getDescribe().isDeletable()){
            delete sheetlineslist;
            // }
           
            system.debug('recordId---------->qw'+recordId);
            integer itemInc = 100;
            list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c, buildertek__Vendor_Scheduled_Value__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ORDER BY buildertek__Item__c ASC];
           
            system.debug('kdhgwlastSOV--------->'+lastSOV);
            
            if(!lastSOV.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c SV : lastSOV){
                    SV.buildertek__Item__c = String.valueOf(itemInc);
                    itemInc++;
                }
                update lastSOV; 
                system.debug('lastSOV--------->'+lastSOV);
            }            
            
            
            
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    
    @AuraEnabled
    public static String submitSOVForView(String recordId, date todayDate){
        system.debug(recordId);
        system.debug('date'+todayDate);
        system.debug('todayDate'+System.now());
        
        buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Type__c,RecordTypeId, recordtype.name,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id =:recordId];
        system.debug(updateStatus);
        updateStatus.buildertek__Status__c = 'Vendor Submitted';
        updateStatus.recordtype.name = 'Vendor';
        updateStatus.buildertek__Date_Submitted__c = todayDate;
        
        update updateStatus;
        system.debug('updates status ------> '+ updateStatus);
        return 'success';
    }
    
    
    @AuraEnabled
    public static String isSovSubmitted(String recordId){
        system.debug(recordId);
        if(recordId != null){
            buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id =:recordId];
            system.debug(updateStatus);
            //  updateStatus.buildertek__Status__c = 'Vendor Submitted';
            
            system.debug('updates status ------> '+ updateStatus);
            return updateStatus.buildertek__Status__c;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static String getSOVName(string recordId){
        buildertek__Schedule_of_Values__c consSovLines = [select Id, Name from buildertek__Schedule_of_Values__c    WHERE Id =:recordId];
        return consSovLines.Name;
    }
    @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSovforCurrency(string recordId) {
        string insertedSOVString = '';
        if(UserInfo.isMultiCurrencyOrganization()){
            insertedSOVString = 'SELECT Id,Name,CurrencyIsoCode FROM buildertek__Schedule_of_Values__c WHERE ID =:recordId';
        }else{
            insertedSOVString = 'SELECT Id,Name FROM buildertek__Schedule_of_Values__c WHERE ID =:recordId';
        }
        buildertek__Schedule_of_Values__c sov =  Database.query(insertedSOVString);
        return sov;
    }
    @AuraEnabled
    public static List<buildertek__Schedule_of_Value_Lines__c> getSOVlineslistbyType(String SOVId,String filter){
       List<buildertek__Schedule_of_Value_Lines__c> sovLineList = new List<buildertek__Schedule_of_Value_Lines__c>();
    
    if(filter == 'All'){
       sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Vendor_Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE buildertek__Schedule_of_Values__c =: SOVId AND buildertek__isConsolidated__c = false ORDER BY buildertek__Status__c DESC];
          
    
    }else{
    sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Vendor_Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE buildertek__Schedule_of_Values__c =: SOVId AND buildertek__Status__c=:filter AND buildertek__isConsolidated__c = false  ORDER BY buildertek__Status__c DESC];
          
    }
      return sovLineList;   
    }

    
    @AuraEnabled 
    public static String delSlctRec(List<String> slctRec, string recordId)
    {
        List<buildertek__Schedule_of_Value_Lines__c> sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Vendor_Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE Id IN : slctRec];
        
       try{
           delete sovLineList;
           
           
           
           system.debug('recordId---------->qw'+recordId);
           integer itemInc = 100;
           list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c, buildertek__Vendor_Scheduled_Value__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ORDER BY buildertek__Item__c ASC];
           
           system.debug('kdhgwlastSOV--------->'+lastSOV);
           
           if(!lastSOV.isEmpty()){
               for(buildertek__Schedule_of_Value_Lines__c SV : lastSOV){
                   SV.buildertek__Item__c = String.valueOf(itemInc);
                   itemInc++;
               }
               update lastSOV;   
           } 
           
           
           
           
           
           } catch(Exception ex)
          {
             throw new AuraHandledException(ex.getMessage());
          }
          return 'deleted';
       
    }
    
    
    
        @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSovType(String recordId){
        
        buildertek__Schedule_of_Values__c SOVType = [select Id, Name,buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c from buildertek__Schedule_of_Values__c WHERE Id =: recordId];
        
        return SOVType;
    }
    
    
    
      @AuraEnabled
    public static  List<SOVWrapper>  getSOVs(String recordId){       
        
        buildertek__Schedule_of_Values__c mainRecord = [select Id, buildertek__Project__c from buildertek__Schedule_of_Values__c where Id =: recordId];
        
           String projectId = mainRecord.buildertek__Project__c;
            
        List<SOVWrapper> SOVWrapperList = new List<SOVWrapper>();        
       
        list<buildertek__Schedule_of_Values__c> sovsList = [ SELECT Id,
                                                            Name, buildertek__Project__c, 
                                                            buildertek__Project__r.Name,
                                                            buildertek__Type__c,RecordTypeId, recordtype.name,
                                                            buildertek__Date_Submitted__c, 
                                                            buildertek__Vendor__c,
                                                            buildertek__Status__c ,(SELECT Id, Name, 
                                                                                    buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c,
                                                                                    buildertek__Schedule_of_Values__r.Name, 
                                                                                    buildertek__Item__c, buildertek__Description_of_Work__c ,
                                                                                    buildertek__Vendor__c, buildertek__Vendor__r.Name
                                                                                    FROM buildertek__Schedule_of_Values_Lines__r where  buildertek__Status__c='Approved')
                                                            FROM buildertek__Schedule_of_Values__c  
                                                            where  buildertek__Status__c='Company Approved'  AND buildertek__Project__c =: projectId AND recordtype.name = 'Vendor'
                                                           ];
        integer i=1;
        // integer j=1;
        
        if(sovsList.size() > 0){
            for(buildertek__Schedule_of_Values__c rec : sovsList){
                SOVWrapper obj = new SOVWrapper();
                obj.RowNumber = i;
                obj.RecordId = rec.Id;
                system.debug(obj.RecordId); 
                obj.Name = rec.Name;
                obj.Project = rec.buildertek__Project__r.Name;
                obj.DateSubmitted = rec.buildertek__Date_Submitted__c;
                obj.Status = rec.buildertek__Status__c; 
                obj.vendorName = rec.buildertek__Vendor__c;
                obj.expanded = false; 
                integer j=1;
                
                List<SOVLinesWrapper> SOVLinesList = new List<SOVLinesWrapper>(); 
                String vName = '';
                for(buildertek__Schedule_of_Value_Lines__c lines : rec.buildertek__Schedule_of_Values_Lines__r){
                    SOVLinesWrapper sovLi = new SOVLinesWrapper();
                    sovLi.RowNumber = j;
                    sovLi.RecordId = lines.Id;
                    sovLi.Name = lines.Name;
                    sovLi.ScheduleOfValues = rec.Id;
                    sovLi.Item = lines.buildertek__Item__c;
                    sovLi.Description = lines.buildertek__Description_of_Work__c ;
                    sovLi.ScheduleValue = lines.buildertek__Scheduled_Value__c;
                    sovLi.expanded = false;
                    if(lines.buildertek__Vendor__c != null){
                        vName = lines.buildertek__Vendor__r.Name; 
                      sovLi.vendorName = lines.buildertek__Vendor__r.Name;  
                    }
                    
                    SOVLinesList .add(sovLi);
                    
                    j=j+1;
                }
                obj.vendorName = vName;
                obj.sovlinesList= SOVLinesList;
                SOVWrapperList.add(obj);  
                
                i++;
            }
        } 
        system.debug(SOVWrapperList.size());
        
        system.debug('SOVWrapperList'+SOVWrapperList);
        
        return SOVWrapperList;
        
    }
    
    
    public class SOVWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String Name;
        @AuraEnabled public String Project;
        @AuraEnabled public String Type;
        @AuraEnabled public Datetime DateSubmitted;
        @AuraEnabled public String Status; 
        @AuraEnabled public boolean isChecked=false; 
        @AuraEnabled public boolean expanded;
        @AuraEnabled public String vendorName;
        
        @AuraEnabled public list<SOVLinesWrapper> sovlinesList;
        
        
    } 
    
        public class SOVLinesWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String Name;
        @AuraEnabled public decimal ScheduleValue;
        @AuraEnabled public String ScheduleOfValues;
        @AuraEnabled public String Item;
        @AuraEnabled public String Description;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public String vendorName;
    } 
    
    
     @AuraEnabled
    public static Integer createSOVLines(List<String> selectedSOV, String newSOV){  
        
        
        list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: newSOV ORDER BY buildertek__Item__c DESC ];
            
            integer itemInc = 100;
            
            if(lastSOV.size() > 0){
               itemInc = Integer.valueOf(lastSOV[0].buildertek__Item__c)+1;
            }
            
        
        Integer itemno=1;
        System.debug('List of SOV Ids-----------------------------------   '+selectedSOV);
         System.debug('New SOV Id-----------------------------------   '+newSOV);
        Set<Id> sovIDs=new Set<Id>();
         list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,
                                                                 buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c 
                                                                 where Id IN:selectedSOV];
        if(updateStatus.size()>0){
        for(buildertek__Schedule_of_Values__c SOV:updateStatus){
            sovIDs.add(SOV.Id);
        }
        }
        
        system.debug('sovIDs----->'+sovIDs);
        
         list<buildertek__Schedule_of_Value_Lines__c> sovlinesList = [ SELECT Id, 
                                                                      Name, buildertek__Scheduled_Value__c,
                                                                      buildertek__Schedule_of_Values__c,
                                                                      buildertek__Schedule_of_Values__r.Name,
                                                                      buildertek__Status__c,
                                                                      buildertek__Vendor__c,
                                                                      buildertek__Vendor_SOV_Line__c,
                                                                      buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                      buildertek__Item__c, buildertek__Description_of_Work__c,
                                                                      buildertek__Item_New__c
                                                                      FROM buildertek__Schedule_of_Value_Lines__c where   buildertek__Schedule_of_Values__c In:sovIDs AND buildertek__Status__c = 'Approved'];
        
         list<buildertek__Schedule_of_Value_Lines__c> newsovlinesList = new list<buildertek__Schedule_of_Value_Lines__c>(); 
        system.debug('sovlinesList.size() --->' +sovlinesList.size());
        
        if(sovlinesList.size()>0){
            for(buildertek__Schedule_of_Value_Lines__c SOVLines : sovlinesList){
                buildertek__Schedule_of_Value_Lines__c newsovline = new buildertek__Schedule_of_Value_Lines__c(); 
                newsovline.buildertek__Schedule_of_Values__c=newSOV;
                
                
                
                newsovline.buildertek__Item__c=String.valueOf(itemInc);
                newsovline.buildertek__Vendor__c=SOVLines.buildertek__Vendor__c;
                newsovline.buildertek__Scheduled_Value__c = SOVLines.buildertek__Scheduled_Value__c;
                newsovline.buildertek__Description_of_Work__c=SOVLines.buildertek__Description_of_Work__c;
                newsovline.buildertek__Status__c='Pending';
                newsovline.buildertek__Vendor_SOV_Line__c = SOVLines.Id;
                newsovlinesList.add(newsovline);
                itemno++;
                itemInc++;
            }
        }
        
        system.debug('newsovlinesList--->'+newsovlinesList.size());
        
        if(newsovlinesList.size()>0){
            insert newsovlinesList;
        }
         return sovlinesList.size();
    }
    
}