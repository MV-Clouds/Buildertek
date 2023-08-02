@isTest
private class BT_DeleteScheduleControllerTest {

	private static testMethod void test() {
	    buildertek__Schedule__c scheRec = new buildertek__Schedule__c();
	    scheRec.buildertek__Primary_Schedule__c = true;
	    insert scheRec;
	    BT_DeleteScheduleController scheduleControllerRec = new BT_DeleteScheduleController();
        BT_DeleteScheduleController.deleteScheduleRecord(scheRec.Id);
        System.assertEquals(scheRec.buildertek__Primary_Schedule__c,true);
	}

}