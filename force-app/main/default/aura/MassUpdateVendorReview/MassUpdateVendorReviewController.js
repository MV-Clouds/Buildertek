({
    doInit: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var pageRef = component.get("v.pageReference");
        if (pageRef != undefined) {
            var state = pageRef.state;
            if (state != undefined && state.c__Id != undefined) {
                component.set("v.recordId", state.c__Id);
            }

            if (state != undefined && state.buildertek__Id != undefined) {
                component.set("v.recordId", state.buildertek__Id);
            }
        }

        let vendorReviewId = component.get("v.recordId");
        if (vendorReviewId != undefined) {
            helper.getVendorReviewLines(component, event, helper);
        }
    },

    onAddClick: function (component, event, helper) {
        var vendorReviewLines = component.get('v.vendorReviewLines');
        var vendorReviewLine = {
            'Name': '',
            'buildertek__Contract_Review__c': component.get('v.recordId'),
        };
        vendorReviewLines.push(vendorReviewLine);
        component.set('v.vendorReviewLines', vendorReviewLines);
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var vendorReviewLines = component.get('v.vendorReviewLines');
        var index = target.getAttribute("data-index");
        console.log('index', index);
        if (index != null) {
            if (vendorReviewLines[index].Id != '' && vendorReviewLines[index].Id != undefined && vendorReviewLines[index].Id != null) {
                var deletedVendorReviewLines = component.get('v.deletedVendorReviewLines');
                deletedVendorReviewLines.push(vendorReviewLines[index]);
                component.set('v.deletedVendorReviewLines', deletedVendorReviewLines);
                vendorReviewLines.splice(index, 1);
                component.set('v.vendorReviewLines', vendorReviewLines);

            } else {
                vendorReviewLines.splice(index, 1);
                component.set('v.vendorReviewLines', vendorReviewLines);
            }
        }
    },

    onMassUpdate: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.validateVendorReviewLines(component, event, helper);
    },

    onMassUpdateCancel: function (component, event, helper) {
        component.set("v.isCancelModalOpen", true);
    },

    closeScreen: function (component, event, helper) {
        helper.closeScreenAndRedirect(component, event, helper);
    },

    closeCancelModal: function (component, event, helper) {
        component.set("v.isCancelModalOpen", false);
    },

    recalculateScore: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        var vendorReviewLines = component.get('v.vendorReviewLines');
        var vrl = vendorReviewLines[index];

        var weighting = vrl.buildertek__Weighting__c || 0;
        var rating = vrl.buildertek__Rating__c || 0;
        var score = (weighting * rating / 100).toFixed(2);

        vrl.buildertek__Score__c = score;

        component.set('v.vendorReviewLines', vendorReviewLines);
    }
})