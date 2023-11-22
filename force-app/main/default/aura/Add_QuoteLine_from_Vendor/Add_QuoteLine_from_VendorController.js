({
    doInit : function(component, event, helper) {
        var QuoteId = component.get("v.quoteId");
        console.log('QuoteId: ' + QuoteId);
        helper.getVendors(component, event, helper);
    },

    closeCmp : function(component, event, helper) {
        component.set("v.openProductBoxwithVendor", false);
     //    $A.get("e.force:closeQuickAction").fire() 
 
    },
})
