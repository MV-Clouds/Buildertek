({
	importMasterContinuaionSheets : function(component, event, helper){
        var RecordId =  component.get("v.recordId");
        var action = component.get("c.getmasterContinuaionSheets");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null){
                    if(result.length > 2){
                        result = JSON.parse(result);
                        component.set("v.objInfo",result);
                    }
                    else{
                        component.set("v.objInfo",null);
                    }
                }
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
	},
    
    importContinuationItems: function(component, event, helper){
        component.set("v.Spinner", true);
        var Records = component.get("v.mainObjectId");
	    var rfqItems = component.get("v.objInfo");
	    var SubOptions = [];
	    for(var i=0 ; i < rfqItems.length;i++){
	        if(rfqItems[i].SubmittalCheck == true){
	            SubOptions.push(rfqItems[i].MasterRFQItem.Id);
	        }
	    }
	    if(SubOptions.length > 0){
	        component.set("v.selectedobjInfo",SubOptions);
	        var action = component.get("c.importContinuationSheetItems");
            action.setParams({
                Id : SubOptions,
                recordId : component.get("v.recordId")
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.Spinner", false);
                    
                    $A.get("e.force:closeQuickAction").fire();
                    
                   location.reload();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'Continuation Sheet Lines Successfiully Imported',
                        "type": 'Success'
                    });
                    toastEvent.fire();
                }
               
            }); 
            $A.enqueueAction(action);
        }
        if(SubOptions.length < 1){
             component.set("v.Spinner", false);
             var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Please Select a Continuation Sheet to Import',
                        "type": 'Error'
                    });
                    toastEvent.fire();
        }
	}
})