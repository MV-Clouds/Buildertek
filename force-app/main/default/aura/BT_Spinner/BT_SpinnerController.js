({
    spinner: function (component, event, helper) {
        var action = event.getParam("action");
        var spinner = component.find("BTSpinner");
        if(action == 'SHOW') {
            $A.util.addClass(spinner, 'slds-show');
            $A.util.removeClass(spinner, 'slds-hide');
        } else {
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.removeClass(spinner, 'slds-show');
        }
    }
})