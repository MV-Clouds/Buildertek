public class BT_ImportMasterPRLClass {
     @AuraEnabled
    public static object getMasterBudgets(){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Pricing_Request_Line__c> rfqList;
          If(Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Description__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Status__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Cost__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Markup__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__New_Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Pricing_Request_Line__c.fields.buildertek__Type__c.isAccessible()){ 
               rfqList = [SELECT Id,
                          Name,
                          buildertek__Description__c,
                          buildertek__Type__c,
                          buildertek__Status__c,
                          buildertek__New_Price__c,
                          buildertek__Cost__c,
                          buildertek__Markup__c,
                          buildertek__Price__c
                          FROM buildertek__Pricing_Request_Line__c
                          WHERE buildertek__Type__c = 'Master' ];    
               
           }
        for(buildertek__Pricing_Request_Line__c bud : rfqList){
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
            List<buildertek__Pricing_Request_Line__c> masterBudgetList;
            List<buildertek__Pricing_Request_Line_Details__c> pricingrequestlinedetails;
            masterBudgetList = [SELECT Id,
                                Name,
                                buildertek__Description__c,
                                buildertek__Type__c,
                                buildertek__Status__c,
                                buildertek__New_Price__c,
                                buildertek__RFQ__c,
                                buildertek__Cost__c,
                                buildertek__Markup__c,
                                buildertek__Price__c,
                                buildertek__Pricing_Request__c,
                                buildertek__Notes__c
                                FROM buildertek__Pricing_Request_Line__c
                                WHERE id IN: budgetIds]; 
            system.debug('masterBudgetList'+masterBudgetList);
            List<buildertek__Pricing_Request_Line__c> BudgetItemist =  new List<buildertek__Pricing_Request_Line__c>();
            list<Id> pricingrequestids = new list<Id>();
            if(!masterBudgetList.isEmpty()){
                for(buildertek__Pricing_Request_Line__c masterBudget : masterBudgetList){
                    pricingrequestids.add(masterBudget.id);
                    buildertek__Pricing_Request_Line__c BudgetItem = new buildertek__Pricing_Request_Line__c();
                    BudgetItem.buildertek__Pricing_Request__c = recordId;
                    BudgetItem.buildertek__Description__c = masterBudget.buildertek__Description__c;
                  //  BudgetItem.buildertek__Status__c = masterBudget.buildertek__Status__c;
                    //BudgetItem.buildertek__Category__c = masterBudget.buildertek__Category__c;
                     BudgetItem.buildertek__Notes__c = masterBudget.buildertek__Notes__c;
                    BudgetItem.buildertek__Markup__c = masterBudget.buildertek__Markup__c;
                     BudgetItem.buildertek__RFQ__c = masterBudget.buildertek__RFQ__c;
                    BudgetItem.buildertek__Old_Pricing_Reuest_Id__c = masterBudget.id;
                    
                    BudgetItemist.add(BudgetItem);
                    system.debug('BudgetItemist'+BudgetItemist);
                }   
            }
            if(BudgetItemist.size() > 0){
                
                insert BudgetItemist;
                list<buildertek__Pricing_Request_Line_Details__c> pricingdetailList = new list<buildertek__Pricing_Request_Line_Details__c>();
                pricingrequestlinedetails = [SELECT Id, Name, buildertek__Pricing_Request_Line__c, buildertek__Cost__c, buildertek__Vendor__c, buildertek__Markup__c, buildertek__Price__c,buildertek__Multiplier__c,
                                             buildertek__Product__c, buildertek__Description__c, buildertek__Quantity__c FROM buildertek__Pricing_Request_Line_Details__c
                                             Where buildertek__Pricing_Request_Line__c IN: pricingrequestids];
                for(buildertek__Pricing_Request_Line__c prlineRec : BudgetItemist){
                    for(buildertek__Pricing_Request_Line_Details__c oldpredetaillineRec : pricingrequestlinedetails){
                        if(prlineRec.buildertek__Old_Pricing_Reuest_Id__c == oldpredetaillineRec .buildertek__Pricing_Request_Line__c){
                            buildertek__Pricing_Request_Line_Details__c newpricingdetalRec = new buildertek__Pricing_Request_Line_Details__c();
                            newpricingdetalRec.buildertek__Pricing_Request_Line__c = prlineRec.Id;
                            newpricingdetalRec.buildertek__Cost__c = oldpredetaillineRec.buildertek__Cost__c;
                            newpricingdetalRec.buildertek__Vendor__c = oldpredetaillineRec.buildertek__Vendor__c;
                            newpricingdetalRec.buildertek__Markup__c = oldpredetaillineRec.buildertek__Markup__c;
                            newpricingdetalRec.buildertek__Product__c = oldpredetaillineRec.buildertek__Product__c;
                            newpricingdetalRec.buildertek__Description__c = oldpredetaillineRec.buildertek__Description__c;
                            newpricingdetalRec.buildertek__Quantity__c = oldpredetaillineRec.buildertek__Quantity__c;
                            newpricingdetalRec.buildertek__Multiplier__c = oldpredetaillineRec.buildertek__Multiplier__c;
                            pricingdetailList.add(newpricingdetalRec);
                        }
                    }
                }
                if(pricingdetailList.size() > 0){
                    insert pricingdetailList;   
                }
                
                msg.Status = 'Success';
                msg.Message = 'PRL Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no PRL for the selected PRLD';    
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
    

     public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__Pricing_Request_Line__c budgetRecord {get;set;}
        
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }

}