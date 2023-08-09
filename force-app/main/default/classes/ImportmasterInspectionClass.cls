public with sharing class ImportmasterInspectionClass {

    @AuraEnabled
    public static object getMasterInspection(){

        //Inspection List
        list<buildertek__Inspection__c> masterInspectionList;
        If(Schema.sObjectType.buildertek__Inspection__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Inspection__c.fields.Id.isAccessible() &&
              Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Type_Clone__c.isAccessible()) {
                masterInspectionList = [SELECT Id, Name, buildertek__Type_Clone__c, buildertek__Details__c, buildertek__Name__c FROM buildertek__Inspection__c 
                                            WHERE buildertek__Type_Clone__c = 'Master'
                                            ORDER BY Name
                                            ASC limit 50000]; 
              } 
                                                                        
        List<MasterInspectionClass> MasterInspectionClassList = new List<MasterInspectionClass>();
        for(buildertek__Inspection__c masterInspection : masterInspectionList){
            MasterInspectionClass MasterInspectionClassRecord = new MasterInspectionClass(); 
            MasterInspectionClassRecord.masterInspectionRecord = masterInspection;
            MasterInspectionClassRecord.inspectionCheck = false;
            MasterInspectionClassList.add(MasterInspectionClassRecord);
        }
        return  MasterInspectionClassList;                                         
    }
    
    @AuraEnabled
    public static MessageClass importMasterInspectionLines(List<String> inspectionIds, String recordId){
        MessageClass msg = new MessageClass();
        try{

            List<buildertek__Inspection__c> inspelst = [SELECT Id, Name, buildertek__Type_Clone__c, buildertek__Details__c  FROM buildertek__Inspection__c WHERE Id =: inspectionIds];
            System.debug('inspelst--->'+inspelst);

            List<buildertek__Inspection_Line__c> insplinelst = [SELECT Id, Name, buildertek__Inspection__c, buildertek__Date_Inspected__c, buildertek__Date_Inspection_Due__c, buildertek__Description__c, buildertek__Comments__c, buildertek__Date_Reinspected__c, buildertek__Status__c FROM buildertek__Inspection_Line__c WHERE buildertek__Inspection__c =: inspectionIds];

            List<buildertek__Inspection_Line__c> newinslst = new List<buildertek__Inspection_Line__c>();
            for (buildertek__Inspection_Line__c ins : insplinelst) {
                buildertek__Inspection_Line__c newinsp = new buildertek__Inspection_Line__c();
                newinsp.buildertek__Inspection__c = recordId;
                newinsp.buildertek__Status__c = 'Pending';
                newinsp.buildertek__Description__c = ins.buildertek__Description__c;
                newinsp.buildertek__Comments__c = ins.buildertek__Comments__c;
                newinslst.add(newinsp);
            }
            if (newinslst.size() > 0) {
                insert newinslst;
                msg.Status = 'Success';
                msg.Message = 'Inspection Lines Imported Successfully';
            } else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Inspection Lines for the selected Inspection';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
    public class MasterInspectionClass{
         @AuraEnabled
         public buildertek__Inspection_Line__c inspectionRecord {get;set;}
         @AuraEnabled
         public buildertek__Inspection__c masterInspectionRecord {get;set;}
         @AuraEnabled
         public boolean inspectionCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 
}