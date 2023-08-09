({
    doInit : function(component, event, helper)
    {
        console.log('Edit Extended Cost Component Called');
        console.log('compon1--',component);
        console.log('fieldAPIName--',component.get('v.fieldAPIName'));
        console.log('parentId--',component.get('v.parentId'));

        var fieldNameToOperate = component.get('v.fieldAPIName');
        // helper.getTableData(component, event, helper);
        console.log('showSaveCancelBtn==='+component.get("v.showSaveCancelBtn"));
        if(fieldNameToOperate != null && fieldNameToOperate != undefined && fieldNameToOperate == 'buildertek__OCIP_CCIP_Required__c')
        {
            helper.getPicklistVal(component, event, helper);
            helper.getBOMData(component, event, helper);
        }
        else
        {
            helper.getTableData(component, event, helper);
        }
        

        if(fieldNameToOperate != null && fieldNameToOperate != undefined && fieldNameToOperate == 'buildertek__Workers_Comp__c')
        {
            component.set('v.formulaNameToShow','Workers Comp Value Calculation Formula.');
            component.set('v.formulaTextToShow','Value = Install Cost * ( Rate / Denominator Rate)');
        }

        if(fieldNameToOperate != null && fieldNameToOperate != undefined && fieldNameToOperate == 'buildertek__General_Liability_Insurance_Long__c')
        {
            component.set('v.formulaNameToShow','General Liability Insurance Calculation Formula.');
            component.set('v.formulaTextToShow','Value = Proposal Amount * ( Rate / Denominator Rate)');
        }
        if(fieldNameToOperate != null && fieldNameToOperate != undefined && fieldNameToOperate == 'buildertek__Textura_Fee__c')
        {
            component.set('v.formulaNameToShow','Textura Fee Calculation Formula.');
            component.set('v.formulaTextToShow','Value = Proposal Amount * Rate. The Value should be between $500 to $3750.');
        }
        
    },

    // Created a method as a part of CAES-86 3rd issue
    OCIPChange: function(component,event,helper){
        component.set('v.showSaveCancelBtn',true);
    },
    handleSave: function (component, event, helper)
    {
        console.log('tableData ON SAVE--',component.get('v.tableData'));
        var isSuccess = helper.validateRecords(component, event, helper);
        console.log('isSuccess--',isSuccess);
        if(isSuccess == true)
        {
            var fieldNameToOperate = component.get('v.fieldAPIName');
            console.log('fieldNameToOperate-->'+fieldNameToOperate);
            if(fieldNameToOperate != null && fieldNameToOperate != undefined && fieldNameToOperate == 'buildertek__OCIP_CCIP_Required__c')
            {
                console.log('saveBOMRecord');
                helper.saveBOMRecord(component, event, helper);
            }
            else
            {
                console.log('saveRecord');
                helper.saveRecord(component, event, helper);
            }
        }
    },
    handleClose: function (component, event, helper)
    {
        var parentComponent = component.get("v.parent");
        parentComponent.closeProductCodeComponent()
    },
    showToastMessage: function (component, event, helper)
    {
        var params = event.getParam('arguments');
        helper.showToast(component, event, helper, 'Error!', params.toastMessage , 'error');
    },
})