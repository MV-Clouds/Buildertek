({
    doInit:function(component, event, helper) {
        component.set('v.isBOMmodalOpen' , true);
        helper.getQuoteGrouping(component, event, helper);

    },
    // submitDetails: function(component, event, helper) {
    //     helper.submitDetails(component, event, helper);

    // },
     closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.isBOMmodalOpen", false);
        component.set("v.openPopup", false);

    },
    onclickDuplicate: function(component, event, helper) {
        console.log('onclickDuplicate');
        component.set("v.openPopup", true);

        var currentId = event.currentTarget.getAttribute("data-id");
        console.log(currentId);
        component.set("v.currentId", currentId);
        component.set("v.PopupHeader", "Duplicate Quote Line");
        component.set("v.PopupDescription", "Are you sure you want to duplicate this Quote Line?");
        component.set("v.isDuplicate", true);
    },
    duplicateQuote: function(component, event, helper) {
        var currentId = component.get("v.currentId");
        if (currentId != "" && currentId != undefined) {
            component.set("v.openPopup", false);

            component.set("v.isDuplicate", false);
            
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var checkvalue = component.find("selectAll");
            var duplicateRecs = [];
            duplicateRecs.push(currentId);
            var action = component.get("c.massDuplicateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": duplicateRecs
            });
            action.setCallback(this, function(respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    component.set("v.value", false);
                    component.set("v.currentId", "");
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function() {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Duplicate records for selected quote items created successfully.',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    var page = component.get("v.page") || 1                   
                    helper.getQuoteGrouping(component, event, helper); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeDuplicateModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "Fasle"
        component.set("v.isOpen", false);
        component.set("v.isDuplicate", false);
        component.set("v.isMassDuplicate", false);
        component.set("v.currentId", "");
    },
    editQuote: function(component, event, helper) {
        console.log(event.currentTarget);
        var recordId = event.currentTarget.dataset.id;
        console.log({recordId});
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },
})