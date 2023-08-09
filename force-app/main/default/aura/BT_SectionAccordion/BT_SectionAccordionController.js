/* Lightning Component Controller.
 * Copyright 2018-2019, thoriyas.
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
        var sectionId = component.get("v.section").Id;
        if (sectionId) {
            var elem = document.getElementById('accordion' + component.getGlobalId());

            // Check for class
            if (elem.classList.contains('slds-is-open')) {

                // Add class
                elem.classList.add('slds-is-close');

                // Remove class
                elem.classList.remove('slds-is-open');

                component.set("v.icone", "add");
            } else {
                console.log('ELSE');
                if (component.get("v.questionGroupDetails").length > 0) {
                    elem.classList.add('slds-is-open');
                    elem.classList.remove('slds-is-close');
                    component.set("v.icone", "dash");
                } else {
                    helper.createQuestionGroupDetails(component, event, helper, sectionId);
                }
            }
        }

    },

    handleTreeNodeClick: function (component, event, helper) {
        // console.log('Section Accordion..');
        var elem, nodeData = event.getParam("nodeData"),
            sectionId = component.get("v.section").Id,
            actionType = event.getParam("actionType"),
            elem = document.getElementById('accordion' + component.getGlobalId());

        if (nodeData.key != undefined && nodeData.key === sectionId) {
            if (actionType == 'nodecollapse') {
                if (elem.classList.contains('slds-is-open')) {
                    elem.classList.add('slds-is-close');
                    elem.classList.remove('slds-is-open');
                    component.set("v.icone", "add");
                }
                return;
            } else {
                if (component.get("v.questionGroupDetails").length > 0) {
                    elem.classList.add('slds-is-open');
                    elem.classList.remove('slds-is-close');
                    component.set("v.icone", "dash");
                    helper.createQuestionGroupDetails(component, event, helper, sectionId);
                } else {
                    helper.createQuestionGroupDetails(component, event, helper, sectionId);
                }
                if (actionType == 'nodeclick') {
                    document.getElementById(sectionId).scrollIntoView(true);
                    window.scrollBy(0, -250);
                }
            }
        }
        // console.log('nodeData Event::', JSON.stringify(nodeData));
    },

    /* This method will display the new section component for edit section record*/
    openNewSectionComponent: function (component, event, helper) {
        var sectionId = component.get("v.section").Id;
        var sectionRecordType = component.get("v.recordTypeDeveloperName");
        var sectionModalHeader;

        sectionModalHeader = "Edit Selection Category Detail";
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": sectionModalHeader,
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewSection", {
                    "sectionId": sectionId,
                    "section": component.get("v.section"),
                    "recordTypeName": sectionRecordType,
                    "onSuccess": function (object) {
                        var section = component.get("v.section");
                        console.log('In section accordioncontroller');
                        console.log({section});
                        section.Name = object.Name;
                        section.buildertek__Title__c = object.buildertek__Title__c;
                        component.set("v.section", section);
                    },
                    "onDelete": function () {
                        var initReference = component.get("v.initReference");
                        $A.enqueueAction(initReference);
                    }

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

    /* This method will display the new question group component for create question group record*/
    openNewQuestionGroupComponent: function (component, event, helper) {
        var sectionObject = component.get("v.section");
        var sectionRecordType = component.get("v.recordTypeDeveloperName");
        var controlModalHeader;

        controlModalHeader = "New Selection Type Detail";


        $A.createComponents([
            ["aura:html", {
                "tag": "h2",
                "body": controlModalHeader,
                "HTMLAttributes": {
                    "class": "slds-text-heading_medium slds-hyphenate"
                }
            }],
            ["c:BT_NewQuestionGroup", {
                "section": sectionObject,
                "onSuccess": function () {
                    helper.createQuestionGroupDetails(component, event, helper, sectionObject.Id);
                },
            }],

        ], function (components, status) {
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
    saveQuestionGroupHierarchy: function (component, event, helper) {

    },
    addSubSection: function (component, event, helper) {
        var sectionRecordType = component.get("v.recordTypeDeveloperName");
        var adId = component.get("v.section").buildertek__Selection__c;
        var sectionModalHeader;


        sectionModalHeader = "New Selection Category Details";

        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": sectionModalHeader,
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewSection", {
                    "adId": adId,
                    "onSuccess": function (object) {
                        object.Parent__c = component.get("v.section").Id;
                        object.index = component.get("v.index");
                        component.set('v.newSection', JSON.stringify(object));

                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "SHOW"
                        }).fire();
                        var initChildReference = component.get('v.initChildReference');
                        $A.enqueueAction(initChildReference);
                    }
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

    }

})