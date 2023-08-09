public class QuestionsTriggerHandler {
    
    public void OnAfterUpdate(buildertek__Questions__c[] oldQuestions, buildertek__Questions__c[] updatedQuestions, Map<ID, buildertek__Questions__c> QuestionsMap, Map<Id, buildertek__Questions__c> oldQuestionsMap){
         Map<String,String> questionMap = new Map<String,String>();
        List<string> questionIds = new List<string>(); 
        for(buildertek__Questions__c question:updatedQuestions){
            questionMap.put(question.Id,question.buildertek__Customize__c); 
            questionIds.add(question.Id);
            
        }
        List<buildertek__Checklist_Questions__c> checklistQuestion = [SELECT Id,
                                                                          Name,
                                                                          buildertek__Question__c,
                                                                          buildertek__Questions__c
                                                                          FROM buildertek__Checklist_Questions__c
                                                                          WHERE buildertek__Questions__c IN:questionIds];
        if(!checklistQuestion.isEmpty()) {
            for(buildertek__Checklist_Questions__c qc:checklistQuestion){
                if(qc.buildertek__Questions__c != null){
                    if(questionMap.get(qc.buildertek__Questions__c) != null){
                        qc.buildertek__Question__c = questionMap.get(qc.buildertek__Questions__c);
                    } 
                }
                
            }
        }
        if(!checklistQuestion.isEmpty()){
            update checklistQuestion;
        }
        

    }
    
}