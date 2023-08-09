public class BT_ImportMasterPRLDClass {
    @AuraEnabled
    public static object getMasterBudgets(){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Pricing_Request_Line_Details__c> rfqList;
          If(Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Description__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Quantity__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Cost__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Markup__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Vendor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line_Details__c.fields.buildertek__Category__c.isAccessible()){ 
               rfqList = [SELECT Id,
                          Name,
                          buildertek__Description__c,
                          buildertek__Type__c,
                          buildertek__Category__r.Name,
                          buildertek__Quantity__c,
                          buildertek__Cost__c,
                          buildertek__Markup__c,
                          buildertek__Price__c,
                          buildertek__Vendor__r.Name
                          FROM buildertek__Pricing_Request_Line_Details__c
                          WHERE buildertek__Type__c = 'Master' ];    
               
           }
        for(buildertek__Pricing_Request_Line_Details__c bud : rfqList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
             MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;   
    }
    
    
     
  @AuraEnabled
public static MessageClass importRFQItems(List<String> budgetIds, String recordId){
     MessageClass msg = new MessageClass();
    try{
        List<buildertek__Pricing_Request_Line_Details__c> masterBudgetList;
        masterBudgetList = [SELECT Id,
                  Name,
                  buildertek__Description__c,
                  buildertek__Type__c,
                  buildertek__Category__r.Name,
                  buildertek__Quantity__c,
                  buildertek__Cost__c,
                  buildertek__Markup__c,
                  buildertek__Price__c,
                  buildertek__Vendor__r.Name
                  FROM buildertek__Pricing_Request_Line_Details__c
                  WHERE id IN: budgetIds]; 
        system.debug('masterBudgetList'+masterBudgetList);
        List<buildertek__Pricing_Request_Line_Details__c> BudgetItemist =  new List<buildertek__Pricing_Request_Line_Details__c>();
        if(!masterBudgetList.isEmpty()){
            for(buildertek__Pricing_Request_Line_Details__c masterBudget : masterBudgetList){
                buildertek__Pricing_Request_Line_Details__c BudgetItem = new buildertek__Pricing_Request_Line_Details__c();
                BudgetItem.buildertek__Pricing_Request_Line__c = recordId;
                BudgetItem.buildertek__Description__c = masterBudget.buildertek__Description__c;
                BudgetItem.buildertek__Quantity__c = masterBudget.buildertek__Quantity__c;
               // BudgetItem.buildertek__Category__r.Name = masterBudget.buildertek__Category__r.Name;
                BudgetItem.buildertek__Cost__c = masterBudget.buildertek__Cost__c;
                BudgetItem.buildertek__Markup__c = masterBudget.buildertek__Markup__c;
                BudgetItem.buildertek__Vendor__c = masterBudget.buildertek__Vendor__c;
                BudgetItemist.add(BudgetItem);
                system.debug('BudgetItemist'+BudgetItemist);
           }   
        }
        if(BudgetItemist.size() > 0){
            
                insert BudgetItemist;
            
            msg.Status = 'Success';
            msg.Message = 'PRLD Lines Imported Successfully';
        }else{
            msg.Status = 'Failed';
            msg.Message = 'There were no PRLD for the selected PRLD';    
        }
        return msg;
    }catch(Exception exp){
        msg.Status = 'Failed';
        msg.Message = exp.getMessage();  
        return msg;
    }                                             

}

@AuraEnabled
public static String getTradeTypes(String RFQRecId){
    buildertek__Pricing_Request_Line_Details__c rfqRec = [select id,Name,buildertek__Category__c from buildertek__Pricing_Request_Line_Details__c where id =: RFQRecId];
    return rfqRec.buildertek__Category__c;
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
  List<buildertek__Pricing_Request_Line_Details__c> rfqLists;
   String  name =  + searchKey + '%'; 
   //  decimal  names =  + searchKey + 1 ;
    // decimal names =  + searchKeys + ' % ';
    rfqLists = [SELECT Id,
                  buildertek__Description__c,
                  buildertek__Type__c,
                  buildertek__Category__r.Name,
                  buildertek__Quantity__c,
                  buildertek__Cost__c,
                  buildertek__Markup__c,
                  buildertek__Price__c,
                  buildertek__Vendor__r.Name
                      FROM buildertek__Pricing_Request_Line_Details__c
                      WHERE buildertek__Type__c = 'Master'
            and  buildertek__Category__r.Name LIKE :name ];
    
     for(buildertek__Pricing_Request_Line_Details__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
             MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists;  
    
}
    
     public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__Pricing_Request_Line_Details__c budgetRecord {get;set;}
        
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }

}