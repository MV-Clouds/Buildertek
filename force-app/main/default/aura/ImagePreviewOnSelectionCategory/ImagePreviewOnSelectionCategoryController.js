({
    init : function(component, event, helper) {
        var sobjectname = component.get("v.sObjectName");

        var recordId = component.get("v.selectedCategoryId");
        console.log('Categary recordId => ' + recordId);
        var recordId1 = component.get("v.recordId");
        console.log('recordId => ' + recordId1);
        if (sobjectname == 'buildertek__Section__c') {
            component.set("v.mainRecordId", recordId1);
        } else if(sobjectname == 'buildertek__Selection__c'){
            component.set("v.mainRecordId", recordId);
        }

        var orgId = $A.get("$SObjectType.CurrentUser.Id");
        var baseUrl = window.location.protocol + '//' + window.location.hostname + '/' + orgId.substring(0, 15);
        console.log('Organization Base URL: ' + baseUrl);
        component.set('v.orgBaseURL', baseUrl);
        
        var action = component.get("c.getSelectionCategoryFiles");
        action.setParams({
            recordId: component.get("v.mainRecordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', {state});
            var result = response.getReturnValue();
            console.log('Result =>', {result});
            if (result.status == 'success') {
                component.set("v.categoryList", result.selectionCategory);
                helper.initializePagination(component);
                console.log(result.selectionCategory.length);
            }else if(result.status == 'There Are No Files.') {
                component.set("v.message", 'There are no Selection Types for this Selection Category.');  
            }else{
                component.set("v.message", 'Something went wrong while fetching Selection Types.'); 
            }
        });
        $A.enqueueAction(action);
    },
    previousPage: function(component, event, helper) {
        helper.previousPageNew(component);
    },
    
    nextPage: function(component, event, helper) {
        helper.nextPageNew(component);
    },
    handleImageClick: function(component, event, helper) {
        var clickedDiv = event.currentTarget;
        var imageId = clickedDiv.getAttribute('id');
        var imageName = clickedDiv.getAttribute('data-name');
        component.set('v.showSelectionOptions', false);
        component.set("v.selectionTypeId", imageId);
        component.set("v.selectionTypeName", imageName); 
        component.set("v.showSelectionOptions", true); 

    },
})