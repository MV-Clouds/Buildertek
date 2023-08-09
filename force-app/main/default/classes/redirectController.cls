public class redirectController {
    
    public pagereference redirectToPackageLine(){
        
       string viewid =   [SELECT Id,Name FROM ListView WHERE SObjectType = 'buildertek__Package_Line__c' and name = 'All Package Lines'].id;
      string objectprefx =  buildertek__Package_Line__c.sobjecttype.getDescribe().getKeyPrefix();
      
      PageReference ref = new PageReference('/'+objectprefx+'?fcf='+viewid);
      
        return ref;
    }

}