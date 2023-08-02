@isTest
public class ImportmasterInspectionClassTest {
 
    public static testMethod void getBudgets() {
        
        buildertek__Inspection__c insp = new buildertek__Inspection__c();
        insp.buildertek__Type_Clone__c = 'Master';
        insp.buildertek__Details__c = 'Test Detail';
        insp.buildertek__Name__c = 'Test Name';
        insert insp;

        buildertek__Inspection_Line__c newinsp = new buildertek__Inspection_Line__c();
        newinsp.buildertek__Inspection__c = insp.Id;
        newinsp.buildertek__Status__c = 'Pending';
        newinsp.buildertek__Description__c = 'Testing Description';
        newinsp.buildertek__Comments__c = 'Testing Comments';
        insert newinsp;

        buildertek__Inspection_Line__c inspline = new buildertek__Inspection_Line__c();
        inspline.buildertek__Inspection__c = insp.Id;
        inspline.buildertek__Status__c = 'Pending';
        inspline.buildertek__Description__c = newinsp.buildertek__Description__c;
        inspline.buildertek__Comments__c = newinsp.buildertek__Comments__c;
        insert inspline;

        List<String> selectedIds = new List<String>();
        selectedIds.add(insp.Id);

        ImportmasterInspectionClass.getMasterInspection();
        ImportmasterInspectionClass.importMasterInspectionLines(selectedIds,insp.Id);


   }
}