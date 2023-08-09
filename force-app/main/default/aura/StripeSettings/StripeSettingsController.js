({
	doInit : function(component, event, helper) {
        //helper.getTemplates(component, event, helper);
		var action = component.get("c.getMSASettings");	
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.msaSettings", result);
            }   
        });
        $A.enqueueAction(action);
	},
    
    edit : function(component, event, helper) {
        component.set("v.isEdit", true);
    },
    
    save : function(component, event, helper) {
    	var action = component.get("c.saveSettings");
        action.setParams({
            msaSettings : component.get("v.msaSettings")   
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	component.set("v.isEdit", false);
                $A.enqueueAction(component.get("c.doInit"));  
            }    
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
    	component.set("v.isEdit", false);    
    },
    
})