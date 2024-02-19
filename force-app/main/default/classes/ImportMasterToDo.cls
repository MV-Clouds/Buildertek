public with sharing class ImportMasterToDo{
	@AuraEnabled
	public Static MessageClass getAllMaseterRecords(String recordId, String searchKeyword){
		MessageClass msg = new MessageClass();
		try {
			List<buildertek__To_Do__c> toDoList = [SELECT Id, Name, buildertek__Project__c,buildertek__Project__r.Name, buildertek__Description__c, 
											buildertek__Additional_Details__c, buildertek__Assigned_To__c, buildertek__Due_Date__c, 
											buildertek__Status__c, buildertek__Priority__c, buildertek__Assigned_Vendor__c, buildertek__Date_Completed__c, 
											buildertek__Schedule_Item__c, buildertek__Type__c, buildertek__Customer_Account__c, buildertek__Customer_Account__r.Name,
											buildertek__Assigned_Vendor__r.Name
		                                   FROM buildertek__To_Do__c
		                                   WHERE buildertek__Type__c = 'Master' AND ID != :recordId];
			List<buildertek__To_Do__c> listtosend = new List<buildertek__To_Do__c>();
			for (buildertek__To_Do__c todo : toDoList) {
				if ((todo.buildertek__Description__c != null && todo.buildertek__Description__c.containsIgnoreCase(searchKeyword)) ||
				(todo.buildertek__Customer_Account__r.Name != null && todo.buildertek__Customer_Account__r.Name.containsIgnoreCase(searchKeyword)) ||
				(todo.buildertek__Assigned_Vendor__r.Name != null && todo.buildertek__Assigned_Vendor__r.Name.containsIgnoreCase(searchKeyword))) {
					listtosend.add(todo);
				}
			}								   
			if (listtosend.size() > 0){
				msg.Status = 'Success';
				msg.Message = '';
				msg.returnToDoList = listtosend;
			} else {
				msg.Status = 'Fail';
				msg.Message = 'No record Found';
				msg.returnToDoList = null;
			}
		} catch (Exception e) {
			List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            msg.Status = 'Fail';
			msg.Message = e.getMessage();
			msg.returnToDoList = null;
		}
		return msg;
	}

	@AuraEnabled
	public static MessageClass importToDoRecords(String recordId, List<String> selectedRecordId){
		MessageClass msg = new MessageClass();
		try{
			List<buildertek__To_Do_Items__c> toDoItems = [SELECT buildertek__Description__c, buildertek__Additional_Details__c, buildertek__Assigned_To__c, buildertek__Assigned_Vendor__c, buildertek__Status__c, buildertek__Priority__c, buildertek__Due_Date__c, buildertek__Date_Completed__c
			                                              FROM buildertek__To_Do_Items__c
			                                              WHERE buildertek__To_Do__c In :selectedRecordId];

			for (buildertek__To_Do_Items__c item : toDoItems){
				item.Id = null;
				item.buildertek__To_Do__c = null;
				item.buildertek__To_Do__c = recordId;
			}
			if (toDoItems.size() > 0){
				insert toDoItems;
				msg.Status = 'Success';
				msg.Message = '';
				msg.returnToDoList = null;
			} else {
				msg.Status = 'Fail';
				msg.Message = 'No Items are there it import.';
				msg.returnToDoList = null;
			}
		} catch (Exception e){
			List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            msg.Status = 'Fail';
			msg.Message = e.getMessage();
			msg.returnToDoList = null;
		}
		return msg;
	}

	public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
		@AuraEnabled
        public List<buildertek__To_Do__c> returnToDoList {get;set;}
        
    }
}