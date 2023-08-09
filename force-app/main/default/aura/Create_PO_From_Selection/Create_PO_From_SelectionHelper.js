({
    doInitHelper: function(component, event, helper){
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId => '+recordId);
        var action = component.get("c.getOption");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State => ' + state);
            var result = response.getReturnValue();
            console.log('Result =>', { result });

            if (state == "SUCCESS") {
                component.set('v.columns', [
                    { label: 'Option Name', fieldName: 'Name', type: 'text', sortable: true },
                    { label: 'Manufacturer', fieldName: 'ManufacturerName', type: 'text', sortable: true },
                    { label: 'Product', fieldName: 'ProductName', type: 'text', sortable: true },
                    { label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'text' },
                    { label: 'Sales Price', fieldName: 'buildertek__Cost__c', type: 'currency', cellAttributes: { alignment: 'left' } }
                ]);
    
                result.forEach(element => {
                    console.log('element => ', {element});
                    element.ManufacturerName = element.buildertek__Manufacturer__r.Name;
                    element.ProductName = element.buildertek__Product__r.Name
                });
                component.set("v.data", result);
                component.set("v.Spinner", false);
            } else{
                component.set("v.Spinner", false);
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
        console.log("sorted data : ",component.get("v.data"));
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
        function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    createRecord: function(component, event, helper){
        var recordId = component.get("v.recordId");
        var selectedRowList = component.get("v.selectedRowList");
        console.log('selectedRowList =>', {selectedRowList});
        if (selectedRowList.length != 0) {
            component.set("v.Spinner", true);
            var action = component.get("c.createPO");
            action.setParams({
                recordId: recordId, 
                selectedRowList: selectedRowList
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('State => ' + state);
                if (state == "SUCCESS") {
                    helper.showToast("Success", "Success", "New PO and PO Lines Created.", "5000");
                    $A.get("e.force:closeQuickAction").fire();
                } else{
                    helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                    var error = response.getError();
                    console.log('Error =>', {error});
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        } else {
            helper.showToast("Error", "Error", "Please Select Options", "5000");
        }
    },

    showToast: function(type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
})