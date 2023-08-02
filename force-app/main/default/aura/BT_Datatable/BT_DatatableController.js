({
	initializeData: function (component, event, helper) {
		
		var objectName, filterConditions, fieldSetName;
    	objectName = component.get("v.objectName");
        filterConditions = component.get("v.filterConditions");
        fieldSetName=component.get("v.fieldSetName");
        
		helper.getGidDataRecords(component, event, helper, objectName, filterConditions, fieldSetName, function(){
	        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
    	});
	}
})