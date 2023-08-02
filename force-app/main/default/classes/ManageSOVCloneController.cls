public class ManageSOVCloneController {
    
    @AuraEnabled
    public static String getProjectName(string projectId){
        buildertek__Project__c consSovLines = [select Id, Name from buildertek__Project__c    WHERE Id =:projectId];
        return consSovLines.Name;
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
    public static list<ApprovedSovLinesInnerClass> getApprovedSovData(string recordId){
        list<ApprovedSovLinesInnerClass> ApprovedSovLinesInnerClasslist = new list<ApprovedSovLinesInnerClass>();
        list<buildertek__Schedule_of_Value_Lines__c> Schedulelist = [select Id, Name, buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Item__c,buildertek__Schedule_of_Values__r.buildertek__Type__c,
                                                                     buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                     buildertek__Old_Vendor_Id__c,buildertek__Vendor__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__r.Name, buildertek__Status__c  
                                                                     from buildertek__Schedule_of_Value_Lines__c
                                                                     where buildertek__Schedule_of_Values__c =:recordId AND 
                                                                     buildertek__Status__c = 'Approved' ORDER BY buildertek__Item__c];
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
            ApprovedSovLinesInnerrec.oldVendorId = Schedulerec.buildertek__Vendor__c;
            ApprovedSovLinesInnerClasslist.add(ApprovedSovLinesInnerrec);
        }  
        return ApprovedSovLinesInnerClasslist;                                                           
    }
    
    @AuraEnabled
    public static list<PendingSovLinesInnerClass> getPendingSovData(string recordId){
        list<PendingSovLinesInnerClass> PendingSovLinesInnerClasslist = new list<PendingSovLinesInnerClass>();
        list<buildertek__Schedule_of_Value_Lines__c> Schedulelist = [select Id, Name, buildertek__Scheduled_Value__c,
                                                                     buildertek__Description_of_Work__c,buildertek__Item__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Type__c,
                                                                     buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                                                                     buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                     buildertek__Schedule_of_Values__r.buildertek__Project__r.Name,
                                                                     buildertek__Status__c ,buildertek__Vendor__c,
                                                                     buildertek__Rejection_Reason__c,
                                                                     buildertek__Old_Vendor_Id__c
                                                                     from buildertek__Schedule_of_Value_Lines__c
                                                                     where buildertek__Schedule_of_Values__c =:recordId AND 
                                                                     (buildertek__Status__c = 'Pending' OR buildertek__Status__c = 'Customer Rejected') ORDER BY buildertek__Item__c];
        
        list<string> Ids = new list<string>();
        for(buildertek__Schedule_of_Value_Lines__c Sch : Schedulelist){
            if(Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
               Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                   string[] Idslist = sch.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                   for(string str : Idslist){
                       Ids.add(str);
                   }
               }
        }
        Map<Id,buildertek__Schedule_of_Value_Lines__c> Schedulelinemap = new Map<Id,buildertek__Schedule_of_Value_Lines__c>([select Id, Name, buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Item__c,buildertek__Schedule_of_Values__r.buildertek__Type__c,
                                                                                                                             buildertek__Schedule_of_Values__c, buildertek__Vendor__r.Name,
                                                                                                                             buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                                                                             buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                                                                             buildertek__Schedule_of_Values__r.buildertek__Project__r.Name, buildertek__Status__c,
                                                                                                                             buildertek__Rejection_Reason__c,buildertek__Vendor__c,buildertek__Old_Vendor_Id__c
                                                                                                                             from buildertek__Schedule_of_Value_Lines__c
                                                                                                                             where Id IN: Ids ORDER BY buildertek__Item__c]);
        for(buildertek__Schedule_of_Value_Lines__c Schedulerec : Schedulelist){
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
                PendingSovLinesInnerrec.Status = Schedulerec.buildertek__Status__c;
                PendingSovLinesInnerrec.RejectStatus = Schedulerec.buildertek__Rejection_Reason__c;
                
                
                list<ConsolidatedLinesInnerClass> ConsolidatedLinesInnerClasslist = new list<ConsolidatedLinesInnerClass>();
                if(Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
                   Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                       string[] Idslist = Schedulerec.buildertek__Old_Sov_Line_Ids_From_Project__c.split(',');
                       for(string str : Idslist){
                           if(Schedulelinemap.get(str) != null){
                               ConsolidatedLinesInnerClass ConsolidatedLinesInner = new ConsolidatedLinesInnerClass();
                               ConsolidatedLinesInner.Item = Schedulelinemap.get(str).buildertek__Item__c;
                               ConsolidatedLinesInner.DescofWork = Schedulelinemap.get(str).buildertek__Description_of_Work__c;
                               ConsolidatedLinesInner.ScheduleValue = Schedulelinemap.get(str).buildertek__Scheduled_Value__c;
                               ConsolidatedLinesInner.VendorName = Schedulelinemap.get(str).buildertek__Vendor__r.Name;
                               ConsolidatedLinesInner.oldVendorId = Schedulelinemap.get(str).buildertek__Old_Vendor_Id__c;
                               ConsolidatedLinesInner.Type = Schedulelinemap.get(str).buildertek__Schedule_of_Values__r.buildertek__Type__c;
                               ConsolidatedLinesInner.Id = Schedulelinemap.get(str).Id;
                               ConsolidatedLinesInner.Status = Schedulelinemap.get(str).buildertek__Status__c;
                               ConsolidatedLinesInner.RejectStatus = Schedulelinemap.get(str).buildertek__Rejection_Reason__c;
                               ConsolidatedLinesInnerClasslist.add(ConsolidatedLinesInner);
                           }
                       } 
                       PendingSovLinesInnerrec.IsConsolidate = true;
                   }
                PendingSovLinesInnerrec.ConsolidatedLinesInnerlist = ConsolidatedLinesInnerClasslist;
                PendingSovLinesInnerClasslist.add(PendingSovLinesInnerrec);
            }
        }  
        return PendingSovLinesInnerClasslist;   
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
            
            
            list<buildertek__Schedule_of_Value_Lines__c> ApprovedSchedulelist = new list<buildertek__Schedule_of_Value_Lines__c>();
            list<buildertek__Schedule_of_Value_Lines__c> PendingSchedulelist = new list<buildertek__Schedule_of_Value_Lines__c>();
            for(ApprovedSovLinesInnerClass ApprovedSovLinesInner : ApprovedSovLinesInnerlist){
                buildertek__Schedule_of_Value_Lines__c schedlines = new buildertek__Schedule_of_Value_Lines__c();
                schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Description_of_Work__c = ApprovedSovLinesInner.DescofWork;
                schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Scheduled_Value__c = ApprovedSovLinesInner.ScheduleValue;
                if(ApprovedSovLinesInner.Id == null && ApprovedSovLinesInner.Id == '')
                    schedlines.buildertek__Schedule_of_Values__c = recordId;
                schedlines.buildertek__Status__c = 'Approved';
                schedlines.buildertek__isConsolidated__c = false; 
                if(ApprovedSovLinesInner.oldVendorId != null && ApprovedSovLinesInner.oldVendorId != '')
                    schedlines.buildertek__Vendor__c  =  ApprovedSovLinesInner.oldVendorId;               
                ApprovedSchedulelist.add(schedlines);
            }
            
            for(PendingSovLinesInnerClass ApprovedSovLinesInner : PendingSovLinesInnerlist){
                buildertek__Schedule_of_Value_Lines__c schedlines = new buildertek__Schedule_of_Value_Lines__c();
                schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Description_of_Work__c = ApprovedSovLinesInner.DescofWork;
                schedlines.buildertek__Item__c = ApprovedSovLinesInner.Item;
                schedlines.Id = ApprovedSovLinesInner.Id;
                schedlines.buildertek__Scheduled_Value__c = ApprovedSovLinesInner.ScheduleValue;
                if(ApprovedSovLinesInner.Id == null || ApprovedSovLinesInner.Id == '')
                    schedlines.buildertek__Schedule_of_Values__c = recordId;
                schedlines.buildertek__Old_Vendor_Id__c = ApprovedSovLinesInner.oldVendorId;
                schedlines.buildertek__Vendor__c = adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
                if(ApprovedSovLinesInner.Status != 'Customer Rejected'){
                    schedlines.buildertek__Status__c = 'Pending'; 
                }
                
                schedlines.buildertek__isConsolidated__c = false;
                string oldIds = '';
                if(ApprovedSovLinesInner.IsConsolidate == true){
                    for(ConsolidatedLinesInnerClass ConsolidatedLinesInner : ApprovedSovLinesInner.ConsolidatedLinesInnerlist){
                        oldIds += ConsolidatedLinesInner.Id + ',';
                        buildertek__Schedule_of_Value_Lines__c conschedlines = new buildertek__Schedule_of_Value_Lines__c();
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
                    }
                }
                if(oldIds != ''){
                    schedlines.buildertek__Old_Sov_Line_Ids_From_Project__c = oldIds.substring(0,oldIds.length() - 1);
                }
                
                PendingSchedulelist.add(schedlines);                       
            }
            
            if(!ApprovedSchedulelist.isEmpty()){
                upsert ApprovedSchedulelist;
            }
            
            if(!PendingSchedulelist.isEmpty()){
                upsert PendingSchedulelist;
            }
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
    }
    
    public class PendingSovLinesInnerClass{
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
    }
    
    public class ConsolidatedLinesInnerClass{
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
        
    }
}