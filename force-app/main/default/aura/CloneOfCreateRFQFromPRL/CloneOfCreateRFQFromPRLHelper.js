({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId => '+recordId);
        var action = component.get("c.getPRLDsData");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State => ' + state);
            var result = response.getReturnValue();
            console.log('Result =>', { result });

            if (result.length === 0 ) {
                $A.get("e.force:closeQuickAction").fire();
				helper.showToast("Error", "Error", "There Are No PRLD", "5000");
            } else if (result.length > 0 && result[0].buildertek__Pricing_Request_Line__r.buildertek__RFQ__c != null) {
				$A.get("e.force:closeQuickAction").fire();
				helper.showToast("Error", "Error", "RFQ is already exists on PRL", "5000");
			} else {
				if (state == "SUCCESS") {
					component.set('v.columns', [
						{ label: 'PRLD Name', fieldName: 'Name', type: 'text', sortable: true },
						{ label: 'Description', fieldName: 'buildertek__Description__c', type: 'text', sortable: true },
						{ label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'text' },
						{ label: 'Unit Cost', fieldName: 'buildertek__Cost__c', type: 'currency', cellAttributes: { alignment: 'left' } },
					]);
					component.set("v.data", result);
					component.set("v.Spinner", false);
				} else{
					component.set("v.Spinner", false);
					helper.showToast("Error", "Error", "Something Went Wrong", "5000");
					$A.get("e.force:closeQuickAction").fire();
				}
			}

        });
        $A.enqueueAction(action);
    }, 
    
    createRecord: function(component, event, helper){
        var recordId = component.get("v.recordId");

        var RFQ = component.get("v.RFQ");
        console.log('RFQ Name ==> '+RFQ.Name);
        if (RFQ.Name != '') {
            var selectedRowList = component.get("v.selectedRowList");
            console.log('selectedRowList =>', {selectedRowList});

            if (selectedRowList.length != 0) {
                component.set("v.Spinner", true);
                var action = component.get("c.CreateRFQ");
                action.setParams({
                    recordId: recordId,
                    RFQ: RFQ,
                    PRLDsList: selectedRowList,
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('State => ' + state);
                    if (state == "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('Result ==> '+result);
                        helper.showToast("Success", "Success", "New RFQ Created.", "5000");
                        
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
                helper.showToast("Error", "Error", "Please Select Pricing Request Line Details", "5000");
            }
        } else{
            helper.showToast("Error", "Error", "RFQ Name is required", "5000");
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