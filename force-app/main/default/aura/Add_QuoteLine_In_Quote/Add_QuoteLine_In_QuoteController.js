({
   doInit : function(component, event, helper) {
       helper.doInitHelper(component, event, helper)
   }, 

   closeCmp : function(component, event, helper) {
       component.set("v.openProductBox", false);
    //    $A.get("e.force:closeQuickAction").fire() 

   }, 

   changePricebook: function(component, event, helper) {
     var selectedPricebook = component.find("selectedPricebook").get("v.value");
       helper.changePricebookHelper(component, event, helper , selectedPricebook);
   },

   searchInDatatable: function(component, event, helper){
       helper.searchInDatatableHelper(component, event, helper);
   }, 

   goToEditModal: function(component, event, helper) {
       helper.goToEditModalHelper(component, event, helper);
   },
   
   goToProductModal: function(component, event, helper) {
       var quoteLineList = component.get("v.quoteLineList");
       var checkAll = true;
       quoteLineList.forEach(element => {
           if (!element.Selected) {
               checkAll = false
           }
       });
       
       component.set("v.sProductFamily", '');
       component.set("v.sProductName", '');

       component.set("v.tableDataList", quoteLineList);
       component.set("v.selecteProducts", true);
       component.find("selectAll").set("v.checked", checkAll);
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
       var tableDataList = component.get("v.tableDataList");
       var checkAll = true;
       tableDataList.forEach(element => {
           if (!element.Selected) {
               checkAll = false
           }
       });
       component.find("selectAll").set("v.checked", checkAll);
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
   removeQuoteLine:function(component, event, helper){
     var currentId=event.currentTarget.dataset.id;
     var productList=component.get('v.selectedProducts');
     var updatedList=[];
     productList.forEach(function(value){
        if(value.Id !== currentId){
            updatedList.push(value);
        }

     });
     component.set('v.selectedProducts' , updatedList);

     var quoteLineList = component.get("v.quoteLineList");
       quoteLineList.forEach(element => {
            if(element.Id === currentId){
                element.Selected=false;
            }
       });

   }

})