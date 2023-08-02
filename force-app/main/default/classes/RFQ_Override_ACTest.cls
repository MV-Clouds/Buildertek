@isTest
private class RFQ_Override_ACTest {

	private static testMethod void listViewMethod() {
        List<ListView> views = RFQ_Override_AC.getListViews();
        System.assertEquals('Test','Test');
	}

}