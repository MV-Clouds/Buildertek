({
    doInit : function(component, event, helper)
    {
        console.log('Child Component Called');
        console.log('fieldAPIName--',component.get('v.fieldAPIName'));
        console.log('objectList--',component.get('v.objectList'));

        var fieldNameToOperate = component.get('v.fieldAPIName');
        var DataList = component.get('v.objectList');

        console.log('Contains--',DataList[0][fieldNameToOperate]);
        if(DataList != null && DataList != undefined && DataList.length > 0 &&
            DataList[0][fieldNameToOperate] != null && DataList[0][fieldNameToOperate] != undefined)
        {
            var fieldValueList = DataList[0][fieldNameToOperate];
            component.set('v.fieldValues',JSON.parse(fieldValueList) );
            component.set('v.recordIdToRedirect',DataList[0].Id );
        }
    },
    handleSave: function (component, event, helper)
    {
        console.log('SAVE fieldValues--',component.get('v.fieldValues'));
        console.log('SAVE objectList1--',component.get('v.objectList'));
        console.log('SAVE recordId--',component.get('v.recordIdToRedirect'));
        var DataList = component.get('v.objectList');
        var updatedFieldValues = component.get('v.fieldValues');
        var fieldNameToOperate = component.get('v.fieldAPIName');
        DataList[0][fieldNameToOperate] = JSON.stringify(updatedFieldValues);

        var action = component.get("c.updateBomRecords");
        action.setParams({

            'updatedBomList': DataList

        });
        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result***', result);

                if (result.isSuccess) {
                    //Call Parent aura method
                    var parentComponent = component.get("v.parent");
                    parentComponent.afterSaveProductCode()

                } else {
                    console.log('@@Return Value False');
                    //helper.showToast(component, event, helper, 'Error!', result.message, 'error');

                }

            } else {
                console.log('@@Not Success');
                //helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
            }

        });
        $A.enqueueAction(action);
    },
    handleClose: function (component, event, helper)
    {
        var parentComponent = component.get("v.parent");
        parentComponent.closeProductCodeComponent()
    },
})