/* Lightning Component Controller.
 * Copyright 2018-2019, @ thoriyas.
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
    twistAccordion: function (component, event, helper) {
        var questionGroupId = component.get("v.questionGroup").Id;
        console.log('Questiongroup::0000::', component.get("v.questionGroup"));
        if (questionGroupId) {
            var elem = document.getElementById('accordion' + component.getGlobalId());
            if (elem.classList.contains('slds-is-open')) { // Check for class
                elem.classList.add('slds-is-close'); // Add class
                elem.classList.remove('slds-is-open'); // Remove class
                component.set("v.icone", "add");
            } else {
                if (component.get("v.questionDetails").length > 0) {
                    elem.classList.add('slds-is-open');
                    elem.classList.remove('slds-is-close');
                    component.set("v.icone", "dash");
                    helper.showQuestionGroupDetails(component, event, helper);
                } else {
                    helper.showQuestionGroupDetails(component, event, helper);
                }
            }
        }
    },

    handleTreeNodeClick: function (component, event, helper) {
        console.log('Question Group..');
        var elem, nodeData = event.getParam("nodeData"),
            questionGroupId = component.get("v.questionGroup").Id,
            actionType = event.getParam("actionType"),
            elem = document.getElementById('accordion' + component.getGlobalId());

        if (nodeData.key === questionGroupId) {
            if (actionType == 'nodecollapse') {
                if (elem.classList.contains('slds-is-open')) {
                    elem.classList.add('slds-is-close');
                    elem.classList.remove('slds-is-open');
                    component.set("v.icone", "add");
                }
                return;
            } else {
                if (component.get("v.questionDetails").length > 0) {
                    elem.classList.add('slds-is-open');
                    elem.classList.remove('slds-is-close');
                    component.set("v.icone", "dash");
                } else {
                    helper.showQuestionGroupDetails(component, event, helper);
                }
                if (actionType === 'nodeclick') {
                    document.getElementById(questionGroupId).scrollIntoView(true);
                    window.scrollBy(0, -150);
                }
            }
        }
    },

    /* This method will display the new question group component for edit question group record*/
    openNewQuestionGroupComponent: function (component, event, helper) {
        var questionGroup = component.get("v.questionGroup")
        var controlModalHeader = "Edit Selection Type Detail";

        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": controlModalHeader,
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewQuestionGroup", {
                    "questionGroup": questionGroup,
                    "section": component.get("v.section"),
                    "onSuccess": function (object) {
                        questionGroup = component.get("v.questionGroup");
                        if (object != undefined && object.Name != undefined) {
                            questionGroup.Name = object.Name;
                            questionGroup.buildertek__Title__c = object.buildertek__Title__c;
                        }
                        component.set("v.questionGroup", questionGroup);
                    },
                    "onDelete": function () {
                        component.initMethod();
                    },
                }],

            ],
            function (components, status) {
                if (status === 'SUCCESS') {

                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'uiModal--medium'
                    });

                }
            });
    },

    /* This method will display the new question component for create question record*/
    openNewQuestionComponent: function (component, event, helper) {
        var questionGroup = component.get("v.questionGroup");
        console.log('Questiongroup::0000::', questionGroup);
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Selection Option",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewQuestion", {
                    "questionGroup": questionGroup,
                    "onSuccess": function (object) {
                        helper.showQuestionGroupDetails(component, event, helper);
                    },
                }],

            ],
            function (components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });

                }
            });
    },
})