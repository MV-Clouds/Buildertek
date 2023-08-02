({
    doInit: function (component, event, helper) {
        console.log('Call');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:DuplicateSSTLFromProducts",
            componentAttributes: {
                recordId: component.get('v.recordId')
            }
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})