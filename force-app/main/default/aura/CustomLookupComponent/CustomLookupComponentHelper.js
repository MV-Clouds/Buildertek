({
	searchHelper : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var strSearch = component.get("v.strSearch");
        
        var action = component.get("c.getLookupData");
        action.setParams({
            'strObject' : sObjectName,
            'strSearch' : strSearch
        });
        
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                if(storeResponse.listSearchObjects.length == 0) {
                    component.set("v.strMessage", 'No Result Found...');
                }
                else {
                    component.set("v.strMessage", '');
                }
                
                component.set("v.listOfSearchRecords", storeResponse.listSearchObjects);
            }
        });
        
        $A.enqueueAction(action);
	}
})