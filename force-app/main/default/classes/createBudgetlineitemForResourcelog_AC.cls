public with sharing class createBudgetlineitemForResourcelog_AC {
    /**/
    @AuraEnabled
    public static object getBudgets(string ResourcelogRecId){
       buildertek__Resource_Log__c reslog = [select id,Name,buildertek__Project__c from buildertek__Resource_Log__c where Id =:ResourcelogRecId];
        
        list<buildertek__Budget__c> BudgetList;
        
                         BudgetList = [SELECT Id,
                                        Name,
                                        buildertek__Project__c,
                                        buildertek__Project__r.Name,
                                        buildertek__Type__c
                                        FROM buildertek__Budget__c
                                        WHERE buildertek__Project__c =: reslog.buildertek__Project__c];    
        
              
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        for(buildertek__Budget__c bud : BudgetList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;  
    }
 @AuraEnabled
    public static MessageClass createBudgetLinerecs(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
                                                
          List<buildertek__Resource_Log__c>  resloglist = [select id,
                                                            Name,buildertek__Resource__c,
                                                            buildertek__Resource__r.Name,
                                                            buildertek__Log_Date__c,
                                                            buildertek__Daily_Expense__c,
                                                            buildertek__Hours_Worked_Formula__c,
                                                            buildertek__Hourly_Rate__c,
                                                            buildertek__Cost_Code__c
                                                            from buildertek__Resource_Log__c
                                                            where Id =:recordId];                                        
            list<buildertek__Budget__c> budlstrec = [SELECT Id,Name from buildertek__Budget__c where Id IN:budgetIds];
            List<buildertek__Budget_Item__c> BudgetItemlist =  new List<buildertek__Budget_Item__c>();
            buildertek__Budget_Line_Group__c linegroup =[select id ,Name from buildertek__Budget_Line_Group__c where Name =:'Labor' limit 1];
            
            if(!resloglist.isEmpty()){
                for(buildertek__Budget__c bud: budlstrec){
                    buildertek__Budget_Item__c BudgetItem = new buildertek__Budget_Item__c();
                    BudgetItem.Name = resloglist[0].buildertek__Resource__r.Name +'  '+ resloglist[0].buildertek__Log_Date__c ;
                   
                    BudgetItem.buildertek__Budget__c = bud.id;
                    BudgetItem.buildertek__Group__c = linegroup.Id;
                    BudgetItem.buildertek__Cost_Type__c = 'Labor';
                    
                    //BudgetItem.buildertek__Quantity__c = resloglist[0].buildertek__Hours_Worked_Formula__c;
                    BudgetItem.buildertek__Quantity__c = 1;
                    BudgetItem.buildertek__cost_Code__c = resloglist[0].buildertek__cost_Code__c;
                    BudgetItem.buildertek__Unit_Price__c = resloglist[0].buildertek__Daily_Expense__c * -1;
                    //BudgetItem.buildertek__Budget_Line_Group__c = linegroup.Id;
                    BudgetItemlist.add(BudgetItem);
                }         
            }
            
            if(BudgetItemlist.size() > 0){
                
                    insert BudgetItemlist;
                
                msg.Status = 'Success';
                msg.Message = 'Budget Line Created Successfully';
            }else{
                msg.Status = 'Failed';
               // msg.Message = 'There were no Budget Lines for the selected Budget';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                    
    }
    
 public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__Budget__c budgetRecord {get;set;}
        
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