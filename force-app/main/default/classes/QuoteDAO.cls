/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  01-Nov-2017
 */
public with sharing class QuoteDAO{
    /*Method to used to set default grouping in quote item*/
    public static void setDefaultGrouping(List<Quote_Item__c> quoteItems){
        set<Id> quoteIds = new set<Id>();
        SET<Id> groupIds = new SET<Id>(); 
        map<String, String> quoteIdByGroupId = new map<String, String>();
        set<Id> newQuoteWithoutGroup = new set<Id>();
        system.debug('quoteItems ---------> ' + quoteItems);
        // get all quote Ids
        for (Quote_Item__c item : quoteItems){
            quoteIds.add(item.Quote__c);
            if (item.Grouping__c != null){
                groupIds.add(item.Grouping__c);
                quoteIdByGroupId.put(item.Id, item.Grouping__c);
            }
        }
        system.debug('quoteIdByGroupId ---------> ' + quoteIdByGroupId);
        system.debug('groupIds --------> ' + groupIds.isEmpty());
        if (!groupIds.isEmpty()){
            for (Quote_Item__c qItem : quoteItems){
                qItem.Grouping__c = quoteIdByGroupId.get(qItem.Id);
            }
        } else{
            List<Quote_Line_Group__c> qutGroup;
            if (Schema.sObjectType.Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.Quote_Line_Group__c.fields.Name.isAccessible()){
                qutGroup = [SELECT Id
                            FROM Quote_Line_Group__c
                            WHERE Name = 'No Grouping'];
            }
            if (qutGroup.size() > 0){
                for (Quote_Item__c qItem : quoteItems){
                    qItem.Grouping__c = qutGroup[0].Id;
                }
            } else{
                Quote_Line_Group__c quoteGroup = new Quote_Line_Group__c();
                if (Schema.sObjectType.Quote_Line_Group__c.fields.Name.isCreateable()){
                    quoteGroup.Name = 'No Grouping';
                }
                insert quoteGroup;
                for (Quote_Item__c qItem : quoteItems){
                    qItem.Grouping__c = quoteGroup.Id;
                }
            }


        }
    }
    @AuraEnabled
    public static string getRfqTo(){
       return UserInfo.getDefaultCurrency();
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
       return UserInfo.isMultiCurrencyOrganization();
    }
    public static void setProductNameToItemName(List<buildertek__Quote_Item__c> quoteItems){

        Set<Id> productIds = new set<Id>();
        for (buildertek__Quote_Item__c qItem : quoteItems){
            if (qItem.buildertek__Product__c != null){
                productIds.add(qItem.buildertek__Product__c);
            }
        }

        Map<Id, Product2> productByIDs = new map<Id, Product2>([Select Id, Name
                                                                from Product2
                                                                where Id IN :productIds]);
        for (buildertek__Quote_Item__c qItem : quoteItems){
            if (qItem.buildertek__Product__c != null && productByIDs.ContainsKey(qItem.buildertek__Product__c)){
                qItem.Name = productByIDs.get(qItem.buildertek__Product__c).Name;
                qItem.buildertek__Item_Name__c = productByIDs.get(qItem.buildertek__Product__c).Name;

                if (qItem.Name.length() > 80){
                    qItem.Name = qItem.Name.substring(0, 80);
                }
            }
        }
    }

    @AuraEnabled
    public static string getpricebook(string quoteId){
        list<buildertek__Quote__c> quotesList;
        If (Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            quotesList = [select id, buildertek__Project__r.buildertek__Price_Book__c
                          from buildertek__Quote__c
                          where id = :quoteId];
        }
        if (quotesList.size() > 0){
            return quotesList[0].buildertek__Project__r.buildertek__Price_Book__c;
        }
        return null;
    }

    @AuraEnabled
    //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        list<pricebook2> PriceList;
        /* if(Schema.sObjectType.pricebook2.fields.Id.isAccessible()&&
         Schema.sObjectType.pricebook2.fields.Name.isAccessible()){ */
        PriceList = [select Id, Name from pricebook2 where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
        if(PriceList.size()>0){
            for (pricebook2 p : PriceList){
                //Put Picklist Value & Label in Map
                options.put(p.name, p.Id);
            }
            return options;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    //get product family Values
    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){

            list<pricebookEntry> PElist;

            PElist = [select id, Product2Id
                      from pricebookEntry
                      where pricebook2Id = :parentId];

            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst = [SELECT toLabel(Family) familyLabel
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('familyLabel'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }

    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteGrouping(String quoteId){
        List<buildertek__Quote_Line_Group__c> quotelinegrp;
        if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Number__c.isAccessible()){
            quotelinegrp = [Select Id, Name, buildertek__Description__c
                            from buildertek__Quote_Line_Group__c
                            where buildertek__Quote__c = :quoteId
                            Order by buildertek__Number__c DESC];
        }
        return quotelinegrp;
    }

    @AuraEnabled
    public static List<EmailTemplate> getQuoteTemplates(){
        return BT_Email_Utils.getTemplates('BT Quote');
    }

    @AuraEnabled
    public static void sendQuote(String recordId, String targetRecipientId, String templateId, String signatureBase64){
        /*
         try {

         system.debug('---signatureBase64--'+signatureBase64);
         if(signatureBase64 != null && signatureBase64 != ''){
         List<Attachment> existingSignature = [Select Id from Attachment where parentId =:recordId and name ='Signature'];
         Attachment att = new Attachment();
         if(!existingSignature.isEmpty()){
         delete existingSignature[0];
         }

         att.ParentId = recordId;
         att.Name = 'Signature';
         att.ContentType = 'image/png';
         att.body = EncodingUtil.base64Decode(signatureBase64.replace('data:image/png;base64,',''));
         upsert att;
         }

         BT_Email_Utils.sendEmailNotification(recordId, targetRecipientId, templateId);
         } catch(Exception ex){
         throw new AuraHandledException(ex.getMessage());
         }
         */
    }

    @AuraEnabled
    public static string createQuoteItem(String quoteItemsJSON){
        try{
            List<String> groupIds = new List<String>();
            map<String, String> quoteIdByGroupId = new map<String, String>();
            set<Id> newQuoteWithoutGroup = new set<Id>();
            List<buildertek__Quote_Item__c> quoteItemsToInsert = (List<buildertek__Quote_Item__c>)System.JSON.deserialize(quoteItemsJSON, List<buildertek__Quote_Item__c>.class);
            //insert (List<Quote_Item__c>)System.JSON.deserialize(quoteItemsJSON, List<Quote_Item__c>.class);


            List<String> rfqIds = new List<String>();
            Map<String, String> poMap = new Map<String, String>();

            system.debug('quoteItemsToInsert ----------> ' + quoteItemsToInsert);
            for (buildertek__Quote_Item__c qutItem : quoteItemsToInsert){
                system.debug('qutItem.Grouping__c --------> ' + qutItem.Grouping__c);
                if (qutItem.Grouping__c != null){
                    groupIds.add(qutItem.Grouping__c);
                    quoteIdByGroupId.put(qutItem.Id, qutItem.Grouping__c);
                }
                if (qutItem.buildertek__RFQ__c != null){
                    rfqIds.add(qutItem.buildertek__RFQ__c);
                }
            }

            
            List<buildertek__Purchase_Order__c> purchaseOrderRecs;
            if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isAccessible()){
                purchaseOrderRecs = [select id, name, buildertek__RFQ__c
                                     from buildertek__Purchase_Order__c
                                     where buildertek__RFQ__c In :rfqIds
                                     order by createddate desc];
            }
            for (buildertek__Purchase_Order__c po : purchaseOrderRecs){
                if (!poMap.containsKey(po.buildertek__RFQ__c)){
                    poMap.put(po.buildertek__RFQ__c, po.id);
                }
            }

            string qutgrpid;
            List<Quote_Line_Group__c> qutGrouping = [SELECT Id
                                                     FROM Quote_Line_Group__c
                                                     WHERE Name = 'No Grouping'
                                                     limit 1];

            if (qutGrouping.size() > 0){
                qutgrpid = qutGrouping[0].Id;
            } else{
                Quote_Line_Group__c quotGroup = new Quote_Line_Group__c();
                quotGroup.Name = 'No Grouping';
                insert quotGroup;
                qutgrpid = quotGroup.Id;
            }

            system.debug('Is Empty ----------> ' + groupIds.isEmpty());
            if (!groupIds.isEmpty()){
                system.debug('Not Empty ----------> ' + groupIds);

                for (buildertek__Quote_Item__c qItem : quoteItemsToInsert){

                    system.debug('qItem----------> ' + qItem.Id);
                    if (qItem.Id != null){
                        qItem.Grouping__c = quoteIdByGroupId.get(qItem.Id);
                    }
                    if (qItem.Grouping__c == null){
                        qItem.Grouping__c = qutgrpid;
                    }
                    system.debug('qItem--qItem.Grouping__c--------> ' + qItem.Grouping__c);
                    if (poMap.containsKey(qItem.buildertek__RFQ__c)){
                        qItem.buildertek__Purchase_Order__c = poMap.get(qItem.buildertek__RFQ__c);
                    }
                }
            } else{
                List<Quote_Line_Group__c> qutGroup;
                if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                    qutGroup = [SELECT Id
                                FROM Quote_Line_Group__c
                                WHERE Name = 'No Grouping'];
                }
                system.debug('qutGroup ----------> ' + qutGroup);
                if (qutGroup.size() > 0){
                    for (buildertek__Quote_Item__c qItem : quoteItemsToInsert){
                        if (qItem.Grouping__c == null){
                            qItem.Grouping__c = qutGroup[0].Id;
                        }
                        if (poMap.containsKey(qItem.buildertek__RFQ__c)){
                            qItem.buildertek__Purchase_Order__c = poMap.get(qItem.buildertek__RFQ__c);
                        }
                    }
                } else{
                    Quote_Line_Group__c quoteGroup = new Quote_Line_Group__c();
                    if (Schema.sObjectType.Quote_Line_Group__c.fields.Name.isCreateable()){
                        quoteGroup.Name = 'No Grouping';
                    }
                    if (Schema.sObjectType.Quote_Line_Group__c.isCreateable() && Schema.sObjectType.Quote_Line_Group__c.fields.Name.isCreateable()){
                        insert quoteGroup;
                    }
                    system.debug('quoteGroup ----------> ' + quoteGroup);
                    for (buildertek__Quote_Item__c qItem : quoteItemsToInsert){
                        qItem.Grouping__c = quoteGroup.Id;
                        if (poMap.containsKey(qItem.buildertek__RFQ__c)){
                            qItem.buildertek__Purchase_Order__c = poMap.get(qItem.buildertek__RFQ__c);
                        }
                        quoteItemsToInsert.add(qItem);
                    }
                }
            }
            System.debug('quoteItemsToInsert' + quoteItemsToInsert);
            insert quoteItemsToInsert;
            List<buildertek__RFQ_Item__c> rfqLinesList =[Select Id ,buildertek__RFQ_Package__c  , buildertek__Quote_Item__c ,Name From buildertek__RFQ_Item__c where buildertek__RFQ_Package__c=:rfqIds];


            for (buildertek__Quote_Item__c qItem : quoteItemsToInsert){
                qItem.buildertek__RFQ__c=qItem.buildertek__Quote__c;
                for(buildertek__RFQ_Item__c rfqline:rfqLinesList){
                    rfqline.buildertek__Quote_Item__c=qItem.Id;
                }
            }
            update rfqLinesList;

            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
        return null;
    }

    // @AuraEnabled
    // public static List<buildertek__Quote_Item__c> saveQuoteLineItemsValues(String quoteRec, Decimal markupvalue, Decimal marginvalue){
    //     system.debug(quoteRec + '<-----markup value----->' + markupvalue);
    //     system.debug(quoteRec + '<-----margin value----->' + marginvalue);
    //     List<buildertek__Quote_Item__c> quoteItemListRec;

    //     quoteItemListRec = [select Name, buildertek__Product__c, buildertek__Margin_To_Markup__c, buildertek__Quote__c, buildertek__Grouping__c, buildertek__UOM__c, buildertek__Unit_Cost__c, buildertek__Unit_Price__c, buildertek__Quantity__c, buildertek__Cost_Code__c, buildertek__Markup__c,buildertek__Margin__c
    //                         from buildertek__Quote_Item__c
    //                         where buildertek__Quote__c = :quoteRec];
    //     System.debug(quoteItemListRec + 'LIST');
    //     //* sakina's new code 
    //     // List<buildertek__Quote_Item__c> newQuoteItemListRec = new List<buildertek__Quote_Item__c>();

    //     // for (buildertek__Quote_Item__c quoteItem : quoteItemListRec){
    //     //     quoteItem.buildertek__Markup__c = markupvalue;
    //     //     quoteItem.buildertek__Margin__c = marginvalue;
    //     //     newQuoteItemListRec.add(quoteItem);
    //     // }
    //     // if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isupdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Margin__c.isupdateable()){
    //     //     System.debug('<<<<----In If Block---->>>>');
    //     //     update newQuoteItemListRec;
    //     //     System.debug('Update Successfully');
    //     //     System.debug('quoteItemListRec----->'+newQuoteItemListRec);

    //     //     for (buildertek__Quote_Item__c quoteLine : newQuoteItemListRec) {
    //     //         System.debug('quoteLine ==> '+quoteLine);
    //     //         System.debug('quoteLine Markup -> '+quoteLine.buildertek__Markup__c );
    //     //         System.debug('quoteLine Margin -> '+quoteLine.buildertek__Margin__c );

    //     //     }
    //     // }

    //     // return newQuoteItemListRec;

    //     for (buildertek__Quote_Item__c quoteItem : quoteItemListRec){

    //         system.debug(quoteRec + 'Markup value----->' + markupvalue);
    //         system.debug(quoteRec + 'Margin value----->' + marginvalue);
    //         System.debug(quoteItem + 'Item Quote');
    //         System.debug('quoteItem.buildertek__Markup__c====>>>'+quoteItem.buildertek__Markup__c);
    //         System.debug(quoteItem.buildertek__Markup__c == null);
    //         System.debug(quoteItem.buildertek__Markup__c <= 0);
    //         if (quoteItem.buildertek__Markup__c == null || quoteItem.buildertek__Markup__c <= 0){
    //             System.debug('----1st If----');
    //             quoteItem.buildertek__Markup__c = markupvalue;
    //             System.debug('quoteItem.buildertek__Markup__c---->>>>'+quoteItem.buildertek__Markup__c);
    //         }
    //         if (quoteItem.buildertek__Margin__c == null || quoteItem.buildertek__Margin__c <= 0){
    //             System.debug('----2nd If----');
    //             quoteItem.buildertek__Margin__c = marginvalue;
    //             System.debug('quoteItem.buildertek__Margin__c--->>>'+quoteItem.buildertek__Margin__c);
    //         }
    //         // update quoteItem;
    //         // System.debug('Update Successfully');
    //         // quoteItemListRec.add(quoteItem);
    //     }
    //     // update quoteItemListRec;
    //     //* old code
    //     for(buildertek__Quote_Item__c qutoeitem : quoteItemListRec ){
    //         System.debug(qutoeitem.Name+ ' :::::::::::---> '+ qutoeitem.buildertek__Markup__c);
    //     }
    //     update quoteItemListRec;
    //     System.debug('=======AFTER UPDATE MARKUP VALUE IS=======');
    //     for(buildertek__Quote_Item__c qutoeitem : quoteItemListRec ){
    //         System.debug(qutoeitem.Name+ ' :::::::::::---> '+ qutoeitem.buildertek__Markup__c);
    //     }

    //     if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isupdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Margin__c.isupdateable()){
    //         System.debug('<<<<----In If Block---->>>>');
    //         // update quoteItemListRec;
    //     }

    //     return quoteItemListRec;
    // }

    @AuraEnabled
    public static List<buildertek__Quote_Item__c> saveQuoteLineItemsValues(String quoteRec, Decimal markupvalue, Decimal marginvalue){
        //get all the buildertek__Quote_Item__c records for the quote
        List<buildertek__Quote_Item__c> quoteItemListRec;
        quoteItemListRec = [select Name, buildertek__Product__c, buildertek__Margin_To_Markup__c, buildertek__Quote__c, buildertek__Grouping__c, buildertek__UOM__c, buildertek__Unit_Cost__c, buildertek__Unit_Price__c, buildertek__Quantity__c, buildertek__Cost_Code__c, buildertek__Markup__c,buildertek__Margin__c
                            from buildertek__Quote_Item__c
                            where buildertek__Quote__c = :quoteRec];

        for (buildertek__Quote_Item__c quoteItem : quoteItemListRec){
            if(markupvalue != null){
                if (quoteItem.buildertek__Markup__c == null || quoteItem.buildertek__Markup__c <= 0 ){
                    quoteItem.buildertek__Markup__c = markupvalue;
                    System.debug(quoteItem.Name +'---->>>>'+quoteItem.buildertek__Markup__c);
                }
            }
            if(marginvalue != null){
                if (quoteItem.buildertek__Margin__c == null || quoteItem.buildertek__Margin__c <= 0 ){
                    quoteItem.buildertek__Margin__c = marginvalue;
                }
            }

        }

        //update the quote line items
        update quoteItemListRec;

        return quoteItemListRec;

    }
   
    @AuraEnabled
    public static string insertQuoteLines(List<Quote_Item__c> quoteLines){
        try{
            if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isCreateable()){

                insert quoteLines;
            }
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
        return 'success';
    }

    @AuraEnabled
    public static QuoteLinesController.SearchResult getLookupData(String strObject, String strSearch){
        return QuoteLinesController.getLookupData(strObject, strSearch);
    }

    @AuraEnabled
    public static QuoteLinesController.BaseData getBaseData(){
        return QuoteLinesController.getBaseData();
    }

    @AuraEnabled
    public static QuoteLinesController.ResponseBase insertQuoteLineItem(string quoteItem){
        // List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        // quoteItemList.add(quoteItem);
        buildertek__Quote_Item__c quoteItemRec = new buildertek__Quote_Item__c();
        quoteItemRec = (buildertek__Quote_Item__c)System.JSON.deserialize(quoteItem, buildertek__Quote_Item__c.class);
        return QuoteLinesController.insertQuoteLineItem(quoteItem);
    }

    /** Developer Name : Sachin Dond
     Date : 24/7/2018
     **/
    // @AuraEnabled
    // public static List<sObject> getProductRecords(String searchKeyWord, String ObjectName, String filter, string parentId, string prodctfamly){
    //     system.debug('ObjectName-->' + ObjectName);
    //     String searchKey = '%'+ searchKeyWord + '%';
    //     List<sObject> returnList = new List<sObject>();
    //     String sQuery;

    //     if (ObjectName == 'Product2' && parentId != null){
    //         list<string> ProdIds = new list<string>();
    //         list<pricebookEntry> PElist;
    //         system.debug('prodctfamly---->' + prodctfamly);
    //         if (prodctfamly != '--None--'){
    //             PElist = [select id, Product2Id, product2.family
    //                       from pricebookEntry
    //                       where pricebook2Id = :parentId AND toLabel(product2.family) = :prodctfamly];
    //         } else{
    //             PElist = [select id, Product2Id, product2.family
    //                       from pricebookEntry
    //                       where pricebook2Id = :parentId AND toLabel(product2.family) = :null];
    //         }
    //         System.debug('PElist'+ PElist);
    //         for (pricebookEntry PE : PElist){
    //             ProdIds.add(PE.Product2Id);
    //         }
    //         if (filter != null){
    //             filter = filter + ' AND Id IN: ProdIds';
    //         }
    //          else{
    //             filter = 'Id IN: ProdIds';
    //         }
    //     }
    //     if (filter != null){
    //         sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND ' + filter + ' order by Name ASC limit 5';
    //     } else{
    //         System.debug('Inisde 2nd one');
    //         sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by Name ASC limit 5';
    //     }
    //     system.debug('searchKey --------> ' + searchKey);
    //     system.debug('sQuery --------> ' + sQuery);
    //     List<sObject> lstOfRecords;
    //     lstOfRecords = Database.query(sQuery);
    //     for (sObject obj : lstOfRecords){
    //         returnList.add(obj);
    //     }
    //     return returnList;
    // }
    
    @AuraEnabled
    public static List<sObject> getTasksInSchedule(String searchKeyWord, String ObjectName, String filter, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery;
        List<buildertek__Project_Task__c> taskList = new List<buildertek__Project_Task__c>();
        if (ObjectName == 'buildertek__Project_Task__c' && parentId != null){
            list<string> taskIds = new list<string>();
           
                taskList = [select Id, buildertek__Schedule__c, Name,buildertek__Dependency__c
                          from buildertek__Project_Task__c
                          where buildertek__Schedule__c = :parentId];
                          
            for (buildertek__Project_Task__c PE : taskList){
                taskIds.add(PE.Id);
            }
            
            system.debug(taskIds);
            if (filter != null){
                filter = filter + ' AND Id IN: taskIds';
            } else{
                filter = 'Id IN: taskIds';
            }
        }
        if (filter != null){
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND ' + filter + ' order by Name ASC limit 5';
        } else{
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by Name ASC limit 5';
        }
        system.debug('searchKey --------> ' + searchKey);
        system.debug('sQuery --------> ' + sQuery);
        List<sObject> lstOfRecords;
        
        lstOfRecords = Database.query(sQuery);
        for (sObject obj : lstOfRecords){
            system.debug(obj);
            returnList.add(obj);
        }
        return returnList;
    }
    
   @AuraEnabled
    public static buildertek__Project_Task__c getTaskName(string recId){
        system.debug(recId);
        buildertek__Project_Task__c conRec = new buildertek__Project_Task__c();
        if(recId != '' && recId != null){
            Id recorId = Id.valueOf(recId);
            system.debug(recorId);
            conRec = [Select Id,Name From buildertek__Project_Task__c Where Id =: recorId];
            system.debug(conRec);
        }
        if(conRec != null){
            return conRec;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static List<sObject> getContractResource(String searchKeyWord, String ObjectName, String filter, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery;
        List<Contact> conList = new List<Contact>();
        if (ObjectName == 'Contact' && parentId != null){
            list<string> ConIds = new list<string>();
           
                conList = [select Id, AccountId, Name
                          from Contact
                          where AccountId = :parentId];
                          
            for (Contact PE : conList){
                ConIds.add(PE.Id);
            }
            
            system.debug(ConIds);
            if (filter != null){
                filter = filter + ' AND Id IN: ConIds';
            } else{
                filter = 'Id IN: ConIds';
            }
        }
        if (filter != null){
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND ' + filter + ' order by Name ASC limit 5';
        } else{
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by Name ASC limit 5';
        }
        system.debug('searchKey --------> ' + searchKey);
        system.debug('sQuery --------> ' + sQuery);
        List<sObject> lstOfRecords;
        /*if(ObjectName == 'Product2'){
         if(Schema.sObjectType.Product2.fields.Id.isAccessible() &&
         Schema.sObjectType.Product2.fields.Name.isAccessible() ){

         lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
         }
         }else{*/
        lstOfRecords = Database.query(sQuery);
        
        /*}*/
        for (sObject obj : lstOfRecords){
            system.debug(obj);
            returnList.add(obj);
        }
        return returnList;
    }
    
    
    @AuraEnabled
    public static Contact getContactName(string recId){
        system.debug(recId);
        Contact conRec = new Contact();
        if(recId != '' && recId != null){
            Id recorId = Id.valueOf(recId);
            system.debug(recorId);
            conRec = [Select Id,Name From Contact Where Id =: recorId];
            system.debug(conRec);
        }
        if(conRec != null){
            return conRec;
        }
        return null;
    }
    
   
 
    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId, String pricebookId){
        System.debug('########pricebook' + productId);
        list<PricebookEntry> pList = new list<PricebookEntry>();

        pList = [select id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Product2Id, Product2.buildertek__Quote_Group__r.Name, Product2.QuantityUnitOfMeasure	
                 from PricebookEntry
                 where product2Id = :productId and pricebook2Id =: pricebookId];

        system.debug('====pList' + pList);
        return pList;
    }
    
    @AuraEnabled
    public static string  getProductUOM(string productId){
        Product2 productRec = new Product2();
        productRec = [select id,QuantityUnitOfMeasure,Name
                 from Product2
                 where Id = :productId];
        return productRec.QuantityUnitOfMeasure;
    }

    @AuraEnabled
    public static buildertek__Quote_Item__c saveQuoteLineItem(string quoteLineRecord){
        System.debug('------------------ saveQuoteLineItem ------------------');
        System.debug('---quote Items' + quoteLineRecord);
        buildertek__Quote_Item__c QuoteRec = new buildertek__Quote_Item__c();
        QuoteRec = (buildertek__Quote_Item__c)System.JSON.deserialize(quoteLineRecord, buildertek__Quote_Item__c.class);
        if (QuoteRec.buildertek__Grouping__c == null){
            List<buildertek__Quote_Line_Group__c> QuoteGroup;
            if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                QuoteGroup = [select Id
                              from buildertek__Quote_Line_Group__c
                              where Name = 'No Grouping'];
            }
            if (QuoteGroup.size() > 0){
                QuoteRec.buildertek__Grouping__c = QuoteGroup[0].Id;
            } else{
                buildertek__Quote_Line_Group__c qutGroup = new buildertek__Quote_Line_Group__c();
                if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                    qutGroup.Name = 'No Grouping';
                }
                insert qutGroup;
                QuoteRec.buildertek__Grouping__c = qutGroup.Id;
            }

        }

        if (QuoteRec.buildertek__Product__c != null){
            List<product2> prdctrec = [SELECT id, Name, buildertek__Cost_Code__c
                                        FROM product2
                                        where Id = :QuoteRec.buildertek__Product__c];

            if (prdctrec.size() > 0) {
                QuoteRec.buildertek__Cost_Code__c = prdctrec[0].buildertek__Cost_Code__c;
            }
        }
        buildertek__Quote_Item__c QuoteLineToInsert = new buildertek__Quote_Item__c();

        //string Quotename =  QuoteRec.Name;

        QuoteLineToInsert.buildertek__Product__c = QuoteRec.buildertek__Product__c;
        if (QuoteRec.Name != null && QuoteRec.Name.length() > 79){
            QuoteLineToInsert.Name = QuoteRec.Name.left(78);
            QuoteLineToInsert.buildertek__Description__c = QuoteRec.Name;
        } else{
            QuoteLineToInsert.Name = QuoteRec.Name;
        }
        
        QuoteLineToInsert.buildertek__Quote__c = QuoteRec.buildertek__Quote__c;
        QuoteLineToInsert.buildertek__Grouping__c = QuoteRec.buildertek__Grouping__c;
        QuoteLineToInsert.buildertek__UOM__c = QuoteRec.buildertek__UOM__c;
        QuoteLineToInsert.buildertek__Unit_Cost__c = QuoteRec.buildertek__Unit_Cost__c;
        QuoteLineToInsert.buildertek__Unit_Price__c = QuoteRec.buildertek__Unit_Price__c;
        QuoteLineToInsert.buildertek__Quantity__c = QuoteRec.buildertek__Quantity__c;
        QuoteLineToInsert.buildertek__Notes__c = QuoteRec.buildertek__Notes__c;
        QuoteLineToInsert.buildertek__Cost_Code__c = QuoteRec.buildertek__Cost_Code__c;
        QuoteLineToInsert.buildertek__Margin__c = QuoteRec.buildertek__Margin__c;
        QuoteLineToInsert.buildertek__Markup__c = QuoteRec.buildertek__Markup__c;
        QuoteLineToInsert.buildertek__Additional_Discount__c = QuoteRec.buildertek__Additional_Discount__c;

        

        QuoteLineToInsert.buildertek__Product_Family__c = QuoteRec.buildertek__Product_Family__c != 'None' ? QuoteRec.buildertek__Product_Family__c:'No Grouping';

        System.debug('---Budget Line Items recordId 321--> ' + QuoteLineToInsert);

        insert QuoteLineToInsert;

        if(QuoteLineToInsert.buildertek__Markup__c !=0.0000){
            QuoteLineToInsert.buildertek__Margin__c = QuoteRec.buildertek__Margin__c;
        }
        update QuoteLineToInsert;

        return QuoteLineToInsert;
    }

    @AuraEnabled
    public static String updateDescription(string groupId, String groupDescription){
        try{
            buildertek__Quote_Line_Group__c quoteGroup = new buildertek__Quote_Line_Group__c();
            quoteGroup.Id = groupId;
            quoteGroup.buildertek__Description__c = groupDescription;
            update quoteGroup;
            return 'Success';
        } catch (Exception e){
            System.debug('Error::'+e.getMessage());
            System.debug('Line::'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Error';
    }

    @AuraEnabled
    public static String updateGroupName(string groupId,String groupName){
        try{
            if(String.isNotBlank(groupId)){
                List<buildertek__Quote_Line_Group__c> quoteLineGroups = [Select id FROM buildertek__Quote_Line_Group__c WHERE Id != : groupId AND  Name =: groupName];
                if(quoteLineGroups.size() == 0){
                    buildertek__Quote_Line_Group__c quoteLineGroup = new buildertek__Quote_Line_Group__c();
                    quoteLineGroup.Id = groupId;
                    quoteLineGroup.Name = groupName;
                    update quoteLineGroup;
                    return 'Success';
                }else{
                    return 'Warning';
                }
            }
        } catch (Exception e){
            System.debug('Error::'+e.getMessage());
            System.debug('Line::'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Error';
    }

    @AuraEnabled(cacheable = true)
    public static object retrieveGroups(string quoteId, Decimal pageNumber, Integer recordToDisply, String status){
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        quoteDetails Detail = new quoteDetails();
        Detail.groups = getQuoteGroupDetails(quoteId, null, recordToDisply, offset , status);
        Detail.columns = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Quote_Item__c', 'buildertek__BT_Related_List_View_Fields');

        List<String> groupIds = new List<String>();
        List<String> allFields = new List<String>();
        List<String> fieldsList = new List<String>();
        String fieldsType = '[';
        List<String> fieldsTypeList = new List<String>();
        for (quote_line_group__c grp : Detail.groups){
            groupIds.add(grp.Id);
        }
        for (BT_Lightning_Utils.dataTableFields dtFields : Detail.columns){
            if (dtFields.type != 'reference'){
                allFields.add(dtFields.fieldName);
            }
            if (dtFields.type == 'currency' && dtFields.fieldName != 'buildertek__Tax__c'){
                fieldsList.add(dtFields.fieldName);
            } else if(dtFields.fieldName == 'buildertek__Quantity__c'){
                fieldsList.add(dtFields.fieldName);
            }
            if (dtFields.type == 'reference'){
                allFields.add(dtFields.fieldName.replace('__c', '__r.Name'));
            }
            fieldsType += '{"fieldName": "' + dtFields.fieldName + '","fieldType": "' + dtFields.type + '","isEditable":' + dtFields.editable + '},';
        }
        allFields.add('Id');
        allFields.add('buildertek__Grouping__c');
        fieldsType += '{"fieldName": "buildertek__Grouping__c","fieldType": "Reference","isEditable": false},';
        fieldsType += '{"fieldName": "Id","fieldType": "","isEditable": false}]';

        List<wrapperClass> wrapperList = new List<wrapperClass>();
        wrapperList = groupValues(quoteId, fieldsList, allFields, groupIds, recordToDisply, offset ,status );
        TargetTable tarTable = new TargetTable();
        //List<FieldClass> fieldClassList = (List<FieldClass>)System.JSON.deserialize(fieldsType, List<FieldClass>.class);
        tarTable = getQuoteItemData(quoteId, allFields, fieldsType, recordToDisply, offset , status);
        FinalWrapperClass wrap = new FinalWrapperClass();
        wrap.tarTable = tarTable;
        wrap.wrapperList = wrapperList;
        wrap.columns = Detail.columns;
        wrap.totalColumns = Detail.columns.size() / 2;
        wrap.Totalcols = Detail.columns.size()+3;

        wrap.groups = Detail.groups;
        wrap.pageSize = pageSize;
        wrap.page = (Integer)pageNumber;
        wrap.total = [SELECT count()
                      FROM buildertek__Quote_Item__c
                      WHERE buildertek__Quote__c = :quoteId];
        //  wrap.status=status;
        //FinalWrapperClass wrap = new FinalWrapperClass();
        return wrap;
    }

    /*@AuraEnabled
     public static quote_line_group__c updateLineFromDataTable(String items, String groupId, String quoteId){
     if(items.contains('%')){
     items = items.replace('%','');
     }
     update (List<Quote_Item__c>)System.JSON.deserialize(Items, List<Quote_Item__c>.class);
     return getQuoteGroupDetails(quoteId, groupId, recordToDisply, offset)[0];
     }*/
    public static List<quote_line_group__c> getQuoteGroupDetails(String quoteId, String groupId, Decimal recordToDisply, Integer offset , string status){
        List<quote_line_group__c> budgetGroup;
        // Add selected field in soql from field set
        String objectName = 'buildertek__Quote_Item__c';
        String filterConditions = ' AND buildertek__Quote__c =:quoteId';
        String fieldSetAPI = 'buildertek__BT_Related_List_View_Fields';
        String soql = 'SELECT Id, Name ';
        soql = soql + ', buildertek__Grouping__c, buildertek__Description__c ';

        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
        system.debug('fieldSetMemberList -----> ' + fieldSetMemberList);
        for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            System.debug('soql sakina'+ soql);

            if (!soql.contains(fieldSetMemberObj.getFieldPath())){
                system.debug('fieldSetMemberObj ********' + fieldSetMemberObj.getFieldPath());
                soql = soql + ',' + fieldSetMemberObj.getFieldPath();
            }

            if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE'){
                if (!fieldSetMemberObj.getFieldPath().Contains('__c')){
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
                } else{
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
                }
            }
        }
        soql = soql + ' FROM buildertek__Quote_Item__c';
        // string status = 'Accept';
        soql = soql + ' WHERE buildertek__Quote__c =: quoteId AND buildertek__status__c =: status ORDER BY buildertek__Grouping__r.buildertek__Sort_Id__c,buildertek__Grouping__r.Name  ASC limit ' + recordToDisply + ' OFFSET ' + offset;

        List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        /* if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/
        quoteItemList = Database.query(soql);
        /*}*/
        system.debug(quoteItemList.size()+'----quoteItemList ------------> ' + quoteItemList);
        SET<Id> groupIdSet = new SET<Id>();
        for (buildertek__Quote_Item__c quoteItem : quoteItemList){
            groupIdSet.add(quoteItem.Grouping__c);
        }
        /*List<quote_line_group__c> budgetGroup;

         String query = 'SELECT Id, Name ';
         query = query + ', Grouping__c, Description__c, Product__c ';

         String namespacePrefix1 = BT_Utils.getNamespacePrefix();
         List<Schema.FieldSetMember> fieldSetMemberList1 = BT_Utils.getFieldSetMembers(fieldSetAPI,objectName);
         system.debug('fieldSetMemberList -----> '+fieldSetMemberList1);
         for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList1)
         {

         if(!query.contains(fieldSetMemberObj.getFieldPath())){
         system.debug('fieldSetMemberObj ********' + fieldSetMemberObj.getFieldPath());
         query = query+ ',' + fieldSetMemberObj.getFieldPath();
         }

         if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE') {
         if (!fieldSetMemberObj.getFieldPath().Contains('__c')) {
         query = query+ ',' + fieldSetMemberObj.getFieldPath().replace('Id','.Name');
         } else {
         query = query+ ',' + fieldSetMemberObj.getFieldPath().replace('__c','__r.Name');
         }
         }
         }
         query = query + ' FROM BT_Quote_Items__r';
         if(quoteId != null) {
         query = query + ' WHERE Id != null AND buildertek__Quote__c =: quoteId ORDER BY Name ASC';
         }else {
         query = query + ' WHERE Id != null AND  ORDER BY Name ASC';
         }*/

        if (groupId != null){
            If (Schema.sObjectType.buildertek__quote_line_group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__quote_line_group__c.fields.Name.isAccessible()){
                budgetGroup = Database.query('Select Id, Name, buildertek__Description__c,buildertek__Sort_Id__c From quote_line_group__c where Id =: groupId  ORDER BY buildertek__Sort_Id__c,Name ASC');
            }
        } else{
            If (Schema.sObjectType.buildertek__quote_line_group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__quote_line_group__c.fields.Name.isAccessible()){
                budgetGroup = Database.query('Select Id, Name,buildertek__Description__c,buildertek__Sort_Id__c From quote_line_group__c where Id IN: groupIdSet ORDER BY buildertek__Sort_Id__c,Name ASC');
            }
        }
        system.debug('budgetGroup ----------> ' + budgetGroup);
        return budgetGroup;
    }

    @AuraEnabled
    public static List<fieldSet> getFieldSet(String fieldSetName, String objectName){
        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<fieldSet> fieldSet = new List<fieldSet>();
        Schema.DescribeFieldResult describeFieldResult;

        List<Schema.FieldSetMember> fieldSetMembers = BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+fieldSetName, namespacePrefix + objectName);
        Map<String, Schema.SObjectField> sobjectFieldsByName = Schema.getGlobalDescribe().get(namespacePrefix + objectName).getDescribe().fields.getMap();

        if (!fieldSetMembers.isEmpty()){
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
                describeFieldResult = sobjectFieldsByName.get(fieldSetMember.getFieldPath()).getDescribe();
                fieldSet.Add(new fieldSet(fieldSetMember.getLabel(), fieldSetMember.getFieldPath(), describeFieldResult.isHtmlFormatted(), fieldSetMember.getRequired()));
            }
        }

        return fieldSet;
    }

    @AuraEnabled
    public static string insertQuoteLineGroup(String groupName, String groupDescription){
        try {
            if(String.isNotBlank(groupName)){
                buildertek__Quote_Line_Group__c quoteLineGroup = new buildertek__Quote_Line_Group__c();
                quoteLineGroup.Name = groupName;
                quoteLineGroup.buildertek__Description__c  = groupDescription;
                insert quoteLineGroup;
                return 'Success';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'Error';
    }

    @AuraEnabled
    public static buildertek__Quote_Item__c getQuoteItem(string QuoteLineRecord){
        buildertek__Quote_Item__c QuoteItem;
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Discount__c.isAccessible() && Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible()){
            QuoteItem = [select Id, Name, buildertek__Product__r.Name, buildertek__Product__c, buildertek__Quote__c, buildertek__Cost_Code__r.buildertek__Cost_Code_Name__c, buildertek__Cost_Code__c, buildertek__Cost_Code__r.Name, buildertek__Grouping__c, buildertek__Grouping__r.Name, buildertek__UOM__c, buildertek__Unit_Cost__c, buildertek__Quantity__c, buildertek__Discount__c
                         from buildertek__Quote_Item__c
                         where Id = :QuoteLineRecord];
        }
        return QuoteItem;
    }

    @AuraEnabled
    public static string getselectOptions(sObject QuoteObject, string QuoteField){
        system.debug('QuoteObject --->' + QuoteObject);
        system.debug('QuoteField --->' + QuoteField);
        Schema.sObjectType objType = QuoteObject.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(QuoteField).getDescribe().getPickListValues();

        list<QuoteClass> allQuoteOptions = new list<QuoteClass>();
        integer i = 1;
        for (Schema.PicklistEntry a : values){
            QuoteClass allQuoteOption = new QuoteClass();
            allQuoteOption.Id = a.getLabel();
            allQuoteOption.values = a.getValue();
            allQuoteOptions.add(allQuoteOption);
            i++;
        }
        String AllQuotevalues = json.serialize(allQuoteOptions);
        system.debug('allOpts ---->' + allQuoteOptions);
        //allOpts.sort();
        return AllQuotevalues;
    }

    @AuraEnabled
    public static buildertek__Quote__c getQuoteRecord(String quoteRecId){
        List<buildertek__Quote__c> quoteRecs;
        If (Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Markup__c.isAccessible()){
            quoteRecs = [select id, Name, buildertek__Markup__c
                         from buildertek__Quote__c
                         where id = :quoteRecId];
        }
        if (quoteRecs.size() > 0){
            return quoteRecs[0];
        }
        return null;
    }

    @AuraEnabled
    public static buildertek__Quote__c saveQuoteSingleRec(String quoteRec){
        buildertek__Quote__c quoteRecs = (buildertek__Quote__c)Json.deserialize(quoteRec, buildertek__Quote__c.class);
        if (Schema.sObjectType.buildertek__Quote__c.isUpdateable() && Schema.sObjectType.buildertek__Quote__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Opportunity__c.isUpdateable() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary_Contact__c.isUpdateable() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Product__c.isUpdateable()){
            update quoteRecs;
        }
        List<buildertek__Quote_Item__c> QuoteItems;
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible()){
            QuoteItems = [select Id, Name, buildertek__Quote__c, buildertek__Markup__c
                          from buildertek__Quote_Item__c
                          where buildertek__Quote__c = :quoteRecs.Id];
        }
        if (quoteRecs.buildertek__Markup__c != 0 && quoteRecs.buildertek__Markup__c != null){
            for (buildertek__Quote_Item__c Qi : QuoteItems){
                if (Qi.buildertek__Markup__c == 0 || Qi.buildertek__Markup__c == null){
                    Qi.buildertek__Markup__c = quoteRecs.buildertek__Markup__c;
                }
            }
            if (QuoteItems.size() > 0){
                if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isUpdateable()){
                    update QuoteItems;
                }
            }
        }
        return quoteRecs;
    }

    @AuraEnabled
    public static void massDuplicateQuoteLineItem(List<string> quoteLineRecords){
        List<String> quoteLineItemRecs = quoteLineRecords;
        // List<buildertek__Quote_Item__c> lstRecs= [select id,name from buildertek__Quote_Item__c where id in :quoteLineItemRecs];

        String query = '';
        String SobjectApiName = 'buildertek__Quote_Item__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();

        String strFields = '';

        for (String fieldName : fieldMap.keyset()){
            if (strFields == null || strFields == ''){
                strFields = fieldName;
            } else{
                strFields = strFields + ',' + fieldName;
            }
        }

        query = 'select ' + strFields + ' from ' + SobjectApiName + ' where id in :quoteLineItemRecs';

        List<buildertek__Quote_Item__c> lstRecs;
        /*if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/

        lstRecs = Database.query(query);
        /*}*/
        List<buildertek__Quote_Item__c> lstRecsClone = lstRecs.deepClone();
        if (lstRecsClone.size() > 0){
            if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable()){

                insert lstRecsClone;
            }
        }
    }

    @AuraEnabled
    public static void massUpdateQuoteLineItem(string quoteLineRecords){
        System.debug('quoteLineRecords ::' + quoteLineRecords);
        List<buildertek__Quote_Item__c> QuoteRecs = new List<buildertek__Quote_Item__c>();
        QuoteRecs = (List<buildertek__Quote_Item__c>)System.JSON.deserialize(quoteLineRecords, List<buildertek__Quote_Item__c>.class);
        System.debug('QuoteRecs------->>>>'+QuoteRecs);
        if (QuoteRecs.size() > 0){

            update QuoteRecs;

        }
    }

    @AuraEnabled
    public static void updateQuoteLineItem(string QuoteLineRecord){
        System.debug('---Quote Line Items' + QuoteLineRecord);
        system.debug('Created QuoteLineRecord: ' + QuoteLineRecord);
        // List<buildertek__Quote_Item__c> QuoteLineRecordListref = new List<buildertek__Quote_Item__c>();
        // QuoteLineRecordListref.add(QuoteLineRecord);
        if (QuoteLineRecord.contains('%')){
            QuoteLineRecord = QuoteLineRecord.replace('%', '');
            system.debug('QuoteLineRecord --------> ' + QuoteLineRecord);
        }
        buildertek__Quote_Item__c QuoteRec = new buildertek__Quote_Item__c();
        QuoteRec = (buildertek__Quote_Item__c)System.JSON.deserialize(QuoteLineRecord, buildertek__Quote_Item__c.class);
        if (QuoteRec.buildertek__Grouping__c == null){
            List<buildertek__Quote_Line_Group__c> QuoteGroup;
            If (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                QuoteGroup = [select Id, Name
                              from buildertek__Quote_Line_Group__c
                              where Name = 'No Grouping'];
            }

            if (QuoteGroup.size() > 0){
                QuoteRec.buildertek__Grouping__c = QuoteGroup[0].Id;
            } else{
                buildertek__Quote_Line_Group__c qutGroup = new buildertek__Quote_Line_Group__c();
                if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                    qutGroup.Name = 'No Grouping';
                }
                insert qutGroup;
                QuoteRec.buildertek__Grouping__c = qutGroup.Id;
            }

        }
        /*if(QuoteRec.buildertek__Grouping__c != null){
         buildertek__Quote_Line_Group__c QuoteGroup = [select Id, Name from buildertek__Quote_Line_Group__c where Id =: QuoteRec.buildertek__Grouping__c];
         system.debug('Group Name ----> '+QuoteGroup.Name);
         buildertek__Quote_Line_Group__c newQuoteGroup = new buildertek__Quote_Line_Group__c();
         if(QuoteGroup != null){
         system.debug('Group Name 123 ----> '+QuoteGroup.Name);
         if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isUpdateable() &&
         Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isUpdateable()){
        // newQuoteGroup.Id = QuoteGroup.Id;
        // newQuoteGroup.Name = QuoteGroup.Name;
         QuoteGroup.buildertek__Quote__c = QuoteRec.buildertek__Quote__c;
         }
         update QuoteGroup;
         }else{
         if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isCreateable()){
         newQuoteGroup.Name = QuoteGroup.Name;
         newQuoteGroup.buildertek__Quote__c = QuoteRec.buildertek__Quote__c;
         insert newQuoteGroup;
         }
         }
         }*/
        buildertek__Quote_Item__c QuoteLineToInsert = new buildertek__Quote_Item__c();
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isUpdateable()){
            // QuoteLineToInsert.Id = QuoteLineRecord.Id;
            // QuoteLineToInsert.buildertek__Product__c = QuoteLineRecord.buildertek__Product__c;
            // QuoteLineToInsert.Name = QuoteLineRecord.Name;
            // QuoteLineToInsert.buildertek__Grouping__c = QuoteLineRecord.buildertek__Grouping__c;
            // QuoteLineToInsert.buildertek__Unit_Cost__c = QuoteLineRecord.buildertek__Unit_Cost__c;
            // QuoteLineToInsert.buildertek__Quantity__c = QuoteLineRecord.buildertek__Quantity__c;
            // QuoteLineToInsert.buildertek__UOM__c  = QuoteLineRecord.buildertek__UOM__c;
            // QuoteLineToInsert.buildertek__Cost_Code__c  = QuoteLineRecord.buildertek__Cost_Code__c;
            // QuoteLineToInsert.buildertek__Unit_Price__c = QuoteLineRecord.buildertek__Unit_Cost__c;
            // system.debug('Created QuoteLineRecord: ' + QuoteLineToInsert);
            QuoteLineToInsert = QuoteRec;
            update QuoteLineToInsert;

        }
    }

    @AuraEnabled
    public static ErrorClass cloneQuote(String recordId){
        ErrorClass err = new ErrorClass();
        try{
            String query = 'SELECT ';
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('buildertek__Quote__c').getDescribe().fields.getMap();
            for (String s : objectFields.keySet()){
                query += s + ',';
            }
            system.debug('query 121 -----------> ' + query);
            query = query.removeEnd(',');
            system.debug('query 123 -----------> ' + query);
            query += ' FROM buildertek__Quote__c';
            query += ' WHERE Id =\'' + String.escapeSingleQuotes(recordId)+'\'';
            system.debug('query -----------> ' + query);
            buildertek__Quote__c quote;
            /*         If(Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_City__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Country__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Name__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_State__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Street__c.isAccessible()&&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Zip_Code__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Confidence_of_Contract_COC__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__ContactId__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Date_Sent_To_Customer__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Discount__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Doc_Template__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Body__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Subject__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Template__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Expires_On__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Grand_Total__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Gross_Margin__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Gross_Profit__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Group_Line_Items__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__List_Total__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Markup__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Markup_Amount__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Net_Total_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Opportunity__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Payment_Terms__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary__c.isAccessible()&&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Product__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Profit_Margin__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Number__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Description__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Sales_Rep__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Service_Request__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_City__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Country__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Name__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_State__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Street__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Zip_Code__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Shipping_and_Handling__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__SignatureBase64__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Start_Date__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Subtotal__c.isAccessible()&&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Tax__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Total__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Total_Costs__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Type__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Unit_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Version_Number__c.isAccessible() ){*/
            quote = Database.query(query);
            /*}*/
            system.debug('quote -----------> ' + quote);

            buildertek__Quote__c newQuote = quote.clone(false, true);
            Decimal versionNumber;
            String quoteName = quote.Name;


            if (quote.buildertek__Version_Number__c == null){
                versionNumber = 1.0;
                //newQuote.Name = quote.Name + ' Ver ' + versionNumber;
                newQuote.Name = quote.Name;
                newQuote.buildertek__Version_Number__c = '1.0';
                newQuote.buildertek__Status__c = 'Draft';
            } else{
                versionNumber = Decimal.valueOf(quote.buildertek__Version_Number__c);
                versionNumber = versionNumber + .1;
                //quoteName = quoteName.right(1);
                //quoteName = quoteName.replace(quoteName.right(1), String.valueOf(versionNumber));
                newQuote.buildertek__Version_Number__c = String.valueOf(versionNumber);
                newQuote.buildertek__Status__c = 'Draft';
            }

            if (Schema.sObjectType.buildertek__Quote__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Version_Number__c.isCreateable()){
                insert newQuote;
            }

            String groupQuery = 'SELECT ';
            Map<String, Schema.SObjectField> groupObjectFields = Schema.getGlobalDescribe().get('buildertek__Quote_Line_Group__c').getDescribe().fields.getMap();
            for (String s : groupObjectFields.keySet()){
                groupQuery += s + ',';
            }
            system.debug('query 121 -----------> ' + groupQuery);
            groupQuery = groupQuery.removeEnd(',');
            system.debug('query 123 -----------> ' + groupQuery);
            groupQuery += ' FROM buildertek__Quote_Line_Group__c';
            groupQuery += ' WHERE buildertek__Quote__c =\'' + String.escapeSingleQuotes(quote.Id)+'\'';
            system.debug('query -----------> ' + groupQuery);
            List<buildertek__Quote_Line_Group__c> quoteLineGroup;
            /*If(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Description__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Locked__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Markup__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Number__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isAccessible()&&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Sort_Id__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Target_Price__c.isAccessible() ){*/
            quoteLineGroup = Database.query(groupQuery);
            /*}*/
            system.debug('quoteLineGroup -----------> ' + quoteLineGroup);
            List<buildertek__Quote_Line_Group__c> quoteGroupList = new List<buildertek__Quote_Line_Group__c>();
            for (buildertek__Quote_Line_Group__c groups : quoteLineGroup){

                buildertek__Quote_Line_Group__c quoteGroup = groups.clone(false, true);
                quoteGroup.buildertek__Quote__c = newQuote.Id;
                quoteGroupList.add(quoteGroup);

            }
            if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isCreateable()){
                insert quoteGroupList;
            }
            system.debug('quoteGroupList ---------> ' + quoteGroupList);
            system.debug('quoteGroupList size  ---------> ' + quoteGroupList.size());
            Map<String, String> groupMap = new Map<String, String>();
            Map<String, String> groupNameMap = new Map<String, String>();
            for (buildertek__Quote_Line_Group__c grp : quoteGroupList){
                groupMap.put(grp.buildertek__Quote__c, grp.Id);
                groupNameMap.put(grp.buildertek__Quote__c, grp.Name);
            }

            String childRecordsQuery = 'SELECT ';
            Map<String, Schema.SObjectField> childObjectFields = Schema.getGlobalDescribe().get('buildertek__Quote_Item__c').getDescribe().fields.getMap();
            //debug the childObjectFields
            System.debug('childObjectFields: ' + childObjectFields);
            for (String s : childObjectFields.keySet()){
                childRecordsQuery += s + ',';
            }
            system.debug('query 121 -----------> ' + childRecordsQuery);
            childRecordsQuery = childRecordsQuery.removeEnd(',');
            system.debug('query 123 -----------> ' + childRecordsQuery);
            childRecordsQuery += ',buildertek__Grouping__r.Name FROM buildertek__Quote_Item__c';
            childRecordsQuery += ' WHERE buildertek__Quote__c =\'' + String.escapeSingleQuotes(quote.Id)+'\'';
            system.debug('query -----------> ' + childRecordsQuery);
            List<buildertek__Quote_Item__c> quoteItems;
            /*if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/
            quoteItems = Database.query(childRecordsQuery);
            /*}*/
            system.debug('quote -----------> ' + quoteItems);

            set<Id> groupIdSet = new set<Id>();

            List<buildertek__Quote_Item__c> quoteLineItemList = new List<buildertek__Quote_Item__c>();
            for (buildertek__Quote_Item__c quoteLine : quoteItems){
                if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable()){

                    buildertek__Quote_Item__c quoteLineItems = quoteLine.clone(false, true);
                    quoteLineItems.buildertek__Quote__c = newQuote.Id;
                    // if (quoteLine.buildertek__Grouping__r.Name == groupNameMap.get(newQuote.Id)){
                    //     quoteLineItems.buildertek__Grouping__c = groupMap.get(newQuote.Id);
                    // } else{
                    //     quoteLineItems.buildertek__Grouping__c = groupMap.get(newQuote.Id);
                    // }
                    // quoteLineItems.buildertek__Grouping__c = groupMap.get(quoteLine.buildertek__Quote__c);
                    quoteLineItemList.add(quoteLineItems);

                }

            }
            insert quoteLineItemList;
            system.debug('quoteLineItemList ---------> ' + quoteLineItemList);
            err.Message = 'Success';
            err.RecordId = newQuote.Id;
            return err;
        } catch (Exception exp){
            err.Message = exp.getMessage();
            err.RecordId = '';
            return err;
        }
    }

    public Class QuoteClass{
        @AuraEnabled
        public String Id{ get; set; }

        @AuraEnabled
        public String values{ get; set; }
    }

    @AuraEnabled
    public static void updateGroupsOrder(List<quote_line_group__c> groups){
        try{
            DMLManager.updateAsUser(groups);
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteGroups(List<quote_line_group__c> groups){
        try{
            DMLManager.deleteAsUser(groups);
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static quote_line_group__c deleteItem(List<buildertek__Quote_Item__c> Items, String groupId, String quoteId , String status){
        system.debug('Items ------> ' + Items);
        system.debug('groupId -------> ' + groupId);
        try{
            DMLManager.deleteAsUser(Items);
            system.debug('Quote Line Items ' + getQuoteGroupDetails(quoteId, groupId, 10, 10, status)[0]);
            return getQuoteGroupDetails(quoteId, groupId, 10, 10 , status)[0];
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }

    public class quoteDetails{
        @AuraEnabled
        public List<quote_line_group__c> groups{ get; set; }

        @AuraEnabled
        public List<String> headerFields{ get; set; }

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns{ get; set; }

        public quoteDetails(){
            groups = new List<quote_line_group__c>();
            headerFields = new List<String>();
            columns = new List<BT_Lightning_Utils.dataTableFields>();
        }
    }

    public class fieldSet{
        @AuraEnabled
        public String fieldLabel{ get; set; }

        @AuraEnabled
        public String fieldName{ get; set; }

        @AuraEnabled
        public Boolean isRequired{ get; set; }

        @AuraEnabled
        public Boolean isHtmlFormatted{ get; set; }

        public fieldSet(String fieldLabel, String fieldName, Boolean isHtmlFormatted, Boolean isRequired){
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
            this.isHtmlFormatted = isHtmlFormatted;
            this.isRequired = isRequired;
        }
    }

    @AuraEnabled
    public static void deleteLineItems(list<string> quoteItemIds){
        try{
            list<buildertek__Quote_Item__c> quoteItemLists;
            if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()){
                quoteItemLists = [select id
                                  from buildertek__Quote_Item__c
                                  where id IN :quoteItemIds];
            }
            If (buildertek__Quote_Item__c.sObjectType.getDescribe().isDeletable()){
                delete quoteItemLists;
            }
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ErrorClass{
        @AuraEnabled
        public String Message{ get; set; }

        @AuraEnabled
        public String RecordId{ get; set; }
    }

    public static Id createQuoteFromRFQ(Map<Id, RFQ__c> rfqs){

        Map<Id, Quote__c> rfqToQuotes = new map<Id, Quote__c>();
        String groupId;
        List<Quote_Line_Group__c> qutGroup;
        if (Schema.sObjectType.Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.Quote_Line_Group__c.fields.Name.isAccessible()){
            qutGroup = [SELECT Id
                        FROM Quote_Line_Group__c
                        WHERE Name = 'No Grouping'];
        }
        if (qutGroup.size() > 0){
            groupId = qutGroup[0].Id;
        } else{

            buildertek__Quote_Line_Group__c quoteGroup = new buildertek__Quote_Line_Group__c();
            if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                quoteGroup.Name = 'No Grouping';
            }
            insert quoteGroup;
            groupId = quoteGroup.Id;
        }

        for (buildertek__RFQ__c rfq : rfqs.values()){
            buildertek__Quote__c qt = new buildertek__Quote__c();
            qt.Name = rfq.Name;
            qt.Project__c = rfq.Project__c;
            rfqToQuotes.put(rfq.id, qt);
        }
        if (Schema.sObjectType.buildertek__Quote__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isCreateable()){
            insert rfqToQuotes.values();
        }

        List<Quote_Item__c> qtItems = new List<Quote_Item__c>();
        for (RFQ__c rfq : rfqs.values()){
            System.debug('Inside RFQ');
            System.debug(rfq);

            for (RFQ_Item__c rfqItem : rfq.RFQ_Items__r){

                Quote_Item__c qtItem = new Quote_Item__c();

                fillqtItemFromRFQItem(qtItem, rfqItem, groupId);
                if (Schema.sObjectType.Quote_Item__c.fields.Quote__c.isCreateable()){
                    qtItem.Quote__c = rfqToQuotes.get(rfq.Id).Id;
                    qtItems.add(qtItem);
                }
            }
        }

        QuoteTriggerHandler.blnSkipQuoteUpdateTrigger = true;
        insert qtItems;
        QuoteTriggerHandler.blnSkipQuoteUpdateTrigger = false;

        return rfqToQuotes.values()[0].ID;
    }

    // FILL PO ITME DETAILS FROM RFQ ITME
    public static void fillqtItemFromRFQItem(Quote_Item__c qtItem, RFQ_Item__c rfqItem, String groupId){
        qtItem.Name = rfqItem.Name;
        qtItem.Description__c = rfqItem.Description__c;
        qtItem.Cost_Code__c = rfqItem.Cost_Code__c;
        qtItem.Item_Name__c = rfqItem.Name;
        qtItem.buildertek__Notes__c = qtItem.buildertek__Notes__c;
        qtItem.Quantity__c = rfqItem.Quantity__c;
        qtItem.Unit_Price__c = rfqItem.Unit_Price__c;
        qtItem.Unit_Cost__c = rfqItem.Unit_Price__c;
        qtItem.Product__c = rfqItem.Product__c;
        qtItem.Grouping__c = groupId;
    }

    @AuraEnabled
    public static buildertek__Quote_Item__c deleteQuoteItem(String quoteId){
        buildertek__Quote_Item__c quoteItem;
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible()){
            quoteItem = [SELECT Id, Name
                         FROM buildertek__Quote_Item__c
                         WHERE Id = :quoteId];
        }
        If (buildertek__Quote_Item__c.sObjectType.getDescribe().isDeletable()){
            delete quoteItem;
        }
        return quoteItem;
    }

    @AuraEnabled
    public static void deleteSelectedItems(List<String> recordIds){
        list<buildertek__Quote_Item__c> quoteItemLists;
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()){
            quoteItemLists = [select id
                              from buildertek__Quote_Item__c
                              where id IN :recordIds];
        }
        If (buildertek__Quote_Item__c.sObjectType.getDescribe().isDeletable()){
            delete quoteItemLists;
        }
    }

    //@AuraEnabled
    public static List<wrapperClass> groupValues(String recordId, list<String> currencyFields, List<String> allFields, List<String> groupIds, Decimal recordToDisply, Integer offset, string status){
       System.debug(':::::::groupValues:::::::');
        Map<string, string> mapForLabel = new Map<string, string>();
        Map<string, string> mapForFieldType = new Map<string, string>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType ctype = gd.get('buildertek__Quote_Item__c');
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
        system.debug('FieldsName ' + fmap.keySet());
        for (String fieldName : fmap.keySet()){
            mapForLabel.put(fieldName, fmap.get(fieldName).getDescribe().getLabel());
            mapForFieldType.put(fieldName, string.valueof(fmap.get(fieldName).getDescribe().getType()));
        }
        List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        list<AggregateResult> childObjGroup = new list<AggregateResult>();
        string myqueries = '';
        String myquery = '';
        String aggregateFields = '';
        String queryFields = '';
        integer i = 1;

        for (string sumOfFields : currencyFields){
            queryFields += ', ' + sumOfFields.trim();
        }
        // string status = 'Accept';
        myquery = 'select buildertek__Grouping__c ' + queryFields + ' from buildertek__Quote_Item__c where buildertek__Quote__c =: recordId AND buildertek__Status__c =: status Order by buildertek__Grouping__r.buildertek__Sort_Id__c,buildertek__Grouping__r.Name, buildertek__Priority__c ASC, Name ASC limit ' + recordToDisply + ' OFFSET ' + offset;
        system.debug('----myquery -----------> ' + myquery);
        /*if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/
        quoteItemList = database.query(myquery);
        system.debug('----quoteItemList -----------> ' + quoteItemList.Size());
        /*}*/
        for (string sumOfFields : currencyFields){
            aggregateFields += ', SUM(' + sumOfFields.trim()+') total' + i;
            i++;
        }

        myqueries = 'select buildertek__Grouping__c ' + aggregateFields + ' from buildertek__Quote_Item__c where Id IN: quoteItemList  Group By buildertek__Grouping__c';
        system.debug('myqueries Results ' + myqueries);
        /*if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
         Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/
        childObjGroup = database.query(myqueries);
        /*}*/
        system.debug('childObjGroup Results ' + childObjGroup);
        string Childs = 'select Id, Name from buildertek__Quote_Line_Group__c where id IN: groupIds order by buildertek__Sort_Id__c,Name ASC';
        list<buildertek__Quote_Line_Group__c> childObjGroups;
        if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
            childObjGroups = database.query(Childs);
        }
        Map<string, string> GroupNameMap = new Map<String, string>();
        for (buildertek__Quote_Line_Group__c Grps : childObjGroups){
            GroupNameMap.put((String)Grps.get('Id'), (String)Grps.get('Name'));
        }
        system.debug('GroupNameMap ------------> ' + GroupNameMap);

        Map<String, Boolean> fieldTypeMap = new Map<String, Boolean>();
        for (string sumOfFields : currencyFields){
            fieldTypeMap.put(sumOfFields, true);
        }
        system.debug('fieldTypeMap ----------> ' + fieldTypeMap);
        List<wrapperClass> wrapperClassList = new List<wrapperClass>();
        for (AggregateResult objAgr : childObjGroup){
            integer j = 1;
            integer child = 1;
            for (string sumOfFields : allFields){
                if (child >= 2){
                    system.debug('Result --------> ' + fieldTypeMap.get(sumOfFields));
                    if (fieldTypeMap.get(sumOfFields) == true){
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Grouping__c')), (Decimal)objAgr.get('total' + j), string.valueOf(mapForFieldType.get(sumOfFields.toLowercase().replace(' ', ''))), sumOfFields));
                        j++;
                    } else{
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Grouping__c')), null, 'false', sumOfFields));
                    }

                }
                child++;
            }
        }
        system.debug('wrapperClassList ----------> ' + wrapperClassList);
        return wrapperClassList;
    }

    //@AuraEnabled
    public static TargetTable getQuoteItemData(String recordId, List<String> fieldsList, String fieldString, Decimal recordToDisply, Integer offset ,  string status ){
        List<FieldClass> fieldClassList = (List<FieldClass>)System.JSON.deserialize(fieldString, List<FieldClass>.class);
        system.debug('fieldClassList ------------> ' + fieldClassList);
        system.debug('fieldsList --------> ' + fieldsList);
        TargetTable TargetTable_inst = new TargetTable();
        List<EachRecord> allListOfRecords = new List<EachRecord>();
        String aggregateFields = '';
        String objectName = 'buildertek__Quote_Item__c';
        String listType = 'List<' + objectName + '>';
        String EachRecordType = '' + objectName + '';
        System.debug('listType' + listType);
        System.debug('EachRecordType' + EachRecordType);
        SObject IndividualMember = (SObject)Type.forName(EachRecordType).newInstance();
        for (string sumOfFields : fieldsList){
            if (sumOfFields != null){
                aggregateFields += ', ' + sumOfFields;
            }
        }
        system.debug('aggregateFields --------> ' + aggregateFields);
        // string status = 'Accept';
        String myqueries = '';
        String myqueries2 = '';

        myqueries = 'select buildertek__Quote__c,buildertek__Status__c ,buildertek__Grouping__r.Name,buildertek__Grouping__r.buildertek__Sort_Id__c ' + aggregateFields + ' from buildertek__Quote_Item__c where buildertek__Quote__c =: recordId  AND buildertek__Status__c =: status  Order By buildertek__Grouping__r.buildertek__Sort_Id__c,buildertek__Grouping__r.Name, buildertek__Priority__c ASC , Name ASC limit ' + recordToDisply + ' OFFSET ' + offset;
        // myqueries2 = 'select buildertek__Quote__c,buildertek__Status__c ,buildertek__Grouping__r.Name,buildertek__Grouping__r.buildertek__Sort_Id__c ' + aggregateFields + ' from buildertek__Quote_Item__c where buildertek__Quote__c =: recordId  AND buildertek__Status__c =Accept  Order By buildertek__Grouping__r.buildertek__Sort_Id__c,buildertek__Grouping__r.Name, buildertek__Priority__c ASC , Name ASC limit ' + recordToDisply + ' OFFSET ' + offset;
        List<SObject> ListOfRecords;
        ListOfRecords = Database.query(myqueries);

        
        system.debug('ListOfRecords --------> ' + ListOfRecords.size());
        /*}*/
        Integer count = 0;
        for (Integer i = 0; i < ListOfRecords.size(); i++){
            IndividualMember = ListOfRecords[i];
            EachRecord Each_record_nested_List_Of_Fields = new EachRecord();
            List<object> temp = new List<object>();
            List<RecordsList> recList = new List<RecordsList>();
            for (FieldClass field : fieldClassList){
                if (field.fieldName == 'id'){
                    Each_record_nested_List_Of_Fields.recordId = (Id)IndividualMember.get(field.fieldName);
                } else{
                    if (field.fieldName != null && field.fieldName != 'buildertek__Grouping__c' && field.fieldName != 'Name' && !field.fieldName.contains('__r.Name')){
                        if (field.fieldType == 'currency'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '$0.00' : '$' + IndividualMember.get(field.fieldName), field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        } else if (field.fieldType == 'string'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        } else if (field.fieldType == 'reference' && field.fieldName != null){
                            String referenceField = field.fieldName.replace('__c', '__r');
                            if (IndividualMember.getSobject(referenceField) != null && IndividualMember.getSobject(referenceField).get('Name') != null){
                                recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, String.valueOf(IndividualMember.getSobject(referenceField).get('Name'))));
                            } else{
                                recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                            }
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        } else{
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName)+'', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        }
                    }
                }
                if (field.fieldName == 'buildertek__Grouping__c'){
                    Each_record_nested_List_Of_Fields.groupId = (Id)IndividualMember.get(field.fieldName);
                    //System.debug('Group Name::'+IndividualMember.get(''));
                    //Each_record_nested_List_Of_Fields.groupName = (String)IndividualMember.get(field.fieldName.replace('__c', '__r.Name'));
                }
                if (field.fieldName == 'Name'){
                    Each_record_nested_List_Of_Fields.recordName = (String)IndividualMember.get(field.fieldName);
                }
            }
            System.debug('i -----------> ' + i + '-' + temp);
            //recList.recordValue=temp;
            Each_record_nested_List_Of_Fields.recordValue = temp;
            Each_record_nested_List_Of_Fields.recordList = recList;
            Each_record_nested_List_Of_Fields.recordCount = count;
            Each_record_nested_List_Of_Fields.isSelected = false;
            allListOfRecords.add(Each_record_nested_List_Of_Fields);
            count++;
        }
        TargetTable_inst.records = ListOfRecords;
        TargetTable_inst.ListOfEachRecord = allListOfRecords;
        // TargetTable_inst.getRejectLines = quoteList;

        return TargetTable_inst;
    }

    @AuraEnabled
    public static List<buildertek__Quote_Item__c> prepareString(String quoteString){
        List<buildertek__Quote_Item__c> quoteItemsToInsert = (List<buildertek__Quote_Item__c>)System.JSON.deserialize(quoteString, List<buildertek__Quote_Item__c>.class);
        system.debug('quoteItemsToInsert ----------> ' + quoteItemsToInsert);
        List<buildertek__Quote_Item__c> newQIList = new List<buildertek__Quote_Item__c>();
        for (buildertek__Quote_Item__c qi : quoteItemsToInsert){
            boolean found = false;
            for (buildertek__Quote_Item__c newQi : newQIList){
                if (qi.Id == newQi.Id){
                    found = true;
                    break;
                }
            }
            if (!found){
                newQIList.add(qi);
            }
        }
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isUpdateable()){
            update newQIList;
        }
        return newQIList;
    }

    @AuraEnabled
    public static void saveUpdatedValues(List<buildertek__Quote_Item__c> quoteItemList){
        Map<String, buildertek__Quote_Item__c> quoteItemIdMap = new Map<String, buildertek__Quote_Item__c>();
        system.debug('budgetItemList -----------> ' + quoteItemList);
        quoteItemIdMap.putAll(quoteItemList);

        system.debug('quoteItemIdMap key ----------> ' + quoteItemIdMap.keyset());
        system.debug('quoteItemIdMap ----------> ' + quoteItemIdMap);
        system.debug('quoteItemIdMap ----------> ' + quoteItemIdMap.values());
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isUpdateable()){
            update quoteItemIdMap.values();
        }
    }
    
    @AuraEnabled
    public static buildertek__Quote_Item__c getquote(String recordId){
        
         system.debug('recordId ---------->'+recordId);
        
        buildertek__Quote_Item__c quoteRecord = [select id, name, buildertek__Markup__c,buildertek__Unit_Price__c,buildertek__Status__c ,buildertek__Net_Unit__c,buildertek__Additional_Discount__c, buildertek__Unit_Cost__c, buildertek__Notes__c from buildertek__Quote_Item__c Where Id =: recordId];
        
        
        system.debug('Quote record-------->'+quoteRecord);
        return quoteRecord;
        
        
    }
    
     @AuraEnabled
    public static buildertek__Quote_Item__c updatequote(String recordId, Decimal markup){
    
    system.debug('markup from controller----->'+markup);
    
   buildertek__Quote_Item__c quoterec= [select id, name, buildertek__Markup__c,buildertek__Status__c ,buildertek__Net_Unit__c,buildertek__Additional_Discount__c, buildertek__Unit_Cost__c, buildertek__Notes__c from buildertek__Quote_Item__c Where Id =: recordId];
    quoterec.buildertek__Markup__c = markup;
    
    update quoterec;
    system.debug('updated record--->'+quoterec);
    return quoterec;
        
    }

    public class FieldClass{
        @AuraEnabled
        public String fieldName; //Record Id used for Firing Events
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public Boolean isEditable;
    }

    public class RecordsList{
        @AuraEnabled
        public Boolean isEditable;
        @AuraEnabled
        public String recordValue;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public Object originalValue;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String referenceValue;
        public RecordsList(Boolean isEditable, String recordValue, String fieldName, Object originalValue, String fieldType, String referenceValue){
            this.isEditable = isEditable;
            this.recordValue = recordValue;
            this.fieldName = fieldName;
            this.originalValue = originalValue;
            this.fieldType = fieldType;
            this.referenceValue = referenceValue;
        }
    }

    public class EachRecord{
        @AuraEnabled
        public Integer recordCount;
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public List<RecordsList> recordList;
        @AuraEnabled
        public List<object> recordValue;  //Record
        @AuraEnabled
        public Id recordId; //Record Id used for Firing Events
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public String groupName;
        @AuraEnabled
        public Id groupId;
    }

    public class TargetTable{
        @AuraEnabled
        public List<sObject> records; //actual list of records
        @AuraEnabled
        public List<EachRecord> ListOfEachRecord;

        // @AuraEnabled
        // public List<buildertek__Quote_Item__c> getRejectLines;

        

        //all data will be saved as array of array values
    }

    public class QuoteWrapper{
        @AuraEnabled
        public List<buildertek__Quote_Item__c> quoteList{ get; set; }

        @AuraEnabled
        public List<String> fieldNames{ get; set; }

        @AuraEnabled
        public Boolean checkQuote{ get; set; }
    }

    public class wrapperClass{
        @AuraEnabled
        public String groupName{ get; set; }

        @AuraEnabled
        public Decimal totalValue{ get; set; }

        @AuraEnabled
        public String fieldType{ get; set; }

        @AuraEnabled
        public String fieldLabel{ get; set; }

        public wrapperClass(String groupName, Decimal totalValue, String fieldType, String fieldLabel){
            this.groupName = groupName;
            this.totalValue = totalValue;
            this.fieldType = fieldType;
            this.fieldLabel = fieldLabel;
        }
    }

    public class finalWrapperClass{
        @AuraEnabled
        public TargetTable tarTable;
        @AuraEnabled
        public List<wrapperClass> wrapperList;
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;

        @AuraEnabled
        public List<quote_line_group__c> groups{ get; set; }

        @AuraEnabled
        public Integer totalColumns{ get; set; }

        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer page{ get; set; }

        @AuraEnabled
        public Integer total{ get; set; }

        @AuraEnabled
        public String status{get;set;}

        @AuraEnabled
        public Integer Totalcols{ get; set; }

    }

    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }
    @AuraEnabled
    public static buildertek__Quote__c getProject(String recordId){
        //String projectName = '';
        buildertek__Quote__c quoterecord = [Select Id,Name,buildertek__Project__c,buildertek__Project__r.Name from buildertek__Quote__c  where Id =: recordId LIMIT 1];
       // projectName = quoterecord.buildertek__Project__r.Name;
        return quoterecord;
    }
    
        @AuraEnabled
    public static List<Product2> getProducts(){
        DataTableWrapper listDtw;
        List<Product2> pp =  [SELECT Id,Name,ProductCode,Description,toLabel(Family) Family,(select UnitPrice from PricebookEntries where IsActive = True) FROM Product2 WHERE IsActive = True AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE isActive = true)];
       
       /*    List<String> labels = new     List<String>();
        labels.add('Product Name');
        labels.add('Product Code');
        labels.add('List Price');
        labels.add('Product Description');
        labels.add('Product Family');
        
        List<String> Apis = new  List<String>();
        Apis.add('Name');
        Apis.add('ProductCode');
        Apis.add('Description');
        Apis.add('Family');
        Apis.add(pp.) */
        
        return pp;
        
    }
    
        public class DataTableWrapper {
        @AuraEnabled
            
            public List<String> fieldLabel;
            
           @AuraEnabled
            public List<String> fieldApiName;
            @AuraEnabled
              public List<Product2> records;
            
            
            
            
            
            
        }
 @AuraEnabled
    public static List<Product2> getProductRecordsByIds(List<Id> Ids, List<String> PricebookId){
        List<Product2> productList = new  List<Product2>();
        
        system.debug('PricebookId--------->'+PricebookId);
        
        if(PricebookId.size() > 0){
            system.debug('ifiiifif');
            productList =  [select id,Name,ProductCode,Description,Family,buildertek__Quote_Group__r.Name, (select UnitPrice,buildertek__Unit_Cost__c,Pricebook2Id,Pricebook2.Name,buildertek__Markup__c,buildertek__Discount__c,IsActive from PricebookEntries where Pricebook2Id IN: PricebookId AND IsActive = True  )  from Product2 where Id in :Ids ];
            system.debug('productList--------->'+productList);
        }else{
            system.debug('elseleseelse');
            if(Ids.size() > 0){
                productList =  [select id,Name,ProductCode,Description,Family,buildertek__Quote_Group__r.Name,(select UnitPrice,Pricebook2Id,Pricebook2.Name,buildertek__Markup__c,buildertek__Unit_Cost__c,buildertek__Discount__c,IsActive from PricebookEntries where IsActive = True order by CreatedDate ASC )  from Product2 where Id in :Ids ];
                system.debug('productList--------->'+productList );   
            } 
        }
        
        return productList;
    }

    @AuraEnabled
    public static Id createQuoteLineGroup(String productFamilyName){
        Id groupId = null;
        //check if the product family name exists in the quote line group
        List<buildertek__Quote_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c WHERE Name =: productFamilyName];
        if(groupList.size() > 0){
            groupId = groupList[0].Id;
        }else{
            //create a new group
            buildertek__Quote_Line_Group__c newGroup = new buildertek__Quote_Line_Group__c();
            newGroup.Name = productFamilyName;
            insert newGroup;
            groupId = newGroup.Id;
        }
        return groupId;
    }

    //create a method which takes in a list of product and finds the Quote Line Group Id whose name matches the product family
    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteLineGroup(List<Product2> productList){
        //create a list of product family names
        List<String> productFamilyNameList = new List<String>();
        for(Product2 p : productList){
            productFamilyNameList.add(p.Family);
        }
        //see if all the product family names exist in the quote line group and if not create them
        List<buildertek__Quote_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c WHERE Name IN :productFamilyNameList];
        //create a map of product family name and quote line group id
        Map<String, Id> productFamilyNameMap = new Map<String, Id>();
        for(buildertek__Quote_Line_Group__c g : groupList){
            productFamilyNameMap.put(g.Name, g.Id);
        }
        //create a list of quote line group to be inserted
        List<buildertek__Quote_Line_Group__c> groupListToBeInserted = new List<buildertek__Quote_Line_Group__c>();
        for(Product2 p : productList){
            if(!productFamilyNameMap.containsKey(p.Family)){
                buildertek__Quote_Line_Group__c newGroup = new buildertek__Quote_Line_Group__c();
                newGroup.Name = p.Family;
                groupListToBeInserted.add(newGroup);
            }
        }
        //insert the new quote line groups
        if(groupListToBeInserted.size() > 0){
            insert groupListToBeInserted;
        }
        //get the list of quote line groups again
        groupList = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c WHERE Name IN :productFamilyNameList];
        return groupList;
    }
        
    @AuraEnabled
    public static List<buildertek__Quote_Item__c> QuoteLinesInsert(List<buildertek__Quote_Item__c> Quotelines,String QuoteId){
        System.debug('Quotelines => '+Quotelines);
        List<buildertek__Quote_Item__c> insertListofQuoteLines = new List<buildertek__Quote_Item__c>();
        for(buildertek__Quote_Item__c qql : Quotelines){
            System.debug('Record => ' + qql);
            buildertek__Quote_Item__c newQline = new    buildertek__Quote_Item__c();
            newQline.Name = qql.Name;
            if (newQline.Name.length() > 80){
                newQline.Name = newQline.Name.substring(0, 79);
            }
            newQline.buildertek__Product__c = qql.buildertek__Product__c;
            if(qql.buildertek__Unit_Price__c != null){
                newQline.buildertek__Unit_Price__c = qql.buildertek__Unit_Price__c;               
            }
            else{
                newQline.buildertek__Unit_Price__c = 0;
                // newQline.buildertek__Unit_Cost__c = 0;
            } 
            newQline.buildertek__Unit_Cost__c = qql.buildertek__Unit_Cost__c;
            newQline.buildertek__Markup__c = qql.buildertek__Markup__c;
            newQline.buildertek__Additional_Discount__c = qql.buildertek__Additional_Discount__c;
            newQline.buildertek__Grouping__c = qql.buildertek__Grouping__c;   
            newQline.buildertek__Quantity__c = qql.buildertek__Quantity__c;
            newQline.buildertek__Notes__c = newQline.buildertek__Notes__c;
            newQline.buildertek__Status__c = 'Accept';
            newQline.buildertek__Quote__c = QuoteId;
            newQline.buildertek__Product_Family__c = qql.buildertek__Product_Family__c;
            newQline.buildertek__UOM__c = qql.buildertek__UOM__c;
            insertListofQuoteLines.add(newQline); 
        }
        insert insertListofQuoteLines;
        return insertListofQuoteLines;
    }
    
  /*    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteLineGroupRecords(){
        
        List<buildertek__Quote_Line_Group__c> quoteLineGroupRecords = [select id,Name from buildertek__Quote_Line_Group__c];
        return quoteLineGroupRecords;
    } */
    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteGrouping2(String quoteId){
        List<buildertek__Quote_Line_Group__c> quotelinegrp;
       // if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Number__c.isAccessible()){
            quotelinegrp = [Select Id, Name, buildertek__Description__c
                            from buildertek__Quote_Line_Group__c ORDER BY Name ASC NULLS LAST/*where buildertek__Quote__c =: quoteId*/];
       // }
        return quotelinegrp;
    }

    @AuraEnabled
    public static List<Product2> getProducts2(){
        DataTableWrapper listDtw;
        List<Product2> pp =  [select id,Name,ProductCode,Description,Family,(select UnitPrice from PricebookEntries) from Product2];
        return pp;
        
    }
    
    @AuraEnabled
    public static List<Product2> getProductsthroughPriceBook(string pbookId) {
        System.debug('Project Price Book Id ------------------------->'+pbookId);
        List<PriceBookEntry> pEntries;
         if(pbookId != null && pbookId != 'None'){
             System.debug('If');
             //sort by Product2.Name
             pEntries = [SELECT Id, Product2Id, Product2.Name,Product2.ProductCode,Product2.Description,toLabel(Product2.Family), Product2.IsActive,buildertek__Unit_Cost__c,Pricebook2.Name,UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True];
             System.debug('pEntries--->>>'+pEntries);
             List<Product2> products = new List<Product2>();
             for (PriceBookEntry pEntry: pEntries) {
                     Product2 aProduct = new Product2();
                     aProduct.Id = pEntry.Product2Id;
                     aProduct.Name = pEntry.Product2.Name;
                     aProduct.ProductCode = pEntry.Product2.ProductCode;
                     aProduct.Description = pEntry.Product2.Description;
                     aProduct.Family = pEntry.Product2.Family;
                     aProduct.IsActive = pEntry.Product2.IsActive;
                     aProduct.buildertek__Available_Quantity__c = pEntry.UnitPrice;
                     aProduct.buildertek__Size__c = pEntry.Pricebook2.Name;
                     products.add(aProduct);
             }
             return products;
        }else{
            return null;
        }

}

 @AuraEnabled
      public static List<PricebookEntry> getProductRecordsByIds1(List<Id> Ids, String pBookId){
      List<PricebookEntry> pEntries;
    /*  if(pBookId != null && pBookId != ''){
      System.debug('Entered');
       pEntries = [select Pricebook2.Name,Product2.Name,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c from PricebookEntry where Product2Id in :Ids AND Pricebook2Id =:pBookId AND IsActive = True];
      }
      else{
            System.debug('Yes'); */
            pEntries = [select Pricebook2.Name,Product2.Name,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c from PricebookEntry where Product2Id in :Ids AND IsActive = True];
          //  }

      return pEntries;
      }
    
    @AuraEnabled
    public static String priceBookInProject(String recordId){
        pricebook2[] priceBookName = [select Id, Name  from pricebook2 where Name = 'Standard Price Book'];
        buildertek__Quote__c[] quote = [select Id,buildertek__Project__r.buildertek__Price_Book__c from buildertek__Quote__c where Id =: recordId];
        if(quote.size() > 0){
            if(quote[0].buildertek__Project__r.buildertek__Price_Book__c != null){
                pricebook2[] priceBook = [select Id, Name  from pricebook2 where Id =: quote[0].buildertek__Project__r.buildertek__Price_Book__c];
                if(priceBook.size() > 0){
                    System.debug('PriceBook -----------------------------> '+ priceBook[0].Name);
                     return priceBook[0].Id;
                }
                else{
                    if(priceBookName.size() > 0){
                        return priceBookName[0].Id;
                    }
                    else{
                     return '01s41000000kFZJAA2';
                         }
                }
                 
            }
            else{
                 if(priceBookName.size() > 0){
                        return priceBookName[0].Id;
                    }
  else{
                     return '01s41000000kFZJAA2';
                         }            }
        }
        else{
            return 'ERROR';
        }
    }
    
    // new method only for search filter for product family on NewQuoteitemClone 
    @AuraEnabled
    public static List<Product2> searchProdcutFamily(string searchedWord){
        try {
            List<Product2> getProductsFamily = new List<Product2>();
            string filterKey = searchedWord+'%';
            // getProductsFamily = [select id,family from product2 where family LIKE :filterKey];
            getProductsFamily = [SELECT Id,Name,ProductCode,Description,toLabel(Family),(SELECT UnitPrice FROM PricebookEntries WHERE IsActive = True) FROM Product2 WHERE  IsActive = True AND family LIKE :filterKey AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE isActive = true) ORDER BY Name ASC NULLS LAST];
            System.debug('List of product family is here ==> '+getProductsFamily);
            return getProductsFamily;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            return null;
        }
    }
     /*
    Created:- 8th December 2022
    Description:- Used to Fetch all Quotelines 
    */
    @AuraEnabled
    public static List<buildertek__Quote_Item__c> getQuoteLines(string recordId){
        try{
        List<buildertek__Quote_Item__c> quoteLineList = new List<buildertek__Quote_Item__c>();
        quoteLineList= [SELECT  Id, Name, buildertek__Status__c,buildertek__Net_Unit__c,buildertek__Net_Total_Price__c,buildertek__Total_Cost__c    ,buildertek__Quantity__c, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c ,buildertek__Quote__c FROM buildertek__Quote_Item__c where buildertek__Quote__c=:recordId AND buildertek__Status__c='Reject'];
        System.debug(quoteLineList);
        return quoteLineList;
        }catch(Exception e){
            System.debug(e.getMessage() + ':' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static List<Boolean> getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Remove_Single_Quote_Line_Option__c, buildertek__Hide_Global_Margin__c, buildertek__Hide_Global_Markup__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Quote Configuration'];

        Boolean checkSingleQLine = adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c ;
        Boolean checkButtonMargin = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c;
        Boolean checkButtonMarkup = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c;

        List<Boolean> islien = new List<Boolean>{checkSingleQLine, checkButtonMargin,checkButtonMarkup};


        return islien;
    }   

    @AuraEnabled
    public static quoteLineWrapperClass getQuoteData(String quoteId, Integer pageNumber, Integer recordToDisply, List<String> groupingList){
        quoteLineWrapperClass mainWrapper = new quoteLineWrapperClass();
        Integer pageSize = recordToDisply;
        Integer offset = (pageNumber - 1) * pageSize;
        List<String> gorupingFieldList = new List<String>{'id','buildertek__Build_Phase__c', 'buildertek__Build_Reference_1__c','buildertek__Base_Location__c','buildertek__Location_Picklist__c','buildertek__Location_Detailed_Area__c','buildertek__Location_Detail_Reference_1__c','buildertek__BL_SERVICE_CATEGORY__c', 'buildertek__Product_Family__c', 'buildertek__Sub_Group__c', 'buildertek__Grouping__c'};
        String apiString = '';

        List<BT_Lightning_Utils.dataTableFields> column = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Quote_Item__c', 'buildertek__BT_Related_List_View_Fields');
        for(BT_Lightning_Utils.dataTableFields s : column){
            if (!gorupingFieldList.contains(s.fieldName)) {
                apiString += s.fieldName + ', ';
            }
        }
        String query = 'SELECT Id, '+apiString+' buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Build_Reference_1__c, buildertek__Base_Location__c, buildertek__Location_Picklist__c, buildertek__Location_Detailed_Area__c, ';
        query += 'buildertek__Location_Detail_Reference_1__c, buildertek__BL_SERVICE_CATEGORY__c, buildertek__Product_Family__c, buildertek__Sub_Group__c, buildertek__Sub_Group__r.Name, buildertek__Grouping__c, buildertek__Grouping__r.Name ';
        query += 'FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =\''+quoteId+'\''+' ORDER BY '+groupingList[0];
        if (groupingList.size() > 1) {
            query += ', '+groupingList[1];
        }
        if (groupingList.size() > 2) {
            query += ', '+groupingList[2];
        }
        if (groupingList.size() > 3) {
            query += ', '+groupingList[3];
        }
        query += ' NULLS LAST';

        List<buildertek__Quote_Item__c> quoteLineList = Database.query(query);

        Integer totalQuoteLine = [SELECT count() FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :quoteId];

        buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Quote_Line_Grouping_Fields__c FROM buildertek__Quote__c WHERE Id =: quoteId];
        quote.buildertek__Quote_Line_Grouping_Fields__c = JSON.serialize(groupingList);
        update quote;

        mainWrapper.quoteLineList = quoteLineList;
        mainWrapper.columns = column;
        mainWrapper.pageSize = recordToDisply;
        mainWrapper.pageNumber = pageNumber;
        mainWrapper.total = totalQuoteLine;

        return mainWrapper;

    }


    public class quoteLineWrapperClass{

        @AuraEnabled
        public List<buildertek__Quote_Item__c> quoteLineList;
    
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;
    
        @AuraEnabled
        public Integer pageSize{ get; set; }
    
        @AuraEnabled
        public Integer pageNumber{ get; set; }
    
        @AuraEnabled
        public Integer total{ get; set; }
    }

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }

    // @AuraEnabled
    // public static List<pricebook2> getPricebookList(){
    //     List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
    //     return PriceList;
    // }
    @AuraEnabled
    public static List<pricebookWrapper> getPricebookList(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
        priceWrap.priceWrapList=PriceList;
        if(recordId != null){
            buildertek__Quote__c quoteRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Quote__c  WHERE Id = :recordId];
            if(quoteRecord.buildertek__Project__c != null && quoteRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:quoteRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }

    @AuraEnabled
    public static List<productWrapper> getProductsthroughPriceBook2(string pbookId) {


        List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), 
                                            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure  //----
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True 
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST];

        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry: pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;            
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;     //----
            products.add(aProduct);
        }

        return products;
    }

    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteLineGroups(){
        List<buildertek__Quote_Line_Group__c> quoteLineGrouping = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c ORDER BY Name ASC];
        return quoteLineGrouping;
        
    }



    public class productWrapper{
        @AuraEnabled
        public Id Id;

        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String ProductCode;

        @AuraEnabled
        public String Description;

        @AuraEnabled
        public String Family;

        @AuraEnabled
        public Boolean IsActive;

        @AuraEnabled
        public Decimal UnitPrice;

        @AuraEnabled
        public String Size;

        @AuraEnabled
        public Boolean Selected;
        
        @AuraEnabled
        public Decimal UnitCost;
        
        @AuraEnabled
        public String Phase;
        
        @AuraEnabled
        public Decimal MarkUp;

        @AuraEnabled
        public Decimal Discount;

        @AuraEnabled
        public String QuantityUnitOfMeasure;        //----
    }

    @AuraEnabled
    public static List<sObject> getProductRecords(String searchKeyWord, String ObjectName, String filter, string parentId, string prodctfamly){
        system.debug('ObjectName-->' + ObjectName);
        // String searchKey = '%'+ searchKeyWord + '%';
        String[] searchTerms = searchKeyWord.split(' ');
        String searchKey = '';
        for (Integer i = 0; i < searchTerms.size(); i++) {
            searchKey += 'Name LIKE \'%' + searchTerms[i] + '%\'';
            if (i < searchTerms.size() - 1) {
                searchKey += ' AND ';
            }
        }
        List<sObject> returnList = new List<sObject>();
        String sQuery;
        list<string> ProdIds = new list<string>();
        list<pricebookEntry> PElist;
        System.debug('parentId'+parentId);
        System.debug(parentId != '');
        System.debug(parentId != null);


        if (ObjectName == 'Product2' && parentId != null && parentId != ''){
            if(prodctfamly == '--None--'){
                PElist = [select id, Product2Id, product2.family from pricebookEntry  where pricebook2Id = :parentId AND toLabel(product2.family) = :null];
            }else{

                PElist = [select id, Product2Id, product2.family from pricebookEntry  where pricebook2Id = :parentId AND toLabel(product2.family) = :prodctfamly];
            }
            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
            if (filter != null){
                filter = filter + ' AND Id IN: ProdIds';
            }else{
                filter = 'Id IN: ProdIds';
            }
            
        // }else if(ObjectName == 'Product2' && prodctfamly == '--None--' && parentId == null){

        //     PElist = [select id, Product2Id, product2.family from pricebookEntry where product2.family = null];   
        //     for (pricebookEntry PE : PElist){
        //         ProdIds.add(PE.Product2Id);
        //     }   
        //     if (filter != null){
        //         filter = filter + ' AND Id NOT IN: ProdIds';
        //     }else{
        //         filter = 'Id NOT IN: ProdIds';
        //     }      
        }else if(ObjectName == 'Product2' && (parentId == null || parentId == '')){

            PElist = [select id, Product2Id, product2.family from pricebookEntry];   
            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }   
            if (filter != null){
                filter = filter + ' AND Id NOT IN: ProdIds';
            }else{
                filter = 'Id NOT IN: ProdIds';
            }      
        }

        sQuery = 'select id, Name from ' + ObjectName + ' WHERE ' + searchKey + ' AND ' + filter + ' order by Name ASC LIMIT 800';
        List<sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj : lstOfRecords){
            returnList.add(obj);
        }
        System.debug('returnList'+ returnList);
        return returnList;
    }

    
    
}