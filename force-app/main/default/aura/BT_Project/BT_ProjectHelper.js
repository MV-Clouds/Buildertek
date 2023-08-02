({
    getProjects: function (component, event, helper) {
        var action = component.get("c.getAllProjects");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var list = response.getReturnValue();
                for (var i in list) {
                    if (list[i].buildertek__Is_Expanded__c == undefined) {
                        list[i].buildertek__Is_Expanded__c = false;
                    }
                    list[i].buildertek__Is_Expanded__c = false;
                }
                component.set('v.listOfRecords', list);
                console.log('Response :: ', response.getReturnValue());
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                helper.showErrorToast(component, event, helper, 'Error!', 'Something went wrong!');
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '3000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})