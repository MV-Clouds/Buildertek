@isTest
public class BT_CircularProgressControllerTest {

     @testSetup static void insertTestData(){
        //insert account
        Account account = new Account(Name='Test Account');
        insert account;
        Opportunity opp = new Opportunity(Name='Opp',StageName='Won',CloseDate=Date.today(), Account=account, Amount=100);
        insert opp;
        System.assertEquals('Test','Test');
    }
    
     static testMethod void testController(){
         Opportunity opp = [SELECT Name,Id, Amount, ExpectedRevenue FROM Opportunity WHERE Name = 'Opp' LIMIT 1 ];
         String Response = BT_CircularProgressController.computePercentage('Opportunity', opp.Id, 'ExpectedRevenue', 'Amount');
         String ResponseElse = BT_CircularProgressController.computePercentage('Opportunity', opp.Id, 'Amount', 'ExpectedRevenue');
         String Response2 = BT_CircularProgressController.computePercentage('Opportunity', opp.Id, '', 'Amount');
         String ResponseCatch = BT_CircularProgressController.computePercentage('Opportunity', opp.Id, '', 'WrongField');
         System.assertEquals('Test','Test');
     }
}