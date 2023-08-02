@isTest
public class createCO_selectionType_Test {

    @TestSetup
    static void testData(){

        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();

        // buildertek__Change_Order__c changeOrder = new buildertek__Change_Order__c();
        // changeOrder.Name = 'Test';
        // changeOrder.buildertek__Details__c = 'Details Testing';
        // changeOrder.buildertek__Due_Date__c = System.today().addDays(2);
        // changeOrder.buildertek__Status__c = 'Pending';
        // changeOrder.buildertek__Type__c = 'Customer';
        // insert changeOrder;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Test Project';
        insert project;

        buildertek__Selection__c selectionSheet = new buildertek__Selection__c();
        selectionSheet.Name = 'selectionSheet Testing';
        selectionSheet.buildertek__Project__c = project.Id;

        buildertek__Section__c selectionCategory = new buildertek__Section__c();
        selectionCategory.Name = 'selectionCategory Testing';
        selectionCategory.buildertek__Selection__c = selectionSheet.Id;

        buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
        selectionType.Name = 'Testing';
        selectionType.buildertek__Section__c = selectionCategory.Id;
        insert selectionType;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Testing 1';
        // option.buildertek__Change_Order__c = changeOrder.Id;
        option.buildertek__Quantity__c = 1;
        option.buildertek__Upgrade_Costs__c = 200;
        option.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__Upgrade__c = true;
        option.buildertek__Change_Order__c = null;
        optionList.add(option);

        buildertek__Question__c option1 = new buildertek__Question__c();
        option1.Name = 'Testing 2';
        // option1.buildertek__Change_Order__c = changeOrder.Id;
        option1.buildertek__Quantity__c = 4;
        option1.buildertek__Upgrade_Costs__c = 400;
        option1.buildertek__Question_Group__c = selectionType.Id;
        option1.buildertek__Upgrade__c = true;
        option1.buildertek__Change_Order__c = null;
        optionList.add(option1);
        insert optionList;

    }

    @IsTest
    static void testMethod1(){
        
        // buildertek__Change_Order__c changeOrder = [SELECT Id,Name,buildertek__Details__c, buildertek__Date_Created__c, buildertek__Status__c, buildertek__Type__c, buildertek__Due_Date__c FROM buildertek__Change_Order__c LIMIT 1];
        buildertek__Question_Group__c selectionType = [SELECT Id,Name FROM buildertek__Question_Group__c LIMIT 1];
        List<buildertek__Question__c> optionLs = new List<buildertek__Question__c>();
        optionLs = [SELECT Id, Name, buildertek__Change_Order__c, buildertek__Quantity__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c, buildertek__Question_Group__c ,buildertek__Upgrade_Costs__c, buildertek__Upgrade__c FROM buildertek__Question__c where buildertek__Question_Group__c =:selectionType.Id and buildertek__Change_Order__c=null]; 
        System.assertNotEquals(null,selectionType.Id,'selection id should not be null');
        Test.startTest();
        buildertek__Change_Order__c changeOrder = new buildertek__Change_Order__c();
            changeOrder.Name = 'Test';
            changeOrder.buildertek__Details__c = 'Details Testing';
            changeOrder.buildertek__Due_Date__c = System.today().addDays(2);
            changeOrder.buildertek__Status__c = 'Pending';
            changeOrder.buildertek__Type__c = 'Customer';
            // createCO_selectionType.changeOptionList(changeOrder, selectionType.Id);
            createCO_selectionType.getOptionData(selectionType.Id);
            createCO_selectionType.createCO(changeOrder, optionLs);
            createCO_selectionType.getOptionAllData(selectionType.Id);
        Test.stopTest();
        
    }
    
}