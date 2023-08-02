/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date: 15/09/2017
*/
public without sharing class QuoteTriggerHandler {

    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipQuoteUpdateTrigger = false;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public QuoteTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(Quote__c[] newQuotes){
        set<Id> oppoids = new set<Id>();
        for(Quote__c quoterec : newQuotes){
            if(quoterec.buildertek__Opportunity__c !=null){
                oppoids.add(quoterec.buildertek__Opportunity__c);
            }
        }
        if(oppoids.size() > 0 ){
            list<Opportunity> opplst = [Select Id, Name,AccountId,
                                        Account.buildertek__Email_Address__c,
                                        Account.phone,
                                        Account.Name,
                                        Account.Billingcity,
                                        Account.Billingstate,
                                        Account.Billingcountry,
                                        Account.Billingstreet,
                                        Account.Billingpostalcode,
                                        Description from Opportunity where Id IN : oppoids  and AccountId != null];
            for(Quote__c quoterec : newQuotes){
                for(Opportunity opp :opplst ){
                    if(quoterec.buildertek__Opportunity__c == opp.Id ){
                        if(quoterec.Name == null || quoterec.Name == ''){
                            quoterec.Name = opp.Name;
                        }
                        // ====created date:-19th december 2022 devName:- Sakina ===
                        if(quoterec.buildertek__Description__c == null || quoterec.buildertek__Description__c == ''){
                            quoterec.buildertek__Description__c = opp.Description;
                        }
                        // ====created date:-19th december 2022 devName:- Sakina ===
                        if(opp.AccountId != null){
                            if(quoterec.buildertek__Bill_To_Email_Address__c == null || quoterec.buildertek__Bill_To_Email_Address__c == ''){
                                quoterec.buildertek__Bill_To_Email_Address__c = opp.Account.buildertek__Email_Address__c;
                            }
                            if(quoterec.buildertek__Bill_To_Cell_Phone__c == null || quoterec.buildertek__Bill_To_Cell_Phone__c == ''){
                                quoterec.buildertek__Bill_To_Cell_Phone__c = opp.Account.phone;
                            }
                            if(quoterec.buildertek__Bill_To_Name__c == null || quoterec.buildertek__Bill_To_Name__c == ''){
                                quoterec.buildertek__Bill_To_Name__c = opp.Account.Name;
                            }
                            /*  if(quoterec.buildertek__Bill_To_State__c == null || quoterec.buildertek__Bill_To_State__c == ''){
                            quoterec.buildertek__Bill_To_State__c = opp.Account.Billingstate;
                            }*/
                            if(quoterec.buildertek__Bill_To_City__c == null || quoterec.buildertek__Bill_To_City__c == ''){
                                quoterec.buildertek__Bill_To_City__c = opp.Account.Billingcity;
                            }
                            if(quoterec.buildertek__Bill_To_Street__c == null || quoterec.buildertek__Bill_To_Street__c == ''){
                                quoterec.buildertek__Bill_To_Street__c = opp.Account.Billingstreet;
                            }
                            if(quoterec.buildertek__Bill_To_Zip_Code__c == null || quoterec.buildertek__Bill_To_Zip_Code__c == ''){
                                quoterec.buildertek__Bill_To_Zip_Code__c = opp.Account.Billingpostalcode;
                            }


                        }
                    }

                }

            }
        }
        List<Quote__c> quList;

        quList = [Select Id, Auto_Number1__c,buildertek__Opportunity__c from Quote__c
                  where Project__c =:newQuotes[0].Project__c
                  ORDER BY CREATEDDATE DESC  LIMIT 1];

        // if(!Test.isRunningTest()){
        BT_Utils.genrateAutoNumber(quList, newQuotes, 'Auto_Number1__c');
        // }
        set<string> ProjectsIds = new set<string>();
        for(Quote__c Qts : newQuotes){
            ProjectsIds.add(Qts.Project__c);
        }
        system.debug('&&'+ProjectsIds);
        list<buildertek__Project__c> projectList;

        projectList=[SELECT Name,buildertek__Address__c,buildertek__Customer__c,buildertek__City__c,buildertek__Customer__r.BillingCity,buildertek__Customer__r.Name,buildertek__Customer__r.BillingState,buildertek__Customer__r.BillingPostalCode,buildertek__Customer__r.BillingStreet, buildertek__Customer__r.BillingCountry, buildertek__State__c,buildertek__Zip__c,buildertek__Country__c, buildertek__County__c FROM buildertek__Project__c WHERE Id IN :ProjectsIds];
        system.debug('&&'+projectList);
        for(Quote__c Qts : newQuotes){
            if(Qts.Project__c != null){
                for(buildertek__Project__c Projs : projectList){
                    if(Qts.Project__c == Projs.Id){
                        System.debug('Projs.Id-->>'+Projs.Id);
                        System.debug('Project Account--->>>'+Projs.buildertek__Customer__c);
                        if(Projs.buildertek__City__c == null || Projs.buildertek__State__c == null || Projs.buildertek__Address__c == null || Projs.buildertek__Zip__c == null || Projs.buildertek__County__c == null){
                            System.debug('---First If---');
                            if(Projs.buildertek__Customer__c != null){
                                System.debug('---Second IF---');
                                if(Qts.buildertek__Ship_To_City__c == null || Qts.buildertek__Ship_To_City__c == ''){
                                    System.debug('---In Qty---');
                                    System.debug('Projs.buildertek__Customer__c---->>'+Projs.buildertek__Customer__c);
                                    Qts.buildertek__Ship_To_City__c = Projs.buildertek__Customer__r.BillingCity;
                                    Qts.buildertek__Bill_To_City__c = Projs.buildertek__Customer__r.BillingCity;
                                }
                                if(Qts.buildertek__Ship_To_Name__c == null || Qts.buildertek__Ship_To_Name__c == ''){
                                    Qts.buildertek__Ship_To_Name__c = Projs.buildertek__Customer__r.Name;
                                    Qts.buildertek__Bill_To_Name__c = Projs.buildertek__Customer__r.Name;
                                }
                                if(Qts.buildertek__Ship_To_State__c == null || Qts.buildertek__Ship_To_State__c == ''){
                                    Qts.buildertek__Ship_To_State__c = Projs.buildertek__Customer__r.BillingState;
                                    Qts.buildertek__Bill_To_State__c = Projs.buildertek__Customer__r.BillingState;
                                }
                                if(Qts.buildertek__Ship_To_Street__c == null || Qts.buildertek__Ship_To_Street__c == ''){
                                    Qts.buildertek__Ship_To_Street__c = Projs.buildertek__Customer__r.BillingStreet;
                                    Qts.buildertek__Bill_To_Street__c = Projs.buildertek__Customer__r.BillingStreet;
                                }
                                if(Qts.buildertek__Ship_To_Zip_Code__c == null || Qts.buildertek__Ship_To_Zip_Code__c == ''){
                                    Qts.buildertek__Ship_To_Zip_Code__c = Projs.buildertek__Customer__r.BillingPostalCode;
                                    Qts.buildertek__Bill_To_Zip_Code__c = Projs.buildertek__Customer__r.BillingPostalCode;
                                }
                                if(Qts.buildertek__Ship_To_Country__c == null || Qts.buildertek__Ship_To_Country__c == ''){
                                    Qts.buildertek__Ship_To_Country__c = Projs.buildertek__Customer__r.BillingCountry;
                                    Qts.buildertek__Bill_To_Country__c = Projs.buildertek__Customer__r.BillingCountry;
                                }
                            }
                        }else{
                            System.debug('---Esle---');
                            if(Qts.buildertek__Ship_To_City__c == null || Qts.buildertek__Ship_To_City__c == ''){
                                Qts.buildertek__Ship_To_City__c = Projs.buildertek__City__c;
                                Qts.buildertek__Bill_To_City__c = Projs.buildertek__City__c;
                            }
                            if(Qts.buildertek__Ship_To_Name__c == null || Qts.buildertek__Ship_To_Name__c == ''){
                                Qts.buildertek__Ship_To_Name__c = Projs.Name;
                                Qts.buildertek__Bill_To_Name__c = Projs.Name;
                            }
                            if(Qts.buildertek__Ship_To_State__c == null || Qts.buildertek__Ship_To_State__c == ''){
                                Qts.buildertek__Ship_To_State__c = Projs.buildertek__State__c;
                                Qts.buildertek__Bill_To_State__c = Projs.buildertek__State__c;
                            }
                            if(Qts.buildertek__Ship_To_Street__c == null || Qts.buildertek__Ship_To_Street__c == ''){
                                Qts.buildertek__Ship_To_Street__c = Projs.buildertek__Address__c;
                                Qts.buildertek__Bill_To_Street__c = Projs.buildertek__Address__c;
                            }
                            if(Qts.buildertek__Ship_To_Zip_Code__c == null || Qts.buildertek__Ship_To_Zip_Code__c == ''){
                                Qts.buildertek__Ship_To_Zip_Code__c = Projs.buildertek__Zip__c;
                                Qts.buildertek__Bill_To_Zip_Code__c = Projs.buildertek__Zip__c;
                            }
                            if(Qts.buildertek__Ship_To_Country__c == null || Qts.buildertek__Ship_To_Country__c == ''){
                                Qts.buildertek__Ship_To_Country__c = Projs.buildertek__Country__c;
                                Qts.buildertek__Bill_To_Country__c = Projs.buildertek__Country__c;
                            }
                            if(Qts.buildertek__Bill_To_County__c == null || Qts.buildertek__Bill_To_County__c == ''){
                                Qts.buildertek__Bill_To_County__c = Projs.buildertek__County__c;
                            }
                        }
                    }
                }
            }
        }

    }

    public void OnBeforeUpdate(Quote__c[] oldQuotes, Quote__c[] updatedQuotes, Map<ID, Quote__c> QuotesMap){

    }

    public void OnBeforeDelete(Quote__c[] QuotesToDelete, Map<ID, Quote__c> QuotesMap){
        for(buildertek__Quote__c qtemp : QuotesToDelete){
            if(qtemp.buildertek__Status__c=='Sent'){
                //  qtemp.addError('Shouldn\'t be able to delete a \'Sent\' or \'Accepted\' Quote.');
                qtemp.addError('You cannot Delete a Quote that has a Sent Status.');
            }else if (qtemp.buildertek__Status__c=='Customer Accepted') {
                qtemp.addError('You cannot Delete a Quote that has a Customer Accepted Status.');
            }
        }
    }

    public void OnAfterInsert(Quote__c[] newQuotes, Map<ID, Quote__c> newQuotesMap){
        set<Id> oppoids = new set<Id>();
        for(buildertek__Quote__c qutrec : newQuotes){
            if(qutrec.buildertek__Status__c == 'Customer Accepted' && qutrec.buildertek__Opportunity__c !=null){
                oppoids.add(qutrec.buildertek__Opportunity__c);
            }
        }
        if(oppoids.size()>0){
            list<opportunity> opprecstagelst = new list<opportunity> ();
            list<opportunity> oppreclst = [select id,name,StageName,buildertek__checkOpptyStage__c from Opportunity where Id IN : oppoids];
            for(opportunity opprec : oppreclst){
                if(opprec.StageName != 'Closed Won' && opprec.buildertek__checkOpptyStage__c !='Project Created'){
                    oppRec.buildertek__checkOpptyStage__c = 'No Project';
                    opprec.StageName = 'Closed Won';
                    opprecstagelst.add(opprec);
                }

            }
            if(opprecstagelst.size() > 0) {
                update opprecstagelst;
            }
        }
    }

    public void OnAfterUpdate(Quote__c[] oldQuotes, Quote__c[] updatedQuotes, Map<ID, Quote__c> QuotesMap, Map<Id, Quote__c> oldQuotesMap){

        list<buildertek__Admin_Interface_Node_Configuration__c> adminSetting = [Select Id, Name , buildertek__Send_customer_Quote_after_signature__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Quote Configuration' limit 1];

        //Create Project from Quote Acceptance on Opportunity
        set<Id> quoteoppoids = new set<Id>();
        set<Id> quoteIdsList = new set<Id>();
        decimal totalamount = 0;
        string quoteOwner = '';
        Map<Id, List<Id>> quoteIdToUserIdsMap = new Map<Id, List<Id>>();
        for(buildertek__Quote__c qutrec : updatedQuotes){
            if(qutrec.buildertek__Status__c == 'Customer Accepted' && qutrec.buildertek__Opportunity__c !=null && oldQuotesMap.get(qutrec.id).buildertek__Status__c != qutrec.buildertek__Status__c){
                quoteoppoids.add(qutrec.buildertek__Opportunity__c);
                quoteOwner = qutrec.OwnerId;
                system.debug('&&'+quoteoppoids);
                system.debug('&&'+quoteOwner);
                //quoteIdsList.add(qutrec.id);
            }


            // if(qutrec.buildertek__Status__c == 'Customer Accepted' && oldQuotesMap.get(qutrec.id).buildertek__Status__c != qutrec.buildertek__Status__c && qutrec.buildertek__Description__c != null){
            //     String Description = qutrec.buildertek__Description__c;
            //     Id TempalteId = Description.split('Jaimin')[0];
            //     Blob ConverId = Description.split('Jaimin')[1];
            //     System.debug('TemplateId: ' + TempalteId);
            //     System.debug('ConverId: ' + ConverId);
            //     ConfirmationController.setAttachmentBody(qutrec.id,TempalteId,ConverId);
            //     // system.debug('Blob ---> ' + b);

            //     // ContentVersion conVer1 = new ContentVersion();
            //     // conVer1.PathOnClient = 'Quote.pdf'; // The files name, extension is very important here which will help the file in preview.
            //     // conVer1.VersionData = b; // converting your binary string to Blog
            //     // insert conVer1;    //Insert ContentVersion

            //     // ContentDocumentLink conDocLink1 = New ContentDocumentLink();
            //     // conDocLink1.LinkedEntityId = qutrec.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            //     // conDocLink1.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer1.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
            //     // conDocLink1.Visibility = 'AllUsers';
            //     // insert conDocLink1;

            // }

            // Commented this based on requirements in BUIL - 3264
            // if(qutrec.buildertek__Status__c == 'Customer Accepted'){
            //     string email = qutrec.buildertek__Bill_To_Email_Address__c;
            //     if(email != null && email != ''){
            //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //         mail.setToAddresses(new String[] {email});
            //         mail.setSenderDisplayName('BuilderTek');
            //         mail.setSubject('BuilderTek Quote Accepted');
            //         mail.setPlainTextBody('Thank you for accepting the quote. We will be in touch with you shortly.');
            //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            //         System.debug('Email sent to '+email);
            //     }
            // }

            if(adminSetting.size() > 0 && adminSetting[0].buildertek__Send_customer_Quote_after_signature__c == true){
                System.debug('Jaimin : Quote Id is '+qutrec.Id);
                System.debug('Jaimin : Quote Owner is '+qutrec.OwnerId);

                if(qutrec.buildertek__Status__c == 'Customer Accepted'  && oldQuotesMap.get(qutrec.id).buildertek__Status__c != qutrec.buildertek__Status__c){
                    // string emailbody = '<html><body><h3>  Your Quote has been Accepted </h3>'  + '<br/>';
                    User user = [SELECT Id, Email, Name FROM User WHERE Id =:qutrec.OwnerId];
                    List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'QuoteAccepted'];
                    // emailbody += 'Quote Name : '+qutrec.Name+'<br/>';
                    // if(qutrec.buildertek__Customer_Account__c != null){
                    //     emailbody += 'Customer Name : '+qutrec.buildertek__Customer_Account__r.Name+'<br/>';
                    // }
                    // if(qutrec.buildertek__Grand_Total__c != null){
                    //     emailbody += 'Quote Amount : '+qutrec.buildertek__Grand_Total__c+'<br/>';
                    // }
                    // if(qutrec.OwnerId != null){
                    //     emailbody += 'Quote Owner : '+user.Name+'<br/></body></html>';
                    // }
                    Id tempID = null;
                    if (!templates.isEmpty()) {
                        tempID = templates[0].Id;
                    }
                
                    if (tempID == null) {
                        System.debug('Email template not found');
                        return;
                    }

                    string email = qutrec.OwnerId;
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
                    //log user.email
                    System.debug('Jaimin : Email is '+user.Email);
                    System.debug('Jaimin : Owner is '+user.Name);
                    if(email != null && email != ''){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {email});
                        if (owea.size() > 0) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        // mail.setSubject('Quote Accepted (Quote Id : '+qutrec.Id+')');
                        // mail.setHtmlBody(emailbody);
                        mail.setTemplateId(tempID);
                        mail.setSaveAsActivity(false);
                        // Set the related record ID
                        mail.setWhatId(qutrec.Id);
                        mail.setTargetObjectId(qutrec.OwnerId);
                        System.debug('mail-->' + mail);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        System.debug('Email sent to ' + email);
                    }
                }

            }






        }



        // added by Jaimin for CHB-34
        // Set<Id> ownerIdsSet = new Set<Id>();
        // for(Id quoteId : quoteIdToUserIdsMap.keySet()){
        //     List<Id> userIdsList = quoteIdToUserIdsMap.get(quoteId);
        //     ownerIdsSet.add(userIdsList.get(1));
        // }
        // for (Id t : ownerIdsSet) {
        //     System.debug('name of id '+t);
        // }
        // Set<Id> CustomerIdSet = new Set<Id>();
        // for(Id quoteId : quoteIdToUserIdsMap.keySet()){
        //     List<Id> userIdsList = quoteIdToUserIdsMap.get(quoteId);
        //     CustomerIdSet.add(userIdsList.get(0));
        // }
        // for (Id t : CustomerIdSet) {
        //     System.debug('name of id CustomerIdSet '+t);
        // }
        // Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIdsSet]);
        // Map<Id, Account> CustomerMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :CustomerIdSet]);
        // for(buildertek__Quote__c qutrec : updatedQuotes){
        //     if(adminSetting.size() > 0 && adminSetting[0].buildertek__Send_customer_Quote_after_signature__c == true){
        //         if(qutrec.buildertek__Status__c == 'Customer Accepted'  && oldQuotesMap.get(qutrec.id).buildertek__Status__c != qutrec.buildertek__Status__c){
        //             string emailbody = '<html><body><h3>  Your Quote has been Accepted </h3><br/>';
        //             emailbody += 'Quote Name : '+qutrec.Name+'<br/>';
        //             if(qutrec.buildertek__Customer_Account__c != null){
        //                 // emailbody += 'Customer Name : '+qutrec.buildertek__Customer_Account__r.Name+'<br/>';
        //                 emailbody += 'Customer Name : '+CustomerMap.get(qutrec.buildertek__Customer_Account__c).Name+'<br/>';
        //             }
        //             if(qutrec.buildertek__Grand_Total__c != null){
        //                 emailbody += 'Quote Amount : '+qutrec.buildertek__Grand_Total__c+'<br/>';
        //             }
        //             if(qutrec.OwnerId != null){
        //                 // emailbody += 'Quote Owner : '+qutrec.Owner.Name+'<br/></body></html>';
        //                 emailbody += 'Quote Owner : '+ownerMap.get(qutrec.OwnerId).Name+'<br/></body></html>';
        //             }

        //             string email = qutrec.OwnerId;
        //             if(email != null && email != ''){
        //                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //                 mail.setToAddresses(new String[] {email});
        //                 mail.setSenderDisplayName('Admin');
        //                 mail.setSubject('Quote Accepted (Quote Id : '+qutrec.Id+')');
        //                 mail.setHtmlBody(emailbody);
        //                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        //                 System.debug('Email sent to '+email);
        //             }
        //         }

        //     }
        // }


        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                    buildertek__Quote_Configuration__c,buildertek__Update_the_Opp_Amount__c,
                                                                                                    buildertek__Default_Project_Owner__c,buildertek__Org_Base_URL__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name=:'Quote Configuration' and buildertek__Quote_Configuration__c !=false limit 1];
        if(quoteoppoids.size()>0){

            if(adminInterfaceNodeConfigurations.size()>0 ){
                if(adminInterfaceNodeConfigurations[0].buildertek__Quote_Configuration__c == true){
                    list<buildertek__Quote__c> oppquotereclist = [select id,name,buildertek__Is_Customer_Accepted__c,buildertek__Opportunity__r.Account.Billingstreet,buildertek__Opportunity__r.Account.Billingcountry,buildertek__Opportunity__r.Account.Billingstate,buildertek__Opportunity__r.Account.Billingcity,buildertek__Opportunity__r.Account.Billingpostalcode,buildertek__Grand_Total__c,buildertek__Total__c,buildertek__Status__c,buildertek__Opportunity__r.Name,buildertek__Opportunity__r.buildertek__Notes__c,buildertek__Opportunity__r.Account.Name,buildertek__Opportunity__c,buildertek__Opportunity__r.AccountId,buildertek__Opportunity__r.OwnerId from buildertek__Quote__c  where buildertek__Opportunity__c = :quoteoppoids and buildertek__Status__c = 'Customer Accepted'];
                    list<buildertek__Quote__c> updateCustomerAcceptedQuoteList = new List<buildertek__Quote__c>();
                    decimal totalquoteamount = 0;
                    if(oppquotereclist.size() > 0){
                        //decimal totalquoteamount = 0;
                        for(buildertek__Quote__c qutrec : oppquotereclist){
                            totalquoteamount += qutrec.buildertek__Grand_Total__c;
                            totalamount += qutrec.buildertek__Total__c;
                        }
                        Set<Id> contactIds= new Set<Id>();
                        contactIds.add(oppquotereclist[0].buildertek__Opportunity__c); //include all the contact ids for which you need to retrieve content note
                        system.debug(contactIds);
                        Set<Id> contentDocumentIds1 = new Set<Id>();
                        //get all contentdocumentids so that you can query on contentnote
                        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :contactIds]){
                            contentDocumentIds1.add(conDoc.ContentDocumentId);
                        }
                        system.debug('contentDocumentIds'+contentDocumentIds1);
                        //get all the content notes using contentDocumentIds
                        List<ContentNote> contentNotes = [SELECT Id, Title,TextPreview,Content from ContentNote where Id In: contentDocumentIds1];
                        system.debug('contentNotes'+contentNotes.size());
                        system.debug('contentNotes'+contentNotes);
                        //String[] tmp1 = New String[]{};
                        //String[] tmp2 = New String[]{};
                        String[] tmp  = New String[]{};
                            // String Title, TextPreview;
                            string allnotes = '';
                        String TextPreview1;
                        for(ContentNote c : contentNotes){
                            // tmp1.add(c.Title);
                            // tmp2.add(c.TextPreview);
                            tmp.add(c.Title + ' : ' + c.TextPreview);
                        }

                        //  Title = string.join(tmp1 ,',' );
                        // TextPreview = string.join(tmp2,',');
                        TextPreview1 = string.join(tmp,'\n\n');
                        system.debug('TextPreview1'+TextPreview1);
                        set<string> oppoids = new set<string>();
                        list<buildertek__Project__c> projectlst = new list<buildertek__Project__c>();
                        buildertek__Project__c project = new buildertek__Project__c();
                       /* buildertek__Common_Files__c cf=new buildertek__Common_Files__c();
                        cf.Name='Common File';
                        insert cf; */
                        list<Opportunity> opplst = [Select Id, Name,AccountId,
                                                    Account.buildertek__Email_Address__c,
                                                    Account.phone,
                                                    Account.Name,
                                                    Account.Billingcity,
                                                    Account.Billingstate,
                                                    Account.Billingcountry,
                                                    Account.Billingstreet,
                                                    Account.Billingpostalcode
                                                    from Opportunity where Id IN : oppoids  and AccountId != null];
                        system.debug('&&'+opplst);
                        system.debug('&&'+oppquotereclist[0].buildertek__Opportunity__r.AccountId);
                        if(oppquotereclist[0].buildertek__Opportunity__c !=null && oppquotereclist[0].buildertek__Opportunity__r.AccountId != null){
                            System.debug('----------------------------test----------------------------------------');
                            project.Name = oppquotereclist[0].buildertek__Opportunity__r.Account.Name;
                            project.buildertek__Account__c = oppquotereclist[0].buildertek__Opportunity__r.AccountId;
                            project.buildertek__Customer__c = oppquotereclist[0].buildertek__Opportunity__r.AccountId;
                            project.buildertek__City__c =  oppquotereclist[0].buildertek__Opportunity__r.Account.Billingcity;
                            // project.buildertek__County__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingcountry;
                            project.buildertek__State__c =  oppquotereclist[0].buildertek__Opportunity__r.Account.Billingstate;
                            project.buildertek__Address__c =  oppquotereclist[0].buildertek__Opportunity__r.Account.Billingstreet;
                            project.buildertek__Zip__c =  oppquotereclist[0].buildertek__Opportunity__r.Account.Billingpostalcode;

                            /* Createing Common File Record */

                            // cf.Name= oppquotereclist[0].buildertek__Opportunity__r.Account.Name;

                            //System.debug('-----------------------------------CF Record----------------------------'+cf);
                            /*--------------END-------------*/

                        }else{

                            if(oppquotereclist[0].buildertek__Opportunity__r.Name !=null){
                                project.Name = oppquotereclist[0].buildertek__Opportunity__r.Name;

                            }
                        }
                        if(totalquoteamount !=null){
                            // project.buildertek__Contract_Amount__c = totalquoteamount;
                        }
                        project.buildertek__Notes__c = TextPreview1;
                        if(oppquotereclist[0].buildertek__Opportunity__c !=null){
                            project.buildertek__Opportunity__c =  oppquotereclist[0].buildertek__Opportunity__c;
                        }
                        project.buildertek__Quote_Owner__c = quoteOwner;

                        //Checking selected opportunity owner active or not
                        List<User> opportunityOwnerList = [SELECT Id, Name, IsActive FROM User WHERE Id =: oppquotereclist[0].buildertek__Opportunity__r.OwnerId AND IsActive = True LIMIT 1];

                        //Checking selected User from configiration was active or not
                        List<User> configurationDefaultProjectOwnerUserList = New List<User>();
                        if(adminInterfaceNodeConfigurations[0].buildertek__Default_Project_Owner__c != null){
                            configurationDefaultProjectOwnerUserList = [SELECT Id, Name, IsActive FROM User WHERE Id =: adminInterfaceNodeConfigurations[0].buildertek__Default_Project_Owner__c AND IsActive = True LIMIT 1];
                        }

                        if(!opportunityOwnerList.isEmpty()){
                            project.OwnerId = oppquotereclist[0].buildertek__Opportunity__r.OwnerId;
                        }
                        else if(!configurationDefaultProjectOwnerUserList.isEmpty()){
                            project.OwnerId = configurationDefaultProjectOwnerUserList[0].Id;
                        }
                        else{
                            project.OwnerId = UserInfo.getUserId();
                        }

                      //  System.debug('-----------------------------------CF Record----------------------------'+cf);
                      //  project.buildertek__Project_File__c=cf.Id;
                        if(adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c != null){
                        	project.buildertek__Pictures__c = adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c+'/lightning/r/buildertek__Quote__c/'+oppquotereclist[0].Id+'/related/AttachedContentDocuments/view';
                        }
                        //project.buildertek__Pictures__c =
                        if(oppquotereclist[0].buildertek__Is_Customer_Accepted__c == false){
                            insert project;

                           // System.debug('-----------------------------------CF Record----------------------------'+cf);
                            oppquotereclist[0].buildertek__Is_Customer_Accepted__c = true  ;
                            buildertek__Quote__c updateCustomerAcceptedQuote = new buildertek__Quote__c();
                            updateCustomerAcceptedQuote.buildertek__Is_Customer_Accepted__c = true;
                            updateCustomerAcceptedQuote.Id = oppquotereclist[0].Id;
                            updateCustomerAcceptedQuoteList.add(updateCustomerAcceptedQuote);
                        }

                        if(updateCustomerAcceptedQuoteList.size()>0){
                            QuoteTriggerHandler.blnSkipQuoteUpdateTrigger = true;
                            update updateCustomerAcceptedQuoteList;
                            QuoteTriggerHandler.blnSkipQuoteUpdateTrigger = true;

                        }

                        List<ContentNote> contentNoteslist = new List<ContentNote>();
                        for(ContentNote c : contentNotes){
                            ContentNote noteRec = new ContentNote();
                            noteRec.Title = c.Title;
                            noteRec.Content = c.Content;
                            contentNoteslist.add(noteRec);
                        }
                      //  System.debug('Common File Record Id----------------------------'+cf.Id);
                        System.debug('Common File Record Id----------------------------'+contentNoteslist.size());
                        if(contentNoteslist.size() > 0){
                           // System.debug('Common File Record Id----------------------------'+cf.Id);
                            insert contentNoteslist;
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentNote> contentVersionList = [SELECT Id FROM ContentNote WHERE Id IN: contentNoteslist];
                            for(ContentNote cv : contentVersionList){
                                contentDocumentIds.add(cv.Id);
                            }
                            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            //create ContentDocumentLink  record to link with parentId
                            if(project.id != null){
                                for(ContentDocument cd : conDocList){
                                    ContentDocumentLink objCntDocLink = new ContentDocumentLink();
                                    objCntDocLink.LinkedEntityId = project.id; // Specify your parent Id
                                    objCntDocLink.ContentDocumentId = cd.Id;  //Content Note Id
                                    objCntDocLink.shareType = 'V'; // Specify your sharing type
                                    cdlList.add(objCntDocLink);
                                }
                                insert cdlList;
                            }
                         //   System.debug('Common File Record Id----------------------------'+cf.Id);
                        }

                        List<buildertek__Quote__c> quoteList = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c,
                                                                buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c,
                                                                buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c,
                                                                buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c,
                                                                buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c,
                                                                buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c,
                                                                buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c,buildertek__OppToQuoteId__c, buildertek__Ship_To_Zip_Code__c,
                                                                buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c,buildertek__Opportunity__c,
                                                                buildertek__SignatureBase64__c,buildertek__Bill_To_Cell_Phone__c,buildertek__Bill_To_Email_Address__c,buildertek__Customer_Accepted_Date__c,
                                                                buildertek__Date_Accepted_by_Customer__c,buildertek__Date_Sent_To_Customer__c,buildertek__Type__c,buildertek__Notes__c
                                                                from buildertek__Quote__c
                                                                where buildertek__Opportunity__c =: quoteoppoids and (buildertek__Status__c = 'Approved' OR buildertek__Status__c = 'Customer Accepted')];

                        List<buildertek__Quote__c> quoteToUpdateList = new List<buildertek__Quote__c>();
                        for(buildertek__Quote__c quote: quoteList){
                            quoteIdsList.add(quote.Id);

                            buildertek__Quote__c quoteToUpdate = new buildertek__Quote__c();
                            //quoteToUpdate.Id = quote.Id;
                            quoteToUpdate.Name = quote.Name  ;
                            quoteToUpdate.buildertek__Description__c = quote.buildertek__Description__c  ;
                            quoteToUpdate.buildertek__Status__c = quote.buildertek__Status__c ;
                            quoteToUpdate.buildertek__Project__c = project.Id;
                            quoteToUpdate.buildertek__OppToQuoteId__c = quote.Id;
                            quoteToUpdate.buildertek__Primary__c  = quote.buildertek__Primary__c;
                            quoteToUpdate.buildertek__Markup__c  = quote.buildertek__Markup__c;
                            quoteToUpdate.buildertek__Shipping_and_Handling__c = quote.buildertek__Shipping_and_Handling__c ;
                            quoteToUpdate.buildertek__Profit_Margin__c  = quote.buildertek__Profit_Margin__c ;
                            quoteToUpdate.buildertek__Payment_Terms__c  =quote.buildertek__Payment_Terms__c  ;
                            quoteToUpdate.buildertek__Discount__c = quote.buildertek__Discount__c ;
                            quoteToUpdate.buildertek__Tax__c = quote.buildertek__Tax__c ;
                            quoteToUpdate.buildertek__Expires_On__c = quote.buildertek__Expires_On__c ;
                            quoteToUpdate.buildertek__Sales_Rep__c = quote.buildertek__Sales_Rep__c ;
                            quoteToUpdate.buildertek__Primary_Contact__c = quote.buildertek__Primary_Contact__c ;
                            quoteToUpdate.buildertek__Start_Date__c  = quote.buildertek__Start_Date__c ;
                            quoteToUpdate.buildertek__Bill_To_Name__c = quote.buildertek__Bill_To_Name__c ;
                            quoteToUpdate.buildertek__Bill_To_Street__c = quote.buildertek__Bill_To_Street__c;
                            quoteToUpdate.buildertek__Bill_To_City__c = quote.buildertek__Bill_To_City__c ;
                            quoteToUpdate.buildertek__Bill_To_State__c  = quote.buildertek__Bill_To_State__c;
                            quoteToUpdate.buildertek__Bill_To_Country__c  = quote.buildertek__Bill_To_Country__c ;
                            quoteToUpdate.buildertek__Ship_To_Name__c  = quote.buildertek__Ship_To_Name__c ;
                            quoteToUpdate.buildertek__Ship_To_Street__c = quote.buildertek__Ship_To_Street__c ;
                            quoteToUpdate.buildertek__Ship_To_City__c  = quote.buildertek__Ship_To_City__c;
                            quoteToUpdate.buildertek__Ship_To_State__c = quote.buildertek__Ship_To_State__c;
                            quoteToUpdate.buildertek__Group_Line_Items__c  = quote.buildertek__Group_Line_Items__c ;
                            quoteToUpdate.buildertek__Ship_To_Zip_Code__c = quote.buildertek__Ship_To_Zip_Code__c ;
                            quoteToUpdate.buildertek__Email_Body__c = quote.buildertek__Email_Body__c;
                            quoteToUpdate.buildertek__Email_Subject__c  = quote.buildertek__Email_Subject__c ;
                            quoteToUpdate.buildertek__Ship_To_Country__c = quote.buildertek__Ship_To_Country__c ;
                            quoteToUpdate.buildertek__Bill_To_Zip_Code__c  = quote.buildertek__Bill_To_Zip_Code__c ;
                            quoteToUpdate.buildertek__SignatureBase64__c = quote.buildertek__SignatureBase64__c;
                            quoteToUpdate.buildertek__Bill_To_Cell_Phone__c = quote.buildertek__Bill_To_Cell_Phone__c;
                            quoteToUpdate.buildertek__Bill_To_Email_Address__c = quote.buildertek__Bill_To_Email_Address__c;
                            quoteToUpdate.buildertek__Customer_Accepted_Date__c = quote.buildertek__Customer_Accepted_Date__c;
                            quoteToUpdate.buildertek__Date_Accepted_by_Customer__c = quote.buildertek__Date_Accepted_by_Customer__c;
                            quoteToUpdate.buildertek__Date_Sent_To_Customer__c = quote.buildertek__Date_Sent_To_Customer__c;
                            quoteToUpdate.buildertek__Type__c = quote.buildertek__Type__c ;
                            quoteToUpdate.buildertek__Notes__c = quote.buildertek__Notes__c ;
                           // quoteToUpdate.buildertek__Quote_File__c=cf.Id;
                            if(adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c != null){
                           	 quoteToUpdate.buildertek__Pictures__c = adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c+'/lightning/r/buildertek__Quote__c/'+quote.Id+'/related/AttachedContentDocuments/view';
                            }
                            quoteToUpdateList.add(quoteToUpdate);
                        }
                        system.debug('quoteToUpdateList --------> '+quoteToUpdateList[0].buildertek__Quote_File__c);
                        if(quoteToUpdateList.size() > 0){
                            insert quoteToUpdateList;
                        }

                        list<buildertek__Quote_Item__c> quoteItemList = [SELECT Id,
                                                                         Name,
                                                                         buildertek__Item_Name__c,
                                                                         buildertek__Description__c,
                                                                         buildertek__Quantity__c,
                                                                         buildertek__Unit_Price__c,
                                                                         buildertek__Total_Cost__c,
                                                                         buildertek__Quote__c,
                                                                         buildertek__Quote__r.buildertek__Opportunity__c,
                                                                         buildertek__Cost_Code__c,
                                                                         buildertek__Auto_Number__c,
                                                                         buildertek__Product__c,
                                                                         buildertek__Grouping__c,
                                                                         buildertek__UOM__c,
                                                                         buildertek__Vendor__c,
                                                                         buildertek__Markup__c,
                                                                         buildertek__Unit_Cost__c,
                                                                         buildertek__List_Total__c,
                                                                         buildertek__Net_Unit__c,
                                                                         buildertek__Applied_Markup__c,
                                                                         buildertek__Net_Total__c,
                                                                         buildertek__MFG_Discount__c,
                                                                         buildertek__List_Unit_Price__c,
                                                                         buildertek__Pricing_Method__c,
                                                                         buildertek__Discount__c,
                                                                         buildertek__Profit_Margin__c,
                                                                         buildertek__Net_Total_Price__c,
                                                                         buildertek__Notes__c,
                                                                         buildertek__Additional_Discount__c,
                                                                         buildertek__Purchase_Order__c
                                                                         FROM buildertek__Quote_Item__c
                                                                         WHERE buildertek__Quote__c IN: quoteIdsList and
                                                                         buildertek__Quote__r.buildertek__Opportunity__c =:quoteoppoids and
                                                                         buildertek__Status__c = 'Accept'];

                        system.debug('quoteToUpdateList --->'+quoteToUpdateList.size());
                        //insert quote items
                        if(quoteToUpdateList !=null){

                            list<buildertek__Quote_Item__c> quoteitemreclst = new list<buildertek__Quote_Item__c>();
                            for(buildertek__Quote_Item__c quoteitemrecs : quoteItemList){
                                for(buildertek__Quote__c quoteid : quoteToUpdateList){
                                    system.debug('----'+quoteitemrecs.buildertek__Quote__c+'existquoteid---'+quoteid.buildertek__OppToQuoteId__c);
                                    if(quoteid.buildertek__OppToQuoteId__c == quoteitemrecs.buildertek__Quote__c){
                                        buildertek__Quote_Item__c quoteitem =  new buildertek__Quote_Item__c();
                                        quoteitem.Name = quoteitemrecs.Name;
                                        quoteitem.buildertek__Item_Name__c =quoteitemrecs.buildertek__Item_Name__c;
                                        quoteitem.buildertek__Description__c = quoteitemrecs.buildertek__Description__c;
                                        quoteitem.buildertek__Quantity__c = quoteitemrecs.buildertek__Quantity__c;
                                        quoteitem.buildertek__Unit_Price__c =  quoteitemrecs.buildertek__Unit_Price__c;
                                        quoteitem.buildertek__Quote__c = quoteid.Id;
                                        quoteitem.buildertek__Cost_Code__c =  quoteitemrecs.buildertek__Cost_Code__c ;
                                        quoteitem.buildertek__Product__c =  quoteitemrecs.buildertek__Product__c ;
                                        quoteitem.buildertek__Grouping__c = quoteitemrecs.buildertek__Grouping__c ;
                                        quoteitem.buildertek__UOM__c = quoteitemrecs.buildertek__UOM__c;
                                        quoteitem.buildertek__Vendor__c = quoteitemrecs.buildertek__Vendor__c ;
                                        quoteitem.buildertek__Markup__c = quoteitemrecs.buildertek__Markup__c ;
                                        quoteitem.buildertek__Unit_Cost__c = quoteitemrecs.buildertek__Unit_Cost__c ;
                                        quoteitem.buildertek__Applied_Markup__c = quoteitemrecs.buildertek__Applied_Markup__c ;
                                        quoteitem.buildertek__Pricing_Method__c = quoteitemrecs.buildertek__Pricing_Method__c ;
                                        quoteitem.buildertek__Notes__c = quoteitemrecs.buildertek__Notes__c;
                                        quoteitem.buildertek__Purchase_Order__c = quoteitemrecs.buildertek__Purchase_Order__c;
                                        quoteitem.buildertek__Additional_Discount__c = quoteitemrecs.buildertek__Additional_Discount__c;
                                        quoteitemreclst.add(quoteitem) ;
                                    }
                                }
                            }
                            system.debug('quoteitemreclst---size--'+quoteitemreclst.Size()+'quoteitemreclst--->'+quoteitemreclst);
                            if(quoteitemreclst.size() >0 ){
                                insert quoteitemreclst;
                            }
                        }
                        list<buildertek__Proposal_Images__c> quoteImageList = [SELECT Id,
                                                                               Name,buildertek__Base_URL__c,
                                                                               buildertek__Contact__c,buildertek__Contract__c,
                                                                               buildertek__Description__c,buildertek__Image__c,
                                                                               buildertek__Proposal__c
                                                                               FROM buildertek__Proposal_Images__c
                                                                               WHERE buildertek__Proposal__c IN: quoteIdsList];
                        if(quoteImageList !=null){
                            list<buildertek__Proposal_Images__c> contractImagereclst = new list<buildertek__Proposal_Images__c>();
                            for(buildertek__Proposal_Images__c quoteimagerecs : quoteImageList){
                                for(buildertek__Quote__c quoteid : quoteToUpdateList){
                                    if(quoteid.buildertek__OppToQuoteId__c == quoteimagerecs.buildertek__Proposal__c){

                                        buildertek__Proposal_Images__c quoteimage =  new buildertek__Proposal_Images__c();
                                        // quoteimage.Name = quoteimagerecs.Name;
                                        quoteimage.buildertek__Base_URL__c =quoteimagerecs.buildertek__Base_URL__c;
                                        quoteimage.buildertek__Contact__c = quoteimagerecs.buildertek__Contact__c;
                                        quoteimage.buildertek__Contract__c = quoteimagerecs.buildertek__Contract__c;
                                        quoteimage.buildertek__Description__c =  quoteimagerecs.buildertek__Description__c;
                                        quoteimage.buildertek__Proposal__c = quoteid.Id;
                                        quoteimage.buildertek__Image__c =  quoteimagerecs.buildertek__Image__c ;
                                        contractImagereclst.add(quoteimage) ;
                                    }
                                }
                            }
                            if(contractImagereclst.size() >0 ){
                                insert contractImagereclst;
                            }
                        }
                      /* transient set<Id> contentDocIDList = new set<Id>();
                        Map<Id, Id> contentdocMap = new Map<Id, Id>();
                        list<ContentDocumentLink> ContentDocumentLinklist = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility
                                                                             FROM ContentDocumentLink WHERE LinkedEntityId IN: quoteIdsList];
                        for(ContentDocumentLink conDocLink : ContentDocumentLinklist){
                            contentDocIDList.add(conDocLink.ContentDocumentId);
                            contentdocMap.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);
                            system.debug('contentDocIDList'+contentDocIDList);
                        }
                        transient List<ContentVersion> VersionList = new List<ContentVersion>();
                        transient List<ContentVersion> attachlist = new List<ContentVersion>();
                        attachlist = [select Title, Description, FileType,Owner.Name, VersionNumber,VersionData,CreatedDate,PathOnClient,FileExtension,ContentDocumentId from ContentVersion
                                      where ContentDocumentId in :contentDocIDList AND IsLatest = true];
                        List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                        SET<Id> quoteIds = new SET<Id>();
                        for(buildertek__Quote__c quoteRec : quoteToUpdateList)
                        {
                            quoteIds.add(quoteRec.Id);
                            for(ContentVersion objIndividualAttachment : attachlist)
                            {
                                if(contentdocMap.containsKey(objIndividualAttachment.ContentDocumentId)){
                                    if(quoteRec.buildertek__OppToQuoteId__c == contentdocMap.get(objIndividualAttachment.ContentDocumentId) ){
                                        ContentVersion con= new contentversion();
                                        con.ContentLocation = 'S';
                                        con.PathOnClient = objIndividualAttachment.PathOnClient;
                                        //con.VersionData = blob.valueOf('/services/data/v53.0/sobjects/ContentVersion/'+objIndividualAttachment.Id+'/VersionData');//objIndividualAttachment.VersionData;
                                        con.VersionData = objIndividualAttachment.VersionData;
                                        con.Title = objIndividualAttachment.Title;
                                        contentVersionToInsert.add(con);

                                    }
                                }
                            }
                        }
                        if(contentVersionToInsert.size() > 0){
                            insert contentVersionToInsert;
                            system.debug('contentVersionToInsert size -------> '+contentVersionToInsert.size());
                            system.debug('contentVersionToInsert -------> '+contentVersionToInsert);
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                            for(ContentVersion cv : contentVersionList){
                                contentDocumentIds.add(cv.ContentDocumentId);
                            }

                            map<Id,Id> lstContentDocumentlinkmap = new map<Id,Id>();
                            List<ContentDocumentLink> lstContentDocumentlink = [SELECT ContentDocumentId, LINKEDENTITYID
                                                                                FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIds];

                            for(ContentDocumentLink cdlnk : lstContentDocumentlink){
                                lstContentDocumentlinkmap.put(cdlnk.LINKEDENTITYID, cdlnk.LINKEDENTITYID);
                            }
                            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            //for(String quoteId : quoteIds){
                            //system.debug('quoteId ------> '+quoteId);
                            for(ContentDocument cd : conDocList){
                                system.debug('cf.Id --------> '+lstContentDocumentlinkmap.get(cf.Id));
                                if(lstContentDocumentlinkmap.get(cf.Id) == null){
                                    ContentDocumentLink CDL = new ContentDocumentLink();
                                    CDL .ContentDocumentId = cd.Id;
                                    CDL .LinkedEntityId = cf.Id;
                                    CDL .ShareType = 'I';
                                    CDL .Visibility = 'AllUsers';
                                    cdlList.add(CDL);
                                }

                            }
                            //}
                            if(cdlList.size() > 0){
                                insert cdlList;
                                system.debug('cdlList size -------> '+cdlList.size());
                                system.debug('cdlList -------> '+cdlList);
                            }


                        }*/
                        Boolean isCreateContract = false;
                        Boolean isCreateBudget = false;
                        List<Id> createdContractCustomerToAccess = new List<Id>();
                        List<Id> createdBudgetCustomerToAccess = new List<Id>();
                        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeCon = [Select Id,buildertek__Change_Order_Configuration__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Create Contract on Quote Acceptance' LIMIT 1];
                        if(adminInterfaceNodeCon.size()>0){
                            isCreateContract = adminInterfaceNodeCon[0].buildertek__Change_Order_Configuration__c;
                        }
                        for(buildertek__Quote__c newquote : quoteToUpdateList ){
                            if(isCreateContract && newquote.Status__c == 'Customer Accepted'){
                                createdContractCustomerToAccess.add(newquote.Id);
                            }
                        }
                        if(!createdContractCustomerToAccess.isEmpty()) {
                            futureContoller.createContractsFromQuote(createdContractCustomerToAccess);
                            //BudgetContractCreateHelper.createContractsFromQuote(createdContractCustomerToAccess);
                        }
                        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodebudgetConfiguration = [Select Id,buildertek__Create_Budget_on_Quote_Acceptance__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Budget Configuration' LIMIT 1];
                        system.debug('&***'+adminInterfaceNodebudgetConfiguration);
                        if(adminInterfaceNodebudgetConfiguration.size()>0){
                            system.debug('**************'+adminInterfaceNodebudgetConfiguration);
                            isCreateBudget = adminInterfaceNodebudgetConfiguration[0].buildertek__Create_Budget_on_Quote_Acceptance__c;
                        }
                        for(buildertek__Quote__c newqte : quoteToUpdateList ){
                            if(isCreateBudget && newqte.Status__c == 'Customer Accepted'){
                                createdBudgetCustomerToAccess.add(newqte.Id);
                            }
                        }
                        if(!createdBudgetCustomerToAccess.isEmpty()) {
                            futureContoller.createBudgetFromQuote(createdBudgetCustomerToAccess);
                            //BudgetContractCreateHelper.createBudgetFromQuote(createdBudgetCustomerToAccess);
                        }
                    }
                }
            }
        }
        //Once the Quote Status is set to Custome Accepted we need to go back to the Opportunity and set the status to Closed Won
        set<Id> oppoids = new set<Id>();
        for(buildertek__Quote__c qutrec : updatedQuotes){
            if(qutrec.buildertek__Status__c == 'Customer Accepted' && qutrec.buildertek__Opportunity__c !=null){
                oppoids.add(qutrec.buildertek__Opportunity__c);
            }
        }
        system.debug('oppoids----'+oppoids.size());
        if(oppoids.size()>0){
            list<opportunity> opprecstagelst = new list<opportunity> ();
            system.debug('oppreclstbefore---'+[select id,name,StageName,buildertek__checkOpptyStage__c,Amount from Opportunity where Id IN : oppoids]);
            list<opportunity> oppreclst = [select id,name,StageName,buildertek__checkOpptyStage__c,Amount from Opportunity where Id IN : oppoids];
            system.debug('oppreclst---'+oppreclst.size());
            if(!oppreclst.isEmpty()){
                for(opportunity opprec : oppreclst){
                    if(opprec.StageName != 'Closed Won' && opprec.buildertek__checkOpptyStage__c !='Project Created' ){
                        opprec.buildertek__checkOpptyStage__c = 'No Project';
                        opprec.StageName = 'Closed Won';
                        if(adminInterfaceNodeConfigurations.size()>0 ){
                            if(adminInterfaceNodeConfigurations[0].buildertek__Update_the_Opp_Amount__c == true){
                                system.debug('&&&&&&&&&&&'+opprec.Amount);
                                if(opprec.Amount != null && totalamount !=null){
                                    totalamount = totalamount + opprec.Amount ;
                                    opprec.Amount = totalamount;
                                }else if(opprec.Amount == null && totalamount !=null){
                                    opprec.Amount = totalamount;
                                }
                            }
                        }

                        opprecstagelst.add(opprec);
                    }

                }
            }
            if(opprecstagelst.size() > 0) {
                update opprecstagelst;
            }
        }
        //--------------------------end--------------------------------

    }

    public void OnBeforeUpdate(Quote__c[] newQuotes, Map<ID, Quote__c> newQuotesMap){

    }

    public void OnAfterDelete(Quote__c[] oldQuotes){
    }

}