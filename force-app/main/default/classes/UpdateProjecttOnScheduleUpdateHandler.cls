global with sharing class UpdateProjecttOnScheduleUpdateHandler  {
    public void updateProjectList(List<buildertek__Project__c> updateprojectListFromschedule){
        System.debug('*** updateProjectList ***');
        updateProjectDataInner handler = new updateProjectDataInner(); 
        handler.updateProjectListInnerMethod(updateprojectListFromschedule);
      
    }
    
    public void updateProjectList_New(List<buildertek__Project__c> updateprojectListFromschedule){
        System.debug('*** updateProjectList_New ***');
        updateProjectDataInner handler = new updateProjectDataInner(); 
        handler.updateProjectListInnerMethod_New(updateprojectListFromschedule);
      
    }
    
    /**
     * WITHOUT SHARING USED:
     * =====================
     * 
     */ 
    public without sharing class updateProjectDataInner{
        public void updateProjectListInnerMethod(List<buildertek__Project__c> updateprojectListFromscheduleClone){
            System.debug('*** updateProjectListInnerMethod ***');
            if(updateprojectListFromscheduleClone.size() > 0){
                update updateprojectListFromscheduleClone;
            }
            
        }
        public void updateProjectListInnerMethod_New(List<buildertek__Project__c> updateprojectListFromscheduleClone){
            System.debug('*** updateProjectListInnerMethod_New ***');
            if(updateprojectListFromscheduleClone.size() > 0){
                update updateprojectListFromscheduleClone;
            }
            
        }
    }
    
    }
    
    

/*public without sharing class UpdateProjecttOnScheduleUpdateHandler {
    public void updateProjectList(List<buildertek__Project__c> updateprojectListFromschedule){
        if(updateprojectListFromschedule.size() > 0)
            update updateprojectListFromschedule;
    }
}*/