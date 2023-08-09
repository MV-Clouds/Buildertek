({


    fetchpricebooks: function (component, event, helper) {
        var actions = component.get("c.getpricebooks");
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: ""
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                component.set("v.pricebookoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },

    ongetQuestionInfo: function (component, event, helper) {
        component.set("v.imageId", null);
        component.set("v.documentId", null);
        var selectedLookUpRecord = component.get("v.selectedLookUpRecord");
        if (selectedLookUpRecord != undefined && selectedLookUpRecord.Id != undefined && selectedLookUpRecord.Id != '' &&
            component.get("v.pricebookName") != undefined && component.get("v.pricebookName") != '') {

            var action = component.get("c.getQuestionInfo");
            action.setParams({
                productId: selectedLookUpRecord.Id,
                priceBookId: component.get("v.pricebookName")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var rslt = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rslt != undefined) {
                    console.log('Product Details::', rslt);
                    if (rslt.imageId != undefined) {
                        component.set("v.imageId", rslt.imageId);
                    }
                    if (rslt.documentId != undefined) {
                        component.set("v.documentId", rslt.documentId);
                    }
                    if (rslt.PriceBookEntry != undefined) {
                        var result = rslt.PriceBookEntry;
                        var setupFieldEle = component.find("setupField");
                        var setupField = component.get("v.questionDetail.questionSetupFields");
                        console.log('setupField::', setupField);
                        if (setupField == undefined || setupField.length == 0) {
                            return;
                        }
                        var instructionIndex = setupField.indexOf('buildertek__Instructions__c');
                        var costIndex = setupField.indexOf('buildertek__Cost__c');
                        var nameIndex = setupField.indexOf('Name');
                        var vendorIndex = setupField.indexOf('buildertek__Vendor__c');
                        var manufacturerIndex = setupField.indexOf('buildertek__Manufacturer__c');
                        var skuIndex = setupField.indexOf('buildertek__StockKeepingUnit__c');
                        var productcodeIndex = setupField.indexOf('buildertek__ProductCode__c');
                        var finishIndex = setupField.indexOf('buildertek__Finish__c');
                        //var colorIndex = setupField.indexOf('buildertek__Color__c');
                        var colorIndex = setupField.indexOf('buildertek__BT_COLOR__c');
                        var questionHTMLIndex = setupField.indexOf('buildertek__Question_HTML__c');
                        if (setupFieldEle.length > 0) {
                            if (instructionIndex != undefined && setupFieldEle.length > instructionIndex) {
                                if (result.Product2.buildertek__Instructions__c != undefined) {
                                    setupFieldEle[instructionIndex].set("v.value", result.Product2.buildertek__Instructions__c);
                                }
                            }
                            if (costIndex != undefined && setupFieldEle.length > costIndex) {
                                setupFieldEle[costIndex].set("v.value", result.UnitPrice);
                            }
                            if (nameIndex != undefined && setupFieldEle.length > nameIndex && result.Product2.Name != undefined) {
                                setupFieldEle[nameIndex].set("v.value", result.Product2.Name);
                            }
                            if (questionHTMLIndex != undefined && setupFieldEle.length > questionHTMLIndex && result.Product2.Description != undefined) {
                                setupFieldEle[questionHTMLIndex].set("v.value", result.Product2.Description);
                            }
                            if (vendorIndex > 0 && vendorIndex != undefined && setupFieldEle.length > vendorIndex && result.Product2.buildertek__Vendor__c != undefined) {
                                setupFieldEle[vendorIndex].set("v.value", result.Product2.buildertek__Vendor__c);
                            }
                            if (manufacturerIndex != undefined && setupFieldEle.length > manufacturerIndex && result.Product2.buildertek__Manufacturer__c != undefined) {
                                setupFieldEle[manufacturerIndex].set("v.value", result.Product2.buildertek__Manufacturer__c);
                            }
                            if (skuIndex != undefined && setupFieldEle.length > skuIndex && result.Product2.StockKeepingUnit != undefined) {
                                setupFieldEle[skuIndex].set("v.value", result.Product2.StockKeepingUnit);
                            }
                            if (productcodeIndex != undefined && setupFieldEle.length > productcodeIndex && result.Product2.ProductCode != undefined) {
                                setupFieldEle[productcodeIndex].set("v.value", result.Product2.ProductCode);
                            }
                            if (finishIndex != -1 && finishIndex != undefined && setupFieldEle.length > finishIndex && result.Product2.buildertek__Finish__c != undefined) {
                                setupFieldEle[finishIndex].set("v.value", result.Product2.buildertek__Finish__c);
                            }
                            /*if (colorIndex != -1 && colorIndex != undefined && setupFieldEle.length > colorIndex && result.Product2.buildertek__Color__c != undefined) {
                                setupFieldEle[colorIndex].set("v.value", result.Product2.buildertek__Color__c);
                            }*/
                            if (colorIndex != -1 && colorIndex != undefined && setupFieldEle.length > colorIndex && result.Product2.buildertek__BT_COLOR__c != undefined) {
                                setupFieldEle[colorIndex].set("v.value", result.Product2.buildertek__BT_COLOR__c);
                            }
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    onchangeProductHelper: function (component, event, helper) {
        var selectedLookUpRecord = component.get("v.selectedLookUpRecord");
        var pricebookNameJS = component.get("v.pricebookName");
        if (selectedLookUpRecord.Id != undefined && selectedLookUpRecord.Id != '' && pricebookNameJS != undefined) {
            var productIdJS = selectedLookUpRecord.Id;
            var param = pricebookNameJS + '-' + productIdJS;
            var action1 = component.get("c.product2Detail");
            action1.setParams({
                "data": param
            });
            action1.setCallback(this, function (response) {
                var result = response.getReturnValue();
                if (response.getState() == "SUCCESS" && result != null) {

                    var setupFieldEle = component.find("setupField");
                    var setupField = component.get("v.questionDetail.questionSetupFields");
                    if (setupField == undefined || setupField.length == 0) {
                        return;
                    }
                    var instructionIndex = setupField.indexOf('buildertek__Instructions__c');
                    var costIndex = setupField.indexOf('buildertek__Cost__c');
                    var questionHTMLIndex = setupField.indexOf('buildertek__Question_HTML__c');
                    var vendorIndex = setupField.indexOf('buildertek__Vendor__c');
                    var manufacturerIndex = setupField.indexOf('buildertek__Manufacturer__c');
                    var skuIndex = setupField.indexOf('StockKeepingUnit');
                    var productcodeIndex = setupField.indexOf('ProductCode');
                    var finishIndex = setupField.indexOf('buildertek__Finish__c');
                    //var colorIndex = setupField.indexOf('buildertek__Color__c');
                    var colorIndex = setupField.indexOf('buildertek__BT_COLOR__c');

                    if (setupFieldEle.length > 0) {
                        if (instructionIndex != undefined && setupFieldEle.length > instructionIndex) {
                            if (result.Product2.buildertek__Instructions__c != undefined) {
                                setupFieldEle[instructionIndex].set("v.value", result.Product2.buildertek__Instructions__c);
                            }
                        }
                        if (costIndex != undefined && setupFieldEle.length > costIndex) {
                            setupFieldEle[costIndex].set("v.value", result.UnitPrice);
                        }
                        if (questionHTMLIndex != undefined && setupFieldEle.length > questionHTMLIndex && result.Product2.Name != undefined) {
                            setupFieldEle[questionHTMLIndex].set("v.value", result.Product2.Name);
                        }
                        if (vendorIndex != undefined && setupFieldEle.length > vendorIndex && result.Product2.buildertek__Vendor__c != undefined) {
                            setupFieldEle[vendorIndex].set("v.value", result.Product2.buildertek__Vendor__c);
                        }
                        if (manufacturerIndex != undefined && setupFieldEle.length > manufacturerIndex && result.Product2.buildertek__Manufacturer__c != undefined) {
                            setupFieldEle[manufacturerIndex].set("v.value", result.Product2.buildertek__Manufacturer__c);
                        }
                        if (skuIndex != undefined && setupFieldEle.length > skuIndex && result.Product2.StockKeepingUnit != undefined) {
                            setupFieldEle[skuIndex].set("v.value", result.Product2.StockKeepingUnit);
                        }
                        if (productcodeIndex != undefined && setupFieldEle.length > productcodeIndex && result.Product2.ProductCode != undefined) {
                            setupFieldEle[productcodeIndex].set("v.value", result.Product2.ProductCode);
                        }
                        if (finishIndex != -1 && finishIndex != undefined && setupFieldEle.length > finishIndex && result.Product2.buildertek__Finish__c != undefined) {
                            setupFieldEle[finishIndex].set("v.value", result.Product2.buildertek__Finish__c);
                        }
                        /*if (colorIndex != -1 && colorIndex != undefined && setupFieldEle.length > colorIndex && result.Product2.buildertek__Color__c != undefined) {
                            setupFieldEle[colorIndex].set("v.value", result.Product2.buildertek__Color__c);
                        }*/
                        if (colorIndex != -1 && colorIndex != undefined && setupFieldEle.length > colorIndex && result.Product2.buildertek__BT_COLOR__c != undefined) {
                            setupFieldEle[colorIndex].set("v.value", result.Product2.buildertek__BT_COLOR__c);
                        }
                    }
                }
            });
            $A.enqueueAction(action1);
        } else {}
    },
    fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptionsforproductfamily");
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: ""
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                component.set("v.productfamilyoptions", opts);
                console.log(JSON.stringify(opts));
            }
        });
        $A.enqueueAction(actions);
    },
    getProductAttributes: function (component, event, helper) {
        var responseList = component.get('v.responseTypeList');
        var action = component.get("c.getAllProductAttributes");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue()) {
                var response = response.getReturnValue();
                console.log('Response Product::', response);
                var attributes = [];
                if (response.Color != undefined) {
                    var obj = {};
                    obj.responseTypeName = 'Color';
                    obj.selectedResponsetypeValue = "Single Select~Drop Down";
                    var selectionChoice = [];
                    for (var i in response.Color) {
                        var obj1 = {};
                        obj1.buildertek__Choice_Text__c = response.Color[i];
                        selectionChoice.push(obj1);
                    }
                    obj.selectionChoices = selectionChoice;
                    attributes.push(obj);
                }
                if (response.Finish != undefined) {
                    var obj = {};
                    obj.responseTypeName = 'Finish';
                    obj.selectedResponsetypeValue = "Single Select~Drop Down";
                    var selectionChoice = [];
                    for (var i in response.Finish) {
                        var obj1 = {};
                        obj1.buildertek__Choice_Text__c = response.Finish[i];
                        selectionChoice.push(obj1);
                    }
                    obj.selectionChoices = selectionChoice;
                    attributes.push(obj);
                }
                if (response.Option != undefined) {
                    var obj = {};
                    obj.responseTypeName = 'Option Number';
                    obj.selectedResponsetypeValue = "Single Select~Drop Down";
                    var selectionChoice = [];
                    for (var i in response.Option) {
                        var obj1 = {};
                        obj1.buildertek__Choice_Text__c = response.Option[i];
                        selectionChoice.push(obj1);
                    }
                    obj.selectionChoices = selectionChoice;
                    attributes.push(obj);
                }
                if (response.Category != undefined) {
                    var obj = {};
                    obj.responseTypeName = 'Selection Category';
                    obj.selectedResponsetypeValue = "Single Select~Drop Down";
                    var selectionChoice = [];
                    for (var i in response.Category) {
                        var obj1 = {};
                        obj1.buildertek__Choice_Text__c = response.Category[i];
                        selectionChoice.push(obj1);
                    }
                    obj.selectionChoices = selectionChoice;
                    attributes.push(obj);
                }
                console.log('Attributes::', attributes);
                component.set('v.responseTypeList', attributes);
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    fetchproductfamily: function (component, event, helper) {
        var actions = component.get("c.getselectOptionsforproductfamily");
        actions.setParams({
            "budgetObject": "Product2",
            "budgetField": "Family"
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                //opts.push({key: "None", value: "" });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                component.set("v.productfamilyoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },
    /*Get the fields list form fieldset based on question group record type Name */
    getFieldSet: function (component) {
        var controlRecordTypeName = component.get("v.questionGroup");
        var fieldSet = "buildertek__Question_Fields";
        var getFieldSet = component.get("c.getQuestionFieldSet");
        getFieldSet.setParams({
            fieldSetName: fieldSet
        });

        getFieldSet.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.questionDetail", response.getReturnValue());
                console.log('QuestionDetail::', response.getReturnValue());
                component.set("v.namespace", response.getReturnValue().namespacePrefix);
            }
        });
        $A.enqueueAction(getFieldSet);
    },

    /*Prepare the list of question response type Options*/
    listQuestionTypes: function (component) {
        var items = [];
        items.push({
            "label": "Single Select With Drop Down",
            "value": "Single Select~Drop Down"
        });
        items.push({
            "label": "Single Select With Radio",
            "value": "Single Select~Radio"
        });
        items.push({
            "label": "Single Select With Horizontal Radio",
            "value": "Single Select~Radio-lineDirection"
        });
        items.push({
            "label": "Multi Select With Checkbox",
            "value": "Multi Select~Checkbox"
        });
        items.push({
            "label": "Multi Select With Horizontal Checkbox",
            "value": "Multi Select~Checkbox-lineDirection"
        });
        items.push({
            "label": "Multi Select With Drop Down",
            "value": "Multi Select~Multi Select List"
        });
        items.push({
            "label": "Simple Text",
            "value": "Text~Simple Text"
        });
        items.push({
            "label": "Long Text",
            "value": "Text~Text Area"
        });
        items.push({
            "label": "Date",
            "value": "Date~Date Picker"
        });

        component.set("v.responsetypeOptions", items);
        component.set("v.selectedResponsetypeValue", "Single Select~Radio-lineDirection");

    },

    /*Show and Hide text data type base on response type*/
    questionResponseDataType: function (component, event) {

    },

    /*Used to prepare the dynamic string using list of arguments. */
    format: function (label, labelArguments) {
        var values = String(labelArguments).split(',');
        for (var i = 0; i < values.length; i++) {
            label = label.replace(new RegExp('\\{' + i + '\\}', 'gm'), values[i]);
        }
        return label;
    },

    /*This method is for validate fields before submit the record edit from*/
    validate: function (component, event) {
        return true;
    }
})