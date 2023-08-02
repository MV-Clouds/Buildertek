({
    doInit: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BT_MassUpdateQuote",
            componentAttributes: {
                recordId: component.get('v.recordId')
            }
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})