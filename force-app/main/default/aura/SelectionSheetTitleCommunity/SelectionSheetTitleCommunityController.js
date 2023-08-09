({
	doInit : function(component, event, helper) {
        debugger;
        console.log('Record Id ::',component.get('v.recordId'));
        var recordId = component.get('v.recordId');
        var action = component.get('c.getSelection');
        action.setParams({ "recordId" :recordId});
		action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
            	console.log('LOOG');
                component.set('v.recordName',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})