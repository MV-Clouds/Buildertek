@isTest
public  class NewResourceScheduleDashnoardClsTest {
    @TestSetup
    static void makeData(){
        buildertek__Trade_Type__c tradeType=new buildertek__Trade_Type__c();
        tradeType.Name='test';
        insert tradeType;

        Account account = new Account();
        account.Name = 'test';
        account.Phone = '32423123';
        account.buildertek__Trade_Type_Lookup__c=tradeType.Id;
        insert account;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'test';
        project.buildertek__Customer__c = account.Id;
        insert project;

    	buildertek__schedule__c schedule1 = new buildertek__schedule__c();
    	schedule1.Description__c = 'test';
    	schedule1.Type__c = 'Master';
    	schedule1.Project__c = project.Id;
    	insert schedule1;

        Contact c = new Contact();
        c.LastName = 'test';
        c.Email = 'test@gamil.com';
        c.AccountId=account.Id;
        c.buildertek__Simultaneous_Tasks__c=2;
        insert c;

        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask1.buildertek__Duration__c=10;
        projectTask1.buildertek__Phase__c='Candidate Selection';
        projectTask1.buildertek__Lag__c=0;
        projectTask1.buildertek__Milestone__c =false;
        projectTask1.buildertek__Contractor__c=account.Id;
        projectTask1.buildertek__Resource__c =c.Id;
        projectTask1.buildertek__Contractor_Resource__c  =c.Id;
        projectTask1.buildertek__Project__c  =project.Id;
        projectTask1.buildertek__Trade_Type__c  =tradeType.Id;
        insert projectTask1;
        
    }

    @isTest
    private static void testMethod1() {
        
        Contact c=[Select Id , Name From Contact LIMIT 1];
        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];
        buildertek__schedule__c scedule=[Select Id , buildertek__Project__c from buildertek__Schedule__c LIMIT 1];
        buildertek__Trade_Type__c tradeType=[Select Id ,Name from buildertek__Trade_Type__c LIMIT 1];

        Test.startTest();
        NewResourceScheduleDashnoardCls.getProjectId(scedule.Id);
        NewResourceScheduleDashnoardCls.getResourcesByProject( project.Id , c.Id , '12/15/15' , '12/15/15');
        NewResourceScheduleDashnoardCls.getScheduleItemsByProject('2021-02-31', '2025-02-31',tradeType.Id ,project.Id, c.Id, 'test' , 'test' , 'test');
        Test.stopTest();
        System.assert(project != null);
        System.assert(scedule != null);
        System.assert(c != null);

        
    }

    @isTest
    private static void testMethod2() {
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Testing Project';
        insert project;

        Contact c=[Select Id , Name From Contact LIMIT 1];
        buildertek__schedule__c scedule=[Select Id , buildertek__Project__c from buildertek__Schedule__c LIMIT 1];
        // List<buildertek__Project_Task__c> projectTask1=[Select Id , Name , buildertek__Schedule__c From  buildertek__Project_Task__c];
        Test.startTest();
        NewResourceScheduleDashnoardCls.getProjectId(scedule.Id);
        NewResourceScheduleDashnoardCls.getResourcesByProject( project.Id , c.Id , '01/24/15' , '12/12/30');
        NewResourceScheduleDashnoardCls.getScheduleItemsByProject('2021-02-31', '2025-02-31' ,'test' ,project.Id, c.Id, null , 'test' , 'test');

        NewResourceScheduleDashnoardCls.Wrapper wrapData = new NewResourceScheduleDashnoardCls.Wrapper();
        wrapData.recordId=c.Id;
        wrapData.Name='Test';
        wrapData.Tasks='test';
        wrapData.TradeType='test';

        NewResourceScheduleDashnoardCls.projectResourceWrapper projectWrapData = new NewResourceScheduleDashnoardCls.projectResourceWrapper();
        projectWrapData.projectRecName='Test';
        projectWrapData.projectRecId=project.Id;
        projectWrapData.projectRecAccName='test';
        projectWrapData.projectRecAccId='test';

        Test.stopTest();
        
        System.assert(project != null);
        System.assert(scedule != null);
        System.assert(c!= null);

        
    }

    

    @isTest
    private static void testMethod3() {
       
        Contact c=[Select Id , Name From Contact LIMIT 1];
        Test.startTest();
        NewResourceScheduleDashnoardCls.getScheduleItemsByProject('2021-02-31', '2025-02-31','test' , null, c.Id, null , 'test' , 'test');
        Test.stopTest();
    }

    @isTest
    private static void testMethod4() {
        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];
        Contact c=[Select Id , Name From Contact LIMIT 1];
        Test.startTest();
        NewResourceScheduleDashnoardCls.getScheduleItemsByProject('2021-02-31', '2025-02-31' ,'test' , project.id, c.Id, null , null , 'test');
        Test.stopTest();
        
    }
    
}