public class ManageVendorSOVController {
    
    
    @AuraEnabled
    public static string getcurrency(){
        return UserInfo.getDefaultCurrency();
    }
    
    
     @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSOVdata(String SOVId) {
       buildertek__Schedule_of_Values__c sov = [SELECT Id,buildertek__Status__c,buildertek__Type__c from buildertek__Schedule_of_Values__c WHERE id=:SOVId];
        return sov;
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
        
        system.debug('postel code'+ portalCode);
        return  userRec[0] ;
    }
    

    @AuraEnabled
    public static SOVLinesWrapperClass getVendorSOVLines(String SOVId) {
        system.debug('@@@@@@@@@@@@@'+SOVId);
        SOVLinesWrapperClass  wc = new SOVLinesWrapperClass();
        
        List<buildertek__Schedule_of_Value_Lines__c> sovLineListreturn = new List<buildertek__Schedule_of_Value_Lines__c>();
        buildertek__Schedule_of_Values__c SOVName = [select Id, Name from buildertek__Schedule_of_Values__c where Id =:SOVId ];
        
        system.debug('@@@@@@@@@@@@@'+SOVName);
        wc.sovName = SOVName.Name;
        
        List<buildertek__Schedule_of_Value_Lines__c> sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Original_Scheduled_Value__c ,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE buildertek__Schedule_of_Values__c =: SOVId  ORDER BY buildertek__Item__c ASC  ];
       if(!sovLineList.isEmpty()){
         wc.VendorSOVLinesList=sovLineList;
       }else{
          wc.VendorSOVLinesList=sovLineListreturn;
       }
              
        
        
        //AND buildertek__Status__c!= 'Pending'
        
      Integer ApprovedLinesCount = [SELECT COUNT()
            FROM buildertek__Schedule_of_Value_Lines__c
            WHERE  buildertek__Schedule_of_Values__c =: SOVId and buildertek__Status__c = 'Approved'];
            
        wc.ApprovedSOVLinesCount = ApprovedLinesCount;
        
