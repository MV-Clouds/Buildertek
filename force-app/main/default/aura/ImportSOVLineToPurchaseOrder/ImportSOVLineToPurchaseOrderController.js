({
	doInit : function(component, event, helper) {
        try {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var action = component.get("c.getPOInfo");
            action.setParams({
                poId : component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                var result = response.getReturnValue();
                console.log('result---> ',result);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if(result != null){
                    component.set("v.ProjectId", result[0].buildertek__Project__c);
                    helper.getAllSOVToImportInPO(component, event, helper);
                } else {
                    component.set("v.MessageToDisplay", 'Status of PO must be Open to insert SOV Lines.');
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log('error---> ',error);
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        }
	},
	
	handleCheckbox: function (component, event, helper) {
        try {
            var checkbox = event.getSource();
            var isChecked = checkbox.get("v.value");
            var recordId = checkbox.get("v.text");
            var checkedRecordIds = component.get("v.checkedRecordIds");
            console.log(`isChecked: ${isChecked} recordId: ${recordId}`);
            if (isChecked) {
                checkedRecordIds.push(recordId);
            } else {
                var index = checkedRecordIds.indexOf(recordId);
                if (index !== -1) {
                    checkedRecordIds.splice(index, 1);
                }
            }

            component.set("v.checkedRecordIds", checkedRecordIds);
            console.log('checkedRecordIds', checkedRecordIds);
        } catch (error) {
            console.log('Error---> ',error);
        }
    },

    selectAll: function (component, event, helper) {
        var checkbox = event.getSource();
        var isChecked = checkbox.get("v.value");
        console.log('isChecked--> ',isChecked);
        var checkboxes = component.find("checkContractor");
        var allrecord = [];
        allrecord = component.get("v.allSOVList");
        if (isChecked == true) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.value", true);
                });
            } else {
                checkboxes.set("v.value", true);
            } 
            var idList = allrecord.map(function(item) {
                return item.Id;
            });
            console.log('checkedRecordIds', idList);
            component.set("v.checkedRecordIds", idList);
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.value", false);
                });
            } else {
                checkboxes.set("v.value", false);
            }
            component.set("v.checkedRecordIds", []);
        }
    },
	
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
	
	importSOVLine : function(component, event, helper){
        try {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var selectedRecordIds = component.get("v.checkedRecordIds");
            console.log('selectedRecordIds.length---->' + selectedRecordIds.length);
            if(selectedRecordIds.length > 0){
                var action = component.get("c.importSOVasPOLine");
                action.setParams({
                    sOVIds : selectedRecordIds,
                    recordId : component.get("v.recordId")
                });
                action.setCallback(this, function(response){
                    console.log({response});
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                        var result = response.getReturnValue();  
                        console.log({result});
                        if(result.Status === 'Success'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": result.Message,
                                "type": 'Success'
                            });
                            toastEvent.fire(); 
                            $A.get("e.force:closeQuickAction").fire();  
                            window.setTimeout(
                                $A.getCallback(function() {
                                    document.location.reload(true);    
                                }), 1000
                            );
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": result.Message,
                                "type": 'Error'
                            });
                            toastEvent.fire();    
                        }
                    }
                });
                $A.enqueueAction(action);
            }else{
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Please Select at least One SOV record.',
                    "type": 'Error',
                    "duration": '10000',
                    "mode": 'dismissible'
                });    
                toastEvent.fire();
            }
        } catch (error) {
            console.log('Error---> ',error);
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        }
	},
	
	next: function (component, event, helper) {
        try {
            var sObjectList = component.get("v.allSOVList");
            var end = component.get("v.endPage");
            var start = component.get("v.startPage");
            var pageSize = component.get("v.pageSize");
            var Paginationlist = [];
            var counter = 0;
            for(var i=end+1; i<end+pageSize+1; i++){
                if(sObjectList.length > i){
                    Paginationlist.push(sObjectList[i]);
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
            helper.updateCheckboxValues(component);
        } catch (error) {
            console.log('Error---> ',error);
        }
    },
    previous: function (component, event, helper) {
        try {
            var sObjectList = component.get("v.allSOVList"); 
            var end = component.get("v.endPage");
            var start = component.get("v.startPage");
            var pageSize = component.get("v.pageSize");
            var Paginationlist = [];
            var counter = 0;
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    Paginationlist.push(sObjectList[i]);
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
            helper.updateCheckboxValues(component);
        } catch (error) {
            console.log('Error---> ',error);
        }
    },
})