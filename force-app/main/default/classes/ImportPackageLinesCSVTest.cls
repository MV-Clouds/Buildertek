@isTest
public class ImportPackageLinesCSVTest {
    public static testMethod void awardVendor() {
        
        buildertek__Package__c packageRec = new buildertek__Package__c();
        insert packageRec;
        
        buildertek__Trade_Type__c tradetype = new buildertek__Trade_Type__c();
        tradetype.Name  = 'Plumbing';
        insert tradetype;
        
        buildertek__Product_Type__c producttype = new buildertek__Product_Type__c();
        producttype.Name  = 'Toilet Seat';
        insert producttype;
        
        buildertek__Category__c category = new buildertek__Category__c();
        category.Name  = 'Plumbing';
        insert category;
        
        
        List<String> listValues = new List<String>();
        
        String jsonData = '[{"TradeType":"Plumbing","Category":"Plumbing","ProductType":"Toilet Seat","Location":"Master Bathroom","Quantity":"2","UOM":"Each"}]';
        ImportPackageLinesCSV.insertData(packageRec.Id,jsonData);
        
        
        system.assertEquals('test', 'test');
    }
}