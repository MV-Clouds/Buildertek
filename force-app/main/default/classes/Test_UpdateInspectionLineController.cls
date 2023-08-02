@isTest
public class Test_UpdateInspectionLineController {

    @isTest
    public static void test1(){
                   

        buildertek__Inspection__c insp = new buildertek__Inspection__c();
        insp.buildertek__Type_Clone__c = 'Master';
        insp.buildertek__Details__c = 'Test Detail';
        insp.buildertek__Name__c = 'Test Name';
        insert insp;

        List<Inspection_Line__c> inspList = new List<Inspection_Line__c>();
        Inspection_Line__c inspectionline = new Inspection_Line__c();
        inspectionline.buildertek__Inspection__c = insp.Id;
        inspList.add(inspectionline);
        insert inspList;
        
        PageReference pageRef = Page.UpdateInspectionLines;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(inspectionline.Id));

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(inspList);
        UpdateInspectionLineController testUpd = new UpdateInspectionLineController(sc);

        testUpd.save();
        testUpd.redirectURL();
    }
}