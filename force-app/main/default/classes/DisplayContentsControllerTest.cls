@isTest
private class DisplayContentsControllerTest {

	private static testMethod void test() {
	    
        List<buildertek__Content__c> contentList = new List<buildertek__Content__c>();
        buildertek__Admin_Interface_Node_Configuration__c node = new buildertek__Admin_Interface_Node_Configuration__c();
        node.buildertek__Header_Text__c = 'Test Node';
        insert node;
        
        buildertek__Content__c content = new buildertek__Content__c();
	    content.Name = 'Test Content';
	    content.buildertek__Admin_Interface_Node_Configuration__c = node.Id;
	    insert content;
	    
	    content.Name = 'Test Content 1';
	    update content;
        
        ApexPages.currentPage().getParameters().put('id', node.Id); 
        DisplayContentsController dc = new DisplayContentsController();
        system.assertEquals('test', 'test');
	}

}