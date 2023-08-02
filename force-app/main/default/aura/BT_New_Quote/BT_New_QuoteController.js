({
	doInit : function(component, event, helper) {
	    
	    console.log("newquote");
	    
	   var action = component.get("c.getProjectDetails");
       action.setParams({ "get_accountid": component.get("v.recordId") });
       
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var projectvalues = response.getReturnValue();
                console.log(response.getReturnValue());
                console.log(projectvalues.buildertek__Address__c);
                var evt = $A.get("e.force:createRecord");
                evt.setParams({
                    'entityApiName':'buildertek__Quote__c',
                    'defaultFieldValues': {
                        'buildertek__Project__c':component.get("v.recordId"),
                        'buildertek__Ship_To_City__c':projectvalues.buildertek__City__c,
                        'buildertek__Ship_To_Name__c':projectvalues.Name,
                        'buildertek__Ship_To_State__c':projectvalues.buildertek__State__c,
                        'buildertek__Ship_To_Street__c':projectvalues.buildertek__Address__c,
                        'buildertek__Ship_To_Zip_Code__c':projectvalues.buildertek__Zip__c 
                    }
                    //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
                });
                evt.fire();
            }else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
       $A.enqueueAction(action);
    },
    
    doneRendering: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})