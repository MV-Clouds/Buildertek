({
	doInit : function(component, event, helper) {
		var rid = component.get("v.recordId");
		
        var action = component.get("c.getKnowledgeArticleInfo");
        action.setParams({recordIds : rid });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var a = response.getReturnValue();
                //component.set('v.myMap',response.getReturnValue());
            	console.log(a.Phone__c);
                component.set("v.phone",a.Phone__c);
                component.set("v.hours",a.Hours__c);
                component.set("v.website",a.Website__c);
                
                
            }
        });
        $A.enqueueAction(action);

	}
})