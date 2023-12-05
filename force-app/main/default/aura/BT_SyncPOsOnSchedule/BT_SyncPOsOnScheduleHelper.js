({
    getAllScheduleItems: function (component, event, helper) {
        let action = component.get("c.fetchScheduleItem");
        let recordId = component.get("v.recordId");
        action.setParams({
            "scheduleId": recordId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.scheduleItemList", response.getReturnValue());
                console.log('scheduleItemList: ' + JSON.stringify(response.getReturnValue()));
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
        $A.enqueueAction(action);
    },

    getAllPOs: function (component, event, helper) {
        let action = component.get("c.fetchAllPOs");
        action.setParams({
            "searchKeyword": '',
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.poList", result);
                console.log('PO List: ' + JSON.stringify(result));
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
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

    saveSchedulePO: function (component, event, helper) {
        let selectedScheduleItems = component.get("v.selectedScheduleItems");
        let jsonSchedulePO = JSON.stringify(selectedScheduleItems);
        let action = component.get("c.setPOForScheduleItem");
        action.setParams({
            "schedulePO": jsonSchedulePO,
            "scheduleId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('result: ' + JSON.stringify(result));
                showToast('success', 'Success', 'POs are successfully synced', '3000');
                $A.get("e.force:closeQuickAction").fire();
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})