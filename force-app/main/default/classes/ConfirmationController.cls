/*Developed By: Laxman
 Date:  11-08-2020
 Description : Here we have to update signature and date of the customer .
 */
public without sharing class ConfirmationController{
    public string selectedValue{ get; set; }

    public string recordID{ get; set; }

    // Construct the list of emails we want to send
    string templateBody = '';
    string templateBody1 = '';
    string templateBody2 = '';
    public String templateId;
    public string theTemplate;
    public string templateName;

    public string fileid{ get; set; }

    public string Checkcustomerview{ get; set; }

    public string filerecid{ get; set; }

    public String imageURL{ get; set; }

    public String customerAcceptedDate{ get; set; }

    public transient boolean customSignature{ get; set; }

    public boolean orderRejected{ get; set; }

    public buildertek__Contract__c contrctrec{ get; set; }

    public boolean contractstatus{ get; set; }

    public Boolean isOrderLien{ get; set; }

    public string objectAPIName{ get; set; }

    public transient string strBody{ get; set; }

    public list<linewrapper> wraplst{ get; set; }

    public String rejectionReason{ get; set; }

    public String cdId{ get; set; }

    public list<buildertek__Quote_Line_Group__c> Quotelinegroup;
    Public map<id, list<buildertek__Quote_Item__c>> quotegroupingmap;

    public List<buildertek__Quote_Item__c> quotelinerecords{ get; set; }

    public boolean displayPopup{ get; set; }

    public Boolean isActionMethodCall{ get; set; }
    public String quoteMessage{ get; set; }
    public Boolean isAccepted{ get; set; }

    public Boolean allQuoteLineAccepted{ get; set; }

    public String Result{ get; set; }
    public String RejectResult{ get; set; }

    //public ApexPages.StandardController std;
    public transient string imageContent{ get; set; }
     public string imageContentforReject{ get; set; }
    public Boolean reject_Quote_on_Rejected_Lines{ get; set; }

    public ConfirmationController(){
        isAccepted  = false;
        // std = ApexPages.StandardSetController;
        //        System.debug('Constrctor 2::'+std);
        contractstatus = true;
        orderRejected = false;
        isOrderLien = false;
        isActionMethodCall = true;
        isAccepted = false;
        allQuoteLineAccepted=true;
        Result = 'Not Accepted';
        RejectResult = 'Not Accepted';
        contrctrec = new buildertek__Contract__c();
        Quotelinegroup = new list<buildertek__Quote_Line_Group__c>();
        recordID = apexpages.currentPage().getParameters().get('Id');
        if (apexpages.currentPage().getParameters().get('isOrderLienItem') != null){
            isOrderLien = Boolean.valueOf(apexpages.currentPage().getParameters().get('isOrderLienItem'));
        } else{
            isOrderLien = false;
        }

        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id, Name, buildertek__Reject_Quote_on_Rejected_Lines__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name =: 'Quote Configuration'];
        reject_Quote_on_Rejected_Lines = adminInterfaceNodeConfigurations.buildertek__Reject_Quote_on_Rejected_Lines__c;

        //recordID =  std.getRecord().Id;
        Checkcustomerview = apexpages.currentPage().getParameters().get('view');
        system.debug('id---constructr --customerview------> ' + recordID);
        system.debug('Checkcustomerview'+Checkcustomerview);
        objectAPIName = '';
        string keyPrefix = recordID.substring(0, 3);
        for (Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            String prefix = obj.getDescribe().getKeyPrefix();
            //if (prefix == keyPrefix){
            if(keyPrefix.equals(prefix)){
                system.debug('hello'+keyPrefix.equals(prefix));
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }
        //if(Checkcustomerview == null){
        if(objectAPIName.contains('buildertek__Quote__c')){
            buildertek__Quote__c quotrec;
            quotrec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__To_Emails__c,buildertek__Opportunity__c,buildertek__Opportunity__r.OwnerId
                       from buildertek__Quote__c
                       where Id = :recordId
                       limit 1];
            if(quotrec != null && quotrec.buildertek__Status__c == 'Customer Accepted'){
                quoteMessage = 'This Quote has already been Accepted, please contact your Sales Representative with any questions.';
                isAccepted  = true;
                 Result = 'Accepted';
                RejectResult = 'Accepted';
            }else if(quotrec != null && quotrec.buildertek__Status__c == 'Rejected'){
                quoteMessage = 'This Quote has already been Rejected, please contact your Sales Representative with any questions.';
                isAccepted  = true;
                Result = 'Accepted';
                RejectResult = 'Rejected';
            }else{
                isAccepted  = false;
            }

        }
       // }
       /* if(recordID != null){
            objectAPIName = Id.valueOf(recordID).getSObjectType().getDescribe().getName();
            system.debug('objectAPIName&&&&&&&&&&&'+objectAPIName);
        }*/

        /*  if(objectAPIName.contains('buildertek__Contract__c')){
         contrctrec = [select id,Name,buildertek__Status__c,buildertek__Project__c from buildertek__Contract__c where Id = :recordID limit 1];
         if(contrctrec.buildertek__Status__c == 'Accepted'){
         customSignature = true;
         }
         }*/

        displayQuotelinerecords();
    }

    public list<string> recjectquotelineids{ get; set; }

    public list<string> acceptQuotelineids{ get; set; }

    public string quotelineid{ get; set; }

    public void RjectUnCheckSelectAll(){


        for (linewrapper rec : wraplst){
            for (quotelinewrapper wrapp : rec.warapperrec){

                if (wrapp.isRejected == true){
                    wrapp.isApproved = false;
                    //acceptQuotelineids.add(wrapp.Qlinerec.Id);
                }

            }
        }
    }

    public void UnCheckSelectAll(){
        for (linewrapper rec : wraplst){
            for (quotelinewrapper wrapp : rec.warapperrec){

                if (wrapp.isApproved == true){
                    wrapp.isRejected = false;
                    //acceptQuotelineids.add(wrapp.Qlinerec.Id);
                }

            }
        }
    }

    public list<buildertek__Quote_Item__c> rejectQuotelinerecords{ get; set; }

    public list<buildertek__Quote_Item__c> acceptQuotelinerecords{ get; set; }

    public void updateQuotelinestatus(){
        try{
            rejectQuotelinerecords = new list<buildertek__Quote_Item__c>();
            acceptQuotelinerecords = new list<buildertek__Quote_Item__c>();
            recjectquotelineids = new list<string>();
            acceptQuotelineids = new list<string>();

            for (linewrapper rec : wraplst){
                for (quotelinewrapper wrapp : rec.warapperrec){

                    if (wrapp.isApproved == true){

                        acceptQuotelineids.add(wrapp.Qlinerec.Id);
                    }
                    if (wrapp.isRejected == true){

                        recjectquotelineids.add(wrapp.Qlinerec.Id);
                    }
                }
            }
            system.debug(acceptQuotelineids + '-----Qlinerec-----' + recjectquotelineids);
            if (recjectquotelineids.size() > 0){
                rejectQuotelinerecords = [select id, Name, Net_Total_Price__c, buildertek__Quote__c, buildertek__Status__c
                                          from buildertek__Quote_Item__c
                                          where buildertek__Quote__c = :recordID and Id IN :recjectquotelineids];
                for (buildertek__Quote_Item__c qlinerec : rejectQuotelinerecords){
                    qlinerec.buildertek__Status__c = 'Reject';
                }
                update rejectQuotelinerecords;
            }
            if (acceptQuotelineids.size() > 0){
                acceptQuotelinerecords = [select id, Name, Net_Total_Price__c, buildertek__Quote__c, buildertek__Status__c
                                          from buildertek__Quote_Item__c
                                          where buildertek__Quote__c = :recordID and Id IN :acceptQuotelineids];
                for (buildertek__Quote_Item__c qlinerec : acceptQuotelinerecords){
                    qlinerec.buildertek__Status__c = 'Accept';
                }
                update acceptQuotelinerecords;
            }
            system.debug(acceptQuotelineids + '---------Accept and reject-----ids--------------' + recjectquotelineids);
            createconfirmationPage();
            system.debug(rejectQuotelinerecords + '---------Accept and reject-------------------' + acceptQuotelinerecords);
        } catch (exception e){
        }
    }

    public void closeRejectReason(){
        displayPopup = false;
    }

    public void showRejectReasonPopup(){
        displayPopup = true;
    }

    public list<buildertek__Quote_Item__c> customerrejectQuotelinerecords{ get; set; }

    public list<buildertek__Quote_Item__c> customeracceptQuotelinerecords{ get; set; }

    public list<string> customerrecjectlineids{ get; set; }

    public list<string> customeracceptlineids{ get; set; }

    public void saveRejectionReason(){

        displayPopup = false;
        if (String.isNotBlank(rejectionReason)){
            customerrecjectlineids = new list<string>();
            customeracceptlineids = new list<string>();
            customerrejectQuotelinerecords = new list<buildertek__Quote_Item__c>();
            customeracceptQuotelinerecords = new list<buildertek__Quote_Item__c>();

            DateTime nowDT = System.now();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'SignatureName.png'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Signature' + ' ' + nowDT; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(imageContentforReject);  // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            system.debug('*******conVer*******' + conVer);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
            system.debug('objectAPIName-----' + objectAPIName);
            if (objectAPIName.contains('buildertek__Contract__c')){
                buildertek__Contract__c contractrec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__Project__c, buildertek__Signed_Contract_Date__c, buildertek__Contract_Rejection_Reason__c
                                                       from buildertek__Contract__c
                                                       where Id = :recordID
                                                       limit 1];
                if (contractrec != null){
                    contractrec.buildertek__Customer_Accepted_Date__c = system.today();
                    contractrec.buildertek__Status__c = 'Rejected';
                    contractrec.buildertek__Contract_Rejection_Reason__c = rejectionReason;
                    update contractrec;
                }
            }
            if (objectAPIName.contains('buildertek__Purchase_Order__c')){

                buildertek__Purchase_Order__c porec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__Date_Confirmed__c, buildertek__Rejection_Reason__c
                                                       from buildertek__Purchase_Order__c
                                                       where id = :recordID
                                                       limit 1];
                if (porec != null){
                    porec.buildertek__Customer_Accepted_Date__c = System.today();
                    porec.buildertek__Status__c = 'Vendor Rejected';
                    porec.buildertek__Rejection_Reason__c = rejectionReason;
                    update porec;
                }
            }
            if (objectAPIName.contains('buildertek__Quote__c')){
                if (!reject_Quote_on_Rejected_Lines) {
                    for (linewrapper rec : wraplst){
                        for (quotelinewrapper wrapp : rec.warapperrec){
                            if (wrapp.isRejected == true){
                                customerrecjectlineids.add(wrapp.Qlinerec.Id);
                            }
                        }
                    }
                    if (customerrecjectlineids.size() > 0){
                        customerrejectQuotelinerecords = [select id, Name, Net_Total_Price__c, buildertek__Quote__c, buildertek__Status__c
                                                          from buildertek__Quote_Item__c
                                                          where buildertek__Quote__c = :recordID and Id IN :customerrecjectlineids];
                        for (buildertek__Quote_Item__c qlinerec : customerrejectQuotelinerecords){
                            qlinerec.buildertek__Status__c = 'Accept';
                        }
                        update customerrejectQuotelinerecords;
                    }
                }
                buildertek__Quote__c quoterec;

                quoterec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c
                            from buildertek__Quote__c
                            where Id = :recordId
                            limit 1];
                if (quoterec != null){
                    quoterec.buildertek__Customer_Accepted_Date__c = system.today();
                    //  quoterec.buildertek__Status__c ='Customer Accepted';
                    quoterec.buildertek__Status__c = 'Rejected';
                    quoterec.buildertek__Rejection_Reason__c = rejectionReason;
                    update quoterec;
                }
            }
            if (objectAPIName.contains('buildertek__Change_Order__c')){
                buildertek__Change_Order__c corec = [select id, Name, buildertek__Customer_Accepted_Date__c, buildertek__Date_Approved__c
                                                     from buildertek__Change_Order__c
                                                     where Id = :recordID
                                                     limit 1];
                if (corec != null){
                    corec.buildertek__Customer_Accepted_Date__c = system.today();
                    corec.buildertek__Rejection_Reason__c = rejectionReason;
                    corec.buildertek__Status__c = 'Customer Rejected';
                    update corec;
                }
            }
            orderRejected = true;
            customSignature = true;
        }
    }

    public void displayQuotelinerecords(){
        wraplst = new list<linewrapper>();
        quotelinerecords = new list<buildertek__Quote_Item__c>();
        System.debug('RecordId Display::' + recordID);
        List<buildertek__Quote__c> Quoterec = [select id, name, buildertek__Status__c
                                               from buildertek__Quote__c
                                               where Id = :recordID
                                               limit 1];
        /*if(Quoterec.size()>0){
         if(Quoterec[0].buildertek__Status__c == 'Customer Accepted'){
         quotelinerecords = [select id,Name,buildertek__Net_Total_Price__c,buildertek__Grouping__c,buildertek__Net_Unit__c,
         buildertek__Grouping__r.Name,buildertek__Quote__c,buildertek__Status__c from buildertek__Quote_Item__c where buildertek__Quote__c =:recordID AND buildertek__Status__c =:'Accept'];
         }else{ */
        quotelinerecords = [select id, Name, buildertek__Net_Total_Price__c, buildertek__Grouping__c, buildertek__Net_Unit__c, buildertek__Grouping__r.Name, buildertek__Quote__c, buildertek__Status__c
                            from buildertek__Quote_Item__c
                            where buildertek__Quote__c = :recordID
                            ORDER BY buildertek__Priority__c ASC];
        //}
        //}
        /* for(buildertek__Quote_Item__c  quoteitem : quotelinerecords){
         quotelinewrapper Qlinewrap = new quotelinewrapper();
         Qlinewrap.Qlinerec = quoteitem;
         if(quoteitem.buildertek__Status__c == 'Accept'){
         Qlinewrap.isApproved = false;
         }else{
         Qlinewrap.isApproved = true;
         }
         quotelinewraplst.add(Qlinewrap);
         }*/
        set<Id> groupid = new set<Id>();
        quotegroupingmap = new map<id, list<buildertek__Quote_Item__c>>();
        for (buildertek__Quote_Item__c qutitem : quotelinerecords){
            if (!quotegroupingmap.containsKey(qutitem.buildertek__Grouping__c)){
                quotegroupingmap.put(qutitem.buildertek__Grouping__c, new list<buildertek__Quote_Item__c>());
            }
            quotegroupingmap.get(qutitem.buildertek__Grouping__c).add(qutitem);

            if (qutitem.buildertek__Grouping__c != null){
                groupid.add(qutitem.buildertek__Grouping__c);
            }
        }

        Quotelinegroup = [Select Id, Name
                          from buildertek__Quote_Line_Group__c
                          where Id = :groupId
                          order by Name asc];
        system.debug('Quotelinegroupsize---->' + Quotelinegroup.size());

        for (buildertek__Quote_Line_Group__c quotelinegrouprec : Quotelinegroup){

            decimal quoteitemNetunitprice = 0.0;
            decimal quoteitemlistTotal = 0.0;
            linewrapper wrap = new linewrapper();
            wrap.groupName = quotelinegrouprec.Name;
            //wrap.quotelineitemlst = quotegroupingmap.get(quotelinegrouprec.Id);
            list<quotelinewrapper> qlinewraplst = new list<quotelinewrapper>();
            for (buildertek__Quote_Item__c quoteitemrec : quotegroupingmap.get(quotelinegrouprec.Id)){
                quotelinewrapper qlinewrap = new quotelinewrapper();
                if (quoteitemrec.buildertek__Status__c == 'Accept'){
                    qlinewrap.isApproved = true;
                    qlinewrap.isRejected = false;
                } else{
                    qlinewrap.isApproved = false;
                    qlinewrap.isRejected = true;
                    if (reject_Quote_on_Rejected_Lines){
                        allQuoteLineAccepted=false;
                    }
                }
                if (quoteitemrec.buildertek__Net_Unit__c != null){
                    quoteitemNetunitprice += quoteitemrec.buildertek__Net_Unit__c;
                }
                if (quoteitemrec.buildertek__Net_Total_Price__c != null){
                    quoteitemlistTotal += quoteitemrec.buildertek__Net_Total_Price__c;
                }
                qlinewrap.Qlinerec = quoteitemrec;
                qlinewraplst.add(qlinewrap);
            }

            wrap.netunitprice = quoteitemNetunitprice;
            wrap.listTotal = quoteitemlistTotal;
            wrap.warapperrec = qlinewraplst;

            wraplst.add(wrap);
        }
    }

    public void createconfirmationPage(){
        //Don't need this functionality
        // if (objectAPIName.contains('buildertek__Quote__c')){
        //     buildertek__Quote__c quote = new buildertek__Quote__c();
        //     quote.Id = recordID;
        //     quote.buildertek__Date_Proposal_Opened_Last__c = System.now();
        //     update quote;
        // }
        string vendorID;
        // Pick a dummy Contact
        if (vendorID == null){
            Contact c;
            c = [select id, Email
                 from Contact
                 where email<>null
                 limit 1];
            vendorID = c.id;
        }
        templateId = apexpages.currentPage().getParameters().get('templateId');
        recordID = apexpages.currentPage().getParameters().get('Id');
        Checkcustomerview = apexpages.currentPage().getParameters().get('view');


        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Savepoint sp = Database.setSavepoint();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //string theTemplate;
        if (templateId != null){
            theTemplate = [SELECT Id
                           FROM EmailTemplate
                           WHERE Id = :templateId].Id;
        }
        if (templateId == null && Checkcustomerview != null){
            EmailTemplate emailtemrec = [Select Id, Name, Body, DeveloperName
                                         from EmailTemplate
                                         where DeveloperName = :'Quote_Template_2'
                                         limit 1];
            theTemplate = emailtemrec.Id;
        }
       email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(vendorID);
        email.setSaveAsActivity(false);
        email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        msgList.add(email);

        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }
      /*  String[] toAddresses = new String[] {'mailto:manisha.kotha@diligentforcelabs.com'};

email.setToAddresses(toAddresses);
email.setSenderDisplayName('Salesforce Support');
email.setSubject('New Case Created : ');
email.setBccSender(false);
email.setUseSignature(false);
email.setPlainTextBody('Your Case: '  +' has been created.');
email.setHtmlBody('Your case:<b> </b>has been created.<p>'+
     'To view your case <a href=https://mydomainname.my.salesforce.com/>click here.</a>');
     email.SetSaveAsActivity(true);

// Send the email you have created.
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  */











        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
        string theTemplate1 = [SELECT Id
                               FROM EmailTemplate
                               WHERE Name = 'BT Proposal Images'].Id;
        email1.setTemplateId(theTemplate1);
        email1.setWhatId(recordId);
        email1.setTargetObjectId(vendorID);
        email1.setSaveAsActivity(false);
        email1.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        msgList1.add(email1);
        Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew1 : msgList1){
            templateBody2 = emailNew1.getHTMLBody();
        }
        system.debug('templateBody 2 ----------> ' + templateBody2);
        templateBody = templateBody1 + templateBody2;
        strBody = templateBody;
        system.debug('strBody -----> ' + strBody);

        try{
            document doc;
            doc = [SELECT ID
                   from Document
                   where DeveloperName = 'Company_Logo'
                   limit 1];

            string imageid = doc.id;
            imageid = imageid.substring(0, 15);
            strBody = strBody.replace('###############', imageid);
        } catch (exception ex){
            System.debug('Error Mesage::' + ex.getMessage());
            System.debug('Error Line::' + ex.getLineNumber());
        }
    }

    public void generatePDF(){
    }

    public PageReference uploadSignature(){

        transient Date nowDT = Date.today();
        System.debug('Check Debug log ==> '+nowDT);
        customerAcceptedDate = String.valueOf(DateTime.now());
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'SignatureName.png'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Signature' + ' ' + nowDT; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(imageContent);  // converting your binary string to Blog
        insert conVer;
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId
                     FROM ContentVersion
                     WHERE Id = :conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = recordID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'I';
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;

        ContentDistribution cd = new ContentDistribution();
        cd.name = 'PO';
        cd.ContentVersionId = conVer.id;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesAllowPDFDownload = true;
        cd.PreferencesAllowViewInBrowser = true;
        insert cd;
        ContentDistribution cdPublickLink = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl
                                             FROM ContentDistribution
                                             WHERE Id = :cd.Id];
        cdId = cdPublickLink.Id;

        if (objectAPIName.contains('buildertek__Contract__c')){
            buildertek__Contract__c contractrec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__Project__c, buildertek__Signed_Contract_Date__c
                                                   from buildertek__Contract__c
                                                   where Id = :recordID
                                                   limit 1];
            if (contractrec != null){
                contractrec.buildertek__Customer_Accepted_Date__c = nowDT;
                contractrec.buildertek__Status__c = 'Accepted';
                update contractrec;
            }
        }
        if (objectAPIName.contains('buildertek__Purchase_Order__c')){

            buildertek__Purchase_Order__c porec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__Date_Confirmed__c, buildertek__Rejection_Reason__c
                                                   from buildertek__Purchase_Order__c
                                                   where id = :recordID
                                                   limit 1];
            if (porec != null){

                if (isOrderLien){
                    porec.buildertek__Date_Lien_Release_Signed__c = Date.valueOf(Datetime.now().format('yyyy-MM-dd'));
                    porec.buildertek__Date_Confirmed__c = Date.today();
                } else{
                    porec.buildertek__Customer_Accepted_Date__c = nowDT;
                    porec.buildertek__Rejection_Reason__c = '';
                    porec.buildertek__Status__c = 'Vendor Accepted';

                }
                update porec;
            }

        }
        if (objectAPIName.contains('buildertek__Quote__c')){
            buildertek__Quote__c quoterec;

            quoterec = [select id, Name, buildertek__Status__c, buildertek__Customer_Accepted_Date__c, buildertek__To_Emails__c,buildertek__Opportunity__c,buildertek__Opportunity__r.OwnerId
                        from buildertek__Quote__c
                        where Id = :recordId
                        limit 1];
            if (quoterec != null){
                quoterec.buildertek__Customer_Accepted_Date__c = nowDT;
                quoterec.buildertek__Status__c = 'Customer Accepted';
                quoterec.buildertek__Date_Accepted_by_Customer__c = system.now();
                quoterec.buildertek__Date_Sent_To_Customer__c = System.today();
                update quoterec;

                buildertek__RFQ_Template_Settings__c rfqTemplateSettings = buildertek__RFQ_Template_Settings__c.getOrgDefaults();

                List<String> to = new List<String>();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{rfqTemplateSettings.buildertek__Inbound_Email_Address__c});
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setSubject('SavePDF [ref:' + quoterec.Id + ']');
                mail.setSaveAsActivity(false);
                System.debug('templateId: ' + templateId);
                if (templateId == null){
                    templateId = [SELECT Id
                                  FROM EmailTemplate
                                  WHERE DeveloperName = :'Quote_Template_2'].Id;
                }
                System.debug('templateId: ' + templateId);
                mail.setHtmlBody('Action:SavePDF; recordId:' + quoterec.Id + ';templateId:' + templateId + ';fileId:' + conVer.Id+'; Confirmation Controller');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });

                /*if(quoterec.buildertek__Status__c == 'Customer Accepted' && Checkcustomerview == null){
                 string theTemplate;
                 if (templateId != null){
                 theTemplate = [SELECT Id
                 FROM EmailTemplate
                 WHERE Id = :templateId].Id;
                 }
                 if (templateId == null && Checkcustomerview != null){
                 EmailTemplate emailtemrec = [Select Id, Name, Body, DeveloperName
                 from EmailTemplate
                 where DeveloperName = :'Quote_Template_2'
                 limit 1];
                 theTemplate = emailtemrec.Id;
                 }

                 String testString = quoterec.buildertek__To_Emails__c;
                 List<String> values = testString.split(',');
                // List<String> to = new List<String>();
                // to.add('harika.chunduri@diligentforcelabs.com');
                 List<String> cc = new List<String>();
                // cc.add('');
                 system.debug('theTemplate'+theTemplate + 'templateId'+templateId +'values' + values);
                 PreviewQuoteController.acceptandsendProposal('','',recordId,theTemplate,values, cc, conVer.Id ,cc,'');
                 }*/

            }

        }
        system.debug('objectAPIName'+objectAPIName);
        if (objectAPIName.contains('buildertek__Change_Order__c')){
            buildertek__Change_Order__c corec = [select id, Name, buildertek__Customer_Accepted_Date__c, buildertek__Date_Approved__c,buildertek__Status__c
                                                 from buildertek__Change_Order__c
                                                 where Id = :recordID
                                                 limit 1];
            if (corec != null){
                corec.buildertek__Status__c = 'Customer Accepted';
                corec.buildertek__Customer_Accepted_Date__c = nowDT;
                update corec;
            }
        }
        customSignature = true;
        return null;
    }

    public PageReference insertAttachment(){
        transient ContentDistribution cdPublicLink = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl
                                            FROM ContentDistribution
                                            WHERE Id = :cdId];
        PageReference pdfPage;
        pdfPage = Page.buildertek__ConfirmationPageAsPDF;
        pdfPage.getParameters().put('Id', recordID);
        pdfPage.getParameters().put('templateId', theTemplate);
        pdfPage.getParameters().put('isOrderLienItem', 'true');
        String imgURL = cdPublicLink.ContentDownloadUrl;
        pdfPage.getParameters().put('imgURL', imgURL);
        pdfPage.getParameters().put('customerAcceptedDate', customerAcceptedDate);

        Blob pdfBlob;
        pdfBlob = pdfPage.getContent(); //generate the pdf blob
        if (objectAPIName.contains('buildertek__Purchase_Order__c')){
            transient ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'Purchase Order Lien.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Purchase Order Lien' + ' ' + Datetime.valueOf(customerAcceptedDate).format('MM-dd-yyyy HH:mm:ss')+'.pdf'; // Display name of the files
            conVer.VersionData = pdfBlob;  // converting your binary string to Blog
            insert conVer;
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            transient ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            conDocLink.Visibility = 'AllUsers';
            insert conDocLink;
        }
        else if (objectAPIName.contains('buildertek__Change_Order__c')){
            transient ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'ChangeOrder.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'ChangeOrder' + ' ' + Datetime.valueOf(customerAcceptedDate).format('MM-dd-yyyy HH:mm:ss')+'.pdf'; // Display name of the files
            conVer.VersionData = pdfBlob;  // converting your binary string to Blog
            insert conVer;
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            transient ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            conDocLink.Visibility = 'AllUsers';
            insert conDocLink;
        }
        customSignature = true;
        return null;
    }

    public class linewrapper{
        public String groupName{ get; set; }

        public decimal netunitprice{ get; set; }

        public decimal listTotal{ get; set; }

        public list<quotelinewrapper> warapperrec{ get; set; }
    }

    public class quotelinewrapper{
        public buildertek__Quote_Item__c Qlinerec{ get; set; }

        public Boolean isApproved{ get; set; }

        public Boolean isRejected{ get; set; }
    }
}