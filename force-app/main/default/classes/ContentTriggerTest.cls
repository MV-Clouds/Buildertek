@isTest
private class ContentTriggerTest {

	private static testMethod void test() {
        List<buildertek__Content__c> contentList = new List<buildertek__Content__c>();
        buildertek__Admin_Interface_Node_Configuration__c node = new buildertek__Admin_Interface_Node_Configuration__c();
        node.buildertek__Header_Text__c = 'Test Node';
        insert node;
        
        System.assert(node.Id!=null);
        
        buildertek__Content__c content = new buildertek__Content__c();
	    content.Name = 'Test Content';
	    content.buildertek__Admin_Interface_Node_Configuration__c = node.Id;
	    insert content;
	    
        System.assert(content.Id!=null);
        
	    content.Name = 'Test Content 1';
	    update content;
        System.assertEquals('Test Content 1', content.Name);

        
	}

}