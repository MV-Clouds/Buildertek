({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.loadTasks(component, recordId);
        helper.getContractorListHelper(component, event, helper);
    },
    filterRec: function(component, event,helper) {
        var contractorId = component.get("v.selectedContractorId");
        var recordId = component.get("v.recordId");
        helper.FieterTaskWithVendorNameAndCurrentProject(component, recordId, contractorId);
    },
    searchContractorData : function(component, event, helper) {
        component.set('v.displayContractor', true);
        event.stopPropagation();
    },
    keyupContractorData: function (component, event, helper) {
        component.set('v.displayContractor', true);
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        setTimeout($A.getCallback(function() {
            var listOfAllRecords = component.get('v.allContractorRecords');
            var tempArray = [];
            var i;
            
            for (i = 0; i < listOfAllRecords.length; i++) {
                var recordName = listOfAllRecords[i].Name;
                if (recordName && recordName.toUpperCase().indexOf(searchFilter) !== -1) {
                    tempArray.push(listOfAllRecords[i]);
                }
            }
            
            if (tempArray.length === 0) {
                component.set('v.selectedContractorId', ' ');
                component.set("v.contractorList", []);
                component.set("v.Message", 'There are no Contractors.');
                // component.set("v.Spinner", false);
                
            } else {
                component.set("v.contractorList", tempArray);
            }
        }), 2000);
    },
    hideList : function(component, event, helper) {
        component.set('v.displayContractor', false);
    },
    clearInput: function(component, event, helper) {
        component.set('v.selectedContractorName','');
        component.set('v.selectedContractorId','');
    },
    preventHide: function(component, event, helper) {
        event.preventDefault();
    },
    clickHandlerContractor: function(component, event, helper){
        component.set('v.displayContractor', false);
        var recordId = event.currentTarget.dataset.value;
        component.set('v.selectedContractorId', recordId);
        var contractorList = component.get("v.contractorList");
        contractorList.forEach(element => {
            if (recordId == element.Id) {
                component.set('v.selectedContractorName', element.Name);

            }
        });
    },
})