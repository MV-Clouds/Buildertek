public with sharing class BT_Expenses_ComponentController {

    @AuraEnabled
    public static List<Project__c> getProjects(){
        List<buildertek__Project__c> projects = [SELECT Id, Name FROM buildertek__Project__c ORDER BY Name ASC];
        return projects;
    }

    @AuraEnabled
    public static List<buildertek__Expense__c> getExpenses(Id projectId){
        List<buildertek__Expense__c> ExpenseList = new List<buildertek__Expense__c>();
        ExpenseList = [SELECT Id, Name, buildertek__Project__c, buildertek__Description__c,buildertek__Budget_Line__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Budget__c,
                                buildertek__Total_Expense__c, buildertek__Cost_Code__r.Name FROM buildertek__Expense__c
                                WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: projectId ORDER BY Name ASC];
        return ExpenseList;
    }

    @AuraEnabled
    public static List<buildertek__Budget__c> getBudgets(Id projectId){
        List<buildertek__Budget__c> BudgetList = new List<buildertek__Budget__c>();
        BudgetList = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c
                                WHERE buildertek__Project__c=: projectId ORDER BY Name ASC];
        return BudgetList;
    }

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> getBudgetLines(Id budgetId){
        List<buildertek__Budget_Item__c> BudgetLineList = new List<buildertek__Budget_Item__c>();
        BudgetLineList = [SELECT Id, Name, buildertek__Budget__c, buildertek__Cost_Code__c, buildertek__Cost_Code__r.Name FROM buildertek__Budget_Item__c
                                WHERE buildertek__Budget__c=: budgetId ORDER BY Name ASC];
        return BudgetLineList;
    }

    @AuraEnabled
    public static void saveExp(List<buildertek__Expense__c> expenses){
        System.debug('expenses: ' + expenses);
        update expenses;
    }

    @AuraEnabled
    public static List<buildertek__Time_Cards__c> getTimeCards(Id projectId){
        List<buildertek__Time_Cards__c> TimeCardList = new List<buildertek__Time_Cards__c>();
        TimeCardList = [SELECT Id, Name,buildertek__Resource__c, buildertek__Hours_Worked__c, buildertek__Daily_Expense__c, buildertek__Project__c, buildertek__Budget__c, buildertek__Resource__r.Name
                                FROM buildertek__Time_Cards__c
                                WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND  buildertek__Project__c=: projectId ORDER BY Name ASC];
        return TimeCardList;
    }

    @AuraEnabled
    public static void saveTC(List<buildertek__Time_Cards__c> TimeCard){
        System.debug('TimeCard: ' + TimeCard);
        update TimeCard;
    }

    @AuraEnabled
    public static List<buildertek__Account_Payable_Clone__c> getInvoices(Id projectId){
        List<buildertek__Account_Payable_Clone__c> InvoiceList = new List<buildertek__Account_Payable_Clone__c>();
        InvoiceList = [SELECT Id, buildertek__Auto_Number__c, buildertek__Project__c, buildertek__Description__c, buildertek__Cost_Code__c, buildertek__Net_Amount__c, buildertek__Budget__c, buildertek__Budget_Line__c
                                FROM buildertek__Account_Payable_Clone__c
                                WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: projectId ORDER BY Name ASC];
        return InvoiceList;
    }

    @AuraEnabled
    public static List<buildertek__Change_Order__c> getChangeOrders(Id projectId){
        List<buildertek__Change_Order__c> changeOrderList = new List<buildertek__Change_Order__c>();
        changeOrderList = [SELECT Id, Name, buildertek__CO_Number__c, buildertek__Date_Approved__c, buildertek__Total_Amount_Tax__c, buildertek__Project__c, buildertek__Description__c, buildertek__Total_Costs__c, buildertek__Budget__c, buildertek__Budget_Line__c
                                FROM buildertek__Change_Order__c
                                WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: projectId ORDER BY Name ASC];
        return changeOrderList;
    }



    @AuraEnabled
    public static List<buildertek__Account_Payable_Clone__c> saveInv(List<buildertek__Account_Payable_Clone__c> Invoices){
        System.debug('invoices: ' + invoices);
        update invoices;
        return invoices;
    }


    @AuraEnabled
    public static List<buildertek__Change_Order__c> saveChangeOrder(List<buildertek__Change_Order__c> changeOrderList){
        System.debug('changeOrderList: ' + changeOrderList);
        update changeOrderList;
        return changeOrderList;
    }


    @AuraEnabled
    public static List<buildertek__Purchase_Order__c> getPurchaseOrders(Id projectId){
        List<buildertek__Purchase_Order__c> PurchaseOrderList = new List<buildertek__Purchase_Order__c>();
        PurchaseOrderList = [SELECT Id, Name, buildertek__Project__c, buildertek__Type__c, buildertek__Cost_Code__c,buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__PO_Balance__c, buildertek__Budget__c, buildertek__Budget_Line__c
                                FROM buildertek__Purchase_Order__c
                                WHERE buildertek__Budget_Line__c = null AND buildertek__Budget__c = null AND buildertek__Project__c=: projectId ORDER BY Name ASC];
        return PurchaseOrderList;
    }

    @AuraEnabled
    public static void savePO(List<buildertek__Purchase_Order__c> PurchaseOrder){
        System.debug('PurchaseOrder: ' + PurchaseOrder);
        update PurchaseOrder;
    }


}