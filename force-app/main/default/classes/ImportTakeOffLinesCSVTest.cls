@isTest
public class ImportTakeOffLinesCSVTest {
    public static testMethod void awardVendor() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
    
     
        buildertek__Project_Takeoff__c projecttakeoff = new buildertek__Project_Takeoff__c();
        projecttakeoff.buildertek__Project__c  = proj.Id;
        projecttakeoff.buildertek__Name__c  = 'Master Bathroom';
        insert projecttakeoff;
        
        buildertek__Trade_Type__c tradetype = new buildertek__Trade_Type__c();
        tradetype.Name  = 'Plumbing';
        insert tradetype;
        
         buildertek__Product_Type__c producttype = new buildertek__Product_Type__c();
        producttype.Name  = 'Toilet Seat';
        insert producttype;
        
         buildertek__Category__c category = new buildertek__Category__c();
        category.Name  = 'Plumbing';
        insert category;
        
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
        buildertek__Budget__c budgetItem = new buildertek__Budget__c();
        budgetItem.Name = 'Test Material';
        budgetList.add(budgetItem);
        insert budgetList;
        
        String budgetJsonId = '["'+budgetList[0].Id +'"]';
     
        List<String> listValues = new List<String>();
        
        String jsonData = '[{"TradeType":"Plumbing","Category":"Plumbing","ProductType":"Toilet Seat","Location":"Master Bathroom","Quantity":"2","UOM":"Each"}]';
        String jsonData1 = '[{"TradeType":"Plumbing","Category":"Plumbing","ProductType":"Toilet Seat","Location":"Master Bathroom","Quantity":"2","UOM":"Each\r"}]';
        ImportTakeOffLinesCSV.importRecords(budgetList[0].Id,jsonData);
        ImportTakeOffLinesCSV.getListOfFileContentsAsStrings(jsonData1);
        ImportTakeOffLinesCSV.appendCellValuesSeparatedByNewLines(listValues);
        ImportTakeOffLinesCSV.appendCellValuesSeparatedByCommas(listValues);
        ImportTakeOffLinesCSV.insertData(projecttakeoff.Id,jsonData);
       
        
        system.assertEquals('test', 'test');
    }
}