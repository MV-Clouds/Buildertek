({
    getAccountDetails: function (component, event, helper) {
        //'recordId': recordId+''
        var projectrecordId = component.get('v.projectrecordId');
        if (projectrecordId != undefined) {
            var action = component.get("c.getAccount");
            action.setParams({
                projectrecordId: projectrecordId+''
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.accountId', response.getReturnValue());
                } else if (state === "ERROR") {
                    console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action);
       }
    }
})