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
                var result = response.getReturnValue();
                if(result != null){
                    if(result.length > 2){
                        result = JSON.parse(result);
                        var maxLength = 40;
                        result.forEach(function(item){       
                            if(item.MasterRFQItem.Name != null){
                                if (item.MasterRFQItem.Name.length > maxLength) {
                                    console.log('is it working');
                                    item.MasterRFQItem.truncatedName = item.MasterRFQItem.Name.substring(0, maxLength - 3) + "...";
                                } else {
                                    item.MasterRFQItem.truncatedName = item.MasterRFQItem.Name;
                                }
                            }
                            if(item.MasterRFQItem.buildertek__Description__c != null){
                                if (item.MasterRFQItem.buildertek__Description__c.length > (maxLength + 20)) {
                                    console.log('is it working');
                                    item.MasterRFQItem.truncateddes = item.MasterRFQItem.buildertek__Description__c.substring(0, maxLength + 17) + "...";
                                } else {
                                    item.MasterRFQItem.truncateddes = item.MasterRFQItem.buildertek__Description__c;
                                }
                            }
                        })
                        component.set("v.objInfo",result);
                        console.log('check 1');
                        var pageSize = component.get("v.pageSize");
                        console.log('start 1');
                        var totalRecordsList = result;
                        var totalLength = totalRecordsList.length ;
                        console.log('start 2');
                        component.set("v.totalRecordsCount", totalLength);
                        component.set("v.startPage",0);
                        console.log('start 3');
                        component.set("v.endPage",pageSize-1);
                        console.log('check 2');

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
                        }
                }
                component.set("v.Spinner",false);

                
            }
            
        });
        $A.enqueueAction(action);
	},
    
    importRFQItems: function(component, event, helper){
        component.set("v.Spinner", true);
        var Records = component.get("v.mainObjectId");
	    var rfqItems = component.get("v.objInfo");
	    var SubOptions = [];
       // alert(SubOptions);
        if(rfqItems != null){
	    for(var i=0 ; i < rfqItems.length;i++){
         // alert(rfqItems[i].SubmittalCheck );
	        if(rfqItems[i].SubmittalCheck == true){
	            SubOptions.push(rfqItems[i].MasterRFQItem.Id);
	        }
	    }
	    if(SubOptions.length > 0){
	        component.set("v.selectedobjInfo",SubOptions);
            console.log(SubOptions);
            console.log(Records);
	        var action = component.get("c.importRFQItems");
            action.setParams({Id : SubOptions, RFQId : Records})
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
	},
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
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

        const allActive = Paginationlist.every(function(obj) {
            return obj.isChecked === true;
         });
         if(allActive){
            component.find("selectAllRFQ").set("v.value", true);

        }else{
           component.find("selectAllRFQ").set("v.value", false);

        }
         

      
    },
    previous : function(component,event,sObjectList,end,start,pageSize){

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
        const allActive = Paginationlist.every(function(obj) {
            return obj.isChecked === true;
         });
         if(allActive){
            component.find("selectAllRFQ").set("v.value", true);

        }else{
           component.find("selectAllRFQ").set("v.value", false);

        }
    },
    updatePagination: function(component, filteredList) {
        var pageSize = component.get("v.pageSize");
        var totalRecordsCount = filteredList.length;
        var totalPages = Math.ceil(totalRecordsCount / pageSize);
        var currentPage = component.get("v.currentPage");

        // Update total records count and total pages
        component.set("v.totalRecordsCount", totalRecordsCount);
        component.set("v.TotalPages", totalPages);
        console.log("Error is before this");

        // Calculate new start and end page indices
        var startPage = (currentPage - 1) * pageSize;
        var endPage = Math.min(startPage + pageSize - 1, totalRecordsCount - 1);

        // Update pagination attributes
        component.set("v.startPage", startPage);
        component.set("v.endPage", endPage);

        // Update the pagination list based on the new start and end indices
        var PaginationList = [];
        for (var i = startPage; i <= endPage; i++) {
            PaginationList.push(filteredList[i]);
        }
        component.set("v.PaginationList", PaginationList);
    },
})