public class BT_SubmitRFQ {
    @AuraEnabled
    public static void UpdateRFQ(String rfqid) {
        set<Id> vendorIds = new set<Id>();
        buildertek__RFQ_To_Vendor__c rfqToVendor = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,
                                                              buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__Submitted_Date__c
                                                              from buildertek__RFQ_To_Vendor__c where Id =: rfqid];
        buildertek__RFQ__c rfqreclst;
        rfqreclst = [SELECT Id, Name, buildertek__RFQ_s_Replied_To__c,buildertek__Status__c,buildertek__RFQ_s_Sent__c FROM buildertek__RFQ__c WHERE Id = :rfqToVendor.buildertek__RFQ__c];
        /*for(buildertek__RFQ_To_Vendor__c rfqToVendor : rfqToVendorlist){
            if(rfqToVendor.buildertek__Vendor__c !=null){
                vendorIds.add(rfqToVendor.buildertek__Vendor__c);
            }
        }
        map<Id,Id> vendorUserMap = new map<Id,Id>();
        list<Id> vendorUser = new list<Id>();
        string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId, buildertek__Account_Id__c, isPortalEnabled '+
            'FROM User Where AccountId In:vendorIds  And isPortalEnabled=true  ';    
        list<User> usersList = Database.query(strQry);
        if(usersList.size() > 0){
            for(User usr: usersList){
                vendorUser.add(usr.AccountId);
            }
        }
        system.debug('rfqToVendor,yju');
        list<User> usersLis = [Select id,Name,AccountId from User where AccountId IN: vendorUser limit 1];*/
        string accountId = '';
        string portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, AccountId, isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();            
        }
        if(portalCode=='true'){
            accountId = userRec[0].get('AccountId').toString(); 
        }
        if(rfqToVendor.buildertek__Status__c != 'Quote Submitted' && rfqToVendor.buildertek__Vendor__c == accountId){
                    Integer numberOfDays = 0;
                    Integer countEmptyFields = 0;
                    Date acceptedDate;
                    Date submittedDate;
                    if (rfqToVendor.buildertek__RFQ__c != null){
                                if (rfqreclst.buildertek__RFQ_s_Replied_To__c != null){
                                    rfqreclst.buildertek__RFQ_s_Replied_To__c += 1;
                                } else{
                                    rfqreclst.buildertek__RFQ_s_Replied_To__c = 1;
                                }
                            update rfqreclst;
                        /* list<buildertek__RFQ_Vendor_Item__c> vendoritemlist1 = new list<buildertek__RFQ_Vendor_Item__c>();
boolean rfqline = false;
map<id,id> rfqvendor = new map <id,id>();
for (Integer k = 0; k < rfqToVendor.buildertek__Vendor_Items__r.size(); k++){
rfqvendor.put(rfqToVendor.buildertek__Vendor_Items__r[k].id,rfqToVendor.buildertek__Vendor_Items__r[k].id);
}
for (Integer j = 0; j < rfqreclst[0].buildertek__RFQ_Items__r.size(); j++){ 
for (Integer i = 0; i < rfqToVendor.buildertek__Vendor_Items__r.size(); i++){  
// if(rfqToVendor.buildertek__Vendor_Items__r[i].buildertek__RFQ_Item__c == rfqreclst[0].buildertek__RFQ_Items__r[j].id){
if(rfqvendor.get(rfqreclst[0].buildertek__RFQ_Items__r[j].id) != null && rfqToVendor.buildertek__Vendor_Items__r[i].buildertek__RFQ_Item__c == rfqreclst[0].buildertek__RFQ_Items__r[j].id){
rfqToVendor.buildertek__Vendor_Items__r[i].buildertek__Quantity__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Quantity__c;
rfqToVendor.buildertek__Vendor_Items__r[i].buildertek__Unit_Price__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Unit_Price__c;
} /*else {
buildertek__RFQ_Vendor_Item__c vendoritem = new buildertek__RFQ_Vendor_Item__c();
vendoritem.Name = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Item_Name__c = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Vendor__c = rfqToVendor.Id;
vendoritem.buildertek__RFQ_Item__c = rfqreclst[0].buildertek__RFQ_Items__r[j].id;
vendoritem.buildertek__Cost_code__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__cost_code__c;
vendoritem.buildertek__Quantity__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Quantity__c;
vendoritem.buildertek__Unit_Price__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Unit_Price__c;
vendoritem.buildertek__Description__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Description__c;
vendoritemlist1.add(vendoritem);
}*/
                        /*     if(rfqvendor.get(rfqreclst[0].buildertek__RFQ_Items__r[j].id) == null){
buildertek__RFQ_Vendor_Item__c vendoritem = new buildertek__RFQ_Vendor_Item__c();
vendoritem.Name = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Item_Name__c = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Vendor__c = rfqToVendor.Id;
vendoritem.buildertek__RFQ_Item__c = rfqreclst[0].buildertek__RFQ_Items__r[j].id;
vendoritem.buildertek__Cost_code__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__cost_code__c;
vendoritem.buildertek__Quantity__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Quantity__c;
vendoritem.buildertek__Unit_Price__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Unit_Price__c;
vendoritem.buildertek__Description__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Description__c;
vendoritemlist1.add(vendoritem);
}
}
}
if(vendoritemlist1.size() > 0){
insert vendoritemlist1;
}
list<buildertek__RFQ_Vendor_Item__c> vendoritemlist = new list<buildertek__RFQ_Vendor_Item__c>();
for (Integer j = 0; j < rfqreclst[0].buildertek__RFQ_Items__r.size(); j++){
system.debug('hi^^^^^^^^^^');
if(rfqToVendor.buildertek__Vendor_Items__r.size() == 0){
buildertek__RFQ_Vendor_Item__c vendoritem = new buildertek__RFQ_Vendor_Item__c();
vendoritem.Name = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Item_Name__c = rfqreclst[0].buildertek__RFQ_Items__r[j].Name;
vendoritem.buildertek__Vendor__c = rfqToVendor.Id;
vendoritem.buildertek__RFQ_Item__c = rfqreclst[0].buildertek__RFQ_Items__r[j].id;
vendoritem.buildertek__Cost_code__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__cost_code__c;
vendoritem.buildertek__Quantity__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Quantity__c;
vendoritem.buildertek__Unit_Price__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Unit_Price__c;
vendoritem.buildertek__Description__c = rfqreclst[0].buildertek__RFQ_Items__r[j].buildertek__Description__c;
vendoritemlist.add(vendoritem);
}
}
if(vendoritemlist.size() > 0){
system.debug('vendoritemlist'+vendoritemlist);
insert vendoritemlist;
}*/
                        if (rfqToVendor.buildertek__Accepted_Date__c != null){
                            acceptedDate = rfqToVendor.buildertek__Accepted_Date__c.Date();
                        }
                        if (rfqToVendor.buildertek__Submitted_Date__c != null){
                            submittedDate = rfqToVendor.buildertek__Submitted_Date__c.Date();
                        }
                        if (acceptedDate != null && submittedDate != null){
                            numberOfDays = submittedDate.daysBetween(acceptedDate);
                        }
                        system.debug('rfqToVendor.buildertek__Status__c1'+rfqToVendor.buildertek__Status__c);
                        //rfqToVendor.buildertek__Send_Invitation__c = true;
                        rfqToVendor.buildertek__Days_Outstanding__c = numberOfDays; 
                        rfqToVendor.buildertek__Submitted_Date__c = system.now();
                        rfqToVendor.buildertek__Status__c = 'Quote Submitted';
                        system.debug('rfqToVendor.buildertek__Status__c'+rfqToVendor.buildertek__Status__c);
                        update rfqToVendor;
                    }
                    
            
          List<buildertek__RFQ_Vendor_Item__c> vendorRFQLinesList=[SELECT Id, 
                                                               Name,
                                                               buildertek__Vendor__c,
                                                                buildertek__Vendor__r.buildertek__Status__c, 
                                                                buildertek__Vendor_Name__c,
                                                                buildertek__Quantity__c,
                                                                buildertek__Unit_Price__c,
                                                                buildertek__Vendor_Quantity__c,
                                                                buildertek__Vendor_Unit_Price__c,
                                                                buildertek__Note__c,
                                                                buildertek__Vendor_Note__c,buildertek__Estimated_Work_Days__c,buildertek__Vendor_Estimated_Work_Days__c,
                                                                buildertek__Item_Name__c,
                                                                buildertek__isVendorRFQSubmited__c,
                                                                buildertek__RFQ_Item__c FROM buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c =:rfqToVendor.Id and buildertek__Vendor__r.buildertek__Status__c=:'Quote Submitted'];
            for(buildertek__RFQ_Vendor_Item__c vendorRFQ:vendorRFQLinesList){
                vendorRFQ.buildertek__isVendorRFQSubmited__c=false;
                vendorRFQ.buildertek__Quantity__c = vendorRFQ.buildertek__Vendor_Quantity__c;
                vendorRFQ.buildertek__Unit_Price__c = vendorRFQ.buildertek__Vendor_Unit_Price__c;
                vendorRFQ.buildertek__Vendor_Note__c= vendorRFQ.buildertek__Note__c;
                vendorRFQ.buildertek__Estimated_Work_Days__c= vendorRFQ.buildertek__Vendor_Estimated_Work_Days__c;
                
            }
            update vendorRFQLinesList;
        }
        
        
    }
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    @AuraEnabled
    public static String getrfq(string RecordId){
       buildertek__RFQ_To_Vendor__c rfqToVendor = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,
                                                              buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,
                                                              buildertek__Submitted_Date__c from buildertek__RFQ_To_Vendor__c where ID =: RecordId]; 
        return rfqToVendor.buildertek__RFQ__c;
    }
    @AuraEnabled
    public static buildertek__RFQ_To_Vendor__c getRQToAccount(String recordId){
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Status__c,
                                                     buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        //return rfqToAccount.buildertek__Status__c;
       return rfqToAccount;
    }


    @AuraEnabled
    public static String validateRFIs(string RecordId){
        System.debug('RecordId'+RecordId);
        string status = '';
       list<buildertek__RFI__c> rfislist = [SELECT Id FROM buildertek__RFI__c 
       where buildertek__RFQ_To_Vendor__c =:RecordId];

       integer rfiscount = 0;
       if(rfislist.size()>0){
            rfiscount = rfislist.size();
       }
       System.debug(rfiscount);
       list<buildertek__RFI__c> rfisstatuslist = new list<buildertek__RFI__c>();
       rfisstatuslist = [SELECT Id FROM buildertek__RFI__c 
       where buildertek__RFQ_To_Vendor__c =:RecordId
       and buildertek__Status__c ='Closed'];
       integer rfisclosedcount = 0;
       System.debug(rfisclosedcount);
       if(rfisstatuslist!=null){
            if(rfisstatuslist.size()>0){
                rfisclosedcount = rfisstatuslist.size();
            }
       }   
       
       if(rfiscount>0 && rfiscount != rfisclosedcount){
          status = 'RFIs Not Closed'; 
       } if((rfiscount>0 || rfiscount == 0)&& rfiscount == rfisclosedcount){
          status = 'RFIs Closed'; 
       }
       
       return status;

    }
@AuraEnabled
     public static innerclass checkduedate(String recordId){
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__r.buildertek__Due_Date__c,buildertek__RFQ__c, buildertek__RFQ__r.buildertek__Status__c from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        system.debug('duedate'+parentId.buildertek__RFQ__r.buildertek__Due_Date__c);
         System.debug('today'+system.today());
         Boolean isdueexp = false;
         if(parentId.buildertek__RFQ__r.buildertek__Due_Date__c < system.today()){
             isdueexp = true;
         }
         innerclass inn = new innerclass();
         inn.isdueexp = isdueexp;
        inn.RFQStatus = parentId.buildertek__RFQ__r.buildertek__Status__c;
         return inn;
        }
    
    public class innerclass{
        @AuraEnabled
        public boolean isdueexp;
        @AuraEnabled
        public String RFQStatus;
    }


}