({
    init: function(component, event, helper) {
        var value = component.get("v._value");
        var text_value = component.get("v._text_value");
        var filter = component.get("v._filter");
        helper.initiateTargetSObject(component);
    },
    search: function(component, event, helper) {
        var value = event.target.value;
        //alert('value --------> '+value);
        if (value && value.length > 0) {
            helper.search(component, value);
        } else {
            component.set("v._value", null);
            component.set("v._text_value", '');
        }
    },
    itemSelected: function(component, event, helper) {
        console.log("event " + event);
        $A.util.removeClass(component.find("selectedlookUp"), "slds-show");
        component.set("v._value", event.target.id);
        component.set("v._text_value", event.target.title);
    },

    closeSelectBox: function(component, event, helper) {
        $A.util.removeClass(component.find("selectedlookUp"), "slds-show");
    },

    closeDropDown: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.removeClass(component.find("selectedlookUp"), "slds-show");
            }), 1000
        );

    },

    searchAll: function(component, value) {
        var objectName = component.get("v._target_sobject");
        console.log({ objectName });
        var action = component.get("c.getAllValues");
        action.setParams({
            "objectName": objectName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searchList", response.getReturnValue());
                var searchList = component.get("v.searchList");
                $A.util.addClass(component.find("selectedlookUp"), "slds-show");
            }
        });
        $A.enqueueAction(action);
    }

})