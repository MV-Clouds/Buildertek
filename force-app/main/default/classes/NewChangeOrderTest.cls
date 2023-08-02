@isTest
public class NewChangeOrderTest {
    private static testMethod void getorder() {
        
         List<buildertek__Project__c> projList = new List<buildertek__Project__c>();
       buildertek__Project__c proj = new buildertek__Project__c();
     
        proj.Name = 'Test Project';
        proj.buildertek__Project_Id__c=proj.id;
        projList.add(proj); 
          try{
        insert projList;
        
        List<String> selectedIds = new List<String>();
        selectedIds.add(projList[0].Id);
         NewChangeOrder.getAccount(projList[0].Id);
        } 
catch (AuraHandledException qe ){
            //throw new AuraHandledException(e.getMessage());
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, qe.getMessage());
                ApexPages.addMessage(msg);
        }
       
}
}