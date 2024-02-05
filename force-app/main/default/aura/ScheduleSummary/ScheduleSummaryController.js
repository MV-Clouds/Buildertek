({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.loadTasks(component, recordId);
    },
})