({
    getProductByProductFamily: function (component, event, helper) {
        var isPricebook = helper.checkIfPriceBookExists(component);
        if (!helper.checkIfPriceBookExists(component)) {
            helper.retrieveProductCandidatesByPFamily(component);
        }
    },
    //Get the Product Candidates from the search
    getProductCandidates: function (component, event, helper) {
        var isPricebook = helper.checkIfPriceBookExists(component);
        if (!helper.checkIfPriceBookExists(component)) {
            helper.retrieveProductCandidates(component);
        }
    },
    toggleFilterBar: function (component, event, helper) {
        var showFilterBar = component.get("v.showFilterBar");
        if (showFilterBar) {
            $A.util.removeClass(component.find("productFilterBar"), "slds-hide")
        } else {
            $A.util.addClass(component.find("productFilterBar"), "slds-hide")
        }
    },
    applyFilter: function (component, event, helper) {
        helper.search(component);
    },
    cancel: function (component, event, helper) {
        component.set("v._opportunity", new Object());
        if (!helper.checkIfPriceBookExists(component)) {
            helper.retrieveProductCandidates(component);
        }
    },

    close: function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    },

    parentComponentEvent: function (component, event, helper) {
        var message = event.getParam("OrderByProduct");
        //alert('message ---------> '+message);
        //Set the handler attributes based on event data 
        component.set("v.orderString", message);
        $A.enqueueAction(component.get('c.getProductCandidates'));
    }



})