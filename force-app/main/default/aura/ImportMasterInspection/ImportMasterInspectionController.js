({
	doInit : function(component, event, helper) {
	    component.set("v.Spinner", true);
        var action = component.get("c.getMasterInspection");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.masterInspectionList", result);
                component.set("v.totalRecords", component.get("v.masterInspectionList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterInspectionList").length> i)
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
        console.log({checkbox});
        var Submittals = component.get("v.masterInspectionList");
        console.log({Submittals});
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
	        if(Submittals[i].masterInspectionRecord != null){
                console.log('Not Null');
                console.log('checkbox.get("v.text")-->',checkbox.get("v.text"));
                console.log('Submittals[i].inspectionCheck-->',Submittals[i].inspectionCheck);
	            if(Submittals[i].masterInspectionRecord.Id == checkbox.get("v.text") && Submittals[i].inspectionCheck == false){
                    console.log('inspectionCheck');
    	            Submittals[i].inspectionCheck = true;
    	        }
    	        else if(Submittals[i].masterInspectionRecord.Id == checkbox.get("v.text") && Submittals[i].inspectionCheck == true){
    	             Submittals[i].inspectionCheck = false;
    	        }    
	        }else if(Submittals[i].mastermasterInspectionRecord != null){
	            if(Submittals[i].mastermasterInspectionRecord.Id == checkbox.get("v.text") && Submittals[i].inspectionCheck == false){
    	            Submittals[i].inspectionCheck = true;
    	        }
    	        else if(Submittals[i].mastermasterInspectionRecord.Id == checkbox.get("v.text") && Submittals[i].inspectionCheck == true){
    	             Submittals[i].inspectionCheck = false;
    	        }    
	        }
	        
	    }
        console.log({Submittals});
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.masterInspectionList");
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
            				var Submittals = component.get("v.masterInspectionList");
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
            				var Submittals = component.get("v.masterInspectionList");
            	                Submittals[i].budgetCheck = false;
                       
                   } 
            }
        }
     
    },
	
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
	
	importBudget : function(component, event, helper){
	    component.set("v.Spinner", true);
	    var InspectionList = component.get("v.masterInspectionList");
        console.log({InspectionList});
	    console.log('quotesList ---------> '+JSON.stringify(InspectionList));
	    var inspectionids = [];
	    for(var i=0 ; i < InspectionList.length;i++){
	        //alert('quoteCheck -------> '+quotesList[i].quoteCheck);
	        
	        if(InspectionList[i].inspectionCheck == true){
                console.log('InspectionList[i].masterInspectionRecord--->',InspectionList[i].masterInspectionRecord);
	            if(InspectionList[i].masterInspectionRecord != null){
                    console.log('IFF');
	                inspectionids.push(InspectionList[i].masterInspectionRecord.Id);    
	            }
                // else if(InspectionList[i].budgetRecord != null){
	            //     inspectionids.push(InspectionList[i].budgetRecord.Id);    
	            // }
	        }
	    }
	    if(inspectionids.length > 0){
	        var action = component.get("c.importMasterInspectionLines");
	        action.setParams({
	            inspectionIds : inspectionids,
	            recordId : component.get("v.recordId")
	        });
	        action.setCallback(this, function(response){
                console.log({response});
	            var state = response.getState();
	            if(state === "SUCCESS"){
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
                "message": 'Please Select at least One Inspection record.',
                "type": 'Error',
                "duration": '10000',
				"mode": 'dismissible'
            });    
              toastEvent.fire();
	    }
	},
	
	next: function (component, event, helper) {
        var sObjectList = component.get("v.masterInspectionList");
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
        var sObjectList = component.get("v.masterInspectionList"); 
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