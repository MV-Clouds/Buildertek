public class ServiceRequestAssigneeHandler{
    public static void UniqueSRAId(Map<Id,Service_Request_Assignee__c> oldMap,List<Service_Request_Assignee__c> lstSRA){
        for(Service_Request_Assignee__c objSRA : lstSRA){
            if(oldMap != null){
                if(oldMap.get(objSRA.Id).Employee__c != objSRA.Employee__c){
                    objSRA.Unique_Id__c = objSRA.Service_Request__c + '' + objSRA.Employee__c;
                }
            }
            else{
                objSRA.Unique_Id__c = objSRA.Service_Request__c + '' + objSRA.Employee__c;
            }
        }
    }
}