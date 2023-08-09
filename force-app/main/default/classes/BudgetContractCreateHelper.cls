/**
 *  @author Amar Behere
 *  @date 4 June 2018
 *  @description Helper class to create budget
 */
public without sharing class BudgetContractCreateHelper {
    /**
     *  @description Helper methods to create Budget
     */
    public static List<buildertek__Budget__c> createBudgetFromContract(List<Id> listContractIds) {
        List<Id> contractIds = new List<Id>();
        Integer intIndex = 0;
        Integer itemIndex = 0;
        Map<Integer, buildertek__Budget__c> mapBudgetIndex = new Map<Integer, buildertek__Budget__c>();
        Map<Integer, List<buildertek__Budget_Item__c>> mapBudgetLinesIndex = new Map<Integer, List<buildertek__Budget_Item__c>>();
        Map<Integer, buildertek__Budget_Item__c> mapBudgetItemIndex = new Map<Integer, buildertek__Budget_Item__c>();
        Map<String, List<buildertek__Change_Order__c>> mapChangeOrders = new Map<String, List<buildertek__Change_Order__c>>(); 
        List<buildertek__Change_Order__c> changeOrderList = new List<buildertek__Change_Order__c>();
        SET<Id> coIdSet = new SET<Id>();
        buildertek__Quote_Line_Group__c budGroup = new buildertek__Quote_Line_Group__c();
        if(!Test.isRunningTest()){
            buildertek__Quote_Line_Group__c budgetGroup;
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                budgetGroup= [Select Id from buildertek__Quote_Line_Group__c Where Name ='No Grouping'];
            }
            if(budgetGroup != null){
                budGroup = budgetGroup;    
            }else{
                budGroup.Name = 'No Grouping';
                if(Schema.sObjectType.buildertek__Quote_Line_Group__c.isCreateable()&&
               Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isCreateable() &&
               Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                insert budGroup;
               }
                
            }    
        }
        system.debug('budGroup --------> '+budGroup);
        system.debug('listContractIds ---------> '+listContractIds);
        List<buildertek__Contract__c> contractsList = getContractsWithLines(listContractIds);
        
        for(buildertek__Contract__c currContract : contractsList) {
            
            mapBudgetIndex.put(
                intIndex,
                new buildertek__Budget__c(
                    Name = currContract.Name,
                    buildertek__Project__c = currContract.buildertek__Project__c,
                    buildertek__Approved_CO_Amount__c = currContract.buildertek__Change_Order_Amount__c
                )
            );
            
            mapBudgetLinesIndex.put(intIndex, new List<buildertek__Budget_Item__c>());
            contractIds.add(currContract.Id);
        }
        
        List<buildertek__Contract_Item__c> contractItemList = getContractLines(contractIds);
        for(buildertek__Contract_Item__c currContractLine : contractItemList) {
            mapBudgetLinesIndex.get(intIndex).add(new buildertek__Budget_Item__c(
                Name = currContractLine.Name,
                buildertek__Product__c = currContractLine.buildertek__Product__c,
                buildertek__Item_Name__c = currContractLine.buildertek__Item_Name__c,
                buildertek__Cost_Code__c = currContractLine.buildertek__Cost_Code__c,
                buildertek__Quantity__c = currContractLine.buildertek__Quantity__c,
                buildertek__Unit_Price__c = currContractLine.buildertek__Unit_Price__c,                
                buildertek__Budget_Line_Group__c = currContractLine.buildertek__Contract_Item_Group__c
            ));
        }
        intIndex++;
        system.debug('mapBudgetIndex ---------> '+mapBudgetIndex);
        if(!mapBudgetIndex.isEmpty()) {
            List<buildertek__Budget_Item__c> listBudgetItems = new List<buildertek__Budget_Item__c>();
            if(Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable() &&
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable() && 
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Approved_CO_Amount__c.isCreateable()){
            insert mapBudgetIndex.values();
            }
            for(Integer currIndex : mapBudgetIndex.keySet()) {
                for(buildertek__Budget_Item__c currBudgetItem : mapBudgetLinesIndex.get(currIndex)) {
                    currBudgetItem.buildertek__Budget__c = mapBudgetIndex.get(currIndex).Id;
                    listBudgetItems.add(currBudgetItem);
                }
            }
            
            if(!listBudgetItems.isEmpty()) {
                 if(Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable()&&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__UOM__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Amount_In__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__cost_Code__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Description__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Forecast_To_Complete__c.isCreateable() ){
                    insert listBudgetItems;
                }
            }
        }
        return mapBudgetIndex.values();
    }
    
    public static List<buildertek__Budget__c> createBudgetFromQuote(List<Id> QuoteId) {
        List<String> quoteIdsList = new List<String>();
        Integer intIndex = 0;
        Map<Integer, buildertek__Budget__c> mapBudgetIndex = new Map<Integer, buildertek__Budget__c>();
        Map<Integer, List<buildertek__Budget_Item__c>> mapBudgetLinesIndex = new Map<Integer, List<buildertek__Budget_Item__c>>();
        
        
        List<String> poIds=new List<String>();
        
        MAP<Integer,List<String>> idMap= new Map<Integer,List<String>>();
        Map<String,String> quoteToBudget = new Map<String,String>();
        Map<String,buildertek__Budget_Item__c> quoteToBudgetItem= new Map<String,buildertek__Budget_Item__c>();
        
        
        buildertek__Quote_Line_Group__c budGroup = new buildertek__Quote_Line_Group__c();
        
        //if(!Test.isRunningTest()){
            buildertek__Quote_Line_Group__c budgetGroup;
          //  if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
              //  Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                budgetGroup= [Select Id from buildertek__Quote_Line_Group__c Where Name ='No Grouping'];
              //  }
            if(budgetGroup != null){
                budGroup = budgetGroup;    
            }else{
                budGroup.Name = 'No Grouping';
            //    if(Schema.sObjectType.buildertek__Quote_Line_Group__c.isCreateable()&&
            //   Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isCreateable() &&
             //  Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                insert budGroup;
             //  }
                
            }    
        //}
        //List<buildertek__Quote__c> allQuote = getQuotesWithLines(QuoteId);
        List<buildertek__Quote__c> allQuote = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c, 
                        buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c,
                        buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c,
                        buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c, 
                        buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c, 
                        buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c, 
                        buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c, buildertek__Ship_To_Zip_Code__c, buildertek__Opportunity__c, 
                        buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c, 
                        buildertek__SignatureBase64__c,buildertek__Notes__c,buildertek__Quote_File__c
                FROM buildertek__Quote__c
                WHERE Id IN : QuoteId];
        for(buildertek__Quote__c curQuote : allQuote) {
            mapBudgetIndex.put(
                intIndex,
                new buildertek__Budget__c(   
                    Name = curQuote.Name,
                    buildertek__Project__c = curQuote.buildertek__Project__c
                )
            );
            quoteIdsList.add(curQuote.Id);
            mapBudgetLinesIndex.put(intIndex, new List<buildertek__Budget_Item__c>());
        }
        
        List<buildertek__Quote_Item__c> quoteItemList = getQuoteLines(quoteIdsList);

        List<buildertek__Budget_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c];

        Map<String, Id> groupMap = new Map<String, Id>();

        for (buildertek__Budget_Line_Group__c groupData : groupList) {
            groupMap.put(groupData.Name, groupData.Id);
        }

        List<buildertek__Budget_Line_Group__c> newGroupList = new List<buildertek__Budget_Line_Group__c>();
        String groupId = budGroup.Id;
        for (buildertek__Quote_Item__c quoteLine : quoteItemList) {
            if (quoteLine.buildertek__Grouping__c != null && quoteLine.buildertek__Grouping__c != groupId) {
                if (!groupMap.containsKey(quoteLine.buildertek__Grouping__r.Name)) {
                    buildertek__Budget_Line_Group__c newGroup = new buildertek__Budget_Line_Group__c();
                    newGroup.Name = quoteLine.buildertek__Grouping__r.Name;
                    newGroupList.add(newGroup);
                }
                groupId = quoteLine.buildertek__Grouping__c;
            }
        }

        if (newGroupList.size() > 0) {
            insert newGroupList;
            for (buildertek__Budget_Line_Group__c groupData : newGroupList) {
                groupMap.put(groupData.Name, groupData.Id);
            }
        }

        idMap.put(intIndex,new List<String>());
        for(buildertek__Quote_Item__c currQuoteLine : quoteItemList) {
            System.debug('currQuoteLine.buildertek__Grouping__r.Name ==> '+currQuoteLine.buildertek__Grouping__r.Name);
            mapBudgetLinesIndex.get(intIndex).add(new buildertek__Budget_Item__c(
                Name = currQuoteLine.Name,
                buildertek__Product__c = currQuoteLine.buildertek__Product__c,
                buildertek__Item_Name__c = currQuoteLine.buildertek__Item_Name__c,
                buildertek__Cost_Code__c = currQuoteLine.buildertek__Cost_Code__c,
                buildertek__Quantity__c = currQuoteLine.buildertek__Quantity__c,
                buildertek__Unit_Price__c = currQuoteLine.buildertek__Unit_Cost__c,
                //buildertek__Unit_Price__c = currQuoteLine.buildertek__Net_Unit__c,
                buildertek__Sales_Price__c = currQuoteLine.buildertek__Net_Total_Price__c, 
                buildertek__Budget_Line_Group__c = currQuoteLine.buildertek__Grouping__c,
                buildertek__Group__c = groupMap.get(currQuoteLine.buildertek__Grouping__r.Name),
                buildertek__Markup__c = currQuoteLine.buildertek__Markup__c
            ));
            if(currQuoteLine.buildertek__Purchase_Order__c!=null){
                poIds.add(currQuoteLine.buildertek__Purchase_Order__c);    
            }
            idMap.get(intIndex).add(currQuoteLine.buildertek__Purchase_Order__c);
        }
         
        intIndex++;
        
        if(!mapBudgetIndex.isEmpty()) {
            List<buildertek__Budget_Item__c> listBudgetItems = new List<buildertek__Budget_Item__c>();
            // if(Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable() &&
             //  Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable()){ 
                 insert mapBudgetIndex.values();
             //  }
            system.debug('mapBudgetIndex----'+mapBudgetIndex.values());
            for(Integer currIndex : mapBudgetIndex.keySet()) {
                for(buildertek__Budget_Item__c currBudgetItem : mapBudgetLinesIndex.get(currIndex)) {
                  //  if(Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable()){ 
                        currBudgetItem.buildertek__Budget__c = mapBudgetIndex.get(currIndex).Id;
                        listBudgetItems.add(currBudgetItem);
                  //  }
                }
            }
            
            if(!listBudgetItems.isEmpty()) {
                insert listBudgetItems;
                 system.debug('listBudgetItems----'+listBudgetItems);
                Map<Integer, List<buildertek__Budget_Item__c>> mapBudgetLines = new Map<Integer, List<buildertek__Budget_Item__c>>();
                Integer i=0;
                for(Integer currIndex : mapBudgetIndex.keySet()) {
                    
                    for(buildertek__Budget_Item__c currBudgetItem : mapBudgetLinesIndex.get(currIndex)) { 
                        if(!mapBudgetLines.containsKey(currIndex)){
                            mapBudgetLines.put(currIndex, new List<buildertek__Budget_Item__c>());
                            mapBudgetLines.get(currIndex).add(listBudgetItems[i]); 
                            i++;
                        }else{
                            mapBudgetLines.get(currIndex).add(listBudgetItems[i]);
                            i++;
                        }
                        
                    }
                }
                
                List<buildertek__Purchase_Order__c> purchaseOrderLst = getPurchaseOrdersWithLines(poIds);
                Map<id,buildertek__Purchase_Order__c> purchaseOrderLstMap = new Map<id,buildertek__Purchase_Order__c>();
                for(buildertek__Purchase_Order__c potemp: purchaseOrderLst){
                    purchaseOrderLstMap.put(potemp.id,potemp);
                }
                List<buildertek__PO_Item_To_Budget_Item_Link__c>  budgetItemLinkRecs= new List<buildertek__PO_Item_To_Budget_Item_Link__c>();

                for(Integer currIndex : idMap.keySet()) {
                    Integer Index=0;
                    for(String temp : idMap.get(currIndex)){
                        if(temp!=null){
                            buildertek__Purchase_Order__c purchaseOrderRec = purchaseOrderLstMap.get(temp);
                            buildertek__Budget_Item__c budgetItemRec = mapBudgetLines.get(currIndex)[Index];
                            for(buildertek__Purchase_Order_Item__c currPOLine : purchaseOrderRec.buildertek__Purchase_Order_Items__r) {

                                buildertek__PO_Item_To_Budget_Item_Link__c budgetItemLinkRec = new buildertek__PO_Item_To_Budget_Item_Link__c();
                                budgetItemLinkRec.buildertek__Approved_PO__c=currPOLine.buildertek__Unit_Price__c;
                                    budgetItemLinkRec.buildertek__PO_Item__c=currPOLine.id;
                                 budgetItemLinkRec.buildertek__Budget_Item__c=budgetItemRec.id;
                                budgetItemLinkRecs.add(budgetItemLinkRec);
                                
                                system.debug('----working in budget contract create helper');
                            }
                        }
                        index++;
                    }
                }
                System.debug('budgetItemLinkRecs :: '+budgetItemLinkRecs);
                if(budgetItemLinkRecs.size()>0){
                   // if (Schema.sObjectType.buildertek__PO_Item_To_Budget_Item_Link__c.fields.buildertek__Approved_PO__c.isCreateable() && 
                      //  Schema.sObjectType.buildertek__PO_Item_To_Budget_Item_Link__c.fields.buildertek__PO_Item__c.isCreateable() &&
                      //   Schema.sObjectType.buildertek__PO_Item_To_Budget_Item_Link__c.fields.buildertek__Budget_Item__c.isCreateable() ) {
                    system.debug('----working in budget contract create helper');   
                    insert budgetItemLinkRecs;
                  //  }
                  system.debug('----working in budget contract create helper');
                }
                  
            }
        }
        
        return mapBudgetIndex.values();
    }
    
    /**
     *  @description Helper methods to create Quote
     */
    public static List<buildertek__Contract__c> createContractsFromQuote(List<Id> listQuoteIds) {
        system.debug('%%%%%%%%%%%%%'+listQuoteIds);
        List<Id> quoteIdsList = new List<Id>(); 
        Integer intIndex = 0;
        Map<Integer, buildertek__Contract__c> mapQuoteIndex = new Map<Integer, buildertek__Contract__c>();
        Map<Integer, List<buildertek__Contract_Item__c>> mapQuoteLineIndex = new Map<Integer, List<buildertek__Contract_Item__c>>();
        List<Site> sites = [SELECT Id, Name, GuestUserId FROM Site where Status='Active' AND SiteType='Visualforce'];
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                    buildertek__Org_Base_URL__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name=:'Quote Configuration' limit 1];
        //system.debug('userList ------> '+userList[0].Id);
        buildertek__Quote_Line_Group__c contGroup = new buildertek__Quote_Line_Group__c();
        if(!Test.isRunningTest()){
          buildertek__Quote_Line_Group__c contractGroup;
          
               contractGroup = [Select Id from buildertek__Quote_Line_Group__c Where Name ='No Grouping'];
            
        if(contractGroup != null){
            contGroup = contractGroup;
        }else{
            contGroup.Name = 'No Grouping';
            
                insert contGroup;
            
        }
        }
        List<buildertek__Quote__c> allQuote=getQuotesWithLines(listQuoteIds);
        string pictur = '';
        if(adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c != null){
            pictur = adminInterfaceNodeConfigurations[0].buildertek__Org_Base_URL__c;
        }
        system.debug('listQuoteIds'+listQuoteIds);
        for(buildertek__Quote__c currQuote : allQuote) {
            system.debug('currQuote'+currQuote);
            system.debug('currQuote'+currQuote.buildertek__Quote_File__c);
            mapQuoteIndex.put(
                intIndex,
                new buildertek__Contract__c(
                    Name = currQuote.Name,
                    buildertek__BT_Quote__c = currQuote.Id,
                    buildertek__Pictures__c = pictur+'/lightning/r/buildertek__Quote__c/'+currQuote.buildertek__OppToQuoteId__c+'/related/AttachedContentDocuments/view',
                    buildertek__Contract_Start_Date__c = currQuote.buildertek__Start_Date__c,
                    buildertek__Email_Body__c = currQuote.buildertek__Email_Body__c,
                    buildertek__Email_Subject__c = currQuote.buildertek__Email_Subject__c,
                    buildertek__Expiration_Date__c = currQuote.buildertek__Expires_On__c,
                    buildertek__Primary_Contact__c = currQuote.buildertek__Primary_Contact__c,
                    buildertek__Project__c = currQuote.buildertek__Project__c,
                    buildertek__Start_Date__c = currQuote.buildertek__Start_Date__c,
                    buildertek__Discount__c = currQuote.buildertek__Discount__c,
                    buildertek__Tax_Rate__c = currQuote.buildertek__Tax__c,
                    buildertek__Shipping_Handling__c = currQuote.buildertek__Shipping_and_Handling__c,
                    buildertek__Notes__c = currQuote.buildertek__Notes__c,
                    // buildertek__Status__c = currQuote.buildertek__Status__c
                    buildertek__Status__c = 'Approved',
                    buildertek__Contract_File__c=currQuote.buildertek__Quote_File__c
                )
            );
            
            mapQuoteLineIndex.put(intIndex, new List<buildertek__Contract_Item__c>());
            quoteIdsList.add(currQuote.Id);
            
        }
        List<buildertek__Quote_Item__c> quoteItemList = getQuoteLines(quoteIdsList);
        for(buildertek__Quote_Item__c currQuoteItem : quoteItemList) {
            mapQuoteLineIndex.get(intIndex).add(new buildertek__Contract_Item__c(
                Name = currQuoteItem.Name,
                buildertek__Cost_Code__c = currQuoteItem.buildertek__Cost_Code__c,
                buildertek__Description__c = currQuoteItem.buildertek__Description__c,
                buildertek__Product__c = currQuoteItem.buildertek__Product__c,
                buildertek__Quantity__c = currQuoteItem.buildertek__Quantity__c,
                //buildertek__Total_Price__c = currQuoteItem.buildertek__Total_Cost__c,
                buildertek__Unit_Price__c = currQuoteItem.buildertek__Net_Unit__c,
                buildertek__Contract_Item_Group__c = currQuoteItem.buildertek__Grouping__c,
                buildertek__Notes__c = currQuoteItem.buildertek__Notes__c
            ));
            
        }
            
        System.debug('mapQuoteIndex ::: '+JSON.serialize(mapQuoteIndex));
        if(!mapQuoteIndex.isEmpty()) {
            List<buildertek__Contract_Item__c> listContractLines = new List<buildertek__Contract_Item__c>();
           
                 insert mapQuoteIndex.values();
                
            
            for(Integer currIndex : mapQuoteIndex.keySet()) {
                for(buildertek__Contract_Item__c currBudgetItem : mapQuoteLineIndex.get(currIndex)) {
                    currBudgetItem.buildertek__Contract__c = mapQuoteIndex.get(currIndex).Id;
                    listContractLines.add(currBudgetItem);
                }
            }
            
            if(!listContractLines.isEmpty()) {
               
                insert listContractLines;
                
            }
        }
        list<buildertek__Proposal_Images__c> quoteImageList = [SELECT Id, 
                                                        Name,buildertek__Base_URL__c,
                                                        buildertek__Contact__c,buildertek__Contract__c,
                                                        buildertek__Description__c,buildertek__Image__c,
                                                        buildertek__Proposal__c
                                                        FROM buildertek__Proposal_Images__c
                                                        WHERE buildertek__Proposal__c IN: listQuoteIds]; 
        if(quoteImageList !=null){
            list<buildertek__Proposal_Images__c> contractImagereclst = new list<buildertek__Proposal_Images__c>();
                for(buildertek__Proposal_Images__c quoteimagerecs : quoteImageList){
                     for(buildertek__Contract__c contractRec : mapQuoteIndex.values())
                    if(!mapQuoteIndex.isEmpty()) {
                        buildertek__Proposal_Images__c quoteimage =  new buildertek__Proposal_Images__c();
                       // quoteimage.Name = quoteimagerecs.Name;
                        quoteimage.buildertek__Base_URL__c =quoteimagerecs.buildertek__Base_URL__c;
                        quoteimage.buildertek__Contact__c = quoteimagerecs.buildertek__Contact__c;
                        quoteimage.buildertek__Contract__c = contractRec.id;
                        quoteimage.buildertek__Description__c =  quoteimagerecs.buildertek__Description__c;
                       // quoteimage.buildertek__Proposal__c = quoteid.Id;
                        quoteimage.buildertek__Image__c =  quoteimagerecs.buildertek__Image__c ;
                        contractImagereclst.add(quoteimage) ;
                    }
                }  
            if(contractImagereclst.size() >0 ){
                insert contractImagereclst;
            }
       }
       /* transient set<Id> contentDocIDList = new set<Id>();
        Map<Id, Id> contentdocMap = new Map<Id, Id>();
        if(listQuoteIds.size()>0){
        transient list<ContentDocumentLink> ContentDocumentLinklist = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility 
                                               FROM ContentDocumentLink WHERE LinkedEntityId IN: listQuoteIds]; 
        for(ContentDocumentLink conDocLink : ContentDocumentLinklist){
            contentDocIDList.add(conDocLink.ContentDocumentId);
            contentdocMap.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);                                                   
            system.debug('contentDocIDList'+contentDocIDList);                                       
        }
       transient List<ContentVersion> VersionList = new List<ContentVersion>();
       transient List<ContentVersion> attachlist = new List<ContentVersion>();
        attachlist = [select Title, Description, FileType,Owner.Name, VersionNumber,CreatedDate,PathOnClient,FileExtension,VersionData,ContentDocumentId from ContentVersion 
                      where ContentDocumentId in :contentDocIDList AND IsLatest = true];
        
        transient List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
        SET<Id> contractIds = new SET<Id>();
        for(buildertek__Contract__c quoteRec : mapQuoteIndex.values())
        {
            contractIds.add(quoteRec.Id);
            for(ContentVersion objIndividualAttachment : attachlist)
            {
                if(contentdocMap.containsKey(objIndividualAttachment.ContentDocumentId)){
                    if(quoteRec.buildertek__BT_Quote__c == contentdocMap.get(objIndividualAttachment.ContentDocumentId) ){
                        transient ContentVersion con= new contentversion();
                        con.ContentLocation = 'S'; 
                        con.PathOnClient = objIndividualAttachment.PathOnClient; 
                        // con.ContentUrl = '/'+childobject.id;
                        con.VersionData = objIndividualAttachment.VersionData; 
                        con.Title = objIndividualAttachment.Title;
                        con.FirstPublishLocationId = quoteRec.OwnerId;
                        if(sites[0].GuestUserId != UserInfo.getUserId()){
                            contentVersionToInsert.add(con);
                        }
                    }
                }
            }
        }
        system.debug('contentVersionToInsert --------> '+contentVersionToInsert);
        if(contentVersionToInsert.size() > 0){
            insert contentVersionToInsert;
            SET<Id> contentDocumentIds = new SET<Id>();
            transient List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
            for(ContentVersion cv : contentVersionList){
                contentDocumentIds.add(cv.ContentDocumentId);
            }
            transient List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
            transient List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(String contractId : contractIds){
                system.debug('contractId --------> '+contractId);
                for(ContentDocument cd : conDocList){
                    transient ContentDocumentLink CDL = new ContentDocumentLink();
                    CDL.ContentDocumentId = cd.Id;
                    CDL.LinkedEntityId = contractId; 
                    CDL.ShareType = 'I'; 
                    CDL.Visibility = 'AllUsers'; 
                    cdlList.add(CDL);
                }
            }
            
            if(cdlList.size() > 0){
                insert cdlList;     
            }
        }
        }*/
        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodebudgetConfiguration = [Select Id,
                                                                                                         buildertek__Automatically_Create_Inv_from_ConSigning__c 
                                                                                                         from buildertek__Admin_Interface_Node_Configuration__c 
                                                                                                         WHERE Name=:'Create Contract on Quote Acceptance' LIMIT 1];
            if(adminInterfaceNodebudgetConfiguration.size()>0){
                if(adminInterfaceNodebudgetConfiguration[0].buildertek__Automatically_Create_Inv_from_ConSigning__c == true){
                    for(buildertek__Contract__c contractRec : mapQuoteIndex.values()){
                        if(!mapQuoteIndex.isEmpty()) {
                            CreateInvoiceFromContract.CreateInvoiceMethod(contractRec.id);
                        }
                    }
                }
            }
        return mapQuoteIndex.values();
    }
    
    /**
     *  @description Get all Purchase Orders and associated Order Line Items on Purchase Order Id's
     */
    
    public static List<buildertek__Purchase_Order__c> getPurchaseOrdersWithLines(List<Id> listPoIds) {
        List<buildertek__Purchase_Order__c> purchaseorderlist;
        if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible()){
                purchaseorderlist = [select id,(select id,buildertek__Unit_Price__c from buildertek__Purchase_Order_Items__r) from buildertek__Purchase_Order__c where id In :listPoIds];
        }
        return purchaseorderlist;
    }
        
        
    /**
     *  @description Get all Quotes and associated Quote Line Items on Quote Id's
     */
    public static List<buildertek__Quote__c> getQuotesWithLines(List<Id> listQuoteIds) {
        Map<String, List<buildertek__Quote_Item__c>> quoteIdQuoteLinesMap = new Map<String, List<buildertek__Quote_Item__c>>();
        List<buildertek__Quote__c> quotelist = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c, 
                        buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c,buildertek__OppToQuoteId__c,
                        buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c,
                        buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c, 
                        buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c, 
                        buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c, 
                        buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c, buildertek__Ship_To_Zip_Code__c, buildertek__Opportunity__c, 
                        buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c, 
                        buildertek__SignatureBase64__c,buildertek__Notes__c,buildertek__Quote_File__c
                FROM buildertek__Quote__c
                WHERE Id IN : listQuoteIds];
                
       system.debug('quotelist -------> '+quotelist);
        for(buildertek__Quote__c qut : quotelist){
            quoteIdQuoteLinesMap.put(qut.Id, qut.buildertek__Quote_Items__r);        
        }
        return quotelist;
    }
    
    
    public static List<buildertek__Quote_Item__c> getQuoteLines(List<Id> quoteIds){
        List<buildertek__Quote_Item__c> quoteItemList;
       
                    
            quoteItemList = [SELECT Id, 
                                    Name, 
                                    buildertek__Item_Name__c,
                                    buildertek__Description__c, 
                                    buildertek__Quantity__c, 
                                    buildertek__Unit_Price__c, 
                                    buildertek__Total_Cost__c, 
                                    buildertek__Quote__c, 
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
                                     buildertek__Status__c,
                                    buildertek__Purchase_Order__c, 
                                    buildertek__Grouping__r.Name
                                    FROM buildertek__Quote_Item__c
                                    WHERE buildertek__Quote__c IN: quoteIds  And buildertek__Status__c != 'Reject'];      
        
        
        return quoteItemList;
              
    }
    
      
    
    
    public static List<buildertek__Contract_Item__c> getContractLines(List<Id> contractIds){
        List<buildertek__Contract_Item__c> contractItemList;
       /* if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
                
                Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Contract__c.isAccessible()){*/
                    
           contractItemList = [SELECT Id, 
                                        Name, 
                                        buildertek__Item_Name__c, 
                                        buildertek__Contract__c, 
                                        buildertek__Quantity__c, 
                                        buildertek__Unit_Price__c, 
                                        buildertek__Total_Price__c, 
                                        buildertek__Cost_Code__c, 
                                        buildertek__Description__c, 
                                        buildertek__Budget_Item__c, 
                                        buildertek__Auto_Number__c, 
                                        buildertek__Product__c, 
                                        buildertek__Contract_Item_Group__c 
                                        FROM buildertek__Contract_Item__c
                                        WHERE buildertek__Contract__c IN: contractIds];    
            
        /*}*/
        return contractItemList;
    }
    
    /**
     *  @description Get all Contracts and associated Contract Line Items on Contract Id's
     */
    public static List<buildertek__Contract__c> getContractsWithLines(List<Id> listContractIds) {
        List<buildertek__Contract__c> buildercontractlist ;
        /* if(Schema.sObjectType.buildertek__Contract__c.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Auto_Number__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Status__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_End_Date__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Start_Date__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Signed_Contract_Date__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Retainage__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Budget__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__BT_Quote__c.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Rejection_Reason__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Expiration_Date__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Email_Subject__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Email_Body__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Change_Order_Amount__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible() &&
                Schema.sObjectType.RecordType.fields.Name.isAccessible() &&
                
                Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible() ){*/
                    
                buildercontractlist= [SELECT Id, RecordTypeId, RecordType.Name, Name, buildertek__Project__c, buildertek__Auto_Number__c, buildertek__Status__c, 
                        buildertek__Contract_End_Date__c, buildertek__Contract_Start_Date__c, buildertek__Signed_Contract_Date__c, buildertek__Retainage__c, 
                        buildertek__Inclusions__c, buildertek__Exclusions__c, buildertek__Description__c, buildertek__Contract_Amount__c, buildertek__RFQ__c, 
                        buildertek__Budget__c, buildertek__Vendor__c, buildertek__BT_Quote__c, buildertek__Contract_Rejection_Reason__c, 
                        buildertek__Expiration_Date__c, buildertek__Primary_Contact__c, buildertek__Email_Subject__c, buildertek__Email_Body__c,
                        buildertek__Change_Order_Amount__c,
                        (SELECT Id, buildertek__Total_Amount_Tax__c, buildertek__Status__c FROM buildertek__Change_Orders__r)
                FROM buildertek__Contract__c
                WHERE Id IN : listContractIds];
      /*}*/
      return buildercontractlist;
    }
}