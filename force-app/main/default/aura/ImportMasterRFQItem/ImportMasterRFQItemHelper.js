({
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                console.log('inside getcurr');
                component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    getmulticur : function (component, event, helper) {
        var action = component.get("c.getmulticurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                console.log('inside getmulticur');
                component.set("v.multicurrency",response.getReturnValue());
                //  component.set("v.multicurrency",false);
			} 
		});
		$A.enqueueAction(action);		
    },
	importMasterRFQItems : function(component, event, helper, searchString){
        var RecordId =  component.get("v.recordId");
        var action = component.get("c.getmasterRFQItems");
        action.setParams({ searchString: searchString });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.startPage",0);
                component.set("v.endPage",0);
                var result = response.getReturnValue();
                console.log("this is result"+result);
                if(result != null){
                    component.set("v.disableBtn", false);
                    if(result.length > 2){
                        result = JSON.parse(result);
                        var maxLength = 40;
                        result.forEach(function(item){       
                            if(item.MasterRFQItem.Name != null){
                                if (item.MasterRFQItem.Name.length > maxLength) {
                                    item.MasterRFQItem.truncatedName = item.MasterRFQItem.Name.substring(0, maxLength - 3) + "...";
                                } else {
                                    item.MasterRFQItem.truncatedName = item.MasterRFQItem.Name;
                                }
                            }
                            if(item.MasterRFQItem.buildertek__Description__c != null){
                                if (item.MasterRFQItem.buildertek__Description__c.length > (maxLength + 20)) {
                                    item.MasterRFQItem.truncateddes = item.MasterRFQItem.buildertek__Description__c.substring(0, maxLength + 17) + "...";
                                } else {
                                    item.MasterRFQItem.truncateddes = item.MasterRFQItem.buildertek__Description__c;
                                }
                            }
                        })
                        component.set("v.objInfo",result);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = result;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalRecordsCount", totalLength);
                        component.set("v.startPage",0);
                        component.set("v.endPage",pageSize-1);

                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.objInfo").length > i){
                                PaginationLst.push(result[i]);    
                            } 
                        }
                        
                        component.set('v.PaginationList', PaginationLst);
                        }
                        else{
                            component.set("v.objInfo",null);
                            component.set("v.startPage",0);
                            component.set("v.endPage",0);
                            component.set("v.disableBtn", true);

                        }
                }
                else{
                }
                component.set("v.Spinner",false);
                this.updateCheckboxValues(component);
                
            }
            
        });
        $A.enqueueAction(action);
	},
    
    importRFQItems: function(component, event, helper){
        try {
            component.set("v.Spinner", true);
            var Records = component.get("v.mainObjectId");
	        var rfqItems = component.get("v.objInfo");
            var checkedRecordIds = component.get("v.checkedRecordIds");
            if(rfqItems != null){
	        
	            if(checkedRecordIds.length > 0){
	                var action = component.get("c.importRFQItems");
                    action.setParams({Id : checkedRecordIds, RFQId : Records})
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var result = response.getReturnValue();
                        if (state === "SUCCESS") {
                            component.set("v.Spinner", false);
                            component.get("v.onSuccess")();  
                        }
                    
                    }); 
                    $A.enqueueAction(action);
                }else{
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error!',
                        message: 'Please Select RFQ Item.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
            }else{
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error!',
                    message: 'There is No Master RFQ Line',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                    mode: "pester",
                });
                toastEvent.fire();
            }
        } catch (error) {
            console.log({error});
        }
        
	},


    updateCheckboxValues: function (component) {
        var PaginationList = component.get("v.PaginationList");
        var checkedRecordIds = component.get("v.checkedRecordIds");
    
        // Iterate through PaginationList and update checkbox values
        PaginationList.forEach(function (record) {
            // Get the record ID for the checkbox
            var recordId = record.MasterRFQItem.Id;
    
            // Get the checkbox by name attribute
            var checkboxes = component.find("checkInspection");
    
            // If there are multiple checkboxes, component.find() returns an array
            if (Array.isArray(checkboxes)) {
                // Loop through the array of checkboxes
                checkboxes.forEach(function (checkbox) {
                    if (checkbox.get("v.text") === recordId) {
                        // Update the checkbox value based on checkedRecordIds
                        checkbox.set("v.value", checkedRecordIds.includes(recordId));
                    }
                });
            } else {
                // If there's only one checkbox
                if (checkboxes.get("v.text") === recordId) {
                    // Update the checkbox value based on checkedRecordIds
                    checkboxes.set("v.value", checkedRecordIds.includes(recordId));
                }
            }
        });
    },
})