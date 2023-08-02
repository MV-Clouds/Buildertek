@isTest
public with sharing class RFQVendorItemControllerTest {
    @TestSetup
    static void RFQVendorItem() {

        Id pId = [select id from profile where name='Partner Community User'].id;
    
        Account acc = new Account() ;
        acc.name = 'Grazitti';
        insert acc; 
    
        Contact cont = new Contact();
        cont.LastName = 'testCon'; 
        cont.AccountId = acc.Id;
        insert cont;  
                
        User user = new User();
        user.alias = 'test123';
        user.email = 'test123@noemail.com';
        user.emailencodingkey = 'UTF-8';
        user.lastname = 'Testing';
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'en_US';
        user.profileid = pId;
        user.country = 'United States';
        user.IsActive = true;
        user.ContactId = cont.Id;
        user.timezonesidkey = 'America/Los_Angeles';
        user.username = 'tester@noemail.com';
        insert user;
        
        // User user = [select ContactId,AccountId from User where id = :userInfo.getUserId()];
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        Account ac=new Account();
        ac.Name='Testing Account';
        insert ac;

		List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], ac);
		List<File__c> files = BT_TestUtils.createFiles(folders[0], ac);
    
        buildertek__RFQ__c rfq=new buildertek__RFQ__c();
        rfq.Name='rfq test';
        insert rfq;
        
        Contact con=new Contact();
        con.LastName='Test con';
        insert con;
        
        buildertek__RFQ_To_Vendor__c rf=new buildertek__RFQ_To_Vendor__c();
        rf.Name='rfq test';
        rf.buildertek__Contact__c=con.Id;
        rf.buildertek__RFQ__c=rfq.id;
        insert rf;
        
        buildertek__RFQ_Vendor_Item__c v=new buildertek__RFQ_Vendor_Item__c();
        v.Name='Test';
        v.buildertek__Vendor__c=rf.Id;
        insert v;
        
        buildertek__VendorRfqList__c lt=new buildertek__VendorRfqList__c();
        lt.Name='Test';
        // lt.buildertek__RFQUser__c=user.id;
        insert lt;        
        lt.buildertek__RFQListName__c='ltnm';
       	update lt;
        
        List<buildertek__Admin_Interface_Node_Configuration__c> nodeList = new List<buildertek__Admin_Interface_Node_Configuration__c>();
        
        buildertek__Admin_Interface_Node_Configuration__c ad=new buildertek__Admin_Interface_Node_Configuration__c();
        ad.Name='test admin';
        nodeList.add(ad);
        // insert ad;

        buildertek__Admin_Interface_Node_Configuration__c node =new buildertek__Admin_Interface_Node_Configuration__c();
        node.Name='RFQ Configuration';
        // insert ad;
        nodeList.add(node);

        insert nodeList;

        
        
    }
    @isTest
    static void RFQVendorItem2(){
        
        buildertek__RFQ__c r=new buildertek__RFQ__c();
        r=[select id,Name from buildertek__RFQ__c LIMIT 1];
        
        buildertek__RFQ_To_Vendor__c rf=new buildertek__RFQ_To_Vendor__c();
        rf=[Select id,Name,buildertek__RFQ__c,buildertek__Contact__c from buildertek__RFQ_To_Vendor__c LIMIT 1];
        String s=rf.buildertek__RFQ__c;
        system.debug('rfq__c---------------------->'+rf.buildertek__RFQ__c);
        System.debug('******51*****'+rf);
       
        List<buildertek__RFQ_Vendor_Item__c> vl=new List<buildertek__RFQ_Vendor_Item__c>();
        buildertek__RFQ_Vendor_Item__c v=new buildertek__RFQ_Vendor_Item__c();
		v=[select id,Name,buildertek__Vendor__c from buildertek__RFQ_Vendor_Item__c LIMIt 1];
        vl.add(v);      
        
        buildertek__VendorRfqList__c lt=new buildertek__VendorRfqList__c();
        lt=[select Id, Name, buildertek__RFQUser__c from buildertek__VendorRfqList__c ];  
        
        buildertek__File__c fl=new buildertek__File__c(name='test', buildertek__RFQ__c = r.Id, buildertek__RFQ_To_Vendor__c = rf.Id); 
        insert fl;
        
        ListView lv=new ListView();
        lv=[SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LastViewedDate, LastReferencedDate FROM ListView LIMIT 1];
        
        RFQVendorItemController.DeleteVendorItems(v.Id);
        RFQVendorItemController.getRQToAccount(rf.Id);
        RFQVendorItemController.updateVendorItems(vl);
        RFQVendorItemController.getContentDocs(fl.id);
        RFQVendorItemController.getvendorContentfiles(fl.id);  
        RFQVendorItemController.getobjectName(rf.id); 
        RFQVendorItemController.getrfq(rf.id);
         
        RFQVendorItemController.fetchListViews(lv.id); 
        RFQVendorItemController.customsettings();        
        RFQVendorItemController.updatecustomsettings(lt.id,'demo');
        RFQVendorItemController.getRfqTo();
        RFQVendorItemController.getmulticurrency();
        RFQVendorItemController.currentUserDetailMethod();  
        RFQVendorItemController.getRelatedList(r.Id);      
        
        
        RFQVendorItemController.uploadFile(rf.Id,'abc','abcd','hello','');

        RFQVendorItemController.getContentfiles(rf.Id);
        RFQVendorItemController.getrfqfiles(rf.id);
        RFQVendorItemController.getListViewQuery(rf.id, 'buildertek__RFQ_To_Vendor__c');

        user usr = [SELECT Id, FirstName, LastName, Username, Email, ContactId, AccountId FROM User WHERE email =: 'test123@noemail.com'];
        System.runAs(usr) {
            
            RFQVendorItemController.getvendorRelatedList(rf.Id);
            RFQVendorItemController.findByName('a',rf.id,'All');
            RFQVendorItemController.findByName('a',rf.id,'non'); 
            RFQVendorItemController.getListViewQuery(rf.id, 'buildertek__RFQ_To_Vendor__c');
        }

        
        // buildertek__File__c fl1=[select id,Name,buildertek__RFQ_To_Vendor__c,buildertek__RFQ__c,buildertek__ContentDocument_Id__c from buildertek__File__c where buildertek__RFQ__c =: rf.buildertek__RFQ__c];
        // insert fl1;

    //    buildertek__File__c fl1=[select id,Name,buildertek__RFQ__c,buildertek__ContentDocument_Id__c from buildertek__File__c where buildertek__RFQ__c =: rf.buildertek__RFQ__c];
    //     insert fl1;
        
    //     List<Attachment> attList = [select Id,Name from Attachment where ParentId =: rf.buildertek__RFQ__c];        
        
    //     Account ac=new Account();
    //     ac=[select id,Name from Account];     
        
       // RFQVendorItemController.getContentfiles(contentVersion.id);         
        // RFQVendorItemController.getrfqfiles(fl1.id);
             
    }
}