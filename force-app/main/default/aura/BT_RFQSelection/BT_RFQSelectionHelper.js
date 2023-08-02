({
    doSearchHelper : function(component, event, helper) {

        var quotId = component.get("v.quotId");
        var searchKeyword = component.get('v.searchKeyword');
        var searchProject = component.get('v.searchProject');
        var searchVendor = component.get('v.searchVendor');
        
        var action = component.get("c.getRFQSearch");
        action.setParams({			
            'quotId' : quotId,
            'searchKeyword' : searchKeyword,
            'searchProject' : searchProject,
            'searchVendor' : searchVendor
        });
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result ==> ',{result});
                result.forEach(element => {
                    if (element.buildertek__Vendor__c != null) {
                        element.vendorName = element.buildertek__Vendor__r.Name;
                    }
                    if (element.buildertek__Project__c != null) {
                        element.projectName = element.buildertek__Project__r.Name;
                    }
                });
                component.set("v.rfqs", result);  
            } else{
                var error = response.getError();
                console.log('Error =>',{error});
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": 'Error',
                    "type": 'Error',
                    "message": 'Something Went Wrong',
                    "duration": '5000'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})