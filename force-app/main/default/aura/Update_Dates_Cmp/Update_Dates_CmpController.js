({
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    init: function (component, event,helper) {
        helper.getInitialData(component, event, helper);
        helper.fetchScheduleShipDateChangeReasons(component);
        helper.fetchRequestDateChangeReasons(component); 
        component.set("v.fieldsList", [{ label: "Product SKU", value: "Product SKU" },{ label: "Quantity", value: "Quantity" },{ label: "Status", value: "Status" },{ label: "Product Description", value: "Product Description" },{ label: "Customer Reference Description", value: "Customer Reference Description" },{ label: "Customer Reference Id", value: "Customer Reference Id" }]);
        component.set("v.selectedFields", ["Product SKU", "Quantity","Status","Product Description","Customer Reference Description","Customer Reference Id","Quantity"]);
        // "values" must be a subset of values from "options"
    },    
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var spinner1 = component.find('modaldialog');
        $A.util.removeClass(spinner1, "slds-fade-in-open"); 
        $A.util.addClass(spinner1, "slds-fade-in-hide");
    },
    oERChanges: function(component, event, helper) { 
        var orderEntryReleaseName = component.get("v.updateDatesWrapper").selectedName;
        
        if(orderEntryReleaseName == '--None--'){            
            component.set("v.validationErrorMsg","Please first select an Order Entry Release name from the dropdown list cmp");
        }
        else{
            component.set("v.showSpinner",true);
            component.set("v.selectedReferenceId","--None--");
            component.set("v.selectedSKU","--None--"); 
            component.set("v.validationErrorMsg","");
            helper.filterChangeEvent(component, event, helper,false);
        }
        
    },
    handleGenreChange: function (component, event, helper) {
        //alert('Multi Select');
        //Get the Selected values   
        var selectedValues = event.getParam("value");
        
        //Update the Selected Values  
        component.set("v.selectedGenreList", selectedValues);
        //alert('Multi Select' + component.get("v.selectedGenreList"));
    },
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    },
    cutomerRefChange: function(component, event, helper) { 
        var orderEntryReleaseName = component.get("v.updateDatesWrapper");
        var orderEntryReleaseName = component.get("v.updateDatesWrapper").selectedName;
        console.log('orderEntryReleaseName : '+ orderEntryReleaseName);
        if(orderEntryReleaseName == '--None--'){            
            component.set("v.validationErrorMsg","Please first select an Order Entry Release name from the dropdown list cmp");
        }
        else{
        	component.set("v.selectedSKU","--None--"); 
        }
    },
    skuChange: function(component, event, helper) {  
        var orderEntryReleaseName = component.get("v.updateDatesWrapper").selectedName;
        console.log('orderEntryReleaseName : '+ orderEntryReleaseName);
        if(orderEntryReleaseName == '--None--'){            
            component.set("v.validationErrorMsg","Please first select an Order Entry Release name from the dropdown list cmp");
        }
        
    },
    FilteredData: function(component, event, helper) {   
        component.set("v.showSpinner",true);
        helper.FilteredDataHelper(component, event, helper,false);
    },
    ApplyFilter: function(component, event, helper) {   
        
        var orderEntryReleaseName = component.get("v.updateDatesWrapper").selectedName;
        console.log('orderEntryReleaseName : '+ orderEntryReleaseName);
        if(orderEntryReleaseName == '--None--'){            
            component.set("v.validationErrorMsg","Please first select an Order Entry Release name from the dropdown list cmp");
        }
        else{
            component.set("v.showSpinner",true);
            component.set("v.validationErrorMsg","");
            component.set("v.isAll",false);
            component.set("v.message"," ");
            component.set("v.selectedCount",0);
            helper.filterChangeEvent(component, event, helper,true);
        }
    },
    ResetFilter: function(component, event, helper) {
        var existingWrapper = component.get("v.updateDatesWrapper");
        //alert(existingWrapper.updateTableOELs);
        if(existingWrapper.updateTableOELs == null || existingWrapper.updateTableOELs == 'undefined'){ 
            //alert('Reset Done');
            helper.getInitialData(component, event, helper);
            helper.fetchScheduleShipDateChangeReasons(component);
            helper.fetchRequestDateChangeReasons(component); 
        }else{
            component.set("v.isError",true);
            component.set("v.message","Please click on \"Update Dates & Finish\" because some Order Entry Lines have been updated");
            return false;
            
        }
    },
    Cancel: function(component, event, helper) {
        var existingWrapper = component.get("v.updateDatesWrapper");
        //alert(existingWrapper.updateTableOELs);
        if(existingWrapper.updateTableOELs == null || existingWrapper.updateTableOELs == 'undefined'){ 
             //alert('Cancel Done');
            helper.redirectToRecord(component, event, helper);
        }else{
            component.set("v.isError",true);
            component.set("v.message","Please click on \"Update Dates & Finish\" because some Order Entry Lines have been updated");
            return false;
            
        }
    },    
    handleAllChange: function (component, event) {
        console.log("v.isAll==>");
        console.log(component.get("v.isAll"));
        console.log(event.getSource());
        var currentTarget =event.getSource();
        var isEditInfo = currentTarget.get("v.value");
        console.log(isEditInfo);
        var allRecords = component.find("ordersList");
        if(! Array.isArray(allRecords)){
            component.find("ordersList").set("v.value", isEditInfo);
            
        }
        else{
            for (var i = 0; i < allRecords.length; i++) {
                
                component.find("ordersList")[i].set("v.value", isEditInfo);
            }
            
        }
        //var record = component.find("ordersList")[currentTarget.get("v.text")];
        
        
    },
    handleChange: function (component, event) {
        console.log("v.isAll==>");
        console.log(component.get("v.isAll"));
        if(component.get("v.isAll")==false){
            var currentTarget =event.getSource();
            
            var isEditInfo = currentTarget.get("v.value");
            var selectedCountInfo = component.get("v.selectedCount");
            var recordsForSave = component.get("v.listForSave");
            var recordIdsForSave = component.get("v.listOfIdsForSave");
            var indexInfo = currentTarget.get("v.text");
            var records = component.get("v.listWrapper");
            records[indexInfo].isEdit=isEditInfo;
            component.set("v.listWrapper",records);
            var record = records[indexInfo].oel;
            var recordId = record.Id;
            if(isEditInfo==true){
                selectedCountInfo += 1;
                recordsForSave.push(record);
                recordIdsForSave.push(record.Id);
            }
            else{
                selectedCountInfo -= 1;
                if(recordIdsForSave.indexOf(recordId) == -1){
                    var recordIdIndex =  recordIdsForSave.indexOf(recordId);
                    recordsForSave.splice(recordIdIndex,1);
                    recordIdsForSave.splice(recordIdIndex,1);
                }
                
            }
            if(selectedCountInfo>=0)
                component.set("v.selectedCount",selectedCountInfo);
            
            component.set("v.listForSave",recordsForSave);
            component.get("v.listOfIdsForSave",recordIdsForSave);
            
            
        }
    },
    
    filterscreenAction:function (component, event, helper){
        console.log('entry filterscreenAction->');
        var isSwitching = false;
        var isFilter = false;
        if(event.target!=undefined){
            console.log(event.target.title);
            isSwitching = event.target.title=='Redirect Filer Screen';
            isFilter= event.target.title=='Redirect Filer Screen';
        }
        
        console.log('isSwitching==>');
        console.log(isFilter);
        console.log(isSwitching);
        
        if(isSwitching){
            if(isFilter){
                component.set("v.isEditWindow",false);
                component.set("v.isFilterWindow",true); 
            }
        }
        else{
            var currentSource = event.getSource();
            
            console.log(currentSource.get("v.title"));
            
            helper.toggleClass(component,'backdrop','slds-backdrop--');
            helper.toggleClass(component,'Filters','slds-fade-in-');
            
            if(currentSource.get("v.title")=='massupdate'){
                component.set("v.isEditWindow",true);
                component.set("v.isFilterWindow",false);    
            }
            else{
                component.set("v.isEditWindow",false);
                component.set("v.isFilterWindow",true);        
            }
        }
    },   
    closeModel : function (component, event, helper) {  
        helper.toggleClassInverse(component,'backdrop','slds-backdrop--');        
        helper.toggleClassInverse(component,'Filters','slds-fade-in-');
        helper.toggleClassInverse(component,'EditAction','slds-fade-in-');
        helper.toggleClassInverse(component,'FieldsPicking','slds-fade-in-');     
        helper.toggleClassInverse(component,'ImportFile','slds-fade-in-');     
        helper.toggleClassInverse(component,'errorModel','slds-fade-in-');     
        component.set("v.isEditWindow",false);
        component.set("v.isFilterWindow",false);
    },
    EditscreenAction:function (component, event, helper){
        helper.toggleClass(component,'backdrop','slds-backdrop--');
        helper.toggleClass(component,'EditAction','slds-fade-in-');
        component.set("v.isEditWindow",true);
        component.set("v.isFilterWindow",false);
    }, 
    ImportHileScreen:function (component, event, helper){
        helper.toggleClass(component,'backdrop','slds-backdrop--');
        helper.toggleClass(component,'ImportFile','slds-fade-in-');
    },   
    hideSortingIcon : function (component, event, helper) {
        if(event.target!=null){
            var sortByInput = event.target.title;
            
            if(component.get('v.sortField') != sortByInput){
                component.set('v.actionsortField','');
                
            }
        }
    },
    showSortingIcon : function (component, event, helper) {
        if(event.target!=null){
            var sortByInput = event.target.title;
            if(component.get('v.sortField') != sortByInput){
                component.set('v.actionsortField',sortByInput);
                
            }
        }
    },
    pickFields: function (component, event, helper) {
        
        helper.toggleClass(component,'backdrop','slds-backdrop--');
        helper.toggleClass(component,'FieldsPicking','slds-fade-in-');
        
    },
    handleFieldsSelection: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set('v.isSKU', selectedOptionValue.toString().includes('Product SKU'));
        component.set('v.isQuantity', selectedOptionValue.toString().includes('Quantity'));
        
        component.set('v.isProductDescription', selectedOptionValue.toString().includes('Product Description'));
        component.set('v.isCustomerReferenceDesc', selectedOptionValue.toString().includes('Customer Reference Description'));
        component.set('v.isCustomerReferenceId', selectedOptionValue.toString().includes('Customer Reference Id'));
        component.set('v.isStatus', selectedOptionValue.toString().includes('Status'));
        
    },
    handleSelect: function (component, event,helper) {  
        component.set("v.isError",false);
        component.set("v.message"," ");
        var selectedMenuItemValue = event.getParam("value");  
        var wrapperInfo = component.get("v.updateDatesWrapper")
        var orderEntryReleaseName = wrapperInfo.selectedName;
        //alert(orderEntryReleaseName);
        if(selectedMenuItemValue=='Update Dates & Continue'){   
            if(orderEntryReleaseName == '--None--'){
                component.set("v.isError",true);
                component.set("v.message","Please first select atleast one Order Entry Release Name From the Filter Dropdown");
                return false;
            }
            if(component.get("v.selectedCount") != null && component.get("v.selectedCount")>0){
                component.set("v.showSpinner",true);
                console.log('See Save Call');
                var existingWrapper = component.get("v.updateDatesWrapper");
                existingWrapper.isContinue =  true;
                component.set("v.updateDatesWrapper",existingWrapper);
                helper.saveUpdateDatesCall(component,helper);
                component.set("v.isError",false);
                component.set("v.message"," ");
                component.set("v.isAll",false);
                component.set("v.selectedCount",0);
            }
            else{
                component.set("v.isError",true);
                component.set("v.message","Please first select atleast one Order Entry Line Item");
            }
        }else{
    
            var existingWrapper = component.get("v.updateDatesWrapper"); 
            if(existingWrapper.updateTableOELs == null ){
                if(component.get("v.selectedCount") != null && component.get("v.selectedCount") > 0){
                    component.set("v.showSpinner",true);
                    existingWrapper.isFinishedMethod = true;
                    existingWrapper.isContinue =  false;
                    helper.saveUpdateDatesCall(component,helper);
                }
                else {
                    component.set("v.isError",true);
                    component.set("v.message","Please first select atleast one Order Entry Line Item");
                    return true;
                }
            }
            else { 
                component.set("v.showSpinner",true);
                existingWrapper.isFinishedMethod = true;
                existingWrapper.isContinue =  false;
                helper.saveUpdateDatesCall(component,helper);
            }
            
            
        }
        // Find all menu items
        var menuItems = component.find("menuItems");
        console.log(menuItems);
        
        menuItems.forEach(function (menuItem) {
            // For each menu item, if it was checked, un-check it. This ensures that only one
            // menu item is checked at a time
            if (menuItem.get("v.checked")) {
                menuItem.set("v.checked", false);
            }
            // Check the selected menu item
            if (menuItem.get("v.value") === selectedMenuItemValue) {
                menuItem.set("v.checked", true);
            }
        });
    },
    closeError: function (component, event,helper) {
        component.set('v.isError',false);
        component.set('v.isSuccess',false);
        
    },
    handleSelectSections: function (component, event,helper) {
        // This will contain the index (position) of the selected lightning:menuItem
        // Find all menu items
        var selectedMenuItemValue = event.getParam("value");
        
        var menuItems = component.find("menuItemSections");
        console.log(menuItems);
        
        var menuItem = menuItems.find(function(menuItem) {
            return menuItem.get("v.value") === selectedMenuItemValue;
        });
        // Toggle the existing checked value, if it was true, it will be set to false, and vice-versa
        var isTrue = !menuItem.get("v.checked");
        
        
        console.log('selectedMenuItemValue==>');
        console.log(selectedMenuItemValue);
        if(selectedMenuItemValue=='All'){
            
            component.set("v.isAllSections",true);
            component.set("v.isEditSection",false);
            component.set("v.isNonEditSection",false);
            component.set("v.isUpdatedSection",false);
            menuItems.forEach(function (menuItem) {
                // For each menu item, if it was checked, un-check it. This ensures that only one
                // menu item is checked at a time
                if (menuItem.get("v.checked")) {
                    menuItem.set("v.checked", false);
                }
                // Check the selected menu item
                if (menuItem.get("v.value") === selectedMenuItemValue) {
                    menuItem.set("v.checked", true);
                }
            });
            
        }
        else if(selectedMenuItemValue=='Edit Section'){
            menuItems[0].set("v.checked", false);
            component.set("v.isAllSections",false);
            component.set("v.isEditSection",isTrue);
            menuItem.set("v.checked", isTrue);
            
        }
            else if(selectedMenuItemValue=='Non Editable Section'){
                menuItems[0].set("v.checked", false);
                component.set("v.isNonEditSection",isTrue);
                component.set("v.isAllSections",false);
                menuItem.set("v.checked", isTrue);
                
            }
                else if(selectedMenuItemValue=='Updated Section'){
                    menuItems[0].set("v.checked", false);
                    component.set("v.isUpdatedSection",isTrue);
                    component.set("v.isAllSections",false);
                    
                    menuItem.set("v.checked", isTrue);
                    
                }
        
    },
    updateandContinue: function (component, event, helper){
        console.log('updateandContinue Controllr');
        //alert('Selected Records'+"v.selectedCount")
        if(component.get("v.selectedCount")>0){
            //helper.updateandContinueHelper (component, event, helper,true);
        }
        else{
            component.set("v.message","Please first select an Order Entry Release name from the dropdown list");
            helper.showToast(component, event, helper);
        }
        
    },
    approvedDatesJS: function (component, event, helper){        
        var action = component.get("c.approvedDates");
        action.setParams({   
            wrapperData : JSON.stringify(component.get("v.updateDatesWrapper"))
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var wrapperResult = a.getReturnValue();
            helper.toggleClassInverse(component,'backdrop','slds-backdrop--');
            helper.toggleClassInverse(component,'errorModel','slds-fade-in-');
            
           // alert('navigateToOpp : '+ wrapperResult.navigateToOpp + ' : Refresh : '+ wrapperResult.refreshPage+ ' : isFinishedMethod : '+ wrapperResult.isFinishedMethod);
            
            if(wrapperResult.isFinishedMethod && wrapperResult.navigateToOpp){
                helper.redirectToRecord(component, event, helper);
            }else{
                component.set("v.updateDatesWrapper", wrapperResult);
            }
            
        });
        $A.enqueueAction(action);
    },
})