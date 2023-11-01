({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.pageReference.state.buildertek__parentId");
        component.set('v.recordId', recordId);
        helper.getQuoteLinesRecords(component, event, helper);
    },
    closeModel : function (component,event,helper) {
        component.set("v.showModel",false);
        var checkboxes = component.find("checkboxInput");
        checkboxes.forEach(function(checkbox) {
            checkbox.set("v.checked", false);
        });
        component.set("v.selectedRecords", []);
        component.set("v.selectedPricebookId", '');
    },
    
    openPopupModel:function(component, event, helper) {
        component.set("v.Spinner", true);
        var Id=  event.currentTarget.dataset.iconattr;
        component.set("v.takeoffLineId",Id);
        component.set("v.selectedPricebookId", '');
        component.set("v.tableDataList", []);
        component.set("v.showModel",true);
        helper.getPricebookRecords(component, event, helper);
    },
    changePricebook: function(component, event, helper) {
        var selected = [];
        component.set("v.selectedRecords", selected);
        helper.changePricebookHelper(component, event, helper);
    },
    changeProductFamily: function(component, event, helper) {
        var checkboxes = component.find("checkboxInput");
        checkboxes.forEach(function(checkbox) {
            checkbox.set("v.checked", false);
        });
        component.set("v.selectedRecords", []);
        var priceBookId = component.find("selectedPricebook").get("v.value");
        var selectedProductFamily = component.find("selectedProductFamily").get("v.value");
        helper.changeProductFamilyHelper(component, event, helper , priceBookId, selectedProductFamily);
    },
    searchInDatatable: function(component, event, helper){
        console.log("Method called" , component.get("v.selectedPricebookId"));
        if (component.get("v.selectedPricebookId") != '') {
            // var checkboxes = component.find("checkboxInput");
            // checkboxes.forEach(function(checkbox) {
            //     checkbox.set("v.checked", false);
            // });
            component.set("v.selectedRecords", []);
            var inputElement = event.getSource().get('v.value');
                var prevInput = component.get('v.prevInput');
                var searchTimeout = component.get('v.searchTimeout');
                
                clearTimeout(searchTimeout);
                    if (inputElement === prevInput) {
                        helper.searchDatatableHelper(component, event, helper);
                    } else {
                        searchTimeout = setTimeout($A.getCallback(function() {
                            if (inputElement === component.get('v.sProductName')) {
                                helper.searchDatatableHelper(component, event, helper);
                            }
                        }), 2000);
                        component.set('v.searchTimeout', searchTimeout);
                    }
                component.set('v.prevInput', inputElement);
        }else {
            var inputElement = event.getSource().get('v.value');
        }
    }, 
    checkboxChange: function(component, event, helper) {
        var selectedRecords = [];
        var tableDataList = component.get("v.tableDataList");
        var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
        var productId = selectedCheckbox.get("v.id");
        var isChecked = selectedCheckbox.get("v.checked");
        var selectedRecord = tableDataList.find(record => record.Id === productId);
    
        if (isChecked) {
            selectedRecords.push(selectedRecord);
        }
    
        component.set("v.selectedRecords", selectedRecords);       
        // Uncheck all other checkboxes
        var checkboxes = component.find("checkboxInput");
        checkboxes.forEach(function(checkbox) {
            var checkboxId = checkbox.get("v.id");
            if (checkboxId !== productId) {
                checkbox.set("v.checked", false);
            }
        });
    },
    saveProduct: function(component, event, helper){
        component.set("v.Spinner", true);
        var onlyUpdatedTakeoffLines = [];
        var takeoffLineList = component.get("v.takeoffLineList");
        var updatedquoteLineList = [];
        var  quoteLineNeedToUpdateId= component.get("v.takeoffLineId"); // The ID you want to match for the update
        var product = component.get("v.selectedRecords"); // The new value you want to set
        
            if (product.length == 0) {
                component.set('v.Spinner', false);
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Please select at least one Product.",
                        "type": "error",
                        "duration": 5000
                    });
                    toastEvent.fire();
                }
            }
            for (var i = 0; i < takeoffLineList.length; i++) {
                var record = takeoffLineList[i];
                if (record.Id === quoteLineNeedToUpdateId) { // Check if the ID matches
                    record.buildertek__Product__r = {Id : product[0].Id , Name : product[0].Name}; // Update the specific field
                    record.buildertek__Product__c = product[0].Id;
                    updatedquoteLineList.push(record); // Add the updated record to the updatedList
                } else {
                    updatedquoteLineList.push(record); // Add the unmodified record to the updatedList
                }
            }

            component.set("v.takeoffLineList", updatedquoteLineList);
            for (var i = 0; i < updatedquoteLineList.length; i++) {
                var record = updatedquoteLineList[i];
                if (record.buildertek__Product__r) {
                    onlyUpdatedTakeoffLines.push(record);
                }
            }
            component.set("v.onlyUpdatedTakeoffLines",onlyUpdatedTakeoffLines);
            if (onlyUpdatedTakeoffLines.length > 0 ) {
                component.set("v.MassSaveButtonDisabled", false);
            } else {
                component.set("v.MassSaveButtonDisabled", true );  
            }
            var checkboxes = component.find("checkboxInput");
            checkboxes.forEach(function(checkbox) {
                checkbox.set("v.checked", false);
            });
            component.set("v.selectedRecords", []);
            component.set("v.Spinner", false);
            component.set("v.showModel",false);
    },
    onMassUpdate: function(component, event, helper){
        component.set("v.Spinner", true);
        helper.UpdateQuoteLineList(component,event,helper);
    },
    onMassUpdateCancel: function(component, event, helper){
        var workspaceAPI = component.find("workspace");
	    workspaceAPI.getFocusedTabInfo().then(function(response) {

		    var focusedTabId = response.tabId;
		    workspaceAPI.closeTab({tabId: focusedTabId});
		});
    },
    removeProduct: function(component, event, helper){
        var removeQlId=  event.currentTarget.dataset.iconattr;
        var updatedquoteLineList =[];
        var onlyUpdatedTakeoffLines =[];
        var removeProd = component.get("v.takeoffLineList");

        for (var i = 0; i < removeProd.length; i++) {
            var record = removeProd[i];
            if (record.Id === removeQlId) { 
                delete  record.buildertek__Product__r 
                delete  record.buildertek__Product__c
                updatedquoteLineList.push(record); // Add the updated record to the updatedList
            } else {
                updatedquoteLineList.push(record); // Add the unmodified record to the updatedList
            }
        }
        component.set("v.takeoffLineList" , updatedquoteLineList);
            for (var i = 0; i < updatedquoteLineList.length; i++) {
                var record = updatedquoteLineList[i];
                if (record.buildertek__Product__r) {
                    onlyUpdatedTakeoffLines.push(record);
                }
            }
            component.set("v.onlyUpdatedTakeoffLines",onlyUpdatedTakeoffLines);
            if (onlyUpdatedTakeoffLines.length > 0 ) {
                component.set("v.MassSaveButtonDisabled", false);
            } else {
                component.set("v.MassSaveButtonDisabled", true );  
            }
    }
    
    

})