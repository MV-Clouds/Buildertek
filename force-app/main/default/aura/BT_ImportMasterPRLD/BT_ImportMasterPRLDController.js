({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var recId =  component.get("v.recordId");
        var action = component.get("c.getMasterBudgets");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterBudgetsList", result);
                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
	
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();
        var Submittals = component.get("v.masterBudgetsList");
	    for(var i=0 ; i < Submittals.length;i++){
	        if(Submittals[i].budgetRecord != null){
	            if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
    	            Submittals[i].budgetCheck = true;
                    
    	        }
    	        else if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
    	             Submittals[i].budgetCheck = false;
    	        }    
	        }else if(Submittals[i].masterBudgetRecord != null){
	            if(Submittals[i].masterBudgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
    	            Submittals[i].budgetCheck = true;
    	        }
    	        else if(Submittals[i].masterBudgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
    	             Submittals[i].budgetCheck = false;
    	        }    
	        }
	        
	    }
        
       /*   var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.masterBudgetsList");
       
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedRFQIds",selectedRfqIds);*/
        
        
        
        
        
        
        
        
        
        
    },
    
     selectAll : function(component, event, helper) { 
       var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.masterBudgetsList");
        var getAllId = component.find("checkContractor");
        
        if (getAllId != undefined) {
            if (Submittals.length > 1) {
        if(! Array.isArray(getAllId)){
           if(selectedHeaderCheck == true){ 
              component.find("checkContractor").set("v.value", true); 
              component.set("v.selectedCount", 1);
               
           }else{
               component.find("checkContractor").set("v.value", false);
               component.set("v.selectedCount", 0);
           }
        }
        else{ 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
					component.find("checkContractor")[i].set("v.value", true); 
					var checkbox = component.find("checkContractor")[i].get("v.text");  
            	        Submittals[i].budgetCheck = true;
            	    
                }
            } 
            else{
                for (var i = 0; i < getAllId.length; i++) {
    				component.find("checkContractor")[i].set("v.value", false); 
    				var checkbox = component.find("checkContractor")[i].get("v.text"); 
    				var Submittals = component.get("v.masterBudgetsList");
    	                Submittals[i].budgetCheck = false;
               }
           } 
        } 
            }else{
                var i = 0;
				if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
					Submittals[i].budgetCheck = true;
				} else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].budgetCheck = false;
				}
            }   
        }
           /*var checkStatus = event.getSource().get("v.value");
        var rfqRecordList = component.get("v.masterBudgetsList");;
        var getAllId = component.find("checkContractor");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkContractor").set("v.value", true);
                    var Id = component.find("checkContractor").get("v.text");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkContractor")[i].set("v.value", true);
                        var Id = component.find("checkContractor")[i].get("v.text");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                        //rfqRecordList[i].checkValue = "true";
                    }
                }
                component.set("v.masterBudgetsList",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkContractor").set("v.value", false);
                    var Id = component.find("checkContractor").get("v.text");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkContractor")[i].set("v.value", false);
                        var Id = component.find("checkContractor")[i].get("v.text");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                        //rfqRecordList[i].checkValue = "true";
                    }
                }
                component.set("v.masterBudgetsList",recordIds);
            }
        }
        console.log(recordIds);*/
         
         
         
         
    },
	
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
	
	importBudget : function(component, event, helper){
	    component.set("v.Spinner", true);
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
	    var budgetsList = component.get("v.masterBudgetsList");
	    var budgetIds = [];
        if(budgetsList != null){
	    for(var i=0 ; i < budgetsList.length;i++){
	     if(budgetsList[i].budgetCheck == true){
	                budgetIds.push(budgetsList[i].budgetRecord.Id);
               
           }
	      }
	    }
	    if(budgetIds.length > 0){
             component.set("v.selectedobjInfo",budgetIds);
	        var action = component.get("c.importRFQItems");  
	        action.setParams({
	            budgetIds : budgetIds,
	            recordId : component.get("v.recordId")
	        });
	        action.setCallback(this, function(response){
	            var state = response.getState();
	            if(state === "SUCCESS"){
	                var result = response.getReturnValue();  
	               if(state === "SUCCESS"){
	                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "PLRD's Imported successfully",
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire();  
                        window.setTimeout(
                            $A.getCallback(function() {
                                document.location.reload(true);    
                            }), 1000
                        );
	                }else{
	                    component.set("v.Spinner", false);
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
	        component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please Select at least One PLRD record.',
                "type": 'Error',
                "duration": '10000',
				"mode": 'dismissible'
            });    
              toastEvent.fire();
	    }
	},
    
      searchKeyChange: function(component, event) {
        var list = component.get("v.PaginationList");
         // alert(JSON.stringify(list));
        var searchKey = component.find("searchKey").get("v.value");
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey,
             recId : component.get("v.recordId"),
           // "searchKeys":searchKeys
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
           //alert( JSON.stringify(result));
            /* for ( var i = 0; i < result.length; i++ ) {
                var row = result[i];
              alert(JSON.stringify(row));
                row.RFQName = row.buildertek__Category__r.Name;
                 alert( row.RFQName);
               // var rfqauto =  row.buildertek__RFQ__r.buildertek__Auto_Number__c.split("-");
              //  row.WhatName = 'RFQ' +' - '+ ; 
               // row.Id = '/vendor/s/rfq-to-vendor/' + row.Id;
            }*/
            if(searchKey != ''){
            component.set("v.PaginationList",result);
            }
            else{
                 var action1 = component.get("c.getMasterBudgets");
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterBudgetsList", result);
                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
        
    },
    
     handleComponentEvent : function(component, event, helper){
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var recId = component.get("v.mainObjectId");
       helper.getRfqList(component, event, helper, pageNumber, pageSize, productCategoryValue);
     },           
	
	next: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList");
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
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList"); 
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
    },
})