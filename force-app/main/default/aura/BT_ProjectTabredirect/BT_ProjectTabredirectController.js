({
    gotoList : function (component, event, helper) {
        var action = component.get("c.getListViews");
         action.setParams({
            SobjectType: 'buildertek__Project__c'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": listviews.Name,
                    "scope": "buildertek__Project__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})