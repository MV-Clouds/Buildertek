({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId => '+recordId);
        var action = component.get("c.getRecord");
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
                    { label: 'Selection Type', fieldName: 'Name', type: 'text', sortable: true },
                    { label: 'Description', fieldName: 'buildertek__Title__c', type: 'text', sortable: true },
                    { label: 'Status', fieldName: 'buildertek__Status__c', type: 'text', sortable: true },
                ]);
    
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
    
    createRecord: function(component, event, helper){
        var recordId = component.get("v.recordId");

        var pricingRequest = component.get('v.pricingRequest');
        console.log('pricingRequest Data ==> '+pricingRequest.Name);
        if (pricingRequest.Name != '') {
            var selectedRowList = component.get("v.selectedRowList");
            console.log('selectedRowList =>', {selectedRowList});

            if (selectedRowList.length != 0) {
                component.set("v.Spinner", true);
                var optionList = [];

                selectedRowList.forEach(element => {
                    if (element.buildertek__Questions__r != undefined) {
                        element.buildertek__Questions__r.forEach(ele => {
                            optionList.push(ele);
                        });
                    }
                });

                var action = component.get("c.createPR");
                action.setParams({
                    recordId: recordId,
                    pricingRequest: pricingRequest,
                    selectionTypeList: selectedRowList,
                    optionList: optionList
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('State => ' + state);
                    if (state == "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('Result ==> '+result);
                        helper.showToast("Success", "Success", "New Pricing Request Created.", "5000");
                        
                        $A.get("e.force:closeQuickAction").fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                        
                    } else{
                        helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                        var error = response.getError();
                        console.log('Error =>', {error});
                    }
                    component.set("v.Spinner", false);
                });
                $A.enqueueAction(action);
            } else {
                helper.showToast("Error", "Error", "Please Select Selection Types", "5000");
            }
        } else{
            helper.showToast("Error", "Error", "Pricing Request Name is required", "5000");
        }

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