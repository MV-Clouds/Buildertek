({
	doInit : function(component, event, helper) {
		var action = component.get("c.getProjects");
		action.setParams({
			projectId: component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var projects = response.getReturnValue();
				console.log(projects);
				component.set("v.projects", projects);
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},

	handleChange : function(component, event, helper) {
		
	},
    handleClick:function(component, event, helper) {
        var itemsToclonned = component.get("v.value");
		var projects = component.get("v.projects");
		var countyText;
		if(projects[0].buildertek__County_Text__c != null){
			countyText = projects[0].buildertek__County_Text__c;
		}
		if(itemsToclonned){
            itemsToclonned = component.get("v.recordId")+'~'+itemsToclonned ;
        }else {
            itemsToclonned = '';    
        }
        
		var evt = $A.get("e.force:createRecord");
	        evt.setParams({
	            'entityApiName':'buildertek__Project__c',
	            'defaultFieldValues': {
	                'buildertek__Source_Project__c':itemsToclonned,
					'buildertek__County_Text__c':countyText
	            }
	        });
	        evt.fire();
	},
})