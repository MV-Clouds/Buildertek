({
	doInit : function(component, event, helper) {
        //alert(component.get("v.recordId"));
		var action = component.get("c.getFileData");
        action.setParams({
            "recordId" : component.get("v.recordId")
         }); 
        action.setCallback(this, function(response){
            var state = response.getState();
           debugger;
            //alert(JSON.stringify(response.getError()));
            
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.wrapperList",response.getReturnValue());
                console.log(JSON.stringify(result));
            }
         });
        $A.enqueueAction(action); 
	},
    onclick : function(component, event, helper) {

        //alert(event.target.id);
        var action = component.get("c.downloadFile");
        action.setParams({
            "fileId" : event.target.id
         });
            action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                window.open(result);
            }
         });
        $A.enqueueAction(action);         
    }
    
})