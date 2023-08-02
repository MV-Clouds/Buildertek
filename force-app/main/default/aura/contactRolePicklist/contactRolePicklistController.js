({
doinit : function(component, event, helper) {
    var action = component.get("c.getOpportunityContactRoles");
    //var oppId = component.get("v.opportunityRec");
    action.setParams({
        oppId : component.get("v.oppId")
    });
    action.setCallback(this, function(response){
            var result =response.getReturnValue();
        	console.log('In call back'+result);
            console.log(result);
            component.set("v.opportunityContactRoleRec",result);
    });
    $A.enqueueAction(action);
},
    
    getSelected : function(component, event, helper){
        console.log('In function');
    	var selectedVal = component.find("contactRole").get("v.value");
        console.log('selectedVal'+selectedVal);
        component.set("v.selectedContact",selectedVal);
	}
})