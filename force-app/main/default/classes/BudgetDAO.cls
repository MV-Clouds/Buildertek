/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date: 19/09/2017
Last Modified By: DILIGENT FORCE LABS
Date: 11-Mar-2020
*/
public with sharing class BudgetDAO{
    public static boolean isCreateExpense = false;
    /*Method to used to set default grouping in Budget item*/
    public static void setDefaultGrouping(List<Budget_Item__c> budgetItems){
       // system.debug(budgetItems);
        set<Id> budgetIds = new set<Id>();
        SET<Id> groupIds = new SET<Id>();
        map<String, String> budgetIdByGroupId = new map<String, String>();
        // get all quote Ids
        for (buildertek__Budget_Item__c bItem : budgetItems){
            budgetIds.add(bItem.buildertek__Budget__c);
            if (bItem.buildertek__Group__c != null){
                groupIds.add(bItem.buildertek__Group__c);
                budgetIdByGroupId.put(bItem.Id, bItem.buildertek__Group__c);
            }
        }

        if (!groupIds.isEmpty()){
            for (buildertek__Budget_Item__c bItem : budgetItems){
                bItem.buildertek__Group__c = budgetIdByGroupId.get(bItem.Id);
            }
        } else{
            List<buildertek__Budget_Line_Group__c> btGroup;
            if (Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isAccessible()){
                btGroup = [SELECT Id
                           FROM buildertek__Budget_Line_Group__c
                           WHERE Name = 'No Grouping' ORDER BY Name ASC];
            }
            if (btGroup.size() > 0){
                for (buildertek__Budget_Item__c bItem : budgetItems){
                    bItem.buildertek__Group__c = btGroup[0].Id;
                }
            } else{
                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                if (Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isCreateable()){
                    budgetGroup.Name = 'No Grouping';
                }

                insert budgetGroup;
                for (buildertek__Budget_Item__c bItem : budgetItems){
                    bItem.buildertek__Group__c = budgetGroup.Id;
                }
            }


        }


        // // create new group for quote
        // if(!newBudgetWithoutGroup.isEmpty()){
        //     Budget_Line_Group__c budGroup = [SELECT Id FROM Budget_Line_Group__c WHERE Name = 'No Grouping'];
        //     /*budgetIdByGroupId = new map<Id,Budget_Line_Group__c>();
        //     for(Id budgetId: newBudgetWithoutGroup){
        //         Budget_Line_Group__c defaultGroup = new Budget_Line_Group__c();
        //         defaultGroup.Name = 'No Grouping';
        //         defaultGroup.Budget__c = budgetId;
        //         budgetIdByGroupId.put(budgetId, defaultGroup);
        //     }

        //     insert budgetIdByGroupId.values();*/

        //     for(Budget_Item__c bItem:budgetItems){
        //         if(budgetIdByGroupId.containsKey(bItem.Budget__c)){
        //             //bItem.Group__c = budgetIdByGroupId.get(bItem.budget__c).Id;
        //             bItem.Group__c = budGroup.Id;
        //         }
        //     }
        // }
    }
    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
       return UserInfo.isMultiCurrencyOrganization();
    }

    @AuraEnabled
    public static String getBudgetLineRecords(String selectedBudgetId){
        try{
            if (String.isNotBlank(selectedBudgetId)){
                List<buildertek__Budget_Item__c> budgetItems = [Select Id, Name
                                                                FROM buildertek__Budget_Item__c
                                                                WHERE buildertek__Budget__c = :selectedBudgetId ORDER BY Name ASC];
                if (budgetItems.size() > 0)
                    return JSON.serialize(budgetItems);
            }
        } catch (Exception e){
           // System.debug('Error Message: ' + e.getMessage());
           // System.debug('Error Line: ' + e.getLineNumber());
            throw new AuraHandledException(JSON.serialize(e));
        }
        return null;
    }

    @AuraEnabled
    public static string updateBudgetItemFromExpenseItem(String expenseNote, String expenseAmount, String expenseRefNo, String expensePaymentMethod, String expenseCostCode, String expenseType, String expensebudgetId, String expenseDescription, String projectId, String budgetItemId){
        isCreateExpense = true;
        buildertek__Budget_Line_Group__c budgetLineGroup = [SELECT Id, Name
                                                            FROM buildertek__Budget_Line_Group__c
                                                            WHERE Name = 'Expense' 
                                                            ORDER BY Name ASC
                                                            limit 1];
        if (projectId == null || expensebudgetId == null){
            return projectId ;
        }

      //  system.debug(budgetItemId);
        try{
            buildertek__Expense__c expenseobj = new buildertek__Expense__c();
            expenseobj.buildertek__Description__c = expenseDescription;
            expenseobj.buildertek__Budget__c = expensebudgetId;
            expenseobj.buildertek__Type__c = expenseType;
            expenseobj.buildertek__Cost_Code__c = expenseCostCode;
            expenseobj.buildertek__Payment_Method__c = expensePaymentMethod;
            expenseobj.buildertek__Ref_No__c = expenseRefNo;
            if (expenseAmount != null && String.isNotBlank(expenseAmount)){
                expenseobj.buildertek__Amount__c = Decimal.valueOf(expenseAmount);
            }
            expenseobj.buildertek__Notes__c = expenseNote;
            expenseobj.buildertek__Budget_Line__c = Id.valueOf(budgetItemId);
            expenseobj.buildertek__Project__c = projectId;
            insert expenseobj;
        } catch (Exception ex){
           // System.debug('The following exception has occurred: ' + ex.getMessage());
           // System.debug('The following exception has occurred: ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return projectId;
    }

    // method for create expense and budget item
    @AuraEnabled
    public static string createBudgetItemFromExpenseItem(String expenseNote, String expenseAmount, String expenseRefNo, String expensePaymentMethod, String expenseCostCode, String expenseType, String expensebudgetId, String expenseDescription, String projectId){
        isCreateExpense = true;
        Decimal Amount = null;
        if (expenseAmount != null){
            Amount = Decimal.valueOf(expenseAmount);
        }
        buildertek__Budget_Line_Group__c budgetLineGroup = [SELECT Id, Name
                                                            FROM buildertek__Budget_Line_Group__c
                                                            WHERE Name = 'Expense'
                                                            ORDER BY Name ASC
                                                            limit 1];
        if (projectId == null || expensebudgetId == null){
            system.debug('haii');
            return projectId;
        }
        try{
            system.debug('helo');
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.buildertek__Cost_Code__c = expenseCostCode;
            budgetItem.Name = expenseDescription;
            budgetItem.buildertek__Group__c = budgetLineGroup.Id;
            budgetItem.buildertek__Budget__c = expensebudgetId;
            budgetItem.buildertek__Description__c = expenseDescription;
            budgetItem.buildertek__Cost_Type__c = expenseType;
            //budgetItem.buildertek__Expense_Amount__c = expenseAmount;
            budgetItem.buildertek__Notes__c = expenseNote;
            insert budgetItem;

            buildertek__Expense__c expenseobj = new buildertek__Expense__c();
            expenseobj.buildertek__Description__c = expenseDescription;
            expenseobj.buildertek__Budget__c = expensebudgetId;
            expenseobj.buildertek__Type__c = expenseType;
            expenseobj.buildertek__Cost_Code__c = expenseCostCode;
            expenseobj.buildertek__Payment_Method__c = expensePaymentMethod;
            expenseobj.buildertek__Ref_No__c = expenseRefNo;
            //expenseobj.buildertek__Amount__c = Decimal.valueOf(expenseAmount);
            expenseobj.buildertek__Amount__c = Amount;
            expenseobj.buildertek__Notes__c = expenseNote;
            expenseobj.buildertek__Budget_Line__c = budgetItem.Id;
            expenseobj.buildertek__Project__c = projectId;
            insert expenseobj;
        } catch (Exception ex){
          //  System.debug('The following exception has occurred: ' + ex.getMessage());

        }
         return projectId;
    }

    @AuraEnabled
    public static string duplicateExpense(String expenseAmount, String expenseType, String expensePaymentMethod, String expenseDescription){
        Decimal Amount = null;
        if (expenseAmount != null){
            Amount = Decimal.valueOf(expenseAmount);
        }
        list<buildertek__Expense__c> expenselist = [select id, Name, buildertek__Description__c, buildertek__Type__c, buildertek__Payment_Method__c, buildertek__Amount__c
                                                    from buildertek__Expense__c
                                                    where buildertek__Description__c = :expenseDescription and buildertek__Type__c = :expenseType and buildertek__Payment_Method__c = :expensePaymentMethod and buildertek__Amount__c = :Amount ORDER BY Name ASC];
        system.debug(expenselist);
        if (expenselist.size() > 0){
            return 'DuplicateExpense';
        } else{
            return null;
        }
    }

    //Contingency Budget Items
    @AuraEnabled
    public static String getContingencyBudgetItems(String recordId){
        //try{
        Map<String, List<buildertek__Budget_Item__c>> budgetItemMap = new Map<String, List<buildertek__Budget_Item__c>>();
        List<buildertek__Budget_Item__c> budgetItemList = [select ID, Name, buildertek__Amount_Out_2__c, buildertek__Eligible_Amount__c, buildertek__Product_Name__c, buildertek__Group__c, buildertek__Quantity__c,
                                                           buildertek__Unit_Price__c, buildertek__Original_Budget__c, buildertek__Budget__c, buildertek__Group_Name__c, buildertek__Total_CO__c, buildertek__Description__c,
                                                           buildertek__Product__c, buildertek__Approved_CO__c, buildertek__Pending_CO__c,
                                                           buildertek__Committed_Costs__c, buildertek__Direct_Costs__c,buildertek__Cost_Code__c,
                                                           buildertek__Pending_Costs__c, buildertek__Total_Costs__c, buildertek__Auto_Number__c, buildertek__Revised_Budget__c,
                                                           buildertek__Base_Sq_Feet__c, buildertek__Projected_Budget__c, buildertek__Forecast_To_Complete__c,
                                                           buildertek__Estimated_Cost_To_Complete__c, buildertek__Profit_Loss__c, buildertek__Projected_Costs__c, buildertek__Amount_Out__c, buildertek__Amount_In__c,
                                                           buildertek__Budget_Modification__c, buildertek__Regional_Factor__c, buildertek__Auto_Number1__c, buildertek__Cost_Code_Name__c, buildertek__Contractor__c, buildertek__Trade_Type__c, buildertek__Notes__c, buildertek__Contingency__c, buildertek__Budget_Line_Group__c, buildertek__Cost_Type__c, buildertek__Total_Approvals_CO__c,buildertek__CO_Total__c,
                                                           buildertek__Variance__c, buildertek__Expense_Amount__c, buildertek__Variance_Percentage__c, buildertek__Additional_Costs__c,
                                                           buildertek__Bought_Out__c, buildertek__Gross_Profit_Percemtage__c, buildertek__Upgrades__c, buildertek__Total_Cost__c, buildertek__Cost_P__c, buildertek__Discount__c, buildertek__Sales_Price__c, buildertek__Proj_Profit_Loss__c, buildertek__Projected_Gross_Profit__c, buildertek__Eligible_Contingency_Amount__c
                                                           From buildertek__Budget_Item__c
                                                           where (buildertek__Budget__c = :recordId and buildertek__Contingency__c = false)
                                                           ORDER BY Name ASC];
        List<buildertek__Budget_Item__c> contingencyItemList = [select ID, Name, buildertek__Amount_Out_2__c, buildertek__Eligible_Amount__c, buildertek__Product_Name__c, buildertek__Group__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Original_Budget__c, buildertek__Budget__c, buildertek__Group_Name__c,buildertek__Cost_Code__c, buildertek__Total_CO__c, buildertek__Description__c, buildertek__Product__c, buildertek__Approved_CO__c, buildertek__Pending_CO__c, buildertek__Committed_Costs__c, buildertek__Direct_Costs__c, buildertek__Pending_Costs__c, buildertek__Total_Costs__c, buildertek__Auto_Number__c, buildertek__Revised_Budget__c, buildertek__Base_Sq_Feet__c, buildertek__Projected_Budget__c, buildertek__Forecast_To_Complete__c, buildertek__Estimated_Cost_To_Complete__c, buildertek__Profit_Loss__c, buildertek__Projected_Costs__c, buildertek__Amount_Out__c, buildertek__Amount_In__c, buildertek__Budget_Modification__c, buildertek__Regional_Factor__c, buildertek__Auto_Number1__c, buildertek__Cost_Code_Name__c, buildertek__Contractor__c, buildertek__Trade_Type__c, buildertek__Notes__c, buildertek__Contingency__c, buildertek__Budget_Line_Group__c, buildertek__Cost_Type__c, buildertek__Total_Approvals_CO__c,buildertek__CO_Total__c, buildertek__Variance__c, buildertek__Expense_Amount__c, buildertek__Variance_Percentage__c, buildertek__Additional_Costs__c, buildertek__Bought_Out__c, buildertek__Gross_Profit_Percemtage__c, buildertek__Upgrades__c, buildertek__Total_Cost__c, buildertek__Cost_P__c, buildertek__Discount__c, buildertek__Sales_Price__c, buildertek__Proj_Profit_Loss__c, buildertek__Projected_Gross_Profit__c, buildertek__Eligible_Contingency_Amount__c
                                                                from buildertek__Budget_Item__c
                                                                where buildertek__Budget__c = :recordId and buildertek__Contingency__c = true
                                                                ORDER BY Name ASC];
        budgetItemMap.put('budgetItemList', budgetItemList);
        budgetItemMap.put('contingencyItemList', contingencyItemList);
        return JSON.serialize(budgetItemMap);
        /*  } catch (Exception e){
System.debug('Error Message::' + e.getMessage());
System.debug('Error Line Number::' + e.getLineNumber());
}*/
        return null;
    }

    @AuraEnabled
    public static String transferAmount(Boolean isLeftToRight, String budgetId, String budgetLineId, String budgetAmount, String contingencyId, String contingencyAmount, String amount, String note){
        try{
            if (String.isNotBlank(amount) && String.isNotBlank(note)){
                if (isLeftToRight){
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Id = budgetLineId;
                    budgetItem.buildertek__Amount_In__c = Decimal.valueOf(budgetAmount);
                    budgetItem.buildertek__Notes__c = note;
                    update budgetItem;

                    budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Id = contingencyId;
                    budgetItem.buildertek__Amount_Out_2__c = Decimal.valueOf(contingencyAmount);
                    budgetItem.buildertek__Notes__c = note;
                    update budgetItem;
                } else{
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Id = budgetLineId;
                    budgetItem.buildertek__Amount_Out_2__c = Decimal.valueOf(budgetAmount);
                    budgetItem.buildertek__Notes__c = note;
                    update budgetItem;

                    budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Id = contingencyId;
                    budgetItem.buildertek__Amount_In__c = Decimal.valueOf(contingencyAmount);
                    budgetItem.buildertek__Notes__c = note;
                    update budgetItem;
                }
                return getContingencyBudgetItems(budgetId);
            } else{
                throw new AuraHandledException('Required field is missing');
            }
        } catch (Exception e){
           // System.debug('Error Message::' + e.getMessage());
            //System.debug('Error Line Number::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /*Method to used to set Product name in Budget item Name field*/
    public static void setProductNameToItemName(List<buildertek__Budget_Item__c> budgetItems){

        Set<Id> productIds = new set<Id>();
        for (buildertek__Budget_Item__c bItem : budgetItems){
            if (bItem.buildertek__Product__c != null){
                productIds.add(bItem.buildertek__Product__c);
            }
        }

        Map<Id, Product2> productByIDs = new map<Id, Product2>([Select Id, Name
                                                                from Product2
                                                                where Id IN :productIds
                                                                ORDER BY Name ASC]);

        for (buildertek__Budget_Item__c bItem : budgetItems){
            if (bItem.buildertek__Product__c != null && productByIDs.ContainsKey(bItem.buildertek__Product__c)){
                bItem.Name = productByIDs.get(bItem.buildertek__Product__c).Name;
                bItem.buildertek__Item_Name__c = productByIDs.get(bItem.buildertek__Product__c).Name;

                if (bItem.Name.length() > 80){
                    bItem.Name = bItem.Name.substring(0, 79);
                }
            }
        }
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a Budget Item from PO items
Parameters: Map<Id, Id> purchaseOrderItemIdByBudgetItem
Returns: List<Purchase_Order_Item__c>
Throws [Exceptions]:
**********************************************************************************************************************/
    public static void updateBudgetItemModificationInAmount(List<buildertek__Budget_Modifications__c> budgetModifications){
        set<Id> toBudgetItemIds = new set<Id>();
        for (buildertek__Budget_Modifications__c bdM : budgetModifications){
            toBudgetItemIds.add(bdm.buildertek__To__c);
        }

        List<buildertek__Budget_Item__c> budgetItemsToUpdate = new List<buildertek__Budget_Item__c>();
        List<string> listrec = new List<string>();
        Map<string, decimal> MapLists = new Map<string, decimal>();
        AggregateResult[] groupedResults;
        if (Schema.sObjectType.buildertek__Budget_Modifications__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget_Modifications__c.fields.buildertek__To__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Modifications__c.fields.buildertek__Amount__c.isAccessible()){
            groupedResults = [SELECT buildertek__To__c, SUM(buildertek__Amount__c)
                              FROM buildertek__Budget_Modifications__c
                              where buildertek__To__c IN :toBudgetItemIds
                              GROUP BY buildertek__To__c];
        }
        for (AggregateResult ar : groupedResults){
            // Budget_Item__c budgetItem = new Budget_Item__c();

            //  budgetItem.Id = (Id)ar.get('buildertek__To__c');
            //  budgetItem.Amount_In__c = (Decimal)ar.get('expr0');
            //  budgetItemsToUpdate.add(budgetItem);
            listrec.add((Id)ar.get('buildertek__To__c'));
            MapLists.put((Id)ar.get('buildertek__To__c'), (Decimal)ar.get('expr0'));

        }
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Amount_In__c.isAccessible()){
            budgetItemsToUpdate = [select id, buildertek__Amount_In__c
                                   from buildertek__Budget_Item__c
                                   where id IN :listrec
                                   ORDER BY Name ASC];
        }

        for (buildertek__Budget_Item__c BD : budgetItemsToUpdate){
            Bd.buildertek__Amount_In__c = MapLists.get(Bd.Id);
        }
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Amount_In__c.isUpdateable()){
            update budgetItemsToUpdate;
        }
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a Budget Item from PO items
Parameters: Map<Id, Id> purchaseOrderItemIdByBudgetItem
Returns: List<Purchase_Order_Item__c>
Throws [Exceptions]:
**********************************************************************************************************************/
    public static List<buildertek__Purchase_Order_Item__c> createBudgetItemFromPOItem(List<buildertek__Purchase_Order_Item__c> poItems){
        List<buildertek__Budget_Item__c> budgetItems = new List<buildertek__Budget_Item__c>();
        Set<Id> poIds = new Set<Id>();
        for (buildertek__Purchase_Order_Item__c poItem : poItems){
            poIds.add(poItem.buildertek__Purchase_Order__c);
        }
        Map<Id, buildertek__Purchase_Order__c> poIdToPO = new Map<Id, buildertek__Purchase_Order__c>([Select Id, buildertek__Budget__c
                                                                                                      from buildertek__Purchase_Order__c
                                                                                                      Where Id IN :poIds
                                                                                                      ORDER BY Name ASC]);
        Map<Integer, buildertek__Budget_Item__c> poItemIndexToBudgetItem = new Map<Integer, buildertek__Budget_Item__c>();

        Integer index = 0;
        for (buildertek__Purchase_Order_Item__c poItem : poItems){

            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();

            budgetItem.buildertek__Budget__c = poIdToPO.get(poItem.buildertek__Purchase_Order__c).buildertek__Budget__c;
            budgetItem.Name = poItem.buildertek__Item_Name__c;
            budgetItem.buildertek__Item_Name__c = poItem.buildertek__Item_Name__c;
            budgetItem.buildertek__Description__c = poItem.buildertek__Description__c;
            budgetItem.buildertek__Cost_Code__c = poItem.buildertek__Cost_Code__c;
            budgetItem.buildertek__Notes__c = poItem.buildertek__Notes__c;

            budgetItems.add(budgetItem);

            poItemIndexToBudgetItem.put(index, budgetItem);
            index++;
        }

        if (!BudgetItems.isEmpty()){

            insert BudgetItems;

        }

        index = 0;
        for (buildertek__Purchase_Order_Item__c poItem : poItems){
            poItem.buildertek__budget_Item__c = poItemIndexToBudgetItem.get(index).id;
            index++;
        }

        return poItems;
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a New budgetline group
Parameters: budgetlinegrouping data
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static string savenewbudgetlinegroup(string newbudgetllinegroup, string newbudgetllinegroupdes){
        //   buildertek__Budget_Line_Group__c budgetlinegroupToInsert = (buildertek__Budget_Line_Group__c)JSON.deserialize(newbudgetllinegroup, buildertek__Budget_Line_Group__c.class);
        List<buildertek__Budget_Line_Group__c> budgetGroup = [SELECT Id
                                                              FROM buildertek__Budget_Line_Group__c
                                                              WHERE Name = :newbudgetllinegroup
                                                              ORDER BY Name ASC];
        string nameexist;
        if (budgetGroup.size() > 0){
            nameexist = 'This group Name is exist Please try with another Name';
        } else{
            buildertek__Budget_Line_Group__c budgetlinegroupToInsert = new buildertek__Budget_Line_Group__c();
            budgetlinegroupToInsert.Name = newbudgetllinegroup;
            budgetlinegroupToInsert.buildertek__Description__c = newbudgetllinegroupdes;
            insert budgetlinegroupToInsert;
            nameexist = 'Success';
        }

        return nameexist;
    }

    @AuraEnabled
    public static string saveNewBudgetSubGroup(string budgetLineSubGroupName, string budgetLineSubGroupDescription){
        List<buildertek__Budget_Line_Sub_Group__c> budgetGroup = [SELECT Id
                                                                  FROM buildertek__Budget_Line_Sub_Group__c
                                                                  WHERE Name = :budgetLineSubGroupName
                                                                  ORDER BY Name ASC];
        string nameexist;
        if (budgetGroup.size() > 0){
            nameexist = 'This group Name is exist Please try with another Name';
        } else{
            buildertek__Budget_Line_Sub_Group__c budgetLineSubGroupToInsert = new buildertek__Budget_Line_Sub_Group__c();
            budgetLineSubGroupToInsert.Name = budgetLineSubGroupName;
            budgetLineSubGroupToInsert.buildertek__Description__c = budgetLineSubGroupDescription;
            insert budgetLineSubGroupToInsert;
            nameexist = 'Success';
        }

        return nameexist;
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a Budget Item from selected products
Parameters: String budgetId, String groupId, List<String> selectedProductIds
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static string createBudgetItem(string budgetItemsJSON){
      //  system.debug('budgetItemsJSON -------> ' + budgetItemsJSON);
        try{
            List<String> groupIds = new List<String>();
            map<String, String> budgetIdByGroupId = new map<String, String>();
            set<Id> newQuoteWithoutGroup = new set<Id>();
            List<buildertek__Budget_Item__c> budgetItemsToInsert = (List<buildertek__Budget_Item__c>)System.JSON.deserialize(budgetItemsJSON, List<buildertek__Budget_Item__c>.class);
            //insert (List<buildertek__Budget_Item__c>)System.JSON.deserialize(quoteItemsJSON, List<buildertek__Budget_Item__c>.class);
          //  system.debug('budgetItemsToInsert ----------> ' + budgetItemsToInsert);
            for (buildertek__Budget_Item__c budItem : budgetItemsToInsert){
               // system.debug('budItem.buildertek__Group__c --------> ' + budItem.buildertek__Group__c);
                if (budItem.buildertek__Group__c != null){
                    groupIds.add(budItem.buildertek__Group__c);
                    budgetIdByGroupId.put(budItem.Id, budItem.buildertek__Group__c);
                }
            }
            string budgrpid;
            List<buildertek__Budget_Line_Group__c> budGrouping = [SELECT Id
                                                                  FROM buildertek__Budget_Line_Group__c
                                                                  WHERE Name = 'No Grouping'
                                                                  ORDER BY Name ASC
                                                                  limit 1];

            if (budGrouping.size() > 0){
                budgrpid = budGrouping[0].Id;
            } else{
                buildertek__Budget_Line_Group__c budGroup = new buildertek__Budget_Line_Group__c();
                budGroup.Name = 'No Grouping';
                insert budGroup;
                budgrpid = budGroup.Id;
            }
          //  system.debug('Is Empty ----------> ' + groupIds.isEmpty());
            if (!groupIds.isEmpty()){
               // system.debug('Not Empty ----------> ' + groupIds);
                for (buildertek__Budget_Item__c budgetItem : budgetItemsToInsert){
                  //  system.debug('budgetItem.Id ' + budgetItem.Id);
                    if (budgetItem.Id != null){
                        budgetItem.buildertek__Group__c = budgetIdByGroupId.get(budgetItem.Id);
                    }
                    if (budgetItem.buildertek__Group__c == null){
                      //  system.debug('budgetItem.buildertek__Group__c ' + budgetItem.buildertek__Group__c);
                        budgetItem.buildertek__Group__c = budgrpid;
                    }
                }
            } else{
                List<buildertek__Budget_Line_Group__c> budgetGroup = [SELECT Id
                                                                      FROM buildertek__Budget_Line_Group__c
                                                                      WHERE Name = 'No Grouping'
                                                                      ORDER BY Name ASC];
              //  system.debug('budgetGroup ----------> ' + budgetGroup);
                if (budgetGroup.size() > 0){
                    for (buildertek__Budget_Item__c bItem : budgetItemsToInsert){
                        if (bItem.buildertek__Group__c == null){
                            bItem.buildertek__Group__c = budgetGroup[0].Id;
                        }
                    }
                } else{
                    buildertek__Budget_Line_Group__c budGroup = new buildertek__Budget_Line_Group__c();

                    budGroup.Name = 'No Grouping';

                    insert budGroup;
                  //  system.debug('budGroup ----------> ' + budGroup);
                    for (buildertek__Budget_Item__c bItem : budgetItemsToInsert){
                        bItem.buildertek__Group__c = budGroup.Id;
                        budgetItemsToInsert.add(bItem);
                    }
                }
            }

            insert budgetItemsToInsert;

            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
        return null;
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a RFQ from selected budget itmes
Parameters: Budget__c budget, RFQ__c rfq, string rfqItemsJson
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static string createRFQFromBudget(buildertek__Budget__c budget, string rfqJson, string rfqItemsJson){

        try{
            buildertek__RFQ__c rfqRec = new buildertek__RFQ__c();
            if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.Project__c.isCreateable() && Schema.sObjectType.buildertek__RFQ__c.fields.RFQ_Workflow_Stage__c.isCreateable()){
                rfqRec = (buildertek__RFQ__c)System.JSON.deserialize(rfqJson, buildertek__RFQ__c.class);
                rfqRec.buildertek__Budget__c = budget.Id;
                rfqRec.buildertek__Project__c = budget.buildertek__Project__c;
                rfqRec.buildertek__RFQ_Workflow_Stage__c = '3';
            }
            Database.insert(rfqRec, true);

            List<buildertek__RFQ_Item__c> rfqItems = new List<buildertek__RFQ_Item__c>();
            rfqItems = (List<buildertek__RFQ_Item__c>)System.JSON.deserialize(rfqItemsJson, List<buildertek__RFQ_Item__c>.class);
            for (buildertek__RFQ_Item__c rfqItem : rfqItems){
                rfqItem.buildertek__RFQ_Package__c = rfqRec.Id;
                //rfqItems.add(rfqItem);
            }

            if (rfqItems.size() > 0){
                if (Schema.sObjectType.buildertek__RFQ_Item__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Notes_Details__c.isCreateable() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Description__c.isCreateable()){
                    insert rfqItems;
                }
            }
            return 'Success';

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }

        return null;
    }

    /*for(List<RFQ_Item__c> rfqItems : [Select Id, Name ,RFQ_Package__c from RFQ_Item__c]){
for(Integer i=0; i<rfqItems.size(); i++){ //data manipulation logic } update listOfMatches; }
//   RFQ_Item__c rfqRef = new RFQ_Item__c();
rfqItems.RFQ_Package__c = rfq.Id;
rfqItems.add(rfqItem);
}
insert rfqItems;
}
// insert rfqItems;
return 'Success';
}catch(Exception ex){
throw new AuraHandledException(ex.getMessage());
}
return null;
}   */
    /**********************************************************************************************************************
Purpose: This method is used to create a PO from selected budget itmes
Parameters: Budget__c budget, Purchase_Order__c po, string poItemsJson
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static string createPOFromBudget(buildertek__Budget__c budget, string poJson, string poItemsJson){

        try{
           Account accRec = [select id,Name from Account limit 1];
            buildertek__Purchase_Order__c PORec = new buildertek__Purchase_Order__c();
            if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable()){
                PORec = (buildertek__Purchase_Order__c)System.JSON.deserialize(poJson, buildertek__Purchase_Order__c.class);
                PORec.buildertek__Budget__c = budget.Id;
                PORec.buildertek__Project__c = budget.buildertek__Project__c;
                 if(budget.buildertek__Project__r.buildertek__Customer__c != null){
                    PORec.buildertek__Vendor__c = budget.buildertek__Project__r.buildertek__Customer__c;
                } else{
                    PORec.buildertek__Vendor__c = accRec.id;
                }
                //  po.Vendor__r = null;
            }
            //insert po;
            Database.insert(PORec, true);

            List<buildertek__Purchase_Order_Item__c> poItems = new List<buildertek__Purchase_Order_Item__c>();
            poItems = (List<buildertek__Purchase_Order_Item__c>)System.JSON.deserialize(poItemsJson, List<buildertek__Purchase_Order_Item__c>.class);

            for (buildertek__Purchase_Order_Item__c poItem : poItems){
                poItem.buildertek__Purchase_Order__c = PORec.Id;
                //poItems.add(poItem);
            }
            if (Schema.sObjectType.buildertek__Purchase_Order_Item__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isCreateable()){
                insert poItems;
            }
            return 'Success';

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }

        return null;
    }

    /**********************************************************************************************************************
Purpose: This method is used to create a CO from selected budget itmes
Parameters: Budget__c budget, Change_Order__c co, string coItemsJson
Returns: string "Success"
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static string createCOFromBudget(buildertek__Budget__c budget, string coJson, string coItemsJson){

        try{
            buildertek__Change_Order__c coRec = new buildertek__Change_Order__c();
            if (Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isCreateable()){
                coRec = (buildertek__Change_Order__c)System.JSON.deserialize(coJson, buildertek__Change_Order__c.class);
                coRec.buildertek__Budget__c = budget.Id;
                coRec.buildertek__Project__c = budget.Project__c;
                //co.Vendor__r = null;
            }
            insert coRec;

            List<buildertek__Change_Order_Item__c> coItems = new List<buildertek__Change_Order_Item__c>();
            coItems = (List<buildertek__Change_Order_Item__c>)System.JSON.deserialize(coItemsJson, List<buildertek__Change_Order_Item__c>.class);
            for (buildertek__Change_Order_Item__c coItem : coItems){
                coItem.buildertek__Change_Order__c = coRec.Id;
                coItems.add(coItem);
            }
            if (Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Change_Order__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Price__c.isCreateable()){
                insert coItems;
            }
            return 'Success';

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }

        return null;
    }

    /**********************************************************************************************************************
Purpose: This method is used to get price from the active pricebook for the selected product in inline add budget line item
Parameters: ProductId
Returns: Pricebookentry List
Throws [Exceptions]:
**********************************************************************************************************************/
    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId, String pricebookId){

        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c
                from PricebookEntry
                where product2Id = :productId and pricebook2Id =: pricebookId];

    //  system.debug('====pList' + pList);
        return pList;
    }

    @AuraEnabled
    public static buildertek__Budget_Item__c saveBudgetLineItem(string budgetLineRecord, String recordId, String contractor){
     //   System.debug('---Budget Line Items' + budgetLineRecord);
        buildertek__Budget_Item__c budgetRec = new buildertek__Budget_Item__c();
        budgetRec = (buildertek__Budget_Item__c)System.JSON.deserialize(budgetLineRecord, buildertek__Budget_Item__c.class);
        System.debug('budgetRec------------------>'+budgetRec);
      //  system.debug('Budget Group ------------> ' + budgetRec.buildertek__Budget_Line_Group__c);

        /*  if(budgetRec.buildertek__Budget_Line_Group__c == null){
List<buildertek__Quote_Line_Group__c> budgetGroup = [select Id, Name from buildertek__Quote_Line_Group__c where Name = 'No Grouping'];
if(budgetGroup.size() > 0){
budgetRec.buildertek__Budget_Line_Group__c = budgetGroup[0].Id;
}else{
buildertek__Quote_Line_Group__c budGroup = new buildertek__Quote_Line_Group__c();
if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
budGroup.Name = 'No Grouping';
}
insert budGroup;
budgetRec.buildertek__Budget_Line_Group__c = budGroup.Id;
}

} */
        // Modified by laxman 08/07/2020
        // Description :- here we goup the Budgetline items based on the buildertek__Group__c field.
        if (budgetRec.buildertek__Group__c == null){
            List<buildertek__Budget_Line_Group__c> budgetGroup = [select Id, Name
                                                                  from buildertek__Budget_Line_Group__c
                                                                  where Name = 'No Grouping'
                                                                  ORDER BY Name ASC];
            if (budgetGroup.size() > 0){
                budgetRec.buildertek__Group__c = budgetGroup[0].Id;
            } else{
                buildertek__Budget_Line_Group__c budGroup = new buildertek__Budget_Line_Group__c();
                budGroup.Name = 'No Grouping';
                insert budGroup;
                budgetRec.buildertek__Group__c = budGroup.Id;
            }
        }

       /* if (budgetRec.buildertek__Product__c != null){
            product2 prdctrec = [SELECT id, Name, buildertek__Cost_Code__c
                                 FROM product2
                                 where Id = :budgetRec.buildertek__Product__c];
            budgetRec.buildertek__Cost_Code__c = prdctrec.buildertek__Cost_Code__c;
        }*/
        buildertek__Budget_Item__c BudgetLineToInsert = new buildertek__Budget_Item__c();

     //   System.debug('p------>---Budget Line Items recordId --> ' + budgetRec.buildertek__Product__c);
        //System.debug('---Budget Line Items recordId --> '+recordId);
        BudgetLineToInsert.buildertek__Product__c = budgetRec.buildertek__Product__c;
        //BudgetLineToInsert.buildertek__Product__c = productId;
        if (budgetRec.Name.length() > 79){
            BudgetLineToInsert.Name = budgetRec.Name.left(78);
            BudgetLineToInsert.buildertek__Description__c = budgetRec.Name;
        } else{
            BudgetLineToInsert.Name = budgetRec.Name;
        }
        BudgetLineToInsert.buildertek__Budget__c = budgetRec.buildertek__Budget__c;
        BudgetLineToInsert.buildertek__Budget_Line_Group__c = budgetRec.buildertek__Budget_Line_Group__c;
        BudgetLineToInsert.buildertek__UOM__c = budgetRec.buildertek__UOM__c;
        BudgetLineToInsert.buildertek__Notes__c = budgetRec.buildertek__Notes__c;
        BudgetLineToInsert.buildertek__Contractor__c = contractor;
        // BudgetLineToInsert.buildertek__Trade_Type__c = tradeType;
        BudgetLineToInsert.buildertek__Unit_Price__c = budgetRec.buildertek__Unit_Price__c;
        BudgetLineToInsert.buildertek__Sales_Price__c = budgetRec.buildertek__Sales_Price__c;
        BudgetLineToInsert.buildertek__Quantity__c = budgetRec.buildertek__Quantity__c;
        BudgetLineToInsert.buildertek__Budget__c = budgetRec.buildertek__Budget__c;
        BudgetLineToInsert.buildertek__Cost_Code__c = budgetRec.buildertek__Cost_Code__c;
        BudgetLineToInsert.buildertek__Group__c = budgetRec.buildertek__Group__c;
        BudgetLineToInsert.buildertek__Sub_Grouping__c = budgetRec.buildertek__Sub_Grouping__c;
        BudgetLineToInsert.buildertek__Discount__c = budgetRec.buildertek__Discount__c;
      //  System.debug('---Budget Line Items recordId 321--> ' + BudgetLineToInsert);
        insert BudgetLineToInsert;
        System.debug('---------------BudgetLineToInsert------------------>>>>>'+BudgetLineToInsert);

       // system.debug('Created budgetLineRecord: ' + BudgetLineToInsert);

        return BudgetLineToInsert;
    }

    @AuraEnabled
    public static Object retrieveGroups(string budgetId, Decimal pageNumber, Integer recordToDisply){
        try{
            Integer pageSize = recordToDisply;
            Integer offset = ((Integer)pageNumber - 1) * pageSize;

            budgetDetails budgetDetail = new budgetDetails();
            budgetDetail.groups = getBudgetGroupDetails(budgetId, null, recordToDisply, offset);
            budgetDetail.subGroups = getBudgetSubGroupDetails(budgetId, null, recordToDisply, offset);
            budgetDetail.columns = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Budget_Item__c', 'buildertek__BT_Related_List_View_Fields');
          //  system.debug(budgetDetail.columns);
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, String> formulaMap = new Map<String, String>();
            Schema.SObjectType objectSchema = schemaMap.get('buildertek__Budget_Item__c');
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()){
                Schema.DescribeFieldResult df = fieldMap.get(fieldName).getDescribe();
                if (df.isCalculated() && df.getCalculatedFormula() != null){
                    formulaMap.put(fieldName, String.valueOf(df.getCalculatedFormula().replace('\n', ' ').replace('\r', ' ')));
                }
            }
            List<String> groupIds = new List<String>();
            List<String> subGroupIds = new List<String>();
            List<String> allFields = new List<String>();
            List<String> fieldsList = new List<String>();
            String fieldsType = '[';
            List<String> fieldsTypeList = new List<String>();
            for (Budget_Line_Group__c grp : budgetDetail.groups){
                groupIds.add(grp.Id);
            }
            for (BT_Lightning_Utils.dataTableFields dtFields : budgetDetail.columns){
                //sai
               // system.debug('dtFieldsName'+dtFields);
                if (dtFields.type != 'reference'){
                    allFields.add(dtFields.fieldName);
                }
                if (dtFields.type == 'currency' ){ //|| dtFields.fieldName == 'buildertek__Gross_Profit_Percemtage__c' || dtFields.fieldName == 'buildertek__Gross_Profit_Margin__c' || dtFields.fieldName == 'buildertek__Projected_Gross_Profit__c' || dtFields.fieldName == 'buildertek__Bought_Out__c'){
                    //sai
                   // system.debug('dtFieldscurrency'+dtFields);
                    fieldsList.add(dtFields.fieldName);
                }

                if (dtFields.type == 'reference'){
                        allFields.add(dtFields.fieldName.replace('__c', '__r.Name'));
                }
                fieldsType += '{"fieldName": "' + dtFields.fieldName + '","fieldType": "' + dtFields.type + '","isEditable":' + dtFields.editable + '},';
            }
            allFields.add('Id');
            allFields.add('buildertek__Group__c');
            allFields.add('buildertek__Group__r.Name');
            allFields.add('buildertek__Sub_Grouping__c');
            allFields.add('buildertek__Sub_Grouping__r.Name');
            allFields.add('buildertek__CostCodeDivision__c');
            allFields.add('buildertek__Cost_Code__c');
            allFields.add('buildertek__Cost_Code__r.Name');
            if(!allFields.contains('buildertek__Contractor__r.Name')){
                allFields.add('buildertek__Contractor__c');
                allFields.add('buildertek__Contractor__r.Name');
                fieldsType += '{"fieldName": "buildertek__Contractor__c","fieldType": "Reference","isEditable": false},';
            }
            fieldsType += '{"fieldName": "buildertek__Group__c","fieldType": "Reference","isEditable": false},';
            fieldsType += '{"fieldName": "buildertek__Group__r.Name","fieldType": "Reference","isEditable": false},';
            fieldsType += '{"fieldName": "buildertek__Sub_Grouping__c","fieldType": "Reference","isEditable": false},';
            fieldsType += '{"fieldName": "buildertek__Sub_Grouping__r.Name","fieldType": "Reference","isEditable": false},';
            fieldsType += '{"fieldName": "buildertek__CostCodeDivision__c","fieldType": "","isEditable": false},';
            fieldsType += '{"fieldName": "Id","fieldType": "","isEditable": false}]';

            List<wrapperClass> wrapperList = new List<wrapperClass>();
            wrapperList = groupValues(budgetId, fieldsList, allFields, groupIds, recordToDisply, offset);
            TargetTable tarTable = new TargetTable();
            tarTable = getBudgetItemData(budgetId, allFields, fieldsType, recordToDisply, offset);
            FinalWrapperClass wrap = new FinalWrapperClass();
            wrap.tarTable = tarTable;
            wrap.wrapperList = wrapperList;
            wrap.columns = budgetDetail.columns;
            wrap.formulaFields = JSON.serialize(formulaMap);
            wrap.groups = budgetDetail.groups;
            wrap.subGroups = budgetDetail.subGroups;
            wrap.pageSize = pageSize;
            wrap.page = (Integer)pageNumber;
            wrap.total = [SELECT count()
                          FROM buildertek__Budget_Item__c
                          WHERE buildertek__Budget__c = :budgetId];
            return wrap;
        } catch (Exception e){
            //System.debug('Error Message::' + e.getMessage());
           System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+''+  e.getLineNumber());
        }
    }

    /*  @AuraEnabled
public static quote_line_group__c updateBudgetLinFromDataTable(String budgetItems, String groupId, String budgetId){


update (List<Budget_Item__c>)System.JSON.deserialize(budgetItems, List<Budget_Item__c>.class);

system.debug('---------> '+(List<Budget_Item__c>)System.JSON.deserialize(budgetItems, List<Budget_Item__c>.class));

return getBudgetGroupDetails(budgetId, groupId, 50, 50)[0];
} */
    public static List<buildertek__Budget_Line_Group__c> getBudgetGroupDetails(String budgetId, String groupId, Decimal recordToDisply, Integer offset){
        // Add selected field in soql from field set
        String objectName = 'buildertek__Budget_Item__c';
        String filterConditions = ' AND buildertek__budget__c =:budgetId';
        String fieldSetAPI = 'buildertek__BT_Related_List_View_Fields';
        String soql = 'SELECT Id, Name ';
        soql = soql + ', Group__c, buildertek__Budget_Line_Group__c, Description__c, Product__c ';

        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
        for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            if (!soql.contains(fieldSetMemberObj.getFieldPath().replace(namespacePrefix, ''))){
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
        soql = soql + ' FROM buildertek__Budget_Item__c';

        soql = soql + ' WHERE buildertek__budget__c =: budgetId ORDER BY buildertek__Group__r.Name ASC limit ' + recordToDisply + ' OFFSET ' + offset;

        List<buildertek__Budget_Item__c> budgetItemList;

        budgetItemList = Database.query(soql);

       // system.debug('budgetItemList -----------> ' + budgetItemList);
        SET<Id> groupIdSet = new SET<Id>();
        for (buildertek__Budget_Item__c budgetItem : budgetItemList){
            groupIdSet.add(budgetItem.buildertek__Group__c);
        }

        List<buildertek__Budget_Line_Group__c> budgetGroup;
    //     String query = 'SELECT Id, Name ';
    //     query = query + ', buildertek__Group__c,Budget_Line_Group__c, Description__c, Product__c ';

    //     String namespacePrefix1 = BT_Utils.getNamespacePrefix();
    //     List<Schema.FieldSetMember> fieldSetMemberList1 = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
    //    // system.debug('fieldSetMemberList -----> ' + fieldSetMemberList1);
    //     for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList1){

    //         if (!query.contains(fieldSetMemberObj.getFieldPath())){
    //           //  system.debug('fieldSetMemberObj ********' + fieldSetMemberObj.getFieldPath());
    //             query = query + ',' + fieldSetMemberObj.getFieldPath();
    //         }

    //         if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE'){
    //             if (!fieldSetMemberObj.getFieldPath().Contains('__c')){
    //                 query = query + ',' + fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
    //             } else{
    //                 query = query + ',' + fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
    //             }
    //         }
    //     }
    //     query = query + ' FROM Budget_Items__r';

    //     if (budgetId != null){
    //         query = query + ' WHERE Id != null AND buildertek__budget__c =: budgetId ORDER BY Name ASC';
    //     } else{
    //         query = query + ' WHERE Id != null ORDER BY Name ASC';
    //     }

        if (groupId != null){

            budgetGroup = Database.query('Select Id, Name from buildertek__Budget_Line_Group__c where Id =: groupId ORDER BY Name ASC');

        } else{

            budgetGroup = Database.query('Select Id, Name from buildertek__Budget_Line_Group__c where Id IN: groupIdSet ORDER BY Name ASC');

        }


        /*if(budgetId != null)
budgetGroup = Database.query('Select Id, Name,('+soql+') from budget_line_group__c where budget__c =: budgetId ORDER BY Sort_id__c, Name ASC');
else if(groupId != null)
budgetGroup = Database.query('Select Id, Name,('+soql+') from budget_line_group__c where Id =: groupId ORDER BY Sort_id__c, Name ASC');*/
        return budgetGroup;
    }

    public static List<buildertek__Budget_Line_Sub_Group__c> getBudgetSubGroupDetails(String budgetId, String groupId, Decimal recordToDisply, Integer offset){
        // Add selected field in soql from field set
        String objectName = 'buildertek__Budget_Item__c';
        String filterConditions = ' AND buildertek__budget__c =:budgetId';
        String fieldSetAPI = 'buildertek__BT_Related_List_View_Fields';
        String soql = 'SELECT Id, Name ';
        soql = soql + ', Group__c, buildertek__Sub_Grouping__c, Description__c, Product__c ';

        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
        for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            if (!soql.contains(fieldSetMemberObj.getFieldPath().replace(namespacePrefix, ''))){
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
        soql = soql + ' FROM buildertek__Budget_Item__c';

        soql = soql + ' WHERE buildertek__budget__c =: budgetId ORDER BY buildertek__Sub_Grouping__r.Name ASC';

        List<buildertek__Budget_Item__c> budgetItemList;
        budgetItemList = Database.query(soql);
        SET<Id> groupIdSet = new SET<Id>();
        for (buildertek__Budget_Item__c budgetItem : budgetItemList){
            if (budgetItem.buildertek__Sub_Grouping__c != null && String.isNotBlank(budgetItem.buildertek__Sub_Grouping__c)){
                groupIdSet.add(budgetItem.buildertek__Sub_Grouping__c);
            }
        }
        List<buildertek__Budget_Line_Sub_Group__c> budgetGroup;
        // String query = 'SELECT Id, Name ';
        // query = query + ', buildertek__Sub_Grouping__c,Budget_Line_Group__c, Description__c, Product__c ';

        // String namespacePrefix1 = BT_Utils.getNamespacePrefix();
        // List<Schema.FieldSetMember> fieldSetMemberList1 = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
        // for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList1){
        //     if (!query.contains(fieldSetMemberObj.getFieldPath())){
        //         query = query + ',' + fieldSetMemberObj.getFieldPath();
        //     }
        //     if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE'){
        //         if (!fieldSetMemberObj.getFieldPath().Contains('__c')){
        //             query = query + ',' + fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
        //         } else{
        //             query = query + ',' + fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
        //         }
        //     }
        // }
        // query = query + ' FROM Budget_Items__r';

        // if (budgetId != null){
        //     query = query + ' WHERE Id != null AND buildertek__budget__c =: budgetId ORDER BY Name ASC';
        // } else{
        //     query = query + ' WHERE Id != null ORDER BY Name ASC';
        // }

        if (groupId != null){
            budgetGroup = Database.query('Select Id, Name from buildertek__Budget_Line_Sub_Group__c where Id =: groupId ORDER BY Name ASC');
        } else{
            budgetGroup = Database.query('Select Id, Name from buildertek__Budget_Line_Sub_Group__c where Id IN: groupIdSet ORDER BY Name ASC');
        }
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
    public static void updateGroupsOrder(List<budget_line_group__c> groups){
        try{
            DMLManager.updateAsUser(groups);
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteGroups(List<budget_line_group__c> groups){
        try{
            DMLManager.deleteAsUser(groups);
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static buildertek__Budget_Line_Group__c deleteBudgetItem(List<buildertek__Budget_Item__c> budgetItems, String groupId, String budgetId){
        try{
            DMLManager.deleteAsUser(budgetItems);
            return getBudgetGroupDetails(budgetId, groupId, 50, 50)[0];
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Budget_Item__c getBudgetItem(string budgetLineRecord){
        Budget_Item__c BudgetItem;


        BudgetItem = [select Id, Name, buildertek__Product_Name__c, buildertek__Product__c, buildertek__Budget__c, buildertek__Cost_Code__c, buildertek__Cost_Code__r.Name, buildertek__Budget_Line_Group__c, buildertek__Group__r.Name, buildertek__UOM__c, buildertek__Trade_Type__c, buildertek__Contractor__c, buildertek__Unit_Price__c, buildertek__Quantity__c
                      from buildertek__Budget_Item__c
                      where Id = :budgetLineRecord
                      ORDER BY Name ASC];

        return BudgetItem;
    }

    @AuraEnabled
    public static void updateBudgetLineItem(string budgetLineRecord){
        buildertek__Budget_Item__c BudgetLineToInsert = new buildertek__Budget_Item__c();
        BudgetLineToInsert = (buildertek__Budget_Item__c)System.JSON.deserialize(budgetLineRecord, buildertek__Budget_Item__c.class);
        update BudgetLineToInsert;
    }

    @AuraEnabled
    public static string getpricebook(string BudgetId){
        list<buildertek__budget__c> budget;
        if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            budget = [select id, Name, buildertek__Project__r.buildertek__Price_Book__c
                      from buildertek__budget__c
                      where id = :BudgetId
                      ORDER BY Name ASC];
        }
        if (budget.size() > 0){
            return budget[0].buildertek__Project__r.buildertek__Price_Book__c;
        }
        return null;
    }

    @AuraEnabled
    //get Account Industry Picklist Values
    public static Map<String, String> getselect(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Budget_Item__c.buildertek__UOM__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    @AuraEnabled
    //get Account Industry Picklist Values
    public static Map<String, String> getselectOptions(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Budget_Item__c.buildertek__UOM__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    @AuraEnabled
    //get ProdcutFamily  Picklist Values
    public static Map<String, String> getselectOptionsforproductfamily(){
        Map<String, String> options = new Map<String, String>();
        //get product2 Product2 Field Describe
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        //get Product2 Product2 Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
      //  system.debug('options----' + options);
        return options;
    }


    //get Pricebook Values
    // public static Map<String, String> getpricebooks(){
    //     Map<String, String> options = new Map<String, String>();
    //     list<pricebook2> PriceList;
    //     PriceList = [select Id, Name from pricebook2 Where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
    //     for (pricebook2 p : PriceList){
    //         options.put(p.name, p.Id);
    //     }
    //     return options;
    // }

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }

   
    @AuraEnabled
    public static List<pricebookWrapper> getpricebooks(String recordId){
                
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();

        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [select Id, Name from pricebook2 Where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
        priceWrap.priceWrapList=PriceList;

        if(recordId != null){
            buildertek__Budget__c budgetRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Budget__c  WHERE Id = :recordId ORDER BY Name ASC];
            if(budgetRecord.buildertek__Project__c != null && budgetRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:budgetRecord.buildertek__Project__r.buildertek__Price_Book__c ORDER BY Name ASC LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }


    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    //get product family Values
    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
       // system.debug('ObjectName-->' + ObjectName);
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
        List<AggregateResult> productfamlylst = [SELECT toLabel(family) family
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
           // system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }

    @AuraEnabled
    public static list<Budget_Item__c> BudgetItemList(list<string> BudgetIds){
        list<Budget_Item__c> BudgetItemList;
        //if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Amount_In__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isAccessible()){
        BudgetItemList = [select Id, Name, buildertek__Product__c, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Gross_Profit_Percemtage__c,buildertek__Trade_Type__c, buildertek__Sales_Price__c
                          from buildertek__Budget_Item__c
                          where id IN :BudgetIds
                          ORDER BY Name ASC];
        //}
        return BudgetItemList;
    }

    @AuraEnabled
    public static List<buildertek__Schedule__c> checkSchedulesRecords(String projectId){
      //  system.debug(projectId);
        List<buildertek__Schedule__c> scheduleRecords = [SELECT Id, Name, buildertek__Description__c FROM buildertek__Schedule__c where buildertek__Project__c =: projectId];
      //  system.debug(scheduleRecords);//order by CreatedDate desc LIMIT 1
        return scheduleRecords;
    }

    @AuraEnabled
    public static void deleteLineItems(list<string> budgetItemIds){
        try{
            /* if(Schema.sObjectType.buildertek__Budget_Configurations__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Budget_Configurations__c.fields.buildertek__Disable_Validations__c.isCreateable()){
buildertek__Budget_Configurations__c s = buildertek__Budget_Configurations__c.getInstance();
s.Name = UserInfo.getUserID();
s.buildertek__Disable_Validations__c = true;
insert s;*/

            list<buildertek__Budget_Item__c> budgetItemLists;
            if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible()){
                budgetItemLists = [select id
                                   from buildertek__Budget_Item__c
                                   where id IN :budgetItemIds];
            }
            if (buildertek__Budget_Item__c.sObjectType.getDescribe().isDeletable()){
                delete budgetItemLists;
            }
            //if(buildertek__Budget_Configurations__c.sObjectType.getDescribe().isDeletable()){
            //delete s;
            //}
            //}
        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static buildertek__Budget_Item__c deleteBudgetLineItem(String budgetId){

        buildertek__Budget_Item__c budgetItem;
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible()){
            budgetItem = [SELECT Id
                          FROM buildertek__Budget_Item__c
                          WHERE Id = :budgetId];
        }
        if (buildertek__Budget_Item__c.sObjectType.getDescribe().isDeletable()){
            delete budgetItem;
        }
        return budgetItem;
    }

    @AuraEnabled
    public static list<buildertek__Budget_Item__c> RemovegroupingBudgetLineItems(String groupingid, string budgetId){

        list<buildertek__Budget_Item__c> budgetItem = new list<buildertek__Budget_Item__c>();
        budgetItem = [select id, name, buildertek__Group__c, buildertek__Group__r.name, buildertek__Budget__c
                      from buildertek__Budget_Item__c
                      where buildertek__Group__c = :groupingid and buildertek__Budget__c = :budgetId
                      ORDER BY name ASC];
       // system.debug('checklsit---' + budgetItem);
       // system.debug(budgetId + '-----idscheck---' + groupingid);
        if (budgetItem.size() > 0){
            List<buildertek__Budget_Line_Group__c> btGroup = [SELECT Id
                                                              FROM buildertek__Budget_Line_Group__c
                                                              WHERE Name = 'No Grouping'
                                                              ORDER BY Name ASC];

            if (btGroup.size() > 0){
                for (buildertek__Budget_Item__c bItem : budgetItem){
                    bItem.buildertek__Group__c = btGroup[0].Id;
                }
                update budgetItem;
            } else{
                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                budgetGroup.Name = 'No Grouping';
                insert budgetGroup;
                for (buildertek__Budget_Item__c bItem : budgetItem){
                    bItem.buildertek__Group__c = budgetGroup.Id;
                }
                update budgetItem;
            }


        }

        return budgetItem;
    }

    @AuraEnabled
    public static void deleteSelectedItems(List<String> recordIds){
        list<buildertek__Budget_Item__c> budgetItemLists;
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible()){
            budgetItemLists = [select id
                               from buildertek__Budget_Item__c
                               where id IN :recordIds];
        }
        if (buildertek__Budget_Item__c.sObjectType.getDescribe().isDeletable()){
            for(buildertek__Budget_Item__c budgetLine: budgetItemLists){
                System.debug('budgetLine--->>>>'+budgetLine);
            }
            delete budgetItemLists;
        }
    }

    @AuraEnabled
    public static List<wrapperClass> groupValues(String recordId, list<String> currencyFields, List<String> allFields, List<String> groupIds, Decimal recordToDisply, Integer offset){
        Map<string, string> mapForLabel = new Map<string, string>();
        Map<string, string> mapForFieldType = new Map<string, string>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType ctype = gd.get('buildertek__Budget_Item__c');
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
        for (String fieldName : fmap.keySet()){
            mapForLabel.put(fieldName, fmap.get(fieldName).getDescribe().getLabel());
            mapForFieldType.put(fieldName, string.valueof(fmap.get(fieldName).getDescribe().getType()));
        }
        List<buildertek__Budget_Item__c> BudgetItemList = new List<buildertek__Budget_Item__c>();
        List<buildertek__Budget_Item__c> BudgetItemList2 = new List<buildertek__Budget_Item__c>();
        list<AggregateResult> childObjGroup = new list<AggregateResult>();
        list<AggregateResult> subChildObjGroup = new list<AggregateResult>();
        string myqueries = '';
        String myquery = '';
        String queryFields = '';
        String aggregateFields = '';
        integer i = 1;
        for (string sumOfFields : currencyFields){
            queryFields += ', ' + sumOfFields.trim();
        }
        myquery = 'select buildertek__Group__c ' + queryFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId Order by buildertek__Group__r.Name, Name ASC nulls first limit ' + recordToDisply + ' OFFSET ' + offset;
      //  myquery = 'select buildertek__Group__c ' + queryFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId Order by buildertek__Group_Name__c DESC limit ' + recordToDisply + ' OFFSET ' + offset;

       // myquery = 'select buildertek__Cost_Code_Name__c ' + queryFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId Order by buildertek__Cost_Code_Name__c ASC limit ' + recordToDisply + ' OFFSET ' + offset;

       System.debug('---------------------');
       System.debug('myquery ==> '+myquery);

       BudgetItemList = database.query(myquery);

        for (string sumOfFields : currencyFields){
            //sai
          //  system.debug(sumOfFields);
            aggregateFields += ', SUM(' + sumOfFields.trim()+') total' + i;
          //  system.debug(aggregateFields);
            i++;
        }
        myqueries = 'select buildertek__Group__c ' + aggregateFields + ' from buildertek__Budget_Item__c where Id IN: BudgetItemList Group By buildertek__Group__c';
        childObjGroup = database.query(myqueries);

        string Childs = 'select Id, Name from buildertek__Budget_Line_Group__c where id IN: groupIds order by Name ASC';
        List<buildertek__Budget_Line_Group__c> childObjGroups;
        childObjGroups = database.query(Childs);

        Map<string, string> GroupNameMap = new Map<String, string>();
        for (buildertek__Budget_Line_Group__c Grps : childObjGroups){
            GroupNameMap.put((String)Grps.get('Id'), (String)Grps.get('Name'));
        }

        Map<String, Boolean> fieldTypeMap = new Map<String, Boolean>();
        for (string sumOfFields : currencyFields){
            fieldTypeMap.put(sumOfFields, true);
        }

        List<wrapperClass> wrapperClassList = new List<wrapperClass>();
        for (AggregateResult objAgr : childObjGroup){
            integer j = 1;
            integer child = 1;
            //sai
          //  system.debug(objAgr);
            for (string sumOfFields : allFields){
                //sai
               // system.debug(sumOfFields);
                if (child >= 2){
                    if (fieldTypeMap.get(sumOfFields) == true){
                        //sai
                       system.debug('test111'+new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Group__c')), (Decimal)objAgr.get('total' + j),
                                                                string.valueOf(mapForFieldType.get(sumOfFields.toLowercase().replace(' ', ''))),
                                                                sumOfFields,(String)objAgr.get('buildertek__Group__c'),null,null));
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Group__c')), (Decimal)objAgr.get('total' + j), string.valueOf(mapForFieldType.get(sumOfFields.toLowercase().replace(' ', ''))),
                                                              sumOfFields,(String)objAgr.get('buildertek__Group__c'),null,null));
                        j++;
                    } else{
                        //sai
                       system.debug('test222'+new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Group__c')), null, 'false', sumOfFields,
                                                                (String)objAgr.get('buildertek__Group__c'),null,null));
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Group__c')), null, 'false',
                                                              sumOfFields, (String)objAgr.get('buildertek__Group__c'),null,null));
                    }
                }
                child++;
            }
        }
        return wrapperClassList;
    }

    @AuraEnabled
    public static TargetTable getBudgetItemData(String recordId, List<String> fieldsList, String fieldString, Decimal recordToDisply, Integer offset){

        List<FieldClass> fieldClassList = (List<FieldClass>)System.JSON.deserialize(fieldString, List<FieldClass>.class);
        TargetTable TargetTable_inst = new TargetTable();
        List<EachRecord> allListOfRecords = new List<EachRecord>();
        String aggregateFields = '';
        String objectName = 'buildertek__Budget_Item__c';
        String listType = 'List<' + objectName + '>';
        String EachRecordType = '' + objectName + '';

        SObject IndividualMember = (SObject)Type.forName(EachRecordType).newInstance();
        for (string sumOfFields : fieldsList){
            if (sumOfFields != null){
                aggregateFields += ', ' + sumOfFields;
            }
        }
        String myqueries = '';
      string myquerie = '';
                myqueries = 'select buildertek__Budget__c  ' + aggregateFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId ORDER BY buildertek__CostCodeDivision__c ASC NULLS LAST, Name Asc limit ' + recordToDisply + ' OFFSET ' + offset;
               // myquerie = 'select buildertek__Budget__c  ' + aggregateFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId and buildertek__Group_Name__c = No Grouping Order By buildertek__Group_Name__c ASC limit ' + recordToDisply + ' OFFSET ' + offset;

           // if(nullspoRecList.size()>0){
           // myqueries.addAll(myquerie);
        //}
        //  myqueries = 'select buildertek__Budget__c  ' + aggregateFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId Order By buildertek__Group__r.Name, Name ASC ,buildertek__Cost_Code_Name__c DESC  limit ' + recordToDisply + ' OFFSET ' + offset;
      //  myqueries = 'select buildertek__Budget__c  ' + aggregateFields + ' from buildertek__Budget_Item__c where buildertek__Budget__c =: recordId Order By buildertek__Cost_Code_Name__c DESC limit ' + recordToDisply + ' OFFSET ' + offset;
        List<SObject> ListOfRecords;
        ListOfRecords = Database.query(myqueries);

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
                    if (field.fieldName != null && field.fieldName != 'buildertek__Group__c' && field.fieldName != 'buildertek__Group__r.Name' && field.fieldName != 'buildertek__Sub_Grouping__c' && field.fieldName != 'buildertek__Sub_Grouping__r.Name' && field.fieldName != 'Name'){
                        if (field.fieldType == 'currency'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '$0.00' : '$' + IndividualMember.get(field.fieldName), field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                          //  system.debug(IndividualMember.get(field.fieldName));
                            //temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? 0 : IndividualMember.get(field.fieldName)); //sai
                        } else if (field.fieldType == 'string'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName),field.fieldType, ''));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        } else if (field.fieldType == 'reference' && field.fieldName != null){
                            String referenceField = field.fieldName.replace('__c', '__r');
                            if (IndividualMember.getSobject(referenceField) != null && IndividualMember.getSobject(referenceField).get('Name') != null){
                                recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, String.valueOf(IndividualMember.getSobject(referenceField).get('Name'))));
                            } else{
                                recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '0.00%' : IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName),field.fieldType, ''));
                            }
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        } else{
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName)+'', field.fieldName, (IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName), field.fieldType, ''));
                            temp.add((IndividualMember.get(field.fieldName) == null) ? '' : IndividualMember.get(field.fieldName));
                        }
                    }
                }
                if (field.fieldName == 'buildertek__Group__c'){
                    Each_record_nested_List_Of_Fields.groupId = (Id)IndividualMember.get(field.fieldName);
                    if (IndividualMember.getSObject('buildertek__Group__r') != null && IndividualMember.getSObject('buildertek__Group__r').get('Name') != null){
                        Each_record_nested_List_Of_Fields.groupName = (String)IndividualMember.getSObject('buildertek__Group__r').get('Name');
                        Each_record_nested_List_Of_Fields.groupID = (String)IndividualMember.getSObject('buildertek__Group__r').get('Id');
                      //  system.debug('******'+(String)IndividualMember.getSObject('buildertek__Group__r').get('Id'));
                      //  system.debug('Each_record_nested_List_Of_Fields.groupID--->'+Each_record_nested_List_Of_Fields.groupID);
                    }
                }
                if (field.fieldName == 'buildertek__Contractor__c'){
                    Each_record_nested_List_Of_Fields.groupId = (Id)IndividualMember.get(field.fieldName);
                    if (IndividualMember.getSObject('buildertek__Contractor__r') != null && IndividualMember.getSObject('buildertek__Contractor__r').get('Name') != null){
                        Each_record_nested_List_Of_Fields.vendorName = (String)IndividualMember.getSObject('buildertek__Contractor__r').get('Name');
                        Each_record_nested_List_Of_Fields.vendorId = (String)IndividualMember.getSObject('buildertek__Contractor__r').get('Id');
                      //  system.debug('******'+(String)IndividualMember.getSObject('buildertek__Contractor__r').get('Id'));
                       // system.debug('Each_record_nested_List_Of_Fields.vendorId--->'+Each_record_nested_List_Of_Fields.vendorId);
                    }
                }
                 if (field.fieldName == 'buildertek__Cost_Code__c'){
                    Each_record_nested_List_Of_Fields.groupId = (Id)IndividualMember.get(field.fieldName);
                    if (IndividualMember.getSObject('buildertek__Cost_Code__r') != null && IndividualMember.getSObject('buildertek__Cost_Code__r').get('Name') != null){
                        Each_record_nested_List_Of_Fields.costName = (String)IndividualMember.getSObject('buildertek__Cost_Code__r').get('Name');
                        Each_record_nested_List_Of_Fields.costId = (String)IndividualMember.getSObject('buildertek__Cost_Code__r').get('Id');
                      //  system.debug('******'+(String)IndividualMember.getSObject('buildertek__Cost_Code__r').get('Id'));
                       // system.debug('Each_record_nested_List_Of_Fields.costId--->'+Each_record_nested_List_Of_Fields.costId);
                    }
                }
                if (field.fieldName == 'buildertek__Sub_Grouping__c'){
                    Each_record_nested_List_Of_Fields.subGroupId = (Id)IndividualMember.get(field.fieldName);
                    if (IndividualMember.getSObject('buildertek__Sub_Grouping__r') != null && IndividualMember.getSObject('buildertek__Sub_Grouping__r').get('Name') != null){
                        Each_record_nested_List_Of_Fields.subGroupName = (String)IndividualMember.getSObject('buildertek__Sub_Grouping__r').get('Name');
                    }
                }
                if (field.fieldName == 'Name'){
                    Each_record_nested_List_Of_Fields.recordName = (String)IndividualMember.get(field.fieldName);
                }
            }

            Each_record_nested_List_Of_Fields.recordCount = count;
            Each_record_nested_List_Of_Fields.recordValue = temp;
            Each_record_nested_List_Of_Fields.recordList = recList;
            allListOfRecords.add(Each_record_nested_List_Of_Fields);
            count++;
        }
        // Map<Id,List<EachRecord>> allrecords = new Map<Id,List<EachRecord>>();
        // Map<Id,List<EachRecord>> allrecords2 = new Map<Id,List<EachRecord>>();
        // for(Integer i = 0;i<allListOfRecords.size();i++){
        //     List<EachRecord> recordListData = allrecords.get(allListOfRecords[i].groupId);
        //     if(!allrecords.containsKey(allListOfRecords[i].groupId)){
        //         recordListData = new List<EachRecord>();
        //         recordListData.add(allListOfRecords[i]);
        //         allrecords.put(allListOfRecords[i].groupId,recordListData);
        //     }else{
        //         allrecords.get(allListOfRecords[i].groupId).add(allListOfRecords[i]);
        //     }
        // }

        // for(Integer i = 0;i<allListOfRecords.size();i++){
        //     List<EachRecord> recordListData = allrecords2.get(allListOfRecords[i].subGroupId);
        //     if(!allrecords2.containsKey(allListOfRecords[i].subGroupId)){
        //         recordListData = new List<EachRecord>();
        //         recordListData.add(allListOfRecords[i]);
        //         allrecords2.put(allListOfRecords[i].subGroupId,recordListData);
        //     }else{
        //         allrecords2.get(allListOfRecords[i].subGroupId).add(allListOfRecords[i]);
        //     }
        // }
        // Map<Id,List<EachRecord>> allrecords3 = new Map<Id,List<EachRecord>>();
        // for(Integer i = 0;i<allListOfRecords.size();i++){
        //     if(allrecords.containsKey(allListOfRecords[i].groupId) && allrecords2.containsKey(allListOfRecords[i].subGroupId)){

        //     }
        // }
        TargetTable_inst.records = ListOfRecords;
        TargetTable_inst.ListOfEachRecord = allListOfRecords;
      //  system.debug('&&&&&&&&&&&'+TargetTable_inst);
        return TargetTable_inst;
    }

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> prepareString(String budgetString){
        List<buildertek__Budget_Item__c> budgetItemsToInsert = (List<buildertek__Budget_Item__c>)System.JSON.deserialize(budgetString, List<buildertek__Budget_Item__c>.class);
      //  system.debug('budgetItemsToInsert ----------> ' + budgetItemsToInsert);
        //update budgetItemsToInsert;
        return budgetItemsToInsert;
    }

    @AuraEnabled
    public static void saveUpdatedValues(List<buildertek__Budget_Item__c> budgetItemList){
        Map<String, buildertek__Budget_Item__c> budgetItemIdMap = new Map<String, buildertek__Budget_Item__c>();
       // system.debug('budgetItemList -----------> ' + budgetItemList);
        //for(buildertek__Budget_Item__c budItem : budgetItemList){
        budgetItemIdMap.putAll(budgetItemList);
        //}

      //  system.debug('budgetItemIdMap key ----------> ' + budgetItemIdMap.keyset());
      //  system.debug('budgetItemIdMap ----------> ' + budgetItemIdMap);
      //  system.debug('budgetItemIdMap ----------> ' + budgetItemIdMap.values());
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Trade_Type__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Contractor__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__UOM__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isUpdateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isUpdateable()){
            update budgetItemIdMap.values();
        }
    }

    /* mass Functionality start*/

    @AuraEnabled
    public static void massUpdateBudgetLineItem(string budgetLineRecords){
       // system.debug(budgetLineRecords);
        List<buildertek__Budget_Item__c> budgetitemRecs = (List<buildertek__Budget_Item__c>)System.JSON.deserialize(budgetLineRecords, List<buildertek__Budget_Item__c>.class);
       // system.debug(budgetitemRecs);
        if (budgetitemRecs.size() > 0){
            update budgetitemRecs;
        }
    }

    @AuraEnabled
    public static void massDuplicateBudgetLineItem(List<string> budgetLineRecords,List<string> recordid){
        List<String> budgetLineItemRecs = budgetLineRecords;

        String query = '';
        String SobjectApiName = 'buildertek__Budget_Item__c';
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

        query = 'select ' + strFields + ' from ' + SobjectApiName + ' where id in :budgetLineItemRecs';

        List<buildertek__Budget_Item__c> lstRecs;

        lstRecs = Database.query(query);


        List<String> budgetLineItemRecs1 = budgetLineRecords;

                String query1 = '';
                String SobjectApiName1 = 'buildertek__PO_Item_To_Budget_Item_Link__c';
                Map<String, Schema.SObjectType> schemaMap1 = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> fieldMap1 = schemaMap1.get(SobjectApiName1).getDescribe().fields.getMap();



                String strFields1 = '';

                for (String fieldName1 : fieldMap1.keyset()){
                    if (strFields1 == null || strFields1 == ''){
                        strFields1 = fieldName1;
                    } else{
                        strFields1 = strFields1 + ',' + fieldName1;
                    }
                }

               // system.debug('strfields1'+strFields1);

        query1 = 'select ' + strFields1 + ' from ' + SobjectApiName1 + ' where buildertek__Budget_Item__c in :budgetLineItemRecs1';

       // system.debug('Fields for child object'+query1);

        List<buildertek__PO_Item_To_Budget_Item_Link__c> lstRecs1;

        lstRecs1 = Database.query(query1);

       // system.debug('child records'+lstRecs1);

        Map<String,List<buildertek__PO_Item_To_Budget_Item_Link__c>> budgetToPoItemLinkMap = new Map<String,List<buildertek__PO_Item_To_Budget_Item_Link__c>>();
        for(buildertek__PO_Item_To_Budget_Item_Link__c PoitemLinkrec : lstRecs1){
            if(budgetToPoItemLinkMap.get(PoitemLinkrec.buildertek__Budget_Item__c)!=null){
                list<buildertek__PO_Item_To_Budget_Item_Link__c> onboardingList = budgetToPoItemLinkMap.get(PoitemLinkrec.buildertek__Budget_Item__c);
                onboardingList.add(PoitemLinkrec);
                budgetToPoItemLinkMap.put(PoitemLinkrec.buildertek__Budget_Item__c,onboardingList);
            }else{
                list<buildertek__PO_Item_To_Budget_Item_Link__c> onboardingrec = new list<buildertek__PO_Item_To_Budget_Item_Link__c>();
                onboardingrec.add(PoitemLinkrec);
                budgetToPoItemLinkMap.put(PoitemLinkrec.buildertek__Budget_Item__c,onboardingrec);
            }
        }

      //  system.debug(budgetToPoItemLinkMap);
        Map<String,Id> purchaseorderMap = new Map<String,Id>();
         list<buildertek__Budget_Item__c> PurchaseordersList = new list<buildertek__Budget_Item__c>();
        for(buildertek__Budget_Item__c purchaseRec : lstRecs){
           // system.debug('purchaseRec.buildertek__Tax__c-->'+purchaseRec.buildertek__Tax__c);
            buildertek__Budget_Item__c newpurchaseRec  = purchaseRec.clone(false, false, false, false);
            /*newpurchaseRec.buildertek__Budget__c = null;
            newpurchaseRec.buildertek__Status__c = 'Open';
            newpurchaseRec.buildertek__Project__c = currentProjectId;*/
            newpurchaseRec.buildertek__Old_Budget_Line__c = purchaseRec.id;
            //newpurchaseRec.buildertek__Tax__c = purchaseRec.buildertek__Tax__c;
            PurchaseordersList.add(newpurchaseRec);
            //system.debug('%%%%'+ newpurchaseRec.buildertek__Tax__c);
        }
        if(PurchaseordersList.size()>0){
          //  system.debug('PurchaseordersList.size()-->'+PurchaseordersList.size());
           //  system.debug('PurchaseordersList-->'+PurchaseordersList);
            insert PurchaseordersList;
        }


        for(buildertek__Budget_Item__c purchaseordernewRec :PurchaseordersList){
                purchaseorderMap.put(purchaseordernewRec.buildertek__Old_Budget_Line__c,purchaseordernewRec.id);
            }
            list<buildertek__PO_Item_To_Budget_Item_Link__c> purchaseorderitemlist = new list<buildertek__PO_Item_To_Budget_Item_Link__c>();
            for(buildertek__PO_Item_To_Budget_Item_Link__c oldpurchaseorderrec : lstRecs1){
                buildertek__PO_Item_To_Budget_Item_Link__c purchaseorderitemCopy = oldpurchaseorderrec.clone(false,true);
                if(purchaseorderMap.get(oldpurchaseorderrec.buildertek__Budget_Item__c)!=null){
                    purchaseorderitemCopy.buildertek__Budget_Item__c = purchaseorderMap.get(oldpurchaseorderrec.buildertek__Budget_Item__c);
                  //  system.debug(purchaseorderitemCopy.buildertek__Budget_Item__c);
                }
                purchaseorderitemlist.add(purchaseorderitemCopy);
            }
            if(purchaseorderitemlist.size()>0){
              //  system.debug('purchaseorderitemlist-->'+purchaseorderitemlist);
                insert purchaseorderitemlist;
               // system.debug('----working in budget dao');
            }



       // List<buildertek__Budget_Item__c> lstRecsClone = lstRecs.deepClone();
       // if (lstRecsClone.size() > 0){

            //insert lstRecsClone;



                    /* List<buildertek__PO_Item_To_Budget_Item_Link__c> lstRecsClone1 = lstRecs1.deepClone();
        if (lstRecsClone1.size() > 0){

        system.debug('childs after insert'+lstRecsClone1);
        insert lstRecsClone1;

        }*/



        //}






    }

    /* mass Functionality end*/
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
        public List<RecordsList> subRecordList;
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

    public class subRecordList{
        public Boolean isEditable;
        @AuraEnabled
        public String recordValue;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public Object originalValue;
        @AuraEnabled
        public Object iscurrencyValue ;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String referenceValue;
        public subRecordList(Boolean isEditable, String recordValue, String fieldName, Object originalValue,Object iscurrencyValue, String fieldType, String referenceValue){
            this.isEditable = isEditable;
            this.recordValue = recordValue;
            this.fieldName = fieldName;
            this.originalValue = originalValue;
            this.iscurrencyValue = iscurrencyValue ;
            this.fieldType = fieldType;
            this.referenceValue = referenceValue;
        }
    }

    public class EachRecord{
        @AuraEnabled
        public Integer recordCount;
        @AuraEnabled
        public List<RecordsList> recordList;
        @AuraEnabled
        public List<object> recordValue;  //Record
        @AuraEnabled
        public Id recordId; //Record Id used for Firing Events
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public Id groupId;
        @AuraEnabled
        public String groupName;
        @AuraEnabled
        public Id vendorId;
        @AuraEnabled
        public String vendorName;
          @AuraEnabled
        public Id costId;
        @AuraEnabled
        public String costName;
        @AuraEnabled
        public Id subGroupId;
        @AuraEnabled
        public String subGroupName;
    }

    public class TargetTable{
        @AuraEnabled
        public List<sObject> records; //actual list of records
        @AuraEnabled
        public List<EachRecord> ListOfEachRecord;

        //all data will be saved as array of array values
    }

    public class wrapperClass{
        @AuraEnabled
        public String vendorId{ get; set; }

        @AuraEnabled
        public String vendorName{ get; set; }

         @AuraEnabled
        public String costId{ get; set; }

        @AuraEnabled
        public String costName{ get; set; }

        @AuraEnabled
        public String groupName{ get; set; }

        @AuraEnabled
        public Decimal totalValue{ get; set; }

        @AuraEnabled
        public String fieldType{ get; set; }

        @AuraEnabled
        public String fieldLabel{ get; set; }

        @AuraEnabled
        public String groupID{ get; set; }

        public wrapperClass(String groupName, Decimal totalValue, String fieldType, String fieldLabel,String groupID,string vendorName, string vendorId ){
            this.vendorName = vendorName;
            this.vendorId = vendorId;
            this.groupName = groupName;
            //this.totalValue = totalValue;
            this.totalValue = totalValue != null  ? totalValue : 0.00; //sai
            this.fieldType = fieldType;
            this.fieldLabel = fieldLabel;
            this.groupID = groupID;
        }
    }

    public Class BudgetClass{
        @AuraEnabled
        public String Id{ get; set; }

        @AuraEnabled
        public String values{ get; set; }
    }

    public class budgetDetails{
        @AuraEnabled
        public List<buildertek__Budget_Line_Group__c> groups{ get; set; }

        @AuraEnabled
        public List<buildertek__Budget_Line_Sub_Group__c> subGroups{ get; set; }

        @AuraEnabled
        public List<String> headerFields{ get; set; }

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns{ get; set; }

        @AuraEnabled
        public string formulaFields{ get; set; }

        public budgetDetails(){
            groups = new List<buildertek__Budget_Line_Group__c>();
            subGroups = new List<buildertek__Budget_Line_Sub_Group__c>();
            headerFields = new List<String>();
            columns = new List<BT_Lightning_Utils.dataTableFields>();
        }
    }

    public class InnerClass{
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String fieldValue;
        @AuraEnabled
        public String fieldType;

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

    public class finalWrapperClass{
        @AuraEnabled
        public TargetTable tarTable;
        @AuraEnabled
        public List<wrapperClass> wrapperList;
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;

        @AuraEnabled
        public List<buildertek__Budget_Line_Group__c> groups{ get; set; }

        @AuraEnabled
        public List<buildertek__Budget_Line_Sub_Group__c> subGroups{ get; set; }

        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer page{ get; set; }

        @AuraEnabled
        public Integer total{ get; set; }

        @AuraEnabled
        public String formulaFields{ get; set; }
    }

    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> fetchAccount(String searchKeyWord){
        String searchKey = searchKeyWord + '%';
        List<buildertek__Budget_Item__c> returnList = new List<buildertek__Budget_Item__c>();
        List<buildertek__Budget_Item__c> lstOfAccount = [select id, Name, buildertek__Group__c, buildertek__Group__r.name, buildertek__Sales_Price__c, buildertek__Unit_Price__c, buildertek__Quantity__c
                                                         from buildertek__Budget_Item__c
                                                         where Name like :searchKey OR buildertek__Group__r.name like :searchKey
                                                         ORDER BY Name ASC
                                                         LIMIT 500];

        for (buildertek__Budget_Item__c acc : lstOfAccount){
            returnList.add(acc);
        }
        return returnList;
    }

    @AuraEnabled
    public static buildertek__Budget__c getBudgetDetails(String budgetRecordId){
        /*String SobjectApiName = 'buildertek__Budget__c';
String query = '';
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
query = 'select buildertek__Project__r.Name, CreatedBy.Name,buildertek__Project__r.Id, ' + strFields + ' from ' + SobjectApiName + ' where id = :budgetRecordId';
buildertek__Budget__c budgetCopy = Database.query(query);*/

        buildertek__Budget__c budget = [SELECT id, Name, buildertek__Approved_CO__c,buildertek__Budget_Cost_To_Complete__c, buildertek__Budget_Number__c, buildertek__Committed_Costs__c, buildertek__Estimated_Cost_To_Complete__c,
                                        buildertek__Estimated_Gross_Profit__c, buildertek__Forecast_To_Complete__c, buildertek__Gross_Profit__c, buildertek__Original_Budget__c, buildertek__Profit_Loss__c, buildertek__Project_Sales_Price__c,
                                        buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.Id, buildertek__Revised_Budgets__c, buildertek__Total_Costs__c,buildertek__Type__c, SystemModstamp,
                                        CreatedById, CreatedDate, CreatedBy.Name,LastModifiedById, LastModifiedDate, LastModifiedBy.Name FROM buildertek__Budget__c WHERE id =: budgetRecordId ORDER BY Name ASC];
      //  system.debug(budget);
        return budget;

    }

    @AuraEnabled
    public static void searchbudgetFilter(List<Map<String,Object>> recordList){
     //   system.debug(recordList);
        List<object> records = recordList;
      //  system.debug(records);
        //for(object hierarchy : )
    }
    @AuraEnabled
    public static BudgetDataTableWrapper getBudgetData(Integer pageNumber, Integer pageSize, string RecId){
        buildertek__Budget__c RFQRec = [SELECT Id, Name, buildertek__Project__c
                                        FROM buildertek__Budget__c
                                        where Id = :RecId ORDER BY Name ASC];
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = [SELECT COUNT()
                                FROM buildertek__Purchase_Order__c
                                where buildertek__Project__c = :RFQRec.buildertek__Project__c AND buildertek__PO_Type__c = 'Master'];
        Integer recordEnd = pageSize * pageNumber;
        //Instance of Contact DataTable Wrapper Class
        BudgetDataTableWrapper objDT = new BudgetDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.selectedPurchaseOrder = false;
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,'+
                            'buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c'+
                            ' FROM buildertek__Purchase_Order__c'+
                            ' where buildertek__Budget__c = null AND buildertek__Budget_Line__c =null AND buildertek__Project__c =\'' +RFQRec.buildertek__Project__c+'\' ORDER BY Name ASC LIMIT :pageSize OFFSET :offset';
               objDT.recordList = Database.query(rfqrecords);
            }else{
                // objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,
                //             buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c
                //             FROM buildertek__Purchase_Order__c
                //             where buildertek__Project__c = :RFQRec.buildertek__Project__c
                //             ORDER BY Name
                //             LIMIT :pageSize
                //             OFFSET :offset];

                objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,
                                    buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c
                                    FROM buildertek__Purchase_Order__c
                                    where buildertek__Budget__c = null AND buildertek__Budget_Line__c =null AND buildertek__Project__c = :RFQRec.buildertek__Project__c
                                    ORDER BY Name
                                    LIMIT :pageSize
                                    OFFSET :offset];
            }
        /*objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,
                            buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c
                            FROM buildertek__Purchase_Order__c
                            where buildertek__Project__c = :RFQRec.buildertek__Project__c
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];*/
        return objDT;
    }

    @AuraEnabled
    public static BudgetDataTableWrapperClone getTimeCardData(Integer pageNumber, Integer pageSize, string RecId){
        buildertek__Budget__c RFQRec = [SELECT Id, Name, buildertek__Project__c
                                        FROM buildertek__Budget__c
                                        where Id = :RecId
                                        ORDER BY Name ASC];
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = [SELECT COUNT()
                                FROM buildertek__Time_Cards__c
                                where buildertek__Project__c = :RFQRec.buildertek__Project__c];
        Integer recordEnd = pageSize * pageNumber;
        //Instance of Contact DataTable Wrapper Class
        BudgetDataTableWrapperClone objDT = new BudgetDataTableWrapperClone();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.selectedTimeCards = false;
        System.debug('pageSize -> '+pageSize);
        System.debug('offset -> '+offset);
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'SELECT Id, Name,buildertek__Resource__c, buildertek__Resource__r.Name ,buildertek__Project__c, buildertek__Project__r.Name,buildertek__Description__c, buildertek__Budget_Line__c, buildertek__Budget__c, '+
                            'buildertek__Daily_Expense__c'+
                            ' FROM buildertek__Time_Cards__c'+
                            ' where buildertek__Project__c =\'' +RFQRec.buildertek__Project__c+'\' and buildertek__Budget_Line__c = null and buildertek__Budget__c = null ORDER BY Name LIMIT :pageSize OFFSET :offset';
               objDT.recordList = Database.query(rfqrecords);
            }else{
                objDT.recordList = [SELECT Id, Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Project__c, buildertek__Budget__c, buildertek__Project__r.Name,buildertek__Description__c, buildertek__Budget_Line__c, buildertek__Daily_Expense__c FROM buildertek__Time_Cards__c where buildertek__Project__c = :RFQRec.buildertek__Project__c and buildertek__Budget_Line__c = null and buildertek__Budget__c = null
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];
            }
        /*objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,
                            buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c
                            FROM buildertek__Purchase_Order__c
                            where buildertek__Project__c = :RFQRec.buildertek__Project__c
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];*/
        return objDT;
    }
    @AuraEnabled
    public static InvoiceWrapper getInvioceData(Integer pageNumber, Integer pageSize, string RecId){
        buildertek__Budget__c RFQRec = [SELECT Id, Name, buildertek__Project__c
                                        FROM buildertek__Budget__c
                                        where Id = :RecId
                                        ORDER BY Name ASC];
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = [SELECT COUNT()
                                FROM buildertek__Account_Payable_Item_Clone__c
                                where buildertek__Project__c = :RFQRec.buildertek__Project__c];
        Integer recordEnd = pageSize * pageNumber;
        //Instance of Contact DataTable Wrapper Class
        InvoiceWrapper objDT = new InvoiceWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.selectedTimeCards = false;
        System.debug('pageSize -> '+pageSize);
        System.debug('offset -> '+offset);
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'SELECT Id, Name, buildertek__Project__c, buildertek__Budget__c, buildertek__Project__r.Name,buildertek__Description__c, buildertek__Budget_Line__c, buildertek__Total_Amount__c '+
                            ' FROM buildertek__Account_Payable_Clone__c'+
                            ' where buildertek__Project__c =\'' +RFQRec.buildertek__Project__c+'\' and buildertek__Budget_Line__c = null and buildertek__Budget__c = null ORDER BY Name LIMIT :pageSize OFFSET :offset';
               objDT.recordList = Database.query(rfqrecords);
            }else{
                objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Budget__c, buildertek__Project__r.Name,buildertek__Description__c, buildertek__Budget_Line__c, buildertek__Total_Amount__c FROM buildertek__Account_Payable_Clone__c WHERE buildertek__Project__c =: RFQRec.buildertek__Project__c and buildertek__Budget_Line__c = null and buildertek__Budget__c = null
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];
            }
        /*objDT.recordList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name,buildertek__PO_Type__c,buildertek__Description__c,
                            buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__PO_Total__c
                            FROM buildertek__Purchase_Order__c
                            where buildertek__Project__c = :RFQRec.buildertek__Project__c
                            ORDER BY Name
                            LIMIT :pageSize
                            OFFSET :offset];*/
        return objDT;
    }

    @AuraEnabled
    public static string updateLaborPrice(String recordId, String budgeLineIds){
        List<String> strList = budgeLineIds.split(',');
        List<String> strRecordId = recordId.split(',');
        System.debug(strRecordId);
        System.debug('strRecordId');


        String response;
        if (strRecordId.size() > 0) {
            try {
                List<buildertek__Time_Cards__c> timeCardList =[SELECT Id, Name, buildertek__Daily_Expense__c, buildertek__Budget__c, buildertek__Budget_Line__c FROM buildertek__Time_Cards__c WHERE Id IN:strRecordId];
                List<buildertek__Budget_Item__c> budgetItemList =[SELECT Id, Name, buildertek__Labor__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id IN :strList];

                List<buildertek__Time_Cards__c> updateTimeCard = new List<buildertek__Time_Cards__c>();
                Decimal timeCardValue=0;


                if (budgetItemList.size() > 0) {

                    for(buildertek__Time_Cards__c timeCard : timeCardList){
                        timeCard.buildertek__Budget__c = budgetItemList[0].buildertek__Budget__c;
                        timeCard.buildertek__Budget_Line__c = budgetItemList[0].Id;
                        timeCardValue+=timeCard.buildertek__Daily_Expense__c;
                        updateTimeCard.add(timeCard);

                    }
                    System.debug(timeCardValue);
                    update updateTimeCard;
                    if(budgetItemList[0].buildertek__Labor__c != null){
                        budgetItemList[0].buildertek__Labor__c += timeCardValue;


                    }else{
                        budgetItemList[0].buildertek__Labor__c = timeCardValue;

                    }

                    update budgetItemList[0];




                }



                // if (budgetItemList.size() > 0) {
                //     timeCard.buildertek__Budget__c = budgetItemList[0].buildertek__Budget__c;
                //     timeCard.buildertek__Budget_Line__c = budgetItemList[0].Id;
                //     update timeCard;
                //     for (buildertek__Budget_Item__c bItem : budgetItemList) {
                //         bItem.buildertek__Labor__c = timeCard.buildertek__Daily_Expense__c;
                //         updateBudgetList.add(bItem);
                //     }
                //     update updateBudgetList;
                // }
                response = 'Success';
            } catch (Exception e) {
                System.debug(e.getMessage()+ e.getLineNumber());

                throw new AuraHandledException(e.getMessage());
                response = 'Error';
            }
        }else{
            response = 'null';
        }
        return response;
    }

    @AuraEnabled
    public static string updateInvoicePrice(String recordId, String budgeLineIds){
        List<String> strList = budgeLineIds.split(',');
        List<String> strRecordId = recordId.split(',');

        String response;
        if (strRecordId.size() > 0) {
            try {
                List<buildertek__Account_Payable_Clone__c> invoiceAPList =  [SELECT Id, Name, buildertek__Total_Amount__c, buildertek__Budget__c, buildertek__Budget_Line__c FROM buildertek__Account_Payable_Clone__c WHERE Id =:strRecordId];
                buildertek__Budget_Item__c budgetItem = [SELECT Id, Name, buildertek__Invoice_total__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id IN :strList LIMIT 1];
                List<buildertek__Account_Payable_Clone__c> updateInvoiceAPList = new  List<buildertek__Account_Payable_Clone__c>();
                Decimal Value=0;

                if (strList.size() > 0) {
                    for(buildertek__Account_Payable_Clone__c invoiceAp: invoiceAPList){
                        invoiceAP.buildertek__Budget__c = budgetItem.buildertek__Budget__c;
                        invoiceAP.buildertek__Budget_Line__c = budgetItem.Id;
                        Value+=invoiceAP.buildertek__Total_Amount__c;

                        updateInvoiceAPList.add(invoiceAP);


                    }
                    update updateInvoiceAPList;
                    // budgetItem = [SELECT Id, Name, buildertek__Invoice_total__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id IN :strList LIMIT 1];

                    // invoiceAP.buildertek__Budget__c = budgetItem.buildertek__Budget__c;
                    // invoiceAP.buildertek__Budget_Line__c = budgetItem.Id;
                    // update invoiceAP;

                    if(budgetItem.buildertek__Invoice_total__c != null){
                        budgetItem.buildertek__Invoice_total__c += Value;

                    }else{

                        budgetItem.buildertek__Invoice_total__c = Value;
                    }


                    update budgetItem;
                }

                response = 'Success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                response = 'Error';
            }
        }else{
            response = 'null';
        }
        return response;
    }

    public class BudgetDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer pageNumber{ get; set; }

        @AuraEnabled
        public Integer totalRecords{ get; set; }

        @AuraEnabled
        public Integer recordStart{ get; set; }

        @AuraEnabled
        public Integer recordEnd{ get; set; }
        @AuraEnabled
        Public Boolean selectedPurchaseOrder {get;set;}
        @AuraEnabled
        public List<buildertek__Purchase_Order__c> recordList{ get; set; }
    }
    public class BudgetDataTableWrapperClone{
        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer pageNumber{ get; set; }

        @AuraEnabled
        public Integer totalRecords{ get; set; }

        @AuraEnabled
        public Integer recordStart{ get; set; }

        @AuraEnabled
        public Integer recordEnd{ get; set; }
        @AuraEnabled
        Public Boolean selectedTimeCards {get;set;}
        @AuraEnabled
        public List<buildertek__Time_Cards__c> recordList{ get; set; }
    }
    public class InvoiceWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer pageNumber{ get; set; }

        @AuraEnabled
        public Integer totalRecords{ get; set; }

        @AuraEnabled
        public Integer recordStart{ get; set; }

        @AuraEnabled
        public Integer recordEnd{ get; set; }
        @AuraEnabled
        Public Boolean selectedTimeCards {get;set;}
        @AuraEnabled
        public List<buildertek__Account_Payable_Clone__c> recordList{ get; set; }
    }
    @AuraEnabled
    public static buildertek__Budget__c getbudget(String recordId){
        buildertek__Budget__c quoterecord = [Select Id, Name, buildertek__Original_Budget__c, buildertek__Total_Costs__c, buildertek__Total_Sales_Price__c, buildertek__Gross_Profit__c, buildertek__Estimated_Gross_Profit__c, buildertek__Estimated_Gross_Profit_Percent__c from buildertek__Budget__c  where Id =: recordId ORDER BY Name ASC LIMIT 1];
        return quoterecord;
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
    public static string  getCOCustomerRecordType(){
        string CustomerRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        return CustomerRecordTypeId;
    }

         @AuraEnabled
    public static string  getInvoiceCustomerRecordType(){
        string CustomerRecordTypeId = Schema.SObjectType.buildertek__Account_Payable__c.getRecordTypeInfosByName().get('Existing Payable').getRecordTypeId();
        return CustomerRecordTypeId;
    }
    @AuraEnabled
    public static String getRecords(String parentRecordId, String fieldNameJson,Integer pageNumber, Integer pageSize){

        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            if(String.isNotBlank(parentRecordId)){
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Budget_Item__c';
                query += ' WHERE buildertek__Budget__c = : parentRecordId ORDER BY Name ASC NULLS LAST';
                query += ' LIMIT : pageSize OFFSET : offset';
                for (sObject s : Database.query(query)){
                    lstResult.add(s);
                }
                if (lstResult.size() > 0){
                    result = JSON.serialize(lstResult);
                    return result;
                }
            }
        } catch (Exception e){
            System.debug('Error' + e.getMessage());
        }
        return null;
    }
    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, List<String> deleteLineitems){
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Budget_Item__c> items = (List<buildertek__Budget_Item__c>)JSON.deserialize(updatedRecords, List<buildertek__Budget_Item__c>.class);
              //  system.debug('items'+items);
                for (buildertek__Budget_Item__c item : items){
                    if(item.Id == null){
                        item.buildertek__Budget__c= recordId;
                    }
                }
                if (items.size() > 0){
                    upsert items;
                }
                List<buildertek__Budget_Item__c> deleteList = [SELECT Id from buildertek__Budget_Item__c WHERE Id IN: deleteLineitems];
               // system.debug('delete==>'+deleteList);
                if(deleteList.Size()>0){
                    delete deleteList;
                }
                return getRecords(recordId, fieldSetName, pageNumber, pageSize);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }


    @AuraEnabled
    public static String updateMultipleBudgetLine(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, List<String> deleteLineitems){
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Budget_Item__c> budgetItemList = new List<buildertek__Budget_Item__c>();
                List<multipleBudgetLinesClass> items = (List<multipleBudgetLinesClass>)JSON.deserialize(updatedRecords, List<multipleBudgetLinesClass>.class);
                if(items.Size()>0){
               system.debug('items to check '+items);
                List<buildertek__Budget_Line_Group__c> budgetGroup = [select Id, Name
                                                                            from buildertek__Budget_Line_Group__c
                                                                            where Name = 'No Grouping'
                                                                            ORDER BY Name ASC];
                    Id nogroupId;

                     Map<Id,product2> prdctrec = new Map<Id,product2>([SELECT id, Name, buildertek__Cost_Code__c
                                            FROM product2]);

                    for(multipleBudgetLinesClass listItem : items){
                        buildertek__Budget_Item__c budgetRec = new buildertek__Budget_Item__c();
                        budgetRec  = listItem.newBudgetLine;

                        if (budgetRec.buildertek__Group__c == null){

                            if (budgetGroup.size() > 0){
                                budgetRec.buildertek__Group__c = budgetGroup[0].Id;
                            } else{
                                if(nogroupId == null){
                                    buildertek__Budget_Line_Group__c budGroup = new buildertek__Budget_Line_Group__c();
                                    budGroup.Name = 'No Grouping';
                                    insert budGroup;
                                    nogroupId = budGroup.Id;
                                }else{
                                    budgetRec.buildertek__Group__c = nogroupId ;
                                }
                            }
                        }

                        if (budgetRec.buildertek__Product__c != null){
                                                budgetRec.buildertek__Cost_Code__c = prdctrec.get(budgetRec.buildertek__Product__c).buildertek__Cost_Code__c;
                        }

                        buildertek__Budget_Item__c BudgetLineToInsert = new buildertek__Budget_Item__c();

                        BudgetLineToInsert.buildertek__Product__c = budgetRec.buildertek__Product__c;
                        //BudgetLineToInsert.buildertek__Product__c = productId;
                        System.debug('budgetRec.Name '+budgetRec.Name);
                        if (budgetRec.Name.length() > 79){
                            BudgetLineToInsert.Name = budgetRec.Name.left(78);
                            BudgetLineToInsert.buildertek__Description__c = budgetRec.Name;
                        } else{
                            BudgetLineToInsert.Name = budgetRec.Name;
                        }
                        BudgetLineToInsert.buildertek__Budget__c = recordId;
                        BudgetLineToInsert.buildertek__Budget_Line_Group__c = budgetRec.buildertek__Budget_Line_Group__c;
                        BudgetLineToInsert.buildertek__UOM__c = listItem.UOMvalues;

                        if(listItem.Vendor != null){
                            BudgetLineToInsert.buildertek__Contractor__c = listItem.Vendor.Id;
                        }

                        // BudgetLineToInsert.buildertek__Trade_Type__c = tradeType;
                        BudgetLineToInsert.buildertek__Unit_Price__c = budgetRec.buildertek__Unit_Price__c;
                        BudgetLineToInsert.buildertek__Sales_Price__c = budgetRec.buildertek__Sales_Price__c;
                        BudgetLineToInsert.buildertek__Quantity__c = budgetRec.buildertek__Quantity__c;
                        //BudgetLineToInsert.buildertek__Budget__c = budgetRec.buildertek__Budget__c;
                        BudgetLineToInsert.buildertek__Cost_Code__c = budgetRec.buildertek__Cost_Code__c;
                        BudgetLineToInsert.buildertek__Group__c = budgetRec.buildertek__Group__c;
                        BudgetLineToInsert.buildertek__Sub_Grouping__c = budgetRec.buildertek__Sub_Grouping__c;
                        BudgetLineToInsert.buildertek__Discount__c = budgetRec.buildertek__Discount__c;
                        BudgetLineToInsert.buildertek__Notes__c=budgetRec.buildertek__Notes__c;
                        System.debug('---Budget Line Items recordId 321--> ' + BudgetLineToInsert);
                        budgetItemList.add(BudgetLineToInsert);

                    }

                 //  system.debug('budgetItemList --->'+ budgetItemList);
                   if(budgetItemList.Size()>0){
                       insert budgetItemList;
                   }
                }
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static List<COLineItemsClass> getProduct(String coItems){
        List<buildertek__Budget_Item__c> changeOrderList = (List<buildertek__Budget_Item__c>)JSON.deserialize(coItems, List<buildertek__Budget_Item__c>.class);
      //  system.debug('changeOrderList -----------> ' + changeOrderList);
        List<COLineItemsClass> COItemsClassList = new List<COLineItemsClass>();
        Integer count = 0;
        for (buildertek__Budget_Item__c CO : changeOrderList){
            COLineItemsClass COItemsClass = new COLineItemsClass(CO, true, count);
            count++;
            COItemsClassList.add(COItemsClass);
        }
        return COItemsClassList;
    }

    @AuraEnabled
    public static List<buildertek__Change_Order__c> getCoData(string RecId){
        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];

        List<buildertek__Change_Order__c> changeOrderList = new List<buildertek__Change_Order__c>();

        changeOrderList = [SELECT Id, Name, buildertek__Project__c, buildertek__Description__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__CO_Number__c, buildertek__Total_Costs__c,
                            buildertek__Total_Amount_Tax__c, buildertek__Total_Amount__c FROM buildertek__Change_Order__c
                            WHERE buildertek__Project__c =: budgetRec.buildertek__Project__c AND (buildertek__Status__c = 'Customer Approved' OR buildertek__Status__c = 'Approved' OR buildertek__Status__c = 'Customer Accepted') AND buildertek__Budget__c = null ORDER BY Name ASC];

        return changeOrderList;
    }

    @AuraEnabled
    public static List<buildertek__Expense__c> getExpenseData(string RecId){
        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];

        List<buildertek__Expense__c> ExpenseList = new List<buildertek__Expense__c>();
        ExpenseList = [SELECT Id, Name, buildertek__Project__c, buildertek__Description__c,buildertek__Budget_Line__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Budget__c,
                            buildertek__Total_Expense__c FROM buildertek__Expense__c
                            WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: budgetRec.buildertek__Project__c ORDER BY Name DESC];
        System.debug('ExpenseList======>>>>>>'+ExpenseList);

        return ExpenseList;
    }

    @AuraEnabled
    public static String addCoToBudget(String budgeLineIds, string selectedCO, string RecId){
        List<String> strList = budgeLineIds.split(',');

        buildertek__Change_Order__c co = [SELECT Id, Name, buildertek__Total_Amount_Tax__c, buildertek__Total_Amount__c	, buildertek__Total_Costs__c FROM buildertek__Change_Order__c WHERE Id =: selectedCO];
        List<buildertek__Change_Order_Item__c> coLineList = [SELECT Id, Name FROM buildertek__Change_Order_Item__c WHERE buildertek__Change_Order__c =: selectedCO];

        Set<Id> coLineIds = new Set<Id>();
        for (buildertek__Change_Order_Item__c coLine : coLineList) {
            coLineIds.add(coLine.Id);
        }

        if (coLineIds.size() > 0) {
            String budgetGroupId;
            List<buildertek__Budget_Line_Group__c> budgetLineGroupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Change Order' ORDER BY Name ASC LIMIT 1];
            if (budgetLineGroupList.size() > 0) {
                budgetGroupId = budgetLineGroupList[0].Id;
            } else{
                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                budgetGroup.Name = 'Change Order';
                insert budgetGroup;

                budgetGroupId = budgetGroup.Id;
            }
            List<buildertek__Budget_Item__c> budgetItemList = [SELECT Id, Name,buildertek__Sales_Price__c, buildertek__Unit_Price__c, buildertek__Total_Costs__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id IN :strList ORDER BY Name ASC];

            List<buildertek__CO_Item_To_Budget_Item_Link__c> BudgetCoLinkList = new List<buildertek__CO_Item_To_Budget_Item_Link__c>();

            BudgetCoLinkList = [SELECT Id, Name, buildertek__Budget_Item__c, buildertek__CO_Item__c FROM buildertek__CO_Item_To_Budget_Item_Link__c
                                WHERE buildertek__Budget_Item__c IN: strList AND buildertek__CO_Item__c IN: coLineIds ORDER BY Name ASC];

            List<CO_Item_To_Budget_Item_Link__c> COItemToBudgetItemLinks = new List<CO_Item_To_Budget_Item_Link__c>();
            for (buildertek__Budget_Item__c budgetItem : budgetItemList) {
                for (buildertek__Change_Order_Item__c coLine : coLineList) {
                    Boolean recordAvail = false;
                    for (buildertek__CO_Item_To_Budget_Item_Link__c BudgetCoLink : BudgetCoLinkList) {
                        if (BudgetCoLink.buildertek__Budget_Item__c == budgetItem.Id && BudgetCoLink.buildertek__CO_Item__c == coLine.Id) {
                            recordAvail = true;
                        }
                    }
                    if (!recordAvail) {
                        buildertek__CO_Item_To_Budget_Item_Link__c COItemToBudgetItemLink = new buildertek__CO_Item_To_Budget_Item_Link__c();
                        COItemToBudgetItemLink.CO_Item__c = coLine.Id;
                        COItemToBudgetItemLink.Budget_Item__c = budgetItem.Id;
                        COItemToBudgetItemLinks.add(COItemToBudgetItemLink);

                        // coLine.buildertek__Budget_Item__c=budgetItem.Id;

                    }
                }
                System.debug('buildertek__Unit_Price__c in quoteDAO '+budgetItem.buildertek__Unit_Price__c);
                System.debug('co.buildertek__Total_Costs__c in quoteDAO '+co.buildertek__Total_Costs__c);
                // budgetItem.buildertek__Unit_Price__c=budgetItem.buildertek__Unit_Price__c + co.buildertek__Total_Costs__c;
                System.debug('after updating buildertek__Unit_Price__c in quoteDAO '+budgetItem.buildertek__Unit_Price__c);
            }
            // update budgetItemList;
            insert COItemToBudgetItemLinks;

            co.buildertek__Budget__c = RecId;
            co.buildertek__Budget_Line__c = strList[0];
            update co;

            // if(coLineList.size() > 0){
            //     update coLineList;
            // }

            ChangeOrderDAO.RollUpChangeOrderItemAmount(coLineIds);
            return 'Success';
        } else{
            return 'No Co Line Found On Co.';
        }

    }

    @AuraEnabled
    public static String addChangeOrdertoBudgetonly(List<Change_Order__c> selectedCO, String recId){
        System.debug('selectedCO' + selectedCO);
        System.debug('recId' + recId);

        List<Change_Order__c> coList = [SELECT Id, Name, Total_Amount_Tax__c, Total_Amount__c	, Total_Costs__c FROM Change_Order__c WHERE Id IN:selectedCO ORDER BY Name ASC];
        for(Change_Order__c co : coList){
            co.buildertek__Budget__c = recId;
        }
        update coList;

        return 'Success';
    }

    @AuraEnabled
    public static String addChangeOrdertoBudget(List<String> selectedRecords, List<Change_Order__c> selectedCO, String recId){
        System.debug('selectedRecords' + selectedRecords);
        System.debug('selectedCO' + selectedCO);
        System.debug('recId' + recId);
        
        List<Change_Order__c> coList = [SELECT Id, Name, Total_Amount_Tax__c, Total_Amount__c	, Total_Costs__c FROM Change_Order__c WHERE Id IN:selectedCO ORDER BY Name ASC];
        for(Change_Order__c co : coList){
            co.buildertek__Budget__c = recId;
            co.buildertek__Budget_Line__c = selectedRecords[0];
        }
        update coList;
        
        return 'Success';

        // List<String> strList = budgeLineIds.split(',');

        // buildertek__Change_Order__c co = [SELECT Id, Name, buildertek__Total_Amount_Tax__c, buildertek__Total_Amount__c	, buildertek__Total_Costs__c FROM buildertek__Change_Order__c WHERE Id IN:selectedCO];
        // List<buildertek__Change_Order_Item__c> coLineList = [SELECT Id, Name FROM buildertek__Change_Order_Item__c WHERE buildertek__Change_Order__c IN: selectedCO];

        // Set<Id> coLineIds = new Set<Id>();
        // for (buildertek__Change_Order_Item__c coLine : coLineList) {
        //     coLineIds.add(coLine.Id);
        // }

        // if (coLineIds.size() > 0) {
        //     String budgetGroupId;
        //     List<buildertek__Budget_Line_Group__c> budgetLineGroupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Change Order' LIMIT 1];
        //     if (budgetLineGroupList.size() > 0) {
        //         budgetGroupId = budgetLineGroupList[0].Id;
        //     } else{
        //         buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
        //         budgetGroup.Name = 'Change Order';
        //         insert budgetGroup;

        //         budgetGroupId = budgetGroup.Id;
        //     }
        //     List<buildertek__Budget_Item__c> budgetItemList = [SELECT Id, Name,buildertek__Sales_Price__c, buildertek__Unit_Price__c, buildertek__Total_Costs__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id IN :selectedRecords];

        //     List<buildertek__CO_Item_To_Budget_Item_Link__c> BudgetCoLinkList = new List<buildertek__CO_Item_To_Budget_Item_Link__c>();

        //     BudgetCoLinkList = [SELECT Id, Name, buildertek__Budget_Item__c, buildertek__CO_Item__c FROM buildertek__CO_Item_To_Budget_Item_Link__c
        //                         WHERE buildertek__Budget_Item__c IN: selectedRecords AND buildertek__CO_Item__c IN: coLineIds];

        //     List<CO_Item_To_Budget_Item_Link__c> COItemToBudgetItemLinks = new List<CO_Item_To_Budget_Item_Link__c>();
        //     for (buildertek__Budget_Item__c budgetItem : budgetItemList) {
        //         for (buildertek__Change_Order_Item__c coLine : coLineList) {
        //             Boolean recordAvail = false;
        //             for (buildertek__CO_Item_To_Budget_Item_Link__c BudgetCoLink : BudgetCoLinkList) {
        //                 if (BudgetCoLink.buildertek__Budget_Item__c == budgetItem.Id && BudgetCoLink.buildertek__CO_Item__c == coLine.Id) {
        //                     recordAvail = true;
        //                 }
        //             }
        //             if (!recordAvail) {
        //                 buildertek__CO_Item_To_Budget_Item_Link__c COItemToBudgetItemLink = new buildertek__CO_Item_To_Budget_Item_Link__c();
        //                 COItemToBudgetItemLink.CO_Item__c = coLine.Id;
        //                 COItemToBudgetItemLink.Budget_Item__c = budgetItem.Id;
        //                 COItemToBudgetItemLinks.add(COItemToBudgetItemLink);

        //                 // coLine.buildertek__Budget_Item__c=budgetItem.Id;

        //             }
        //         }
        //         System.debug('buildertek__Unit_Price__c in quoteDAO '+budgetItem.buildertek__Unit_Price__c);
        //         System.debug('co.buildertek__Total_Costs__c in quoteDAO '+co.buildertek__Total_Costs__c);
        //         // budgetItem.buildertek__Unit_Price__c=budgetItem.buildertek__Unit_Price__c + co.buildertek__Total_Costs__c;
        //         System.debug('after updating buildertek__Unit_Price__c in quoteDAO '+budgetItem.buildertek__Unit_Price__c);
        //     }
        //     // update budgetItemList;
        //     insert COItemToBudgetItemLinks;

        //     co.buildertek__Budget__c = RecId;
        //     co.buildertek__Budget_Line__c = selectedRecords[0];
        //     update co;

        //     // if(coLineList.size() > 0){
        //     //     update coLineList;
        //     // }

        //     ChangeOrderDAO.RollUpChangeOrderItemAmount(coLineIds);

    }

    @AuraEnabled
    public static void addExpenseToBudget(String budgeLineIds, List<buildertek__Expense__c> selectedExpenses){
        List<String> strList = budgeLineIds.split(',');

        List<buildertek__Budget_Item__c> budgetItemList = [SELECT Id, Name, buildertek__Additional_Costs__c, buildertek__Budget__c, buildertek__Budget__r.buildertek__Project__c FROM buildertek__Budget_Item__c WHERE Id IN :strList ORDER BY Name ASC];

        for (buildertek__Expense__c exp : selectedExpenses) {
            exp.buildertek__Budget_Line__c = budgetItemList[0].Id;
            exp.buildertek__Budget__c = budgetItemList[0].buildertek__Budget__c;
            exp.buildertek__Project__c = budgetItemList[0].buildertek__Budget__r.buildertek__Project__c;
        }

        update selectedExpenses;

    }

    @AuraEnabled
    public static void CreateLineAddExpense(List<buildertek__Expense__c> selectedExpenses, string RecId){

        BudgetDAO.isCreateExpense = true;

        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];

        List<buildertek__Budget_Line_Group__c> budgetLineGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Expense' ORDER BY Name ASC limit 1];

        String groupId = '';

        if (budgetLineGroup.size() > 0) {
            groupId = budgetLineGroup[0].Id;
        } else {
            buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
            budgetGroup.Name = 'Expense';
            insert budgetGroup;

            groupId = budgetGroup.Id;
        }

        Map<Id, buildertek__Budget_Item__c> budgetItemMap = new Map<Id, buildertek__Budget_Item__c>();
        for (buildertek__Expense__c exp : selectedExpenses) {
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Name = exp.buildertek__Description__c;
            budgetItem.buildertek__Budget__c = RecId;
            budgetItem.buildertek__Group__c = groupId;
            budgetItemMap.put(exp.Id, budgetItem);
        }
        insert budgetItemMap.values();


        for (buildertek__Expense__c exp : selectedExpenses) {
            exp.buildertek__Budget_Line__c = budgetItemMap.get(exp.Id).Id;
            exp.buildertek__Budget__c = RecId;
            exp.buildertek__Project__c = budgetRec.buildertek__Project__c;
        }
        update selectedExpenses;

        BudgetDAO.isCreateExpense = false;
    }

    @AuraEnabled
    public static void CreateLineAddInvoice(List<buildertek__Account_Payable_Clone__c> selectedInvoices, string RecId){

        // BudgetDAO.isCreateExpense = true;
        System.debug('CreateLineAddInvoice');
        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];

        List<buildertek__Budget_Line_Group__c> budgetLineGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Invoice (AP)' ORDER BY Name ASC limit 1];

        String groupId = '';
        System.debug('budgetLineGroup' + budgetLineGroup);


        if (budgetLineGroup.size() > 0) {
            groupId = budgetLineGroup[0].Id;
        } else {
            buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
            budgetGroup.Name = 'Invoice (AP)';
            insert budgetGroup;

            groupId = budgetGroup.Id;
        }

        Map<Id, buildertek__Budget_Item__c> budgetItemMap = new Map<Id, buildertek__Budget_Item__c>();
        for (buildertek__Account_Payable_Clone__c invoiceAP : selectedInvoices) {
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Name = invoiceAP.buildertek__Description__c;
            budgetItem.buildertek__Budget__c = RecId;
            budgetItem.buildertek__Group__c = groupId;
            budgetItemMap.put(invoiceAP.Id, budgetItem);
        System.debug('Before Map' + budgetItemMap);

        }
        insert budgetItemMap.values();
        System.debug('budgetItemMap' + budgetItemMap);


        for (buildertek__Account_Payable_Clone__c invoiceAP : selectedInvoices) {
            invoiceAP.buildertek__Budget_Line__c = budgetItemMap.get(invoiceAP.Id).Id;
            invoiceAP.buildertek__Budget__c = RecId;
            invoiceAP.buildertek__Project__c = budgetRec.buildertek__Project__c;
        }
        update selectedInvoices;
        System.debug('selectedInvoices' + selectedInvoices);


        // BudgetDAO.isCreateExpense = false;
    }
    @AuraEnabled
    public static void CreateLineAddLabor(List<buildertek__Time_Cards__c> selectedTimeCard, string RecId){

        // BudgetDAO.isCreateExpense = true;
        System.debug('CreateLineAddLabor');
        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];

        List<buildertek__Budget_Line_Group__c> budgetLineGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Labor' ORDER BY Name ASC limit 1];

        String groupId = '';
        System.debug('budgetLineGroup' + budgetLineGroup);


        if (budgetLineGroup.size() > 0) {
            groupId = budgetLineGroup[0].Id;
        } else {
            buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
            budgetGroup.Name = 'Labor';
            insert budgetGroup;

            groupId = budgetGroup.Id;
        }

        Map<Id, buildertek__Budget_Item__c> budgetItemMap = new Map<Id, buildertek__Budget_Item__c>();
        for (buildertek__Time_Cards__c timeCard : selectedTimeCard) {
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Name = timeCard.buildertek__Resource__c != null ? timeCard.buildertek__Resource__r.Name : timeCard.Name;
            budgetItem.buildertek__Budget__c = RecId;
            budgetItem.buildertek__Group__c = groupId;
            budgetItemMap.put(timeCard.Id, budgetItem);
        System.debug('Before Map' + budgetItemMap);

        }
        insert budgetItemMap.values();
        System.debug('budgetItemMap' + budgetItemMap);


        for (buildertek__Time_Cards__c timeCard : selectedTimeCard) {
            timeCard.buildertek__Budget_Line__c = budgetItemMap.get(timeCard.Id).Id;
            timeCard.buildertek__Budget__c = RecId;
            timeCard.buildertek__Project__c = budgetRec.buildertek__Project__c;
        }
        update selectedTimeCard;
        System.debug('selectedInvoices' + selectedTimeCard);


        // BudgetDAO.isCreateExpense = false;
    }


    public class multipleBudgetLinesClass{
        @AuraEnabled
        public String pricebookName{ get; set; }

        @AuraEnabled
        public String  productfamily{ get; set; }

        @AuraEnabled
        public Product2 product{ get; set; }

        @AuraEnabled
        public Integer index{ get; set; }

        @AuraEnabled
        public buildertek__Budget_Item__c newBudgetLine{ get; set; }

        @AuraEnabled
        public VendorClass Vendor{ get; set; }

        @AuraEnabled
        public String  UOMvalues{ get; set; }


    }


    public class VendorClass {
        @AuraEnabled
         public Id Id{ get; set; }
          @AuraEnabled
         public String  Name{ get; set; }
    }

    public class COLineItemsClass{
        @AuraEnabled
        public buildertek__Budget_Item__c changeOrderItem{ get; set; }

        @AuraEnabled
        public Boolean isProduct{ get; set; }

        @AuraEnabled
        public Integer rowIndex{ get; set; }

        public COLineItemsClass(buildertek__Budget_Item__c changeOrderItem, Boolean isProduct, Integer rowIndex){
            this.changeOrderItem = changeOrderItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }
    @AuraEnabled
    public static List<COLineItemsClass> addProductsToList(String COItems, buildertek__Budget_Item__c COItem, Integer count){
      //  system.debug('coItem -----------> ' + COItems);
      //  system.debug('COItem -----------> ' + COItem);
       // system.debug('count ---------> ' + count);
        List<COLineItemsClass> changeOrderList = (List<COLineItemsClass>)JSON.deserialize(coItems, List<COLineItemsClass>.class);
      //  system.debug('changeOrderList -----------> ' + changeOrderList);

        changeOrderList.add(new COLineItemsClass(COItem, false, count));
        return changeOrderList;
    }

    @AuraEnabled
    public static buildertek__Admin_Interface_Node_Configuration__c getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Budget_Grouping_Data__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Budget Configuration'];
        return adminInterfaceNodeConfigurations;
    }

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> checkforBidgetItem(list<string> BudgetIds){
        //convert string to id
        List<Id> budgetitemId = new List<Id>();
        for(String budgetId : BudgetIds){
            budgetitemId.add(Id.valueOf(budgetId));
        }
        //check if nay record of buildertek__Account_Payable_Item_Clone__c has the same budget item id as in list budgetitemId
        List<buildertek__Account_Payable_Item_Clone__c> accountPayableItemClones = [Select Id, buildertek__Budget_Line__r.Id, buildertek__Budget_Line__c, buildertek__Budget_Line__r.Name
                                                                                   from buildertek__Account_Payable_Item_Clone__c
                                                                                   where buildertek__Budget_Line__c IN :budgetitemId];
        List<buildertek__Budget_Item__c> budgetItems = new List<buildertek__Budget_Item__c>();
        if(!accountPayableItemClones.isEmpty()){
            for(buildertek__Account_Payable_Item_Clone__c accountPayableItemClone : accountPayableItemClones){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Id = accountPayableItemClone.buildertek__Budget_Line__c;
                budgetItem.Name = accountPayableItemClone.buildertek__Budget_Line__r.Name;
                //check if the budget item is already in the list
                if(!budgetItems.contains(budgetItem)){
                    budgetItems.add(budgetItem);
                }
            }
        }
        return budgetItems;
    }

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> checkforBidgetItemAR(list<string> BudgetIds){
        //convert string to id
        List<Id> budgetitemId = new List<Id>();
        for(String budgetId : BudgetIds){
            budgetitemId.add(Id.valueOf(budgetId));
        }
        //check if nay record of buildertek__Account_Payable_Item_Clone__c has the same budget item id as in list budgetitemId
        List<buildertek__Billable_Lines__c> accountPayableItemClones = [Select Id, buildertek__Budget_Line__r.Id, buildertek__Budget_Line__c, buildertek__Budget_Line__r.Name
                                                                                   from buildertek__Billable_Lines__c
                                                                                   where buildertek__Budget_Line__c IN :budgetitemId];
        List<buildertek__Budget_Item__c> budgetItems = new List<buildertek__Budget_Item__c>();
        if(!accountPayableItemClones.isEmpty()){
            for(buildertek__Billable_Lines__c accountPayableItemClone : accountPayableItemClones){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Id = accountPayableItemClone.buildertek__Budget_Line__c;
                budgetItem.Name = accountPayableItemClone.buildertek__Budget_Line__r.Name;
                //check if the budget item is already in the list
                if(!budgetItems.contains(budgetItem)){
                    budgetItems.add(budgetItem);
                }
            }
        }
        return budgetItems;
    }

    @AuraEnabled
    public static void updatePO(List<String> POId, List<String> BudgetLineId, String budgetId){
        System.debug('POId -----------> ' + POId);
        System.debug('BudgetLineId -----------> ' + BudgetLineId);
        System.debug('budgetId -----------> ' + budgetId);
        List<Id> POIds = new List<Id>();
        for(String PO : POId){
            POIds.add(Id.valueOf(PO));
        }
        List<Id> BudgetLineIds = new List<Id>();
        for(String BudgetLine : BudgetLineId){
            BudgetLineIds.add(Id.valueOf(BudgetLine));
        }
        //get all the PO
        List<buildertek__Purchase_Order__c> purchaseOrders = [Select Id, buildertek__Budget_Line__c, buildertek__Budget_Line__r.Name
                                                                                   from buildertek__Purchase_Order__c
                                                                                   where Id IN :POIds];
        //get all the budget line
        List<buildertek__Budget_Item__c> budgetLines = [Select Id, Name, buildertek__Budget__c, buildertek__Budget__r.Name
                                                                                   from buildertek__Budget_Item__c
                                                                                   where Id IN :BudgetLineIds
                                                                                   ORDER BY Name ASC];
        //loop over all purchase order and update budget and budget line id in PO
        for(buildertek__Purchase_Order__c purchaseOrder : purchaseOrders){
            purchaseOrder.buildertek__Budget__c = budgetLines[0].buildertek__Budget__c;
            purchaseOrder.buildertek__Budget_Line__c = budgetLines[0].Id;
        }
        System.debug('purchaseOrders -----------> ' + purchaseOrders);
        update purchaseOrders;
    }

    // ************ For Add Sales Invoice Button *************

    @AuraEnabled
    public static list<buildertek__Billings__c> getSalesInvoice(String budgetId){
        try {
            String ProjectId = [SELECT Id, Name, buildertek__Project__c FROM  buildertek__Budget__c WHERE Id =: budgetId].buildertek__Project__c;
            list<buildertek__Billings__c> salesInvoiceList = [SELECT Id, Name, buildertek__Budget__r.Name, buildertek__Project__r.Name, buildertek__Project__c, buildertek__Terms__c, buildertek__Amount__c, buildertek__Total_Amount_Tax__c  FROM buildertek__Billings__c WHERE buildertek__Project__c =: ProjectId AND buildertek__Budget__c = null AND buildertek__BT_Budget_Line__c = null];
            return salesInvoiceList;
        } catch (Exception e) {
            System.debug('error in getSalesInvoice => ' + e.getMessage() + ' at line no : '+ e.getLineNumber() );
            return null;
        }
    }

    // @AuraEnabled
    // public static string CreateNewBudgetLine(list<String> SLIDlist, String BudgetId){
    //     try {
    //         String BLGroupID;
    //         list<buildertek__Budget_Line_Group__c> BLGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name LIKE '%Sales Invoice%'];
    //         if (BLGroup.size() == 0){
    //             System.debug('Create Budgt Line Group');
    //             buildertek__Budget_Line_Group__c BLG = new buildertek__Budget_Line_Group__c(Name = 'Sales Invoice');
    //             insert BLG;

    //             BLGroupID = BLG.Id;
    //         } else {
    //             BLGroupID = BLGroup[0].Id;
    //         }
    //         Map<String, buildertek__Budget_Item__c> MapToUpte = new  Map<String, buildertek__Budget_Item__c>();
    //             list<buildertek__Billings__c> UpdateSalesInvoice = new list<buildertek__Billings__c>();
    //             list<buildertek__Billings__c> SalesInvoices = [SELECT Id, Name,buildertek__Total_Amount_Tax__c  FROM buildertek__Billings__c WHERE Id IN : SLIDlist];
    //             for(buildertek__Billings__c Sl : SalesInvoices){
    //                 buildertek__Budget_Item__c BL = new buildertek__Budget_Item__c();
    //                 BL.Name = sl.Name + ' budget line';
    //                 BL.buildertek__Unit_Price__c = sl.buildertek__Total_Amount_Tax__c;
    //                 BL.buildertek__Quantity__c = 1;
    //                 BL.buildertek__Group__c = BLGroupID;
    //                 BL.buildertek__Budget__c = BudgetId;
    //                 MapToUpte.put(Sl.Id, BL);
    //             }
    //             if(MapToUpte.size() > 0){
    //                 // insert MapToUpte.value();
    //                 System.debug('budgetLineToInset => ' + MapToUpte);

    //                 for(buildertek__Billings__c slToUpdate : SalesInvoices){
    //                     slToUpdate.buildertek__BT_Budget_Line__c = MapToUpte.get(slToUpdate.Id).Id;
    //                     slToUpdate.buildertek__Budget__c = BudgetId;
    //                     UpdateSalesInvoice.add(slToUpdate);
    //                 }
    //                 // update UpdateSalesInvoice;
    //                 System.debug('UpdateSalesInvoice => ' + UpdateSalesInvoice);
    //             }
    //         return 'success';
            
    //     } catch (Exception e) {
    //         System.debug('error in UpdateSalesInvoice => ' + e.getMessage() + ' at line no : '+ e.getLineNumber() );
    //         return null;
    //     }
    // }

    @AuraEnabled
    public static string UpdateSalesInvoices(list<String> SLIDlist, String BudgetId){
        try {
            list<buildertek__Billings__c> slToUpdate = new list<buildertek__Billings__c>();
            if(SLIDlist.size() > 0){
                list<buildertek__Billings__c> slIDs = [SELECT Id, Name FROM buildertek__Billings__c WHERE Id IN : SLIDlist];
                for(buildertek__Billings__c sl : slIDs){
                    sl.buildertek__Budget__c = BudgetId;
                    slToUpdate.add(sl);
                }
                    update slToUpdate;
                return 'Successs';
            }
            return null;
        } catch (Exception e) {
            System.debug('error in UpdateSalesInvoice => ' + e.getMessage() + ' at line no : '+ e.getLineNumber() );
            return null;
        }
    }


    @AuraEnabled
    public static List<buildertek__Account_Payable__c> getInvoicePOData(string RecId){
        System.debug('RecId'+ RecId);
        buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c where Id = :RecId ORDER BY Name ASC];
        System.debug(budgetRec);

        List<buildertek__Account_Payable__c> invoicePOList = new List<buildertek__Account_Payable__c>();
        invoicePOList = [SELECT Id, Name, buildertek__Project__c, buildertek__Description__c,buildertek__BT_Budget_Line__c, buildertek__Net_Amount__c, buildertek__Budget__c  FROM buildertek__Account_Payable__c
                        WHERE buildertek__BT_Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: budgetRec.buildertek__Project__c ORDER BY Name DESC];
        
        System.debug('invoicePOList======>>>>>>'+invoicePOList);

        return invoicePOList;
    }

    @AuraEnabled
    public static string addInvoicePOToBudget(list<String> invoicePoList, String BudgetId){
        list<buildertek__Account_Payable__c> invoicePoToUpdate = new list<buildertek__Account_Payable__c>();
        list<buildertek__Payment__c> cashDisburshment = [SELECT Id, buildertek__Payable__c FROM buildertek__Payment__c WHERE buildertek__Payable__c IN: invoicePoList];  // Changes for BUIL-3498 START
        System.debug('cashDisburshment -- SIZE---->' + cashDisburshment.size()); 
        if(invoicePoList.size() > 0 && cashDisburshment.size() == 0){  
            list<buildertek__Account_Payable__c> invPoList = [SELECT Id, Name FROM buildertek__Account_Payable__c WHERE Id IN : invoicePoList];
            for(buildertek__Account_Payable__c invoicePo : invPoList){
                invoicePo.buildertek__Budget__c = BudgetId;
                invoicePoToUpdate.add(invoicePo);
            }
                update invoicePoToUpdate;
            return 'Successs';
        }else if (cashDisburshment.size() > 0) {
            return 'HasDisburshment';
        } // Changes for BUIL-3498 END
        return null;
    }

    @AuraEnabled
    public static string CheckUserAccess(String AccessType){
        // try {
            switch on AccessType{
                when 'Create'{
                    if(Schema.sObjectType.buildertek__Budget_Item__c.isCreateable())
                        {return 'True';}
                    else{ return 'False'; }
                }
                when 'Update'{
                    if(Schema.sObjectType.buildertek__Budget_Item__c.isUpdateable()){
                        return 'True';
                    }
                    else{
                        return 'False';
                    }
                }
                when 'Delete'{
                    if(Schema.sObjectType.buildertek__Budget_Item__c.isDeletable()){
                        return 'True';
                    }
                    else{
                        return 'False';
                    }
                }
                when else{
                    return null;
                }
            }
        }


    @AuraEnabled
    public static budgetLineWrapperClass getBudgetLineData(String budgetId, Integer pageNumber, Integer recordToDisply, List<String> groupingList){
        budgetLineWrapperClass mainWrapper = new budgetLineWrapperClass();
        Integer pageSize = recordToDisply;
        Integer offset = (pageNumber - 1) * pageSize;
        List<String> gorupingFieldList = new List<String>{'id', 'buildertek__Sub_Grouping__c', 'buildertek__Group__c'};
        String apiString = '';

        List<BT_Lightning_Utils.dataTableFields> column = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Budget_Item__c', 'buildertek__BT_Related_List_View_Fields');
        for(BT_Lightning_Utils.dataTableFields s : column){
            if (!gorupingFieldList.contains(s.fieldName)) {
                apiString += s.fieldName + ', ';
            }
        }
        String query = 'SELECT Id, '+apiString;
        query += 'buildertek__Sub_Grouping__c, buildertek__Sub_Grouping__r.Name, buildertek__Group__c, buildertek__Group__r.Name ';
        query += 'FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =\''+budgetId+'\''+' ORDER BY '+groupingList[0];
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

        List<buildertek__Budget_Item__c> budgetLineList = Database.query(query);

        Integer totalBudgetLine = [SELECT count() FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c = :budgetId];

        buildertek__Budget__c budget = [SELECT Id, Name, buildertek__Budget_Line_Grouping_Fields__c FROM buildertek__Budget__c WHERE Id =: budgetId];
        budget.buildertek__Budget_Line_Grouping_Fields__c = JSON.serialize(groupingList);
        update budget;

        mainWrapper.budgetLineList = budgetLineList;
        mainWrapper.columns = column;
        mainWrapper.pageSize = recordToDisply;
        mainWrapper.pageNumber = pageNumber;
        mainWrapper.total = totalBudgetLine;

        return mainWrapper;

    }    

    public class budgetLineWrapperClass{

        @AuraEnabled
        public List<buildertek__Budget_Item__c> budgetLineList;
    
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;
    
        @AuraEnabled
        public Integer pageSize{ get; set; }
    
        @AuraEnabled
        public Integer pageNumber{ get; set; }
    
        @AuraEnabled
        public Integer total{ get; set; }
    }



}