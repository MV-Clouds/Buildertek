/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  27-Sep-2017
*/
public with sharing class RFQDAO{
    /**************************************************************************
Purpose: Award Vendor
Parameters: vendor id
Returns: NA
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static String awardVendor(String vendorId){
        
        try{
            RFQ_To_Vendor__c rfqToVendor = new RFQ_To_Vendor__c();
            //   if(Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable()){
            //          rfqToVendor.Id = vendorId;
            //          rfqToVendor.Status__c = 'Awarded';
            //   }
            List<RFQ_To_Vendor__c> rfqVendorList;
            if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isAccessible()){
                rfqVendorList = [select Id, Status__c
                                 from RFQ_To_Vendor__c
                                 where Id = :vendorId];
            }
            if (rfqVendorList.size() > 0){
                for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                    if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable()){
                        rfqVendor.Status__c = 'Awarded';
                    }
                    //      rfqVendors.add(rfqVendor);
                }
            }
            update rfqVendorList;
            
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static string getRfqTo(){
        //  System.debug('%%%%%'+UserInfo.isMultiCurrencyOrganization());
        //  if(UserInfo.isMultiCurrencyOrganization()){
        return UserInfo.getDefaultCurrency();
        //   }else{
        //    return null;
        //  }
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
        return UserInfo.isMultiCurrencyOrganization();
    }
    @AuraEnabled
    public Static rfqConfig getRfqConfig(String rfqId){
        
        try{
            String query = 'Select Vendor__r.Vendor__c,Vendor__r.Name, Quote__r.Name, Budget__r.Name, (Select id from RFQ_To_Vendors__r), (Select id from RFQ_Items__r), ' + BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c')+' From RFQ__c where Id =:rfqId';
            list<buildertek__RFQ__c> rfqlst;
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Budget__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Vendor__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible()){
                rfqlst = Database.query(String.escapeSingleQuotes(query));
            }
            
            return new rfqConfig((RFQ__c)rfqlst[0]);
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public Static List<RFQ_To_Vendor__c> getRfqToVendors(String rfqId){
        try{
            System.debug('rfqId>>>'+rfqId);
            RFQ__c rfq;
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Trade_Type__c.isAccessible()){
                rfq = [select Id, buildertek__Trade_Type__c
                       from buildertek__RFQ__c
                       where Id = :rfqId];
            }
            List<buildertek__RFQ_To_Vendor__c> rfqVendorsList;
            if(UserInfo.isMultiCurrencyOrganization()){
                string rfqrecords = 'select Id, Name, buildertek__Contact__c, buildertek__Contact__r.Name,buildertek__Contact__r.Email, buildertek__RFQ__r.buildertek__Status__c,'+ 
                    'buildertek__RFQ__r.buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Status__c, buildertek__Vendor__c, buildertek__Vendor__r.buildertek__Pre_Qualified__c,'+ 
                    'buildertek__Quote_Amount__c,CurrencyIsoCode, (Select id, Name, buildertek__Item_Name__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c,CurrencyIsoCode,'+
                    'buildertek__Description__c, buildertek__Budget_Line_Amount__c, buildertek__Estimated_Work_Days__c, buildertek__Vendor_Note__c,buildertek__isVendorRFQSubmited__c'+
                    ' from buildertek__Vendor_Items__r), (Select Id, Name, File__r.Name, File__r.buildertek__File_Presigned_URL__c, File__r.buildertek__Download_Link__c,CurrencyIsoCode,'+
                    'File__r.buildertek__Download_Link1__c from buildertek__RFQ_To_Vendor_Document_Links__r), (Select Id, buildertek__File_Presigned_URL__c,CurrencyIsoCode,'+ 
                    'buildertek__Download_Link__c,buildertek__Download_Link1__c, Name from buildertek__Files__r) from buildertek__RFQ_To_Vendor__c where RFQ__c = :rfqId ';
                
                System.debug('rfqrecords>>'+rfqrecords);    
                rfqVendorsList = Database.query(rfqrecords);
                system.debug('rfqVendorsList'+rfqVendorsList);
            }else{
                rfqVendorsList = [select Id, Name, buildertek__Contact__c, buildertek__Contact__r.Name,buildertek__Contact__r.Email, buildertek__RFQ__r.buildertek__Status__c, 
                                  buildertek__RFQ__r.buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Status__c, buildertek__Vendor__c, buildertek__Vendor__r.buildertek__Pre_Qualified__c, 
                                  buildertek__Quote_Amount__c, (Select id, Name, buildertek__Item_Name__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, 
                                                                buildertek__Description__c, buildertek__Estimated_Work_Days__c, buildertek__Budget_Line_Amount__c, buildertek__Vendor_Note__c,buildertek__isVendorRFQSubmited__c
                                                                from buildertek__Vendor_Items__r order by CreatedDate), (Select Id, Name, File__r.Name, File__r.buildertek__File_Presigned_URL__c, File__r.buildertek__Download_Link__c, File__r.buildertek__Download_Link1__c
                                                                                                                         from buildertek__RFQ_To_Vendor_Document_Links__r), (Select Id, buildertek__File_Presigned_URL__c, buildertek__Download_Link__c, buildertek__Download_Link1__c, Name
                                                                                                                                                                             from buildertek__Files__r)
                                  from buildertek__RFQ_To_Vendor__c
                                  where RFQ__c = :rfqId
                                  ORDER By Order_By_Skip_zero__c ASC, Quote_Amount__c ASC
                                  NULLS LAST];
            }
            
            return rfqVendorsList;
        } catch (Exception ex){
            System.debug('Exception>>>'+ex);
            throw new AuraHandledException(ex.getMessage() + ex.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static RFQ_To_Vendor__c getSelectedVendorData(String vendorId){
        RFQ_To_Vendor__c rfqtovendr;
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()){
            rfqtovendr = [SELECT Id, Name, buildertek__Contact__c
                          FROM RFQ_To_Vendor__c
                          WHERE Id = :vendorId];
        }
        return rfqtovendr;
    }
    
    @AuraEnabled
    public static List<RFQ_To_Vendor__c> getSelectedVendorsData(List<String> vendorId){
        List<RFQ_To_Vendor__c> rfqToVendor;
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()){
            rfqToVendor = [SELECT Id, Name, buildertek__Contact__c,buildertek__RFQ__c
                           FROM RFQ_To_Vendor__c
                           WHERE Id IN :vendorId];
        }
        return rfqToVendor;
    }
    
    /**************************************************************************
Purpose: Award RFQ to vendor
Parameters: Awarded rfqToVendorList
Returns: NA
Throws [Exceptions]: NA
****************************************************************************/
    public static void awardRFQ(List<RFQ_To_Vendor__c> rfqToVendors){
        
        List<RFQ__c> rfqs = new List<RFQ__c>();
        
        for (RFQ_To_Vendor__c rfqToVendor : rfqToVendors){
            //      RFQ__c rfq = new RFQ__c();
            if (Schema.sObjectType.RFQ__c.fields.Status__c.isUpdateable()){
                //      rfq.Id = rfqToVendor.RFQ__c;
                rfqToVendor.Status__c = 'Awarded';
                
                //      rfq.Vendor__c = rfqToVendor.Id;
                //      rfqs.add(rfq);
            }
        }
        
        
        update rfqToVendors;
    }
    
    /**************************************************************************
Purpose: Poplucate Awared Vendors RFQ item detail to RFQ Package
Parameters: awardedVendorIds
Returns: NA
Throws [Exceptions]: NA
****************************************************************************/
    public static void populateRFQItemFromAwardedRFQVendorItem(Set<Id> awardedVendorIds){
        
        List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
        list<string> rfqToVendorLinkIds = new list<string>();
        Map<string, RFQ_Vendor_Item__c> MapList = new Map<string, RFQ_Vendor_Item__c>();
        for (RFQ_Vendor_Item__c rfqToVendor : [Select Id, Unit_Price__c, Quantity__c, Rfq_Item__c
                                               from RFQ_Vendor_Item__c
                                               where Vendor__c IN :awardedVendorIds]){
                                                   
                                                   rfqToVendorLinkIds.add(rfqToVendor.Rfq_Item__c);
                                                   MapList.put(rfqToVendor.Rfq_Item__c, rfqToVendor);
                                                   
                                               }
        List<RFQ_Item__c> rfqVendorList;
        if (Schema.sObjectType.RFQ_Item__c.fields.Id.isAccessible() && Schema.sObjectType.RFQ_Item__c.fields.Quantity__c.isAccessible() && Schema.sObjectType.RFQ_Item__c.fields.Unit_Price__c.isAccessible()){
            rfqVendorList = [select Id, Quantity__c, Unit_Price__c
                             from RFQ_Item__c
                             where Id IN :rfqToVendorLinkIds];
        }
        if (rfqVendorList.size() > 0){
            for (RFQ_Item__c rfqItem : rfqVendorList){
                if (Schema.sObjectType.RFQ_Item__c.fields.Quantity__c.isUpdateable() && Schema.sObjectType.RFQ_Item__c.fields.Unit_Price__c.isUpdateable()){
                    rfqItem.Quantity__c = MapList.get(rfqItem.Id).Quantity__c;
                    rfqItem.Unit_Price__c = MapList.get(rfqItem.Id).Unit_Price__c;
                    rfqItems.add(rfqItem);
                }
            }
        }
        update rfqItems;
        
    }
    
    /**************************************************************************
Purpose: Link vendor to RFQ - used in vendor tab in RFQ Record Deatil
Parameters: rfqId, vendorIds
Returns: status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string linkVendors(string rfqId, List<String> vendorIds){
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        Set<Id> accIds=new Set<Id>();
        Map<Id, Account> vendors = new Map<Id, Account>([Select Id, Name, (Select Id
                                                                           from Contacts
                                                                           Where Primary_Contact__c = true)
                                                         from Account
                                                         where Id In :vendorIds]);
        
        
        List<Account> accList=[Select Id, Name from Account where Id In :vendorIds];
        for(Account acc:accList){
            accIds.add(acc.Id);
        }
        
        buildertek__RFQ__c rfq = [SELECT Id, Name FROM buildertek__RFQ__c WHERE Id =: rfqId];
        for (string vendorId : vendorIds){
            RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
            rfqVendor.Name = rfq.Name;
            rfqVendor.Vendor__c = vendorId;
            rfqVendor.RFQ__c = rfqId; 
            rfqVendors.add(rfqVendor);
        }
        
        
        
        try{
            insert rfqVendors;
            
           
            List<String> vendorRfqIds = new List<String>();
            List<String> conListIds = new List<String>();
            
            for(RFQ_To_Vendor__c  rfv : rfqVendors){
                vendorRfqIds.add(rfv.Id);
            }
            
            List<buildertek__RFQ_To_Vendor__c> vendorContList = [select Id, Name, buildertek__Contact__c from buildertek__RFQ_To_Vendor__c where Id IN: vendorRfqIds];
            
            for(buildertek__RFQ_To_Vendor__c  conl : vendorContList){
                conListIds.add(conl.buildertek__Contact__c);
            }
            
            
            map<String,List<Contact>> rfqToVendorAccount = new map<String,List<Contact>>();
            
            List<Contact> PrimaryContactsList = [SELECT Id, Name, Phone,AccountId,buildertek__Primary_Contact__c, Email FROM Contact Where AccountId IN:vendorIds AND buildertek__Primary_Contact__c = true AND Id NOT IN: conListIds]; 
            
            
            for(Contact con : PrimaryContactsList){
                if(rfqToVendorAccount.get(con.AccountId) == null){
                    rfqToVendorAccount.put(con.AccountId,new List<Contact>());
                }
                rfqToVendorAccount.get(con.AccountId).add(con);
            }
            List<buildertek__BT_Vendor_RFQ_Contacts__c> rfqcontactlist = new  List<buildertek__BT_Vendor_RFQ_Contacts__c>();
            
            for(RFQ_To_Vendor__c rf : rfqVendors ){
                if(rfqToVendorAccount.get(rf.Vendor__c)!= null){
                    List<Contact> contactlists = rfqToVendorAccount.get(rf.Vendor__c);
                    for (Contact con : contactlists){
                        buildertek__BT_Vendor_RFQ_Contacts__c vendorrfqitem = new buildertek__BT_Vendor_RFQ_Contacts__c();
                        vendorrfqitem.buildertek__Account__c = con.AccountId ;
                        vendorrfqitem.buildertek__Contact__c = con.id;
                        vendorrfqitem.buildertek__Vendor_RFQ__c = rf.Id;
                        rfqcontactlist.add(vendorrfqitem);
                        system.debug('rfqcontactlist......'+rfqcontactlist);
                    }
                }
                
            }
            
            if (rfqcontactlist.size() > 0){
                system.debug(rfqcontactlist);
                insert rfqcontactlist;
            }
            
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
        
    }
    
    /**************************************************************************
Purpose: get selected vendor for the RFQ
Parameters: NA
Returns: vendor ids
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string selectedVendors(string rfqId){
        String vendorIds;
        for (RFQ_To_Vendor__c vendor : [Select Id, Vendor__c
                                        from RFQ_To_Vendor__c
                                        where RFQ__c = :rfqId]){
                                            if (String.isBlank(vendorIds)){
                                                vendorIds = '\'' + vendor.Vendor__c + '\'';
                                            } else{
                                                vendorIds = vendorIds + ',\'' + vendor.Vendor__c + '\'';
                                            }
                                        }
        
        if (vendorIds != null){
            vendorIds = '(' + vendorIds + ')';
        }
        
        return vendorIds;
    }
    
    /**************************************************************************
Purpose: delete RFQ to Vendor links
Parameters: NA
Returns: Status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string deleteVendorLinks(List<String> vendorIds){
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        for (string vendorId : vendorIds){
            RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
            rfqVendor.Id = vendorId;
            rfqVendors.add(rfqVendor);
        }
        
        try{
            if (RFQ_To_Vendor__c.sObjectType.getDescribe().isDeletable()){
                delete rfqVendors;
            }
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static string deleteVendor(List<String> vendorIds){
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        for (string vendorId : vendorIds){
            RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
            rfqVendor.Id = vendorId;
            rfqVendors.add(rfqVendor);
        }
        list<buildertek__File__c> btfileslist = [select id,Name,buildertek__RFQ_To_Vendor__c from buildertek__File__c where buildertek__RFQ_To_Vendor__c IN : vendorIds];
        delete btfileslist;
        
        try{
            if (RFQ_To_Vendor__c.sObjectType.getDescribe().isDeletable()){
                delete rfqVendors;
            }
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    /**************************************************************************
Purpose: Send RFQ Invitaion Email
Parameters: NA
Returns: Status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string sendRFQEmailToVendor(List<String> rfqToVendorLinkIds){
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        //  for(string vendorId: rfqToVendorLinkIds){
        //          RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
        //      if(Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isUpdateable()){
        //          rfqVendor.Id = vendorId;
        //          rfqVendor.Send_Invitation__c = true;
        //          rfqVendors.add(rfqVendor);
        //      }
        //  }
        
        set<Id> vendorIds = new set<Id>();
        set<Id> rfqIds = new set<Id>();
        List<RFQ_To_Vendor__c> rfqVendorList;
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isAccessible() 
            && Schema.sObjectType.RFQ_To_Vendor__c.fields.id.isAccessible()
            && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isAccessible()){
                rfqVendorList = [select Id, Send_Invitation__c,buildertek__RFQ__c, buildertek__RFQ__r.buildertek__Project__c, buildertek__Status__c, buildertek__Contact__c, buildertek__Contact__r.Name ,buildertek__Vendor__c, buildertek__Vendor__r.Name
                                 from RFQ_To_Vendor__c
                                 where Id IN :rfqToVendorLinkIds];
            }
        System.debug('rfqVendorList-----' + rfqVendorList);
        if (rfqVendorList.size() > 0){           
            for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                if(rfqVendor.buildertek__RFQ__c != null){
                    rfqIds.add(rfqVendor.buildertek__RFQ__c);
                }
                if(rfqVendor.buildertek__Vendor__c!=null){
                    vendorIds.add(rfqVendor.buildertek__Vendor__c);
                }
                if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isUpdateable() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Submitted_Date__c.isUpdateable()){
                    rfqVendor.Send_Invitation__c = true;
                    // rfqVendor.buildertek__Submitted_Date__c = system.now();
                }
                rfqVendors.add(rfqVendor);
            }
        }
        
        try{
            update rfqVendors;
            //verifiying isportal are avabile or not
            list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
            system.debug('%%%'+netRec.size());
            if(netRec.size() > 0){
                //create sharing record to vendor 
                List<buildertek__RFQ__Share> rfqshareList=new List<buildertek__RFQ__Share>();
                List<buildertek__Project__Share> prjctshareList=new List<buildertek__Project__Share>();
                List<buildertek__File__Share> btfileshareList=new List<buildertek__File__Share>();
                list<buildertek__File__c> fileslist = [SELECT Id,Name,buildertek__Amazon_File_Key__c,buildertek__Download_Link1__c,buildertek__RFQ_To_Vendor__c,
                                                       buildertek__RFI_Response__c,buildertek__File_Presigned_URL__c,buildertek__RFQ__c,buildertek__Download_Link__c,
                                                       buildertek__Content_Type__c FROM buildertek__File__c where buildertek__RFQ__c IN :rfqIds];
                map<Id,User> vendorUserMap = new map<Id,User>();
                string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                    'FROM User Where AccountId In:vendorIds  And isPortalEnabled=true ';    
                list<User> usersList = Database.query(strQry);
                if(usersList.size() > 0){
                    for(User usr: usersList){
                        vendorUserMap.put(usr.AccountId,usr);
                    }
                }
                string theTemplate;
                theTemplate = [SELECT Id
                               FROM EmailTemplate
                               WHERE Name  = : 'RFQ Invitation Email For Community'].id;  
                if (rfqVendorList.size() > 0){ 
                    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();            
                    for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                        if(rfqVendor.buildertek__Vendor__c!=null){
                            if(vendorUserMap.get(rfqVendor.buildertek__Vendor__c)!=null){
                                User usrrec = vendorUserMap.get(rfqVendor.buildertek__Vendor__c);
                                system.debug('usrrec--->'+usrrec); 
                                /*  buildertek__RFQ__Share rfqshare=new buildertek__RFQ__Share();
rfqshare.ParentId= rfqVendor.buildertek__RFQ__c;
rfqshare.UserOrGroupId=usrrec.Id;
rfqshare.AccessLevel= 'Edit';
rfqshare.RowCause=Schema.buildertek__RFQ__Share.RowCause.Manual;             
rfqshareList.add(rfqshare);
system.debug('rfqshare--->'+rfqshare);*/
                                
                                /* buildertek__Project__Share prjshare=new buildertek__Project__Share();
prjshare.ParentId= rfqVendor.buildertek__RFQ__r.buildertek__Project__c;
prjshare.UserOrGroupId=usrrec.Id;
prjshare.AccessLevel= 'Read'; 
prjshare.RowCause=Schema.buildertek__Project__Share.RowCause.Manual;             
prjctshareList.add(prjshare); 
system.debug('prjshare--->'+prjshare);  */
                                string toemailadd = usrrec.Email;
                                Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();
                                message.toAddresses = new String[] { toemailadd};
                                    message.setTemplateID(theTemplate);     
                                message.setSaveAsActivity(false);
                                message.setWhatId(rfqVendor.Id);
                                message.setTargetObjectId(usrrec.Id);
                                messageList.add(message);
                                //   Savepoint sp = Database.setSavepoint();
                                //  Messaging.sendEmail(messageList);
                                // Database.rollback(sp);
                                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                                // loop through the previous message list and set the email fields
                                /* for (Messaging.SingleEmailMessage email : messageList) {
Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
emailToSend.setToAddresses(email.getToAddresses());
emailToSend.setHTMLBody(email.getHTMLBody());
emailToSend.setSaveAsActivity(true);
emailToSend.setFileAttachments(email.getFileAttachments());
//emailToSend.setSubject(email.getSubject()+' - [ref:'+rfiRec1.Id+']');
actualMessageList.add(emailToSend);
} */
                                //Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);                         
                            }
                        }
                    }
                    /*  if(rfqshareList.size()>0){
Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
Database.SaveResult[] prjlsr = Database.insert(prjctshareList,false);
Database.SaveResult[] fillsr = Database.insert(btfileshareList,false);
} */
                }
                //End create sharing record to vendor
                list<Id> accountids= new list<Id>();
                list<Id> contactids= new list<Id>();
                map<Id,buildertek__RFQ_To_Vendor__c> vendorUserMap2 = new map<Id,buildertek__RFQ_To_Vendor__c>();
                List<Messaging.SingleEmailMessage> messageList1 = new List<Messaging.SingleEmailMessage>();   
                List<buildertek__RFQ_To_Vendor__c> rfqVendorListforaccount;
                rfqVendorListforaccount = [select Id, buildertek__Send_Invitation__c,buildertek__RFQ__c, buildertek__RFQ__r.buildertek__Project__c, 
                                           buildertek__Status__c, buildertek__Contact__c, buildertek__Contact__r.Name ,buildertek__Vendor__c, buildertek__Vendor__r.Name
                                           from buildertek__RFQ_To_Vendor__c
                                           where Id IN :rfqToVendorLinkIds];
                list<Id> rfqvendorIds = new list<Id>();
                for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorListforaccount){
                    accountids.add(venroRec.buildertek__Vendor__c); 
                    contactids.add(venroRec.buildertek__Contact__c);
                    vendorUserMap2.put(venroRec.buildertek__Vendor__c,venroRec);
                    rfqvendorIds.add(venroRec.Id);
                    
                }
                list<Id> coRec= new list<Id>();
                set<Id> coRecs= new set<Id>();
                list<Contact> contactlist = [Select id,Name,Email,AccountId from Contact where AccountId IN: accountids AND buildertek__Primary_Contact__c =true 
                                             AND Email != null ];
                system.debug('conlist'+contactlist );
                system.debug('conlist-->'+contactlist .size());
                for(Contact contactRec : contactlist){
                    coRecs.add(contactRec.id);
                }
                system.debug('YU'+coRecs);
                list<buildertek__BT_Vendor_RFQ_Contacts__c> rfqvendorcontactlist = [Select id,Name,buildertek__Account__c,buildertek__Contact__c,
                                                                                    buildertek__Vendor_RFQ__c  from buildertek__BT_Vendor_RFQ_Contacts__c
                                                                                    where buildertek__Vendor_RFQ__c IN : rfqvendorIds];
                for(buildertek__BT_Vendor_RFQ_Contacts__c rfqcontactRec : rfqvendorcontactlist){
                    coRecs.add(rfqcontactRec.buildertek__Contact__c);
                }
                system.debug('coRecs'+coRecs);
                
                map<Id,User> vendorUserMap1 = new map<Id,User>();
                string strQry1 = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                    'FROM User Where ContactId IN : coRecs And isPortalEnabled=true ';    
                system.debug('strQry1t-->'+strQry1);
                list<User> userList1= Database.query(strQry1);
                system.debug('userList'+userList1);
                if(userList1.size() > 0){
                    for(User usr: userList1){
                        vendorUserMap1.put(usr.ContactId,usr);
                    }
                }
                
                list<Contact> conlist = [Select id,Name,Email,AccountId from Contact where Id IN: coRecs AND Email != null ];
                if(fileslist.size() > 0){
                    for (buildertek__File__c btfile : fileslist){
                        for(User userRec1: userList1){
                            if(btfile.buildertek__RFQ__c !=null){
                                buildertek__File__Share fileshare=new buildertek__File__Share();
                                fileshare.ParentId= btfile.Id;
                                fileshare.UserOrGroupId=userRec1.Id;
                                fileshare.AccessLevel= 'Edit';
                                fileshare.RowCause=Schema.buildertek__File__Share.RowCause.Manual;             
                                btfileshareList.add(fileshare);
                                system.debug('fileshare--->'+fileshare); 
                            }
                        }
                    }
                }
                //string htmlbody = '';
                map<Id,Contact> contactMap = new map<Id,Contact>();
                for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorListforaccount){
                    for(Contact conRec : conlist){
                        if(venroRec.buildertek__Vendor__c == conRec.AccountId){
                            system.debug('vendorusermapid--------->'+vendorUserMap1.get(conRec.Id));
                            if(vendorUserMap1.get(conRec.Id)!=null){
                                User usrrec1 = vendorUserMap1.get(conRec.Id);
                                contactMap.put(usrrec1.Id,conRec);
                                buildertek__RFQ_To_Vendor__c vendorRec = vendorUserMap2.get(conRec.AccountId); 
                                buildertek__RFQ__Share rfqshare=new buildertek__RFQ__Share();
                                rfqshare.ParentId= venroRec.buildertek__RFQ__c;
                                rfqshare.UserOrGroupId=usrrec1.Id;
                                rfqshare.AccessLevel= 'Edit';
                                rfqshare.RowCause=Schema.buildertek__RFQ__Share.RowCause.Manual;             
                                rfqshareList.add(rfqshare);
                                
                                buildertek__Project__Share prjshare=new buildertek__Project__Share();
                                prjshare.ParentId= venroRec.buildertek__RFQ__r.buildertek__Project__c;
                                prjshare.UserOrGroupId=usrrec1.Id;
                                prjshare.AccessLevel= 'Read'; 
                                prjshare.RowCause=Schema.buildertek__Project__Share.RowCause.Manual;             
                                prjctshareList.add(prjshare); 
                                //htmlbody = conRec.Name;
                                system.debug('usrrec1.Email--------->'+usrrec1.Email);
                                string toemailadd = usrrec1.Email;
                                Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
                                message1.toAddresses = new String[] { toemailadd};
                                    message1.setTemplateID(theTemplate);
                                system.debug('toaddress---->'+message1.toAddresses);
                                message1.setSaveAsActivity(false);
                                message1.setWhatId(vendorRec.Id);
                                message1.setTargetObjectId(usrrec1.Id);
                                system.debug('message1------>'+message1);
                                messageList1.add(message1);
                                // Messaging.sendEmail(messageList1);
                                //  List<Messaging.SingleEmailMessage> actualMessageList1 = new List<Messaging.SingleEmailMessage>();
                            }
                        }
                    }
                }
                EmailServicesAddress eServices;
                eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                             FROM EmailServicesAddress
                             where LocalPart = 'projects'];
                
                String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
                
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(messageList1);
                Database.rollback(sp);
                // htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                for (Messaging.SingleEmailMessage email : messageList1) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    // emailToSend.setTargetObjectId(email.getTargetObjectId());
                    Contact contactReC = contactMap.get(email.getTargetObjectId());
                    system.debug('&&&&contactReC---->'+contactReC);
                    system.debug('&&&&contactReC---->'+contactReC.Name);
                    string templatebody = email.getHTMLBody();
                    system.debug('templatebody--->'+templatebody);
                    if(templatebody.contains('{replaceresponse}')){
                        templatebody = templatebody.replace('{replaceresponse}',+contactReC.Name);
                        system.debug('&&&&'+templatebody);                            
                    }
                    emailToSend.setHTMLBody('<br/>'+templatebody);    
                    emailToSend.setFileAttachments(email.getFileAttachments());
                    emailToSend.setSubject(email.getSubject());
                    emailToSend.setSaveAsActivity(true);
                    emailToSend.setReplyTo(fromAddress);    
                    actualMessageList.add(emailToSend);
                }
                if(actualMessageList.size() > 0){
                    Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList); 
                }
                
                if(messageList1.size() > 0){
                    // Messaging.sendEmail(messageList1);
                    //  List<Messaging.SingleEmailMessage> actualMessageList1 = new List<Messaging.SingleEmailMessage>();
                }
                if(rfqshareList.size()>0){
                    Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
                    Database.SaveResult[] prjlsr = Database.insert(prjctshareList,false);
                    Database.SaveResult[] fillsr = Database.insert(btfileshareList,false);
                }
            }
            set<Id> RfqId = new Set<Id>();
            set<Id> RfqId1 = new Set<Id>();
            set<Id> vendorRfqId = new Set<Id>();
            set<Id> submitvendorRfqId = new Set<Id>();
            for (RFQ_To_Vendor__c rfqtovendr : rfqVendors){
                system.debug('**'+rfqtovendr.buildertek__Status__c);
                if(rfqtovendr.buildertek__Status__c == 'New'){
                    vendorRfqId.add(rfqtovendr.Id);
                }else if(rfqtovendr.buildertek__Status__c == 'Quote Submitted'){
                    system.debug('^%%%'+ rfqtovendr.buildertek__Status__c);
                    submitvendorRfqId.add(rfqtovendr.Id);
                }
                // RfqId.add(rfqtovendr.buildertek__RFQ__c);
            }
            
            list<RFQ_To_Vendor__c> rfqVendorList1 = [select Id, Send_Invitation__c, buildertek__RFQ__c,  buildertek__RFQ__r.buildertek__Project__c, buildertek__Status__c, buildertek__Contact__c, buildertek__Contact__r.Name ,buildertek__Vendor__c, buildertek__Vendor__r.Name
                                                     from RFQ_To_Vendor__c
                                                     where Id IN :vendorRfqId];
            list<RFQ_To_Vendor__c> rfqVendorList2 = [select Id, Send_Invitation__c, buildertek__RFQ__c,  buildertek__RFQ__r.buildertek__Project__c, buildertek__Status__c, buildertek__Contact__c, buildertek__Contact__r.Name ,buildertek__Vendor__c, buildertek__Vendor__r.Name
                                                     from RFQ_To_Vendor__c
                                                     where Id IN :submitvendorRfqId];
            system.debug('^^^'+ rfqVendorList2.size());
            for (RFQ_To_Vendor__c rfqtovendr : rfqVendorList1){
                RfqId.add(rfqtovendr.buildertek__RFQ__c);
            }
            for (RFQ_To_Vendor__c rfqtovendr : rfqVendorList2){
                RfqId1.add(rfqtovendr.buildertek__RFQ__c);
                
            }
            
            list<buildertek__RFQ__c> rfqreclst;
            list<buildertek__RFQ__c> rfqreclst1;
            /*if(Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() &&
Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() &&
Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isAccessible()){*/
            rfqreclst = [select Id, Name, buildertek__RFQ_s_Sent__c
                         from buildertek__RFQ__c
                         where Id = :RfqId];
            
            /*}*/
            if (rfqreclst.size() > 0){
                system.debug('%%%%'+rfqreclst.size());
                if (rfqreclst[0].buildertek__RFQ_s_Sent__c != null){
                    rfqreclst[0].buildertek__RFQ_s_Sent__c += rfqVendorList1.size();
                } else{
                    rfqreclst[0].buildertek__RFQ_s_Sent__c = rfqVendorList1.size();
                }
                
                if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isUpdateable()){
                    update rfqreclst;
                }
            }
            rfqreclst1 = [select Id, Name, buildertek__RFQ_s_Sent__c,buildertek__RFQ_s_Replied_To__c
                          from buildertek__RFQ__c
                          where Id = :RfqId1];
            system.debug('rfqreclst1'+rfqreclst1);
            if (rfqreclst1.size() > 0){
                if (rfqreclst1[0].buildertek__RFQ_s_Replied_To__c != null){
                    system.debug('^^^'+ rfqVendorList2.size());
                    if(rfqVendorList2.size() == 0) {
                        system.debug('^%%%'+ rfqVendorList2.size());
                        rfqreclst1[0].buildertek__RFQ_s_Replied_To__c -=  1;  
                    }else{
                        system.debug('&&****'+ rfqVendorList2.size());
                        rfqreclst1[0].buildertek__RFQ_s_Replied_To__c -=  rfqVendorList2.size();    
                    }
                    system.debug('((('+rfqreclst1[0].buildertek__RFQ_s_Replied_To__c);
                } else{
                    rfqreclst1[0].buildertek__RFQ_s_Replied_To__c = 0;
                }
                if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isUpdateable()){
                    update rfqreclst1;
                }
            }
            // System.debug('--------------'+rfqVendors.size()+'rfqVendorList-----'+rfqVendors+'-------'+rfqreclst);
            // 
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
                                                                     buildertek__Vendor_Note__c,
                                                                     buildertek__Estimated_Work_Days__c,
                                                                     buildertek__Vendor_Estimated_Work_Days__c,
                                                                     buildertek__Item_Name__c,
                                                                     buildertek__isVendorRFQSubmited__c,
                                                                     buildertek__RFQ_Item__c FROM buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c IN :rfqToVendorLinkIds];
            for(buildertek__RFQ_Vendor_Item__c vendorRFQ:vendorRFQLinesList){
                vendorRFQ.buildertek__isVendorRFQSubmited__c=false;
                vendorRFQ.buildertek__Vendor_Quantity__c = vendorRFQ.buildertek__Quantity__c;
                vendorRFQ.buildertek__Vendor_Unit_Price__c = vendorRFQ.buildertek__Unit_Price__c;
                vendorRFQ.buildertek__Note__c= vendorRFQ.buildertek__Vendor_Note__c;
                vendorRFQ.buildertek__Vendor_Estimated_Work_Days__c= vendorRFQ.buildertek__Estimated_Work_Days__c;
            }
            update vendorRFQLinesList;            
            
        } catch (Exception ex){
            System.debug('--------faill------');
            return ex.getMessage();
        }
        return 'Email Sent Successfully';
    }
    
    @AuraEnabled
    public static BudgetDataTableWrapper getBudgetData(Integer pageNumber, Integer pageSize, string RFQRecId){
        buildertek__RFQ__c RFQRec = [SELECT Id, Name, buildertek__Awarded_Date__c, buildertek__RFQ_s_Sent__c, buildertek__Project__c
                                     FROM buildertek__RFQ__c
                                     where Id = :RFQRecId];
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = [SELECT COUNT()
                                FROM buildertek__Budget__c
                                where buildertek__Project__c = :RFQRec.buildertek__Project__c];
        Integer recordEnd = pageSize * pageNumber;
        //Instance of Contact DataTable Wrapper Class
        BudgetDataTableWrapper objDT = new BudgetDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name
                            FROM buildertek__Budget__c
                            where buildertek__Project__c = :RFQRec.buildertek__Project__c
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];
        return objDT;
    }
    
    @AuraEnabled
    public static String addAcceptedRFQToBudget(String recordId, String budgetIds){
        String message = '';
        try{
            List<buildertek__Budget_Item__c> budgetItems = new List<buildertek__Budget_Item__c>();
            if (String.isNotBlank(recordId)){
                List<String> listOfBudgetIds = (List<String>)JSON.deserialize(budgetIds, List<String>.class);
                List<buildertek__RFQ_To_Vendor__c> acceptedRFQToVensors = [select Id, Name, (Select Id, Name, buildertek__Item_Name__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, buildertek__Description__c, buildertek__Budget_Line_Amount__c, buildertek__Vendor_Note__c,buildertek__isVendorRFQSubmited__c
                                                                                             from buildertek__Vendor_Items__r  order by CreatedDate) 
                                                                           FROM buildertek__RFQ_To_Vendor__c
                                                                           where buildertek__RFQ__c = :recordId AND (buildertek__Status__c = :'Awarded' OR buildertek__Status__c = :'Accepted')];
                system.debug('hii' + acceptedRFQToVensors);
                for (String listOfBudgetId : listOfBudgetIds){
                    for (buildertek__RFQ_To_Vendor__c acceptedRFQToVensor : acceptedRFQToVensors){
                        for (buildertek__RFQ_Vendor_Item__c acceptedRFQ : acceptedRFQToVensor.buildertek__Vendor_Items__r){
                            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                            budgetItem.Name = acceptedRFQ.Name;
                            budgetItem.buildertek__Budget__c = listOfBudgetId;
                            budgetItem.buildertek__Notes__c = acceptedRFQ.buildertek__Vendor_Note__c;
                            budgetItem.buildertek__Unit_Price__c = acceptedRFQ.buildertek__Unit_Price__c;
                            budgetItem.buildertek__Quantity__c = acceptedRFQ.buildertek__Quantity__c;
                            budgetItem.buildertek__Description__c = acceptedRFQ.buildertek__Description__c;
                            budgetItems.add(budgetItem);
                        }
                    }
                }
                if (budgetItems.size() > 0){
                    insert budgetItems;
                    message = '200';
                } else{
                    message = '404';
                }
            }
        } catch (Exception e){
            message = e.getMessage();
        }
        return message;
    }
    
    /**************************************************************************
Purpose: Send RFQ Invitaion Email
Parameters: NA
Returns: Status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string updateRFQToVendorStatus(List<String> rfqToVendorLinkIds, String Status){
        system.debug('Status ---------> ' + Status);
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        
        List<RFQ_To_Vendor__c> rfqVendorList;
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.id.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isAccessible()){
            rfqVendorList = [select Id, Send_Invitation__c, Status__c, buildertek__RFQ__c
                             from RFQ_To_Vendor__c
                             where Id IN :rfqToVendorLinkIds];
        }
        SET<Id> RFQIdSet = new SET<Id>();
        SET<Id> RfqvendrId = new SET<Id>(); 
        SET<Id> EmailsentRfqId = new SET<Id>();
        if (rfqVendorList.size() > 0){
            for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                EmailsentRfqId.add(rfqVendor.buildertek__RFQ__c);
                if (Status == 'Email Sent'){
                    system.debug('Send Invitation ---------> ');
                    rfqVendor.buildertek__Send_Invitation__c = true;
                    //  rfqVendor.buildertek__Submitted_Date__c = system.now();
                    
                    
                } else{
                    RfqvendrId.add(rfqVendor.Id);
                    DateTime dT = System.now();
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable()){
                        rfqVendor.Status__c = Status;
                        // rfqVendor.buildertek__Awarded_Date__c = system.Today();
                        rfqVendor.buildertek__Awarded_Date__c = myDate;
                        RFQIdSet.add(rfqVendor.buildertek__RFQ__c);
                    }
                }
                
                rfqVendors.add(rfqVendor);
            }
        }
        //try{
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isUpdateable() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Awarded_Date__c.isUpdateable()){
            update rfqVendors;
        }
        List<buildertek__RFQ__c> RFQListToUpdate = new List<buildertek__RFQ__c>();
        system.debug('RFQIdSet------' + RFQIdSet);
        string rfqid;
        if (RFQIdSet.size() > 0){
            List<buildertek__RFQ__c> RFQList;
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Awarded_Date__c.isAccessible()){
                RFQList = [SELECT Id, Name, buildertek__Awarded_Date__c, buildertek__RFQ_s_Sent__c
                           FROM buildertek__RFQ__c
                           WHERE Id IN :RFQIdSet];
            }
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            system.debug(RFQList.size()+'RFQList------' + RFQList);
            for (buildertek__RFQ__c rfq : RFQList){
                rfq.buildertek__Awarded_Date__c = myDate;
                RFQListToUpdate.add(rfq);
            }
        }
        
        if (RFQListToUpdate.size() > 0){
            if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Awarded_Date__c.isUpdateable()){
                update RFQListToUpdate;
            }
        }
        
        /*if (EmailsentRfqId.size() > 0 && Status != 'Canceled'){
list<buildertek__RFQ__c> rfqreclst;
if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isAccessible()){
rfqreclst = [select Id, Name, buildertek__RFQ_s_Sent__c
from buildertek__RFQ__c
where Id = :EmailsentRfqId];
}
if (rfqreclst.size() > 0){
if (rfqreclst[0].buildertek__RFQ_s_Sent__c != null){
rfqreclst[0].buildertek__RFQ_s_Sent__c += 1;
} else{
rfqreclst[0].buildertek__RFQ_s_Sent__c = 1;
}
}
if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Sent__c.isUpdateable()){
update rfqreclst;
}
}*/
        
        if(Status=='Awarded'){
            list<buildertek__RFQ__c> rfqreclist = [select id,Name,buildertek__Project__c,buildertek__Project__r.Name,
                                                   buildertek__Project__r.OwnerId,buildertek__Project__r.Owner.Email
                                                   from buildertek__RFQ__c where Id In:EmailsentRfqId ];
            
            string toemailadd='';
            if(rfqreclist.size()>0 && rfqreclist[0].buildertek__Project__c!=null){
                toemailadd = rfqreclist[0].buildertek__Project__r.Owner.Email;
                System.debug('toemailadd--->'+toemailadd);    
                
                string theTemplate;
                
                theTemplate = [SELECT Id
                               FROM EmailTemplate
                               WHERE Name  = 'Award Bid Manager Email'].Id;        
                
                system.debug('theTemplate>'+theTemplate);
                
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();
                
                message1.toAddresses = new String[] { toemailadd};
                    message1.setTemplateID(theTemplate);     
                message1.setSaveAsActivity(false);
                message1.setWhatId(rfqreclist[0].Id);
                //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
                message1.setTargetObjectId(rfqreclist[0].buildertek__Project__r.OwnerId);
                messageList.add(message1);
                
                Savepoint sp = Database.setSavepoint();
                
                Messaging.sendEmail(messageList);
                
                Database.rollback(sp);
                try{ 
                    
                    //List<string> CCAdresses = new List<string>();                    
                    ////CCAdresses.add('sowndarya.nittala@diligentforcelabs.com'); 
                    
                    List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                    
                    // loop through the previous message list and set the email fields
                    for (Messaging.SingleEmailMessage email : messageList) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSaveAsActivity(false);
                        emailToSend.setSubject(email.getSubject());
                        //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                        emailToSend.setFileAttachments(email.getFileAttachments());
                        //emailToSend.setCcAddresses(CCAdresses);
                        actualMessageList.add(emailToSend);
                        system.debug('emailToSend--->'+emailToSend);
                    }
                    
                    
                    Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                    System.debug('The email was sent successfully.');
                }catch(Exception e){
                    System.debug('The email failed to send: ');             
                }                
                
                
                
                
            }
            
            
            
        }
        
        
        
        //}
        system.debug(Status + 'Send Invitation final ---------> ' + rfqVendors);
        return Status + ' Successfully';
        
        /*} catch (Exception ex){
return ex.getMessage();
}*/
    }
    @AuraEnabled
    public static string cancelRFQOnly(string recordId, string reason){
        if(recordId != null){
            buildertek__RFQ__c RFQRec = [SELECT Id, Name,  buildertek__Status__c 
                                         FROM buildertek__RFQ__c
                                         WHERE Id =: recordId];
            RFQRec.buildertek__Status__c = 'Canceled';
            RFQRec.buildertek__Reason_for_Cancelling_RFQ__c = reason;
            update RFQRec;
            return 'SUCCESS';
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static string getrfqstatus(string recId){
        buildertek__RFQ__c RFQRecord = [SELECT Id, Name,buildertek__Status__c 
                                        FROM buildertek__RFQ__c
                                        WHERE Id =: recId];
        return RFQRecord.buildertek__Status__c ;
        
    }
    @AuraEnabled
    public static string cancelRFQvendor(List<String> rfqToVendorLinkIds, string recordId, string reason){
        system.debug('*****************');
        try{
            List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
            List<String> rfqEmailForContact = new List<String>(); 
            SET<Id> RFQIdSet = new SET<Id>();
            List<RFQ_To_Vendor__c> rfqVendorList;
            rfqVendorList = [select Id, Send_Invitation__c, Status__c, buildertek__RFQ__c,buildertek__RFQ__r.Name,buildertek__Contact__c,buildertek__Contact__r.Email
                             from RFQ_To_Vendor__c
                             where buildertek__RFQ__c =: recordId];
            system.debug('rfqVendorList'+rfqVendorList);
            if(rfqVendorList.size() > 0 ){
                for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                    if(rfqVendor.buildertek__RFQ__c !=null){
                        RFQIdSet.add(rfqVendor.buildertek__RFQ__c);
                    }
                }
                SET<Id> RfqvendrId = new SET<Id>();
                List<RFQ_To_Vendor__c> rfqtoVendors = new List<RFQ_To_Vendor__c>();
                for (RFQ_To_Vendor__c vendorRec : rfqVendorList){
                    rfqtoVendors.add(vendorRec);
                }
                list<buildertek__File__c> btfileslist = [select id,Name,buildertek__RFQ_To_Vendor__c from buildertek__File__c where buildertek__RFQ_To_Vendor__c IN : rfqtoVendors];
                delete btfileslist;
                /* List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(rfqEmailForContact);
system.debug('rfqEmailForContact.......'+rfqEmailForContact);
if (rfqVendorList.size() > 0){
for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
system.debug('rfqVendorList'+rfqVendor.buildertek__Contact__r.Email);
system.debug('rfqVendor.buildertek__Contact__c'+rfqVendor.buildertek__Contact__c);
system.debug('Send Invitation ---------> ');
mail.setSubject('RFQ Cancelation Notice for "' + rfqVendor.buildertek__RFQ__r.Name + '"');
mail.setHtmlBody('<p>We apologize but we are cancelling the RFQ for this work. <br/><br/> If you have any questions please contact the office.</p>');
mail.setWhatId(rfqVendor.Id);
mail.setTargetObjectId(rfqVendor.buildertek__Contact__c);
mail.setSaveAsActivity(true);
mails.add(mail);
}
}*/
                string theTemplate;
                theTemplate = [SELECT Id FROM EmailTemplate WHERE Name  = : 'RFQ Cancel Email'].id;  
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                system.debug('rfqVendorList^^^^^'+rfqVendorList.size());
                for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                    system.debug('rfqVendorList'+rfqVendor.buildertek__Contact__r.Email);
                    system.debug('rfqVendor.buildertek__Contact__c'+rfqVendor.buildertek__Contact__c);
                    if(rfqVendor.buildertek__Contact__r.Email != null){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        string toemailadd = rfqVendor.buildertek__Contact__r.Email;
                        message.toAddresses = new String[] { toemailadd};
                            system.debug('&&&'+toemailadd);
                        message.setTemplateID(theTemplate);     
                        message.setSaveAsActivity(false);
                        message.setWhatId(rfqVendor.Id);
                        message.setTargetObjectId(rfqVendor.buildertek__Contact__c);
                        messageList.add(message);
                    }
                }
                if(messageList.size()>0){
                    Messaging.sendEmail(messageList);
                }
                list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
                system.debug('%%%'+netRec.size());
                if(netRec.size() > 0){
                    list<Id> contactids= new list<Id>(); 
                    map<Id,buildertek__RFQ_To_Vendor__c> vendorUserMap2 = new map<Id,buildertek__RFQ_To_Vendor__c>();
                    List<Messaging.SingleEmailMessage> messageList1 = new List<Messaging.SingleEmailMessage>();   
                    for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorList){
                        contactids.add(venroRec.buildertek__Contact__c);
                    }
                    map<Id,User> vendorUserMap1 = new map<Id,User>();
                    string strQry1 = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                        'FROM User Where ContactId IN : contactids And isPortalEnabled=true ';    
                    system.debug('strQry1t-->'+strQry1);
                    list<User> userList1= Database.query(strQry1);
                    system.debug('userList'+userList1);
                    if(userList1.size() > 0){
                        for(User usr: userList1){
                            vendorUserMap1.put(usr.ContactId,usr);
                        }
                    }
                    List<Messaging.SingleEmailMessage> messageLists1 = new List<Messaging.SingleEmailMessage>();
                    for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorList){
                        if(vendorUserMap1.get(venroRec.buildertek__Contact__c)!=null){
                            User usrrec1 = vendorUserMap1.get(venroRec.buildertek__Contact__c);
                            if(venroRec.buildertek__Contact__r.Email != usrrec1.Email){
                                Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
                                string toemailadd = usrrec1.Email;
                                message1.toAddresses = new String[] { toemailadd};
                                    system.debug('&&&'+toemailadd);
                                message1.setTemplateID(theTemplate);     
                                message1.setSaveAsActivity(false);
                                message1.setWhatId(venroRec.Id);
                                message1.setTargetObjectId(usrrec1.id);
                                messageLists1.add(message1);
                            }
                        }
                    }
                    if(messageLists1.size()>0){
                        Messaging.sendEmail(messageLists1);
                    }
                }
                
                
                /*    RFQ_To_Vendor__c rfqToVendor = new RFQ_To_Vendor__c();
rfqToVendor.Id = rfqVendor.Id;
rfqToVendor.Status__c ='Canceled';
rfqVendors.add(rfqToVendor);

}
}*/
                /* if(mails.size()>0){
Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
system.debug('results:::'+results);
}*/
                // try{
                if(rfqVendorList.size()>0){
                    delete rfqVendorList;
                }
                List<buildertek__RFQ__c> RFQListToUpdate = new List<buildertek__RFQ__c>();
                system.debug('RFQIdSet------' + RFQIdSet);
                string rfqid;
                if (RFQIdSet.size() > 0){
                    List<buildertek__RFQ__c> RFQList;
                    RFQList = [SELECT Id, Name,  buildertek__Status__c 
                               FROM buildertek__RFQ__c
                               WHERE Id IN :RFQIdSet];
                    system.debug(RFQList.size()+'RFQList------' + RFQList);
                    for (buildertek__RFQ__c rfq : RFQList){
                        rfq.buildertek__Status__c = 'Canceled';
                        rfq.buildertek__Reason_for_Cancelling_RFQ__c = reason;
                        RFQListToUpdate.add(rfq);
                    }
                }
                
                if (RFQListToUpdate.size() > 0){
                    update RFQListToUpdate;
                }
                system.debug('Send cancel  final ---------> ' + rfqVendors);
                return 'SUCCESS';
            }else if(recordId != null){
                buildertek__RFQ__c RFQRec = [SELECT Id, Name,  buildertek__Status__c 
                                             FROM buildertek__RFQ__c
                                             WHERE Id =: recordId];
                RFQRec.buildertek__Status__c = 'Canceled';
                RFQRec.buildertek__Reason_for_Cancelling_RFQ__c = reason;
                update RFQRec;
                return 'SUCCESS';
            }else{
                return null;
            }
            
        }catch (Exception ex){
            return ex.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static string voidRFQvendor(List<String> rfqToVendorLinkIds, string recordId, string reason){
        try{
            List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
            List<String> rfqEmailForContact = new List<String>(); 
            SET<Id> RFQIdSet = new SET<Id>();
            list<Id> vendorids = new list<Id>();
            List<RFQ_To_Vendor__c> rfqVendorList;
            List<RFQ_To_Vendor__c> uprfqVendorList = new List<RFQ_To_Vendor__c>();
            rfqVendorList = [select Id,buildertek__Send_Invitation__c, buildertek__RFQ__c,buildertek__RFQ__r.Name,buildertek__Contact__c,buildertek__Contact__r.Email,buildertek__Submitted_Date__c,
                             buildertek__Accepted_Date__c,buildertek__Awarded_Date__c,buildertek__Rejected_Date__c,buildertek__Status__c from RFQ_To_Vendor__c
                             where buildertek__RFQ__c =: recordId];
            system.debug('rfqVendorList'+rfqVendorList);
            if(rfqVendorList.size() > 0 ){
                for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                    if(rfqVendor.buildertek__RFQ__c !=null){
                        RFQIdSet.add(rfqVendor.buildertek__RFQ__c);
                    }
                    vendorids.add(rfqVendor.id);
                    if(rfqVendor.buildertek__Submitted_Date__c != null){
                        rfqVendor.buildertek__Submitted_Date__c = null;
                    }
                    if(rfqVendor.buildertek__Rejected_Date__c != null){
                        rfqVendor.buildertek__Rejected_Date__c = null;
                    }
                    if(rfqVendor.buildertek__Accepted_Date__c != null){
                        rfqVendor.buildertek__Accepted_Date__c = null;
                    }
                    if(rfqVendor.buildertek__Awarded_Date__c != null){
                        rfqVendor.buildertek__Awarded_Date__c = null;
                    }
                    if(rfqVendor.buildertek__Status__c != 'New'){
                        rfqVendor.buildertek__Status__c = 'New';
                    }
                    uprfqVendorList.add(rfqVendor);
                    
                }
                SET<Id> RfqvendrId = new SET<Id>();
                List<RFQ_To_Vendor__c> rfqtoVendors = new List<RFQ_To_Vendor__c>();
                for (RFQ_To_Vendor__c vendorRec : rfqVendorList){
                    rfqtoVendors.add(vendorRec);
                }
                list<buildertek__RFQ_Vendor_Item__c> updatevendorlines = new list<buildertek__RFQ_Vendor_Item__c>();
                list<buildertek__RFQ_Vendor_Item__c> deletevendorlines = new list<buildertek__RFQ_Vendor_Item__c>();
                list<buildertek__RFQ_Item__c> rfqlines = [select id,Name,buildertek__RFQ_Package__c from buildertek__RFQ_Item__c where buildertek__RFQ_Package__c IN: RFQIdSet];
                list<buildertek__RFQ_Vendor_Item__c> vendorlines = [select id,Name,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__RFQ_Item__c,buildertek__Cost_Code__c,
                                                                    buildertek__Vendor_Note__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Auto_Number__c,buildertek__Vendor__c 
                                                                    from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c IN: rfqtoVendors];
                
                if(vendorlines.size()>0){
                    for(buildertek__RFQ_Vendor_Item__c rfqvendorline : vendorlines){
                        for(buildertek__RFQ_Item__c rfqrec : rfqlines){
                            if(rfqrec.Id == rfqvendorline.buildertek__RFQ_Item__c){
                                rfqvendorline.buildertek__Unit_Price__c = 0;
                                rfqvendorline.buildertek__Quantity__c = 1;
                                rfqvendorline.buildertek__Vendor_Quantity__c = 1;
                                rfqvendorline.buildertek__Note__c = '';
                                rfqvendorline.buildertek__Vendor_Note__c = '';
                                rfqvendorline.buildertek__Estimated_Work_Days__c = 0;
                                rfqvendorline.buildertek__Vendor_Estimated_Work_Days__c =0;
                                updatevendorlines.add(rfqvendorline );
                            }
                        }
                    }
                    for(buildertek__RFQ_Vendor_Item__c rfqvendorline : vendorlines){
                        if(rfqvendorline.buildertek__RFQ_Item__c == null){
                            system.debug('$$$$'+rfqvendorline.buildertek__RFQ_Item__c);
                            system.debug('updatevendorlines'+deletevendorlines.size());
                            deletevendorlines .add(rfqvendorline );
                        }
                    }
                }
                system.debug('updatevendorlines'+deletevendorlines.size());
                if(updatevendorlines.size()>0){
                    update updatevendorlines;
                }
                if(uprfqVendorList.size()>0){
                    
                    Update uprfqVendorList;
                    system.debug('uprfqVendorList.........'+uprfqVendorList);
                }
                system.debug('deletevendorlines.size'+deletevendorlines.size());
                if(deletevendorlines.size()>0){
                    delete deletevendorlines;
                }
                list<buildertek__File__c> btfileslist = [select id,Name,buildertek__RFQ_To_Vendor__c from buildertek__File__c where buildertek__RFQ_To_Vendor__c IN : rfqtoVendors];
                delete btfileslist;
                
                list<buildertek__Purchase_Order__c> newpurchaseorderlist = new list<buildertek__Purchase_Order__c>();
                list<buildertek__Purchase_Order__c> purchaseorderlist = [select id,Name,buildertek__RFQ__c,buildertek__Status__c from buildertek__Purchase_Order__c where buildertek__RFQ__c IN : RFQIdSet];
                if(purchaseorderlist.size()>0){
                    for(buildertek__Purchase_Order__c purchaserec : purchaseorderlist ){
                        purchaserec.buildertek__Status__c = 'Open';
                        newpurchaseorderlist.add(purchaserec);
                    }
                    update newpurchaseorderlist;
                }
                list<buildertek__Purchase_Order__c> delpurchaseorderlist = [select id,Name,buildertek__RFQ__c,buildertek__Status__c from buildertek__Purchase_Order__c where buildertek__RFQ__c IN : RFQIdSet];
                if(delpurchaseorderlist.size()>0){
                    delete delpurchaseorderlist; 
                }
                list<buildertek__Contract__c> newcontractlist = new list<buildertek__Contract__c>();
                list<buildertek__Contract__c> contractlist = [select id,Name,buildertek__RFQ__c,buildertek__Status__c from buildertek__Contract__c where buildertek__RFQ__c IN : RFQIdSet];
                if(contractlist.size()>0){
                    for(buildertek__Contract__c contactrec : contractlist){
                        contactrec.buildertek__Status__c = 'Draft';
                        newcontractlist .add(contactrec);
                    }
                    update newcontractlist ;
                }
                list<buildertek__Contract__c> delcontractlist = [select id,Name,buildertek__RFQ__c,buildertek__Status__c from buildertek__Contract__c where buildertek__RFQ__c IN : RFQIdSet];
                if(delcontractlist .size()>0){
                    
                    delete delcontractlist;
                }
                list<buildertek__File__c> btrfqfileslist = [select id,Name,buildertek__RFQ__c from buildertek__File__c where buildertek__RFQ__c IN : RFQIdSet];
                if(btrfqfileslist.size() > 0){
                    delete btrfqfileslist;
                }
                
                List<buildertek__RFQ__c> RFQListToUpdate = new List<buildertek__RFQ__c>();
                system.debug('RFQIdSet------' + RFQIdSet);
                string rfqid;
                if (RFQIdSet.size() > 0){
                    List<buildertek__RFQ__c> RFQList;
                    RFQList = [SELECT Id, Name,  buildertek__Status__c,buildertek__Vendor__c,buildertek__Added_to_Quote__c,buildertek__Awarded_Date__c,buildertek__Reason_for_Cancelling_RFQ__c,
                               buildertek__Accepted_Date__c,buildertek__Type__c,buildertek__New_Completion__c,buildertek__RFQ_s_Sent__c,buildertek__RFQ_s_Replied_To__c FROM buildertek__RFQ__c
                               WHERE Id IN :RFQIdSet];
                    system.debug(RFQList.size()+'RFQList------' + RFQList);
                    for (buildertek__RFQ__c rfq : RFQList){
                        if(rfq.buildertek__Status__c != 'New'){
                            rfq.buildertek__Status__c = 'New';
                        }
                        if(rfq.buildertek__Vendor__c != null){
                            rfq.buildertek__Vendor__c = null;
                        }if(rfq.buildertek__Added_to_Quote__c != null){
                            rfq.buildertek__Added_to_Quote__c = null;
                        }if(rfq.buildertek__Awarded_Date__c != null){
                            rfq.buildertek__Awarded_Date__c = null;
                        }if(rfq.buildertek__Reason_for_Cancelling_RFQ__c != ''){
                            rfq.buildertek__Reason_for_Cancelling_RFQ__c = '';
                        }if(rfq.buildertek__Accepted_Date__c != null){
                            rfq.buildertek__Accepted_Date__c = null;
                        }if(rfq.buildertek__Type__c != null){
                            rfq.buildertek__Type__c = null;
                        }if(rfq.buildertek__New_Completion__c != null){
                            rfq.buildertek__New_Completion__c = null;
                        }if(rfq.buildertek__RFQ_s_Sent__c != null){
                            rfq.buildertek__RFQ_s_Sent__c = null;
                        }if(rfq.buildertek__RFQ_s_Replied_To__c != 0){
                            rfq.buildertek__RFQ_s_Replied_To__c = 0;
                        }
                        RFQListToUpdate.add(rfq);
                        
                    }
                }
                
                if (RFQListToUpdate.size() > 0){
                    update RFQListToUpdate;
                    system.debug('RFQListToUpdate.......'+RFQListToUpdate);
                }
                string theTemplate;
                theTemplate = [SELECT Id FROM EmailTemplate WHERE Name  = : 'RFQ Void Email'].id;  
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                system.debug('rfqVendorList^^^^^'+rfqVendorList.size());
                for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                    system.debug('rfqVendorList'+rfqVendor.buildertek__Contact__r.Email);
                    system.debug('rfqVendor.buildertek__Contact__c'+rfqVendor.buildertek__Contact__c);
                    if(rfqVendor.buildertek__Contact__r.Email != null){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        string toemailadd = rfqVendor.buildertek__Contact__r.Email;
                        message.toAddresses = new String[] { toemailadd};
                            system.debug('&&&'+toemailadd);
                        message.setTemplateID(theTemplate);     
                        message.setSaveAsActivity(false);
                        message.setWhatId(rfqVendor.Id);
                        message.setTargetObjectId(rfqVendor.buildertek__Contact__c);
                        messageList.add(message);
                    }
                }
                if(messageList.size()>0){
                    Messaging.sendEmail(messageList);
                }
                list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live' ];
                system.debug('%%%'+netRec.size());
                if(netRec.size() > 0){
                    list<Id> contactids= new list<Id>(); 
                    map<Id,buildertek__RFQ_To_Vendor__c> vendorUserMap2 = new map<Id,buildertek__RFQ_To_Vendor__c>();
                    List<Messaging.SingleEmailMessage> messageList1 = new List<Messaging.SingleEmailMessage>();   
                    for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorList){
                        contactids.add(venroRec.buildertek__Contact__c);
                    }
                    map<Id,User> vendorUserMap1 = new map<Id,User>();
                    string strQry1 = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                        'FROM User Where ContactId IN : contactids And isPortalEnabled=true ';    
                    system.debug('strQry1t-->'+strQry1);
                    list<User> userList1= Database.query(strQry1);
                    system.debug('userList'+userList1);
                    if(userList1.size() > 0){
                        for(User usr: userList1){
                            vendorUserMap1.put(usr.ContactId,usr);
                        }
                    }
                    List<Messaging.SingleEmailMessage> messageLists1 = new List<Messaging.SingleEmailMessage>();
                    for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorList){
                        if(vendorUserMap1.get(venroRec.buildertek__Contact__c)!=null){
                            User usrrec1 = vendorUserMap1.get(venroRec.buildertek__Contact__c);
                            if(venroRec.buildertek__Contact__r.Email != usrrec1.Email){
                                Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
                                string toemailadd = usrrec1.Email;
                                message1.toAddresses = new String[] { toemailadd};
                                    system.debug('&&&'+toemailadd);
                                message1.setTemplateID(theTemplate);     
                                message1.setSaveAsActivity(false);
                                message1.setWhatId(venroRec.Id);
                                message1.setTargetObjectId(usrrec1.id);
                                messageLists1.add(message1);
                            }
                        }
                    }
                    if(messageLists1.size()>0){
                        Messaging.sendEmail(messageLists1);
                    }
                }
                
                return 'SUCCESS';
            }else if(recordId != null){
                buildertek__RFQ__c RFQRec = [SELECT Id, Name,  buildertek__Status__c,buildertek__Vendor__c,buildertek__Added_to_Quote__c,buildertek__Awarded_Date__c,buildertek__Reason_for_Cancelling_RFQ__c,buildertek__Accepted_Date__c,buildertek__Type__c,
                                             buildertek__New_Completion__c,buildertek__RFQ_s_Sent__c,buildertek__RFQ_s_Replied_To__c FROM buildertek__RFQ__c
                                             WHERE Id =: recordId];
                //  RFQRec.buildertek__Status__c = 'Canceled';
                //  RFQRec.buildertek__Reason_for_Cancelling_RFQ__c = reason;
                if(RFQRec.buildertek__Status__c != 'New'){
                    RFQRec.buildertek__Status__c = 'New';
                }
                if(RFQRec.buildertek__Vendor__c != null){
                    RFQRec.buildertek__Vendor__c = null;
                }if(RFQRec.buildertek__Added_to_Quote__c != null){
                    RFQRec.buildertek__Added_to_Quote__c = null;
                }if(RFQRec.buildertek__Awarded_Date__c != null){
                    RFQRec.buildertek__Awarded_Date__c = null;
                }if(RFQRec.buildertek__Reason_for_Cancelling_RFQ__c != ''){
                    RFQRec.buildertek__Reason_for_Cancelling_RFQ__c = '';
                }if(RFQRec.buildertek__Accepted_Date__c != null){
                    RFQRec.buildertek__Accepted_Date__c = null;
                }if(RFQRec.buildertek__Type__c != null){
                    RFQRec.buildertek__Type__c = null;
                }if(RFQRec.buildertek__New_Completion__c != null){
                    RFQRec.buildertek__New_Completion__c = null;
                }if(RFQRec.buildertek__RFQ_s_Sent__c != null){
                    RFQRec.buildertek__RFQ_s_Sent__c = null;
                }if(RFQRec.buildertek__RFQ_s_Replied_To__c != 0){
                    RFQRec.buildertek__RFQ_s_Replied_To__c = 0;
                }
                update RFQRec;
                system.debug('RFQRec.......'+RFQRec);
                return 'SUCCESS';
            }else{
                return null;
            }
            
        }catch (Exception ex){
            system.debug('extestji'+ex.getLineNumber());
            return ex.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static string sendRFQCancelEmailToVendor(List<String> rfqToVendorLinkIds){
        List<RFQ_To_Vendor__c> rfqVendors = new List<RFQ_To_Vendor__c>();
        List<String> rfqEmailForContact = new List<String>(); 
        SET<Id> RFQIdSet = new SET<Id>();
        List<RFQ_To_Vendor__c> rfqVendorList;
        if ( Schema.sObjectType.RFQ_To_Vendor__c.fields.id.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isAccessible() && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()){
            rfqVendorList = [select Id, Send_Invitation__c, Status__c, buildertek__RFQ__c,buildertek__RFQ__r.Name,buildertek__Contact__c,buildertek__Contact__r.Email
                             from RFQ_To_Vendor__c
                             where Id IN :rfqToVendorLinkIds];
        }
        for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
            if(rfqVendor.buildertek__RFQ__c !=null){
                RFQIdSet.add(rfqVendor.buildertek__RFQ__c);
            }if(rfqVendor.buildertek__Contact__r.Email !=null){
                rfqEmailForContact.add(rfqVendor.buildertek__Contact__r.Email);
            }
            
            
        }
        system.debug('rfqEmailForContact:::'+rfqEmailForContact);
        system.debug('rfqVendorList::::'+rfqVendorList);
        SET<Id> RfqvendrId = new SET<Id>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(rfqEmailForContact);
        if (rfqVendorList.size() > 0){
            for (RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                if (rfqVendor.Status__c == 'Accepted' || rfqVendor.Status__c == 'Awarded'){
                    system.debug('Send Invitation ---------> ');
                    mail.setSubject('RFQ Cancelation Notice for "' + rfqVendor.buildertek__RFQ__r.Name + '"');
                    mail.setHtmlBody('<p>We apologize but we are cancelling the RFQ for this work. <br/><br/> If you have any questions please contact the office.</p>');
                    mail.setWhatId(rfqVendor.Id);
                    mail.setTargetObjectId(rfqVendor.buildertek__Contact__c);
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                    
                    RFQ_To_Vendor__c rfqToVendor = new RFQ_To_Vendor__c();
                    rfqToVendor.Id = rfqVendor.Id;
                    rfqToVendor.Status__c ='New';
                    rfqVendors.add(rfqToVendor);
                    
                }
            }
        }
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            system.debug('results:::'+results);
        }
        try{
            if(rfqVendors.size()>0){
                if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable() ){
                    update rfqVendors;
                }
            }
            List<buildertek__RFQ__c> RFQListToUpdate = new List<buildertek__RFQ__c>();
            system.debug('RFQIdSet------' + RFQIdSet);
            string rfqid;
            if (RFQIdSet.size() > 0){
                List<buildertek__RFQ__c> RFQList;
                if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c .isAccessible()){
                    RFQList = [SELECT Id, Name,  buildertek__Status__c 
                               FROM buildertek__RFQ__c
                               WHERE Id IN :RFQIdSet];
                }
                system.debug(RFQList.size()+'RFQList------' + RFQList);
                for (buildertek__RFQ__c rfq : RFQList){
                    rfq.buildertek__Status__c = 'New';
                    RFQListToUpdate.add(rfq);
                }
            }
            
            if (RFQListToUpdate.size() > 0){
                if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isUpdateable()){
                    update RFQListToUpdate;
                }
            }
            system.debug('Send cancel  final ---------> ' + rfqVendors);
            return 'SUCCESS';
        }catch (Exception ex){
            return ex.getMessage();
        }
        
    }
    
    /**************************************************************************
Purpose: link RFQ Documents
Parameters: NA
Returns: Status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string linkRFQDocuments(List<Buildertek__File__c> files, String RFQid){
        system.debug('files -------> ' + files);
        // Link All the RFQ Documents with Vendor record
        List<RFQ_To_Vendor_Document_Link__c> docLinks = new List<RFQ_To_Vendor_Document_Link__c>();
        if (Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.file__c.isCreateable() && Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.RFQ_To_Vendor__c.isCreateable()){
            for (RFQ_To_Vendor__c vendor : [Select Id
                                            from RFQ_To_Vendor__c
                                            where RFQ__c = :RFQid]){
                                                for (Buildertek__File__c file : files){
                                                    RFQ_To_Vendor_Document_Link__c docLink = new RFQ_To_Vendor_Document_Link__c();
                                                    docLink.file__c = file.Id;
                                                    docLink.RFQ_To_Vendor__c = vendor.Id;
                                                    docLinks.add(docLink);
                                                }
                                            }
        }
        try{
            insert docLinks;
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    /**************************************************************************
Purpose: link RFQ Documents
Parameters: NA
Returns: Status
Throws [Exceptions]: NA
****************************************************************************/
    @AuraEnabled
    public static string linkRFQDocumentToVendor(String fileId, String vendorId){
        // Link All the RFQ Documents with Vendor record
        List<RFQ_To_Vendor_Document_Link__c> docLinks = new List<RFQ_To_Vendor_Document_Link__c>();
        if (Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.file__c.isCreateable() && Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.RFQ_To_Vendor__c.isCreateable()){
            RFQ_To_Vendor_Document_Link__c docLink = new RFQ_To_Vendor_Document_Link__c();
            docLink.file__c = fileId;
            docLink.RFQ_To_Vendor__c = vendorId;
            docLinks.add(docLink);
        }
        try{
            insert docLinks;
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    /**************************************************************************
Purpose: Create RFQ Items for Vendor
Parameters: NA
Returns: Radio options list
Throws [Exceptions]: NA
****************************************************************************/
    public static void linkRfqItems(Map<Id, set<Id>> rfqToVendorIds){
        
        Map<Id, RFQ__c> rfqs = new Map<Id, RFQ__c>([Select Id, (Select Id, Name, Cost_Code__c, Quantity__c, Description__c,buildertek__Estimated_Work_Days__c
                                                                from Rfq_Items__r), (Select Id
                                                                                     from files__r)
                                                    from RFQ__c
                                                    where Id IN :rfqToVendorIds.KeySet()]);
        
        List<RFQ_Vendor_Item__c> rfqToVendorItems = new List<RFQ_Vendor_Item__c>();
        
        // Link All the RFQ Documents with Vendor record
        List<RFQ_To_Vendor_Document_Link__c> docLinks = new List<RFQ_To_Vendor_Document_Link__c>();
        
        for (Id rfqId : rfqToVendorIds.keyset()){
            for (RFQ_Item__c rfqItem : rfqs.get(rfqId).Rfq_Items__r){
                for (Id vendorId : rfqToVendorIds.get(rfqId)){
                    if (Schema.sObjectType.RFQ_Vendor_Item__c.fields.Name.isCreateable() && 
                        Schema.sObjectType.RFQ_Vendor_Item__c.fields.Item_Name__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Cost_code__c.isCreateable() 
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Vendor__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.RFQ_Item__c.isCreateable() 
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.buildertek__Estimated_Work_Days__c.isCreateable()
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Description__c.isCreateable()){
                        RFQ_Vendor_Item__c rfqToVendorItem = new RFQ_Vendor_Item__c();
                        rfqToVendorItem.Name = rfqItem.Name;
                        rfqToVendorItem.Item_Name__c = rfqItem.Name;
                        rfqToVendorItem.Cost_code__c = rfqItem.cost_code__c;
                        rfqToVendorItem.Vendor__c = vendorId;
                        rfqToVendorItem.RFQ_Item__c = rfqItem.Id;
                        rfqToVendorItem.Quantity__c = rfqItem.Quantity__c;
                        rfqToVendorItem.buildertek__Estimated_Work_Days__c = rfqItem.buildertek__Estimated_Work_Days__c;
                        rfqToVendorItem.Description__c = rfqItem.Description__c;
                        rfqToVendorItems.add(rfqToVendorItem);
                    }
                }
            }
            
            if (!rfqs.get(rfqId).Files__r.isEmpty()){
                for (File__c file : rfqs.get(rfqId).Files__r){
                    for (Id vendorId : rfqToVendorIds.get(rfqId)){
                        if (Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.file__c.isCreateable() && Schema.sObjectType.RFQ_To_Vendor_Document_Link__c.fields.RFQ_To_Vendor__c.isCreateable()){
                            RFQ_To_Vendor_Document_Link__c docLink = new RFQ_To_Vendor_Document_Link__c();
                            docLink.file__c = file.Id;
                            docLink.RFQ_To_Vendor__c = vendorId;
                            docLinks.add(docLink);
                        }
                    }
                }
            }
        }
        
        if (!docLinks.isEmpty())
            insert docLinks;
        if (!rfqToVendorItems.isEmpty())
            insert rfqToVendorItems;
        system.debug('rfqToVendorItems-----' + rfqToVendorItems);
    }
    
    /**************************************************************************
Purpose: Create RFQ Items for Vendor, This method will call from trigger, When user add new item and vendor is alrady added then we have to add the itme in vendor list aswell
Parameters: NA
Returns: Radio options list
Throws [Exceptions]: NA
****************************************************************************/
    public static void linkNewRfqItems(Map<Id, RFQ_Item__c> rfqItemById){
        try{
        
        map<Id, List<RFQ_Item__c>> itemByParent = new map<Id, List<RFQ_Item__c>>();
        System.debug(rfqItemById.values());
        for (RFQ_Item__c item : rfqItemById.values()){
            if (itemByParent.containsKey(item.RFQ_Package__c)){
                itemByParent.get(item.RFQ_Package__c).add(item);
            } else{
                itemByParent.put(item.RFQ_Package__c, new List<RFQ_Item__c>{item});
            }
        }
        
        Map<Id, RFQ__c> rfqById = new map<Id, RFQ__c>([Select Id, (Select Id, Name
                                                                   from RFQ_to_Vendors__r)
                                                       from RFQ__c
                                                       where Id IN :itemByParent.keySet()]);
        System.debug(rfqById);
        
        List<RFQ_Vendor_Item__c> rfqToVendorItems = new List<RFQ_Vendor_Item__c>();
        System.debug(itemByParent.keyset());
        System.debug(itemByParent);


        for (Id rfqId : itemByParent.keyset()){
            for (RFQ_Item__c rfqItem : itemByParent.get(rfqId)){
                for (RFQ_to_Vendor__c vendor : rfqById.get(rfqId).RFQ_to_Vendors__r){
                    if (Schema.sObjectType.RFQ_Vendor_Item__c.fields.Name.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Item_Name__c.isCreateable() 
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Cost_code__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Vendor__c.isCreateable()
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.RFQ_Item__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Quantity__c.isCreateable() 
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.buildertek__Estimated_Work_Days__c.isCreateable() 
                        && Schema.sObjectType.RFQ_Vendor_Item__c.fields.Description__c.isCreateable() && Schema.sObjectType.RFQ_Vendor_Item__c.fields.buildertek__unit_price__c.isCreateable()){
                        RFQ_Vendor_Item__c rfqToVendorItem = new RFQ_Vendor_Item__c();
                        rfqToVendorItem.Name = rfqItem.Name;
                        rfqToVendorItem.Item_Name__c = rfqItem.Name;
                        rfqToVendorItem.Cost_code__c = rfqItem.cost_code__c;
                        rfqToVendorItem.Vendor__c = vendor.Id;
                        rfqToVendorItem.RFQ_Item__c = rfqItem.Id;
                        rfqToVendorItem.buildertek__Estimated_Work_Days__c = rfqItem.buildertek__Estimated_Work_Days__c;
                        rfqToVendorItem.Quantity__c = rfqItem.Quantity__c;
                        rfqToVendorItem.buildertek__Unit_Price__c = rfqItem.buildertek__Unit_Price__c;
                        rfqToVendorItem.Description__c = rfqItem.Description__c;
                        rfqToVendorItems.add(rfqToVendorItem);
                    }
                }
            }
        }
        system.debug('rfqToVendorItems ---------> ' + rfqToVendorItems);
        if (!rfqToVendorItems.isEmpty())
            insert rfqToVendorItems;
    }catch( Exception e){
        String msg =e.getMessage();
        Integer line = e.getLineNumber();
        System.debug(msg);
        System.debug(line);
       
    }
    }
    
    public static void deleteLinkedVendorItems(Map<Id, RFQ_Item__c> rfqItemById){
        if (RFQ_Vendor_Item__c.sObjectType.getDescribe().isDeletable()){
            delete [Select Id
                    from RFQ_Vendor_Item__c
                    where RFQ_Item__c IN :rfqItemById.Keyset()];
        }
    }
    
    /**************************************************************************
Purpose: copy budget item details to rfq itmes
Parameters: NA
Returns: Radio options list
Throws [Exceptions]: NA
****************************************************************************/
    public static void copyBudgetItemDetails(List<RFQ_Item__c> rfqItems){
        
        Set<Id> budgetItemIds = new Set<Id>();
        for (RFQ_Item__c rfqItem : rfqItems){
            
            if (String.isBlank(rfqItem.Name) && rfqItem.Budget_Item__c != null){
                budgetItemIds.add(rfqItem.Budget_Item__c);
            }
            
        }
        
        if (!budgetItemIds.isEmpty()){
            Map<Id, Budget_Item__c> budgetItems = new Map<Id, Budget_Item__c>([Select Id, Name, Cost_Code__c, Description__c, Quantity__c
                                                                               from Budget_Item__c
                                                                               where Id IN :budgetItemIds]);
            
            for (RFQ_Item__c rfqItem : rfqItems){
                
                if (String.isBlank(rfqItem.Name) && rfqItem.Budget_Item__c != null){
                    Budget_Item__c budgetItem = budgetItems.get(rfqItem.Budget_Item__c);
                    rfqItem.Name = budgetItem.Name;
                    rfqItem.Cost_Code__c = budgetItem.Cost_Code__c;
                    rfqItem.Description__c = budgetItem.Description__c;
                    rfqItem.Quantity__c = budgetItem.Quantity__c;
                }
            }
        }
    }
    
    /**************************************************************************
Purpose: copy quote item details to rfq itmes
Parameters: NA
Returns: Radio options list
Throws [Exceptions]: NA
****************************************************************************/
    public static void copyQuoteItemDetails(List<RFQ_Item__c> rfqItems){
        
        Set<Id> quoteItemIds = new Set<Id>();
        for (RFQ_Item__c rfqItem : rfqItems){
            
            if (String.isBlank(rfqItem.Name) && rfqItem.Quote_Item__c != null){
                quoteItemIds.add(rfqItem.Quote_Item__c);
            }
            
        }
        
        if (!quoteItemIds.isEmpty()){
            Map<Id, Quote_Item__c> quoteItems = new Map<Id, Quote_Item__c>([Select Id, Name, Cost_Code__c, Description__c, Quantity__c
                                                                            from Quote_Item__c
                                                                            where Id IN :quoteItemIds]);
            
            for (RFQ_Item__c rfqItem : rfqItems){
                
                if (String.isBlank(rfqItem.Name) && rfqItem.Quote_Item__c != null){
                    Quote_Item__c quoteItem = quoteItems.get(rfqItem.Quote_Item__c);
                    rfqItem.Name = quoteItem.Name;
                    rfqItem.Cost_Code__c = quoteItem.Cost_Code__c;
                    rfqItem.Description__c = quoteItem.Description__c;
                    rfqItem.Quantity__c = quoteItem.Quantity__c;
                }
            }
        }
    }
    
    /**********************************************************************************************************************
Purpose: This method is used to create a RFQ for selected itmes
Parameters: RFQ__c co, string coItemsJson
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static ResponseBase createRFQ(String rfqJson, string rfqItemsJson){
        system.debug('RFQ To Insert --------> ' + rfqJson);
        system.debug('rfqItemsJson ----------> ' + rfqItemsJson);
        ResponseBase res = new ResponseBase();
        try{
            buildertek__RFQ__c rfqToInsert = (buildertek__RFQ__c)JSON.deserialize(rfqJson, buildertek__RFQ__c.class);
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isCreateable()){
                insert rfqToInsert;
            }
            List<buildertek__RFQ_Item__c> rfqItemList = new List<buildertek__RFQ_Item__c>();
            List<buildertek__RFQ_Item__c> rfqItems = new List<buildertek__RFQ_Item__c>();
            List<RFQLineItemsClass> RFQItemsList = (List<RFQLineItemsClass>)System.JSON.deserialize(rfqItemsJson, List<RFQLineItemsClass>.class);
            system.debug('RFQItemsList ------------> ' + RFQItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for (RFQLineItemsClass wrapper : RFQItemsList){
                rfqItemList.add(wrapper.rfqItem);
                productIdSet.add(wrapper.rfqItem.buildertek__Product__c);
            }
            List<Product2> productList;
            if (Schema.sObjectType.Product2.fields.Id.isAccessible() && Schema.sObjectType.Product2.fields.Name.isAccessible()){
                productList = [SELECT Id, Name
                               from Product2
                               where Id IN :productIdSet];
            }
            Map<String, String> productNameMap = new Map<String, String>();
            for (Product2 prod : productList){
                productNameMap.put(prod.Id, prod.Name);
            }
            
            for (buildertek__RFQ_Item__c rfqItem : rfqItemList){
                if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isCreateable()){
                    
                    rfqItem.Name = productNameMap.get(rfqItem.buildertek__Product__c);
                    rfqItem.buildertek__RFQ_Package__c = rfqToInsert.Id;
                    rfqItems.add(rfqItem);
                    
                }
                
            }
            
            insert rfqItems;
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = rfqToInsert.Id;
            return res;
            
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
            system.debug('Message --------> ' + ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
        
        //return res;
    }
    
    @AuraEnabled
    public static List<buildertek__RFQ__c> getAllApprovedRFQ(String quotId){
        buildertek__Quote__c quote;
        if (Schema.sObjectType.Quote__c.fields.Id.isAccessible() && Schema.sObjectType.Quote__c.fields.Project__c.isAccessible()){
            quote = [Select Id, buildertek__Project__c
                     from buildertek__Quote__c
                     where Id = :quotId];
        }

        List<buildertek__Quote_Item__c> QuoteItemList = [Select Id, buildertek__Quote__c, buildertek__RFQ__c
                                                         from buildertek__Quote_Item__c];
        
        //get buildertek__RFQ__c Ids from QuoteItemList
        Set<Id> rfqIds = new Set<Id>();
        for(buildertek__Quote_Item__c quoteItem : QuoteItemList){
            if(quoteItem.buildertek__RFQ__c != null){
                rfqIds.add(quoteItem.buildertek__RFQ__c);
            }
        }
        System.debug('rfqIds--->>>'+rfqIds);
        
        // return [Select Id, Name,RFQ_Details__c,Status__c, Vendor__r.Name, Vendor_Quote__c from RFQ__c where project__c =:quote.Project__c and status__c = 'Awarded'];
        // return [Select Id, Name, RFQ_Details__c, Status__c, Vendor__r.Name, Vendor_Quote__c
        //   from RFQ__c
        //  where project__c = :quote.Project__c and status__c = 'Accepted'];
        System.debug('quote ==> '+quote.buildertek__Project__c);
        list<buildertek__RFQ__c> rfqlist= new list<buildertek__RFQ__c>();
        string status = 'Accepted';
        if(UserInfo.isMultiCurrencyOrganization()){
            
            String projectId = '';
            if (quote.buildertek__Project__c != null) {
                projectId = quote.buildertek__Project__c;
            }
            //append that id of rfq should not be in rfqIds
            String rfqItemrecords = 'Select Id, Name, buildertek__RFQ_Details__c, buildertek__Status__c, buildertek__Vendor__r.Name, buildertek__Vendor_Quote__c,CurrencyIsoCode, buildertek__Project__c, buildertek__Project__r.Name from buildertek__RFQ__c'+
                ' where buildertek__Added_to_Quote__c = null and buildertek__project__c =\'' + projectId +'\' and buildertek__status__c =\'' +status+'\' and Id NOT IN :rfqIds ORDER BY Name';
            system.debug('rfqItemrecords'+rfqItemrecords);
            rfqlist = Database.query(rfqItemrecords);
            return rfqlist;
        }else{
            // return [Select Id, Name,RFQ_Details__c,Status__c, Vendor__r.Name, Vendor_Quote__c from RFQ__c where project__c =:quote.Project__c and status__c = 'Awarded'];           
            List<buildertek__RFQ__c> rfqlist1 = [Select Id, Name, buildertek__RFQ_Details__c, buildertek__Status__c, buildertek__Vendor__r.Name, buildertek__Vendor_Quote__c, buildertek__Project__c, buildertek__Project__r.Name
                    from buildertek__RFQ__c
                    where buildertek__project__c = :quote.buildertek__Project__c and buildertek__status__c = 'Accepted' and ID NOT IN :rfqIds ORDER BY Name];
            return rfqlist1;
        }
    }
    
    //Search RFQs based on Name, Project and Vendor
    @AuraEnabled
    public static List<buildertek__RFQ__c> getRFQSearch (String quotId, String searchKeyword, String searchProject, String searchVendor){
        buildertek__Quote__c quote = [SELECT Id, buildertek__Project__c FROM buildertek__Quote__c WHERE Id = :quotId];
        

        List<buildertek__Quote_Item__c> QuoteItemList = [Select Id, buildertek__Quote__c, buildertek__RFQ__c
                                                         from buildertek__Quote_Item__c];
        
        //get buildertek__RFQ__c Ids from QuoteItemList
        Set<Id> rfqIds = new Set<Id>();
        for(buildertek__Quote_Item__c quoteItem : QuoteItemList){
            if(quoteItem.buildertek__RFQ__c != null){
                rfqIds.add(quoteItem.buildertek__RFQ__c);
            }
        }

        String projectId = '';
        if (quote.buildertek__Project__c != null) {
            projectId = quote.buildertek__Project__c;
        }

        string status = 'Accepted';
        String query= 'SELECT Id, Name, buildertek__RFQ_Details__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Vendor_Quote__c, buildertek__Project__c, buildertek__Project__r.Name,';
        query += ' buildertek__Status__c FROM buildertek__RFQ__c WHERE buildertek__project__c = \''+ projectId +'\' AND buildertek__status__c =\''+status+'\' and Id NOT IN :rfqIds';
        if ( searchKeyword != '' && searchKeyword != null ) {
            query = query + ' AND Name LIKE \'' + searchKeyword + '%\'';
        }
        if ( searchProject != '' && searchProject != null ) {
            query = query + ' AND buildertek__Project__r.Name LIKE \'' + searchProject + '%\'';
        }
        if ( searchVendor != '' && searchVendor != null ) {
            query = query + ' AND buildertek__Vendor__r.Name LIKE \'' + searchVendor + '%\'';
        }
        return Database.query(query);
    } 
    
    @AuraEnabled
    public static string createCOFromRFQ(string rfqId){
        String query = 'Select buildertek__Vendor__r.vendor__c,' + BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c')+',(Select ' + BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' from RFQ_Items__r) From RFQ__c where Id =:rfqId order by Name';
        map<Id, RFQ__c> rfqmap = new Map<Id, RFQ__c>();
        
        for (RFQ__c rfq : Database.query(String.escapeSingleQuotes(query))){
            rfqmap.put(rfq.Id, rfq);
        }
        system.debug('RFQ Map -------> ' + rfqmap);
        return ChangeOrderDAO.createCOFromRFQ(rfqmap, new Map<Id, Contract__c>());
    }
    
    public class rfqConfig{
        @AuraEnabled
        public RFQ__c rfq{ get; set; }
        
        @AuraEnabled
        public RFQ_Configuration__c config{ get; set; }
        
        public rfqConfig(RFQ__c rfq){
            this.rfq = rfq;
            
            // Get RFQ Configuration
            Map<String, RFQ_Configuration__c> rfqConfigurationMap = RFQ_Configuration__c.getAll();
            
            if (rfqConfigurationMap != null && rfqConfigurationMap.size() > 0)
                config = rfqConfigurationMap.get(BT_Constants.RFQ_CONFIGURATION);
        }
    }
    
    @AuraEnabled
    public static String emailPreview(String rfqId, String vendorId){
        return BT_SendEmailController.getEmailBodyFromTemplate(vendorId, null, null, 'RFQ Invitation Email New');
    }
    
    @AuraEnabled
    public static void sendEmail(String parentRecordID){
        system.debug('parentRecordID --------->' + parentRecordID);
        buildertek__RFQ_To_Vendor__c rfq;
        if (Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible()){
            rfq = [select Id, Name, buildertek__Contact__c, buildertek__RFQ__c
                   from buildertek__RFQ_To_Vendor__c
                   where Id = :parentRecordID];
        }
        string RFQId = rfq.Id;
        string vendorContactId = rfq.buildertek__Contact__c;
        
        List<contact> contactList;
        if (Schema.sObjectType.contact.fields.Id.isAccessible() && Schema.sObjectType.contact.fields.Name.isAccessible() && Schema.sObjectType.contact.fields.Email.isAccessible()){
            contactList = [select Id, Name, Email
                           from contact
                           where Id = :rfq.buildertek__Contact__c];
        }
        List<String> emailList = new List<String>();
        for (Contact con : contactList){
            emailList.add(con.Email);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailList);
        EmailTemplate et;
        
        et = [select id
              from EmailTemplate
              where Name = 'RFQ Invitation Email New' and isActive = true];
        
        mail.setTemplateId(et.id);
        List<OrgWideEmailAddress> owe;
        if (Schema.sObjectType.OrgWideEmailAddress.fields.ID.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.IsAllowAllProfiles.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.DisplayName.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible()){
            owe = [SELECT ID, IsAllowAllProfiles, DisplayName, Address
                   FROM OrgWideEmailAddress
                   WHERE IsAllowAllProfiles = TRUE
                   LIMIT 1];
        }
        if (owe != null && owe.size() > 0){
            mail.setOrgWideEmailAddressId(owe[0].Id);
            mail.setReplyTo(owe[0].Address);
        } else{
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setReplyTo(UserInfo.getUserEmail());
        }
        mail.setHtmlBody('<p></p>');
        mail.setWhatId(parentRecordID);
        mail.setTargetObjectId(vendorContactId);
        mail.setSaveAsActivity(true);
        mails.add(mail);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
    @AuraEnabled
    public static List<RFQLineItemsClass> getProduct(String rfqItems){
        system.debug('rfqItems -----------> ' + rfqItems);
        List<buildertek__RFQ_Item__c> rfqItemList = (List<buildertek__RFQ_Item__c>)JSON.deserialize(rfqItems, List<buildertek__RFQ_Item__c>.class);
        system.debug('rfqItemList -----------> ' + rfqItemList);
        List<RFQLineItemsClass> RFQItemsClassList = new List<RFQLineItemsClass>();
        Integer count = 0;
        for (buildertek__RFQ_Item__c rfqItem : rfqItemList){
            RFQLineItemsClass RFQItemsClass = new RFQLineItemsClass(rfqItem, true, count);
            count++;
            RFQItemsClassList.add(RFQItemsClass);
        }
        
        return RFQItemsClassList;
    }
    
    @AuraEnabled
    public static List<RFQLineItemsClass> addProductsToList(String rfqItemsList, buildertek__RFQ_Item__c rfqItem, Integer count){
        system.debug('rfqItemsList -----------> ' + rfqItemsList);
        system.debug('rfqItem -----------> ' + rfqItem);
        system.debug('count ---------> ' + count);
        List<RFQLineItemsClass> rfqItemClassList = (List<RFQLineItemsClass>)JSON.deserialize(rfqItemsList, List<RFQLineItemsClass>.class);
        system.debug('rfqItemClassList -----------> ' + rfqItemClassList);
        
        rfqItemClassList.add(new RFQLineItemsClass(rfqItem, false, count));
        return rfqItemClassList;
    }
    
    @AuraEnabled
    public static void createTask(String whoId, String whatId, String emailSubject){
        if (Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.WhoId.isCreateable() && Schema.sObjectType.Task.fields.WhatId.isCreateable() && Schema.sObjectType.Task.fields.TaskSubType.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()){
            Task tsk = new Task();
            tsk.Subject = emailSubject;
            tsk.WhoId = whoId;
            tsk.WhatId = whatId;
            tsk.TaskSubType = 'Email';
            tsk.ActivityDate = Date.today();
            tsk.Status = 'Completed';
            insert tsk;
        }
    }
    
    @AuraEnabled
    public static void createMultipleTasks(List<String> contactIds, String whatId, String emailSubject){
        if (Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.WhoId.isCreateable() && Schema.sObjectType.Task.fields.WhatId.isCreateable() && Schema.sObjectType.Task.fields.TaskSubType.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()){
            List<Task> taskRecords = new List<Task>();
            for (String conId : contactIds){
                Task tsk = new Task();
                tsk.Subject = emailSubject;
                tsk.WhoId = conId;
                tsk.WhatId = whatId;
                tsk.TaskSubType = 'Email';
                tsk.ActivityDate = Date.today();
                tsk.Status = 'Completed';
                taskRecords.add(tsk);
            }
            insert taskRecords;
        }
    }
    
    @AuraEnabled
    public static Object getmasterRFQItems(){
        List<MasterRFQItemsClass> rfqClassList = new List<MasterRFQItemsClass>();
        List<buildertek__RFQ_Item__c> rfqItemList;
        /*if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible() && 
Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Product__c.isAccessible() && 
Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Trade_Type__c.isAccessible() 
&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isAccessible() 
&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isAccessible()
&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Description__c.isAccessible()
&& Schema.sObjectType.buildertek__Trade_Type__c.fields.Name.isAccessible()){*/
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqItemrecords = 'SELECT Id, Name,CurrencyIsoCode, buildertek__Product__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__Quantity__c, buildertek__Unit_Price__c,buildertek__Description__c '+
                'FROM buildertek__RFQ_Item__c WHERE buildertek__Master_Item__c = true';
            rfqItemList = Database.query(rfqItemrecords);
        }else{
            rfqItemList = [SELECT Id, Name, buildertek__Product__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__Quantity__c, buildertek__Unit_Price__c,buildertek__Description__c
                           FROM buildertek__RFQ_Item__c
                           WHERE buildertek__Master_Item__c = true];
        }
        //}
        
        if (rfqItemList.size() > 0){
            for (buildertek__RFQ_Item__c rfqItem : rfqItemList){
                MasterRFQItemsClass rfqClass = new MasterRFQItemsClass();
                rfqClass.MasterRFQItem = rfqItem;
                rfqClass.SubmittalCheck = false;
                rfqClassList.add(rfqClass);
            }
        }
        
        String JSONString = JSON.serialize(rfqClassList);
        system.debug('Json String ' + JSONString);
        return JSONString;
    }
    
    @AuraEnabled
    public static void importRFQItems(List<String> Id, String RFQId){
        list<buildertek__RFQ_Item__c> masterRFQItemToInsert = new list<buildertek__RFQ_Item__c>();
        list<buildertek__RFQ_Item__c> masterRFQList;
        if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Product__c.isAccessible() 
            && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Trade_Type__c.isAccessible() && 
            Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isAccessible() && 
            Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isAccessible() && 
            Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Description__c.isAccessible() &&
            Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Cost_Code__c.isAccessible()){
                masterRFQList = [SELECT Id, Name, buildertek__Product__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Cost_Code__c,buildertek__Description__c
                                 FROM buildertek__RFQ_Item__c
                                 WHERE Id IN :Id];
            }
        for (buildertek__RFQ_Item__c masterRFQItem : masterRFQList){
            if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Trade_Type__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isCreateable()){
                
                buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
                rfqItem.Name = masterRFQItem.Name;
                rfqItem.buildertek__Product__c = masterRFQItem.buildertek__Product__c;
                rfqItem.buildertek__Trade_Type__c = masterRFQItem.buildertek__Trade_Type__c;
                rfqItem.buildertek__Quantity__c = masterRFQItem.buildertek__Quantity__c;
                rfqItem.buildertek__Unit_Price__c = masterRFQItem.buildertek__Unit_Price__c;
                rfqItem.buildertek__Cost_Code__c = masterRFQItem.buildertek__Cost_Code__c;
                rfqItem.buildertek__Description__c = masterRFQItem.buildertek__Description__c;
                rfqItem.buildertek__RFQ_Package__c = RFQId;
                masterRFQItemToInsert.add(rfqItem);
                
            }
            
        }
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
    }
    
    /* @AuraEnabled
public static List<ListView> getListViews() {
List<ListView> listviews =
[SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__RFQ__c' and Name='All'];

// Perform isAccessible() check here
return listviews;
}*/
    
    
    @AuraEnabled
    public static ResponseBase createRFQFromQuote(String QuoteId, String selectQuoteItemId){
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try{
            buildertek__Quote_Item__c selectedQuoteItem;
            if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__RFQ__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.Project__c.isAccessible()){
                selectedQuoteItem = [SELECT Id, Name, buildertek__RFQ__c, buildertek__Quote__c, buildertek__Quote__r.Project__c, buildertek__Quote__r.Name
                                     FROM buildertek__Quote_Item__c
                                     WHERE Id = :selectQuoteItemId];
            }
            System.debug('selectedQuoteItem--->>>'+selectedQuoteItem);
            
            
            buildertek__RFQ__c newRFQ = new buildertek__RFQ__c();
            newRFQ.Name = selectedQuoteItem.Name;
            newRFQ.buildertek__Project__c = selectedQuoteItem.buildertek__Quote__r.Project__c;
            newRFQ.buildertek__Status__c = 'New';
            
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isCreateable()){
                insert newRFQ;
                System.debug('newRFQ--->>>'+newRFQ);
            }
            
            if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__RFQ__c.isUpdateable()){
                selectedQuoteItem.buildertek__RFQ__c = newRFQ.Id;
                update selectedQuoteItem;
            }
            
            response.strMessage = 'RFQ created successfully.';
            response.strRecordId = newRFQ.Id;
            response.isSuccess = true;
            
        } catch (Exception ex){
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
    
    @AuraEnabled
    public static List<buildertek__File__c> getContentDocs1(Id arecordId,String rfqID) {
        
        buildertek__RFQ_To_Vendor__c vendorrec = 
            [Select Id, Name, buildertek__Vendor__c, buildertek__RFQ__c
             From buildertek__RFQ_To_Vendor__c
             where buildertek__Vendor__c =:arecordId
             And buildertek__RFQ__c =:rfqID];
        System.debug('arecordId'+arecordId);
        System.debug('vendorrec'+vendorrec);
        
        list<buildertek__File__c> fileslist =
            [SELECT Id, Name, buildertek__Amazon_File_Key__c,buildertek__Account__c, buildertek__Download_Link1__c, 
             buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
             buildertek__Download_Link__c, buildertek__Content_Type__c
             FROM buildertek__File__c 
             Where buildertek__RFQ_To_Vendor__c=:vendorrec.Id ];
        system.debug('fileslist'+fileslist.size());
        return fileslist;
    }
    
    @AuraEnabled
    public static AllFilesWrapper getContentDocs(Id arecordId,String rfqID) {
        AllFilesWrapper wrap = new AllFilesWrapper();
        
        
        buildertek__RFQ_To_Vendor__c vendorrec = 
            [Select Id, Name, buildertek__Vendor__c, buildertek__RFQ__c
             From buildertek__RFQ_To_Vendor__c
             where buildertek__Vendor__c =:arecordId
             And buildertek__RFQ__c =:rfqID];
        System.debug('arecordId'+arecordId);
        System.debug('vendorrec'+vendorrec);
        
        /*   list<buildertek__File__c> fileslist =
[SELECT Id, Name, buildertek__Amazon_File_Key__c,buildertek__Account__c, buildertek__Download_Link1__c, 
buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
buildertek__Download_Link__c, buildertek__Content_Type__c
FROM buildertek__File__c 
Where buildertek__RFQ_To_Vendor__c=:vendorrec.Id ];*/
        
        list<buildertek__File__c> fileslist =
            [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
             buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
             buildertek__Download_Link__c, buildertek__Content_Type__c , buildertek__ContentDocument_Id__c
             FROM buildertek__File__c Where buildertek__RFQ_To_Vendor__c=:arecordId ];
        system.debug('fileslist...........'+fileslist);
        
        list<Id> filecontentid= new list<Id>();        
        for(buildertek__File__c fileRec : fileslist){
            if(fileRec.buildertek__ContentDocument_Id__c != null ){
                filecontentid.add(fileRec.buildertek__ContentDocument_Id__c);
                system.debug('filecontentid................'+filecontentid);
            }
        }
        List<Attachment> attList = new List<Attachment>();
        for (Attachment att : [select Id, Name
                               FROM Attachment
                               where ParentId = :arecordId]){
                                   attList.add(att);
                               }
        system.debug('attList...'+attList);
        list<ContentDocumentLink> files = [select ContentDocumentId, LinkedEntityId
                                           FROM ContentDocumentLink
                                           where LinkedEntityId = :vendorrec.Id and ContentDocumentId NOT IN: filecontentid];
        system.debug('files..........'+files);
        list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
        system.debug('fileList'+fileList);
        List<ContentVersion> fileAttachments = new List<ContentVersion>();
        system.debug('fileAttachments...'+fileAttachments);
        for (ContentDocumentLink content : files){
            for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                        from ContentVersion
                                        where ContentDocumentId = :content.ContentDocumentId]){
                                            fileAttachments.add(docs);
                                        }
        }
        wrap.btfileslist = fileslist;
        wrap.standardfiles = fileAttachments; 
        
        
        return wrap;
    }
    
    
    public class AllFilesWrapper{
        @AuraEnabled 
        public  List<buildertek__File__c> btfileslist;
        @AuraEnabled 
        public list<ContentVersion> standardfiles; 
    } 
    
    
    
    public class RFQLineItemsClass{
        @AuraEnabled
        public buildertek__RFQ_Item__c rfqItem{ get; set; }
        
        @AuraEnabled
        public Boolean isProduct{ get; set; }
        
        @AuraEnabled
        public Integer rowIndex{ get; set; }
        
        public RFQLineItemsClass(buildertek__RFQ_Item__c rfqItem, Boolean isProduct, Integer rowIndex){
            this.rfqItem = rfqItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }
    
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String strRecordId;
        
    }
    
    public class MasterRFQItemsClass{
        @AuraEnabled
        public buildertek__RFQ_Item__c MasterRFQItem{ get; set; }
        
        @AuraEnabled
        public boolean SubmittalCheck{ get; set; }
    }
    
    public class BudgetDataTableWrapper{
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
        public List<buildertek__Budget__c> recordList{ get; set; }
    }
    
    
    @AuraEnabled
    public static Map<String,string> checkClosedRFIs(list<string> rfqtovendorids){
        
        
        System.debug('rfqtovendorids'+rfqtovendorids);
        map<string,string> resultmap = new map<string,string>();        
        
        map<string,integer> rfqvendorandrfiscountmap = new map<string,integer>();
        for (AggregateResult rec : [Select count(Id) Total, buildertek__RFQ_To_Vendor__c  
                                    from buildertek__RFI__c 
                                    Where buildertek__RFQ_To_Vendor__c In:rfqtovendorids 
                                    group by buildertek__RFQ_To_Vendor__c  ])  {            
                                        integer Count = integer.valueof(rec.get('Total'));
                                        string rfqvendor = string.valueof(rec.get('buildertek__RFQ_To_Vendor__c'));            
                                        rfqvendorandrfiscountmap.put(rfqvendor,Count);            
                                    }
        
        System.debug('rfqvendorandrfiscountmap'+rfqvendorandrfiscountmap);
        
        
        map<string,integer> rfqvendorandrfisclosedcountmap = new map<string,integer>();
        for (AggregateResult rec : [Select count(Id) Total, buildertek__RFQ_To_Vendor__c  
                                    from buildertek__RFI__c 
                                    Where buildertek__RFQ_To_Vendor__c In:rfqtovendorids 
                                    And buildertek__Status__c ='Closed'
                                    group by buildertek__RFQ_To_Vendor__c  ])  {            
                                        integer Count = integer.valueof(rec.get('Total'));
                                        string rfqvendor = string.valueof(rec.get('buildertek__RFQ_To_Vendor__c'));            
                                        rfqvendorandrfisclosedcountmap.put(rfqvendor,Count);            
                                    }
        System.debug('rfqvendorandrfisclosedcountmap'+rfqvendorandrfisclosedcountmap);
        
        
        for(string rfqtovendor : rfqtovendorids){
            integer totalrfiscount = 0;
            integer totalrfisclosedcount = 0;
            string status = '';
            if(rfqvendorandrfiscountmap.get(rfqtovendor)!=null){
                totalrfiscount = rfqvendorandrfiscountmap.get(rfqtovendor);
                totalrfisclosedcount = rfqvendorandrfisclosedcountmap.get(rfqtovendor);
                System.debug('totalrfiscount'+totalrfiscount);
                System.debug('totalrfisclosedcount'+totalrfisclosedcount);
                
                
                if(totalrfiscount>0 && totalrfiscount != totalrfisclosedcount){
                    status = 'RFIs Not Closed'; 
                } if(totalrfiscount>0 && totalrfiscount == totalrfisclosedcount){
                    status = 'RFIs Closed'; 
                }
                resultmap.put(rfqtovendor,status);                 
            }
            
        }
        
        return resultmap;
        
        
    }
    
    @AuraEnabled
    public static String uploadFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks  
        System.debug(' parentId  ++++++++++++++++++++++++++++++++++'+parentId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            system.debug('****'+fileId);
        } else {
            //   appendToFile(fileId, base64Data);
        }
        return string.valueOf(fileId);
    }
    public static Id saveTheFile(String parentId, String fileName, String base64Data, String contentType) { 
        system.debug('parentId--->'+parentId);
        /* base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
ContentVersion conVer = new ContentVersion();
Set<SObjectField> ContentVersionFields = new set<SObjectField>{ContentVersion.ContentLocation,
ContentVersion.PathOnClient,
ContentVersion.Title,
ContentVersion.VersionData};
conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
conVer.Title = fileName; // Display name of the files
conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
insert conVer;    //Insert ContentVersion
// First get the Content Document Id from ContentVersion Object
Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
//create ContentDocumentLink  record 
ContentDocumentLink conDocLink = New ContentDocumentLink();
Set<SObjectField> ContentDocumentLinkFields = new set<SObjectField>{ContentDocumentLink.LinkedEntityId,
ContentDocumentLink.ContentDocumentId,
ContentDocumentLink.shareType};
conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
conDocLink.shareType = 'I';
insert conDocLink;
system.debug('inserted--------------'+conDocLink.Id);
return conDocLink.Id;*/
        
        
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = parentId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        
        return contentToInsert.id;
        
        
        
        
        
    }
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        system.debug('saveTheChunk');
        system.debug('parentI'+parentId);
        system.debug('fileId'+fileId); 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFileNew(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFileNew(Id fileId, String base64Data) {
        system.debug('fileId'+fileId);
        system.debug('appendToFileNew');
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        /*Attachment a = [
SELECT Id, Body
FROM Attachment
WHERE Id = :fileId
];

String existingBody = EncodingUtil.base64Encode(a.Body);
a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 

update a;*/
        
        
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :fileId
        ];
        
        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update versionData;
        
        
        
    }
    
    
    
    
    @AuraEnabled
    public static boolean checkStatus(list<string> rfqtovendorids){ 
        boolean isQuoteSubmitted = true;
        List<buildertek__RFQ_To_Vendor__c> vendorRFQList = [SELECT Id,
                                                            Name,
                                                            buildertek__Status__c
                                                            FROM buildertek__RFQ_To_Vendor__c
                                                            WHERE Id IN:rfqtovendorids];
        if(!vendorRFQList.isEmpty()){
            for(buildertek__RFQ_To_Vendor__c vr:vendorRFQList){
                if(vr.buildertek__Status__c != 'Quote Submitted'){
                    isQuoteSubmitted = false;
                    break;
                }
            }
        }
        /*if(vendorRFQList[0].buildertek__Status__c == 'Quote Submitted'){
isQuoteSubmitted = true;
}*/
        return isQuoteSubmitted;
    }  
    
    
    @AuraEnabled
    public static ContactDataTableWrapper getContactData(Integer pageNumber, Integer pageSize , string recordId, String vendorRFQId) {
        /* public static list<buildertek__RFQ_To_Vendor__c> getContactData(Integer pageNumber, Integer pageSize , list<string> recordId) {

List< buildertek__RFQ_To_Vendor__c> vendor = [SELECT Id, buildertek__RFQ__c, buildertek__Contact__c,  buildertek__Vendor__c, Name FROM buildertek__RFQ_To_Vendor__c Where ID IN:recordId]; 
return vendor;
}*/
        
        buildertek__RFQ_To_Vendor__c vendorRFQ = [select Id, Name, buildertek__Contact__c from buildertek__RFQ_To_Vendor__c where Id =: vendorRFQId];
        
        //Offset for SOQL
        boolean checkbox = true;
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM Contact];
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        ContactDataTableWrapper objDT =  new ContactDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        // objDT.checkbox = false;
        objDT.contactList = [SELECT Id, Name, Phone, Email, buildertek__Primary_Contact__c FROM Contact Where AccountId =: recordId AND Id  !=: vendorRFQ.buildertek__Contact__c ORDER BY Name LIMIT :pageSize OFFSET :offset];
        return objDT;
        
    }
    
    //Wrapper Class For Contact DataTable  
    public class ContactDataTableWrapper {
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
        // @AuraEnabled
        // public boolean checkbox {get;set;}
        @AuraEnabled
        public List<Contact> contactList {get;set;}
    }
    
    
    @AuraEnabled
    public static list<buildertek__BT_Vendor_RFQ_Contacts__c> saverfqvendorcontacts(list<string> recordid, string accrecordId ){
        List<buildertek__BT_Vendor_RFQ_Contacts__c> rfqcontactlist = [SELECT Id, buildertek__Contact__c,buildertek__Contact__r.buildertek__Primary_Contact__c, buildertek__Account__c,buildertek__Vendor_RFQ__c FROM buildertek__BT_Vendor_RFQ_Contacts__c Where buildertek__Vendor_RFQ__c IN:recordid];      
        return rfqcontactlist;
        
    }  
    
    
    
    
    
    
    
    @AuraEnabled
    public static list<buildertek__BT_Vendor_RFQ_Contacts__c> savecontacts(list<string> contractId, string recordId ){
        system.debug( 'contractId......'+contractId);
        system.debug( 'recordId......'+recordId);
        List<buildertek__BT_Vendor_RFQ_Contacts__c> rfqcontactlists = [SELECT Id, buildertek__Contact__c,buildertek__Account__c,buildertek__Vendor_RFQ__c FROM buildertek__BT_Vendor_RFQ_Contacts__c Where buildertek__Vendor_RFQ__c =:recordId]; 
        system.debug('rfqcontactlists..........'+rfqcontactlists);
        delete rfqcontactlists;
        List<buildertek__BT_Vendor_RFQ_Contacts__c> rfqcontactlist = new  List<buildertek__BT_Vendor_RFQ_Contacts__c>();
        List< Contact> contactlists = [SELECT Id, Name, Phone,AccountId, Email FROM Contact Where ID IN:contractId];
        system.debug(contactlists);
        for (Contact con : contactlists){
            buildertek__BT_Vendor_RFQ_Contacts__c vendorrfqitem = new buildertek__BT_Vendor_RFQ_Contacts__c();
            vendorrfqitem.buildertek__Account__c = con.AccountId ;
            vendorrfqitem.buildertek__Contact__c = con.id;
            vendorrfqitem.buildertek__Vendor_RFQ__c = recordId;
            rfqcontactlist.add(vendorrfqitem);
            system.debug('rfqcontactlist......'+rfqcontactlist);
        }
        if (rfqcontactlist.size() > 0){
            system.debug(rfqcontactlist);
            insert rfqcontactlist;
        }
        return rfqcontactlist;
    }  
    
    
    @AuraEnabled
    public static Boolean getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Only_RFQ_Portal_Users__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'RFQ Configuration'];
        Boolean islien = false;
        if(adminInterfaceNodeConfigurations.buildertek__Only_RFQ_Portal_Users__c == true){
            islien = true;
        }
        return islien;
    }
    
    
    @AuraEnabled
    public static innerclass checkProtalUsers(string recordId, List<string> selectedVendors){
        
        innerclass inn = new innerclass();
        
        
        list<Id> contactids= new list<Id>();
        List<buildertek__RFQ_To_Vendor__c> rfqVendorListforaccount;
        rfqVendorListforaccount = [select Id, buildertek__Contact__c, buildertek__Contact__r.Name 
                                   from buildertek__RFQ_To_Vendor__c
                                   where Id IN :selectedVendors];
        
        list<Id> rfqvendorIds = new list<Id>();
        
        
        list<buildertek__BT_Vendor_RFQ_Contacts__c> btrfqVendorContacts;
        
        btrfqVendorContacts = [select Id, buildertek__Contact__c, buildertek__Vendor_RFQ__c from buildertek__BT_Vendor_RFQ_Contacts__c where buildertek__Vendor_RFQ__c IN: selectedVendors];
        
        system.debug('btrfqVendorContacts---->'+btrfqVendorContacts);
        
        for(buildertek__BT_Vendor_RFQ_Contacts__c venroRec1 : btrfqVendorContacts){
            contactids.add(venroRec1.buildertek__Contact__c);
        }
        
        
        for(buildertek__RFQ_To_Vendor__c venroRec : rfqVendorListforaccount){
            contactids.add(venroRec.buildertek__Contact__c);
        }
        
        system.debug('contactids---->'+contactids);
        
        List<String> nonProtalContacts = new List<String>();
        
                map<Id,User> vendorUserMap1 = new map<Id,User>();
        
        List<User> lUsers = [SELECT Id,Contact.Id,Name,IsActive, ContactId  FROM User WHERE  ContactId IN :contactids];
        
        system.debug('lUsers------------------->'+lUsers);
        
        
        list<Contact> contactlist = [Select id,Name,Email,AccountId from Contact where Id IN: contactids];
        
        
        for(User usr: lUsers){
            vendorUserMap1.put(usr.ContactId,usr);
        }
        
        for(Contact con : contactlist){
            if(vendorUserMap1.get(con.Id)!= null){
                system.debug('con.Id------>'+con.Id);
                system.debug('vendorUserMap1.get(con.Id)--->'+vendorUserMap1.get(con.Id));
            }else{
              system.debug('con.Idelse------>'+con.Id)  ;
                  nonProtalContacts.add(con.Id);
                
            }
        }
        
        
   /*    if(!contactids .isEmpty()){
            for(String cn : contactids){
                for(User us : lUsers){
                  system.debug('cn---------->'+cn);
                    system.debug('us.ContactId---------->'+us.ContactId);
                     if(cn != us.ContactId){
                        nonProtalContacts.add(cn); 
                    }else{
                        
                    }
                }
                   
                }
               
            }*/
        
        
        system.debug('lUsers---->'+lUsers);
        system.debug('nonProtalContacts---->'+nonProtalContacts);
        
    /*    if(!lUsers .isEmpty()){
            for(String cn : contactids){
                for(User us : lUsers){
                    if(cn != us.ContactId){
                        nonProtalContacts.add(cn);
                    }
                }
            }
        }else{
            
            for(String cn : contactids){
                nonProtalContacts.add(cn);
            } 
            
        }*/
        
        
        
        system.debug('nonProtalContacts------->'+nonProtalContacts);
        
        inn.isportal = false;
        if(!nonProtalContacts.isEmpty()){
            List<Contact> NonPortConList = [select Id, Name, Email from Contact where Id IN:nonProtalContacts];
            inn.ConList = NonPortConList;
              system.debug('NonPortConList-'+NonPortConList);
        }else{
           inn.isportal = true ;
        }
        
      
        
        system.debug('contactids.size()---->'+contactids.size());
        system.debug('lUsers.size()---->'+lUsers.size());
      /*  inn.isportal = false;
        if(contactids.size() == lUsers.size()){
            system.debug('contactids.size()---->'+contactids.size());
            system.debug('lUsers.size()--------->'+lUsers.size());
            inn.isportal = true;
        }*/
        
        return inn;
    }
    
    
    public class innerclass{
        @AuraEnabled
        public Boolean isportal;
        @AuraEnabled
        public List<Contact>  ConList;
        
    }

    @AuraEnabled
    public static string saveRFQs(List<buildertek__RFQ__c> selectedRFQS, Id quoteId){
        System.debug('selectedRFQS'+selectedRFQS);
        System.debug('quoteId'+quoteId);
        for(buildertek__RFQ__c rfq : selectedRFQS){
            rfq.buildertek__Added_to_Quote__c = quoteId;
        }
        update selectedRFQS;
        return 'success';

    }
    
}