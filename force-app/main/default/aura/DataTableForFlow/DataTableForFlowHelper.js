({ 
    doInit : function(component, event, helper) {
        var action = component.get('c.getProductList');
        action.setParams({
            'failureID':component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var sObjectData = response.getReturnValue();
                component.set("v.sObjectData", sObjectData);
                component.set("v.sObjectDataFiltered", sObjectData);
                if(sObjectData != undefined && sObjectData[0] != undefined){
                    component.set("v.failureComponent",sObjectData[0].Failure_Mode__c);
                }
                if(sObjectData.length ==0){
                    component.set("v.Message",true);
                    component.set("v.messageShown",$A.get("$Label.c.AddFailureModesRecordNotFound"));
                    component.set("v.disableButton",true);
                }
            } else if(state === 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    component.set("v.messageShown",errors[0].message);
                    component.set("v.Message",true);
                    component.set("v.disableButton",true);
                }
            }
        });
        
        $A.enqueueAction(action);        
    },
    onCheck : function(component, event, helper){
        var checkbox = event.getSource();
        var RecordSelected =  checkbox.get("v.value");
        var selectedRecordId = checkbox.get("v.text");
        var selectedRecordList = [];
        if(RecordSelected && component.get("v.selectedRecordList").indexOf(selectedRecordId) < 0){
            selectedRecordList.push(selectedRecordId);
            component.get('v.selectedRecordList').push(selectedRecordId);            
        }
        else{
            component.set('v.isAllSelected', false);
            var index = component.get("v.selectedRecordList").indexOf(selectedRecordId);
            if (index > -1) {
                component.get("v.selectedRecordList").splice(index, 1); 
            }
        }
    },
    selectAll : function(component, event, helper,isSelected){
        var checkbox = component.find('checkbox'); 
        var selectedRecordList = [];
        
        if(isSelected) {
            component.set('v.isAllSelected', true);
        }
        else{
            component.set('v.isAllSelected', false);
        }
        if(checkbox != undefined){
            if (!Array.isArray(checkbox)) {
                checkbox = [checkbox];
            }           
            for (var i = 0; i < checkbox.length; i++) {
                checkbox[i].set('v.value', component.get('v.isAllSelected'));
                var selectedRecordId=checkbox[i].get("v.text");
                selectedRecordList.push(selectedRecordId);
                component.get('v.selectedRecordList').push(selectedRecordId);           
            }
        }
    },
    createIssueFailureMode : function(component, event, helper){
        var action = component.get("c.createIssueFailureMode");
        var recordId = component.get("v.recordId");
        action.setParams({
            "selectedRecordList":component.get("v.selectedRecordList"),
            "issueId":recordId,
            "allFailureMode":component.get("v.sObjectData"),
            "isAllSelected" : component.get("v.isAllSelected"),
            "failureComponent": component.get("v.failureComponent")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.spinner", true); 
                helper.refreshAfterSave(component, event, helper);                
            } else if(state === 'ERROR'){
         
                var errors = action.getError();
                if (errors) {
                    component.set("v.messageShown",errors[0].message);
                    component.set("v.Message",true);
                    component.set("v.disableButton",true);
                }           
            }        
        })
        $A.enqueueAction(action);         
        
    },  
    refreshAfterSave  : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    redirectToDetailPage  : function(component, event, helper){
        var sObjectEvent  = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
    },
    searchResult  : function(component, event, helper){
        var sObjectData = component.get('v.sObjectData');
        var searchText = component.get('v.searchText');
        var sObjectDataFiltered =[];
        if(searchText != undefined && searchText != null){
            var searchWith = searchText.toLowerCase();
            
            for(var i=0;i<sObjectData.length;i++){
                var failureMode = (sObjectData[i].Name).toLowerCase();
                if(failureMode.includes(searchText)){
                    sObjectDataFiltered.push(sObjectData[i]);
                }
            }
            component.set("v.sObjectDataFiltered",sObjectDataFiltered);
        }
    }
})