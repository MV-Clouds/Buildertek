({
    getRecords: function (component, event, helper) {
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var action = component.get("c.getPackageTakeoff");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.packageTakeOffList", result);
                component.set("v.totalRecords", component.get("v.packageTakeOffList").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.packageTakeOffList").length > i)
                        paginationList.push(result[i]);
                }
                component.set('v.paginationList', paginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    importPackage: function (component, event, helper, takeOffLinesIds) {
        var action = component.get("c.importPackageLines");
        action.setParams({
            takeOffLinesIds: takeOffLinesIds,
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.Status === 'Success') {
                    //helper.showToast(component, event, helper, 'Success!', result.Message, 'success');
                    component.set("v.Spinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            document.location.reload(true);
                        }), 1000
                    );
                } else {
                    component.set("v.Spinner", false);
                    helper.showToast(component, event, helper, 'Error!', result.Message, 'error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'sticky',
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})