({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteLineRecordList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var QuoteLineList = response.getReturnValue();
                component.set("v.quoteLineList", QuoteLineList);
                component.set("v.changeColorToRed", true);
                console.log(' QuoteLine-->',component.get("v.quoteLineList"));
            }
        });
        $A.enqueueAction(action);
    },
    closeModel : function (component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    editProduct: function(component, event, helper) {
        component.set("v.editMode", true); // Enable editing
        var Id=  event.currentTarget.dataset.iconattr;
        console.log('id-->',Id);
        component.set("v.selectedRecId", Id); 
        component.set("v.isFieldDisabled", false);
        console.log(component.get("v.selectedRecId"));

    },
    save:function(component, event, helper) {
        var Id=  event.currentTarget.dataset.value;
        console.log('id New-->',Id);

    },
    clickHandlerProduct: function(component, event, helper){
        component.set('v.displayProduct', true);   
        var recordId = event.currentTarget.dataset.value;
        console.log('clickHandlerProduct',recordId);
        component.set('v.selectedProductId', recordId);
        var productList = component.get("v.productList");
        productList.forEach(element => {
            if (recordId == element.Id) {
                component.set('v.selectedProductName', element.Name);
                component.set('v.selectedProductId', element.Id);
            }
        });
        var action = component.get("c.getProduct");
        action.setParams({
            productId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({state});
            var result= response.getReturnValue();
            console.log({result});

            if (state === "SUCCESS") {
                console.log("NEw Re--->",{result});
                component.set('v.optName' , result.Name);
                component.set('v.optLongName' , result.Name);
                console.log(result.PricebookEntries);
            }
        });
        $A.enqueueAction(action);
    },
    searchProductData: function(component, event, helper) {
        component.set('v.displayProduct', true);
        helper.getPricebooksProduct(component, event, helper);
        event.stopPropagation();
    },
    keyupProductData:function(component, event, helper) {
        component.set('v.displayProduct', true);

            var allRecords = component.get("v.productList");
            var searchFilter = event.getSource().get("v.value").toUpperCase();
            var tempArray = [];
            var i;
            for (i = 0; i < allRecords.length; i++) {
                if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                    tempArray.push(allRecords[i]);
                }else{
                    component.set('v.selectedProductId' , ' ')
                }
            }
            component.set("v.productList", tempArray);
            helper.getPricebooksProduct(component, event, helper , searchFilter);
    },
    hideList : function(component, event, helper) {
        console.log("Method Called");
        component.set('v.displayProduct', false);
    }

    
})