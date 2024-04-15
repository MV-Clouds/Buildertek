({
    doInit: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); window.setTimeout(
            $A.getCallback(function () {
                console.log('recordId', component.get('v.recordId'));
                helper.getWalkThroughLines(component, event, helper);
                helper.getDropDownValues(component, event, helper);
            }),
            2000
        );
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },
     handleInputChange: function(component, event, helper) {
        var newValue = event.getSource().get("v.value");
        var index = event.getSource().get("v.name"); 
        console.log(newValue);
        var walkThroughLines = component.get('v.walkThroughLine'); 
        walkThroughLines[index].buildertek__Quantity__c = newValue;
        component.set("v.walkThroughLine", walkThroughLines);  
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
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.validateWalkThroughLines(component, event, helper);
    },

    onMassUpdateCancel: function (component, event, helper) {
        component.set("v.isCancelModalOpen", true);
    },

    closeScreen: function (component, event, helper) {
        component.set("v.isCancelModalOpen", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
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

    handleLookUpEvent: function (component, event, helper) {
        var walkThroughLines = component.get('v.walkThroughLine');
        var index = event.getParam("index");
        var selectedRecord = event.getParam("selectedRecordId");
        console.log(`fieldName ${event.getParam("fieldName")}: value ${event.getParam("selectedRecordId")} index: ${index}`);
        if (event.getParam("fieldName") == 'buildertek__Product__c') {
            walkThroughLines[index].buildertek__Product__c = selectedRecord;
        } else if (event.getParam("fieldName") == 'buildertek__BT_Category__c') {
            walkThroughLines[index].buildertek__BT_Category__c = selectedRecord[0];
        }
        component.set('v.walkThroughLine', walkThroughLines);
    },

    clearSelectedHandler: function (component, event, helper) {
        console.log(`clearSelectedHandler`);
        var walkThroughLines = component.get('v.walkThroughLine');
        var index = event.getSource().get("v.index");
        console.log(`fieldName ${event.getParam("fieldName")}: value ${event.getParam("value")} index: ${index}`);
        if (event.getParam("fieldName") == 'buildertek__Product__c') {
            walkThroughLines[index].buildertek__Product__c = '';
        } else if (event.getParam("fieldName") == 'buildertek__BT_Category__c') {
            walkThroughLines[index].buildertek__BT_Category__c = '';
        }
        component.set('v.walkThroughLine', walkThroughLines); x
    },

    ProductSelectHandler: function (component, event, helper) {
        console.log(`ProductSelectHandler`);
        var walkThroughLines = component.get('v.walkThroughLine');
        var index = event.getSource().get("v.index");
        let selectedRecord = event.getParam("recordByEvent");
        console.log(`selectedRecord: ${JSON.stringify(selectedRecord)} index: ${index}`);
        walkThroughLines[index].buildertek__Product__c = selectedRecord.Id;
        component.set('v.walkThroughLine', walkThroughLines);
    }
})