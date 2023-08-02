@isTest
public class QuotelineswithGroupingNamecontrollerTest {
    public static testMethod void testQuotelinegroupingdata() {
         Account account1 = new Account(
            Name = 'Sample Account 1'
        );
        
        insert account1;
        
        Contact contact1 = new Contact( 
            AccountId = account1.Id,
            LastName = 'LastName1'
        );
        
        insert contact1;
        
          buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
           // buildertek__Opportunity__c = opportunity1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        
            insert project;
			
        Product2 product = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        
            Insert product;
            
        buildertek__Quote__c quote = new buildertek__Quote__c(
            Name = 'Sample Quote',
          //  buildertek__Opportunity__c = opportunity1.Id,
            buildertek__Primary_Contact__c = contact1.Id,
          //  buildertek__Product__c = product.Id,
            buildertek__Project__c = project.id
        );
        
            insert quote;
			
        
       list<buildertek__Quote_Line_Group__c> grouplist = new list<buildertek__Quote_Line_Group__c>();
        buildertek__Quote_Line_Group__c GroupRef = new buildertek__Quote_Line_Group__c(Name='test');
        grouplist.add(GroupRef);
        insert GroupRef;
        List<buildertek__Quote_Item__c> quoteListRef = new List<buildertek__Quote_Item__c>();
       
        
        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
        quoteItem.Name = 'test';
        quoteItem.buildertek__Status__c = 'Accept';
        quoteItem.buildertek__Quote__c = quote.Id;
        quoteItem.buildertek__Grouping__c = GroupRef.Id;
        
        quoteListRef.add(quoteItem);
        insert quoteItem;
        string fieldsnames = 'Name,buildertek__Quote__c,buildertek__Net_Total_Price__c';
       
        
        QuotelineswithGroupingNameController quotelinewithgrouping = new QuotelineswithGroupingNameController();
        quotelinewithgrouping.queryfields = fieldsnames;
        quotelinewithgrouping.quoteid = quote.Id;
	   quotelinewithgrouping.Quotelinegroupingdata();
    }
}