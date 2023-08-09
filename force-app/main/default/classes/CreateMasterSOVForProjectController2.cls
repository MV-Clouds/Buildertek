public class CreateMasterSOVForProjectController2 {
        
@AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
    
    @AuraEnabled
    public static String getProjectName(string projectId){
        buildertek__Project__c consSovLines = [select Id, Name from buildertek__Project__c    WHERE Id =:projectId];
        return consSovLines.Name;
    }
    
     @AuraEnabled
    public static String deleteSovLines(List<string> recIds){
       List<buildertek__Schedule_of_Value_Lines__c> consSovLines = [select Id, Name from buildertek__Schedule_of_Value_Lines__c    WHERE Id IN: recIds];
        if(!consSovLines.isEmpty()){
            delete consSovLines;
            return 'success';
        }else{
           return 'Error'; 
        }
    }
    
    @AuraEnabled
    public static String getItemNumber(string recordId){
        Integer AutoitemNumber;
        List<buildertek__Schedule_of_Value_Lines__c> consSovLines = [select Id, Name, 
                                                                buildertek__Item__c,
                                                                buildertek__Schedule_of_Values__c
                                                                from buildertek__Schedule_of_Value_Lines__c
                                                                where buildertek__Schedule_of_Values__c  =: recordId ORDER BY buildertek__Item__c DESC];
        if(consSovLines.size() > 0){
            if(consSovLines[0].buildertek__Item__c != null){
                 AutoitemNumber = Integer.valueOf(consSovLines[0].buildertek__Item__c)+1;
            }else{
               AutoitemNumber = 100; 
            }
        }
        return ''+AutoitemNumber;
            }
    
    @AuraEnabled
    public static String getManageSovName(string sovId){
        buildertek__Schedule_of_Values__c consSovLines = [select Id, Name from buildertek__Schedule_of_Values__c WHERE Id =:sovId];
        return consSovLines.Name;
    }
    
    @AuraEnabled
    public static String deleteSovlineData(list<string> recordId){
        list<buildertek__Schedule_of_Value_Lines__c> consSovLines = [select Id, Name from buildertek__Schedule_of_Value_Lines__c WHERE Id IN:recordId];
        delete consSovLines;
        return 'Success';
    }
 
    @AuraEnabled
    public static Decimal getManageSovsTotal(string sovId){
        Decimal TotalSchValue = 0;
        list<buildertek__Schedule_of_Value_Lines__c> consSovLines = [select Id, Name,buildertek__Grouping__c,buildertek__Item__c, buildertek__Description_of_Work__c, buildertek__Scheduled_Value__c,buildertek__isConsolidated__c,buildertek__Is_Created_First_time__c, buildertek__Old_Sov_Line_Ids_From_Project__c, buildertek__Schedule_of_Values__c, buildertek__Is_Processed__c  from buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =:sovId AND buildertek__Status__c = 'Pending'];
        for(buildertek__Schedule_of_Value_Lines__c sovLine : consSovLines){
            if(sovLine.buildertek__Scheduled_Value__c != null){
                TotalSchValue += sovLine.buildertek__Scheduled_Value__c;
            }
        }
        system.debug('TotalSchValue'+TotalSchValue);
        return TotalSchValue;
    }
    
    @AuraEnabled
    public static PaginationInnerClass getApprovedSovData(string recordId, Integer pageNumber, Integer pageSize, String vendorName, String itemNo, String description){
       
        //Offset for SOQL
        
        Integer offset;
        
        if(pageNumber != null && pageSize != null){
         offset = (pageNumber - 1) * pageSize;
        }else{
           offset = 1;  
        }
        
        if(pageSize == null){
            pageSize = 1;
        }
        
        if(pageNumber == null){
            pageNumber = 1;
        }
        
       
        
   
        PaginationInnerClass ApprovedSovLineslistWithPagination = new PaginationInnerClass();
      
         Integer totalRecords = 0;
        
        
        
      if(vendorName != '' || itemNo != '' || description != '' ){
            String query = 'Select COUNT() FROM buildertek__Schedule_of_Value_Lines__c where (buildertek__Schedule_of_Values__c =: recordId  AND buildertek__Status__c =  \'Approved\')';
            if(vendorName != '' && vendorName != null){
                query = query+ 'AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            if(itemNo != '' && itemNo != null){
                query = query+ ' AND (buildertek__Item__c LIKE \'%'+String.escapeSingleQuotes(itemNo)+'%\')';
            }
            if(description != '' && description != null){
                query = query+ ' AND (buildertek__Description_of_Work__c LIKE \'%'+String.escapeSingleQuotes(description)+'%\')';
            }
            totalRecords = Database.countQuery(query);
            system.debug(totalRecords);
        
        }
        else{
            totalRecords = [select COUNT()  
                                from buildertek__Schedule_of_Value_Lines__c
                                where buildertek__Schedule_of_Values__c =:recordId AND 
                                buildertek__Status__c = 'Approved'];
            system.debug('else total records'+ totalRecords);
        }
        
      
        
        Integer recordEnd = pageSize * pageNumber;
        
        
        
        list<buildertek__Schedule_of_Value_Lines__c> Schedulelist = new list<buildertek__Schedule_of_Value_Lines__c>();
        
        
        if(vendorName != '' || itemNo != '' || description != ''){
            
            String queryList = 'select Id, Name, buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Item__c,buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c,buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name,buildertek__Schedule_of_Values__c,buildertek__Old_Vendor_Id__c,buildertek__Schedule_of_Values__r.buildertek__Type__c,buildertek__Vendor__c, buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name, buildertek__Vendor__r.Name from buildertek__Schedule_of_Value_Lines__c';
            queryList = queryList +  ' where (buildertek__Schedule_of_Values__c =: recordId  AND buildertek__Status__c =  \'Approved\') ';
            if(vendorName != '' && vendorName != null){
                queryList = queryList+ 'AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            if(itemNo != '' && itemNo != null){
                queryList = queryList+ ' AND (buildertek__Item__c LIKE \'%'+String.escapeSingleQuotes(itemNo)+'%\')';
            }
            if(description != '' && description != null){
                queryList = queryList+ 'AND (buildertek__Description_of_Work__c LIKE \'%'+String.escapeSingleQuotes(description)+'%\')';
            }
            
            Schedulelist = Database.query(queryList); 
         
        }else{
            Schedulelist = [select Id, Name, buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Item__c,buildertek__Schedule_of_Values__r.buildertek__Type__c,
                            buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                            buildertek__Schedule_of_Values__r.buildertek__Project__c,
                            buildertek__Old_Vendor_Id__c,buildertek__Vendor__c,
                            buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name,
                            buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name,
                            buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c,
                            buildertek__Schedule_of_Values__r.buildertek__Project__r.Name, buildertek__Status__c  
                            from buildertek__Schedule_of_Value_Lines__c
                            where buildertek__Schedule_of_Values__c =:recordId AND 
                            buildertek__Status__c = 'Approved' ORDER BY buildertek__Item__c LIMIT :pageSize OFFSET :offset];
            
            
        }

        system.debug('totalRecords----->'+totalRecords);
        system.debug('recordEnd----->'+recordEnd);
        list<ApprovedSovLinesInnerClass> Approvelist = new list<ApprovedSovLinesInnerClass>();
        
        for(buildertek__Schedule_of_Value_Lines__c Schedulerec : Schedulelist){
            ApprovedSovLinesInnerClass ApprovedSovLinesInnerrec = new ApprovedSovLinesInnerClass();
            ApprovedSovLinesInnerrec.sovlines = Schedulerec;
            ApprovedSovLinesInnerrec.checksov = false;
            ApprovedSovLinesInnerrec.Item = Schedulerec.buildertek__Item__c;
            ApprovedSovLinesInnerrec.DescofWork = Schedulerec.buildertek__Description_of_Work__c;
            ApprovedSovLinesInnerrec.ScheduleValue = Schedulerec.buildertek__Scheduled_Value__c;
            ApprovedSovLinesInnerrec.VendorName = Schedulerec.buildertek__Vendor__r.Name;
            ApprovedSovLinesInnerrec.Type = Schedulerec.buildertek__Schedule_of_Values__r.buildertek__Type__c;
            ApprovedSovLinesInnerrec.Id = Schedulerec.Id;
            ApprovedSovLinesInnerrec.VendorId = Schedulerec.buildertek__Old_Vendor_Id__c;
            if(Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__c != null){
                ApprovedSovLinesInnerrec.VendorSovName = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name +' - ' + Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name;
            }else{
                ApprovedSovLinesInnerrec.VendorSovName = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name;
            }
            ApprovedSovLinesInnerrec.VendorSovId = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c;
            ApprovedSovLinesInnerrec.oldVendorId = Schedulerec.buildertek__Vendor__c;
            
            system.debug('ApprovedSovLinesInnerrec------>'+ApprovedSovLinesInnerrec);
            
            Approvelist.add(ApprovedSovLinesInnerrec);
            
           
        }
        ApprovedSovLineslistWithPagination.ApprovedSovLinesInnerList = Approvelist;
        ApprovedSovLineslistWithPagination.pageSize = pageSize;
        ApprovedSovLineslistWithPagination.pageNumber = pageNumber;
        ApprovedSovLineslistWithPagination.recordStart = offset + 1;
        ApprovedSovLineslistWithPagination.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        ApprovedSovLineslistWithPagination.totalRecords = totalRecords; 
        
        return ApprovedSovLineslistWithPagination;                                                           
    }
    
    @AuraEnabled
    public static PendingPaginationInnerClass getPendingSovData(string recordId, Integer pageNumber, Integer pageSize){
        
        system.debug('pageNumber----->'+pageNumber);
        system.debug('pageSize----->'+pageSize);
        
        
        //Offset for SOQL
        
        Integer offset;
        
        if(pageNumber != null && pageSize != null){
         offset = (pageNumber - 1) * pageSize;
        }else{
           offset = 1;  
        }
        
        if(pageSize == null){
            pageSize = 1;
        }
        
        if(pageNumber == null){
            pageNumber = 1;
        }
        
        
        
        system.debug('offset----->'+offset);
        
        
        PendingPaginationInnerClass PendingSovLineslistWithPagination = new PendingPaginationInnerClass();
        
        //Total Records
        Integer totalRecords = [select COUNT()  
                                from buildertek__Schedule_of_Value_Lines__c
                                where buildertek__Schedule_of_Values__c =:recordId AND 
                                (buildertek__Status__c = 'Pending' OR buildertek__Status__c = 'Customer Rejected' OR buildertek__Status__c = 'Customer Approved')];
        
        Integer recordEnd = pageSize * pageNumber;
        
        system.debug('totalRecords00000------->'+totalRecords);
        
        if(recordEnd == null || recordEnd == 0){
            recordEnd = totalRecords;
        }
        
        
        list<PendingSovLinesInnerClass> PendingSovLinesInnerClasslist = new list<PendingSovLinesInnerClass>();
        list<buildertek__Schedule_of_Value_Lines__c> Schedulelist = [select Id, Name, buildertek__Scheduled_Value__c,
                                                                     buildertek__Description_of_Work__c,buildertek__Item__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Type__c,
                                                                     buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                                                                     buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__r.Name,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Vendor__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name,
                                                                     buildertek__Status__c ,buildertek__Vendor__c,
                                                                     buildertek__Rejection_Reason__c,
                                                                     buildertek__Schedule_of_Values__r.Name,
                                                                     buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name,
                                                                     buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c,
                                                                     buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__c,
                                                                     buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name,
                                                                     buildertek__Old_Vendor_Id__c
                                                                     from buildertek__Schedule_of_Value_Lines__c
                                                                     where buildertek__Schedule_of_Values__c =:recordId AND 
                                                                     (buildertek__Status__c = 'Pending' OR buildertek__Status__c = 'Customer Rejected' OR buildertek__Status__c = 'Customer Approved') ORDER BY buildertek__Item__c  LIMIT :pageSize OFFSET :offset];
        
        system.debug('Schedulelist-------->'+Schedulelist);
        
        list<Id> Ids = new list<Id>();
        for(buildertek__Schedule_of_Value_Lines__c Sch : Schedulelist){
            if(Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
               Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                   system.debug('consolId--------->'+sch.buildertek__Old_Sov_Line_Ids_From_Project__c);
                   string[] Idslist = sch.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                   for(string str : Idslist){
                        system.debug('jiuhiu1--->'+str);
                       if(!String.isBlank(str)){
                           system.debug('jiuhiu2--->'+str);
                           Ids.add(Id.valueOf(str));
                       }
                   }
               }
        }
        
        system.debug('Idsuh---------->'+Ids);
        
        Map<Id,buildertek__Schedule_of_Value_Lines__c> Schedulelinemap = new Map<Id,buildertek__Schedule_of_Value_Lines__c>([select Id, Name, buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Item__c,buildertek__Schedule_of_Values__r.buildertek__Type__c,
                                                                                                                             buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                                                                                                                             buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                                                                             buildertek__Schedule_of_Values__r.Name,
                                                                                                                             buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                                                                             buildertek__Schedule_of_Values__r.buildertek__Project__r.Name, buildertek__Status__c,
                                                                                                                             buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name,
                                                                                                                             buildertek__Rejection_Reason__c,buildertek__Vendor__c,buildertek__Old_Vendor_Id__c,
                                                                                                                             buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name,
                                                                                                                             buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c
                                                                                                                             from buildertek__Schedule_of_Value_Lines__c
                                                                                                                             where Id IN: Ids AND (buildertek__Status__c = 'Pending' OR buildertek__Status__c = 'Customer Rejected' OR buildertek__Status__c = 'Customer Approved') ORDER BY buildertek__Item__c]);
        
       system.debug('Schedulelinemap----->'+Schedulelinemap);
        list<PendingSovLinesInnerClass> PendingList = new list<PendingSovLinesInnerClass>();
        system.debug('Schedulelist--------->'+Schedulelist);
        for(buildertek__Schedule_of_Value_Lines__c Schedulerec : Schedulelist){
            system.debug('Schedulerec.Id------->'+Schedulelinemap.get(Schedulerec.Id));
            system.debug('Schedulerec-------->'+Schedulerec);
            if(Schedulelinemap.get(Schedulerec.Id) == null){  
                PendingSovLinesInnerClass PendingSovLinesInnerrec = new PendingSovLinesInnerClass();
                PendingSovLinesInnerrec.sovlines = Schedulerec;
                PendingSovLinesInnerrec.checksov = false;
                PendingSovLinesInnerrec.Item = Schedulerec.buildertek__Item__c;
                PendingSovLinesInnerrec.DescofWork = Schedulerec.buildertek__Description_of_Work__c;
                PendingSovLinesInnerrec.ScheduleValue = Schedulerec.buildertek__Scheduled_Value__c;
                PendingSovLinesInnerrec.VendorName = Schedulerec.buildertek__Vendor__r.Name;
                PendingSovLinesInnerrec.oldVendorId = Schedulerec.buildertek__Old_Vendor_Id__c;
                PendingSovLinesInnerrec.Type = Schedulerec.buildertek__Schedule_of_Values__r.buildertek__Type__c;
                PendingSovLinesInnerrec.Id = Schedulerec.Id;
                PendingSovLinesInnerrec.IsConsolidate = false;
                PendingSovLinesInnerrec.IsExpand = false;
                if(Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__c != null){
                    PendingSovLinesInnerrec.VendorSovName = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name + ' - '+Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name;
                    
                }else{
                    PendingSovLinesInnerrec.VendorSovName = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name;
                    
                }
                PendingSovLinesInnerrec.VendorSovId = Schedulerec.buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c;
                PendingSovLinesInnerrec.SOVName = Schedulerec.buildertek__Schedule_of_Values__r.Name + ' - ' +Schedulerec.buildertek__Vendor__r.Name;
                PendingSovLinesInnerrec.SOVId = Schedulerec.buildertek__Schedule_of_Values__c;
                PendingSovLinesInnerrec.Status = Schedulerec.buildertek__Status__c;
                PendingSovLinesInnerrec.RejectStatus = Schedulerec.buildertek__Rejection_Reason__c;
                
                
                list<ConsolidatedLinesInnerClass> ConsolidatedLinesInnerClasslist = new list<ConsolidatedLinesInnerClass>();
                system.debug('text---->'+Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c);
                if(Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
                   Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                       string[] Idslist = Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                               system.debug('Idslistoi--------->'+Idslist);

                       for(string str : Idslist){
                           system.debug('stryyy------->'+str);
                           if(!String.isBlank(str)){
                               
                               if(Schedulelinemap.get(str) != null){
                                   system.debug('str------->'+str);
                                   ConsolidatedLinesInnerClass ConsolidatedLinesInner = new ConsolidatedLinesInnerClass();
                                   ConsolidatedLinesInner.Item = Schedulelinemap.get(str).buildertek__Item__c;
                                   ConsolidatedLinesInner.DescofWork = Schedulelinemap.get(str).buildertek__Description_of_Work__c;
                                   ConsolidatedLinesInner.ScheduleValue = Schedulelinemap.get(str).buildertek__Scheduled_Value__c;
                                   ConsolidatedLinesInner.VendorName = Schedulelinemap.get(str).buildertek__Vendor__r.Name;
                                   ConsolidatedLinesInner.oldVendorId = Schedulelinemap.get(str).buildertek__Old_Vendor_Id__c;
                                   ConsolidatedLinesInner.Type = Schedulelinemap.get(str).buildertek__Schedule_of_Values__r.buildertek__Type__c;
                                   ConsolidatedLinesInner.Id = Schedulelinemap.get(str).Id;
                                   if(Schedulelinemap.get(str).buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__c != null){
                                       ConsolidatedLinesInner.VendorSovName = Schedulelinemap.get(str).buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name +' - '+Schedulelinemap.get(str).buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.buildertek__Vendor__r.Name;
                                   }else{
                                       ConsolidatedLinesInner.VendorSovName = Schedulelinemap.get(str).buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__r.Name;
                                   }
                                   ConsolidatedLinesInner.VendorSovId = Schedulelinemap.get(str).buildertek__Vendor_SOV_Line__r.buildertek__Schedule_of_Values__c;
                                   ConsolidatedLinesInner.SOVName = Schedulelinemap.get(str).buildertek__Schedule_of_Values__r.Name;
                                   ConsolidatedLinesInner.SOVId = Schedulelinemap.get(str).buildertek__Schedule_of_Values__c;
                                   ConsolidatedLinesInner.Status = Schedulelinemap.get(str).buildertek__Status__c;
                                   ConsolidatedLinesInner.RejectStatus = Schedulelinemap.get(str).buildertek__Rejection_Reason__c;
                                   ConsolidatedLinesInnerClasslist.add(ConsolidatedLinesInner);
                               }
                               
                           }
                       } 
                       PendingSovLinesInnerrec.IsConsolidate = true;
                   }
                PendingSovLinesInnerrec.ConsolidatedLinesInnerlist = ConsolidatedLinesInnerClasslist;
               // PendingSovLinesInnerClasslist.add(PendingSovLinesInnerrec);
               system.debug('PendingSovLinesInnerrec------------>'+PendingSovLinesInnerrec);
                 PendingList.add(PendingSovLinesInnerrec);
            }
        }  
        
        PendingSovLineslistWithPagination.PendingSovLinesInnerList = PendingList;
        PendingSovLineslistWithPagination.pageSize = pageSize;
        PendingSovLineslistWithPagination.pageNumber = pageNumber;
        PendingSovLineslistWithPagination.recordStart = offset + 1;
        PendingSovLineslistWithPagination.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        PendingSovLineslistWithPagination.totalRecords = totalRecords; 
        
        system.debug('PendingSovLineslistWithPaginationoi-------->'+PendingSovLineslistWithPagination);
        return PendingSovLineslistWithPagination;   
    }
    
    @AuraEnabled
    public static string updateManageSOV(String Pendingrecord, String Approvedrecord, String recordId){
        try{
            List<ApprovedSovLinesInnerClass> ApprovedSovLinesInnerlist = 
                (List<ApprovedSovLinesInnerClass>)JSON.deserialize(Approvedrecord, List<ApprovedSovLinesInnerClass>.class);
            
            List<PendingSovLinesInnerClass> PendingSovLinesInnerlist = 
                (List<PendingSovLinesInnerClass>)JSON.deserialize(Pendingrecord, List<PendingSovLinesInnerClass>.class);
            
            buildertek__MSA_Settings__c  MSASettings=[SELECT Id, Name, buildertek__Company_Name__c, buildertek__Company_Full_Name__c
                                                      FROM buildertek__MSA_Settings__c LIMIT 1];
            
            buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_SOV__c 
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'SOV Configuration'];
            
            
            system.debug('MSASettings----->'+MSASettings);
            
            
             integer  ItNumber = 100;
            
            integer consLineNmbr = 100+PendingSovLinesInnerlist.size();
            
            system.debug('consLineNmbr---------->'+consLineNmbr);
            
            list<buildertek__Schedule_of_Value_Lines__c> ApprovedSchedulelist = new list<buildertek__Schedule_of_Value_Lines__c>();
            list<buildertek__Schedule_of_Value_Lines__c> PendingSchedulelist = new list<buildertek__Schedule_of_Value_Lines__c>();
            
            for(PendingSovLinesInnerClass ApprovedSovLinesInner : PendingSovLinesInnerlist){
                system.debug('wwwwwwwwwwwwwwwwwww');
                buildertek__Schedule_of_Value_Lines__c schedlines = new buildertek__Schedule_of_Value_Lines__c();
                schedlines.buildertek__Item__c =  ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Description_of_Work__c = ApprovedSovLinesInner.DescofWork;
               // schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Scheduled_Value__c = ApprovedSovLinesInner.ScheduleValue;
                system.debug('ApprovedSovLinesInner.Id---------->'+ApprovedSovLinesInner.Id);
                if(ApprovedSovLinesInner.Id == null || ApprovedSovLinesInner.Id == '')
                    schedlines.buildertek__Schedule_of_Values__c = recordId;
                schedlines.buildertek__Old_Vendor_Id__c = ApprovedSovLinesInner.oldVendorId;
                schedlines.buildertek__Vendor__c = adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
                if(ApprovedSovLinesInner.Status != 'Customer Rejected'){
                    schedlines.buildertek__Status__c = 'Pending'; 
                }
                // ItNumber ++;
                 
                schedlines.buildertek__isConsolidated__c = false;
                string oldIds = '';
                if(ApprovedSovLinesInner.IsConsolidate == true){
                     system.debug('rrrrrrrrrrrrrrrrrrrr');
                    for(ConsolidatedLinesInnerClass ConsolidatedLinesInner : ApprovedSovLinesInner.ConsolidatedLinesInnerlist){
                        oldIds += ConsolidatedLinesInner.Id + ',';
                        buildertek__Schedule_of_Value_Lines__c conschedlines = new buildertek__Schedule_of_Value_Lines__c();
                        system.debug('consLineNmbr3333---------->'+consLineNmbr);
                        conschedlines.buildertek__Item__c = ConsolidatedLinesInner.Item;
                        conschedlines.Id = ConsolidatedLinesInner.Id;
                        conschedlines.buildertek__Description_of_Work__c = ConsolidatedLinesInner.DescofWork;
                        conschedlines.Id = ConsolidatedLinesInner.Id;
                        conschedlines.buildertek__Old_Vendor_Id__c = ConsolidatedLinesInner.oldVendorId;
                        conschedlines.buildertek__Vendor__c = adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
                        conschedlines.buildertek__Scheduled_Value__c = ConsolidatedLinesInner.ScheduleValue;
                        if(ConsolidatedLinesInner.Status != 'Customer Rejected'){
                            conschedlines.buildertek__Status__c = 'Pending';
                        }
                        
                        conschedlines.buildertek__isConsolidated__c = true;  
                        PendingSchedulelist.add(conschedlines);
                         //consLineNmbr ++;
                    }
                }
                if(oldIds != ''){
                    schedlines.buildertek__Old_Sov_Line_Ids_From_Project__c = oldIds.substring(0,oldIds.length() - 1);
                }
                
                PendingSchedulelist.add(schedlines);  
               
            }

            if(!PendingSchedulelist.isEmpty()){
                upsert PendingSchedulelist;
            }
            
            
            system.debug('ItNumber------------->'+ItNumber);
            
            system.debug('ApprovedSovLinesInnerlist------>'+ApprovedSovLinesInnerlist.size());
            
            for(ApprovedSovLinesInnerClass ApprovedSovLinesInner : ApprovedSovLinesInnerlist){
                buildertek__Schedule_of_Value_Lines__c schedlines = new buildertek__Schedule_of_Value_Lines__c();
                schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                system.debug('recordId    '+ ApprovedSovLinesInner.Id + 'Item number    '+consLineNmbr);
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Description_of_Work__c = ApprovedSovLinesInner.DescofWork;
               // schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Scheduled_Value__c = ApprovedSovLinesInner.ScheduleValue;

                if(ApprovedSovLinesInner.Id == null)
                    schedlines.buildertek__Schedule_of_Values__c = recordId;
                schedlines.buildertek__Status__c = 'Approved';
                schedlines.buildertek__isConsolidated__c = false; 
                if(ApprovedSovLinesInner.oldVendorId != null && ApprovedSovLinesInner.oldVendorId != '')
                    schedlines.buildertek__Vendor__c  =  ApprovedSovLinesInner.oldVendorId;               
                ApprovedSchedulelist.add(schedlines);
                consLineNmbr ++;
            }
            
            
            system.debug('ItNumber=======>'+ItNumber);
          
            
            if(!ApprovedSchedulelist.isEmpty()){
                upsert ApprovedSchedulelist;
               system.debug('uyguhbu0--------->'+ApprovedSchedulelist[0]);
            }
            
           
            
          /*   integer itemInc = 100;
            list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c, buildertek__Vendor_Scheduled_Value__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ORDER BY buildertek__Item__c ASC];
            if(!lastSOV.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c SV : lastSOV){
                    SV.buildertek__Item__c = String.valueOf(itemInc);
                    itemInc++;
                }
                update lastSOV;   
            }*/
           
           
            
            
            return 'Success';
        }
        catch(Exception e){
            return e.getmessage();
        }
        
    }
    
    
    @AuraEnabled
    public static String rejectSovlineData(list<string> recordId, string rejectReason){
        system.debug('recordId----->'+recordId);
        List<buildertek__Schedule_of_Value_Lines__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Vendor_SOV_Line__r.buildertek__Status__c, buildertek__Vendor_SOV_Line__r.buildertek__Rejection_Reason__c, buildertek__Vendor_SOV_Line__c, buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id =:recordId];
        system.debug('SovLineList----->'+SovLineList);
        List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c, buildertek__Status__c, buildertek__Rejection_Reason__c,buildertek__Schedule_of_Values__c,buildertek__Schedule_of_Values__r.buildertek__Status__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c =: SovLineList[0].buildertek__Vendor_SOV_Line__c ];
        system.debug('vendorsovlist---->'+vendorsovlist);
        
        Set<String> parentSovIds = new Set<String>();
        Set<String> childSOVLinesList = new Set<String>();
        Set<String> finalSOVIds = new Set<String>();
        system.debug('vendorsovlist----->'+vendorsovlist);
        
        if(!SovLineList.isEmpty()){
            for(buildertek__Schedule_of_Value_Lines__c sov :SovLineList){
                sov.buildertek__Status__c = 'Customer Rejected';
                sov.buildertek__Rejection_Reason__c = rejectReason;
            }
            update SovLineList;
            
            system.debug('SovLineList----->'+SovLineList);
            set<Id> vendorsovlineids = new set<Id>();
            
            system.debug(vendorsovlist);
            if(!vendorsovlist.isEmpty()){
                list<buildertek__Schedule_of_Value_Lines__c> newVendorUpdateList = new list<buildertek__Schedule_of_Value_Lines__c>();
                for(buildertek__Schedule_of_Value_Lines__c sov1 :vendorsovlist){
                    buildertek__Schedule_of_Value_Lines__c newVendor = new buildertek__Schedule_of_Value_Lines__c();
                    newVendor.buildertek__Status__c = 'Rejected';
                    newVendor.buildertek__Rejection_Reason__c = rejectReason;
                    if(sov1.buildertek__Vendor_SOV_Line__c != null  & !vendorsovlineids.contains(sov1.buildertek__Vendor_SOV_Line__c)){
                        vendorsovlineids.add(sov1.buildertek__Vendor_SOV_Line__c);
                        newVendor.Id = sov1.buildertek__Vendor_SOV_Line__c;
                        childSOVLinesList.add(sov1.buildertek__Vendor_SOV_Line__c);
                        newVendorUpdateList.add(newVendor);
                        parentSovIds.add(sov1.buildertek__Schedule_of_Values__c);
                    }  
                }
                
                if(!newVendorUpdateList.isEmpty()){
                    update newVendorUpdateList;
                    
                    
                    List<buildertek__Schedule_of_Value_Lines__c> newVenSovLineList;
                    if(!childSOVLinesList.isEmpty()){
                        newVenSovLineList = [select Id, Name,buildertek__Status__c,buildertek__Schedule_of_Values__c  from buildertek__Schedule_of_Value_Lines__c where Id IN: childSOVLinesList ];
                    }
                    
                    system.debug('newVenSovLineList----->'+newVenSovLineList);
                    if(!newVenSovLineList.isEmpty()){
                        For(buildertek__Schedule_of_Value_Lines__c sLine : newVenSovLineList){
                            finalSOVIds.add(sLine.buildertek__Schedule_of_Values__c);
                        }
                    }
                    
                    system.debug('finalSOVIds----->'+finalSOVIds);
                    List<buildertek__Schedule_of_Values__c> SovList = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id IN:finalSOVIds];
                    system.debug('SovList'+SovList);
                    if(!SovList.isEmpty()){
                        for(buildertek__Schedule_of_Values__c sov1 :SovList){
                           // buildertek__Schedule_of_Values__c newVendor = new buildertek__Schedule_of_Values__c();
                            sov1.buildertek__Status__c = 'Company Rejected';
                        }
                    }
                    if(!SovList.isEmpty()){
                        update SovList;
                    }
                }
            }
            return 'success';
        }else{
            return null;
        }          
        
    }
    
    
    
    public class ApprovedSovLinesInnerClass{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public boolean checksov{ get; set; }
        
        @AuraEnabled
        public string Item{ get; set; }
        
        @AuraEnabled
        public string DescofWork{ get; set; }
        
        @AuraEnabled
        public decimal ScheduleValue{ get; set; }
        
        @AuraEnabled
        public string VendorName{ get; set; }
        
        @AuraEnabled
        public string Type{ get; set; }
        
        @AuraEnabled
        public string VendorId{ get; set; }
        
        @AuraEnabled
        public string Id{ get; set; }
        
        @AuraEnabled
        public string oldVendorId{ get; set; }
        
        @AuraEnabled
        public buildertek__Schedule_of_Value_Lines__c sovlines{get;set;}
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
         @AuraEnabled
        public string VendorSovName{ get; set; }
        
        @AuraEnabled
        public string VendorSovId{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords {get;set;}
        
        @AuraEnabled
        public Integer recordStart {get;set;}
        
        @AuraEnabled
        public Integer recordEnd {get;set;}
    }
    
    public class PendingSovLinesInnerClass{
        @AuraEnabled
        public string SOVName{ get; set; }
        
        @AuraEnabled
        public string SOVId{ get; set; }
        
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public boolean checksov{ get; set; }
        
        @AuraEnabled
        public string Item{ get; set; }
        
        @AuraEnabled
        public string DescofWork{ get; set; }
        
        @AuraEnabled
        public decimal ScheduleValue{ get; set; }
        
        @AuraEnabled
        public string VendorName{ get; set; }
        
        @AuraEnabled
        public string Type{ get; set; }
        
        @AuraEnabled
        public string Id{ get; set; }
        
        @AuraEnabled
        public string oldVendorId{ get; set; }
        
        @AuraEnabled
        public boolean IsConsolidate{ get; set; }
        
        @AuraEnabled
        public boolean IsExpand{ get; set; }
        
        @AuraEnabled
        public buildertek__Schedule_of_Value_Lines__c sovlines{get;set;}
        
        @AuraEnabled
        public list<ConsolidatedLinesInnerClass>  ConsolidatedLinesInnerlist{get;set;}
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public string Status{ get; set; }
        
        @AuraEnabled
        public string RejectStatus{ get; set; }
        
        @AuraEnabled
        public string VendorSovName{ get; set; }
        
        @AuraEnabled
        public string VendorSovId{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords {get;set;}
        
        @AuraEnabled
        public Integer recordStart {get;set;}
        
        @AuraEnabled
        public Integer recordEnd {get;set;}
    }
    
    public class ConsolidatedLinesInnerClass{
        @AuraEnabled
        public string SOVName{ get; set; }
        
        @AuraEnabled
        public string SOVId{ get; set; }
        
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public string Item{ get; set; }
        
        @AuraEnabled
        public string DescofWork{ get; set; }
        
        @AuraEnabled
        public decimal ScheduleValue{ get; set; }
        
        @AuraEnabled
        public string VendorName{ get; set; }
        
        @AuraEnabled
        public string Type{ get; set; }
        
        @AuraEnabled
        public string Status{ get; set; }
        
        @AuraEnabled
        public string Id{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public string RejectStatus{ get; set; }
        
        @AuraEnabled
        public string oldVendorId{ get; set; }
        
        @AuraEnabled
        public string VendorSovName{ get; set; }
        
        @AuraEnabled
        public string VendorSovId{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords {get;set;}
        
        @AuraEnabled
        public Integer recordStart {get;set;}
        
        @AuraEnabled
        public Integer recordEnd {get;set;}
        
    }
    
    
    public class PaginationInnerClass{
        
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public list<ApprovedSovLinesInnerClass>  ApprovedSovLinesInnerList{get;set;}
        
    }
    
    
       public class PendingPaginationInnerClass{
        
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public list<PendingSovLinesInnerClass>  PendingSovLinesInnerList{get;set;}
        
    }
    
}