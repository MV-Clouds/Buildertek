public with sharing class ImportquoteClass {
    @AuraEnabled
    public static object getquotes(){
        List<MasterquoteClass> MasterquoteClassList = new List<MasterquoteClass>();
        List<buildertek__Quote__c> quotesList;
                         quotesList = [SELECT Id,
                                        Name,buildertek__Project__c,
                                        buildertek__Project__r.Name,
                                        buildertek__Type__c
                                        from buildertek__Quote__c
                                        WHERE buildertek__Type__c = 'Master' ORDER BY Name ASC];    
        
        for(buildertek__Quote__c bud : quotesList){
            MasterquoteClass MasterquotesClassRecord = new MasterquoteClass(); 
            MasterquotesClassRecord.quoteRecord = bud;
            MasterquotesClassRecord.budgetCheck = false;
            MasterquoteClassList.add(MasterquotesClassRecord);
        }
        return  MasterquoteClassList;                                               
    }
    
    @AuraEnabled
    public static MessageClass importMasterBudgetLines(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Quote_Item__c> masterquoteList;
                masterquoteList = [SELECT id, 
                                        Name, 
                                        buildertek__Item_Name__c,
                                        buildertek__Pricing_Method__c,
                                        buildertek__UOM__c, 
                                        buildertek__Status__c,
                                        buildertek__Markup__c,
                                    	buildertek__Additional_Discount__c,
                                        buildertek__Applied_Markup__c,
                                        buildertek__Priority__c,
                                    	buildertek__Quantity__c,
                                        buildertek__Quote__c,
                                        buildertek__Sub_Group__c,
                                        buildertek__Grouping__c,
                                        buildertek__Purchase_Order__c,
                                    	buildertek__Product__c,
                                    	buildertek__Cost_Code__c,
                                    	buildertek__Vendor__c,
                                    	buildertek__Description__c,
                                    	buildertek__Notes__c,
                                    	buildertek__Unit_Cost__c,
                                        buildertek__Unit_Price__c
                                        FROM buildertek__Quote_Item__c
                                        WHERE buildertek__Quote__c IN: budgetIds AND buildertek__Status__c = 'Accept']; 
            List<buildertek__Budget_Item__c> BudgetItemist =  new List<buildertek__Budget_Item__c>();
            List< buildertek__Budget_Line_Group__c> budgetGroup;
            budgetGroup= [SELECT Id, Name FROM  buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping'];
            if(!masterquoteList.isEmpty()){
                for(buildertek__Quote_Item__c masterquote : masterquoteList){
                    buildertek__Budget_Item__c BudgetItem = new buildertek__Budget_Item__c();
                    BudgetItem.Name = masterquote.Name;
                    BudgetItem.buildertek__UOM__c = masterquote.buildertek__UOM__c;
                   /* if(masterquote.buildertek__Group__c != null){
                       BudgetItem.buildertek__Group__c = masterquote.buildertek__Group__c; 
                    }else{*/
                        BudgetItem.buildertek__Group__c = budgetGroup[0].Id;
                    //}
                    BudgetItem.buildertek__Budget__c = recordId;
                    BudgetItem.buildertek__Product__c = masterquote.buildertek__Product__c;
                    BudgetItem.buildertek__Quantity__c = masterquote.buildertek__Quantity__c;
                    //BudgetItem.buildertek__Amount_In__c = masterquote.buildertek__Amount_In__c;
                    BudgetItem.buildertek__cost_Code__c = masterquote.buildertek__cost_Code__c;
                   // BudgetItem.buildertek__Unit_Price__c = masterquote.buildertek__Unit_Price__c;
                    BudgetItem.buildertek__Unit_Price__c = masterquote.buildertek__Unit_Cost__c;
                    BudgetItem.buildertek__Description__c = masterquote.buildertek__Description__c;
                   // BudgetItem.buildertek__Forecast_To_Complete__c = masterquote.buildertek__Forecast_To_Complete__c;
                    BudgetItemist.add(BudgetItem);
               }   
            }
            if(BudgetItemist.size() > 0){
                
                    insert BudgetItemist;
        		
                msg.Status = 'Success';
                msg.Message = 'Quote Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Quote Lines for the selected Quote';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
    public class MasterquoteClass{
         @AuraEnabled
         public buildertek__Quote__c quoteRecord {get;set;}
         @AuraEnabled
         public buildertek__Master_Budget__c masterBudgetRecord {get;set;}
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 

}