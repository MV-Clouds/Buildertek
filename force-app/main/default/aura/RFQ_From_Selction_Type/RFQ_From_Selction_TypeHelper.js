({
    getData: function (cmp, event, helper) {

        var recordId = cmp.get("v.recordId");
        var action = cmp.get('c.getOptionData');
        action.setParams({
            selectionTypeId: recordId,
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(element => {
                    if (element.buildertek__Manufacturer__c != null) {
                        element.ManufacturerName = element.buildertek__Manufacturer__r.Name;
                    }
                });
                cmp.set('v.myData', result);

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
})