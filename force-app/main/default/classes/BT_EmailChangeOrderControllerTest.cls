@isTest
private  class BT_EmailChangeOrderControllerTest {
  

@isTest static void testmethod1(){
   

   


    Account acc = new Account();
    acc.Name='test';
    insert acc;

    Contact con = new Contact();
    con.LastName='test';
    con.FirstName='testmthod';
    con.Email='test@test.com';
    con.AccountId=acc.Id;

    Contact con2 = new Contact();
    con2.LastName='test2';
    con2.Email='test2@gmail.com';
    con2.AccountId=acc.Id;


    

    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User u = new User(Alias = 'sttst2', Email='cyril@maverickrealty.ae', 
                      EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = p.Id, MobilePhone = '+91 9326582649', Phone = '+919326582649',
                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@tesorg.com', ManagerId = UserInfo.getUserId());
    Insert u;
        System.RunAs(u){
        EmailTemplate e = new EmailTemplate ();
        e.isActive = true; 
        e.developerName = 'test';
        e.FolderId = UserInfo.getUserId(); 
        e.TemplateType= 'Text'; 
        e.Name = 'test'; 
        insert e;

        EmailTemplate e2 = new EmailTemplate ();
        e2.developerName = 'test2';
        e2.FolderId = UserInfo.getUserId(); 
        e2.TemplateType= 'Text'; 
        e2.Name = 'test'; 
        insert e2;
        

        insert con;
        insert con2;
      


        // insert acc;

        buildertek__RFI__c RFI = new buildertek__RFI__c();
        RFI.buildertek__Subject__c='Test';
        RFI.buildertek__Assigned_To__c=con.Id;
        RFI.buildertek__Due_Date__c=Date.Today();
        insert RFI;

        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=RFI.id;
        insert attach;

        Attachment attach2=new Attachment();       
        attach2.Name='Unit Test Attachment';
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach2.body=bodyBlob2;
        attach2.parentId=RFI.id;
    
        insert attach2;
    
        String folderName = e.Name;

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
    insert contentVersion;

    ContentVersion contentVersion2 = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
insert contentVersion2;


        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = RFI.Id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
            co.name='test';
            insert co;
            

            
        List<String> to = new List<String>();
        to.add(con.Id);
        to.add(con2.Id);


        List<String> cc = new List<String>();
        cc.add(con.Id);

        List<String> files = new List<String>();
        files.add(contentVersion.Id);
        files.add(contentVersion2.Id);
        files.add(attach.Id);
        files.add(attach2.Id);

        


        String subject='Test';

        String body='Test Body ';

        String pdfFileName='Test pdf name';

        List<String> recordId = new List<String>();
        recordId.add(con.Id);
        recordId.add(con2.Id);

        // List<String> templateId = new List<String>();
        // templateId.add(e.Id);
        // templateId.add(e2.Id);

        List<String> emailIds = new List<String>();
        emailIds.add('test@gmail.com');
        emailIds.add('test2@gmail.com');
        emailIds.add('test3@gmail.com');


        List<String> Ids = new List<String>();
        Ids.add(con.Id);
        Ids.add(con2.Id);


       
 
    buildertek__Submittal__c submittal1 = new buildertek__Submittal__c(); 
    submittal1.buildertek__Responsible_Contact__c=con.Id;
    submittal1.buildertek__Responsible_Vendor__c=acc.Id;
    insert submittal1;


    EmailMessage caseEmailMessage = new EmailMessage();
    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
    caseEmailMessage.ToAddress = 'test@gmail.com';
    caseEmailMessage.FromName = UserInfo.getUserName();
    caseEmailMessage.Subject = 'test';
    caseEmailMessage.HtmlBody = 'html test body';
    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
    caseEmailMessage.MessageDate = system.now();
    caseEmailMessage.status = '5';
    caseEmailMessage.buildertek__Subject__c = 'Re: ' + 'test';
    insert  caseEmailMessage;








    


        Test.startTest();

        // FileTriggerHandler.isSkipTrigger=true;
        // List<File__c> flList = new  List<File__c>();
    
        // buildertek__File__c fileItem = new buildertek__File__c();
        // fileItem.Name = 'Test Material';
        // fileItem.buildertek__Bucket_Name__c='btdocs';
        // fileItem.buildertek__Amazon_File_Key__c='PaymentApp(30).xls';
        // fileItem.buildertek__File_Presigned_URL__c='https://s3.amazonaws.com/btdocs/PaymentApp%2830%29.xls';
        // flList.add(fileItem);
    
        // buildertek__File__c fileItem2 = new buildertek__File__c();
        // fileItem2.Name = 'Test Material';
        // fileItem2.buildertek__Bucket_Name__c='btdocs';
        // fileItem2.buildertek__Amazon_File_Key__c='image004(1).png';
        // fileItem2.buildertek__File_Presigned_URL__c='https://s3.amazonaws.com/btdocs/image004%281%29.png';
        // flList.add(fileItem2);
        // insert flList;
    
    
        // // List<String> files = new List<String>();
        // files.add(flList[0].Id);
        // files.add(flList[1].Id);

        BT_EmailChangeOrderController.getObjectContact(submittal1.Id , 'buildertek__Submittal__c');

        BT_EmailChangeOrderController.getTemplates(folderName);
        BT_EmailChangeOrderController.getbodyTemplates(folderName);
        BT_EmailChangeOrderController.gettemplatebodyContent(acc.Id , e.Id );
        BT_EmailChangeOrderController.getFileAttachments(RFI.Id);
        BT_EmailChangeOrderController.getsubject(co.Id , 'buildertek__Change_Order__c');
        BT_EmailChangeOrderController.SendEmail(to, cc ,files,subject ,  body,recordId, e.Id, pdfFileName,emailIds,Ids);
        BT_EmailChangeOrderController.uploadFile(RFI.Id, 'Test' , 'Test data' , 'Test content type' , '');
        




        Test.stopTest();
    }
}
@isTest static void testmethod2(){
    Contact con = new Contact();
    con.LastName='test';
    con.Email='test@test.com';
    insert con;

    buildertek__RFI__c RFI = new buildertek__RFI__c();
    RFI.buildertek__Subject__c='Test';
    RFI.buildertek__Assigned_To__c=con.Id;
    RFI.buildertek__Due_Date__c=Date.Today();
    insert RFI;

    Opportunity Opp = new Opportunity(); 
        Opp.Name = 'Test Opportunity';
        Opp.CloseDate = system.today().addDays(30);
        Opp.StageName = 'Prospecting';
        insert Opp;
     
    
    buildertek__Quote__c quote = new buildertek__Quote__c();
    quote.Name = 'Test Quote';
    quote.buildertek__Opportunity__c = Opp.Id;
    quote.buildertek__Status__c = 'Customer Accepted'; 
    insert quote;


    Test.startTest();

    BT_EmailChangeOrderController.getObjectContact(RFI.Id , 'buildertek__RFI__c' );
    BT_EmailChangeOrderController.getsubject(quote.Id , 'buildertek__Quote__c');


    Test.stopTest();


}

@isTest static void testmethod3(){
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User u = new User(Alias = 'sttst2', Email='cyril@maverickrealty.ae', 
                      EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = p.Id, MobilePhone = '+91 9326582649', Phone = '+919326582649',
                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@tesorg.com', ManagerId = UserInfo.getUserId());
    Insert u;
        System.RunAs(u){
    Account acc = new Account();
    acc.Name='test';
    insert acc;

    Contact con = new Contact();
    con.LastName='test';
    con.FirstName='testmthod';
    con.Email='test@test.com';
    con.AccountId=acc.Id;
    insert con;

    Contact con2 = new Contact();
    con2.LastName='test2';
    con2.Email='test2@gmail.com';
    con2.AccountId=acc.Id;
    insert con2;

    EmailTemplate e = new EmailTemplate ();
    e.isActive = true; 
    e.developerName = 'test';
    e.FolderId = UserInfo.getUserId(); 
    e.TemplateType= 'Text'; 
    e.Name = 'test'; 
    insert e;


    buildertek__RFI__c RFI = new buildertek__RFI__c();
    RFI.buildertek__Subject__c='Test';
    RFI.buildertek__Assigned_To__c=con.Id;
    RFI.buildertek__Due_Date__c=Date.Today();
    insert RFI;

    Attachment attach=new Attachment();       
    attach.Name='Unit Test Attachment';
    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    attach.body=bodyBlob;
    attach.parentId=RFI.id;

    insert attach;

    Attachment attach2=new Attachment();       
    attach2.Name='Unit Test Attachment';
    Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
    attach2.body=bodyBlob2;
    attach2.parentId=RFI.id;

    insert attach2;




    ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
insert contentVersion;

ContentVersion contentVersion2 = new ContentVersion(
    Title          = 'a picture',
    PathOnClient   = 'Pic.jpg',
    VersionData    = Blob.valueOf('Test Content'),
    IsMajorVersion = true);
insert contentVersion2;


    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = RFI.Id;
    cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;



  
    
    buildertek__Contract__c cont = new buildertek__Contract__c();
    cont.Name = 'Test Contract';
    insert cont;

    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
    adminInterfaceNodeConfigurations.Name = 'Change Order Configuration';
    adminInterfaceNodeConfigurations.buildertek__Quote_Configuration__c = false;
    adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = 'Test emial subject';
    insert adminInterfaceNodeConfigurations;



    List<String> to = new List<String>();
    to.add(con.Id);
    to.add(con2.Id);


    List<String> cc = new List<String>();
    cc.add(con.Id);
    // cc.add(con2.Id);

    String subject='Test';

    String body='Test Body ';

    String pdfFileName='Test pdf name';

    List<String> recordId = new List<String>();
    recordId.add(con.Id);
    recordId.add(con2.Id);

    List<String> emailIds = new List<String>();
    emailIds.add('test@gmail.com');


    List<String> Ids = new List<String>();
    Ids.add(con.Id);
    Ids.add(con2.Id);


   
  

    



    Test.startTest();

    FileTriggerHandler.isSkipTrigger=true;
    List<File__c> flList = new  List<File__c>();

    buildertek__File__c fileItem = new buildertek__File__c();
    fileItem.Name = 'Test Material';
    fileItem.buildertek__Bucket_Name__c='btdocs';
    fileItem.buildertek__Amazon_File_Key__c='PaymentApp(30)';
    fileItem.buildertek__File_Presigned_URL__c='https://s3.amazonaws.com/btdocs/PaymentApp%2830%29.xls';
    flList.add(fileItem);

    buildertek__File__c fileItem2 = new buildertek__File__c();
    fileItem2.Name = 'Test Material';
    fileItem2.buildertek__Bucket_Name__c='btdocs';
    fileItem2.buildertek__Amazon_File_Key__c='image004(1)';
    fileItem2.buildertek__File_Presigned_URL__c='https://s3.amazonaws.com/btdocs/image004%281%29.png';
    flList.add(fileItem2);
    insert flList;
    
    Amazon_S3_Key__c key = new Amazon_S3_Key__c();
    key.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key.buildertek__Label__c='AWS Access Key Id';
    key.Name='AWS Public Key';

    insert key;

    Amazon_S3_Key__c key2 = new Amazon_S3_Key__c();
    key2.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key2.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key2.buildertek__Label__c='AWS Secret Key';
    key2.Name='AWS Private Key';

    insert key2;

    AmazonS3Credential s3Credentials = new AmazonS3Credential();
   

    List<String> files = new List<String>();
    files.add(flList[0].Id);
    files.add(flList[1].Id);


    BT_EmailChangeOrderController.getsubject(cont.Id , 'buildertek__Contract__c');

    BT_EmailChangeOrderController.SendEmail(to, cc ,files,subject ,  body,recordId, e.Id, pdfFileName,emailIds,Ids);



    Test.stopTest();
        }


}

@isTest static void testmethod4(){
  
    
    

    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User u = new User(Alias = 'sttst2', Email='cyril@maverickrealty.ae', 
                      EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = p.Id, MobilePhone = '+91 9326582649', Phone = '+919326582649',
                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@tesorg.com', ManagerId = UserInfo.getUserId());
    Insert u;
        System.RunAs(u){

            buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
    rfq1.buildertek__Description__c='TEST';
    insert rfq1;

    Account acc = new Account();
    acc.Name='test';
    insert acc;

    Contact con = new Contact();
    con.LastName='test';
    con.FirstName='testmthod';
    con.Email='test@test.com';
    con.AccountId=acc.Id;
    insert con;

    Contact con2 = new Contact();
    con2.LastName='test2';
    con2.Email='test2@gmail.com';
    con2.AccountId=acc.Id;
    insert con2;

    EmailTemplate e = new EmailTemplate ();
    e.isActive = true; 
    e.developerName = 'test';
    e.FolderId = UserInfo.getUserId(); 
    e.TemplateType= 'Text'; 
    e.Name = 'test'; 
    insert e;


    buildertek__RFI__c RFI = new buildertek__RFI__c();
    RFI.buildertek__Subject__c='Test';
    RFI.buildertek__Assigned_To__c=con.Id;
    RFI.buildertek__Due_Date__c=Date.Today();
    insert RFI;

    Attachment attach=new Attachment();       
    attach.Name='Unit Test Attachment';
    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    attach.body=bodyBlob;
    attach.parentId=RFI.id;

    insert attach;

    Attachment attach2=new Attachment();       
    attach2.Name='Unit Test Attachment';
    Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
    attach2.body=bodyBlob2;
    attach2.parentId=RFI.id;

    insert attach2;




    ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
insert contentVersion;

ContentVersion contentVersion2 = new ContentVersion(
    Title          = 'a picture',
    PathOnClient   = 'Pic.jpg',
    VersionData    = Blob.valueOf('Test Content'),
    IsMajorVersion = true);
insert contentVersion2;


    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = RFI.Id;
    cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;



  
    
    buildertek__Contract__c cont = new buildertek__Contract__c();
    cont.Name = 'Test Contract';
    insert cont;

    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
    adminInterfaceNodeConfigurations.Name = 'Change Order Configuration';
    adminInterfaceNodeConfigurations.buildertek__Quote_Configuration__c = false;
    adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = 'Test emial subject';
    insert adminInterfaceNodeConfigurations;



    List<String> to = new List<String>();
    to.add(con.Id);
    to.add(con2.Id);


    List<String> cc = new List<String>();
    cc.add(con.Id);
    // cc.add(con2.Id);

    String subject='Test';

    String body='Test Body ';

    String pdfFileName='Test pdf name';

    List<String> recordId = new List<String>();
    recordId.add(con.Id);
    recordId.add(con2.Id);

    List<String> emailIds = new List<String>();
    emailIds.add('test@gmail.com');


    List<String> Ids = new List<String>();
    Ids.add(con.Id);
    Ids.add(con2.Id);


   
  

    



    Test.startTest();

    FileTriggerHandler.isSkipTrigger=true;
    List<File__c> flList = new  List<File__c>();

    buildertek__File__c fileItem = new buildertek__File__c();
    fileItem.Name = 'Test Material';
    fileItem.buildertek__Bucket_Name__c='btdocs';
    fileItem.buildertek__Amazon_File_Key__c='PaymentApp(30)';
    fileItem.buildertek__File_Presigned_URL__c=null;
    flList.add(fileItem);

    buildertek__File__c fileItem2 = new buildertek__File__c();
    fileItem2.Name = 'Test Material';
    fileItem2.buildertek__Bucket_Name__c='btdocs';
    fileItem2.buildertek__Amazon_File_Key__c='image004(1)';
    fileItem2.buildertek__File_Presigned_URL__c=null;
    flList.add(fileItem2);
    insert flList;
    
    Amazon_S3_Key__c key = new Amazon_S3_Key__c();
    key.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key.buildertek__Label__c='AWS Access Key Id';
    key.Name='AWS Public Key';

    insert key;

    Amazon_S3_Key__c key2 = new Amazon_S3_Key__c();
    key2.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key2.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key2.buildertek__Label__c='AWS Secret Key';
    key2.Name='AWS Private Key';

    insert key2;

    AmazonS3Credential s3Credentials = new AmazonS3Credential();
   

    List<String> files = new List<String>();
    files.add(flList[0].Id);
    files.add(flList[1].Id);
   
    BT_EmailChangeOrderController.getsubject(rfq1.Id , 'buildertek__RFQ__c');
    BT_EmailChangeOrderController.getTemplates('');
    BT_EmailChangeOrderController.getbodyTemplates('');
    BT_EmailChangeOrderController.SendEmail(to, cc ,files,subject ,  body,recordId, e.Id, pdfFileName,emailIds,Ids);

    Test.stopTest();
        }
}


@isTest static void testmethod5(){
    Account acc = new Account();
    acc.Name='test';
    insert acc;
  
    
    buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
    rfq1.buildertek__Description__c='TEST';
    insert rfq1;

    
    buildertek__Submittal__c submittal1 = new buildertek__Submittal__c(); 
    insert submittal1;

    
    buildertek__Change_Order__c co=new buildertek__Change_Order__c();
    co.name='test';
    insert co;

    buildertek__Purchase_Order__c po=new buildertek__Purchase_Order__c();
    po.buildertek__Change_Order__c=co.Id;
    po.buildertek__Vendor__c = acc.id;
    insert po;

    buildertek__Account_Payable__c acpay=new buildertek__Account_Payable__c();
    acpay.buildertek__Purchase_Order__c=po.Id;
    insert acpay;

    List<String> recordId= new  List<String>();
    buildertek__Project__c project = new buildertek__Project__c();
    project.buildertek__Account__c = acc.Id;
    insert project;
    recordId.add(project.Id);

    buildertek__Project__c project2 = new buildertek__Project__c();
    project2.buildertek__Account__c = acc.Id;
    insert project2;
    recordId.add(project2.Id);
    


    Test.startTest();

    BT_EmailChangeOrderController.getsubject(acpay.Id , 'buildertek__Account_Payable__c');
    BT_EmailChangeOrderController.getdetails(recordId);



    Test.stopTest();
}
@isTest static void testmethod6(){
    buildertek__Account_Payable_Clone__c ap = new buildertek__Account_Payable_Clone__c();
        ap.buildertek__Description__c = 'test1';
        insert ap;
    Test.startTest();

    BT_EmailChangeOrderController.getsubject(ap.Id , 'buildertek__Account_Payable_Clone__c');



    Test.stopTest();
}

@isTest static void testmethod7(){
    


    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User u = new User(Alias = 'sttst2', Email='cyril@maverickrealty.ae', 
                      EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = p.Id, MobilePhone = '+91 9326582649', Phone = '+919326582649',
                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@tesorg.com', ManagerId = UserInfo.getUserId());
    Insert u;
        System.RunAs(u){

            
    buildertek__Contract__c cont = new buildertek__Contract__c();
    cont.Name = 'Test Contract';
    insert cont;


            buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
    rfq1.buildertek__Description__c='TEST';
    insert rfq1;

    Account acc = new Account();
    acc.Name='test';
    insert acc;

    Contact con = new Contact();
    con.LastName='test';
    con.FirstName='testmthod';
    con.Email='test@test.com';
    con.AccountId=acc.Id;
    insert con;

    Contact con2 = new Contact();
    con2.LastName='test2';
    con2.Email='test2@gmail.com';
    con2.AccountId=acc.Id;
    insert con2;

    EmailTemplate e = new EmailTemplate ();
    e.isActive = true; 
    e.developerName = 'test';
    e.FolderId = UserInfo.getUserId(); 
    e.TemplateType= 'Text'; 
    e.Name = 'test'; 
    insert e;


    buildertek__RFI__c RFI = new buildertek__RFI__c();
    RFI.buildertek__Subject__c='Test';
    RFI.buildertek__Assigned_To__c=con.Id;
    RFI.buildertek__Due_Date__c=Date.Today();
    insert RFI;

    Attachment attach=new Attachment();       
    attach.Name='Unit Test Attachment';
    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    attach.body=bodyBlob;
    attach.parentId=RFI.id;

    insert attach;

    Attachment attach2=new Attachment();       
    attach2.Name='Unit Test Attachment';
    Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
    attach2.body=bodyBlob2;
    attach2.parentId=RFI.id;

    insert attach2;




    ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
insert contentVersion;

ContentVersion contentVersion2 = new ContentVersion(
    Title          = 'a picture',
    PathOnClient   = 'Pic.jpg',
    VersionData    = Blob.valueOf('Test Content'),
    IsMajorVersion = true);
insert contentVersion2;


    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = RFI.Id;
    cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;



  
    
    buildertek__Contract__c cont1 = new buildertek__Contract__c();
    cont1.Name = 'Test Contract';
    insert cont1;

    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
    adminInterfaceNodeConfigurations.Name = 'Change Order Configuration';
    adminInterfaceNodeConfigurations.buildertek__Quote_Configuration__c = false;
    adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = 'Test emial subject';
    insert adminInterfaceNodeConfigurations;



    List<String> to = new List<String>();
    to.add(con.Id);
    to.add(con2.Id);


    List<String> cc = new List<String>();
    cc.add(con.Id);
    cc.add(con2.Id);

    String subject='Test';

    String body='Test Body ';

    String pdfFileName='Test pdf name';

    List<String> recordId = new List<String>();
    recordId.add(con.Id);
    recordId.add(con2.Id);

    List<String> emailIds = new List<String>();
    emailIds.add('test@gmail.com');
    emailIds.add('test2@gmail.com');



    List<String> Ids = new List<String>();
    Ids.add(con.Id);
    Ids.add(con2.Id);


   
  

    



    Test.startTest();

    FileTriggerHandler.isSkipTrigger=true;
    List<File__c> flList = new  List<File__c>();

    buildertek__File__c fileItem = new buildertek__File__c();
    fileItem.Name = 'Test Material';
    fileItem.buildertek__Bucket_Name__c='btdocs';
    fileItem.buildertek__Amazon_File_Key__c='PaymentApp(30)';
    fileItem.buildertek__File_Presigned_URL__c=null;
    flList.add(fileItem);

    buildertek__File__c fileItem2 = new buildertek__File__c();
    fileItem2.Name = 'Test Material';
    fileItem2.buildertek__Bucket_Name__c='btdocs';
    fileItem2.buildertek__Amazon_File_Key__c='image004(1)';
    fileItem2.buildertek__File_Presigned_URL__c=null;
    flList.add(fileItem2);
    insert flList;
    
    Amazon_S3_Key__c key = new Amazon_S3_Key__c();
    key.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key.buildertek__Label__c='AWS Access Key Id';
    key.Name='AWS Public Key';

    insert key;

    Amazon_S3_Key__c key2 = new Amazon_S3_Key__c();
    key2.buildertek__Configured_Value__c='AKIAXGW6XJWDK7EYGPHJ';
    key2.buildertek__Description__c='AWS Access Key Id provided by Amazon for authentication of Amazon webservice';
    key2.buildertek__Label__c='AWS Secret Key';
    key2.Name='AWS Private Key';

    insert key2;

    AmazonS3Credential s3Credentials = new AmazonS3Credential();
   

    List<String> files = new List<String>();
    files.add(flList[0].Id);
    files.add(flList[1].Id);
   
    BT_EmailChangeOrderController.getsubject(cont1.Id , 'buildertek__Contract__c');
    BT_EmailChangeOrderController.SendEmail(to, cc ,files,subject ,  body,recordId, e.Id, pdfFileName,emailIds,Ids);
    BT_EmailChangeOrderController.EmailBodyClass email = new  BT_EmailChangeOrderController.EmailBodyClass();
    email.emailBody='Test';
    email.emailSubject='Set subject';
    email.contactId=con.id;




    Test.stopTest();
        }
}



}