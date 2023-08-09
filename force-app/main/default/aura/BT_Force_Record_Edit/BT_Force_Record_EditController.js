({
	doInit : function(component, event, helper) {
		if(component.get("v.newRecordId")){
			$A.createComponent("force:recordEdit",{
										            	"aura:id":"btEdit",
										                "recordId": component.get("v.newRecordId")
									                },
									                function(edit){
										               if (component.isValid()) {
										                   component.set("v.editComponent", edit);
										                   JQ$("#btforcerecordeditor").show();
										                }
										            }
										        );
		} else {
			component.find("newforcerecord").getNewRecord(
	            component.get("v.objectApi"), // objectApiName
	            null, // recordTypeId
	            false, // skip cache?
	            $A.getCallback(function() {
	                var rec = component.get("v.newRecord");
	                var error = component.get("v.newRecordError");
	                if(error || (rec === null)) {
	                    console.log("Error initializing record template: " + error);
	                } else {
	                	var defaultValue = component.get("v.defaultValue");
	                	var obj = component.get("v.sampleNewRecord");
	                	obj.Name = component.get("v.newRecordName");
	                    if(component.get("v.parentApi")) {
	                		obj[component.get("v.parentApi")] = component.get("v.parentId");
	                		
	                		//if(defaultValue && defaultValue.buildertek__Grouping__c)
	                		//obj.buildertek__Grouping__c = defaultValue.buildertek__Grouping__c;
	                		
	                		//for (var key in defaultValue){
							//    obj[key] = defaultValue[key];
							//}
	                		
	                    } 
	                    component.set("v.sampleNewRecord", obj);
			            component.find("newforcerecord").saveRecord(function(saveResult) {
			                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
			                	
			                	$A.createComponent("force:recordEdit",{
										            	"aura:id":"btEdit",
										                "recordId": saveResult.recordId
									                },
									                function(edit){
										               if (component.isValid()) {
										                   component.set("v.editComponent", edit);
										                   component.set("v.newRecordId", saveResult.recordId)
										                   JQ$("#btforcerecordeditor").show();
										                }
										            }
										        );
			                }
		                });
	                }
	            })
	        );
        }
	},
	cancelNewRecord : function(component, event, helper) {
		if(component.get("v.action") == 'NEW'){
			component.find("newforcerecord").deleteRecord($A.getCallback(function(deleteResult) {
	            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
	                console.log("Record is deleted.");
	            } else if (deleteResult.state === "INCOMPLETE") {
	                console.log("User is offline, device doesn't support drafts.");
	            } else if (deleteResult.state === "ERROR") {
	                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
	            } else {
	                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
	            }
	        }));
        }
		component.destroy();
        $A.get('e.force:refreshView').fire();
	},
	saveNewRecord : function(component, event, helper) {
		component.get("v.editComponent")[0].get("e.recordSave").fire();
    	$A.enqueueAction(component.get("v.saveCallBack"));
    	component.destroy();
        $A.get('e.force:refreshView').fire();
	}
})