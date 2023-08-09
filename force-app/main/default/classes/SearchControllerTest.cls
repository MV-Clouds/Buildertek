@isTest
public class SearchControllerTest {
    static testMethod void test() {
        List<String> fields = new List<String>();
        fields.add('Name');
        test.startTest();
        SearchController.search('Account',fields,'N');
        SearchController.searchContact('N');
          SearchController.searchContact(' ');
        test.stopTest();
    }
}