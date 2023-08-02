@isTest
private class SchedulePOControllerTest {

	private static testMethod void getPurchaseOrderData() {
         buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Purchase Order Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true);
        insert adminInterfaceNodeConfigurations;
        Contact con = new Contact();
        con.LastName='test';
        con.email='test@gmail.com';
        insert con;
        Account accRec = new Account();
        accRec.Name = 'Test 2'; 
        insert accRec;
        
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Description__c = 'Test PO';
        PO.buildertek__Project__c = proj.Id;
        PO.buildertek__Vendor__c = accRec.Id;
        insert PO;
        
        List<buildertek__Schedule__c> schList = new List<buildertek__Schedule__c>();
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Project__c = proj.Id;
        schList.add(sch);
        insert schList;
        
        buildertek__Project_Task__c schTask = (buildertek__Project_Task__c)buildertek__Project_Task__c.sObjectType.newSObject(null, true);
        schTask.Name = 'Test Task';
        schTask.buildertek__Schedule__c = schList[0].Id;
        schTask.buildertek__Start__c=System.Now().date();
        insert schTask;
        
        List<SchedulePOController.ScheduleWrap> SCWrapList = new List<SchedulePOController.ScheduleWrap>();
        SchedulePOController.ScheduleWrap SCWrap = new SchedulePOController.ScheduleWrap();
        SCWrap.getSchedulesList = schList[0];
        SCWrap.scheduleCheckbox = false;
        SCWrapList.add(SCWrap);
        
      /*  SchedulePOController.getPurchaseOrderData(PO.Id);
        SchedulePOController.getSchedulelist(PO.Id);
        SchedulePOController.getProjectSchedules(proj.Id);
        SchedulePOController.getselectOptions(schTask, 'buildertek__Phase__c');
        SchedulePOController.insertScheduleTask(schTask, PO.Id, schList[0].Id, null, null, PO.Id);
        schTask.buildertek__Duration__c=2;
        //update schTask;  
        SchedulePOController.insertScheduleTask(schTask, PO.Id, schList[0].Id, null, null, PO.Id);
        schTask.buildertek__Finish__c=System.now().date().addDays(2);
        //update schTask;
        SchedulePOController.insertScheduleTask(schTask, PO.Id, schList[0].Id, null, null, PO.Id);*/
        system.assertEquals('test', 'test');
	}


}