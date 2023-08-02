({
    getTableData: function (component, event, helper) 
    {
        component.set('v.isLoading', true);
        var BOMID = component.get("v.parentId");
        var fieldNameToOperate = component.get('v.fieldAPIName');

        var action = component.get("c.getData");
        action.setParams({
            "bomId": BOMID,
            "fieldName" : fieldNameToOperate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('@@tableData--', result);
                if(result != null && result != undefined && result.length > 0)
                {
                    component.set('v.tableData',result);
                    
                }
                component.set('v.isLoading', false);
            }
            else {
                //helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
        
    },
    getBOMData : function (component, event, helper) 
    {
        component.set('v.isLoading', true);
        var BOMID = component.get("v.parentId");

        var action = component.get("c.getOCIPVal");
        action.setParams({
            "recordId": BOMID
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('@@BOMData--', result);
                if(result != null && result != undefined )
                {
                    component.set('v.bomRecord',result);
                    // if(component.get("v.showSaveCancelBtn") == false){
                        // component.set("v.showSaveCancelBtn",true);

                    // }
                    console.log('Data--',result.buildertek__OCIP_CCIP_Required__c);
                }
                component.set('v.isLoading', false);
            }
            else {
                //helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
        
    },
    getPicklistVal : function (component, event, helper) 
    {
        component.set('v.isLoading', true);

        var action = component.get("c.getTypePickListValFromBOM");


        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('@@PicklistData--', result);
                if(result != null && result != undefined )
                {
                    var picklistVal = [];
                    for (var key in result) {
                        picklistVal.push({ key: key, value: result[key] });
                    }
                    component.set("v.typeMap", picklistVal);
                }
                component.set('v.isLoading', false);
            }
            else {
                //helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Not success');
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
        
    },
    saveRecord: function (component, event, helper) 
    {
        var action = component.get("c.saveData");
        var wrapList = component.get('v.tableData');
        var recordId = component.get('v.parentId');
        var fieldName = component.get('v.fieldAPIName');
        console.log('TableData***', wrapList);
        console.log('fieldName==='+fieldName);
        action.setParams({

            'jsonString': JSON.stringify(wrapList),
            'fieldToUpdate': fieldName,
            'bomId': recordId

        });
        action.setCallback(this, function (response) {
        
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result***', result);
                if (result.isSuccess) {
                    var retResponse = JSON.parse(result.response);
                    console.log('retResponse***', retResponse);
                    var parentComponent = component.get("v.parent");
                    parentComponent.setExtendedCostValues(retResponse)

                } else {
                    console.log('@@Return Value False');

                }

            } else {
                console.log('@@Not Success');

            }

        });
          $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    saveBOMRecord: function (component, event, helper) 
    {
       // alert('nokl');
        var action = component.get("c.saveBOMRecord");
        var bomRecToUpdate = component.get('v.bomRecord');
        console.log('bomRecToUpdate==='+bomRecToUpdate);
        console.log('bomRecToUpdate***', bomRecToUpdate);
        action.setParams({

            'recordDetail': JSON.stringify(bomRecToUpdate)

        });
        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result***', result);

                if (result.isSuccess) {
                    var retResponse = JSON.parse(result.response);
                    console.log('retResponse***', retResponse);
                    // component.set("v.showSaveCancelBtn",false);
                    var parentComponent = component.get("v.parent");
                    parentComponent.setExtendedCostValues(retResponse)

                } else {
                    console.log('@@Return Value False');

                }

            } else {
                console.log('@@Not Success');

            }

        });
        $A.enqueueAction(action);
    },
    validateRecords: function (component, event, helper) 
    {
        var isSuccess = true;
        var fieldName = component.get('v.fieldAPIName');
        var allTableData = component.get('v.tableData');
        // if(allTableData != null && allTableData != undefined && allTableData.length > 0 && fieldName != null && fieldName != undefined && fieldName == 'buildertek__Textura_Fee__c')
        // {
        //     var singleData = allTableData[0];
        //     var dataVal;
        //     for (var i = 0; i < singleData.length; i++) 
        //     {
        //         if (singleData[i].label == 'Value') 
        //         {
        //             dataVal = singleData[i].value;
        //         }
        //     }

        //     if(dataVal != null && dataVal != undefined)
        //     {
        //         dataVal = parseInt(dataVal);
        //         console.log('Validation Rate--',dataVal);
        //         if(dataVal < 500 || dataVal > 3750)
        //         {
        //             console.log('INVAILD Rate--');
        //             helper.showToast(component, event, helper, 'Error!', 'Textura Fee must be between $500 and $3750.', 'error');
        //             isSuccess = false;
        //         }
        //     }
        // }


        return isSuccess;
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
})