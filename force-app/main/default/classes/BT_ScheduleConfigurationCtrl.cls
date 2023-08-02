public class BT_ScheduleConfigurationCtrl {
	public Boolean isScheduleImportEnabled{get;set;}
   /* public BT_ScheduleConfigurationCtrl(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Enable_Schedule_Items_Import__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];
        isScheduleImportEnabled = adminInterfaceNodeConfigurations.buildertek__Enable_Schedule_Items_Import__c;
    }
     public void onSave(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Enable_Schedule_Items_Import__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Enable_Schedule_Items_Import__c = isScheduleImportEnabled;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }*/
}