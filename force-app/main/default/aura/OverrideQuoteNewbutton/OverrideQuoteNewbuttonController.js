({
    doInit : function(component, event, helper) {
	    
	    console.log("newquote");
	   
	   var action = component.get("c.getOpportunityDetails");
       action.setParams({ "recordId": component.get("v.recordId") });
       
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var projectvalues = response.getReturnValue();
                console.log(projectvalues.buildertek__Address__c);
                component.set("v.quotedefaultvalues",JSON.stringify(projectvalues));
                 
                var evt = $A.get("e.force:createRecord");
                evt.setParams({
                    'entityApiName':'buildertek__Quote__c',
                    'defaultFieldValues': {
                        'buildertek__Opportunity__c':component.get("v.recordId"),
                        'buildertek__Bill_To_Email_Address__c' : projectvalues.accemail,
                        'buildertek__Bill_To_Cell_Phone__c' : projectvalues.accphone,
                        'Name' : projectvalues.OppName,
                        'buildertek__Bill_To_Name__c' : projectvalues.BillingName,
                        'buildertek__Bill_To_City__c': projectvalues.Billingcity,
                        //'buildertek__Bill_To_Country__c':projectvalues.Billingcountry,
                        'buildertek__Bill_To_State__c' : projectvalues.Billingstate,
                        'buildertek__Bill_To_Street__c' :projectvalues.Billingstreet,
                        'buildertek__Bill_To_Zip_Code__c':projectvalues.Billingpostalcode
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
    },
	myAction : function(component, event, helper) {
		
	}
})