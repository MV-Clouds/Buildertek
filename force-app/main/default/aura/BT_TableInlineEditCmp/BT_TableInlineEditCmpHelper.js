({
    calculateExtendedCost: function (component, event, helper) 
    {
        var finalExtendedCost;
        var finalSingleExtendedCost;

        var fieldName = component.get('v.fieldNameToOperate');
        var dataList = component.get('v.singleList');

        if (dataList != null && dataList != undefined && dataList.length > 0 &&
            fieldName != null && fieldName != undefined && fieldName.length > 0) 
            {
            if (fieldName == 'buildertek__Fabrication_Install_Rate__c' || fieldName == 'buildertek__Install_Only__c') 
            {
                console.log('FAB INSTALL FOUND');
                var rateValue = 0;
                var sqftValue = 0;
                var quantity = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Adjusted Price') 
                    {
                        rateValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Sq Ft') 
                    {
                        sqftValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Quantity') 
                    {
                        quantity = dataList[i].value;
                    }
                }

                if (rateValue != null && rateValue != undefined  &&
                    sqftValue != null && sqftValue != undefined &&
                    quantity != null && quantity != undefined ) 
                    {
                    rateValue = parseFloat(rateValue);
                    sqftValue = parseFloat(sqftValue);
                    quantity = parseFloat(quantity);

                    finalExtendedCost = rateValue * sqftValue;
                    finalSingleExtendedCost = finalExtendedCost;
                    finalExtendedCost = finalExtendedCost * quantity;
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                }
            }

            if (fieldName == 'buildertek__Fab_Only_Rate__c') 
            {
                console.log('FAB Only FOUND');
                var rateValue = 0;
                var percentVal = 0;
                var quantity = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Adjusted Price') 
                    {
                        rateValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Percentage To Apply') 
                    {
                        percentVal = dataList[i].value;
                    }
                    if (dataList[i].label == 'Quantity') 
                    {
                        quantity = dataList[i].value;
                    }
                }

                if (rateValue != null && rateValue != undefined  &&
                percentVal != null && percentVal != undefined  &&
                quantity != null && quantity != undefined) 
                    {
                    rateValue = parseFloat(rateValue);
                    percentVal = parseFloat(percentVal);
                    quantity = parseFloat(quantity);

                    finalExtendedCost = rateValue * percentVal;
                    finalSingleExtendedCost = finalExtendedCost;
                    finalExtendedCost = finalExtendedCost * quantity;
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                }
            }

            if ( fieldName == 'buildertek__Edge__c' || fieldName == 'buildertek__Options_Rate__c') 
            {
                console.log('Non Slab FOUND');
                var rateValue = 0;
                var quantity = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Adjusted Price') 
                    {
                        rateValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Quantity') 
                    {
                        quantity = dataList[i].value;
                    }
                }

                

                if (rateValue != null && rateValue != undefined  &&
                quantity != null && quantity != undefined ) 
                    {
                    rateValue = parseFloat(rateValue);
                    quantity = parseFloat(quantity);

                    finalExtendedCost = rateValue * quantity;
                    finalSingleExtendedCost = parseFloat(rateValue).toFixed(2);
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                }
                
            }

            if (fieldName == 'buildertek__Miscellaneous_Rates__c') 
            {
                console.log('FAB Only FOUND');
                var rateValue = 0;
                var percentVal = 0;
                var quantity = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Adjusted Price') 
                    {
                        rateValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Quantity') 
                    {
                        quantity = dataList[i].value;
                    }
                }

                if (rateValue != null && rateValue != undefined  &&
                quantity != null && quantity != undefined ) 
                    {
                    rateValue = parseFloat(rateValue);
                    quantity = parseFloat(quantity);

                    finalExtendedCost = rateValue * quantity;
                    finalSingleExtendedCost = parseFloat(rateValue).toFixed(2);
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                }
            }

            if (fieldName == 'buildertek__Workers_Comp__c') 
            {
                console.log('Workers Comp FOUND');
                var nominatorValue = 0;
                var denominatorVal = 0;
                var installCost = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Denominator Rate') 
                    {
                        denominatorVal = dataList[i].value;
                    }
                    if (dataList[i].label == 'Rate') 
                    {
                        nominatorValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Install Cost') 
                    {
                        installCost = dataList[i].value;
                    }
                }

                if (installCost != null && installCost != undefined  &&
                nominatorValue != null && nominatorValue != undefined  &&
                denominatorVal != null && denominatorVal != undefined ) 
                {
                    installCost = parseFloat(installCost);
                    nominatorValue = parseFloat(nominatorValue);
                    denominatorVal = parseFloat(denominatorVal);

                    finalExtendedCost = installCost * (nominatorValue / denominatorVal);
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                    finalSingleExtendedCost = 0;
                }
            }

            if (fieldName == 'buildertek__General_Liability_Insurance_Long__c') 
            {
                console.log('General Liability FOUND');
                var nominatorValue = 0;
                var denominatorVal = 0;
                var proposalAmount = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Denominator Rate') 
                    {
                        denominatorVal = dataList[i].value;
                    }
                    if (dataList[i].label == 'Rate') 
                    {
                        nominatorValue = dataList[i].value;
                    }
                    if (dataList[i].label == 'Proposal Amount') 
                    {
                        proposalAmount = dataList[i].value;
                    }
                }

                if (proposalAmount != null && proposalAmount != undefined &&
                nominatorValue != null && nominatorValue != undefined  &&
                denominatorVal != null && denominatorVal != undefined ) 
                {
                    proposalAmount = parseFloat(proposalAmount);
                    nominatorValue = parseFloat(nominatorValue);
                    denominatorVal = parseFloat(denominatorVal);

                    finalExtendedCost = proposalAmount * (nominatorValue / denominatorVal);
                    finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
                    finalSingleExtendedCost = 0;
                }
            }

            if (fieldName == 'buildertek__Textura_Fee__c') 
            {
                console.log('Textura FOUND');
                var rate = 0;
                var proposalAmount = 0;
                var texturaFeeValue = 0;

                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Rate') 
                    {
                        rate = dataList[i].value;
                    }
                    if (dataList[i].label == 'Proposal Amount') 
                    {
                        proposalAmount = dataList[i].value;
                    }
                }
                console.log('rate-->'+rate);
                if (proposalAmount != null && proposalAmount != undefined  &&
                rate != null && rate != undefined ) 
                {
                    proposalAmount = parseFloat(proposalAmount);
                    rate = parseFloat(rate);
                    console.log('rate-->'+rate);

                    texturaFeeValue = proposalAmount * rate ;
                    console.log('texturaFeeValue-->'+texturaFeeValue);
                    texturaFeeValue = parseFloat(texturaFeeValue).toFixed(2);
                    console.log('texturaFeeValue-->'+texturaFeeValue);

                    if (texturaFeeValue > 499.99 && texturaFeeValue < 3750.01) {
                        finalExtendedCost = parseFloat(texturaFeeValue).toFixed(2);
                    }
                    else if (texturaFeeValue < 500.00) {
                        finalExtendedCost = 500.00;
                    }
                    else if (texturaFeeValue > 3750.00) {
                        finalExtendedCost = 3750.00;
                    }

                    //Storing the Value column into single extended cost
                    finalSingleExtendedCost = texturaFeeValue;

                    if (texturaFeeValue != null && texturaFeeValue != undefined &&
                        finalSingleExtendedCost != null && finalSingleExtendedCost != undefined &&
                        finalExtendedCost != null && finalExtendedCost != undefined)
                    {
                        for (var i = 0; i < dataList.length; i++) 
                        {
                            if (dataList[i].label == 'Extended Cost') 
                            {
                                dataList[i].value = finalExtendedCost;
                            }
                            if (dataList[i].label == 'Value') 
                            {
                                dataList[i].value = Number(texturaFeeValue);
                            }
                            if (dataList[i].label == 'Single Extended Cost') 
                            {
                                dataList[i].value = finalSingleExtendedCost;
                            }
                        }

                        component.set("v.rateEditMode", false);
                        component.set("v.percentageEditMode", false);
                        component.set("v.taxEditMode", false);
                        component.set('v.singleList', dataList);
                    }
                }
            }



            console.log('finalExtendedCost ==', finalExtendedCost);
            console.log('finalSingleExtendedCost ==', finalSingleExtendedCost);
            if (finalExtendedCost != null && finalExtendedCost != undefined &&
                finalSingleExtendedCost != null && finalSingleExtendedCost != undefined && fieldName != 'buildertek__Textura_Fee__c') 
            {
                console.log('finalExtendedCost Inside==', finalExtendedCost);
                for (var i = 0; i < dataList.length; i++) 
                {
                    if (dataList[i].label == 'Extended Cost') 
                    {
                        dataList[i].value = finalExtendedCost;
                    }
                    if (dataList[i].label == 'Single Extended Cost') 
                    {
                        dataList[i].value = finalSingleExtendedCost;
                    }
                    if (dataList[i].label == 'Value') 
                    {
                        dataList[i].value = finalExtendedCost;
                    }
                }
				
                console.log('** dataList ------------->:' + dataList);
                // component.set('v.singleList',[]);
                 component.set("v.rateEditMode", false);
                 component.set("v.percentageEditMode", false);
                component.set("v.taxEditMode", false);
                 component.set('v.singleList',dataList);
            }
            console.log('dataList--',component.get('v.singleList'));
        }
    },
    saveUpdatedRecord: function (component, event, helper) 
    {
        var action = component.get("c.saveData");
        var wrapList = component.get('v.wholeTableData');
        var recordId = component.get('v.billOfMaterialId');
        var fieldName = component.get('v.fieldNameToOperate');

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

                } else {
                    console.log('@@Return Value False');

                }

            } else {
                console.log('@@Not Success');

            }

        });
        $A.enqueueAction(action);
    },
})