/* Lightning Component Helper.
 * Copyright 2018-2019, Riskonnect Inc.
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
    showQuestionGroupDetails: function (component, event, helper) {
        var elem = document.getElementById('accordion' + component.getGlobalId());
        var questionGroupId = component.get("v.questionGroup").Id;
        var isOptionSaved = component.get("v.questionGroup").buildertek__Is_Saved_Items__c;
        var fields = component.get("v.headerFields");
        $A.createComponents([
            ["lightning:recordForm", {
                "objectApiName": "buildertek__Question_Group__c",
                "recordId": questionGroupId,
                "columns": "3",
                "mode": "readOnly",
                "fields": fields
            }],
            ["c:BT_QuestionPreview", {
                "questionGroupId": questionGroupId,
                "selectionId": component.get('v.selectionId'),
                "questionGroup": component.get("v.questionGroup"),
                "callerName": component.get("v.callerName"),
                "isOptionSaved": isOptionSaved
            }]
        ], function (components, status, errorMessage) {
            if (status === "SUCCESS") {
                var recordViewForm = components[0];
                /*var questionGroupHeaderFiels = component.get("v.headerFields");
                var questionGroupHeader = [];
                for(var i in questionGroupHeaderFiels){
                	questionGroupHeader.push(["lightning:outputField",{"fieldName" : questionGroupHeaderFiels[i]}]);
                }*/
                component.set("v.recordViewForm", recordViewForm);
                component.set("v.questionDetails", components[1]);

                /*$A.createComponents(questionGroupHeader,function(subcomponents, substatus, suberrorMessage){
                    if (substatus === "SUCCESS") {
                        recordViewForm.set("v.body",subcomponents);
                        component.set("v.recordViewForm",recordViewForm);
                        component.set("v.questionDetails",components[1]);
                        console.log('components[1]::',components[1]);
                    }
                });*/
            }
        });

        elem.classList.add('slds-is-open');
        elem.classList.remove('slds-is-close');
        component.set("v.icone", "dash");
    }
})