@isTest
public class TestCloneWalkThroughController{
    @isTest
    static void myUnitTest1(){
        buildertek__Walk_Through_List__c walkThrough = new buildertek__Walk_Through_List__c();
        walkThrough.buildertek__Description__c = 'test';
        walkThrough.buildertek__Walk_Through_Date__c = System.today();
        walkThrough.buildertek__Notes__c = 'test notes';
        insert walkThrough;

        List<buildertek__Walk_Through_Line_Items__c> walkThrougLineList = new List<buildertek__Walk_Through_Line_Items__c>();
        buildertek__Walk_Through_Line_Items__c walkThroughLine1 = new buildertek__Walk_Through_Line_Items__c();
        walkThroughLine1.buildertek__Description__c = 'test description 1';
        walkThroughLine1.buildertek__Walk_Through_List__c = walkThrough.Id;
        walkThroughLine1.buildertek__Quantity__c = 1;
        walkThrougLineList.add(walkThroughLine1);

        buildertek__Walk_Through_Line_Items__c walkThroughLine2 = new buildertek__Walk_Through_Line_Items__c();
        walkThroughLine2.buildertek__Description__c = 'test description 2';
        walkThroughLine2.buildertek__Walk_Through_List__c = walkThrough.Id;
        walkThroughLine2.buildertek__Quantity__c = 1;
        walkThrougLineList.add(walkThroughLine2);

        insert walkThrougLineList;

        CloneWalkThroughController.cloneWalkThrough(walkThrough.Id);
    }

}