/*
 Developed By: Harika Ch
 Date: 25/02/2021
 */
public without sharing class OpportunityTriggerHandler{
    public static Boolean isFirstTime = true;
    public void onBeforeUpdateCloseWon(Opportunity[] newOpportunity, Opportunity[] oldOpportunity, Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap){
        system.debug(newOpportunityMap.keySet());
        system.debug(oldOpportunityMap.keySet());
        Set<Id> updateOpps = new Set<Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        String type = 'Opportunity';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type) ;
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        if (fieldMap.keySet().contains('buildertek__checkopptystage__c')){
            for (Opportunity oppRec : newOpportunity){
                system.debug(newOpportunityMap.get(oppRec.Id).StageName);
                system.debug(oldOpportunityMap.get(oppRec.Id).StageName);
                system.debug(oppRec.buildertek__checkOpptyStage__c);
                if (oppRec.StageName == 'Closed Won' && oldOpportunityMap.get(oppRec.Id).StageName != oppRec.StageName && oppRec.buildertek__checkOpptyStage__c != 'Project Created'){

                    oppRec.buildertek__checkOpptyStage__c = 'No Project';
                    system.debug(oppRec.buildertek__checkOpptyStage__c);
                    updateOpps.add(oppRec.Id);
                }

            }

        }

        // system.debug(oldOpportunityMap.get(newOpportunityMap.keySet()[0]).StageName);
    }

    public void afterUpdate(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap){
        //* Added logic for updating opp details to the BT quote e.g. Oppty Account Name, Description
        System.debug('in after update method *&*&*&');
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
        List<buildertek__Quote__c> qtListToUpdate = new List<buildertek__Quote__c>();
        quoteList = [SELECT Id, Name, buildertek__Description__c, buildertek__Opportunity__c, buildertek__Opportunity_Account_Name__c
                     FROM buildertek__Quote__c
                     WHERE buildertek__Opportunity__c IN:newOpportunityMap.keySet()];
        if (quoteList.size() > 0){
            for (buildertek__Quote__c qt : quoteList){
                Opportunity opp = newOpportunityMap.get(qt.buildertek__Opportunity__c);
                Opportunity oldOpp = oldOpportunityMap.get(qt.buildertek__Opportunity__c);
                if (oldOpp.Description != opp.Description){
                    qt.buildertek__Description__c = opp.Description;
                    qtListToUpdate.add(qt);
                }
            }
            if (qtListToUpdate.size() > 0){
                update qtListToUpdate;
            }
        }
    }

    public void OnBeforeUpdate(Opportunity[] newOpportunity, Map<Id, Opportunity> oldOpportunityMap){
        //Create Project from Opportunity Closed Won
        Boolean createProject = true;
        System.debug('calling method');
        set<Id> oppoids = new set<Id>();
        set<Id> quoteIdsList = new set<Id>();
        for (Opportunity qutrec : newOpportunity){
            System.debug('qutrec.StageName ' + qutrec.StageName);
            System.debug('oldOpportunityMap.get(qutrec.id).StageName ' + oldOpportunityMap.get(qutrec.id).StageName);
            if (qutrec.StageName == 'Closed Won' && oldOpportunityMap.get(qutrec.id).StageName != qutrec.StageName){
                oppoids.add(qutrec.id);
            }
        }
        System.debug('oppoids.size() ' + oppoids.size());
        if (oppoids.size() > 0){
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Create_Project_from_Opportunity__c
                                                                                                        from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                        WHERE Name = :'Quote Configuration' and buildertek__Create_Project_from_Opportunity__c != false
                                                                                                        limit 1];

            if (adminInterfaceNodeConfigurations.size() > 0){
                if (adminInterfaceNodeConfigurations[0].buildertek__Create_Project_from_Opportunity__c == true){
                    list<buildertek__Quote__c> oppquotereclist = [select id, name, buildertek__Opportunity__r.OwnerId, buildertek__Opportunity__r.Account.Billingpostalcode, buildertek__Opportunity__r.Account.Billingstreet, buildertek__Opportunity__r.Account.Billingstate, buildertek__Opportunity__r.Account.Billingcity, buildertek__Grand_Total__c, buildertek__Status__c, buildertek__Opportunity__r.Name, buildertek__Opportunity__r.Account.Name, buildertek__Opportunity__r.buildertek__Notes__c, buildertek__Opportunity__c, buildertek__Opportunity__r.AccountId
                                                                  from buildertek__Quote__c
                                                                  where buildertek__Opportunity__c = :oppoids and buildertek__Status__c = 'Customer Accepted'];
                    list<buildertek__Project__c> projectlst = new list<buildertek__Project__c>();
                    decimal totalquoteamount = 0;
                    if (oppquotereclist.size() > 0){
                        System.debug('in if condition');
                        for (buildertek__Quote__c qutrec : oppquotereclist){
                            totalquoteamount += qutrec.buildertek__Grand_Total__c;
                        }
                        Set<Id> contactIds = new Set<Id>();
                        contactIds.add(oppquotereclist[0].buildertek__Opportunity__c); //include all the contact ids for which you need to retrieve content note
                        Set<Id> contentDocumentIds1 = new Set<Id>();
                        for (ContentDocumentLink conDoc : [SELECT ContentDocumentId
                                                           FROM ContentDocumentLink
                                                           WHERE LinkedEntityId IN:contactIds]){
                            contentDocumentIds1.add(conDoc.ContentDocumentId);
                        }
                        List<ContentNote> contentNotes = [SELECT Id, Title, TextPreview, Content
                                                          from ContentNote
                                                          where Id In:contentDocumentIds1];
                        String[] tmp = New String[]{  };
                        string allnotes = '';
                        String TextPreview1;
                        for (ContentNote c : contentNotes){
                            tmp.add(c.Title + ' : ' + c.TextPreview);
                        }
                        TextPreview1 = string.join(tmp, '\n\n');
                        buildertek__Project__c project = new buildertek__Project__c();
                        if (oppquotereclist[0].buildertek__Opportunity__r.AccountId != null){
                            project.Name = oppquotereclist[0].buildertek__Opportunity__r.Account.Name;
                            project.buildertek__Account__c = oppquotereclist[0].buildertek__Opportunity__r.AccountId;
                            project.buildertek__Customer__c = oppquotereclist[0].buildertek__Opportunity__r.AccountId;
                            project.buildertek__City__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingcity;
                            // project.buildertek__County__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingcountry;
                            project.buildertek__State__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingstate;
                            project.buildertek__Address__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingstreet;
                            project.buildertek__Zip__c = oppquotereclist[0].buildertek__Opportunity__r.Account.Billingpostalcode;
                        } else{
                            if (oppquotereclist[0].buildertek__Opportunity__r.Name != null){
                                project.Name = oppquotereclist[0].buildertek__Opportunity__r.Name;
                            }
                        }
                        if (totalquoteamount != null){
                            //project.buildertek__Contract_Amount__c = totalquoteamount;
                        }
                        if (oppquotereclist[0].buildertek__Opportunity__c != null){
                            project.buildertek__Opportunity__c = oppquotereclist[0].buildertek__Opportunity__c;
                        }
                        /*if(oppquotereclist[0].buildertek__Opportunity__r.buildertek__Notes__c !=null){
                         project.buildertek__Notes__c = oppquotereclist[0].buildertek__Opportunity__r.buildertek__Notes__c;
                         }*/
                        if (TextPreview1 != null){
                            project.buildertek__Notes__c = TextPreview1;
                        }
                        project.OwnerId = oppquotereclist[0].buildertek__Opportunity__r.OwnerId;
                        System.debug('project details ' + project);
                        insert project;
                        createProject = false;
                        List<ContentNote> contentNoteslist = new List<ContentNote>();
                        for (ContentNote c : contentNotes){
                            ContentNote noteRec = new ContentNote();
                            noteRec.Title = c.Title;
                            noteRec.Content = c.Content;
                            contentNoteslist.add(noteRec);
                        }
                        if (contentNoteslist.size() > 0){
                            insert contentNoteslist;
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentNote> contentVersionList = [SELECT Id
                                                                    FROM ContentNote
                                                                    WHERE Id IN:contentNoteslist];
                            for (ContentNote cv : contentVersionList){
                                contentDocumentIds.add(cv.Id);
                            }
                            List<ContentDocument> conDocList = [SELECT Id, Title
                                                                FROM ContentDocument
                                                                WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            //create ContentDocumentLink  record to link with parentId
                            if (project.id != null){
                                for (ContentDocument cd : conDocList){
                                    ContentDocumentLink objCntDocLink = new ContentDocumentLink();
                                    objCntDocLink.LinkedEntityId = project.id; // Specify your parent Id
                                    objCntDocLink.ContentDocumentId = cd.Id;  //Content Note Id
                                    objCntDocLink.shareType = 'V'; // Specify your sharing type
                                    cdlList.add(objCntDocLink);
                                }
                                insert cdlList;
                            }

                        }

                        List<buildertek__Quote__c> quoteList;
                        quoteList = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c, buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c, buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c, buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c, buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c, buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c, buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c, buildertek__OppToQuoteId__c, buildertek__Ship_To_Zip_Code__c, buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c, buildertek__Opportunity__c, buildertek__SignatureBase64__c, buildertek__Bill_To_Cell_Phone__c, buildertek__Bill_To_Email_Address__c, buildertek__Customer_Accepted_Date__c, buildertek__Date_Accepted_by_Customer__c, buildertek__Date_Sent_To_Customer__c, buildertek__Type__c, buildertek__Notes__c
                                     from buildertek__Quote__c
                                     where buildertek__Opportunity__c = :oppoids and buildertek__Status__c = 'Customer Accepted'];


                        List<buildertek__Quote__c> quoteToUpdateList = new List<buildertek__Quote__c>();
                        for (buildertek__Quote__c quote : quoteList){
                            quoteIdsList.add(quote.Id);


                            buildertek__Quote__c quoteToUpdate = new buildertek__Quote__c();
                            quoteToUpdate.Name = quote.Name;
                            quoteToUpdate.buildertek__Description__c = quote.buildertek__Description__c;
                            quoteToUpdate.buildertek__Status__c = quote.buildertek__Status__c;
                            quoteToUpdate.buildertek__Project__c = project.Id;
                            quoteToUpdate.buildertek__OppToQuoteId__c = quote.Id;
                            quoteToUpdate.buildertek__Primary__c = quote.buildertek__Primary__c;
                            quoteToUpdate.buildertek__Markup__c = quote.buildertek__Markup__c;
                            quoteToUpdate.buildertek__Shipping_and_Handling__c = quote.buildertek__Shipping_and_Handling__c;
                            quoteToUpdate.buildertek__Profit_Margin__c = quote.buildertek__Profit_Margin__c;
                            quoteToUpdate.buildertek__Payment_Terms__c = quote.buildertek__Payment_Terms__c;
                            quoteToUpdate.buildertek__Discount__c = quote.buildertek__Discount__c;
                            quoteToUpdate.buildertek__Tax__c = quote.buildertek__Tax__c;
                            quoteToUpdate.buildertek__Expires_On__c = quote.buildertek__Expires_On__c;
                            quoteToUpdate.buildertek__Sales_Rep__c = quote.buildertek__Sales_Rep__c;
                            quoteToUpdate.buildertek__Primary_Contact__c = quote.buildertek__Primary_Contact__c;
                            quoteToUpdate.buildertek__Start_Date__c = quote.buildertek__Start_Date__c;
                            quoteToUpdate.buildertek__Bill_To_Name__c = quote.buildertek__Bill_To_Name__c;
                            quoteToUpdate.buildertek__Bill_To_Street__c = quote.buildertek__Bill_To_Street__c;
                            quoteToUpdate.buildertek__Bill_To_City__c = quote.buildertek__Bill_To_City__c;
                            quoteToUpdate.buildertek__Bill_To_State__c = quote.buildertek__Bill_To_State__c;
                            quoteToUpdate.buildertek__Bill_To_Country__c = quote.buildertek__Bill_To_Country__c;
                            quoteToUpdate.buildertek__Ship_To_Name__c = quote.buildertek__Ship_To_Name__c;
                            quoteToUpdate.buildertek__Ship_To_Street__c = quote.buildertek__Ship_To_Street__c;
                            quoteToUpdate.buildertek__Ship_To_City__c = quote.buildertek__Ship_To_City__c;
                            quoteToUpdate.buildertek__Ship_To_State__c = quote.buildertek__Ship_To_State__c;
                            quoteToUpdate.buildertek__Group_Line_Items__c = quote.buildertek__Group_Line_Items__c;
                            quoteToUpdate.buildertek__Ship_To_Zip_Code__c = quote.buildertek__Ship_To_Zip_Code__c;
                            quoteToUpdate.buildertek__Email_Body__c = quote.buildertek__Email_Body__c;
                            quoteToUpdate.buildertek__Email_Subject__c = quote.buildertek__Email_Subject__c;
                            quoteToUpdate.buildertek__Ship_To_Country__c = quote.buildertek__Ship_To_Country__c;
                            quoteToUpdate.buildertek__Bill_To_Zip_Code__c = quote.buildertek__Bill_To_Zip_Code__c;
                            quoteToUpdate.buildertek__SignatureBase64__c = quote.buildertek__SignatureBase64__c;
                            quoteToUpdate.buildertek__Bill_To_Cell_Phone__c = quote.buildertek__Bill_To_Cell_Phone__c;
                            quoteToUpdate.buildertek__Bill_To_Email_Address__c = quote.buildertek__Bill_To_Email_Address__c;
                            quoteToUpdate.buildertek__Customer_Accepted_Date__c = quote.buildertek__Customer_Accepted_Date__c;
                            quoteToUpdate.buildertek__Date_Accepted_by_Customer__c = quote.buildertek__Date_Accepted_by_Customer__c;
                            quoteToUpdate.buildertek__Date_Sent_To_Customer__c = quote.buildertek__Date_Sent_To_Customer__c;
                            quoteToUpdate.buildertek__Type__c = quote.buildertek__Type__c;
                            quoteToUpdate.buildertek__Notes__c = quote.buildertek__Notes__c;


                            quoteToUpdateList.add(quoteToUpdate);

                        }
                        if (quoteToUpdateList.size() > 0){
                            insert quoteToUpdateList;
                        }

                        list<buildertek__Quote_Item__c> quoteItemList = [SELECT Id, Name, buildertek__Item_Name__c, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Cost__c, buildertek__Quote__c, buildertek__Quote__r.buildertek__Opportunity__c, buildertek__Cost_Code__c, buildertek__Auto_Number__c, buildertek__Product__c, buildertek__Grouping__c, buildertek__UOM__c, buildertek__Vendor__c, buildertek__Markup__c, buildertek__Unit_Cost__c, buildertek__List_Total__c, buildertek__Net_Unit__c, buildertek__Applied_Markup__c, buildertek__Net_Total__c, buildertek__MFG_Discount__c, buildertek__List_Unit_Price__c, buildertek__Pricing_Method__c, buildertek__Discount__c, buildertek__Profit_Margin__c, buildertek__Net_Total_Price__c, buildertek__Notes__c, buildertek__Additional_Discount__c, buildertek__Purchase_Order__c
                                                                         FROM buildertek__Quote_Item__c
                                                                         WHERE buildertek__Quote__c IN:quoteIdsList and buildertek__Quote__r.buildertek__Opportunity__c = :oppoids];

                        if (quoteToUpdateList != null){
                            list<buildertek__Quote_Item__c> quoteitemreclst = new list<buildertek__Quote_Item__c>();
                            for (buildertek__Quote_Item__c quoteitemrecs : quoteItemList){
                                for (buildertek__Quote__c quoteid : quoteToUpdateList){
                                    system.debug('----' + quoteitemrecs.buildertek__Quote__c + 'existquoteid---' + quoteid.buildertek__OppToQuoteId__c);
                                    if (quoteid.buildertek__OppToQuoteId__c == quoteitemrecs.buildertek__Quote__c){
                                        buildertek__Quote_Item__c quoteitem = new buildertek__Quote_Item__c();
                                        quoteitem.Name = quoteitemrecs.Name;
                                        quoteitem.buildertek__Item_Name__c = quoteitemrecs.buildertek__Item_Name__c;
                                        quoteitem.buildertek__Description__c = quoteitemrecs.buildertek__Description__c;
                                        quoteitem.buildertek__Quantity__c = quoteitemrecs.buildertek__Quantity__c;
                                        quoteitem.buildertek__Unit_Price__c = quoteitemrecs.buildertek__Unit_Price__c;
                                        quoteitem.buildertek__Quote__c = quoteid.Id;
                                        quoteitem.buildertek__Cost_Code__c = quoteitemrecs.buildertek__Cost_Code__c;
                                        quoteitem.buildertek__Product__c = quoteitemrecs.buildertek__Product__c;
                                        quoteitem.buildertek__Grouping__c = quoteitemrecs.buildertek__Grouping__c;
                                        quoteitem.buildertek__UOM__c = quoteitemrecs.buildertek__UOM__c;
                                        quoteitem.buildertek__Vendor__c = quoteitemrecs.buildertek__Vendor__c;
                                        quoteitem.buildertek__Markup__c = quoteitemrecs.buildertek__Markup__c;
                                        quoteitem.buildertek__Unit_Cost__c = quoteitemrecs.buildertek__Unit_Cost__c;
                                        quoteitem.buildertek__Applied_Markup__c = quoteitemrecs.buildertek__Applied_Markup__c;
                                        quoteitem.buildertek__Pricing_Method__c = quoteitemrecs.buildertek__Pricing_Method__c;
                                        quoteitem.buildertek__Notes__c = quoteitemrecs.buildertek__Notes__c;
                                        quoteitem.buildertek__Purchase_Order__c = quoteitemrecs.buildertek__Purchase_Order__c;
                                        quoteitem.buildertek__Additional_Discount__c = quoteitemrecs.buildertek__Additional_Discount__c;
                                        quoteitemreclst.add(quoteitem);
                                    }
                                }
                            }
                            if (quoteitemreclst.size() > 0){
                                insert quoteitemreclst;
                            }
                        }
                        list<buildertek__Proposal_Images__c> quoteImageList = [SELECT Id, Name, buildertek__Base_URL__c, buildertek__Contact__c, buildertek__Contract__c, buildertek__Description__c, buildertek__Image__c, buildertek__Proposal__c
                                                                               FROM buildertek__Proposal_Images__c
                                                                               WHERE buildertek__Proposal__c IN:quoteIdsList];
                        if (quoteImageList != null){
                            list<buildertek__Proposal_Images__c> contractImagereclst = new list<buildertek__Proposal_Images__c>();
                            for (buildertek__Proposal_Images__c quoteimagerecs : quoteImageList){
                                for (buildertek__Quote__c quoteid : quoteToUpdateList){
                                    if (quoteid.buildertek__OppToQuoteId__c == quoteimagerecs.buildertek__Proposal__c){

                                        buildertek__Proposal_Images__c quoteimage = new buildertek__Proposal_Images__c();
                                        // quoteimage.Name = quoteimagerecs.Name;
                                        quoteimage.buildertek__Base_URL__c = quoteimagerecs.buildertek__Base_URL__c;
                                        quoteimage.buildertek__Contact__c = quoteimagerecs.buildertek__Contact__c;
                                        quoteimage.buildertek__Contract__c = quoteimagerecs.buildertek__Contract__c;
                                        quoteimage.buildertek__Description__c = quoteimagerecs.buildertek__Description__c;
                                        quoteimage.buildertek__Proposal__c = quoteid.Id;
                                        quoteimage.buildertek__Image__c = quoteimagerecs.buildertek__Image__c;
                                        contractImagereclst.add(quoteimage);
                                    }
                                }
                            }
                            if (contractImagereclst.size() > 0){
                                insert contractImagereclst;
                            }
                        }
                        set<Id> contentDocIDList = new set<Id>();
                        Map<Id, Id> contentdocMap = new Map<Id, Id>();
                        for (ContentDocumentLink conDocLink : [SELECT ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType, SystemModstamp, Visibility
                                                               FROM ContentDocumentLink
                                                               WHERE LinkedEntityId IN:quoteIdsList]){
                            contentDocIDList.add(conDocLink.ContentDocumentId);
                            contentdocMap.put(conDocLink.ContentDocumentId, conDocLink.LinkedEntityId);
                            system.debug('contentDocIDList' + contentDocIDList);
                        }
                        List<ContentVersion> VersionList = new List<ContentVersion>();
                        List<ContentVersion> attachlist = new List<ContentVersion>();
                        attachlist = [select Title, Description, FileType, Owner.Name, VersionNumber, CreatedDate, PathOnClient, FileExtension, VersionData, ContentDocumentId
                                      from ContentVersion
                                      where ContentDocumentId in:contentDocIDList AND IsLatest = true];
                        for (buildertek__Quote__c quoteRec : quoteToUpdateList){
                            for (ContentVersion objIndividualAttachment : attachlist){
                                if (contentdocMap.containsKey(objIndividualAttachment.ContentDocumentId)){
                                    if (quoteRec.buildertek__OppToQuoteId__c == contentdocMap.get(objIndividualAttachment.ContentDocumentId)){
                                        ContentVersion con = new contentversion();
                                        con.ContentLocation = 'S';
                                        con.PathOnClient = objIndividualAttachment.PathOnClient;
                                        // con.ContentUrl = '/'+childobject.id;
                                        con.VersionData = objIndividualAttachment.VersionData;
                                        con.Title = objIndividualAttachment.Title;
                                        insert con;
                                        Id conDoc = [SELECT ContentDocumentId, Title
                                                     FROM ContentVersion
                                                     WHERE Id = :con.Id].ContentDocumentId;
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL.ContentDocumentId = conDoc;
                                        CDL.LinkedEntityId = quoteRec.Id;
                                        CDL.ShareType = 'I';
                                        CDL.Visibility = 'AllUsers';
                                        insert CDL;
                                        system.debug('CDL' + CDL);
                                    }
                                }
                            }
                        }
                        Boolean isCreateContract = false;
                        Boolean isCreateBudget = false;
                        List<Id> createdContractCustomerToAccess = new List<Id>();
                        List<Id> createdBudgetCustomerToAccess = new List<Id>();
                        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeCon = [Select Id, buildertek__Change_Order_Configuration__c
                                                                                                         from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                         WHERE Name = :'Create Contract on Quote Acceptance'
                                                                                                         LIMIT 1];
                        if (adminInterfaceNodeCon.size() > 0){
                            isCreateContract = adminInterfaceNodeCon[0].buildertek__Change_Order_Configuration__c;
                        }
                        for (buildertek__Quote__c newquote : quoteToUpdateList){
                            if (isCreateContract && newquote.Status__c == 'Customer Accepted'){
                                createdContractCustomerToAccess.add(newquote.Id);
                            }
                        }
                        if (!createdContractCustomerToAccess.isEmpty()){
                            BudgetContractCreateHelper.createContractsFromQuote(createdContractCustomerToAccess);
                        }
                        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodebudgetConfiguration = [Select Id, buildertek__Create_Budget_on_Quote_Acceptance__c
                                                                                                                         from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                                         WHERE Name = :'Budget Configuration'
                                                                                                                         LIMIT 1];
                        system.debug('&***' + adminInterfaceNodebudgetConfiguration);
                        if (adminInterfaceNodebudgetConfiguration.size() > 0){
                            system.debug('**************' + adminInterfaceNodebudgetConfiguration);
                            isCreateBudget = adminInterfaceNodebudgetConfiguration[0].buildertek__Create_Budget_on_Quote_Acceptance__c;
                        }
                        for (buildertek__Quote__c newqte : quoteToUpdateList){
                            if (isCreateBudget && newqte.Status__c == 'Customer Accepted'){
                                createdBudgetCustomerToAccess.add(newqte.Id);
                            }
                        }
                        if (!createdBudgetCustomerToAccess.isEmpty()){
                            BudgetContractCreateHelper.createBudgetFromQuote(createdBudgetCustomerToAccess);
                        }


                    }

                    List<Opportunity> oppyList = new List<Opportunity>();
                    oppyList = [SELECT Id, Name, AccountId, Account.Name, Account.Billingcity, Account.Billingstate, Account.Billingstreet, Account.Billingpostalcode, ownerId FROM Opportunity WHERE Id IN :oldOpportunityMap.keySet()];
                    if (createProject) {
                        list<buildertek__Project__c> projectList = new list<buildertek__Project__c>();
                        for (Opportunity opp : oppyList) {
                            buildertek__Project__c prj = new buildertek__Project__c();
                            prj.buildertek__Account__c = opp.AccountId;
                            prj.buildertek__Customer__c = opp.AccountId;
                            prj.buildertek__City__c = opp.Account.Billingcity;
                            prj.buildertek__State__c = opp.Account.Billingstate;
                            prj.buildertek__Address__c = opp.Account.Billingstreet;
                            prj.buildertek__Zip__c = opp.Account.Billingpostalcode;
                            prj.Name = opp.Account.Name;
                            prj.buildertek__Opportunity__c = opp.Id;
                            prj.OwnerId = opp.OwnerId;
                            projectList.add(prj);
                        }
                        
                        insert projectList;
                    }
                }
            }
        }
    }

}