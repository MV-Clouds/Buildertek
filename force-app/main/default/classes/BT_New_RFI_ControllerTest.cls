@isTest
public class BT_New_RFI_ControllerTest {
static testMethod void test(){
    List<buildertek__RFI_Settings__c> customsettingsList=new List<buildertek__RFI_Settings__c>();
    buildertek__RFI_Settings__c customsettings = new buildertek__RFI_Settings__c(buildertek__Using_Email__c = true,
                                                                                 buildertek__Using_Communities__c = true,
                                                                                 Name = 'test1',
                                                                                 buildertek__New_RFI_Notification_Template__c = 'New RFI notification');
    insert customsettings;
   
    
    buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
    RFIsetting.Name='RFI Settings';
    RFIsetting.buildertek__Using_Communities__c = true;
    RFIsetting.buildertek__Using_Email__c = true;
    RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
    insert RFIsetting;
    customsettingsList.add(RFIsetting);
    customsettingsList.add(customsettings);    
    Profile prof = new Profile();
    prof.Name = 'johny';
    //insert prof;
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    list<User> u = new list<User>();
    User usr = new User();
    usr.Username = 'hulk@asf.com';
    usr.Alias = 'john';
    usr.Email = 'mani@gmail.com';
    usr.LastName = 'mani';
    usr.LocaleSidKey = 'en_US';
    usr.TimeZoneSidKey = 'America/Los_Angeles';
    usr.EmailEncodingKey = 'ISO-8859-1';
    usr.LanguageLocaleKey = 'en_US';
    usr.ProfileId = profileId.id;
    u.add(usr);
    insert u;
    
     //List<String> selectedId = new List<String>();
       //selectedId.add(u[0].Id);
    
    
    List<Contact> cont = new List<Contact>();
    Contact con = new Contact();
    con.Email = 'test@gmail.com';
    con.LastName = 'test4';
    cont.add(con);
    insert cont;
    
   // List<String> selectedIds = new List<String>();
       //selectedIds.add(cont[0].Id);
       
         
    
    list<buildertek__Project__c> prorec = new list<buildertek__Project__c>();
     buildertek__Project__c pro = new buildertek__Project__c();
    pro.Name = 'test6';
    prorec.add(pro);
    insert prorec;
    
    buildertek__RFI__c rfi = new buildertek__RFI__c();
    rfi.buildertek__Assigned_To__c = cont[0].id;
    rfi.buildertek__Subject__c = 'hai';
    rfi.buildertek__Due_Date__c = Date.Today();
    rfi.buildertek__RFI_Reassigned_To__c = u[0].id;
    rfi.buildertek__Submitted_By2__c = cont[0].id;
    rfi.buildertek__Submitted_By__c = u[0].id;
   //rfi.buildertek__Users_Contacts__c  = usercon.id;
    rfi.buildertek__Type__c = 'Construction';
    rfi.buildertek__Question__c = 'xyz';
    rfi.buildertek__Project__c = prorec[0].id;
    rfi.buildertek__Status__c = 'RFI Sent';
    insert rfi;
    
    
    buildertek__Users_Contacts__c usercon = new buildertek__Users_Contacts__c();
    usercon.buildertek__RFI__c = rfi.id;
    usercon.buildertek__Contact__c=cont[0].id;
    usercon.buildertek__User__c=u[0].id;
    insert usercon;
    
    buildertek__RFI_Response__c rfiresponse = new buildertek__RFI_Response__c();
    rfiresponse.buildertek__Response__c = 'test5';
    rfiresponse.buildertek__RFI__c = rfi.id;
    rfiresponse.buildertek__Response_From_CMP__c = true;
    //rfiresponse.Name = 'test6';
    insert rfiresponse;
    
    buildertek__RFQ__c rfq = new buildertek__RFQ__c();
    rfq.buildertek__Project__c = pro.id;
    rfq.Name = 'test8';
    insert rfq;
    
    buildertek__RFQ_To_Vendor__c RFVendor = new buildertek__RFQ_To_Vendor__c();
    RFVendor.Name = 'Testr';
    RFVendor.buildertek__Accepted_Date__c = system.today();
    RFVendor.buildertek__isCommunityUser__c = true;
    RFVendor.buildertek__Notes__c = 'test';
    RFVendor.buildertek__RFQ__c = rfq.Id;
    //insert RFVendor;
  
   // return prorec;
     Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
   ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = rfi.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
    
    
    
    //List<String> selectedIds = new List<String>();
       // selectedIds.add(quoteList[0].Id);
    
    BT_New_RFI_Controller.fetchUser();
    BT_New_RFI_Controller.getcontact();
    BT_New_RFI_Controller.getproject(rfq.id);
    BT_New_RFI_Controller.getRFISettings();
    //BT_New_RFI_Controller.updaterfirec(rfi.id);
    BT_New_RFI_Controller.getUser();
    BT_New_RFI_Controller.getrfiresponselist(rfi.id);
    BT_New_RFI_Controller.getrfiresponselists(rfi.id);
    BT_New_RFI_Controller.getContentDocs(rfi.Id);
    BT_New_RFI_Controller.getrfiresponserelatedfiles(rfiresponse.id);
    BT_New_RFI_Controller.getrfirelatedfilesrecords(rfiresponse.id);
    BT_New_RFI_Controller.getFieldSet();
   // BT_New_RFI_Controller.sendProposalforVendor(rfi.Id);
    BT_New_RFI_Controller.getRecContacts(rfi.Id);
     BT_New_RFI_Controller.getRecUsers(rfi.Id);
    BT_New_RFI_Controller.getrfiresponeserecords(rfi.Id);
    BT_New_RFI_Controller.getrfiRecord(rfi.Id);
    BT_New_RFI_Controller.getrfirecords(rfi.Id);
    //BT_New_RFI_Controller.updateRFQ(rfiresponse.id, u, cont);
     BT_New_RFI_Controller.saveNewRFI(rfi.Id,u[0].id,'test',pro.id,'test','18-12-2021',cont[0].id,cont[0].id);
    BT_New_RFI_Controller.saveTheFile(rfi.Id, 'test','test','test');
   // BT_New_RFI_Controller.uploadFile(rfi.Id, 'test','test','test','test');
    BT_New_RFI_Controller.getDropDown('Opportunity','StageName');
    BT_New_RFI_Controller.rfiresgetrfiFieldSet('Opportunity','StageName',rfi.Id);
    
    BT_New_RFI_Controller.getContentDocs1(rfiresponse.Id);
    BT_New_RFI_Controller.fetchUser1();
    BT_New_RFI_Controller.getrfirelatedfilesrecordsOld(rfi.Id);
    //BT_New_RFI_Controller.getrfqtovenrfirelatedfilesrecords(RFVendor.Id);
    //BT_New_RFI_Controller.updateRFQ1(rfiresponse.Id);
    //BT_New_RFI_Controller.updateRFQ2(rfiresponse.Id);
    //BT_New_RFI_Controller.updaterfirec(rfiresponse.Id);
    
    
}
    
}