/* Lightning Component Controller.
 * Copyright 2018-2019, @ thoriyas
 * All rights reserved
 *
 * Created by - Sagar T
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */
({
    /*component init method, In this method get the fields from field set*/
    init : function(component, event, helper) {
        helper.getFieldSet(component);
        helper.listQuestionTypes(component);
        
        var questionGroup = component.get("v.questionGroup");
        if(!!questionGroup && !!questionGroup.Id) {
            component.set("v.isNewControl",false);
            if(!$A.util.isUndefinedOrNull(questionGroup) && !$A.util.isUndefinedOrNull(questionGroup.Id)) {  
                if(questionGroup.buildertek__Selection_Attributes__r != undefined){
                    var answerChoices = questionGroup.buildertek__Selection_Attributes__r;
                    var inputOption = ['Date~Date Picker','Text~Text Area','Text~Simple Text'];
                    var responseTypeList = [];   
                    var myMap  = new Map();
                    for(var i=0;i<answerChoices.length;i++){
                        var answerChoice = answerChoices[i];
                        if(!inputOption.includes(answerChoice.buildertek__Choice_Value__c)){
                            if(!myMap.has(answerChoice.Name+'~'+answerChoice.buildertek__Choice_Value__c)){
                                myMap.set(answerChoice.Name+'~'+answerChoice.buildertek__Choice_Value__c,[]); 
                            }  
                            var responseAtt = {};
                            responseAtt.buildertek__Choice_Text__c=answerChoice.buildertek__Choice_Text__c;
                            responseAtt.Id=answerChoice.Id;
                            myMap.get(answerChoice.Name+'~'+answerChoice.buildertek__Choice_Value__c).push(responseAtt);
                        } 
                    }  
                    var responseTypeList = [];
                    var mapKey = [];
                    for(var i=0;i<answerChoices.length;i++){
                        var answerChoice = answerChoices[i];
                        if(!inputOption.includes(answerChoice.buildertek__Choice_Value__c)){
                            var key =  answerChoice.Name+'~'+answerChoice.buildertek__Choice_Value__c;
                            if(!mapKey.includes(key)){
                                mapKey.push(key);
                                if(myMap.has(key)){
                                    var responseType = {};
                                    responseType.selectedResponsetypeValue=answerChoice.buildertek__Choice_Value__c;
                                    responseType.responseTypeName = answerChoice.Name;
                                    responseType.selectionChoices = myMap.get(key); 
                                    responseTypeList.push(responseType);
                                }
                            }
                        }else{
                            var responseType = {}; 
                            responseType.selectedResponsetypeValue=answerChoice.buildertek__Choice_Value__c;
                            responseType.responseTypeName = answerChoice.Name; 
                            responseTypeList.push(responseType);
                        }
                    }
                    component.set("v.responseTypeList",responseTypeList);
                }
            }
        }
    },
    
    /* Save Question Group record*/
    save : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        document.getElementById('saveQuestionGroupbutton').click();
        component.set('v.isSaveAndNew',false);
    },
    
    /* Save Question Group record*/
    saveAndNew : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        document.getElementById('saveQuestionGroupbutton').click();
        component.set('v.isSaveAndNew',true);
        component.set('v.isNewControl',true);
    },
    
    /* When click on save of record edit submit button then this submit event fire.\
		Here save the control object record and insert citation to control link record.*/
    submitcontrolRecord : function(component, event, helper) {
        console.log('submitcontrolRecord :: ');
        var successmessage = "Created";
        var isNewControl = component.get("v.isNewControl");
        var eventFields = event.getParam("fields"); 
        var namespacePrefix = component.get("v.namespace");
        eventFields["Name"]=eventFields[namespacePrefix+"Title__c"];
        if (isNewControl) {
            var sectionRecord = component.get("v.section"); 
            eventFields[namespacePrefix+'Sort_Id__c'] = "001";
            eventFields[namespacePrefix+'Section__c'] = sectionRecord.Id;
            
        } else {
            var questionGroup = component.get("v.questionGroup");
            console.log('questionGroup:0:',questionGroup);
            questionGroup.Name = eventFields["Name"];
            component.set("v.questionGroup",questionGroup);
        }
        
        
        var responseTypeList = [];
        if(component.get("v.responseTypeList")!=undefined){
            responseTypeList = component.get("v.responseTypeList");
        }
        var inputOption = ['Date~Date Picker','Text~Text Area','Text~Simple Text'];
        var question = component.get("v.questionGroup");
        var choices =[];
        for(var i=0;i<responseTypeList.length;i++){
            if(responseTypeList[i].selectionChoices != undefined && question.Id != undefined &&
               responseTypeList[i].selectedResponsetypeValue!= undefined && !inputOption.includes(responseTypeList[i].selectedResponsetypeValue)){
                for(var j=0;j<responseTypeList[i].selectionChoices.length;j++){
                    var choice={};
                    if(responseTypeList[i].selectionChoices[j].Id != undefined){
                        choice.Id = responseTypeList[i].selectionChoices[j].Id;
                    }
                    choice.Name=responseTypeList[i].responseTypeName;
                    choice.buildertek__Selection_Type__c = question.Id;
                    choice.buildertek__Choice_Text__c = responseTypeList[i].selectionChoices[j].buildertek__Choice_Text__c;
                    choice.buildertek__Choice_Value__c = responseTypeList[i].selectedResponsetypeValue;
                    choices.push(choice);
                }
            }else if(responseTypeList[i].selectedResponsetypeValue != undefined && inputOption.includes(responseTypeList[i].selectedResponsetypeValue)){
                var choice={};
                if(responseTypeList[i].Id!=undefined){
                    choice.Id=responseTypeList[i].Id;
                }
                var responseTypeName = responseTypeList[i].responseTypeName;
                if(responseTypeName != undefined){
                    choice.Name=responseTypeName;
                }else{
                    choice.Name='Response Type';
                }
                
                choice.buildertek__Question__c = question.Id;
                choice.buildertek__Choice_Value__c = responseTypeList[i].selectedResponsetypeValue;
                choices.push(choice);
            }
        }
        var addNewQuestion = component.get("c.addNewAnswerChoices");
        addNewQuestion.setParams({choices:JSON.stringify(choices)});
        addNewQuestion.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var onSuccess = component.get("v.onSuccess");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: successmessage,
                    type: 'Success',
                });
                
                toastEvent.fire();
                
                
                if (!$A.util.isUndefinedOrNull(onSuccess)) {
                    onSuccess();
                }
                
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                /*if(!component.get('v.isSaveAndNew')){
                    //component.find("overlayLib").notifyClose();
                }else{
                    var emptyList=[];
                    component.set('v.questionGroup',{});
                    component.set('v.section',{});
                    component.set('v.responseTypeList',emptyList);
                    component.find('setupField').forEach(function(f) {
                        f.reset();
                    });
                }*/
            } 
        });
        $A.enqueueAction(addNewQuestion);
    },
    
    onDeleteHandler : function(component,event,helper){
        var index = event.getSource().get("v.name");
        var responseTypeList = component.get("v.responseTypeList");
        var responseTypeListNew = [];
        if(responseTypeList.length>index && index != undefined){
            for(var i =0;i<responseTypeList.length;i++){
                if(index != i){
                    responseTypeListNew.push(responseTypeList[i]);
                }                
            }
        }
        component.set("v.responseTypeList",responseTypeListNew);
    },
    
    addNewResponseType : function(component,event,helper){
        var responseTypeList = [];
        if(component.get("v.responseTypeList")!=undefined){
            responseTypeList = component.get("v.responseTypeList");
        }
        if(responseTypeList.length>5){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'Max 6 Attribute Allowed.',
                type: 'Info',
            });
            
            toastEvent.fire();
            return;
        }
        var newResponseType = {};
        responseTypeList.push(newResponseType);
        component.set("v.responseTypeList",responseTypeList);
    },
    
    /* when record edit from submit successfully then this event will fire
		Here prepare the success toast message.*/
    sucsesscontrolRecord : function(component, event, helper) {
        console.log('---:::onSuccess:::---');
        var isNewControl = component.get("v.isNewControl");
        if (!isNewControl) {
            var onSuccess = component.get("v.onSuccess");
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            
            var questionGroup = component.get("v.questionGroup");
            if (!!onSuccess) {
                onSuccess(questionGroup);
            }
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'Selection Type "'+questionGroup.buildertek__Title__c+'" was saved',
                type: 'Success',
            });
            
            toastEvent.fire();
            //component.find("overlayLib").notifyClose();
        } else {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'Selection Type was created',
                type: 'Success',
            });
            
            toastEvent.fire();
            var onSuccess = component.get("v.onSuccess");
            if (!!onSuccess) {
                onSuccess();
            }
            
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            //component.find("overlayLib").notifyClose();
        }
        if(!component.get('v.isSaveAndNew')){
            component.find("overlayLib").notifyClose();
        }else{
            var emptyList=[];
            component.set('v.questionGroup',{});
            component.set('v.responseTypeList',emptyList);
            component.set('v.responsetypeOptions',emptyList);
            component.set('v.richTableData',emptyList);
            component.set('v.productfamilyoptions',emptyList);
            component.find('setupField').forEach(function(f) {
                f.reset();
            });
            setTimeout(function(){ 
                component.find('setupField')[0].focus();
            }, 500); 
        }
    },
    
    /* Here prepare delete confirmation modal*/
    deleteRecordModal : function(component,event,helper) {
        var questionGroup = component.get("v.questionGroup");
        $A.createComponents([
            ["aura:html", {
                "tag": "h2",
                "body": "Delete Confirmation",
                "HTMLAttributes": { 
                    "class": "slds-text-heading_medium slds-hyphenate" 
                }
            }],
            ["lightning:button",{
                "aura:id": "no_button",
                "label": "No",
                "name":"no",
                "onclick": component.getReference("c.deleteRecords")     
            }],
            ["lightning:button",{
                "aura:id": "Yes_button",
                "label": "Yes",
                "name":"yes",
                "variant":"brand",
                "onclick": component.getReference("c.deleteRecords")
            }]
        ], function(components, status) {
            var buttons = [];
            buttons.push(components[1]);
            buttons.push(components[2]);
            if (status === "SUCCESS") {
                var modalPromise = component.find('overlayLib').showCustomModal({
                    header: components[0],
                    body: "Are you sure you want to delete this?",
                    footer: buttons,
                    showCloseButton: true
                });
                component.set("v.modalPromise", modalPromise);
            }
        });
    }, 
    
    cancel: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    /* delete citation to control link record */
    deleteRecords : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var name = event.getSource().get("v.name");
        
        if (name === "yes") {
            var sectionRecordId = component.get("v.section").Id;
            
            var questionGroup = component.get("v.questionGroup");
            var questionGroupId = questionGroup.Id;
            
            var deleteRecord = component.get("c.deleteControlRecord"); 
            deleteRecord.setParams({"recordId":questionGroupId});
            deleteRecord.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Selection Type "'+questionGroup.buildertek__Title__c+'" was deleted',
                        type: 'Success',
                    });
                    
                    toastEvent.fire();
                    var onDelete = component.get("v.onDelete");
                    if (!!onDelete) {
                        onDelete();
                    }
                    
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    component.get('v.modalPromise').then(function (modal) {
                        modal.close();
                    });
                    component.find("overlayLib").notifyClose();
                } 
            });
            $A.enqueueAction(deleteRecord);
        } else {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            component.get('v.modalPromise').then(function (modal) {
                modal.close();
            });
        }
    },
    
    responsetype : function (component, event, helper) {
        console.log('---responsetype-- changes--'); 
        var index = event.getSource().get("v.name");
        var selectedOptionValue = event.getParam("value");
        console.log('Selected value::',selectedOptionValue+' index :: '+index);
        var questionscoring;
        if (!$A.util.isUndefinedOrNull(selectedOptionValue) && component.find("buildertek__choice_template__c")[index] != undefined) {
            $A.util.addClass(component.find("buildertek__choice_template__c")[index],'slds-hide');
            $A.util.addClass(component.find("rich_table")[index],'slds-hide'); 
            
            var responseTypeAndLayout = selectedOptionValue.split('~');
            if (!$A.util.isUndefinedOrNull(responseTypeAndLayout[0]) && (responseTypeAndLayout[0].toUpperCase() === 'SINGLE SELECT' || responseTypeAndLayout[0].toUpperCase() === 'MULTI SELECT')) {
                $A.util.addClass(component.find("buildertek__choice_template__c")[index],'slds-hide'); 
            } else if (selectedOptionValue.trim().toUpperCase() === 'TEXT~RICH TABLE') {
                $A.util.removeClass(maxRow, 'slds-hide');
                $A.util.removeClass(visibleRow, 'slds-hide');
                $A.util.removeClass(component.find("rich_table")[index], 'slds-hide');
            } 
        }else{
            $A.util.addClass(component.find("buildertek__choice_template__c"),'slds-hide');
            $A.util.addClass(component.find("rich_table"),'slds-hide'); 
            
            var responseTypeAndLayout = selectedOptionValue.split('~');
            if (!$A.util.isUndefinedOrNull(responseTypeAndLayout[0]) && (responseTypeAndLayout[0].toUpperCase() === 'SINGLE SELECT' || responseTypeAndLayout[0].toUpperCase() === 'MULTI SELECT')) {
                $A.util.addClass(component.find("buildertek__choice_template__c"),'slds-hide'); 
            } else if (selectedOptionValue.trim().toUpperCase() === 'TEXT~RICH TABLE') {
                $A.util.removeClass(maxRow, 'slds-hide');
                $A.util.removeClass(visibleRow, 'slds-hide');
                $A.util.removeClass(component.find("rich_table"), 'slds-hide');
            } 
        }
    },
    
})