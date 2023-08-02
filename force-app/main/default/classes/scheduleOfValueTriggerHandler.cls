public class scheduleOfValueTriggerHandler {
    
    public static boolean isRecursive = false;
    public static Boolean blnSkipSOVTrigger = false;
    
     public static Boolean blnSkipSOVForEmail = false;
    
    public static Boolean blnSkipSOVTriggerUpdate = false;
    
    public void isAfterUpdate(list<buildertek__Schedule_of_Values__c> oldSovValues , list<buildertek__Schedule_of_Values__c> newSovValues,  Map<Id, buildertek__Schedule_of_Values__c> newSovMap, Map<Id, buildertek__Schedule_of_Values__c> oldSovMap){
        
        
        
      /*  list<buildertek__Schedule_of_Values__c>  SOVRec1  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id IN: newSovValues LIMIT 10000 ];
        
        
        for(buildertek__Schedule_of_Values__c sov:SOVRec1){
            sov.buildertek__Type__c = sov.RecordType.Name;
        }
        
        
        if(SOVRec1.size()>0){
            scheduleOfValueTriggerHandler.blnSkipSOVTriggerUpdate = true;
           // update SOVRec1;
            scheduleOfValueTriggerHandler.blnSkipSOVTriggerUpdate = false;
            
        } */
        
        
        
        set<Id>payid = new set<Id>();
        system.debug('newSovValues'+newSovValues);
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry1);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        
        
        List<string> sovIds1 = new List<string>();
        List<buildertek__Schedule_of_Value_Lines__c> sovLinesList = new List<buildertek__Schedule_of_Value_Lines__c>();
        Map<Id,String> Sovmap = new Map<Id,String>();
        for(buildertek__Schedule_of_Values__c sov:newSovValues){
            sovIds1.add(sov.Id);
            Sovmap.put(sov.Id,sov.buildertek__Status__c);
        }
        List<buildertek__Schedule_of_Value_Lines__c> sovLines = new List<buildertek__Schedule_of_Value_Lines__c>();
        if(sovIds1.size() > 0){
            sovLines = [SELECT Id,
                        buildertek__Status__c,
                        buildertek__Schedule_of_Values__c,
                        buildertek__Schedule_of_Values__r.buildertek__Type__c,
                        buildertek__Schedule_of_Values__r.RecordTypeId,
                        buildertek__Schedule_of_Values__r.recordtype.name,
                        buildertek__isConsolidated__c 
                        FROM buildertek__Schedule_of_Value_Lines__c
                        WHERE buildertek__Schedule_of_Values__c IN:sovIds1  LIMIT 10000];
        }
        system.debug(sovLines);
        for(buildertek__Schedule_of_Value_Lines__c line:sovLines){
            if(line.buildertek__Schedule_of_Values__r.recordtype.name == 'Vendor'){
                if(portalCode == 'false'){
                    if(Sovmap.get(line.buildertek__Schedule_of_Values__c) == 'Company Submitted'){
                        line.buildertek__Status__c = 'Company Submitted';
                        sovLinesList.add(line);
                    }/* else if(Sovmap.get(line.buildertek__Schedule_of_Values__c) == 'Company Approved'){
line.buildertek__Status__c = 'Approved';
sovLinesList.add(line);
} */
                } 
                
            }else  if(line.buildertek__Schedule_of_Values__r.recordtype.name == 'Standard'){
                if(portalCode == 'false'){
                    system.debug(Sovmap.get(line.buildertek__Schedule_of_Values__c));
                    if(Sovmap.get(line.buildertek__Schedule_of_Values__c) == 'Customer Approved'){
                        system.debug(line.buildertek__Status__c);
                        if(line.buildertek__Status__c == 'Pending' && line.buildertek__isConsolidated__c == false){
                            line.buildertek__Status__c = 'Customer Approved';
                            sovLinesList.add(line);
                        }
                        
                    }  
                }
                
                system.debug('line.buildertek__Schedule_of_Values__r.recordtype.name'+line.buildertek__Schedule_of_Values__r.recordtype.name);
            }else  if(line.buildertek__Schedule_of_Values__r.recordtype.name == 'Standard'){
                if(portalCode == 'false'){
                    system.debug('Sovmap.get(line.buildertek__Schedule_of_Values__c'+Sovmap.get(line.buildertek__Schedule_of_Values__c));
                    if(Sovmap.get(line.buildertek__Schedule_of_Values__c) == 'Customer Rejected'){
                        
                        line.buildertek__Status__c = 'Customer Rejected';
                        sovLinesList.add(line);
                        
                        
                    }  
                }
                
            }
            
        }
        system.debug('***************************'+sovLinesList);
        if(!sovLinesList.isEmpty()){
            
            
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = true;
            update sovLinesList;
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = false;
            
            
        }
        
        
        List<buildertek__Schedule_of_Value_Lines__c> IntparentSOVList = new List<buildertek__Schedule_of_Value_Lines__c>();
        
        List<buildertek__Schedule_of_Values__c> sovList = [SELECT Id, buildertek__Status__c, buildertek__Type__c,
                                                           (SELECT Id, buildertek__Status__c ,buildertek__Vendor_Scheduled_Value__c,buildertek__Scheduled_Value__c FROM buildertek__Schedule_of_Values_Lines__r) 
                                                           FROM buildertek__Schedule_of_Values__c WHERE Id IN: newSovValues  LIMIT 10000];
        
        
        for(buildertek__Schedule_of_Values__c sovRec : sovList){
            
            if(portalCode == 'true'){
                if(sovRec.buildertek__Status__c == 'Vendor Submitted'){
                    for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovRec.buildertek__Schedule_of_Values_Lines__r){
                        sovLineRec.buildertek__Scheduled_Value__c = sovLineRec.buildertek__Vendor_Scheduled_Value__c;
                        IntparentSOVList.add(sovLineRec);
                    }
                }
            }else{
                for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovRec.buildertek__Schedule_of_Values_Lines__r){
                    if(sovLineRec.buildertek__Scheduled_Value__c != null ){
                        sovLineRec.buildertek__Vendor_Scheduled_Value__c = sovLineRec.buildertek__Scheduled_Value__c;
                        IntparentSOVList.add(sovLineRec);
                    }
                    
                }
            }
            
        }
        
        system.debug('IntparentSOVList-------->'+IntparentSOVList);
        
        if(!IntparentSOVList.isEmpty()){
            
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = true;
            update IntparentSOVList;
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = false;
            
        }
        system.debug('IntparentSOVList-------->'+IntparentSOVList);
        
        
        
        
        
        list<buildertek__Schedule_of_Values__c>  testlist = [select Id, name,buildertek__Status__c from buildertek__Schedule_of_Values__c where Id IN: newSovValues  LIMIT 10000];
        
        
        list<buildertek__Schedule_of_Value_Lines__c> StandardSovList = [Select Id,Name, buildertek__Schedule_of_Values__c, buildertek__Schedule_of_Values__r.buildertek__Status__c, buildertek__Old_Sov_Line_Ids_From_Project__c From buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c IN:newSovValues  LIMIT 10000];
        
        list<string> OldSovlineIds = new list<string>();
        
        for(buildertek__Schedule_of_Value_Lines__c OldSovLineRecords : StandardSovList){
            system.debug(OldSovLineRecords.buildertek__Schedule_of_Values__r.buildertek__Status__c);
            if(OldSovLineRecords.buildertek__Schedule_of_Values__r.buildertek__Status__c == 'Company Approved'){
                system.debug(OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c);
                if(OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c != null){
                    system.debug(OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    if(OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c.contains('_')){
                        List<String> newList = OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c.split('_');
                        for(String s:newList ){
                            OldSovlineIds.add(s);
                        }
                        
                    }else{
                        system.debug('else');
                        OldSovlineIds.add(OldSovLineRecords.buildertek__Old_Sov_Line_Ids_From_Project__c);
                    }
                }
            }
        }
        
        system.debug('OldSovlineIds'+OldSovlineIds);
        
        list<buildertek__Schedule_of_Value_Lines__c> OldSovLineParentList = [select Id, Name,buildertek__Schedule_of_Values__c,buildertek__Schedule_of_Values__r.buildertek__Status__c from buildertek__Schedule_of_Value_Lines__c where Id IN: OldSovlineIds  LIMIT 10000 ];
        List<string> updateSovIdList = new List<string>();
        List<buildertek__Schedule_of_Values__c> updateSovList = new List<buildertek__Schedule_of_Values__c>();
        system.debug(OldSovLineParentList);
        for(buildertek__Schedule_of_Value_Lines__c VendorSovParent : OldSovLineParentList){
            if(VendorSovParent.buildertek__Schedule_of_Values__c != null){
                buildertek__Schedule_of_Values__c updateSov = new buildertek__Schedule_of_Values__c();
                system.debug(updateSov.buildertek__Status__c);
                updateSov.buildertek__Status__c = 'Company Approved';
                system.debug(updateSov.buildertek__Status__c);
                system.debug(VendorSovParent.buildertek__Schedule_of_Values__c);
                updateSov.Id = VendorSovParent.buildertek__Schedule_of_Values__c;
                
                system.debug(updateSovIdList.contains(updateSov.Id));
                system.debug(updateSov);
                if(!updateSovIdList.contains(updateSov.Id)){
                    updateSovList.add(updateSov);
                    system.debug(updateSovList);
                }
                updateSovIdList.add(VendorSovParent.buildertek__Schedule_of_Values__c);
                
                //VendorSovParent.buildertek__Schedule_of_Values__r.buildertek__Status__c = 'Company Approved';
            }
        }
        if(updateSovList.Size()> 0){
            
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = true;
            update updateSovList;
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = false;
            
            
            
            system.debug('updateSovList'+updateSovList);
        }
        isRecursive = true;
        
        
        //  Code for giving permission to master sov for community
        List<buildertek__Schedule_of_Values__Share> rfqshareList = new List<buildertek__Schedule_of_Values__Share>();
        
        list<buildertek__Schedule_of_Values__c>  SOVRec  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name,  buildertek__Status__c, buildertek__Vendor__c  from buildertek__Schedule_of_Values__c where Id IN: newSovValues AND (recordtype.name = 'Vendor' OR recordtype.name = 'Master')  LIMIT 10000];
        system.debug('masterSovList---->'+ SOVRec );
        
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
        
        list<Id> oldVendorIds= New list<Id>();
        List<Id> sovIds = new List<Id>();
        
        
       // ----------------------------------------------------
        
        system.debug('oldSovValues------->'+oldSovValues);
        
        if(oldSovValues!= null){
        list<buildertek__Schedule_of_Values__c>  OldSOVRec  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name,  buildertek__Status__c, buildertek__Vendor__c  from buildertek__Schedule_of_Values__c where Id IN: oldSovValues AND (recordtype.name = 'Vendor' OR recordtype.name = 'Master')  LIMIT 10000];
        
        List<String> OldSOVRecIds = new List<String> ();
         
            if(!OldSOVRec.isEmpty()){
            
        for(buildertek__Schedule_of_Values__c SV :OldSOVRec){
            if(oldSovMap.get(SV.Id).buildertek__Vendor__c != SV.buildertek__Vendor__c){
                OldSOVRecIds.add(SV.Id);
            }
            
        }
            }
        
       List<buildertek__Schedule_of_Values__Share> OldSovShareRec =  [SELECT Id, ParentId
            FROM buildertek__Schedule_of_Values__Share
            WHERE ParentId IN: OldSOVRecIds AND RowCause = 'Manual'  LIMIT 10000]; 
            
        
        if(!OldSovShareRec.isEmpty()){
            delete OldSovShareRec;
        } 
         }
       
      //  -----------------------------------------------------------------
        
        if(SOVRec.size()>0){
        for (buildertek__Schedule_of_Values__c rfqVendor : SOVRec){
            for(User usr1: usersList){
                
                system.debug('usrrec--->'+usersList ); 
                if(rfqVendor.recordtype.name == 'Vendor' &&   rfqVendor.buildertek__Status__c == 'Company Submitted' && rfqVendor.buildertek__Vendor__c != null){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    system.debug('rfqVendor.buildertek__Vendor__c------->'+rfqVendor.buildertek__Vendor__c);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId ){
                        buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                    
                }
                else if(rfqVendor.recordtype.name == 'Master'){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    system.debug('rfqVendor.buildertek__Vendor__c------->'+rfqVendor.buildertek__Vendor__c);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId || rfqVendor.buildertek__Vendor__c == null ){
                        buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    }
                } 
            } 
        }
        
        system.debug('rfqshareList -------> '+rfqshareList);
        if(rfqshareList.size()>0){
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
        }
        
        }
        
        
        
        List<String> vendorrecordIds = new List<String>();
        Map<String,string> vendorMap = new Map<String,String>();
        for(buildertek__Schedule_of_Values__c sov:newSovValues){
            vendorrecordIds.add(sov.buildertek__Vendor__c);
        }
        List<Account> accList = [Select Id,buildertek__Email_Address__c from Account Where Id IN:vendorrecordIds  LIMIT 10000];
        for(Account ac:accList){
            vendorMap.put(ac.Id,ac.buildertek__Email_Address__c);
        }
        
        
        
        
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='SOV Reject Notification'];
        List<contact> conlist = [select id,name, Email from contact where Email != null limit 1];
        for(buildertek__Schedule_of_Values__c sov:newSovValues){
            if(sov.buildertek__Status__c == 'Company Rejected'){
                string EmaiValue = vendorMap.get(sov.buildertek__Vendor__c);
                 
                if(EmaiValue != null && EmaiValue != ''){
                    system.debug('@@@@@@@@@@'+EmaiValue);
                    string htmlbody = '';
                    List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTemplateId(et.Id);
                    msg.setWhatId(sov.Id);
                    msg.setTargetObjectId(conlist[0].Id);
                    msg.toAddresses = new String[] { EmaiValue };
                        //msg.setToAddresses(new list<string>{EmaiValue});
                        lstMsgs.add(msg);
                    //Messaging.sendEmail(lstMsgs);
                    Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(lstMsgs);
                    Database.rollback(sp);
                    
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new list<string>{EmaiValue});
                    email.setSubject(lstMsgs[0].Subject);
                    //email.setPlainTextBody(emailBody);
                    email.setHtmlBody(lstMsgs[0].getHTMLBody());
                    
                    if(scheduleOfValueTriggerHandler.blnSkipSOVForEmail == false){
                        system.debug('send mails---->');
                        if(email != null){
                           Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                        }
                         
                        scheduleOfValueTriggerHandler.blnSkipSOVForEmail = true;
                    }
                    
                   
                    
                }else{
                    //sov.addError('Vendor Email Should not be null');
                }
                
                
            }
        }
        
        
    }
    
    
    public void OnBeforeupdate(list<buildertek__Schedule_of_Values__c> oldSovValues , list<buildertek__Schedule_of_Values__c> newSovValues,  Map<ID, buildertek__Schedule_of_Values__c> newSovMap,  Map<ID, buildertek__Schedule_of_Values__c> oldSovMaps){

        
        set<Id>payid = new set<Id>();
        system.debug('newSovValues'+newSovValues);
        system.debug('oldSovMaps'+oldSovMaps);
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        
        
        List<string> sovIds = new List<string>();
        List<buildertek__Schedule_of_Value_Lines__c> sovLinesList = new List<buildertek__Schedule_of_Value_Lines__c>();
        Map<Id,String> Sovmap = new Map<Id,String>();
        for(buildertek__Schedule_of_Values__c sov:newSovValues){
            sovIds.add(sov.Id);
            Sovmap.put(sov.Id,sov.buildertek__Status__c);
        }
        List<buildertek__Schedule_of_Value_Lines__c> sovLines = new List<buildertek__Schedule_of_Value_Lines__c>();
        if(sovIds.size() > 0){
            sovLines = [SELECT Id,
                        buildertek__Status__c,
                        buildertek__Schedule_of_Values__c,
                        buildertek__Schedule_of_Values__r.buildertek__Type__c,
                        buildertek__Schedule_of_Values__r.RecordTypeId,
                        buildertek__Schedule_of_Values__r.recordtype.name,
                        buildertek__isConsolidated__c 
                        FROM buildertek__Schedule_of_Value_Lines__c
                        WHERE buildertek__Schedule_of_Values__c IN:sovIds];
        }
        system.debug(sovLines);
        for(buildertek__Schedule_of_Value_Lines__c line:sovLines){
            system.debug('line.buildertek__Schedule_of_Values__r.recordtype.name'+line.buildertek__Schedule_of_Values__r.recordtype.name);
            if(line.buildertek__Schedule_of_Values__r.recordtype.name == 'Standard'){
                if(portalCode == 'false'){
                    system.debug('Sovmap.get(line.buildertek__Schedule_of_Values__c)'+Sovmap.get(line.buildertek__Schedule_of_Values__c));
                    if(Sovmap.get(line.buildertek__Schedule_of_Values__c) == 'Customer Rejected'){
                        
                        line.buildertek__Status__c = 'Customer Rejected';
                        sovLinesList.add(line);
                        
                        
                    }  
                }
                
            }
            
        }
        system.debug('***************************'+sovLinesList);
        if(!sovLinesList.isEmpty()){
            
            
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = true;
            // update sovLinesList;
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = false;
            
            // isRecursive = true;
            
            
        }
    }
    
    
    public void isBeforeInsert(list<buildertek__Schedule_of_Values__c> oldSovValues , list<buildertek__Schedule_of_Values__c> newSovValues,  Map<ID, buildertek__Schedule_of_Values__c> newSovMap,  Map<ID, buildertek__Schedule_of_Values__c> oldSovMap){
     
        
    }
    
    public void isAfterInsert(list<buildertek__Schedule_of_Values__c> oldSovValues , list<buildertek__Schedule_of_Values__c> newSovValues,  Map<ID, buildertek__Schedule_of_Values__c> newSovMap,  Map<ID, buildertek__Schedule_of_Values__c> oldSovMap){
        
     
        
        //  Code for giving permission to master sov for community
        List<buildertek__Schedule_of_Values__Share> rfqshareList=new List<buildertek__Schedule_of_Values__Share>();
        
        list<buildertek__Schedule_of_Values__c>  SOVRec  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id IN: newSovValues AND (recordtype.name = 'Vendor' OR recordtype.name = 'Master' ) LIMIT 10000];
        system.debug('masterSovList---->'+ SOVRec );
        
       /* list<buildertek__Schedule_of_Values__c>  SOVRec1  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id IN: newSovValues LIMIT 10000 ];
        
        
        for(buildertek__Schedule_of_Values__c sov:SOVRec1){
            sov.buildertek__Type__c = sov.RecordType.Name;
        }
        
        
        if(SOVRec1.size()>0){
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = true;
           // update SOVRec1;
            scheduleOfValueTriggerHandler.blnSkipSOVTrigger = false;
          
        }        */
        
        
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
        
        if(SOVRec.size()>0){
        for (buildertek__Schedule_of_Values__c rfqVendor : SOVRec){
            for(User usr1: usersList){
                system.debug('usrrec--->'+usersList ); 
                if(rfqVendor.recordtype.name == 'Vendor' &&  rfqVendor.buildertek__Status__c == 'Company Submitted' && rfqVendor.buildertek__Vendor__c != null){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId){
                        buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                    
                }
                
                else if(rfqVendor.recordtype.name == 'Master'){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId || rfqVendor.buildertek__Vendor__c == null){
                        buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'Edit';
                        rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                } 
            } 
        }
        
        system.debug('rfqshareList -------> '+rfqshareList);
        if(rfqshareList.size()>0){
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
        }
        }
        
    }
    
    
     
    public void isBeforeDelete(List<buildertek__Schedule_of_Values__c> PaymentToDelete){
        
      
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        // if(userRec[0].IsPortalEnabled == true){
        if(portalCode != null && portalCode != ''){
            if(boolean.valueof(portalCode) == true){
                system.debug('PaymentToDelete'+PaymentToDelete);
                for (buildertek__Schedule_of_Values__c payment : PaymentToDelete){
                    system.debug('hai');
                    if (payment.buildertek__Status__c == 'Vendor Submitted' || payment.buildertek__Status__c == 'Company Approved' || payment.buildertek__Status__c == 'Customer Approved' || payment.buildertek__Status__c == 'Company Rejected' || payment.buildertek__Status__c == 'Customer Rejected' ){
                        system.debug('helo');
                        payment.adderror('You cannot Delete this SOV because the Status has been set to '+payment.buildertek__Status__c+'. You will need to contact your Administrator to have the Status updated before you can Delete this record. ' );
                        
                    }
                }
            }
            
        }
        
        // system.debug('PaymentMap'+PaymentMap);
        
    }
    
    
}