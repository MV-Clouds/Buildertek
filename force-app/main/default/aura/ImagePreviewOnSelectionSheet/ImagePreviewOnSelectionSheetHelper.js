({
    getSelectionSheetRelatedCategories: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);

        var action = component.get("c.getSelectionCategories");

        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var selectionCategories = response.getReturnValue();
            console.log('selectionCategories--->',selectionCategories);
            if (selectionCategories != null) {
                selectionCategories.unshift({ Name: '---None---', Id: null });
                component.set("v.selectionCategories", selectionCategories);
            } else {
                console.error("Error fetching product files.");
            }
        });

        $A.enqueueAction(action);
    }
})