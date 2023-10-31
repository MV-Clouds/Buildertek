({
   doInit : function(component, event, helper) {
       helper.doInitHelper(component, event, helper)
   }, 

   closeCmp : function(component, event, helper) {
       component.set("v.openProductBox", false);
    //    $A.get("e.force:closeQuickAction").fire() 

   }, 

   changePricebook: function(component, event, helper) {
    var selected = [];
    component.set("v.selectedRecords", selected);
    var selectedPricebook = component.find("selectedPricebook").get("v.value");
    helper.changePricebookHelper(component, event, helper , selectedPricebook);
   },
   changeProductFamily: function(component, event, helper) {
    var selectedPricebook = component.find("selectedPricebook").get("v.value");
    var selectedProductFamily = component.find("selectedProductFamily").get("v.value");
      helper.changeProductFamilyHelper(component, event, helper , selectedPricebook, selectedProductFamily);
  },

   searchInDatatable: function(component, event, helper){
     console.log('in method');
        if (component.get("v.selectedPricebookId") != '') {
            var inputElement = event.getSource().get('v.value');
                var prevInput = component.get('v.prevInput');
                var searchTimeout = component.get('v.searchTimeout');
                
                clearTimeout(searchTimeout);

                // if (inputElement.trim() !== '') {
                    // console.log('in if');
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
            // } 
        }else{
            var inputElement = event.getSource().get('v.value');
        }
    
    },  

    searchVendorInDatatable: function(component, event, helper){
        var searchTimeout = component.get('v.searchTimeout');
        console.log('in Vendor method');
        clearTimeout(searchTimeout);
        var inputElement = event.getSource().get('v.value');

        searchTimeout = setTimeout($A.getCallback(function() {
            if(component.get("v.selectedPricebookId") != ''){
                var inputElement = event.getSource().get('v.value');
                var tableDataList = component.get("v.tableDataList");
                var quoteLineList = component.get("v.quoteLineList");
                
                console.log('inputElement--->',inputElement);
                // console.log('tableDataList--->',tableDataList);
                // console.log('quoteLineList--->',quoteLineList);
                component.set("v.Spinner", true);
                setTimeout($A.getCallback(function() {
                    if(inputElement != '' && inputElement != undefined && inputElement != null){
                        var filterRecord = [];
                        quoteLineList.forEach(element => {
                            if(!element.Vendor){
                                element.Vendor = '';
                            }
                            if(element.Vendor.toLowerCase().includes(inputElement.toLowerCase())){
                                filterRecord.push(element);
                            }
                        });
                        console.log('filterRecord--->',filterRecord);
            
                        component.set("v.tableDataList", filterRecord);
                        console.log('tableDataList--->',component.get("v.tableDataList"));
                        component.set("v.Spinner", false);
                    }else{
                        component.set("v.Spinner", false);
                        console.log("Jaimin is here")
                        //bring selected records to top
                        var selectedRecords = component.get("v.selectedRecords");
                        var remainingRecords = [];
                        var selectedRecordsIds = [];
                        selectedRecords.forEach(element => {
                            selectedRecordsIds.push(element.Id);
                        });
                        console.log('selectedRecordsIds--->',selectedRecordsIds);
                        quoteLineList.forEach(element => {
                            if(!selectedRecordsIds.includes(element.Id)){
                                remainingRecords.push(element);
                            }
                        });
                        console.log('remainingRecords--->',remainingRecords);
                        // make tableDataList as null then assign remainingRecords to tableDataList and then add selectedRecords on top of it
                        component.set("v.tableDataList", null);
                        component.set("v.tableDataList", remainingRecords);
                        console.log('tableDataList--->',component.get("v.tableDataList"));
                        var sortedList = selectedRecords.concat(component.get("v.tableDataList"));
                        console.log('sortedList--->',sortedList);
                        component.set("v.tableDataList", sortedList);
                        console.log('tableDataList--->',component.get("v.tableDataList"));
                    }
                }), 2000);
    
            }
        }
        ), 2000);
        component.set('v.searchTimeout', searchTimeout);
    },

   goToEditModal: function(component, event, helper) {
       helper.goToEditModalHelper(component, event, helper);
   },
   
   goToProductModal: function(component, event, helper) {
    var quoteLineList = component.get("v.quoteLineList");
    component.set("v.sProductName", '');
    component.set("v.sVendorName", '');
    var selectedRecords = [];
    var remainingRecords = [];

    quoteLineList.forEach(element => {
        if (element.Selected) {
            selectedRecords.push(element);
        } else {
            remainingRecords.push(element);
        }
    });

    // Sort the remaining records in ascending order based on Family and then Name
    remainingRecords.sort(function(a, b) {
        if (!a.Family) {
            a.Family = '';
        }
        if (!b.Family ) {
            b.Family = '';
        }
        // Compare by Family first
        var familyComparison = a.Family.localeCompare(b.Family);
        
        // If Family is the same, compare by Name
        if (familyComparison === 0) {
            return a.Name.localeCompare(b.Name);
        } else {
            return familyComparison;
        }
    });

    // Concatenate selected records with sorted remaining records
    var sortedList = selectedRecords.concat(remainingRecords);

    component.set("v.tableDataList", sortedList);
    component.set("v.selecteProducts", true);
},


   checkAllProduct: function(component, event, helper){
       var value = event.getSource().get("v.checked"); 
       var tableDataList = component.get("v.tableDataList");
       tableDataList.forEach(element => {
           element.Selected = value;
       });
       component.set("v.tableDataList", tableDataList);
   }, 

   checkboxChange : function(component, event, helper) {
 
    // var selectedRecordIds = component.get("v.selectedRecordIds");
    // var tableDataList = component.get("v.tableDataList");
    // var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
    // var productId = selectedCheckbox.get("v.id");
    // var isChecked = selectedCheckbox.get("v.checked");
    // var selectedRows = component.get("v.selectedRows");

    // console.log('tableDataList------>',tableDataList);
    
    // if (isChecked) {
        
    // } else {
    //     var indexToRemove = selectedRecordIds.indexOf(productId);
    //     if (indexToRemove !== -1) {
    //         selectedRecordIds.splice(indexToRemove, 1);
    //     }
    // }
    var selectedRecords = component.get("v.selectedRecords");
var tableDataList = component.get("v.tableDataList");
var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
var productId = selectedCheckbox.get("v.id");
var isChecked = selectedCheckbox.get("v.checked");

// Find the selected record by its ID
var selectedRecord = tableDataList.find(record => record.Id === productId);

if (isChecked) {
    selectedRecords.push(selectedRecord);
} else {
    var indexToRemove = selectedRecords.indexOf(selectedRecord);
    if (indexToRemove !== -1) {
        selectedRecords.splice(indexToRemove, 1);
    }
}

component.set("v.selectedRecords", selectedRecords);

// component.set("v.selectedRecordIds", selectedRecordIds);
console.log('selectedRecordIds------>',component.get("v.selectedRecords"));
   var tableDataList = component.get("v.tableDataList");
   var checkAll = true;
   tableDataList.forEach(element => {
       if (!element.Selected) {
           checkAll = false
       }
   });
//    component.find("selectAll").set("v.checked", checkAll);


},

   saveQuoteLine : function(component, event, helper){
       component.set("v.Spinner", true);
       console.log('saveQuoteLine');
       var listQlines = component.get("v.selectedProducts");
       var flag=false;
       listQlines.forEach(function(elem){
        console.log({elem});
        console.log(elem.buildertek__Description__c);
            if(elem.buildertek__Description__c == '' || elem.buildertek__Description__c== undefined){
                flag=true;
            }
            
       });

       console.log({flag});
       if(listQlines.length > 0 && flag== false){
                var action10 = component.get("c.QuoteLinesInsert");
                action10.setParams({
                    "Quotelines": listQlines,
                    "QuoteId": component.get("v.quoteId")
                });

                action10.setCallback(this, function(response) {
                    console.log(response.getReturnValue());
                    component.set("v.openQuoteLineBox", false);
                    $A.get("e.force:refreshView").fire();
                    component.set("v.Spinner", false);
                    component.set("v.openProductBox", false);        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Quote Lines are created successfully',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(action10);

       }else if(flag){
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Please select Description.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
       }else{
        component.set("v.Spinner", false);

        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Product.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();

       }
       
   },
   removeQuoteLine: function(component, event, helper) {
    var currentId = event.currentTarget.dataset.id;
    var productList = component.get('v.selectedProducts');
    var updatedList = [];
    productList.forEach(function(value) {
        if (value.Id !== currentId) {
            updatedList.push(value);
        }
    });
    component.set('v.selectedProducts', updatedList);

    // Remove the record from v.selectedRecords attribute
    var selectedRecords = component.get('v.selectedRecords');
    var updatedSelectedRecords = selectedRecords.filter(function(record) {
        return record.Id !== currentId;
    });
    component.set('v.selectedRecords', updatedSelectedRecords);

    var quoteLineList = component.get('v.quoteLineList');
    quoteLineList.forEach(function(element) {
        if (element.Id === currentId) {
            element.Selected = false;
        }
    });
},

})