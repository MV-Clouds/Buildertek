/* Lightning Component Controller.
 * Copyright 2018-2019, @ thoriyas
 * All rights reserved
 *
 * Created by - Sagar Thoriya
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert */

({
    init: function(component, event, helper) {
        component.get("v.isLocked") && component.get("v.isResponse") ?
            component.set("v.readOnly", true) :
            component.set("v.readOnly", false);

        component.set("v.requiredReload", true);
        var action = component.get("c.checkIfCustomerCommunity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Is Customer Community::', response.getReturnValue());
                component.set("v.isCustomerCommunity", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        helper.getQuestions(component, event, helper);
        helper.getImgVisibility(component, event, helper);
    },

    radioGroupOnchange: function(component, event, helper) {},

    onOptionChange: function(component, event, helper) {
        var questions = component.get("v.questions");
        var src = event.target;
        var id = src.getAttribute("id");
        var questionId = src.getAttribute("data-Id");
        var index = src.getAttribute("data-index");
        var oldValue = src.getAttribute("data-existing-value");
        var additionalCost = 0;
        var removeAdditionalCost = 0;
        var attributeItems = [];
        var attributeItemsToRemove = [];
        var selectedValue = document.getElementById(id).value;
        var oldAnswerId = "";
        var answerId = "";
        var isParent = false;
        var parentId = '';
        var oldAnswerParentId = '';
        //Filter current options
        var question = questions.filter(function(question) {
            return question.check.Id === questionId;
        });

        additionalCost =
            parseInt(question[0].check.buildertek__Additional_Cost__c) != undefined ?
            parseInt(question[0].check.buildertek__Additional_Cost__c) :
            0;

        //Get old value
        if (question.length > 0 && question[0].responses.length > 0) {
            for (var i in question[0].responses) {
                for (var j in question[0].responses[i].items) {
                    if (question[0].responses[i].items[j].value == oldValue) {
                        question[0].responses[i].items[j].isSelected = false;
                        question[0].responses[i].values = "";
                        //question[0].check.buildertek__Image_Id__c = "";
                        oldAnswerId = question[0].responses[i].items[j].Id;
                        oldAnswerParentId = question[0].responses[i].items[j].buildertek__ParentId__c;
                        attributeItemsToRemove.push(question[0].responses[i].items[j]);
                        if (question[0].responses[i].items[j].buildertek__ParentId__c != '') {
                            question[0].responses[i].isChild = selectedValue == 'None' ? true : false;
                        }
                        for (var k in question[0].responses) {
                            for (var l in question[0].responses[k].items) {
                                if (question[0].responses[k].items[l].buildertek__ParentId__c == oldAnswerId && question[0].responses[k].items[l].value == question[0].responses[k].values) {
                                    question[0].responses[k].items[l].isSelected = false;
                                    attributeItemsToRemove.push(question[0].responses[k].items[l]);
                                    question[0].responses[k].values = "";
                                    //question[0].responses[k].buildertek__Image_Id__c = "";
                                    question[0].responses[k].isChild = selectedValue == 'None' ? true : false;
                                    for (var m in question[0].responses) {
                                        for (var n in question[0].responses[m].items) {
                                            if (question[0].responses[m].items[n].buildertek__ParentId__c == question[0].responses[k].items[l].Id) {
                                                question[0].responses[m].items[n].isSelected = false;
                                                attributeItemsToRemove.push(question[0].responses[m].items[n]);
                                                question[0].responses[m].values = "";
                                                //question[0].responses[m].buildertek__Image_Id__c = "";
                                                question[0].responses[m].isChild = selectedValue == 'None' ? true : false;
                                                for (var x in question[0].responses) {
                                                    for (var y in question[0].responses[x].items) {
                                                        if (question[0].responses[x].items[y].buildertek__ParentId__c == question[0].responses[m].items[n].Id) {
                                                            question[0].responses[x].items[y].isSelected = false;
                                                            attributeItemsToRemove.push(question[0].responses[x].items[y]);
                                                            question[0].responses[x].values = "";
                                                            //question[0].responses[x].buildertek__Image_Id__c = "";
                                                            question[0].responses[x].isChild = selectedValue == 'None' ? true : false;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // If old value exist hide them
        if (question.length > 0 && question[0].responses.length > 0) {
            for (var i in question[0].responses) {
                for (var j in question[0].responses[i].items) {
                    if (question[0].responses[i].items[j].buildertek__ParentId__c != "" &&
                        question[0].responses[i].items[j].buildertek__ParentId__c == oldAnswerId) {
                        question[0].responses[i].items[j].isVisible = true;
                        question[0].responses[i].isChild = true;
                        //question[0].responses[i].buildertek__Image_Id__c = '';
                    }
                }
            }
        }

        //Filter only selected Attribute values
        if (question.length > 0 && question[0].responses.length > 0) {
            for (var i in question[0].responses) {
                for (var j in question[0].responses[i].items) {
                    if (question[0].responses[i].items[j].value == selectedValue && selectedValue != oldValue) {
                        question[0].responses[i].items[j].isSelected = true;
                        if (question[0].responses[i].items[j].buildertek__Image_Id__c != '' && question[0].responses[i].items[j].buildertek__Image_Id__c != undefined) {
                            console.log('Image::', JSON.stringify(question[0].responses[i].items[j]));
                            question[0].check.buildertek__Temp_Image_Id__c = question[0].responses[i].items[j].buildertek__Image_Id__c;
                            question[0].check.buildertek__Temp_Document_Id__c = question[0].responses[i].items[j].buildertek__Document_Id__c;
                        }
                        question[0].responses[i].values = selectedValue;
                        answerId = question[0].responses[i].items[j].Id;
                        attributeItems.push(question[0].responses[i].items[j]);
                        //Check if Id is parent
                        if (question[0].responses[i].items[j].buildertek__ParentId__c == "") {
                            isParent = true;
                            parentId = question[0].responses[i].items[j].Id;
                        }
                    } else if (selectedValue == oldValue) {
                        debugger;
                        question[0].responses[i].items[j].isSelected = false;
                        // if (question[0].responses[i].items[j].buildertek__Image_Id__c != '' && question[0].responses[i].items[j].buildertek__Image_Id__c != undefined) {
                        //   question[0].check.buildertek__Temp_Image_Id__c = question[0].responses[i].items[j].buildertek__Image_Id__c;
                        //   question[0].check.buildertek__Temp_Document_Id__c = question[0].responses[i].items[j].buildertek__Document_Id__c;
                        // }
                        question[0].responses[i].values = '';
                        answerId = question[0].responses[i].items[j].Id;
                        attributeItems.push(question[0].responses[i].items[j]);
                        //Check if Id is parent
                        if (question[0].responses[i].items[j].buildertek__ParentId__c == "") {
                            isParent = true;
                            parentId = question[0].responses[i].items[j].Id;
                        }
                    }
                }
            }
        }
        //Filter value with Selected values
        if (question.length > 0 && question[0].responses.length > 0) {
            for (var i in question[0].responses) {
                for (var j in question[0].responses[i].items) {
                    //If Parent is change set all Attribute as a child 
                    if (isParent && question[0].responses[i].items[j].buildertek__ParentId__c != "") {
                        //question[0].responses[i].values = selectedValue;
                        question[0].responses[i].isChild = selectedValue != 'None' ? true : false;
                    }
                    //If Value is change set Attribute as a child 
                    if (question[0].responses[i].items[j].buildertek__ParentId__c == answerId) {
                        //question[0].responses[i].items[j].isVisible = false;
                        question[0].responses[i].isChild = false;
                    }
                }
            }
        }

        if (selectedValue == 'None') {
            question[0].check.buildertek__Temp_Image_Id__c = question[0].check.buildertek__Image_Id__c;
            question[0].check.buildertek__Temp_Document_Id__c = question[0].check.buildertek__Document_Id__c;
        }
        //Remove Additional Cost
        if (attributeItemsToRemove.length > 0) {
            for (var i in attributeItemsToRemove) {
                if (attributeItemsToRemove[i].buildertek__Additional_Cost__c != undefined) {
                    additionalCost -= attributeItemsToRemove[i].buildertek__Additional_Cost__c;
                }
            }
        }

        //Calculate Additional cost
        if (attributeItems.length > 0) {
            for (var i in attributeItems) {
                if (attributeItems[i].buildertek__Additional_Cost__c != undefined) {
                    additionalCost += attributeItems[i].buildertek__Additional_Cost__c;
                }
            }
        }

        //Update Additional Cost
        for (var i in questions) {
            if (i == index && questions[i].check != undefined && questions[i].check.Id != undefined) {
                if (additionalCost != undefined && questions[i].check.buildertek__Additional_Cost__c != undefined) {
                    questions[i].check.buildertek__Additional_Cost__c = additionalCost.toString();
                }
            }

            //Filter by parent child
            for (var j in questions[i].responses) {
                questions[i].responses.sort(function(x, y) {
                    //Parent first
                    return (x.isChild === y.isChild) ? 0 : x.isChild ? 1 : -1;
                });
            }
        }

        component.set("v.questions", questions);
    },

    onCheckBoxChange: function(component, event, helper) {
        var questions = component.get("v.questions");
        var src = event.target;
        var id = src.getAttribute("id");
        var questionId = src.getAttribute("data-questionId");
        var additionalCost = parseInt(src.getAttribute("data-additionalCost"));
        var index = src.getAttribute("data-index");
        var selectedValue = document.getElementById(id).value;
        var totalAdditionalCost = 0;
        var selectedValues = [];

        //Remove All selected Additional Cost from existing
        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                for (var k in questions[i].responses[index].items) {
                    if (
                        questions[i].responses[index].items[k]
                        .buildertek__Additional_Cost__c != undefined &&
                        questions[i].responses[index].items[k].isSelected != undefined &&
                        questions[i].responses[index].items[k].isSelected
                    ) {
                        totalAdditionalCost +=
                            questions[i].responses[index].items[k]
                            .buildertek__Additional_Cost__c;
                    }
                }
            }
        }
        additionalCost = additionalCost - totalAdditionalCost;

        //Assign Checkbox value True to False And False to True
        //Add Additional Cost If CheckBox is Selected
        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                for (var k in questions[i].responses[index].items) {
                    if (
                        questions[i].responses[index].items[k]
                        .buildertek__Additional_Cost__c != undefined &&
                        questions[i].responses[index].items[k].isSelected != undefined
                    ) {
                        if (questions[i].responses[index].items[k].Id == id) {
                            questions[i].responses[index].items[k].isSelected = !questions[i]
                                .responses[index].items[k].isSelected;
                        }
                        if (questions[i].responses[index].items[k].isSelected) {
                            additionalCost +=
                                questions[i].responses[index].items[k]
                                .buildertek__Additional_Cost__c;
                            selectedValues.push(questions[i].responses[index].items[k].value);
                        }
                    }
                    if (questions[i].responses[index].items[k].isSelected == undefined) {
                        if (questions[i].responses[index].items[k].Id == id) {
                            questions[i].responses[index].items[k].isSelected = true;
                            additionalCost +=
                                questions[i].responses[index].items[k]
                                .buildertek__Additional_Cost__c;
                            selectedValues.push(questions[i].responses[index].items[k].value);
                        }
                    }
                }
            }
        }

        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                questions[
                    i
                ].check.buildertek__Additional_Cost__c = additionalCost.toString();
                for (var k in questions[i].responses[index].items) {
                    if (questions[i].responses[index].items[k].Id == id) {
                        questions[i].responses[index].values = selectedValues;
                    }
                }
            }
        }
        component.set("v.questions", questions);
    },

    onRadioChange: function(component, event, helper) {
        var questions = component.get("v.questions");
        var src = event.target;
        var id = src.getAttribute("id");
        var questionId = src.getAttribute("data-questionId");
        var additionalCost = parseInt(src.getAttribute("data-additionalCost"));
        var index = src.getAttribute("data-index");
        var selectedValue = document.getElementById(id).value;
        var totalAdditionalCost = 0;
        var selectedValues = [];

        //Remove All selected Additional Cost from existing
        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                for (var k in questions[i].responses[index].items) {
                    if (
                        questions[i].responses[index].items[k]
                        .buildertek__Additional_Cost__c != undefined &&
                        questions[i].responses[index].items[k].isSelected != undefined &&
                        questions[i].responses[index].items[k].isSelected
                    ) {
                        totalAdditionalCost +=
                            questions[i].responses[index].items[k]
                            .buildertek__Additional_Cost__c;
                    }
                }
            }
        }
        additionalCost = additionalCost - totalAdditionalCost;

        //Assign Checkbox value True to False And False to True
        //Add Additional Cost If CheckBox is Selected
        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                for (var k in questions[i].responses[index].items) {
                    if (
                        questions[i].responses[index].items[k]
                        .buildertek__Additional_Cost__c != undefined &&
                        questions[i].responses[index].items[k].isSelected != undefined
                    ) {
                        if (questions[i].responses[index].items[k].Id == id) {
                            questions[i].responses[index].items[k].isSelected = !questions[i]
                                .responses[index].items[k].isSelected;
                        } else {
                            questions[i].responses[index].items[k].isSelected = false;
                        }
                        if (questions[i].responses[index].items[k].isSelected) {
                            additionalCost +=
                                questions[i].responses[index].items[k]
                                .buildertek__Additional_Cost__c;
                            selectedValues.push(questions[i].responses[index].items[k].value);
                        }
                    }
                    if (questions[i].responses[index].items[k].isSelected == undefined) {
                        if (questions[i].responses[index].items[k].Id == id) {
                            questions[i].responses[index].items[k].isSelected = true;
                            additionalCost +=
                                questions[i].responses[index].items[k]
                                .buildertek__Additional_Cost__c;
                            selectedValues.push(questions[i].responses[index].items[k].value);
                        }
                    }
                }
            }
        }

        for (var i in questions) {
            if (
                questions[i].check != undefined &&
                questions[i].check.Id != undefined &&
                questions[i].check.Id == questionId
            ) {
                questions[
                    i
                ].check.buildertek__Additional_Cost__c = additionalCost.toString();
                for (var k in questions[i].responses[index].items) {
                    if (questions[i].responses[index].items[k].Id == id) {
                        questions[i].responses[index].values = selectedValues;
                    }
                }
            }
        }
        component.set("v.questions", questions);
    },

    deleteOptionImage: function(component, event, helper) {
        var questionId = event.target.getAttribute("data-checkId");
        if (questionId != undefined) {
            component.set("v.isOptionImageDelete", true);
            component.set("v.optionImageDeleteId", questionId);
        }
    },
    closeDeleteImage: function(component, event, helper) {
        component.set("v.isOptionImageDelete", false);
        component.set("v.optionImageDeleteId", "");
    },
    deleteConfirmImage: function(component, event, helper) {
        var questionId = component.get("v.optionImageDeleteId");
        if (questionId != undefined) {
            var action = component.get("c.deleteImage");
            action.setParams({
                questionId: questionId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isOptionImageDelete", false);
                    component.set("v.optionImageDeleteId", "");
                    component.set("v.requiredReload", true);
                    helper.getQuestions(component, event, helper);
                }
            });
            $A.enqueueAction(action);
        }
    },

    handleTreeNodeClick: function(component, event, helper) {
        var nodeData = event.getParam("nodeData"),
            actionType = event.getParam("actionType");

        if (nodeData != undefined && nodeData.key != undefined) {
            if (actionType == 'nodeclick' && document.getElementById(nodeData.key) != null) {
                document.getElementById(nodeData.key).scrollIntoView(true);
                window.scrollBy(0, -250);
            }
        }
    },

    selectedItem: function(component, event, helper) {
        var isChangeOrder = component.get("v.isChangeOrder");
        var target = event.getSource();
        var optionsLabel = target.get("v.label");
        var optionsValue = event.getSource().get("v.value");
        console.log("optionsValue::", optionsValue);
        var question = JSON.parse(JSON.stringify(component.get("v.questions")));
        var overlayLib;
        var optionId = event.getSource().get("v.name");
        component.set("v.optionId", optionId);
        console.log("OptionId::", optionId);

        var state;
        var subaction;
        var isOverageAllowed = false;
        var overageAction = component.get("c.retriveAllowanceOverage");
        overageAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue()) {
                isOverageAllowed = response.getReturnValue();
            }
        });
        $A.enqueueAction(overageAction);
        var action = component.get("c.retriveChangeNodeConfig");
        var optionName;
        var projectId;
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                if (question != undefined) {
                    var optionOverage = 0.0;
                    var allowanceRemaining = 0.0;
                    var optionCost = 0.0;
                    var optionId = component.get("v.optionId");
                    for (var i = 0; i < question.length; i++) {
                        if (!isOverageAllowed) {
                            if (
                                question[i].check != undefined &&
                                question[i].check.Id == optionId &&
                                question[i].check.buildertek__Is_Selected_Item__c !=
                                undefined &&
                                question[i].check.buildertek__Is_Selected_Item__c &&
                                question[i].check.buildertek__Cost__c != undefined &&
                                response.getReturnValue()
                            ) {
                                optionCost = question[i].check.buildertek__Cost__c;
                                if (
                                    question[i].check.buildertek__Question_Group__r !=
                                    undefined &&
                                    question[i].check.buildertek__Question_Group__r
                                    .buildertek__Allowance_Remaining__c != null &&
                                    optionCost >
                                    question[i].check.buildertek__Question_Group__r
                                    .buildertek__Allowance_Remaining__c
                                ) {
                                    allowanceRemaining =
                                        question[i].check.buildertek__Question_Group__r
                                        .buildertek__Allowance_Remaining__c;
                                    optionOverage = optionCost - allowanceRemaining;
                                    optionOverage = new Intl.NumberFormat("en-US", {
                                        style: "currency",
                                        currency: "USD",
                                    }).format(optionOverage);
                                    $A.createComponents(
                                        [
                                            [
                                                "aura:html",
                                                {
                                                    tag: "h2",
                                                    body: "Confirmation",
                                                    HTMLAttributes: {
                                                        class: "slds-text-heading_medium slds-hyphenate",
                                                    },
                                                },
                                            ],
                                            [
                                                "lightning:button",
                                                {
                                                    "aura:id": "Yes_button",
                                                    label: "Yes",
                                                    name: "yes",
                                                    variant: "brand",
                                                    onclick: component.getReference("c.submitData"),
                                                },
                                            ],
                                            [
                                                "lightning:button",
                                                {
                                                    "aura:id": "no_button",
                                                    label: "No",
                                                    name: "no",
                                                    onclick: component.getReference("c.cancel"),
                                                },
                                            ],
                                        ],
                                        function(contant, status) {
                                            if (status === "SUCCESS") {
                                                var footer = [];
                                                var message =
                                                    "If you choose this Option you will be exceeding your remaining allowance available." +
                                                    " " +
                                                    "If you would like to proceed a Change Order will be created for the amount of " +
                                                    optionOverage +
                                                    " ";
                                                footer.push(contant[1]);
                                                footer.push(contant[2]);
                                                overlayLib = component
                                                    .find("overlayLib")
                                                    .showCustomModal({
                                                        header: contant[0],
                                                        body: message,
                                                        footer: footer,
                                                        showCloseButton: true,
                                                    });
                                                component.set("v.overlayLib", overlayLib);
                                            }
                                        }
                                    );
                                    break;
                                }
                            } else if (!response.getReturnValue()) {
                                $A.createComponents(
                                    [
                                        [
                                            "lightning:button",
                                            {
                                                "aura:id": "no_button",
                                                label: "Ok",
                                                name: "ok",
                                                onclick: component.getReference("c.cancelChangeOrder"),
                                            },
                                        ],
                                    ],
                                    function(contant, status) {
                                        if (status === "SUCCESS") {
                                            var footer = [];
                                            var message =
                                                "You cannot select this option it is over your allowance.";
                                            footer.push(contant[0]);
                                            overlayLib = component
                                                .find("overlayLib")
                                                .showCustomModal({
                                                    body: message,
                                                    footer: footer,
                                                    showCloseButton: false,
                                                });
                                            component.set("v.overlayLib", overlayLib);
                                        }
                                    }
                                );
                                break;
                            } else if (
                                question[i].check != undefined &&
                                question[i].check.Id == optionId &&
                                question[i].check.buildertek__Is_Selected_Item__c !=
                                undefined &&
                                !question[i].check.buildertek__Is_Selected_Item__c &&
                                response.getReturnValue()
                            ) {
                                optionName = question[i].check.Name;
                                console.log("OptionName::", optionName);
                                subaction = component.get("c.getChangeOrderIdExist");
                                subaction.setParams({
                                    projectId: component.get("v.projectName"),
                                    optionName: optionName,
                                });
                                subaction.setCallback(this, function(response) {
                                    var result = response.getState();
                                    if (
                                        response.getState() === "SUCCESS" &&
                                        response.getReturnValue()
                                    ) {
                                        $A.createComponents(
                                            [
                                                [
                                                    "lightning:button",
                                                    {
                                                        "aura:id": "no_button",
                                                        label: "Ok",
                                                        name: "ok",
                                                        onclick: component.getReference("c.cancelPopUp"),
                                                    },
                                                ],
                                            ],
                                            function(contant, status) {
                                                if (status === "SUCCESS") {
                                                    var footer = [];
                                                    var message =
                                                        "A change order has already been submitted for this option.  Please contact us in order to remove this option from your selection choice.";
                                                    footer.push(contant[0]);
                                                    overlayLib = component
                                                        .find("overlayLib")
                                                        .showCustomModal({
                                                            body: message,
                                                            footer: footer,
                                                            showCloseButton: false,
                                                        });
                                                    component.set("v.overlayLib", overlayLib);
                                                }
                                            }
                                        );
                                    }
                                });
                                $A.enqueueAction(subaction);
                            }
                        } else {
                            //var a = component.get('c.submitData');
                            ///$A.enqueueAction(a);
                        }
                    }
                }
            }
        });

        //component.set('v.questions',question);

        $A.enqueueAction(action);
    },

    /* Here prepare confirmation modal*/
    savaeRecordModal: function(component, event, helper) {
        if (
            component.get("v.errorMessage") != "" &&
            component.get("v.errorMessage") != undefined
        ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: component.get("v.errorMessage"),
                type: "warning",
            });
            toastEvent.fire();
        } else {
            var target = event.target;
            var index = target.getAttribute("data-selected-index");
            component.set("v.currentIndex", index);
            $A.createComponents(
                [
                    [
                        "aura:html",
                        {
                            tag: "h2",
                            body: "Confirmation",
                            HTMLAttributes: {
                                class: "slds-text-heading_medium slds-hyphenate",
                            },
                        },
                    ],
                    [
                        "lightning:button",
                        {
                            "aura:id": "Yes_button",
                            label: "Yes",
                            name: "yes",
                            variant: "brand",
                            onclick: component.getReference("c.saveAttributeType"),
                        },
                    ],
                    [
                        "lightning:button",
                        {
                            "aura:id": "cancel_button",
                            label: "Cancel",
                            name: "Cancel",
                            onclick: component.getReference("c.cancel"),
                        },
                    ],
                ],
                function(components, status) {
                    var buttons = [];
                    buttons.push(components[1]);
                    buttons.push(components[2]);
                    if (status === "SUCCESS") {
                        var modalPromise = component.find("overlayLib").showCustomModal({
                            header: components[0],
                            body: "Are you sure you want to Save Changes?",
                            footer: buttons,
                            showCloseButton: true,
                        });
                        component.set("v.modalPromise", modalPromise);
                    }
                }
            );
        }
    },
    submitData: function(component, event, helper) {
        component.get("v.overlayLib").then(function(modal) {
            modal.close();
        });
        var projectName = component.get("v.projectName");
        console.log("projectname:::" + projectName);

        var question = JSON.parse(JSON.stringify(component.get("v.questions")));
        console.log("Questions:11:", question);
        debugger;
        var optionName = "";
        var optionOverage = 0;
        var allowanceRemaining = 0;
        var optionCost = 0;
        var optionId = component.get("v.optionId");
        for (var i = 0; i < question.length; i++) {
            if (
                question[i].check != undefined &&
                question[i].check.Id == optionId &&
                question[i].check.buildertek__Is_Selected_Item__c != undefined &&
                question[i].check.buildertek__Is_Selected_Item__c &&
                question[i].check.Name != undefined
            ) {
                optionName = question[i].check.Name;
                allowanceRemaining =
                    question[i].check.buildertek__Question_Group__r
                    .buildertek__Allowance_Remaining__c;
                optionCost = question[i].check.buildertek__Cost__c;
                optionOverage = optionCost - allowanceRemaining;
            }
            console.log("optionOverage::remaining::" + optionOverage);
        }
        var action = component.get("c.createChangeOrder");
        action.setParams({
            optionName: optionName,
            projectName: projectName,
            optionOverage: optionOverage,
        });
        action.setCallback(this, function(response) {
            var result = response.getState();
            console.log("respone::" + response.getState());
            if (response.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "Success",
                    title: "Success!",
                    message: "Create Change Order on Overage successfully.",
                });
                toastEvent.fire();
            } else {
                console.log("There was a problem : " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    cancel: function(component, event, helper) {
        var question = JSON.parse(JSON.stringify(component.get("v.questions")));
        var optionId = component.get("v.optionId");
        for (var i = 0; i < question.length; i++) {
            if (
                question[i].check != undefined &&
                question[i].check.Id == optionId &&
                question[i].check.buildertek__Is_Selected_Item__c != undefined &&
                question[i].check.buildertek__Is_Selected_Item__c
            ) {
                question[i].check.buildertek__Is_Selected_Item__c = false;
            }
        }
        component.set("v.questions", question);
        component.get("v.modalPromise").then(function(modal) {
            modal.close();
        });
        component.find("overlayLib").notifyClose();
    },

    cancelChangeOrder: function(component, event, helper) {
        var question = JSON.parse(JSON.stringify(component.get("v.questions")));
        var optionId = component.get("v.optionId");
        for (var i = 0; i < question.length; i++) {
            if (
                question[i].check != undefined &&
                question[i].check.Id == optionId &&
                question[i].check.buildertek__Is_Selected_Item__c != undefined
            ) {
                question[i].check.buildertek__Is_Selected_Item__c = !question[i].check
                    .buildertek__Is_Selected_Item__c;
            }
        }
        component.set("v.questions", question);
        component.get("v.overlayLib").then(function(modal) {
            modal.close();
        });
        component.find("overlayLib").notifyClose();
    },

    cancelPopUp: function(component, event, helper) {
        var question = JSON.parse(JSON.stringify(component.get("v.questions")));
        var optionId = component.get("v.optionId");
        for (var i = 0; i < question.length; i++) {
            if (
                question[i].check != undefined &&
                question[i].check.Id == optionId &&
                question[i].check.buildertek__Is_Selected_Item__c != undefined &&
                !question[i].check.buildertek__Is_Selected_Item__c
            ) {
                question[i].check.buildertek__Is_Selected_Item__c = true;
            }
        }
        component.set("v.questions", question);
        component.find("overlayLib").notifyClose();
    },

    saveAttributeType: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            action: "SHOW"
        }).fire();
        var name = event.getSource().get("v.name");
        if (name === "yes") {
            $A.get("e.c:BT_SpinnerEvent").setParams({
                action: "SHOW"
            }).fire();

            var multiOutput = [
                "Multi Select~Checkbox",
                "Multi Select~Checkbox-lineDirection",
                "Multi Select~Multi Select List",
            ];
            var answerMap = new Map();

            var questionswrap = component.get("v.questions");
            console.log("Question Wrap::", questionswrap);
            debugger;
            var questions = [];
            var choices = [];
            for (var i = 0; i < questionswrap.length; i++) {
                var question = questionswrap[i];
                var questionswrapSingleRec = question.check;
                var singleQuestion = {};
                singleQuestion.Id = questionswrapSingleRec.Id;
                singleQuestion.buildertek__Question_Group__c =
                    questionswrapSingleRec.buildertek__Question_Group__c;
                singleQuestion.buildertek__Cost__c =
                    questionswrapSingleRec.buildertek__Cost__c;
                singleQuestion.buildertek__Is_Selected_Item__c =
                    questionswrapSingleRec.buildertek__Is_Selected_Item__c;
                singleQuestion.buildertek__Additional_Cost__c =
                    questionswrapSingleRec.buildertek__Additional_Cost__c;
                questions.push(singleQuestion);
                if (
                    question.responses != undefined &&
                    question.responses.length != undefined
                ) {
                    var responses = question.responses;
                    for (var j = 0; j < responses.length; j++) {
                        var response = responses[j];
                        if (!multiOutput.includes(response.Drop_Down_Value__c)) {
                            if (response.Id != undefined) {
                                var newValue = "";
                                if (response.values != undefined) {
                                    newValue = response.values;
                                }
                                //answerMap.set(response.Id,newValue);
                                var newRec = {};
                                newRec.Id = response.Id;
                                newRec.buildertek__Text_Value__c = newValue;
                                choices.push(newRec);
                            } else {
                                if (
                                    response.items != undefined &&
                                    response.items.length != undefined
                                ) {
                                    var items = response.items;
                                    for (var k = 0; k < items.length; k++) {
                                        var item = items[k];
                                        var newRec = {};
                                        newRec.Id = item.Id;
                                        if (response.values == undefined) {
                                            newRec.buildertek__Text_Value__c = "";
                                        } else {
                                            newRec.buildertek__Text_Value__c = response.values;
                                        }
                                        choices.push(newRec);
                                    }
                                }
                            }
                        } else {
                            if (
                                response.items != undefined &&
                                response.items.length != undefined
                            ) {
                                var items = response.items;
                                for (var k = 0; k < items.length; k++) {
                                    var item = items[k];
                                    var newRec = {};
                                    newRec.Id = item.Id;
                                    var responseValue = [];
                                    if (response.values != undefined) {
                                        responseValue = response.values;
                                    }
                                    newRec.buildertek__Text_Value__c = JSON.stringify(
                                        responseValue
                                    );
                                    choices.push(newRec);
                                }
                            }
                        }
                    }
                }
            }
            console.log("On Save Questions::", JSON.stringify(questions));
            console.log("On Save Choices::", JSON.stringify(choices));
            debugger;

            var action = component.get("c.saveAttribute");
            action.setParams({
                choices: JSON.stringify(choices),
                questions: JSON.stringify(questions),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("STATE::", state);
                if (state == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: "Saved Successfully.",
                        type: "Success",
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire();
                    var treeNodeClickEvent = $A.get("e.c:BT_TreeNodeClickEvent");
                    if (treeNodeClickEvent) {
                        treeNodeClickEvent.setParams({
                            nodeData: {
                                childObjectType: "buildertek__Question_Group__c",
                                key: component.get("v.questionGroupId"),
                            },
                        });
                        treeNodeClickEvent.fire();
                    }
                    component.set("v.requiredReload", true);
                    helper.getQuestions(component, event, helper);

                    component.get("v.modalPromise").then(function(modal) {
                        modal.close();
                    });
                    component.find("overlayLib").notifyClose();
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        action: "HIDE"
                    }).fire();
                }
            });
            $A.enqueueAction(action);
        } else {
            component.get("v.modalPromise").then(function(modal) {
                modal.close();
            });
            component.find("overlayLib").notifyClose();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                action: "HIDE"
            }).fire();
        }
    },

    /*handle save*/
    handleSave: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            action: "SHOW"
        }).fire();
        var questionswrap = component.get("v.questions");
        var questions = [];
        for (var i = 0; i < questionswrap.length; i++) {
            questions.push(questionswrap[i].check);
        }
        console.log("SaveQuestion::", questions);
        var action = component.get("c.saveQuestion");
        action.setParams({
            questions: JSON.stringify(questions)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: "Saved Successfully.",
                    type: "Success",
                });

                toastEvent.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    action: "HIDE"
                }).fire();
            }
        });
        $A.enqueueAction(action);
    },

    /* Here prepare delete confirmation modal*/
    deleteRecordModal: function(component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-selected-index");
        component.set("v.currentIndex", index);
        $A.createComponents(
            [
                [
                    "aura:html",
                    {
                        tag: "h2",
                        body: "Delete Confirmation",
                        HTMLAttributes: {
                            class: "slds-text-heading_medium slds-hyphenate",
                        },
                    },
                ],
                [
                    "lightning:button",
                    {
                        "aura:id": "no_button",
                        label: "No",
                        name: "no",
                        onclick: component.getReference("c.deleteRecords"),
                    },
                ],
                [
                    "lightning:button",
                    {
                        "aura:id": "Yes_button",
                        label: "Yes",
                        name: "yes",
                        variant: "brand",
                        onclick: component.getReference("c.deleteRecords"),
                    },
                ],
            ],
            function(components, status) {
                var buttons = [];
                buttons.push(components[1]);
                buttons.push(components[2]);
                if (status === "SUCCESS") {
                    var modalPromise = component.find("overlayLib").showCustomModal({
                        header: components[0],
                        body: "Are you sure that you want to delete this selection option?",
                        footer: buttons,
                        showCloseButton: true,
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            }
        );
    },

    /* Delete control to check link record*/
    deleteRecords: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            action: "SHOW"
        }).fire();
        var name = event.getSource().get("v.name");
        if (name === "yes") {
            var index = component.get("v.currentIndex");
            var questions = component.get("v.questions");
            var question = questions[index].check;
            var deleteRecord = component.get("c.deleteCheckRecord");
            var checkId = question.Id;
            deleteRecord.setParams({
                checkId: checkId
            });

            deleteRecord.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: "Deleted",
                        type: "Success",
                    });

                    toastEvent.fire();
                    component.set("v.requiredReload", true);
                    helper.getQuestions(component, event, helper);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        action: "HIDE"
                    }).fire();
                    component.get("v.modalPromise").then(function(modal) {
                        modal.close();
                    });
                    component.find("overlayLib").notifyClose();
                }
            });
            $A.enqueueAction(deleteRecord);
        } else {
            component.get("v.modalPromise").then(function(modal) {
                modal.close();
            });
            component.find("overlayLib").notifyClose();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                action: "HIDE"
            }).fire();
        }
    },

    handleUploadFinished: function(component, event, helper) {
        var recordId = event.getSource().get("v.recordId");

        console.log("handleUploadFinished");
        console.log("checkId:: " + recordId);
        var fileUpload = document.getElementsByClassName(
            "divFileUpload_" + recordId
        );
        if (
            fileUpload != undefined &&
            fileUpload != null &&
            fileUpload.length > 0
        ) {
            fileUpload[0].style.display = "none";
            var fileUploadCon = document.getElementsByClassName(
                "imageFileUploadCon_" + recordId
            );
            if (fileUploadCon.length > 0) fileUploadCon[0].style.display = "block";
        }

        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var documentId = "";
        uploadedFiles.forEach((file) => (documentId = file.documentId));
        console.log("Document Id::", documentId);
        var action = component.get("c.updateQuestion");
        action.setParams({
            documentId: documentId,
            questionId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                if (documentId != "" && documentId != undefined) {
                    component.set("v.requiredReload", true);
                    helper.getQuestions(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    onShowDocument: function(component, event, helper) {
        var target = event.target;
        var documentId = target.getAttribute("data-documentId");
        if (documentId != undefined && documentId != "") {
            component.set("v.currentDocumentId", documentId);
            component.set("v.hasModalOpen", true);
        }
    },

    onPhotoShow: function(component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-id");
        console.log('Index:', index);
        if (index != undefined) {
            var questions = component.get("v.questions");
            console.log('Questions::', JSON.stringify(questions[index]));
            if (
                questions[index].check.buildertek__Temp_Document_Id__c != null &&
                questions[index].check.buildertek__Temp_Document_Id__c != ""
            ) {
                console.log('Doc Id:', questions[index].check.buildertek__Temp_Document_Id__c);
                component.set(
                    "v.currentDocumentId",
                    questions[index].check.buildertek__Temp_Document_Id__c
                );
                component.set("v.hasModalOpen", true);
            }
        }
    },

    closeModel: function(component, event, helper) {
        component.set("v.hasModalOpen", false);
        component.set("v.currentDocumentId", "");
    },
    onCancelReuploadPhoto: function(component, event, helper) {
        debugger;
        var index = event.currentTarget.dataset.id;
        var questions = component.get("v.questions");
        var questionsCopy = component.get("v.questionsCopy");
        questions[index].check.buildertek__Image_Id__c =
            questionsCopy[index].check.buildertek__Image_Id__c;
        component.set("v.questions", questions);

        var checkId = questions[index].check.Id;
        var fileUpload = document.getElementsByClassName(
            "divFileUpload_" + checkId
        );
        if (
            fileUpload != undefined &&
            fileUpload != null &&
            fileUpload.length > 0
        ) {
            fileUpload[0].style.display = "none";
            var fileUploadCon = document.getElementsByClassName(
                "imageFileUploadCon_" + checkId
            );
            if (fileUploadCon.length > 0) fileUploadCon[0].style.display = "block";
        }
    },

    onReuploadPhoto: function(component, event, helper) {
        var index = event.currentTarget.dataset.id;
        var questions = component.get("v.questions");
        questions[index].check.buildertek__Image_Id__c = "";
        component.set("v.questions", questions);

        console.log("onReuploadPhoto");
        var checkId = event.target.getAttribute("data-checkId");
        var fileUpload = document.getElementsByClassName(
            "divFileUpload_" + checkId
        );
        if (
            fileUpload != undefined &&
            fileUpload != null &&
            fileUpload.length > 0
        ) {
            fileUpload[0].style.display = "block";
            var fileUploadCon = document.getElementsByClassName(
                "imageFileUploadCon_" + checkId
            );
            if (fileUploadCon.length > 0) fileUploadCon[0].style.display = "none";
        }
    },

    viewDetails: function(component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-selected-index");

        $A.createComponents(
            [
                [
                    "aura:html",
                    {
                        tag: "h2",
                        body: "Selection Option",
                        HTMLAttributes: {
                            class: "slds-text-heading_medium slds-hyphenate",
                        },
                    },
                ],
                [
                    "c:BT_ViewQuestion",
                    {
                        question: component.get("v.questions")[index],
                    },
                ],
            ],
            function(components, status) {
                if (status === "SUCCESS") {
                    component.find("overlayLib").showCustomModal({
                        header: components[0],
                        body: components[1],
                        showCloseButton: true,
                        cssClass: "uiModal--medium",
                    });
                }
            }
        );
    },

    editQuestion: function(component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-selected-index");
        console.log('Additional Cost::', component.get("v.questions")[index].check.buildertek__Additional_Cost__c);
        $A.createComponents(
            [
                [
                    "aura:html",
                    {
                        tag: "h2",
                        body: "Edit Selection Option",
                        HTMLAttributes: {
                            class: "slds-text-heading_medium slds-hyphenate",
                        },
                    },
                ],
                [
                    "c:BT_NewQuestion",
                    {
                        question: component.get("v.questions")[index].check,
                        additionalCost: new Intl.NumberFormat('en-US', {
                            style: 'currency',
                            currency: 'USD'
                        }).format(component.get("v.questions")[index].check.buildertek__Additional_Cost__c != undefined && component.get("v.questions")[index].check.buildertek__Additional_Cost__c != '' ? component.get("v.questions")[index].check.buildertek__Additional_Cost__c : 0),
                        isNewQuestion: false,
                        onSuccess: function() {
                            component.set("v.questions", []);
                            helper.getQuestions(component, event, helper);
                        },
                        onDelete: function() {
                            component.set("v.questions", []);
                            helper.getQuestions(component, event, helper);
                        },
                    },
                ],
            ],
            function(components, status) {
                if (status === "SUCCESS") {
                    component.find("overlayLib").showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: "uiModal--medium",
                    });
                }
            }
        );
    },
});