public with sharing class BT_CreateProjectFromOpportunity {
    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
        Opportunity opp;
       
                
            opp = [SELECT Id, AccountId, Account.Name from Opportunity where Id =: recordId]; 
            
        
        
        return opp;
    }
    
    @AuraEnabled
    public static string createProject(String recordId, String projectName, String account, String projectManager, Date contractDate){
        List<Id> quoteIdsList = new List<Id>();
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                    buildertek__Org_Base_URL__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name=:'Quote Configuration' limit 1];
        system.debug('recordId--->'+recordId);
        list<buildertek__Quote__c> oppquotereclist = [select id,name,buildertek__Opportunity__r.OwnerId,buildertek__Grand_Total__c,buildertek__Status__c,buildertek__Opportunity__c from buildertek__Quote__c where buildertek__Opportunity__c = :recordId and buildertek__Status__c = 'Customer Accepted'];
        Opportunity opp = [SELECT Id, AccountId, Account.Name,Account.Billingstate,Account.Billingstreet,Account.Billingpostalcode,Account.Billingcity,buildertek__Notes__c,OwnerId from Opportunity where Id =: recordId]; 
        decimal totalquoteamount = 0;
        if(oppquotereclist.size() > 0){
            //decimal totalquoteamount = 0;
            for(buildertek__Quote__c qutrec : oppquotereclist){
                totalquoteamount += qutrec.buildertek__Grand_Total__c;
            }
        }
            Set<Id> contentDocumentIds1 = new Set<Id>();
            for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]){
                contentDocumentIds1.add(conDoc.ContentDocumentId);
            }
            List<ContentNote> contentNoteslist = new List<ContentNote>();
            List<ContentNote> contentNotes = [SELECT Id, Title,TextPreview,Content from ContentNote where Id In: contentDocumentIds1];
            String[] tmp  = New String[]{};
                string textpreview = '';
                string allnotes = '';
            String TextPreview1;
        for(ContentNote c : contentNotes){
                tmp.add(c.Title + ' : ' + c.TextPreview);
        }
            TextPreview1 = string.join(tmp,'\n\n');
           buildertek__Project__c project = new buildertek__Project__c();
            project.Name = projectName;
            if(account != null){
            project.buildertek__Account__c = account;
           }
            project.buildertek__Project_Manager__c = projectManager;
            project.buildertek__Contract_Date__c = contractDate;
            project.buildertek__Opportunity__c =  recordId;
            project.buildertek__State__c = opp.Account.Billingstate;
             project.buildertek__Address__c = opp.Account.Billingstreet;
             project.buildertek__Zip__c = opp.Account.Billingpostalcode;
              project.buildertek__City__c = opp.Account.Billingcity;
           // project.buildertek__Notes__c = opp.buildertek__Notes__c;   
            if(TextPreview1 != null){
                project.buildertek__Notes__c = TextPreview1; 
            }
           if(account != null){
            project.buildertek__Customer__c = account;
          }
           project.OwnerId = opp.OwnerId;
           if(adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c != null && oppquotereclist.size() > 0){
           project.buildertek__Pictures__c = adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c+'/lightning/r/buildertek__Quote__c/'+oppquotereclist[0].Id+'/related/AttachedContentDocuments/view';
           }
               // project.buildertek__Contract_Amount__c = totalquoteamount;
        insert project;
        for(ContentNote c : contentNotes){
                textpreview = c.TextPreview;
                ContentNote noteRec = new ContentNote();
                noteRec.Title = c.Title;
                noteRec.Content = c.Content;
                contentNoteslist.add(noteRec);
            }
        if(contentNoteslist.size() > 0){
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
             
        }
        
        List<buildertek__Quote__c> quoteList;
            quoteList = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c, 
                        buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c,
                        buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c,
                        buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c, 
                        buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c, 
                        buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c, 
                        buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c,buildertek__OppToQuoteId__c, buildertek__Ship_To_Zip_Code__c, 
                        buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c,buildertek__Opportunity__c, 
                        buildertek__SignatureBase64__c,buildertek__Bill_To_Cell_Phone__c,buildertek__Bill_To_Email_Address__c,buildertek__Customer_Accepted_Date__c,
                        buildertek__Date_Accepted_by_Customer__c,buildertek__Date_Sent_To_Customer__c,buildertek__Type__c 
                                from buildertek__Quote__c 
                                where buildertek__Opportunity__c =: recordId and (buildertek__Status__c = 'Approved' OR buildertek__Status__c = 'Customer Accepted')];
                
        
        system.debug('quoteList ---------> '+quoteList);
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
                   // quoteToUpdate.buildertek__Pictures__c = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/buildertek__Quote__c/'+quote.Id+'/related/AttachedContentDocuments/view';
            if(adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c != null){      
                quoteToUpdate.buildertek__Pictures__c = adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c+'/lightning/r/buildertek__Quote__c/'+quote.Id+'/related/AttachedContentDocuments/view';
            }
                quoteToUpdateList.add(quoteToUpdate);
                    
            }
            
        
        system.debug('quoteToUpdateList --------> '+quoteToUpdateList);
        if(quoteToUpdateList.size() > 0){
        insert quoteToUpdateList; 
        }
      /*  set<Id> contentDocIDList = new set<Id>();
        Map<Id, Id> contentdocMap = new Map<Id, Id>();
        system.debug('quoteids'+ quoteIdsList);
        for(ContentDocumentLink conDocLink : [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility 
                                               FROM ContentDocumentLink WHERE LinkedEntityId IN: quoteIdsList]){
            contentDocIDList.add(conDocLink.ContentDocumentId);
            contentdocMap.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);                                                   
            system.debug('contentDocIDList'+contentDocIDList);                                       
        }
       List<ContentVersion> VersionList = new List<ContentVersion>();
        List<ContentVersion> attachlist = new List<ContentVersion>();
        attachlist = [select Title, Description, FileType,Owner.Name, VersionNumber,CreatedDate,PathOnClient,FileExtension,VersionData,ContentDocumentId from ContentVersion 
                       where ContentDocumentId in :contentDocIDList AND IsLatest = true];
        for(buildertek__Quote__c quoteRec : quoteToUpdateList)
        {
            for(ContentVersion objIndividualAttachment : attachlist)
            {
                if(contentdocMap.containsKey(objIndividualAttachment.ContentDocumentId)){
                    system.debug('&&&&&&&&&&&'+contentdocMap.get(objIndividualAttachment.ContentDocumentId));
                    system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%'+quoteRec.buildertek__OppToQuoteId__c);
                if(quoteRec.buildertek__OppToQuoteId__c == contentdocMap.get(objIndividualAttachment.ContentDocumentId) ){
                    system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                    ContentVersion con= new contentversion();
                    con.ContentLocation = 'S'; 
                    con.PathOnClient = objIndividualAttachment.PathOnClient; 
                    // con.ContentUrl = '/'+childobject.id;
                    con.VersionData = objIndividualAttachment.VersionData; 
                    con.Title = objIndividualAttachment.Title;
                    insert con;
                    Id conDoc = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE Id =:con.Id].ContentDocumentId;
                    ContentDocumentLink CDL = new ContentDocumentLink();
                    CDL .ContentDocumentId = conDoc;
                    CDL .LinkedEntityId = quoteRec.Id; 
                    CDL .ShareType = 'I'; 
                    CDL .Visibility = 'AllUsers'; 
                    insert CDL; 
                    system.debug('CDL'+CDL);
                }
                    }
            }
        } */
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
                                                        WHERE buildertek__Quote__c IN: quoteIdsList and buildertek__Quote__r.buildertek__Opportunity__c =:recordId ]; 
            system.debug('quoteToUpdateList --->'+quoteToUpdateList.size());
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
       transient set<Id> contentDocIDList = new set<Id>();
        Map<Id, Id> contentdocMap = new Map<Id, Id>();
        system.debug('quoteIdsList'+quoteIdsList);
        if(quoteIdsList.size() > 0){
        list<ContentDocumentLink> ContentDocumentLinklist = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility 
                                                              FROM ContentDocumentLink WHERE LinkedEntityId IN: quoteIdsList];
        for(ContentDocumentLink conDocLink : ContentDocumentLinklist){
            contentDocIDList.add(conDocLink.ContentDocumentId);
            contentdocMap.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);                                                   
        }
        transient List<ContentVersion> VersionList = new List<ContentVersion>();
        transient List<ContentVersion> attachlist = new List<ContentVersion>();
        attachlist = [select Title, Description, FileType,Owner.Name, VersionNumber,CreatedDate,PathOnClient,FileExtension,VersionData,ContentDocumentId from ContentVersion 
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
                        con.VersionData = objIndividualAttachment.VersionData; 
                        con.Title = objIndividualAttachment.Title;
                        contentVersionToInsert.add(con);
                       /* insert con;
                        Id conDoc = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE Id =:con.Id].ContentDocumentId;
                        ContentDocumentLink CDL = new ContentDocumentLink();
                        CDL .ContentDocumentId = conDoc;
                        CDL .LinkedEntityId = quoteRec.Id; 
                        CDL .ShareType = 'I'; 
                        CDL .Visibility = 'AllUsers'; 
                        insert CDL; */
                    }
                }
            }
        }  
        if(contentVersionToInsert.size() > 0){
            insert contentVersionToInsert;
            SET<Id> contentDocumentIds = new SET<Id>();
            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
            for(ContentVersion cv : contentVersionList){
                contentDocumentIds.add(cv.ContentDocumentId);
            }
            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(String quoteId : quoteIds){
                for(ContentDocument cd : conDocList){
                    ContentDocumentLink CDL = new ContentDocumentLink();
                    CDL .ContentDocumentId = cd.Id;
                    CDL .LinkedEntityId = quoteId; 
                    CDL .ShareType = 'I'; 
                    CDL .Visibility = 'AllUsers';
                    cdlList.add(CDL);
                }          
            }
            if(cdlList.size() > 0){
                insert cdlList;
            }
        }
            }
        
        List<Id> createdContractCustomerToAccess = new List<Id>();
        for(buildertek__Quote__c newquote : quoteToUpdateList ){
            createdContractCustomerToAccess.add(newquote.Id);
        } 
       // List<buildertek__Contract__c> newContracts = BudgetContractCreateHelper.createContractsFromQuote(quoteIdsList);
          List<buildertek__Contract__c> newContracts = BudgetContractCreateHelper.createContractsFromQuote(createdContractCustomerToAccess);
          List<buildertek__Budget__c> newBudgets = BudgetContractCreateHelper.createBudgetFromQuote(createdContractCustomerToAccess);
        
        return project.Id;
    }
    
    public class displayMessages{
        public String Message {get; set; }    
    }
}