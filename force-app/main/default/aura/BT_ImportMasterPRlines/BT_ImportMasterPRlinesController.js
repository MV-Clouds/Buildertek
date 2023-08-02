({
    doInit : function(component, event, helper) {
        debugger;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Import Pricing Requests"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Import Pricing Requests' 
        });
    });
    var action = component.get("c.getSOVName");
    action.setParams({
    recordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
        debugger;
        if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
            var  result = response.getReturnValue();
            component.set("v.PRName",result.Name)
        }
    });
    $A.enqueueAction(action);
    var action1 = component.get("c.getPRs");
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterquotesList", result);
                component.set("v.totalRecords", component.get("v.masterquotesList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterquotesList").length> i)
                        PaginationList.push(result[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.isLoading", false);
            }
        });
	    $A.enqueueAction(action1);
 },
 NavToSovRec: function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
        "recordId": component.get("v.recordId"),
        "slideDevName": "detail"
    });
    navEvt.fire();
 },
     handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var Submittals = component.get("v.masterquotesList");
      
	    /*for(var i=0 ; i < Submittals.length;i++){
	        console.log('=========> ',i +' '+ Submittals.length);
	        if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].quoteCheck == false){
	            Submittals[i].quoteCheck = true;
	            if(Submittals.length > 1){
	                component.find("checkContractor")[i].set("v.value", true);
	            }
	            else{
	                component.find("checkContractor").set("v.value", true);
	            }
	        }
	        else if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].quoteCheck == true){
	             Submittals[i].quoteCheck = false;
	             component.find("checkContractors").set("v.value", false);
	        }
	    }*/
	    
	    for(var i=0 ; i < Submittals.length;i++){
	        if(Submittals[i].quoteRecord != null){
	            if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
    	            Submittals[i].budgetCheck = true;
                    
    	        }
    	        else if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
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
    },
     selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.masterquotesList");
        var getAllId = component.find("checkContractor"); 
        if(Submittals != null){
            if(Submittals.length > 1){
                if(! Array.isArray(getAllId)){
                   if(selectedHeaderCheck == true){ 
                      component.find("checkContractor").set("v.value", true); 
                   }else{
                       component.find("checkContractor").set("v.value", false);
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
            				var Submittals = component.get("v.masterquotesList");
            	                Submittals[i].budgetCheck = false;
                       }
                   } 
                } 
            }
            else{
                var i=0;
                    if (selectedHeaderCheck == true) {
                        	component.find("checkContractor").set("v.value", true); 
        					var checkbox = component.find("checkContractor").get("v.text");  
                    	        Submittals[i].budgetCheck = true;
                    	    
                        
                    } 
                    else{
                       		component.find("checkContractor").set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor").get("v.text"); 
            				var Submittals = component.get("v.masterquotesList");
            	                Submittals[i].budgetCheck = false;
                       
                   } 
            }
        }
     
    },
	
	closeModel : function(component, event, helper){
	  var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
            //  $A.get('e.force:refreshView').fire();  
            
            var workspaceAPI = component.find( "workspace" );
            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                var focusedTabId = response.tabId;
                window.setTimeout(
                    $A.getCallback(function() {
                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                        $A.get('e.force:refreshView').fire();
                    }), 1500);
            })
	},
        importQuote : function(component, event, helper){
	    component.set("v.Spinner", true);
	    var budgetsList = component.get("v.masterquotesList");
	    console.log('quotesList ---------> '+JSON.stringify(budgetsList));
	    var budgetIds = [];
	    for(var i=0 ; i < budgetsList.length;i++){
	        //alert('quoteCheck -------> '+quotesList[i].quoteCheck);
	        
	        if(budgetsList[i].budgetCheck == true){
	            if(budgetsList[i].masterBudgetRecord != null){
	                budgetIds.push(budgetsList[i].masterBudgetRecord.Id);    
	            }else if(budgetsList[i].quoteRecord != null){
	                budgetIds.push(budgetsList[i].quoteRecord.Id);    
	            }
	        }
	    }
	    if(budgetIds.length > 0){
	        var action = component.get("c.importMasterBudgetLines1");  
	        action.setParams({
	            budgetIds : budgetIds,
	            recordId : component.get("v.recordId")
	        });
	        action.setCallback(this, function(response){
	            var state = response.getState();
	            if(state === "SUCCESS"){
	                var result = response.getReturnValue();  
	                if(result.Status === 'Success'){
                        component.set('v.isdisabled', true);
                        var workspaceAPI = component.find( "workspace" );
                        workspaceAPI.getFocusedTabInfo().then( function( response ) {
                            var focusedTabId = response.tabId;
                            window.setTimeout(
                                $A.getCallback(function() {
                                    workspaceAPI.closeTab( { tabId: focusedTabId } );
                                    $A.get('e.force:refreshView').fire();
                                }), 1500);
                        })
                         setTimeout(function () {
                        var payload = component.get("v.recordId");
                        var url = location.href;
                        var baseURL = url.substring(0, url.indexOf('/', 14));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            messageTemplate: result.Message,
                            messageTemplateData: [{
                                url: baseURL + '/lightning/r/buildertek__Pricing_Request__c/' + payload + '/view',
                                label: payload.name,
                            }],
                            type: 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": payload,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                             }, 200);
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
                "message": 'Please Select at least One Pricing Request record.',
                "type": 'Error',
                "duration": '10000',
				"mode": 'dismissible'
            });   
             toastEvent.fire();
	    }
	},
	
	next: function (component, event, helper) {
        var sObjectList = component.get("v.masterquotesList");
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
        var sObjectList = component.get("v.masterquotesList"); 
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