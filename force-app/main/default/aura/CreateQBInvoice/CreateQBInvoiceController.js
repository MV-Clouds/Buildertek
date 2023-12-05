({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");
        console.log(id);
        helper.createInvoice(component, event, helper);
    }
})