({
	doInit: function(component, event, helper) {
        // Retrieve the Purchase Order record from the component
        helper.init(component);
        console.log('Init');
        // var purchaseOrder = component.get("v.record.buildertek__Status__c");
        // console.log(purchaseOrder);
        // if (purchaseOrder === 'Paid') {
        //     // Stop further execution and display a message (optional)
        //     console.log('Purchase Order is already paid. Execution stopped.');
        //     return;
        // }
    }
})