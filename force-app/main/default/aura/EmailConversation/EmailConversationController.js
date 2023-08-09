({
    doInit: function (component, event, helper) {
      
        component.set("v.Spinner", true);
        var currentRec = component.get("v.recordId");
        console.log('>>>>>>' + currentRec);
        helper.getEmailMessages(component, event, currentRec);
        helper.getRFIName(component, event, currentRec);
    },

    refreshList: function (component, event, helper) {
        $A.enqueueAction(component.get("c.doInit"));
    },

    openRecordPage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    showFullEmail: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        var options = component.get("v.openList");
        if (options.includes(recordId)) {
            var index = options.indexOf(recordId);
            if (index > -1) {
                options.splice(index, 1);
            }
        } else {
            options.push(recordId);
        }
        component.set("v.openList", options);
    },

    /*hideFullEmail : function(component, event, helper) {
        var recordId = component.get("v.lineItemId");
        var options = component.get("v.openList");
        var index = options.indexOf(recordId);
        alert('index -------> '+index);
        if (index > -1) {
          options.splice(index, 1);
        }
        alert('options --------> '+options);
        console.log(options); 
        component.set("v.openList", options);
    },*/

    handleSelect: function (component, event, helper) {
        component.set("v.Spinner", true);
        var selectedMenuItemValue = event.getParam("value");
        var action = component.get("c.deleteItems");
        action.setParams({
            recordId: selectedMenuItemValue
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var result = response.getReturnValue(); 
                $A.enqueueAction(component.get("c.doInit"));
            }

        });
        $A.enqueueAction(action);

    },

    replyEmailmsg: function (component, event, helper) {
        console.log('$$$$$$$$$');
        var emidrply = component.get("v.recordId");
        console.log('>>>>>>@@@' + emidrply);
        var repid = event.getSource().get("v.value")
        console.log(repid);
        helper.replyEmail(component, event, repid, emidrply);
    },
    handleEventCloseModelPopup: function (component, event, helper) {
        console.log('called handleEventCloseModelPopup');
        var overlayPanel = component.get('v.overlayPanel');
        //overlayPanel[0].close(); 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "Success",
            "message": "Email Sent successfully"
        });
        toastEvent.fire();

    },

})