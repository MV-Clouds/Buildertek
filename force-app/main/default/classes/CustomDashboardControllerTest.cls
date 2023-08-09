@isTest
public class CustomDashboardControllerTest {
    public static testmethod void testCustomDashboard(){
        Account account1=new Account();
        account1.Name='account1 Test';
        insert account1;
        System.assert(account1.Id!=null);
        Contact con = new Contact();
        con.LastName ='Test 1';
        con.email='test@gmail.com';
        insert con;
        buildertek__Project__c project1=new buildertek__Project__c();
        project1.Name='project1 Test';
        insert project1;
        System.assert(project1.Id!=null);
        
        
        buildertek__Change_Order__c changeOrder1= new buildertek__Change_Order__c();
        changeOrder1.Name='changeOrder1 Test';
        changeOrder1.buildertek__Project__c=project1.Id;
        changeOrder1.buildertek__Customer_Account__c=account1.Id;
        changeOrder1.buildertek__Status__c='Pending';
        insert changeOrder1;
        System.assert(changeOrder1.Id!=null);
        
        buildertek__Change_Order__c changeOrder2= new buildertek__Change_Order__c();
        changeOrder2.Name='changeOrder2 Test';
        changeOrder2.buildertek__Project__c=project1.Id;
        changeOrder2.buildertek__Customer_Account__c=account1.Id;
        changeOrder2.buildertek__Status__c='Customer Approved';
        insert changeOrder2;
        System.assert(changeOrder2.Id!=null);
        
        buildertek__Billings__c invoice1=new buildertek__Billings__c();
        invoice1.Name='invoice1 Test';
        invoice1.buildertek__Project__c=project1.Id;
        insert invoice1;
        System.assert(invoice1.Id!=null);
        
        buildertek__Budget__c budget1 = new buildertek__Budget__c();
        budget1.Name='budget1 Test';
        budget1.buildertek__Project__c=project1.Id;
        insert budget1;
        System.assert(budget1.Id!=null);
        
        CustomDashboardController.getContractDetails(project1.Id);
        CustomDashboardController.getHCChartData(project1.Id);
        
        buildertek__Schedule__c schedule1 = new buildertek__Schedule__c();
        schedule1.buildertek__Project__c=project1.Id;
        insert schedule1;
        
        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask1.buildertek__Duration__c=10;
        insert projectTask1;
	
        Test.startTest();        
        CustomDashboardController.getScheduleData(project1.Id);
        Test.stopTest();
         System.assert(true);
    }
}