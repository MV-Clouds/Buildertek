({
    handleCloseAction: function(component, event, helper) {
        // Handle the event and close the quick action if needed
        // You can access event payload using event.getParam('payload')
        $A.get("e.force:closeQuickAction").fire();
    }
})
