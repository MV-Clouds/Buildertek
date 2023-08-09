@isTest
public class SearchCompany_TC {
@testSetup
    static void accRecordsSetUp() {
        Account acc=new Account();
        acc.Name='Test Account';
        insert acc;
        
        Contact con=new Contact();
        con.LastName='Test Contact';
        con.FirstName='DFL';
        con.AccountId=acc.Id;
        con.Phone='001122334455';
        con.Email='test@gmail.com';
        insert con;
        
    }
    static testMethod void searchtestMethod() {
        SearchCompany.searchAccount('t');
        SearchController.searchContact('t');
    }
}