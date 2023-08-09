@isTest 
public class ResourceScheduledashboardControllerTest {
    static testMethod void insertProjectTask() {
        Account accRec = new Account();
        accRec.Name = 'Test';
        accRec.buildertek__Email_Address__c = 'laxmantest@gmail.com';
        insert accRec;
        buildertek__Project__c pro = new buildertek__Project__c();
        pro.Name = 'Testproject';
        pro.buildertek__Account__c = accRec.id;
        insert pro;
        
        List<Contact> conListRec = new List<Contact>();
        Contact conRec = new Contact();
        conRec.LastName ='Test';
        conRec.AccountId =accRec.Id;
        conRec.email ='test@gmail.com';
        conListRec.add(conRec);
        insert conListRec;
        
        List<buildertek__Trade_Type__c> tradListRec = new List<buildertek__Trade_Type__c>();
        buildertek__Trade_Type__c tradRec = new buildertek__Trade_Type__c();
        tradRec.Name = 'Test';
        tradListRec.add(tradRec);
        insert tradListRec;
        
        buildertek__Schedule__c scheRec = new buildertek__Schedule__c();
        scheRec.buildertek__Project__c = pro.Id;
        scheRec.buildertek__Contractor__c =accRec.Id;
        insert scheRec;
        List<buildertek__Project_Task__c> projectTaskListRec = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c projectTaskRec = new buildertek__Project_Task__c();
        projectTaskRec.Name ='Test';
        projectTaskRec.buildertek__Contractor_Resource__c = conRec.Id;
        projectTaskRec.buildertek__Original_Start_Date__c = system.today();
        projectTaskRec.buildertek__Original_End_Date__c =system.today()+10;
        projectTaskRec.buildertek__Schedule__c =scheRec.Id;
        projectTaskRec.buildertek__Start__c = system.today();
        projectTaskListRec.add(projectTaskRec);
        //insert projectTaskListRec;
        //string.parse(system.today()),string.parse(system.today())
        ResourceScheduledashboardController RSDCRec = new ResourceScheduledashboardController();
        ResourceScheduledashboardController.getAllProjectTaskscontacts(new List<String>{projectTaskListRec[0].id});
        //ResourceScheduledashboardController.getWeekRecords('09/21/2020','09/27/2020',tradListRec[0].id,projectTaskListRec[0].id,conListRec[0].id);
        ResourceScheduledashboardController.Wrapper.getAllResourcess(new List<String>{conListRec[0].id});
    }
}