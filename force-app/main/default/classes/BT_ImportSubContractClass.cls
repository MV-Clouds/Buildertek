public class BT_ImportSubContractClass {
      @AuraEnabled
    public static object getMasterBudgets(){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqList;
          If(Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Type__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Cost_Code__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Community__c.isAccessible() &&
              Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount__c.isAccessible() &&
              Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Signed_Contract_Date__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isAccessible()){ 
               rfqList = [SELECT Id,
                          Name,
                          buildertek__Type__c,
                          buildertek__Contract_Amount__c,
                          buildertek__Signed_Contract_Date__c,
                          buildertek__Cost_Code__r.Name,
                          buildertek__Vendor__r.Name,
                          buildertek__Community__r.Name,
                          RecordType.Name
                          FROM buildertek__Contract__c
                          WHERE buildertek__Type__c = 'Master' and   RecordType.Name = 'Sub Contract' ];    
               
           }
        for(buildertek__Contract__c bud : rfqList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
             MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;   
    }
    
    
     
    @AuraEnabled
public static MessageClass importSubContractItems(List<String> budgetIds, String recordId){
     MessageClass msg = new MessageClass();
    try{
        List<buildertek__Contract__c> ContractList;
         List<buildertek__Contract_Item__c> contractItems;
        
         ContractList = [SELECT Id,
                          Name,
                          buildertek__Type__c,
                          buildertek__Cost_Code__r.Name,
                          buildertek__Vendor__r.Name,
                           buildertek__Contract_Amount__c,
                          buildertek__Signed_Contract_Date__c,
                          buildertek__Community__r.Name,
                          RecordType.Name
                          FROM buildertek__Contract__c
                          WHERE id IN: budgetIds and buildertek__Type__c = 'Master' and   RecordType.Name = 'Sub Contract' ];    
        
        contractItems = [SELECT Id,
                  Name,
                  buildertek__Contract__c,
                  buildertek__Cost_Code__c,
                  buildertek__Description__c,
                  buildertek__Notes__c,
                  buildertek__Product__c,
                  buildertek__Unit_Price__c,
                  buildertek__Total_Price__c
                  FROM buildertek__Contract_Item__c
                  WHERE buildertek__Contract__c IN : ContractList]; 
        system.debug('ContractList'+ContractList);
        system.debug('contractItems..'+contractItems);
        List<buildertek__Purchase_Order_Item__c> BudgetItemist =  new List<buildertek__Purchase_Order_Item__c>();
        if(!contractItems.isEmpty()){
            for(buildertek__Contract_Item__c masterBudget : contractItems){
                buildertek__Purchase_Order_Item__c BudgetItem = new buildertek__Purchase_Order_Item__c();
                BudgetItem.buildertek__Sub_Contract_Item__c = masterBudget.id;
                BudgetItem.buildertek__Description__c = masterBudget.buildertek__Description__c;
                BudgetItem.buildertek__Purchase_Order__c = recordId;
                BudgetItem.Name = masterBudget.Name;
                BudgetItem.buildertek__Unit_Price__c = masterBudget.buildertek__Unit_Price__c;
                BudgetItem.buildertek__Cost_Code__c = masterBudget.buildertek__Cost_Code__c;
                BudgetItem.buildertek__Product__c = masterBudget.buildertek__Product__c;
               // BudgetItem.buildertek__Budget_Item__c = masterBudget.buildertek__Budget_Item__c;
                BudgetItemist.add(BudgetItem);
                system.debug('BudgetItemist'+BudgetItemist);
           }   
        }
        if(BudgetItemist.size() > 0){
            
                insert BudgetItemist;
            
            msg.Status = 'Success';
            msg.Message = 'Sub-Contract Lines Imported Successfully';
        }else{
            msg.Status = 'Failed';
            msg.Message = 'There were no Sub-Contract Lines for the selected Sub-Contract';    
        }
        return msg;
    }catch(Exception exp){
        msg.Status = 'Failed';
        msg.Message = exp.getMessage();  
        return msg;
    }                                             

}

public class MessageClass{
    @AuraEnabled
    public String Status {get;set;}
     @AuraEnabled
    public string Message {get;set;}
    
} 
    @AuraEnabled
    public static object findByName(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c,
                    buildertek__Community__r.Name,
                    RecordType.Name
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Cost_Code__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists;  
    }
    
     @AuraEnabled
    public static object findByName1(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists1 = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c,
                    buildertek__Community__r.Name,
                    RecordType.Name
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Vendor__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists1.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists1;  
    }
    
     @AuraEnabled
    public static object findByName2(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists2 = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c,
                    buildertek__Community__r.Name,
                    RecordType.Name
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Community__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists2.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists2;  
    }
    

     public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__Contract__c budgetRecord {get;set;}
        
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }

}