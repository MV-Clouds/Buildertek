public class CheckListQuestionTriggerHandler {
    public void OnBeforeInsert(buildertek__Checklist_Questions__c[] newQuestion){
        List<string> qclist = new List<string>();
        Map<String,String> questionMap = new Map<String,String>();
        for(buildertek__Checklist_Questions__c qc:newQuestion){
            if(qc.buildertek__Questions__c != null){
                qclist.add(qc.buildertek__Questions__c);
                
            }
        }
        if(qclist.size()>0){
            List<buildertek__Questions__c> questionlist = [SELECT Id,buildertek__Customize__c from buildertek__Questions__c Where Id IN:qclist];
            for(buildertek__Questions__c qc:questionlist){
                questionMap.put(qc.Id,qc.buildertek__Customize__c);
            }
            
            for(buildertek__Checklist_Questions__c qc:newQuestion){
                qc.buildertek__Question__c = questionMap.get(qc.buildertek__Questions__c); 
                
            }
        }
        
        
    }
}