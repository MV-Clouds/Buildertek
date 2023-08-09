trigger VenderRFQTrigger on buildertek__RFQ_To_Vendor__c (after insert, after update) {

    if(Trigger.isInsert){
        List<ContactShare> contactshareList=new List<ContactShare>();
        set<Id> vendorIds = new set<Id>();
        map<Id,User> vendorUserMap = new map<Id,User>();
        for(buildertek__RFQ_To_Vendor__c rfqVendor:Trigger.new) {
            if(rfqVendor.buildertek__Vendor__c!=null){
                vendorIds.add(rfqVendor.buildertek__Vendor__c);
            }
        }
        List<ContactShare> accountShareList = new List<ContactShare>();
        list<Contact> acclist = [select id,Name,AccountId from Contact Where AccountId IN: vendorIds];
        string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+'FROM User Where isPortalEnabled=true';
        list<User> usersList = Database.query(strQry);
        /*if(usersList.size() > 0){
            for(User usr: usersList){
                vendorUserMap.put(usr.AccountId,usr);
            }
        }*/

        for(Contact accRec: acclist) {
        for(User usrrec : usersList){
            // User usrrec = vendorUserMap.get(accRec.AccountId);
            ContactShare accountRecord = new ContactShare();
            accountRecord.ContactId = accRec.Id;
            accountRecord.UserOrGroupId = usrrec.Id;
            accountRecord.ContactAccessLevel = 'Read';
            accountRecord.RowCause = Schema.ContactShare.RowCause.Manual;
            accountShareList.add(accountRecord); 
            system.debug('accountShareList'+accountShareList.size()); 
            system.debug('contacts'+accountShareList);  
            contactshareList.add(accountRecord); 
        }
        }
        if(accountShareList.size()>0){
            Database.SaveResult[] accountShareInsertResult = Database.insert(accountShareList,false);   
        }
        System.debug('accList is here ==> '+accList);
        System.debug('userList is here ==> '+usersList);
        System.debug('shared record list ==> '+contactshareList);
        for(ContactShare con : contactshareList){
            system.debug('con ==> ' + con);
        }
    }

    if (Trigger.isUpdate) {
        List<buildertek__RFQ__Share> rfqShareList  = new List<buildertek__RFQ__Share>();
        Set<Id> accList = new Set<Id>();
        for (buildertek__RFQ_To_Vendor__c rfqVendor : Trigger.new) {
            if (rfqVendor.buildertek__Status__c == 'Awarded') {
                accList.add(rfqVendor.buildertek__Vendor__c);
            } 
        }
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE AccountId IN: accList];
        Set<Id> conIdList = new Set<Id>();
        for (Contact con : conList) {
            conIdList.add(con.Id);
        }
        List<User> userList = [SELECT Id, Name FROM User WHERE ContactId IN: conIdList];
        for (buildertek__RFQ_To_Vendor__c rfqVendor : Trigger.new) {
            if (rfqVendor.buildertek__Status__c == 'Awarded') {
                for (User usr : userList) {
                    buildertek__RFQ__Share rfqShare  = new buildertek__RFQ__Share();
                    rfqShare.ParentId = rfqVendor.buildertek__RFQ__c;
                    rfqShare.UserOrGroupId = usr.Id;
                    rfqShare.AccessLevel = 'Edit';
                    rfqShareList.add(rfqShare);
                }
            } 
        }
        insert rfqShareList;
    }
     
  
}