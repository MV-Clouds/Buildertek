({
    getAccountId : function(component, userId) {
        console.log('RelatedTasksVendorSiteHelper > getTasks > userId: ' + userId);
        var action = component.get("c.getAccountId");
        action.setParams({
            "userId": userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('AccountId >: ' + response.getReturnValue());
                component.set("v.accountId", response.getReturnValue());
                this.getTasks(component, response.getReturnValue());
            }
            else {
                console.log('RelatedTasksVendorSiteHelper > getTasks > state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },

    getTasks : function(component, accountId) {
        console.log('RelatedTasksVendorSiteHelper > getTasks > accountId: ' + accountId);
        var action = component.get("c.getTasks");
        action.setParams({
            "accountId": accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                console.log("Tasks 1----->", JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.tasks", response.getReturnValue());
            }
            else {
                console.log('RelatedTasksVendorSiteHelper > getTasks > state: ' + state);
            }
        });
        $A.enqueueAction(action);
    }
})
