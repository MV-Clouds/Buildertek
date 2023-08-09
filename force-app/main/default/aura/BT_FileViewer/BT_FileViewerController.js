({
	init : function(component, event, helper) {
		var fileids = component.get("v.fileids");
		if(fileids) {
			var files = fileids.split(',');
			var action = component.get("c.getFiles");
	        action.setParams({fileIds : files});
	        
	        action.setCallback(this,function(response){
	            var state = response.getState();
	            if(state === "SUCCESS"){
	                component.set("v.files",response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
		}
	}
})