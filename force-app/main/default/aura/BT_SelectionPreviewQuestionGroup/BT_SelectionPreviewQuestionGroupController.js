({
    doInit: function (component, event, helper) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.baseURLs", baseURL);
        console.log('errorMessage::', component.get('v.errorMessage'));
    },

    twistAccordion: function (component, event, helper) {

    },

    onChangerequiredReload: function (component, event, helper) {
        if (component.get("v.requiredReload")) {
            $A.get('e.force:refreshView').fire();
        }
    },

    printRecords: function (component, event, helper) {
        var target = event.target;
        var selectionId = target.getAttribute("data-selection-id");
        var baseURLs = component.get('v.baseURLs');
        console.log('Selection Id ::', selectionId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": baseURLs + '/apex/buildertek__BT_SelectionPrint?Id=' + selectionId
        });
        urlEvent.fire();
    },

    handleErrorMessage: function (component, event, helper) {
        var warningMessage = event.getParam("warningMessage"); // getting the value of event attribute
        console.log('name:::' + JSON.stringify(name));
        console.log('errorMessage::::');
        component.set('v.errorMessage', warningMessage);
    },
    /* Here prepare submit confirmation modal*/
    submitRecordModal: function (component, event, helper) {
        var overlayLib;
        if (component.get('v.errorMessage') != '' && component.get('v.errorMessage') != undefined) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: component.get('v.errorMessage'),
                type: 'warning',
            });
            toastEvent.fire();

        } else {
            $A.createComponents(
                [
                    ["aura:html", {
                        "tag": "h2",
                        "body": "Confirmation",
                        "HTMLAttributes": {
                            "class": "slds-text-heading_medium slds-hyphenate"
                        }
                    }],
                    ["lightning:button", {
                        "aura:id": "Yes_button",
                        "label": "Yes",
                        "name": "yes",
                        "variant": "brand",
                        "onclick": component.getReference("c.submitData")
                    }],
                    ["lightning:button", {
                        "aura:id": "no_button",
                        "label": "No",
                        "name": "no",
                        "onclick": component.getReference("c.cancel")
                    }]

                ],
                function (contant, status) {
                    if (status === "SUCCESS") {
                        var footer = [];
                        footer.push(contant[1]);
                        footer.push(contant[2]);
                        overlayLib = component.find('overlayLib').showCustomModal({
                            header: contant[0],
                            body: "Are you sure you want to Submit your choices?",
                            footer: footer,
                            showCloseButton: true
                        });
                        component.set("v.overlayLib", overlayLib);
                    }
                }
            );
        }
    },

    submit: function (component, event, helper) {
        component.get('v.overlayLib').then(function (modal) {
            modal.close();
        });

        var selectionType = component.get("v.st");
        var options = selectionType.selectionOptions;
        console.log('options', options);
        var checkResult, checkResults = [];
        var answerChoice, answerChoices = [];
        var error = false;
        var selectionTypeobj = new Object();
        for (var i in options) {
            if (options[i].responses != undefined) {
                for (var j in options[i].responses) {
                    if (options[i].responses[j].items != undefined) {
                        console.log('options[i].responses[j].items::', options[i].responses[j].items);
                        for (var k in options[i].responses[j].items) {
                            console.log('options[i].responses[j].items::', options[i].responses[j].items);
                            if (options[i].responses[j].items[k].Id == undefined ||
                                options[i].responses[j].items[k].value == undefined) {
                                //options[i].errorMessage = 'Required!';
                                error = true;
                            } else {
                                //options[i].errorMessage = '';
                                if (options[i].responses[j].Drop_Down_Value__c == 'Single Select') {
                                    answerChoice = new Object();
                                    answerChoice.Id = options[i].responses[j].items[k].Id;
                                    answerChoice.buildertek__Check_Result__c = options[i].responses[j].items[k].value;
                                    answerChoices.push(answerChoice);
                                }
                                /*else if(options[i].responses[j].Drop_Down_Value__c== 'Single Select'){
                                                                    
                                                                }*/
                            }
                        }
                    }
                }
            }


            /*if(options[i].check.buildertek__Answer_Choices__r!=undefined){
                for(var j=0;j<options[i].check.buildertek__Answer_Choices__r.length;j++){
                    if(options[i].check.buildertek__Answer_Choices__r[j]==undefined ||
                       options[i].check.buildertek__Answer_Choices__r[j].buildertek__Text_Value__c==undefined ||
                       options[i].check.buildertek__Answer_Choices__r[j].buildertek__Text_Value__c==''){
                        options[i].errorMessage = 'Required!';
                        error = true;
                    }else{
                        options[i].errorMessage = '';
                        if(options[i].check.buildertek__Question_Type__c == 'Single Select') {
                            answerChoice = new Object();
                            answerChoice.Id = options[i].checkResult.Id;
                            answerChoice.buildertek__Choice_Text__c = options[i].check.buildertek__Answer_Choices__r[j].buildertek__Choice_Text__c;
                            answerChoices.push(answerChoice);
                        } else if(options[i].check.buildertek__Question_Type__c == 'Multi Select') {
                            if(options[i].multiSelectChoiceValues.length > 0){
                                for(var j in options[i].multiSelectChoiceValues) {
                                    answerChoice = new Object();
                                    answerChoice.Id = options[i].multiSelectChoiceValues[j];
                                    answerChoice.buildertek__Check_Result__c = options[i].checkResult.Id;
                                    answerChoices.push(answerChoice);
                                }
                            } else {
                                options[i].errorMessage = 'Required!';
                                error = true;
                            }
                        } 
                    }
                }
            }*/
            checkResults.push(options[i].checkResult);
        }

        if (error === true) {
            selectionType.selectionOptions = options;
            component.set("v.st", selectionType);
            return false;
        } else {
            selectionTypeobj.buildertek__Tested__c = true;
            selectionTypeobj.Id = selectionType.selectionType.Id;
            var overlayLib;

            $A.createComponents(
                [
                    ["aura:html", {
                        "tag": "h2",
                        "body": "Confirmation",
                        "HTMLAttributes": {
                            "class": "slds-text-heading_medium slds-hyphenate"
                        }
                    }],
                    ["lightning:button", {
                        "aura:id": "Yes_button",
                        "label": "Yes",
                        "name": "yes",
                        "variant": "brand",
                        "onclick": component.getReference("c.submitData")
                    }],
                    ["lightning:button", {
                        "aura:id": "no_button",
                        "label": "No",
                        "name": "no",
                        "onclick": component.getReference("c.cancel")
                    }]

                ],
                function (contant, status) {
                    if (status === "SUCCESS") {
                        var footer = [];
                        footer.push(contant[1]);
                        footer.push(contant[2]);
                        overlayLib = component.find('overlayLib').showCustomModal({
                            header: contant[0],
                            body: "You are about to submit selected options." +
                                " Are you sure you want to continue ?",
                            footer: footer,
                            showCloseButton: true
                        });
                        component.set("v.overlayLib", overlayLib);
                    }
                }
            );
        }

    },

    cancel: function (component, event, helper) {
        component.get('v.overlayLib').then(function (modal) {
            modal.close();
        });
    },

    submitData: function (component, event, helper) {

        component.get('v.overlayLib').then(function (modal) {
            modal.close();
        });

        var selectionType = component.get("v.st");
        var options = selectionType.selectionOptions;
        var checkResult, checkResults = [];
        var answerChoice, answerChoices = [];
        var error = false;
        var selectionTypeobj = new Object();
        console.log('ST::', JSON.parse(JSON.stringify(selectionType)));
        debugger;
        for (var i in options) {
            /*if(options[i].check.buildertek__Answer_Choices__r!=undefined){
                for(var j=0;j<options[i].check.buildertek__Answer_Choices__r.length;j++){
                    if(options[i].check.buildertek__Answer_Choices__r[j]==undefined ||
                       options[i].check.buildertek__Answer_Choices__r[j].buildertek__Text_Value__c==undefined ||
                       options[i].check.buildertek__Answer_Choices__r[j].buildertek__Text_Value__c==''){
                        options[i].errorMessage = 'Required!';
                        error = true;
                    }else{
                        options[i].errorMessage = '';
                        if(options[i].check.buildertek__Question_Type__c == 'Single Select') {
                            answerChoice = new Object();
                            answerChoice.Id = options[i].checkResult.Id;
                            answerChoice.buildertek__Choice_Text__c = options[i].check.buildertek__Answer_Choices__r[j].buildertek__Choice_Text__c;
                            answerChoices.push(answerChoice);
                        } else if(options[i].check.buildertek__Question_Type__c == 'Multi Select') {
                            /*if(options[i].multiSelectChoiceValues.length > 0){
                                for(var j in options[i].multiSelectChoiceValues) {
                                    answerChoice = new Object();
                                    answerChoice.Id = options[i].multiSelectChoiceValues[j];
                                    answerChoice.buildertek__Check_Result__c = options[i].checkResult.Id;
                                    answerChoices.push(answerChoice);
                                }
                            } else {
                                options[i].errorMessage = 'Required!';
                                error = true;
                            } 
                        } 
                    }
                }
            }*/
            checkResults.push(options[i].checkResult);
        }
        if (error === true) {
            selectionType.selectionOptions = options;
            component.set("v.st", selectionType);
            return false;
        } else {
            console.log('selectionType.selectionType.Id::', selectionType.selectionType.Id);
            selectionTypeobj.Id = selectionType.selectionType.Id;
            selectionTypeobj.buildertek__Section__c = selectionType.selectionType.buildertek__Section__c;
            selectionTypeobj.buildertek__Tested__c = true;
            console.log('selectionTypeobj::', JSON.parse(JSON.stringify(selectionTypeobj)));
            helper.update(component, event, helper, selectionTypeobj, checkResults, answerChoices);
        }
    }
})