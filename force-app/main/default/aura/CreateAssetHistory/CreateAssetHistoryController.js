({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        console.log('recordId: ' + component.get("v.recordId"));
        var action = component.get("c.getPreviousAssetHistory");
        action.setParams({
            assetId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({ state });
            if(state=='SUCCESS'){    
                var result = response.getReturnValue();
                console.log({ result });
                if(result == null){
                    component.set("v.showNewModal", true);
                    component.set("v.Spinner", false);
                }else{
                    // console.log('result: ' + JSON.stringify(result));
                    //if the previous record is not closed, then show the old modal and ask user to close the previous record first based on BUIL - 3292
                    component.set("v.PreviousAssetHistory", result);
                    component.set("v.showOldModal", true);
                    component.set("v.Spinner", false);
                }
            }else{
                helper.showToast("Error", "Error", "Something went wrong", "5000");
                $A.get("e.force:closeQuickAction").fire();
                component.set("v.Spinner", false);
            }
        }
        );
        $A.enqueueAction(action);

    },

    createRecord: function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var AssetHistoryFields = component.get('v.AssetHistory');
            AssetHistoryFields.buildertek__Asset_Manager__c = component.get("v.recordId");
            console.log('CreateAssetHistoryController.createRecord: AssetHistoryFields: ' + JSON.stringify(AssetHistoryFields));
            var action = component.get("c.CreateAssetHistoryRecord");
            action.setParams({
                AssetHistory: AssetHistoryFields
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log({ state });
                var result = response.getReturnValue();
                if(state=='SUCCESS'){
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    helper.showToast("Success", "Success", "Your Asset History is created", "5000");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/r/Asset_History__c/" + result + "/view?ws=%2Flightning%2Fr%2Fbuildertek__Asset_Manager__c%2F" + component.get("v.recordId") + "%2Fview" 
                    });
                    urlEvent.fire();
                }else{
                    helper.showToast("Error", "Error", "Record not inserted", "5000");
                    $A.get("e.force:closeQuickAction").fire();
                }
                component.set("v.Spinner", false);
                
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log({ e });
        }
    },

    updateRecord: function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var AssetHistoryFields = component.get('v.PreviousAssetHistory');
            console.log('CreateAssetHistoryController.updateRecord: AssetHistoryFields: ' + JSON.stringify(AssetHistoryFields));
            //buildertek__Date_off_Job__c should not be null
            if(AssetHistoryFields.buildertek__Date_off_Job__c == null){
                helper.showToast("Error", "Error", "Date off Job is required", "5000");
                component.set("v.Spinner", false);
                return;
            }
            var action = component.get("c.UpdateAssetHistoryRecord");
            action.setParams({
                PreviousAssetHistory: AssetHistoryFields
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log({ state });
                var result = response.getReturnValue();
                console.log('result: ' + JSON.stringify(result));
                if(state=='SUCCESS' && !result.startsWith('Error') ){
                    helper.showToast("Success", "Success", "Your Asset History is updated", "5000");
                    component.set("v.showOldModal", false);
                    component.set("v.showNewModal", true);
                }else{
                    helper.showToast("Error", "Error", "Record not updated", "5000");
                    $A.get("e.force:closeQuickAction").fire();
                }
                component.set("v.Spinner", false);
                
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log({ e });
        }
    },

    closePopup: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})