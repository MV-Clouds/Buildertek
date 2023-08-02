({
    cloneTakeOffLineRecordFromParent: function (component, event, helper) 
    {
        component.set('v.isLoading', true);
        var parentTakeOffLineId = component.get('v.takeOffLineId');
        var action = component.get("c.cloneTakeOffLine");

        action.setParams({
            "recordId" : parentTakeOffLineId
        });
        action.setCallback(this, function (response) 
        {
            var state = response.getState();

            if (state === "SUCCESS") 
            {
                var clonedRecord = response.getReturnValue();
                console.log('@@clonedRecord--'+JSON.stringify(clonedRecord));
                clonedRecord.buildertek__TO_REC_TYPE__c = 'Detail';
                if(clonedRecord.buildertek__TL_SERVICE_CATEGORY__c == null)
                {
                    clonedRecord.buildertek__TL_SERVICE_CATEGORY__c = '';
                }
                if(clonedRecord.buildertek__Product_Count__c == null)
                {
                    clonedRecord.buildertek__Product_Count__c = '';
                }
                if(clonedRecord.buildertek__UOM__c == null)
                {
                    clonedRecord.buildertek__UOM__c = '';
                }
                console.log('@@clonedRecord2--'+JSON.stringify(clonedRecord));
                component.set('v.clonedTakeOffLine',clonedRecord);
                component.set('v.isLoading', false);
            }
            else 
            {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
    },
    saveClonedRecord: function (component, event, helper) 
    {
        component.set('v.isLoading', true);
        var clonedRecord = component.get('v.clonedTakeOffLine');
        var action = component.get("c.saveTakeOffLineRecord");

        action.setParams({
            "record" : clonedRecord
        });
        action.setCallback(this, function (response) 
        {
            var state = response.getState();

            if (state === "SUCCESS") 
            {
                var clonedRecordId = response.getReturnValue();
                console.log('@@clonedRecord ID After Save--'+JSON.stringify(clonedRecordId));
                if(clonedRecordId != null && clonedRecordId != undefined && clonedRecordId != '')
                {
                    helper.showToast(component, event, helper, 'Success', 'Record Saved Successfully.', 'success');
                     var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.takeOffRecordId') + '/view';
                     window.open(redirectUrl, '_self');
                }
                component.set('v.isLoading', false);
            }
            else 
            {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
    },
    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'pester',
            message: message,
            type: type,
            duration: 2
        });
        toastEvent.fire();
        component.set("v.isSpinner", false);
    },

    setTakeOffLineTableColumn: function (component, event, helper)
    {
        
        component.set( 'v.takeOfflineTableColumns', [    
            {label: 'TOL#', fieldName: 'Name', type: 'text'}
        ]);
    },
    getTakeOffLineList: function (component, event, helper) 
    {
        component.set('v.isLoading', true);
        var parentTakeOffId = component.get('v.takeOffRecordId');
        var action = component.get("c.getTakeOffLines");

        action.setParams({
            "parentId" : parentTakeOffId
        });
        action.setCallback(this, function (response) 
        {
            var state = response.getState();

            if (state === "SUCCESS") 
            {
                var allTakeOffLines = response.getReturnValue();
                console.log('@@allTakeOffLines--'+JSON.stringify(allTakeOffLines));
                
                component.set('v.takeOffLineList',allTakeOffLines);
                component.set('v.isLoading', false);
            }
            else 
            {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
    },
})