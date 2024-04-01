({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        window.setTimeout(
            $A.getCallback(function () {
                console.log('recordId', component.get('v.recordId'));
                helper.getWalkThroughLines(component, event, helper);
                helper.getDropDownValues(component, event, helper);
            }),
            2000
        );
    },

    onAddClick: function (component, event, helper) {
        var walkThroughLines = component.get('v.walkThroughLine');
        var walkThroughLine = {
            'Name': '',
            'buildertek__Walk_Through_List__c': component.get('v.recordId'),
        };
        walkThroughLines.push(walkThroughLine);
        component.set('v.walkThroughLine', walkThroughLines);
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var walkThroughLines = component.get('v.walkThroughLine');
        var index = target.getAttribute("data-index");
        console.log('index', index);
        if (index != null) {
            if (walkThroughLines[index].Id != '' && walkThroughLines[index].Id != undefined && walkThroughLines[index].Id != null) {
                var deletedWalkThroughLines = component.get('v.deletedWalkThroughLine');
                deletedWalkThroughLines.push(walkThroughLines[index]);
                component.set('v.deletedWalkThroughLine', deletedWalkThroughLines);
                walkThroughLines.splice(index, 1);
                component.set('v.walkThroughLine', walkThroughLines);

            } else {
                walkThroughLines.splice(index, 1);
                component.set('v.walkThroughLine', walkThroughLines);
            }
        }
    },

    onMassUpdate: function (component, event, helper) {
        component.set("v.Spinner", true);
        helper.validateWalkThroughLines(component, event, helper);
    },

    onMassUpdateCancel: function (component, event, helper) {
        component.set("v.isCancelModalOpen", true);
    },

    closeScreen: function (component, event, helper) {
        component.set("v.isCancelModalOpen", false);
        var appEvent = $A.get("e.c:myEvent");
        appEvent.setParams({
            "message": "Event fired"
        });
        appEvent.fire();

        sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
    },

    closeCancelModal: function (component, event, helper) {
        component.set("v.isCancelModalOpen", false);
    },
})