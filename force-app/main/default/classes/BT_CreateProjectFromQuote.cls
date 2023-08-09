public with sharing class BT_CreateProjectFromQuote {
    @AuraEnabled
    public static buildertek__Quote__c getQuote(String recordId,String searchNameValue){
        buildertek__Quote__c opp;
        opp = [SELECT Id, Name, buildertek__Customer_Account__c from buildertek__Quote__c where Id =: recordId]; 
        List<buildertek__Quote__c> productList = new List<buildertek__Quote__c>();
        String queryList = 'SELECT Id, Name, buildertek__Customer_Account__c FROM buildertek__Quote__c';
        if (searchNameValue != null && searchNameValue != '') {
            queryList = queryList + ' WHERE Name LIKE \'' + searchNameValue + '%\'';
        }
        System.debug('queryList: ' + queryList);
        productList = Database.query(queryList);

        Set<ID> productsIds = new Set<ID>();
        for (buildertek__Quote__c product : productList) {
            productsIds.add(product.Id);
        }
        return opp;
    }

    @AuraEnabled
    public static List<buildertek__Quote__c> getQuoteName1(String searchNameValue){
        List<buildertek__Quote__c> QuoteList = new List<buildertek__Quote__c>();
        List<buildertek__Quote__c> QtList = [SELECT Id, Name FROM buildertek__Quote__c ORDER BY name ASC];

        if(!String.isBlank(searchNameValue)){
            for (buildertek__Quote__c quote : QtList) {
                if (quote.Name.toLowerCase().contains(searchNameValue.toLowerCase())) {
                    QuoteList.add(quote);
                }
            }
        } else{
            for (buildertek__Quote__c quote : QtList) {
                QuoteList.add(quote);
            }
        }
        return QuoteList;
    }
    
    @AuraEnabled
    public static String createProject(String recordId, String projectName, String account, String projectManager, Date contractDate , String customerAccount){
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = projectName;
        if(account != null){
            project.buildertek__Account__c = account;
            project.buildertek__Customer__c = customerAccount;
            
        }
        project.buildertek__Project_Manager__c = projectManager;
        project.buildertek__Contract_Date__c = contractDate;
        insert project;

        
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
        quoteList = [SELECT Id, Name, buildertek__Description__c, buildertek__Quote_Amount__c, buildertek__Status__c, buildertek__Project__c, 
                     buildertek__Auto_Number__c, buildertek__Primary__c, buildertek__Markup__c, buildertek__Shipping_and_Handling__c,
                     buildertek__Profit_Margin__c, buildertek__Payment_Terms__c, buildertek__Discount__c, buildertek__Tax__c,buildertek__Notes__c,
                     buildertek__Expires_On__c, buildertek__Sales_Rep__c, buildertek__Primary_Contact__c, buildertek__Start_Date__c, 
                     buildertek__Bill_To_Name__c, buildertek__Bill_To_Street__c, buildertek__Bill_To_City__c, buildertek__Bill_To_State__c, 
                     buildertek__Bill_To_Country__c, buildertek__Ship_To_Name__c, buildertek__Ship_To_Street__c, buildertek__Ship_To_City__c, 
                     buildertek__Ship_To_State__c, buildertek__Group_Line_Items__c,buildertek__OppToQuoteId__c, buildertek__Ship_To_Zip_Code__c, 
                     buildertek__Email_Body__c, buildertek__Email_Subject__c, buildertek__Ship_To_Country__c, buildertek__Bill_To_Zip_Code__c,buildertek__Opportunity__c, 
                     buildertek__SignatureBase64__c,buildertek__Bill_To_Cell_Phone__c,buildertek__Bill_To_Email_Address__c,buildertek__Customer_Accepted_Date__c,
                     buildertek__Date_Accepted_by_Customer__c,buildertek__Customer_Account__c,buildertek__Date_Sent_To_Customer__c,buildertek__Type__c 
                     from buildertek__Quote__c 
                     where Id =: recordId];
        list<buildertek__Quote_Item__c> quoteItemList = new  list<buildertek__Quote_Item__c>();
        if(!quoteList.isEmpty()){
            


            // project.buildertek__Customer__c=quoteList[0].buildertek__Customer_Account__c;
            // insert project;

            quoteList[0].buildertek__Project__c = project.Id;
            update quoteList;
            
            quoteItemList = [SELECT Id, 
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
                             buildertek__Purchase_Order__c,
                             buildertek__Grouping__r.Name, 
                             buildertek__RFQ__c,
                             buildertek__Tax__c,
                             buildertek__Additional_Costs__c
                             FROM buildertek__Quote_Item__c
                             WHERE buildertek__Quote__c = :quoteList[0].Id]; 

            if (quoteItemList.size() > 0) {
                Set<Id> rfqIds = new Set<Id>();
                for (buildertek__Quote_Item__c quoteItem : quoteItemList) {
                    if (quoteItem.buildertek__RFQ__c != null) {
                        rfqIds.add(quoteItem.buildertek__RFQ__c);
                    }
                }

                if (rfqIds.size() > 0) {
                    List<buildertek__RFQ__c> rfqList = new List<buildertek__RFQ__c>();
                    for (Id rfqId : rfqIds) {
                        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
                        rfq.Id = rfqId;
                        rfq.buildertek__Project__c = project.Id;
                        rfqList.add(rfq);
                    }
                    update rfqList;
                }
            }         
        }
        
        
        if(!quoteList.isEmpty()){
            
            buildertek__Contract__c contract = new buildertek__Contract__c();
            contract.Name = quoteList[0].Name;
            contract.buildertek__BT_Quote__c = quoteList[0].Id;
            contract.buildertek__Contract_Start_Date__c = quoteList[0].buildertek__Start_Date__c;
            contract.buildertek__Email_Body__c = quoteList[0].buildertek__Email_Body__c;
            contract.buildertek__Email_Subject__c = quoteList[0].buildertek__Email_Subject__c;
            contract.buildertek__Expiration_Date__c = quoteList[0].buildertek__Expires_On__c;
            contract.buildertek__Primary_Contact__c = quoteList[0].buildertek__Primary_Contact__c;
            contract.buildertek__Project__c = quoteList[0].buildertek__Project__c;
            contract.buildertek__Start_Date__c = quoteList[0].buildertek__Start_Date__c;
            contract.buildertek__Discount__c = quoteList[0].buildertek__Discount__c;
            contract.buildertek__Tax_Rate__c = quoteList[0].buildertek__Tax__c;
            contract.buildertek__Shipping_Handling__c = quoteList[0].buildertek__Shipping_and_Handling__c;
            contract.buildertek__Notes__c = quoteList[0].buildertek__Notes__c;
            contract.buildertek__Status__c = 'Approved';
            contract.buildertek__Project__c = project.Id;
            contract.buildertek__Markup__c=quoteList[0].buildertek__Markup__c;
            insert contract;
            
            List<buildertek__Contract_Item__c> contractItemList = new List<buildertek__Contract_Item__c>();
            if(!quoteItemList.isEmpty()){
                for(buildertek__Quote_Item__c quoteLine : quoteItemList){
                    buildertek__Contract_Item__c contractLine = new buildertek__Contract_Item__c();
                    contractLine.Name = quoteLine.Name;
                    contractLine.buildertek__Cost_Code__c = quoteLine.buildertek__Cost_Code__c;
                    contractLine.buildertek__Description__c = quoteLine.buildertek__Description__c;
                    contractLine.buildertek__Product__c = quoteLine.buildertek__Product__c;
                    contractLine.buildertek__Quantity__c = quoteLine.buildertek__Quantity__c;
                    contractLine.buildertek__Unit_Price__c = quoteLine.buildertek__Net_Unit__c;
                    contractLine.buildertek__Contract_Item_Group__c = quoteLine.buildertek__Grouping__c;
                    contractLine.buildertek__Notes__c = quoteLine.buildertek__Notes__c;
                    contractLine.buildertek__Contract__c = contract.Id;
                    contractLine.buildertek__Discount__c = quoteLine.buildertek__Discount__c;
                    contractLine.buildertek__Tax__c = quoteLine.buildertek__Tax__c;
                    contractLine.buildertek__Unit_Cost__c = quoteLine.buildertek__Unit_Cost__c;
                    contractItemList.add(contractLine);
                }
                
                if(!contractItemList.isEmpty()){
                    insert contractItemList;
                }
            }
            
        }
        
        if(!quoteList.isEmpty()){
            buildertek__Budget__c Budget = new buildertek__Budget__c();
            Budget.Name = quoteList[0].Name;
            Budget.buildertek__Project__c = project.Id;
           //  Budget.buildertek__Total_Costs__c = quoteList[0].buildertek__Total_Costs__c;
            Budget.buildertek__Type__c = quoteList[0].buildertek__Type__c;
            insert Budget;
            
            List<buildertek__Budget_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c];

            Map<String, Id> groupMap = new Map<String, Id>();
    
            for (buildertek__Budget_Line_Group__c groupData : groupList) {
                groupMap.put(groupData.Name, groupData.Id);
            }
    
            List<buildertek__Budget_Line_Group__c> newGroupList = new List<buildertek__Budget_Line_Group__c>();
            String groupId = Budget.Id;
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

            List<buildertek__Budget_Item__c> BudgetLinesList  =  new List<buildertek__Budget_Item__c>();
            if(!quoteItemList.isEmpty()){
                for(buildertek__Quote_Item__c quoteLine : quoteItemList){
                    buildertek__Budget_Item__c  BudgetLineRecord = new buildertek__Budget_Item__c();
                    BudgetLineRecord.Name = quoteLine.Name;
                    BudgetLineRecord.buildertek__Product__c = quoteLine.buildertek__Product__c;
                    BudgetLineRecord.buildertek__Item_Name__c = quoteLine.buildertek__Item_Name__c;
                    BudgetLineRecord.buildertek__Cost_Code__c = quoteLine.buildertek__Cost_Code__c;
                    BudgetLineRecord.buildertek__Quantity__c = quoteLine.buildertek__Quantity__c;
                    BudgetLineRecord.buildertek__Unit_Price__c = quoteLine.buildertek__Unit_Cost__c;

                    BudgetLineRecord.buildertek__Sales_Price__c = quoteLine.buildertek__Net_Unit__c; 
                    BudgetLineRecord.buildertek__Tax__c = quoteLine.buildertek__Tax__c;
                    BudgetLineRecord.buildertek__Discount__c = quoteLine.buildertek__Additional_Discount__c;
                    BudgetLineRecord.buildertek__Markup__c = quoteLine.buildertek__Markup__c;

                    BudgetLineRecord.buildertek__Additional_Fees__c = quoteLine.buildertek__Additional_Costs__c;
                    BudgetLineRecord.buildertek__Group__c = groupMap.get(quoteLine.buildertek__Grouping__r.Name);
                    BudgetLineRecord.buildertek__Budget__c  =  Budget.Id;
                     BudgetLineRecord.buildertek__UOM__c = quoteLine.buildertek__UOM__c;
                    BudgetLineRecord.buildertek__Contractor__c = quoteLine.buildertek__Vendor__c;
                    BudgetLinesList.add(BudgetLineRecord);
                }
                if(!BudgetLinesList.isEmpty()){
                    insert BudgetLinesList;
                }
            }
            
        }
        
        //*for creating SOV after creating new project on BT quote
        Create_SOV_From_Quote.createSOV(recordId);
        
        return project.Id;
        
    }
    
    
}