({
    doInit : function(component, event, helper) {
        console.log('Single Data--',component.get('v.singleList'));

        var dataToProcess = component.get('v.singleList');
        var proposalAmt = component.get('v.proposalAmount');
        var fieldName = component.get('v.fieldNameToOperate');
        var installCost = component.get('v.installCostAmount');

        if (dataToProcess != null && dataToProcess != undefined && dataToProcess.length > 0 &&
            proposalAmt != null && proposalAmt != undefined && proposalAmt != '' && fieldName != null && fieldName != undefined && 
            fieldName == 'buildertek__General_Liability_Insurance_Long__c') 
            {
                var nominatorVal;
                var denominatorVal;
                for (var i = 0; i < dataToProcess.length; i++) 
                {
                    if (dataToProcess[i].label == 'Proposal Amount') 
                    {
                        dataToProcess[i].value = parseFloat(proposalAmt).toFixed(2);
                    }
                    if (dataToProcess[i].label == 'Rate') 
                    {
                        nominatorVal = dataToProcess[i].value;
                    }
                    if (dataToProcess[i].label == 'Denominator Rate') 
                    {
                        denominatorVal = dataToProcess[i].value;
                    }
                }

                if(nominatorVal != null && nominatorVal != undefined && denominatorVal != null && denominatorVal != undefined)
                {
                    proposalAmt = parseFloat(proposalAmt);
                    nominatorVal = parseFloat(nominatorVal);
                    denominatorVal = parseFloat(denominatorVal);
                    var rateVal = proposalAmt * (nominatorVal / denominatorVal);
                    rateVal = parseFloat(rateVal).toFixed(2);

                    if(rateVal != null && rateVal != undefined)
                    {
                        for (var i = 0; i < dataToProcess.length; i++) 
                        {
                            if (dataToProcess[i].label == 'Value') 
                            {
                                dataToProcess[i].value = rateVal;
                            }
                        }
                    }
                }
                helper.saveUpdatedRecord(component, event, helper);

            }

        if (dataToProcess != null && dataToProcess != undefined && dataToProcess.length > 0 &&
            installCost != null && installCost != undefined && installCost != '' && fieldName != null && fieldName != undefined &&
            fieldName == 'buildertek__Workers_Comp__c') {
            var nominatorVal;
            var denominatorVal;


            for (var i = 0; i < dataToProcess.length; i++) {
                if (dataToProcess[i].label == 'Install Cost') {
                    dataToProcess[i].value = parseFloat(installCost).toFixed(2);
                }
                if (dataToProcess[i].label == 'Rate') {
                    nominatorVal = dataToProcess[i].value;
                }
                if (dataToProcess[i].label == 'Denominator Rate') {
                    denominatorVal = dataToProcess[i].value;
                }
            }

            if (nominatorVal != null && nominatorVal != undefined && denominatorVal != null && denominatorVal != undefined) {
                installCost = parseFloat(installCost).toFixed(2);
                console.log('@@@installCost--', installCost);
                nominatorVal = parseFloat(nominatorVal);
                denominatorVal = parseFloat(denominatorVal);
                var rateVal = installCost * (nominatorVal / denominatorVal);
                rateVal = parseFloat(rateVal).toFixed(2);
                console.log('@@@rateVal--', rateVal);

                if (rateVal != null && rateVal != undefined) {
                    for (var i = 0; i < dataToProcess.length; i++) {
                        if (dataToProcess[i].label == 'Value') {
                            dataToProcess[i].value = rateVal;
                        }
                    }
                }
            }

            helper.saveUpdatedRecord(component, event, helper);


        }

            if (dataToProcess != null && dataToProcess != undefined && dataToProcess.length > 0 &&
                proposalAmt != null && proposalAmt != undefined && proposalAmt != '' && fieldName != null && fieldName != undefined && 
                fieldName == 'buildertek__Textura_Fee__c') 
                {
                    var rate;
                    var rateVal;
                    var texturaExtendedCost;
                    for (var i = 0; i < dataToProcess.length; i++) 
                    {
                        if (dataToProcess[i].label == 'Proposal Amount') 
                        {
                            dataToProcess[i].value = parseFloat(proposalAmt).toFixed(2);
                            // let theProposalAmount = parseInt(proposalAmt);

                            // if(theProposalAmount >= 500 && theProposalAmount <= 3750)
                            // {
                            //     dataToProcess[i].value = parseFloat(proposalAmt).toFixed(2);
                            // }
                            // else if(theProposalAmount < 500)
                            // {
                            //     dataToProcess[i].value = 500.00;
                            // }
                            // else if(theProposalAmount > 3750)
                            // {
                            //     dataToProcess[i].value = 3750.00;
                            // }
                        }
                        if (dataToProcess[i].label == 'Rate') 
                        {
                            rate = dataToProcess[i].value;
                        }
                    }
    
                    if(rate != null && rate != undefined )
                    {
                        proposalAmt = parseFloat(proposalAmt).toFixed(2);
                        rate = parseFloat(rate);
                        rateVal = proposalAmt * rate;
                        rateVal = parseFloat(rateVal).toFixed(2);
    
                        if(rateVal != null && rateVal != undefined)
                        {
                            if( rateVal > 499.99 && rateVal < 3750.01 )
                            {
                                texturaExtendedCost = parseFloat(rateVal).toFixed(2);
                            }
                            else if(rateVal < 500.00 )
                            {
                                texturaExtendedCost = 500.00;
                            }
                            else if(rateVal > 3750.00 )
                            {
                                texturaExtendedCost = 3750.00;
                            }
                            for (var i = 0; i < dataToProcess.length; i++) 
                            {
                                if (dataToProcess[i].label == 'Value') 
                                {
                                    dataToProcess[i].value = rateVal;
                                }
                                else if (dataToProcess[i].label == 'Extended Cost' && texturaExtendedCost != null && texturaExtendedCost != undefined) 
                                {
                                    dataToProcess[i].value = texturaExtendedCost;
                                }
                            }
                        }
                    }

                    if(rateVal != null && rateVal != undefined && texturaExtendedCost != null && texturaExtendedCost != undefined)
                    {
                        helper.saveUpdatedRecord(component, event, helper);
                        // rateVal = parseInt(rateVal);
                        // if(rateVal < 500 || rateVal > 3750)
                        // {
                        //     var parentComponent = component.get("v.parent");
                        //     parentComponent.showToast('Textura Fee must be between $500 and $3750.')
                        // }
                        // else
                        // {
                        //     helper.saveUpdatedRecord(component, event, helper);
                        // }
                    }
    
                }
    },
    inlineEditRate : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.rateEditMode",true)
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
             component.find("rateInputId").focus();
             //component.find("rateInputId").set("v.format", '$#,###.00');
        }, 100);
    },
    inlineEditPercentage : function(component,event,helper){   
        component.set("v.percentageEditMode",true)
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
             component.find("percentageInputId").focus();
        }, 100);
    },
    inlineEdittax : function(component,event,helper){   
        component.set("v.taxEditMode",true)
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
             component.find("taxId").focus();
        }, 100);
    },
    inlineEditDenominator : function(component,event,helper){   
        component.set("v.denominatorEditMode",true)
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
             component.find("denominatorInputId").focus();
        }, 100);
    },
    closeRateBox: function (component, event, helper) {
        // on focus out, close the input section by setting the 'rateEditMode' att. as false   
        component.set("v.rateEditMode", false);
    },
    closePercentageBox: function (component, event, helper) {
        // on focus out, close the input section by setting the 'rateEditMode' att. as false   
        component.set("v.percentageEditMode", false);
    },
    closetaxBox: function (component, event, helper) {
        // on focus out, close the input section by setting the 'rateEditMode' att. as false   
        component.set("v.taxEditMode", false);
    },
    closeDenominatorBox: function (component, event, helper) {
        // on focus out, close the input section by setting the 'rateEditMode' att. as false   
        component.set("v.denominatorEditMode", false);
    },
    onRateChange: function (component, event, helper) {
        console.log('event.getSource()--',event.getSource().get("v.value"));
        console.log('event.getSource() Label--',event.getSource().get("v.label"));
        console.log('onRateChange--',component.get('v.singleList'));
        var fieldName = component.get('v.fieldNameToOperate');

        var dataList = component.get('v.singleList');
        for (var i = 0; i < dataList.length; i++) 
        {
            if(event.getSource().get("v.label") == 'Rate' && event.getSource().get("v.value") == null && dataList[i].label == 'Adjusted Price' )
            {
                dataList[i].value = '';
            }
        }

        if(fieldName != null && fieldName != undefined && fieldName == 'buildertek__Workers_Comp__c')
        {
            if(event.getSource().get("v.label") == 'Denominator Rate' && (event.getSource().get("v.value") == null || event.getSource().get("v.value") == 0))
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Denominator Rate') 
                    {
                        dataList[i].value = 1;
                    }
                }
            }

            if(event.getSource().get("v.label") == 'Rate' && (event.getSource().get("v.value") == null || event.getSource().get("v.value") == 0))
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Rate') 
                    {
                        dataList[i].value = 0;
                    }
                }
            }
        }

        if(fieldName != null && fieldName != undefined && fieldName == 'buildertek__General_Liability_Insurance_Long__c')
        {
            if(event.getSource().get("v.label") == 'Denominator Rate' && (event.getSource().get("v.value") == null || event.getSource().get("v.value") == 0))
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Denominator Rate') 
                    {
                        dataList[i].value = 1;
                    }
                }
            }

            if(event.getSource().get("v.label") == 'Rate' && (event.getSource().get("v.value") == null || event.getSource().get("v.value") == 0))
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Rate') 
                    {
                        dataList[i].value = 0;
                    }
                }
            }
        }

        if(fieldName != null && fieldName != undefined && fieldName == 'buildertek__Textura_Fee__c')
        {

            if(event.getSource().get("v.label") == 'Rate' && (event.getSource().get("v.value") == null || event.getSource().get("v.value") == 0))
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Rate') 
                    {
                        dataList[i].value = 0;
                    }
                }
            }
        }

        if(fieldName != null && fieldName != undefined && fieldName == 'buildertek__Slab_Discount_Rate_LongText__c')
        {

            if(event.getSource().get("v.label") == 'Percentage' && event.getSource().get("v.value") != null 
            && event.getSource().get("v.value") != undefined
            && Math.sign(event.getSource().get("v.value")) == 1 )
            {
                console.log('Slab Discount Positive');
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Percentage To Apply') 
                    {
                        dataList[i].value = -Math.abs(event.getSource().get("v.value"));
                    }
                }
                console.log('Slab Discount Positive dataList--',dataList);
            }
            // else{
            //     console.log('buildertek__Slab_Discount_Rate_LongText__c if');
            //     for (var i = 0; i < dataList.length; i++) 
            //     {
            //         if (dataList[i].label == 'Percentage To Apply') 
            //         {
            //             dataList[i].value = 0;
            //         }
            //     }
            // }
        }
        if(fieldName != null && fieldName != undefined && fieldName == 'buildertek__Tax__c')
        {

            if(event.getSource().get("v.label") == 'Tax' && event.getSource().get("v.value") != null 
            && event.getSource().get("v.value") != undefined
            && Math.sign(event.getSource().get("v.value")) == 1 )
            {
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Tax') 
                    {
                        dataList[i].value = -Math.abs(event.getSource().get("v.value"));
                    }
                }
            }
        }
        component.set("v.showSaveCancelBtn",true);
        helper.calculateExtendedCost(component, event, helper);
    },
    handleChange: function (component, event, helper) 
    {},
    keyPressEvent: function(component, event, helper) {
        
        if(event.which == 13) {
			
            event.stopPropagation();
			event.preventDefault();            
        }
        
    }
})