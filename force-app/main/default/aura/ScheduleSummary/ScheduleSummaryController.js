({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.loadTasks(component, recordId);
        helper.getContractorListHelper(component, event, helper);
    },
    filterRec: function(component, event,helper) {
        var contractorId = component.get("v.selectedContractorId");
        // if contractorId is null or empty make logic to show all contractor data in picklist
        if (contractorId == null || contractorId == '') {
            helper.Cutout_ContractorRecords(component, event);
            component.set('v.NoSearch', true);
            component.set("v.scrollHeight", 3000);
            component.set("v.contractorCount", 100);
        }
        // console.log('contractor id : '+contractorId);

        var recordId = component.get("v.recordId");
        helper.FieterTaskWithVendorNameAndCurrentProject(component, recordId, contractorId);
    },
    searchContractorData : function(component, event, helper) {
        component.set('v.displayContractor', true);
        console.log('displayContractor > ', component.get('v.displayContractor'));
        event.stopPropagation();
    },
    keyupContractorData: function (component, event, helper) {
        component.set('v.displayContractor', true);
        component.set('v.NoSearch', false);
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
                
            } else  if(tempArray.length <= 100){
                component.set("v.contractorList", tempArray);
            }
            else if(tempArray.length > 100){
                var tempArrayLimited = [];
                for(var  i=0; i<=99; i++){
                    tempArrayLimited.push(tempArray[i])
                }
                component.set("v.contractorList", tempArrayLimited);
            }
        }), 1000);
    },

    hideList : function(component, event, helper) {
        component.set('v.displayContractor', false);
        helper.Cutout_ContractorRecords(component, event);
        component.set('v.NoSearch', true);
        component.set("v.scrollHeight", 3000);
        component.set("v.contractorCount", 100);
    },
    clearInput: function(component, event, helper) {
        component.set('v.selectedContractorName','');
        component.set('v.selectedContractorId','');
        component.set('v.NoSearch', true);
        component.set("v.scrollHeight", 3000);
        component.set("v.contractorCount", 100);

        var contractorId = '';
        // if contractorId is null or empty make logic to show all contractor data in picklist
        if (contractorId == null || contractorId == '') {
            helper.Cutout_ContractorRecords(component, event);
        }
        // console.log('contractor id : '+contractorId);

        var recordId = component.get("v.recordId");
        helper.FieterTaskWithVendorNameAndCurrentProject(component, recordId, contractorId);
        
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

    scrollDownLoading: function(component, event, helper){
            if(component.get("v.NoSearch")){

                // console.log('No Search');
                var ScrolledDiv = event.target;
                var scrollHeight = component.get("v.scrollHeight");
                var contractorCount = component.get("v.contractorCount");
                
                if(ScrolledDiv.scrollTop >= scrollHeight){
                    // console.log('ScrolledDiv.scrollHeight>> ', ScrolledDiv.scrollHeight);
                    // console.log('Scrolled >> ', ScrolledDiv.scrollTop);
                    // console.log('scroll Height >> ', scrollHeight);
                    // console.log('contractorCount >> ', contractorCount);
                    var result =  component.get('v.allContractorRecords');
                    if(result.length > (contractorCount+100)){
                        var contractorListLimited = component.get("v.contractorList");
                        for(var  i=contractorCount; i<(contractorCount+100); i++){
                            contractorListLimited.push(result[i]);
                        }
                        component.set("v.contractorList", contractorListLimited);
                    }
                    else{
                        component.set('v.contractorList' ,result);
                    }
                    // console.log("contractorList => ", component.get("v.contractorList"));
                    var scrollHeight = component.set("v.scrollHeight", (scrollHeight+3000));
                    var contractorCount = component.set("v.contractorCount", (contractorCount+100))
                }
            }
    }
})