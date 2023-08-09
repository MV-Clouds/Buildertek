({
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    getmulticur : function (component, event, helper) {
        var action = component.get("c.getmulticurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                  component.set("v.multicurrency",response.getReturnValue());
                //  component.set("v.multicurrency",false);
			} 
		});
		$A.enqueueAction(action);		
    },
	importMasterRFQItems : function(component, event, helper){
        var RecordId =  component.get("v.recordId");
        var action = component.get("c.getmasterRFQItems");
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
    
    importRFQItems: function(component, event, helper){
        component.set("v.Spinner", true);
        var Records = component.get("v.mainObjectId");
	    var rfqItems = component.get("v.objInfo");
	    var SubOptions = [];
       // alert(SubOptions);
        if(rfqItems != null){
	    for(var i=0 ; i < rfqItems.length;i++){
         // alert(rfqItems[i].SubmittalCheck );
	        if(rfqItems[i].SubmittalCheck == true){
	            SubOptions.push(rfqItems[i].MasterRFQItem.Id);
	        }
	    }
	    if(SubOptions.length > 0){
	        component.set("v.selectedobjInfo",SubOptions);
	        var action = component.get("c.importRFQItems");
            action.setParams({Id : SubOptions, RFQId : Records})
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.Spinner", false);
                    component.get("v.onSuccess")();  
                }
               
            }); 
            $A.enqueueAction(action);
        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error!',
                message: 'Please Select RFQ Item.',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }
        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error!',
                message: 'There is No Master RFQ Line',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
            
        }
	}
})