        return wc;
    }
    
    @AuraEnabled
    public static List<buildertek__Schedule_of_Value_Lines__c> getSOVlineslistbyType(String SOVId,String filter){
    system.debug(filter);
    system.debug(SOVId);
    List<buildertek__Schedule_of_Value_Lines__c> sovLineList = new List<buildertek__Schedule_of_Value_Lines__c>();
      if(filter == 'All'){
      system.debug('All');

           sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE buildertek__Schedule_of_Values__c =: SOVId ORDER BY buildertek__Item__c ASC  ];

      }else{
            sovLineList = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Description_of_Work__c,
                                                                    buildertek__Item__c,
                                                                    buildertek__Scheduled_Value__c,
                                                                    buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                    buildertek__Schedule_of_Values__c,
                                                                    buildertek__Vendor__c,
                                                                    buildertek__Status__c,
                                                                    buildertek__Rejection_Reason__c,
                                                                    buildertek__Vendor__r.Name
                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                    WHERE buildertek__Schedule_of_Values__c =: SOVId AND buildertek__Status__c=:filter  ORDER BY buildertek__Item__c ASC  ];

      }
    system.debug('@@@@@@@@@@@@'+sovLineList);

                  return sovLineList;
    }
    
    
    
    public class SOVLinesWrapperClass{
        @AuraEnabled
        public List<buildertek__Schedule_of_Value_Lines__c> VendorSOVLinesList {get;set;}
        @AuraEnabled
        public String sovName {get; set;}
        @AuraEnabled 
        public boolean isChecked=false; 
        @AuraEnabled 
        public Integer ApprovedSOVLinesCount {get; set;}
        @AuraEnabled 
        public boolean isOriginalSOVValueChanges =false;
        
    }
    
    
    
    @AuraEnabled
    public static String ApproveSovLines(String sovLineIds) {
        system.debug('sovLineIds--->'+ sovLineIds);
        List<buildertek__Schedule_of_Value_Lines__c> SovLineList = [select Id, Name, buildertek__Status__c, buildertek__Scheduled_Value__c, buildertek__Vendor__c from buildertek__Schedule_of_Value_Lines__c where Id =:sovLineIds];
        List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c,buildertek__Schedule_of_Values__c,buildertek__Vendor__c ,buildertek__Scheduled_Value__c, buildertek__Status__c, buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c =: sovLineIds];
        
        system.debug('SovLineList------>'+SovLineList);
        system.debug('vendorsovlist------>'+vendorsovlist);
        
        
        if(!SovLineList.isEmpty()){
            for(buildertek__Schedule_of_Value_Lines__c sov :SovLineList){
                sov.buildertek__Status__c = 'Approved';
                sov.buildertek__Rejection_Reason__c = '';
            }
            update SovLineList;
            
            if(!vendorsovlist.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov :vendorsovlist){
                    sov.buildertek__Status__c = 'Approved';
                    sov.buildertek__Rejection_Reason__c = '';
                    sov.buildertek__Scheduled_Value__c = SovLineList[0].buildertek__Scheduled_Value__c;
                    if(SovLineList[0].buildertek__Vendor__c != null){
                        sov.buildertek__Vendor__c = SovLineList[0].buildertek__Vendor__c;
                    }
                }
                update vendorsovlist;
            }  
            
       
            
            
            
            if(!vendorsovlist.isEmpty()){          
                
                List<buildertek__Schedule_of_Value_Lines__c> stdLinesovlist = [select Id,buildertek__Schedule_of_Values__c,buildertek__Scheduled_Value__c,
                                                                               buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: vendorsovlist[0].buildertek__Schedule_of_Values__c ];
                
                
                
                set<string> StIdsList = new set<string>();
                
                if(!stdLinesovlist.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:stdLinesovlist){
                        
                        StIdsList.add(sov.Id);
                    }
                }
                
                system.debug('StIdsList---------->'+StIdsList);
                
                List<buildertek__Schedule_of_Value_Lines__c> slList = [select Id,
                                                                       buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                       buildertek__Status__c,buildertek__Scheduled_Value__c,
                                                                       buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN: StIdsList AND buildertek__Status__c = 'Approved' ];
                
                system.debug('slList-------->'+slList);
                
                
                
                set<string> SL = new set<string>();
                
                if(!slList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:slList){
                        
                        SL.add(sov.Id);
                    }
                }
                
                
                for(buildertek__Schedule_of_Value_Lines__c SSOV : stdLinesovlist){
                    system.debug('tttttttttttttttttttt----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c != null){
                        
                        for(buildertek__Schedule_of_Value_Lines__c SID : slList){
                            system.debug('hhhhhhhhhhhhhhhhhh----->'+SID.Id);
                            if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(SID.Id) ){
                                system.debug('aaaaaaaaaaaaaaaaa');
                                system.debug('qwertyuiohg----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                                SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(SID.Id, '');
                                if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(',,')){
                                    SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(',,', ',');
                                }
                                SSOV.buildertek__Scheduled_Value__c = SSOV.buildertek__Scheduled_Value__c - SID.buildertek__Scheduled_Value__c;
                                system.debug('zzzzzzzzzzzzzzzzz');
                            }
                        }
                    }
                    
                }
                
                
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                update stdLinesovlist;
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                
                
                
              
                list<string> Ids = new list<string>();
                for(buildertek__Schedule_of_Value_Lines__c Sch : stdLinesovlist){
                    system.debug('Sch.buildertek__Old_Sov_Line_Ids_From_Project__c-------->'+Sch.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    if(Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != null ){
                           Ids.add(Sch.id);
                       }
                }
                
                
                list<buildertek__Schedule_of_Value_Lines__c> consolidatedLineList = [select Id, Name, buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where Id IN: Ids];
                
                
                system.debug('consolidatedLineList------->'+consolidatedLineList);
                
                list<buildertek__Schedule_of_Value_Lines__c> nullConRecList = new list<buildertek__Schedule_of_Value_Lines__c>();
                
                
                system.debug('consolidatedLineList---------->'+consolidatedLineList);
                
                if(!consolidatedLineList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c Schrec : consolidatedLineList){
                        system.debug('Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c----->'+Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c);
                            if(Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == null ||
                               Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == '' || Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == ','){
                                   nullConRecList.add(Schrec);
                               }
                        
                    }
                }
                
                
                system.debug('Ids*********'+Ids);
                system.debug('nullConRecList------->'+nullConRecList);
                
                if(!Ids.isEmpty()){
                    delete nullConRecList;
                }
                
                
            }
            
            
            
            
            
            return 'success';
        }else{
            return null;
        }  
    }
     @AuraEnabled
    public static string getAllApproved(List<String> sovLineIds) {
        try {
            system.debug('@@@@@@@@@@@@@sovLineIds'+sovLineIds);
            List<buildertek__Schedule_of_Value_Lines__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN:sovLineIds];
           
            
            List<buildertek__Schedule_of_Value_Lines__c> rejectedLines = [select Id, Name,buildertek__Schedule_of_Values__c, buildertek__Status__c,buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN:sovLineIds and (buildertek__Status__c = 'Rejected' OR buildertek__Status__c = 'Vendor Submitted')];
            List<string> stndSovIds = new List<string>();
            
            set<string> StandardSOVId = new set<string>();
            
            if(!rejectedLines.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:rejectedLines){
                    stndSovIds.add(sov.Id);
                }
            }
       
             
            List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c,
                                                                          buildertek__Vendor__c ,
                                                                          buildertek__Scheduled_Value__c,
                                                                          buildertek__Schedule_of_Values__c,
                                                                          buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                          buildertek__Status__c,
                                                                          buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c,
                                                                          buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c,
                                                                          buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c IN: stndSovIds];
            system.debug('vendorsovlist------>'+vendorsovlist);
            
               if(!vendorsovlist.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:vendorsovlist){
                    
                    StandardSOVId.add(sov.buildertek__Schedule_of_Values__c);
                }
            }
            
            system.debug('StandardSOVId------>'+StandardSOVId);
            
         
            
            if(!SovLineList.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:SovLineList){
                    sov.buildertek__Status__c = 'Approved';
                    sov.buildertek__Rejection_Reason__c = '';
                }
                update SovLineList;
                
                if(!vendorsovlist.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov :vendorsovlist){
                        sov.buildertek__Status__c = 'Approved';
                        sov.buildertek__Rejection_Reason__c = '';
                        system.debug('sov.buildertek__Vendor_SOV_Line__c------>'+sov.buildertek__Vendor_SOV_Line__c);
                        if(sov.buildertek__Vendor_SOV_Line__c != null){
                            system.debug('sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c ------>'+sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c );
                            if(sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c != null){
                                sov.buildertek__Scheduled_Value__c = sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c;
                            }
                            system.debug('sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c ------>'+sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c );
                            if(sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c != null){
                                sov.buildertek__Vendor__c = sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c;
                            }
                        }
                        
                    }
                    update vendorsovlist;
                } 
                
                
                   List<buildertek__Schedule_of_Value_Lines__c> stdLinesovlist = [select Id,buildertek__Schedule_of_Values__c,buildertek__Scheduled_Value__c,buildertek__isConsolidated__c,
                                                                          buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c IN: StandardSOVId ];
            
             system.debug('stdLinesovlist----------->'+stdLinesovlist);
                
                 set<string> StIdsList = new set<string>();
                
                if(!stdLinesovlist.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:stdLinesovlist){
                        
                        StIdsList.add(sov.Id);
                    }
                }
                
                system.debug('StIdsList---------->'+StIdsList);
                
                List<buildertek__Schedule_of_Value_Lines__c> slList = [select Id,
                                                                               buildertek__Old_Sov_Line_Ids_From_Project__c,buildertek__isConsolidated__c,
                                                                               buildertek__Status__c,buildertek__Scheduled_Value__c,
                                                                               buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN: StIdsList AND buildertek__Status__c = 'Approved' ];
                
                system.debug('slList-------->'+slList);
                
                
                
                set<string> SL = new set<string>();
                
                if(!slList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:slList){
                        
                        SL.add(sov.Id);
                    }
                }
                
            
            for(buildertek__Schedule_of_Value_Lines__c SSOV : stdLinesovlist){
                system.debug('tttttttttttttttttttt----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c != null){
                    
                    for(buildertek__Schedule_of_Value_Lines__c SID : slList){
                        system.debug('hhhhhhhhhhhhhhhhhh----->'+SID.Id);
                        if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(SID.Id) ){
                            system.debug('qwertyuyih----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                            SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(SID.Id, '');
                            if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(',,')){
                                SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(',,', ',');
                            }
                            SSOV.buildertek__Scheduled_Value__c = SSOV.buildertek__Scheduled_Value__c - SID.buildertek__Scheduled_Value__c;
                            system.debug('zzzzzzzzzzzzzzzzz');
                        }
                    }
                }
                
            }
                
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                update stdLinesovlist;
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                
                system.debug('slList-------->'+slList);
                
                
                
                
                list<string> Ids = new list<string>();
                for(buildertek__Schedule_of_Value_Lines__c Sch : stdLinesovlist){
                    system.debug('Sch.buildertek__Old_Sov_Line_Ids_From_Project__c-------->'+Sch.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    if(Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
                       Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                           Ids.add(Sch.id);
                       }
                }
                
                
                list<buildertek__Schedule_of_Value_Lines__c> consolidatedLineList = [select Id, Name, buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where Id IN: Ids];
                
                
                system.debug('consolidatedLineList------->'+consolidatedLineList);
                
                list<buildertek__Schedule_of_Value_Lines__c> nullConRecList = new list<buildertek__Schedule_of_Value_Lines__c>();
                
                
                system.debug('consolidatedLineList---------->'+consolidatedLineList);
                
                if(!consolidatedLineList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c Schrec : consolidatedLineList){
                        system.debug('Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c----->'+Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c);
                            if(Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == null ||
                               Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == '' || Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == ','){
                                   nullConRecList.add(Schrec);
                               }
                        
                    }
                }
                
                
                system.debug('Ids*********'+Ids);
                system.debug('nullConRecList------->'+nullConRecList);
                
                if(!Ids.isEmpty()){
                    delete nullConRecList;
                }
                
                
                
                return 'success';
            }else{
                return null;
            }  
        }
        catch(Exception e){ 
            system.debug('error--->'+e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    
     @AuraEnabled
    public static String rejectSovLines(String sovLineIds,string rejectReason) {
        system.debug('sovLineIds--->'+ sovLineIds);
        List<buildertek__Schedule_of_Value_Lines__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id =:sovLineIds];
        
        if(!SovLineList.isEmpty()){
            for(buildertek__Schedule_of_Value_Lines__c sov :SovLineList){
                sov.buildertek__Status__c = 'Rejected';
                sov.buildertek__Rejection_Reason__c = rejectReason;
            }
            update SovLineList;
            return 'success';
        }else{
            return null;
        }  
    }
    
    
      @AuraEnabled
    public static string getAllApprovedexceptReject(List<String> sovLineIds) {
        try {
            system.debug('@@@@@@@@@@@@@sovLineIds'+sovLineIds);
            List<buildertek__Schedule_of_Value_Lines__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN:sovLineIds];
           
            
            List<buildertek__Schedule_of_Value_Lines__c> rejectedLines = [select Id, Name,buildertek__Schedule_of_Values__c, buildertek__Status__c,buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN:sovLineIds and (buildertek__Status__c = 'Rejected' OR buildertek__Status__c = 'Vendor Submitted')];
            List<string> stndSovIds = new List<string>();
            
            set<string> StandardSOVId = new set<string>();
            
            if(!rejectedLines.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:rejectedLines){
                    stndSovIds.add(sov.Id);
                }
            }
       
             
            List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c,
                                                                          buildertek__Vendor__c ,
                                                                          buildertek__Scheduled_Value__c,
                                                                          buildertek__Schedule_of_Values__c,
                                                                          buildertek__Old_Sov_Line_Ids_From_Project__c,
                                                                          buildertek__Status__c,
                                                                          buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c,
                                                                          buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c,
                                                                          buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c IN: stndSovIds];
            system.debug('vendorsovlist------>'+vendorsovlist);
            
               if(!vendorsovlist.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:vendorsovlist){
                    
                    StandardSOVId.add(sov.buildertek__Schedule_of_Values__c);
                }
            }
            
            system.debug('StandardSOVId------>'+StandardSOVId);
            
         
            
            if(!SovLineList.isEmpty()){
                for(buildertek__Schedule_of_Value_Lines__c sov:SovLineList){
                    if(sov.buildertek__Status__c != 'Rejected'){
                         sov.buildertek__Status__c = 'Approved';
                    sov.buildertek__Rejection_Reason__c = '';
                    }
                   
                }
                update SovLineList;
                
                if(!vendorsovlist.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov :vendorsovlist){
                        if(sov.buildertek__Status__c != 'Rejected'){
                            
                            sov.buildertek__Status__c = 'Approved';
                            sov.buildertek__Rejection_Reason__c = '';
                            system.debug('sov.buildertek__Vendor_SOV_Line__c------>'+sov.buildertek__Vendor_SOV_Line__c);
                            if(sov.buildertek__Vendor_SOV_Line__c != null){
                                system.debug('sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c ------>'+sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c );
                                if(sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c != null){
                                    sov.buildertek__Scheduled_Value__c = sov.buildertek__Vendor_SOV_Line__r.buildertek__Scheduled_Value__c;
                                }
                                system.debug('sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c ------>'+sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c );
                                if(sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c != null){
                                    sov.buildertek__Vendor__c = sov.buildertek__Vendor_SOV_Line__r.buildertek__Vendor__c;
                                }
                            }
                        }
                        
                    }
                    update vendorsovlist;
                } 
                
                
                   List<buildertek__Schedule_of_Value_Lines__c> stdLinesovlist = [select Id,buildertek__Schedule_of_Values__c,buildertek__Scheduled_Value__c,buildertek__isConsolidated__c,
                                                                          buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c IN: StandardSOVId ];
            
             system.debug('stdLinesovlist----------->'+stdLinesovlist);
                
                 set<string> StIdsList = new set<string>();
                
                if(!stdLinesovlist.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:stdLinesovlist){
                        
                        StIdsList.add(sov.Id);
                    }
                }
                
                system.debug('StIdsList---------->'+StIdsList);
                
                List<buildertek__Schedule_of_Value_Lines__c> slList = [select Id,
                                                                               buildertek__Old_Sov_Line_Ids_From_Project__c,buildertek__isConsolidated__c,
                                                                               buildertek__Status__c,buildertek__Scheduled_Value__c,
                                                                               buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN: StIdsList AND buildertek__Status__c = 'Approved' ];
                
                system.debug('slList-------->'+slList);
                
                
                
                set<string> SL = new set<string>();
                
                if(!slList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c sov:slList){
                        
                        SL.add(sov.Id);
                    }
                }
                
            
            for(buildertek__Schedule_of_Value_Lines__c SSOV : stdLinesovlist){
                system.debug('tttttttttttttttttttt----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c != null){
                    
                    for(buildertek__Schedule_of_Value_Lines__c SID : slList){
                        system.debug('hhhhhhhhhhhhhhhhhh----->'+SID.Id);
                        if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(SID.Id) ){
                            system.debug('qwertyuyih----->'+SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c);
                            SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(SID.Id, '');
                            if(SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.Contains(',,')){
                                SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c = SSOV.buildertek__Old_Sov_Line_Ids_From_Project__c.replace(',,', ',');
                            }
                            SSOV.buildertek__Scheduled_Value__c = SSOV.buildertek__Scheduled_Value__c - SID.buildertek__Scheduled_Value__c;
                            system.debug('zzzzzzzzzzzzzzzzz');
                        }
                    }
                }
                
            }
                
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                update stdLinesovlist;
                system.debug('stdLinesovlist----------->'+stdLinesovlist);
                
                system.debug('slList-------->'+slList);
                
                
                
                
                list<string> Ids = new list<string>();
                for(buildertek__Schedule_of_Value_Lines__c Sch : stdLinesovlist){
                    system.debug('Sch.buildertek__Old_Sov_Line_Ids_From_Project__c-------->'+Sch.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    if(Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != null &&
                       Sch.buildertek__Old_Sov_Line_Ids_From_Project__c != '' ){
                           Ids.add(Sch.id);
                       }
                }
                
                
                list<buildertek__Schedule_of_Value_Lines__c> consolidatedLineList = [select Id, Name, buildertek__Old_Sov_Line_Ids_From_Project__c from buildertek__Schedule_of_Value_Lines__c where Id IN: Ids];
                
                
                system.debug('consolidatedLineList------->'+consolidatedLineList);
                
                list<buildertek__Schedule_of_Value_Lines__c> nullConRecList = new list<buildertek__Schedule_of_Value_Lines__c>();
                
                
                system.debug('consolidatedLineList---------->'+consolidatedLineList);
                
                if(!consolidatedLineList.isEmpty()){
                    for(buildertek__Schedule_of_Value_Lines__c Schrec : consolidatedLineList){
                        system.debug('Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c----->'+Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c);
                            if(Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == null ||
                               Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == '' || Schrec.buildertek__Old_Sov_Line_Ids_From_Project__c == ','){
                                   nullConRecList.add(Schrec);
                               }
                        
                    }
                }
                
                
                system.debug('Ids*********'+Ids);
                system.debug('nullConRecList------->'+nullConRecList);
                
                if(!Ids.isEmpty()){
                    delete nullConRecList;
                }
                
                
                
                return 'success';
            }else{
                return null;
            }  
        }
        catch(Exception e){ 
            system.debug('error--->'+e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    
    
    
    
}