public class TestQue {

    public static void main(){
          list<listview> allListViews=[SELECT DeveloperName, SObjectType FROM ListView Where SobjectType='buildertek__RFQ_To_Vendor__c'];
		System.debug(allListViews);
    }
}