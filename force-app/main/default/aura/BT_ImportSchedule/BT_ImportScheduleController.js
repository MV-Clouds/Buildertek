({
	doInit : function(component, event, helper) {
	    component.set("v.Spinner", true);
        var action = component.get("c.getMasterQuotes");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterQuotesList", result);
                component.set("v.totalRecords", component.get("v.masterQuotesList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterQuotesList").length> i)
                        PaginationList.push(result[i]);    
                }
                //alert('PaginationList Length ------> '+PaginationList.length);
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }
        });
	    $A.enqueueAction(action);
	},
	
	handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var Submittals = component.get("v.masterQuotesList");
	    for(var i=0 ; i < Submittals.length;i++){
	        console.log('=========> ',i +' '+ Submittals.length);
	        if(Submittals[i].scheduleRecord.Id == checkbox.get("v.text") && Submittals[i].scheduleCheck == false){
	            Submittals[i].scheduleCheck = true;
	            if(Submittals.length > 1){
	                component.find("checkContractor")[i].set("v.value", true);
	            }
	            else{
	                component.find("checkContractor").set("v.value", true);
	            }
	        }
	        else if(Submittals[i].scheduleRecord.Id == checkbox.get("v.text") && Submittals[i].scheduleCheck == true){
	             Submittals[i].scheduleCheck = false;
	             component.find("checkContractors").set("v.value", false);
	        }
	    }
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.masterQuotesList");
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
                    	        Submittals[i].scheduleCheck = true;
                    	    
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
            				component.find("checkContractor")[i].set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor")[i].get("v.text"); 
            				var Submittals = component.get("v.masterQuotesList");
            	                Submittals[i].scheduleCheck = false;
                       }
                   } 
                } 
            }
            else{
                var i=0;
                    if (selectedHeaderCheck == true) {
                        	component.find("checkContractor").set("v.value", true); 
        					var checkbox = component.find("checkContractor").get("v.text");  
                    	        Submittals[i].scheduleCheck = true;
                    	    
                        
                    } 
                    else{
                       		component.find("checkContractor").set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor").get("v.text"); 
            				var Submittals = component.get("v.masterQuotesList");
            	                Submittals[i].scheduleCheck = false;
                       
                   } 
            }
        }
     
    },
	
	closeModel : function(component, event, helper){
	   var projectId = component.get("v.ParentId");
	   var url = location.href;
       var baseURL = url.substring(0, url.indexOf('--', 0));
       alert('baseURL --------> '+baseURL);
	   window.open(baseURL+'.lightning.force.com/lightning/r/'+escape(projectId)+'/related/buildertek__Schedules__r/view', '_self');
	},
	
	importQuote : function(component, event, helper){
	    /*component.set("v.Spinner", true);
	    var quotesList = component.get("v.masterQuotesList");
	    var quoteIds = [];
	    for(var i=0 ; i < quotesList.length;i++){
	        //alert('scheduleCheck -------> '+quotesList[i].scheduleCheck);
	        if(quotesList[i].scheduleCheck == true){
	            quoteIds.push(quotesList[i].scheduleRecord.Id);
	        }
	    }
	    //alert('quoteLines --> '+quoteIds);
	    if(quoteIds.length > 0){
	        var action = component.get("c.importMasterQuoteLines");  
	        action.setParams({
	            quoteIds : quoteIds,
	            recordId : component.get("v.recordId")
	        });
	        action.setCallback(this, function(response){
	            var state = response.getState();
	            if(state === "SUCCESS"){
	                var result = response.getReturnValue();  
	                if(result.Status === 'Success'){
	                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": result.Message,
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
	    }*/
	},
	
	next: function (component, event, helper) {
        var sObjectList = component.get("v.masterQuotesList");
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
        var sObjectList = component.get("v.masterQuotesList"); 
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