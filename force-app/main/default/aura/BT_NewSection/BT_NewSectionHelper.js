/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */
({
	/* Here add the additional fields in section record*/
	addAdditionalField : function(component,event) {
		var namespace = component.get("v.namespace");
        var eventFields = event.getParam("fields"); 
        if(eventFields['buildertek__Title__c']!=undefined){
            eventFields['Name']=eventFields['buildertek__Title__c'];
        }
        var sortId = component.get("v.sortId");
		var sectionObject = component.get("v.sectionObjectFields");
        sectionObject[namespace+'Sort_Id__c'] = '001';
        Object.assign(eventFields, sectionObject);
        event.setParam("fields", eventFields);
        component.set("v.section",eventFields);
	},
	
	/*Get the fields list form fieldset */
	getFieldSet : function(component) {
		var getFieldSet = component.get("c.getObjectFieldSet");
		getFieldSet.setParams({fieldSetName : "buildertek__Section_Fields",
								objectName:"buildertek__Section__c"});
		
		getFieldSet.setCallback(this,function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
				component.set("v.fields",response.getReturnValue());
			}
            console.log("fields::",response.getReturnValue());
		});
		$A.enqueueAction(getFieldSet);
	},
	
	/* Close the overlay library modal*/
	closePopup : function(component) {
		component.find("overlayLib").notifyClose();
	},
	
	/* This is close confirmation and other modal pop-up.*/
	closeModalPop : function(component) {
		component.get('v.modalPromise').then(function (modal) {
            modal.close();
        });
	},
	
	
	
	/* delete section record */
	deleteRecords : function(component,event,helper) {
        var section = component.get("v.section");
		var deleteRecord = component.get("c.deleteRecord");
		deleteRecord.setParams({recordId: section.Id});
		
		deleteRecord.setCallback(this, function(response){
			var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					    message: 'Selection Category" '+section.Name+' " was deleted.',
					    type: 'Success',
					});
					
					toastEvent.fire();
                    var onDelete = component.get("v.onDelete");
                    if (!!onDelete) {
                    	onDelete();
                    }
                    
                	helper.closeModalPop(component);
                	helper.closePopup(component);
                }
		});
		$A.enqueueAction(deleteRecord);
	}
})