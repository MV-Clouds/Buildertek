@isTest
public class Clone_Quote_Controller_TC {
    static testMethod void cloneQuoteTestMethod() {
       buildertek__Quote__c quotecopy=new buildertek__Quote__c(); 
        quotecopy.Name='Test Quote';
        quotecopy.buildertek__Version_Number__c='2.5';
        quotecopy.buildertek__Reason_for_New_Version__c='Test Reason';
        insert quotecopy; 
        buildertek__Quote_Item__c quoteitem=new buildertek__Quote_Item__c();
        quoteitem.Name='Test Quote Item';
        //quoteitem.buildertek__Grouping__c='Change Order';
        quoteitem.buildertek__Quote__c=quotecopy.Id;
        insert quoteitem;
        Clone_Quote_Controller.cloneQuote(quotecopy.Id,quotecopy.buildertek__Version_Number__c,quotecopy.buildertek__Reason_for_New_Version__c);
        Clone_Quote_Controller.getQuote(quotecopy.Id);
    }
}