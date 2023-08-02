public with sharing class ImportmasterRFQClass {
     @AuraEnabled
    public static object getMasterRFQs(){
       /* list<buildertek__Master_Budget__c> masterBudgetList;
        If(Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Type__c.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Budget__c.fields.Original_Budget__c.isAccessible()){
               masterBudgetList = [select id, 
                                            Name, 
                                            buildertek__Type__c,
                                            Original_Budget__c
                                            from buildertek__Master_Budget__c 
                                            ORDER BY Name 
                                            ASC limit 50000]; 
              } 
                                                                        
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        for(buildertek__Master_Budget__c masterBudget : masterBudgetList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.masterBudgetRecord = masterBudget;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }*/
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__RFQ__c> rfqList;
        If(Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() &&
              Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible() &&
              Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Type__c.isAccessible()){ 
                         rfqList = [SELECT Id,
                                        Name,
                                        buildertek__Project__r.Name,
                                        buildertek__Type__c,
                                        buildertek__Status__c
                                        FROM buildertek__RFQ__c
                                        WHERE buildertek__Type__c = 'Master' ];    
        
              }
        for(buildertek__RFQ__c bud : rfqList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;                                               
    }
    @AuraEnabled
    public static MessageClass importMasterBudgetLines(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__RFQ_Item__c> masterBudgetList;
            
                      
                masterBudgetList = [SELECT id, 
                                        Name, 
                                        buildertek__Budget_Item__c, 
                                        buildertek__Cost_Code__c,
                                        buildertek__Description__c,
                                        buildertek__Master_Item__c, 
                                        buildertek__Notes_Details__c,
                                        buildertek__Product__c,
                                        buildertek__Quantity__c, 
                                        buildertek__Quote_Item__c,
                                        buildertek__RFQ_Package__c,
                                        buildertek__Trade_Type__c,
                                        buildertek__Unit_Price__c
                                        FROM buildertek__RFQ_Item__c
                                        WHERE buildertek__RFQ_Package__c IN: budgetIds]; 
            List<buildertek__RFQ_Item__c> BudgetItemist =  new List<buildertek__RFQ_Item__c>();
           /* List< buildertek__Budget_Line_Group__c> budgetGroup;
            
                budgetGroup= [SELECT Id, Name FROM  buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping'];*/
            if(!masterBudgetList.isEmpty()){
                for(buildertek__RFQ_Item__c masterBudget : masterBudgetList){
                    buildertek__RFQ_Item__c BudgetItem = new buildertek__RFQ_Item__c();
                    BudgetItem.Name = masterBudget.Name;
                    BudgetItem.buildertek__Budget_Item__c = masterBudget.buildertek__Budget_Item__c;
                    BudgetItem.buildertek__RFQ_Package__c = recordId;
                    BudgetItem.buildertek__Cost_Code__c = masterBudget.buildertek__Cost_Code__c;
                    BudgetItem.buildertek__Description__c = masterBudget.buildertek__Description__c;
                    BudgetItem.buildertek__Master_Item__c = masterBudget.buildertek__Master_Item__c;
                    BudgetItem.buildertek__Notes_Details__c = masterBudget.buildertek__Notes_Details__c;
                    BudgetItem.buildertek__Product__c = masterBudget.buildertek__Product__c;
                    BudgetItem.buildertek__Quantity__c = 1;
                     //BudgetItem.buildertek__Quantity__c = masterBudget.buildertek__Quantity__c;
                     BudgetItem.buildertek__Quote_Item__c = masterBudget.buildertek__Quote_Item__c;
                     BudgetItem.buildertek__Trade_Type__c = masterBudget.buildertek__Trade_Type__c;
                   //  BudgetItem.buildertek__Unit_Price__c = 0;
                    BudgetItem.buildertek__Unit_Price__c = masterBudget.buildertek__Unit_Price__c;
                    BudgetItemist.add(BudgetItem);
               }   
            }
            if(BudgetItemist.size() > 0){
                
                    insert BudgetItemist;
                
                msg.Status = 'Success';
                msg.Message = 'RFQ Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no RFQ Lines for the selected RFQ';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
      @AuraEnabled
    public static string Checkstatus(string RFQId){
        buildertek__RFQ__c RFQRecord = [SELECT Id, Name,buildertek__Status__c 
                                        FROM buildertek__RFQ__c
                                        WHERE Id =: RFQId];
        return RFQRecord.buildertek__Status__c ;
        
    }
    
    
    
    
    
    public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__RFQ__c budgetRecord {get;set;}
        // @AuraEnabled
        // public buildertek__Master_Budget__c masterBudgetRecord {get;set;}
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