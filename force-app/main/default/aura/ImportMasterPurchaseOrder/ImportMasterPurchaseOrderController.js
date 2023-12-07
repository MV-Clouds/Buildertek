({
	doInit : function(component, event, helper) {
        try {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var action = component.get("c.getMasterPO");
            action.setCallback(this, function(response){
                var result = response.getReturnValue();
                console.log('result---> ',result);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if(result != null){
                    var pageSize = component.get("v.pageSize");
                    component.set("v.masterPOList", result);
                    component.set("v.totalRecords", component.get("v.masterPOList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.masterPOList").length> i)
                            PaginationList.push(result[i]);    
                    }
                    component.set('v.PaginationList', PaginationList);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Something went wrong.',
                        "type": 'Error'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
            helper.getcurr(component, event, helper);
        } catch (error) {
            console.log('error---> ',error);
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        }
	},
	
	handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        console.log({checkbox});
        var Submittals = component.get("v.masterPOList");
        console.log({Submittals});
	    
	    for(var i=0 ; i < Submittals.length;i++){
	        if(Submittals[i].masterPORecord != null){
                console.log('Not Null');
                console.log('checkbox.get("v.text")-->',checkbox.get("v.text"));
                console.log('Submittals[i].poCheck-->',Submittals[i].poCheck);
	            if(Submittals[i].masterPORecord.Id == checkbox.get("v.text") && Submittals[i].poCheck == false){
                    console.log('poCheck');
    	            Submittals[i].poCheck = true;
    	        }
    	        else if(Submittals[i].masterPORecord.Id == checkbox.get("v.text") && Submittals[i].poCheck == true){
    	             Submittals[i].poCheck = false;
    	        }    
	        }else if(Submittals[i].mastermasterPORecord != null){
	            if(Submittals[i].mastermasterPORecord.Id == checkbox.get("v.text") && Submittals[i].poCheck == false){
    	            Submittals[i].poCheck = true;
    	        }
    	        else if(Submittals[i].mastermasterPORecord.Id == checkbox.get("v.text") && Submittals[i].poCheck == true){
    	             Submittals[i].poCheck = false;
    	        }    
	        }
	        
	    }
        console.log({Submittals});
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.masterPOList");
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
                    	        Submittals[i].poCheck = true;
                    	    
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
            				component.find("checkContractor")[i].set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor")[i].get("v.text"); 
            				var Submittals = component.get("v.masterPOList");
            	                Submittals[i].poCheck = false;
                       }
                   } 
                } 
            }
            else{
                var i=0;
                    if (selectedHeaderCheck == true) {
                        	component.find("checkContractor").set("v.value", true); 
        					var checkbox = component.find("checkContractor").get("v.text");  
                    	        Submittals[i].poCheck = true;
                    	    
                        
                    } 
                    else{
                       		component.find("checkContractor").set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor").get("v.text"); 
            				var Submittals = component.get("v.masterPOList");
            	                Submittals[i].poCheck = false;
                       
                   } 
            }
        }
     
    },
	
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
	
	importPOLine : function(component, event, helper){
	    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
	    var POList = component.get("v.masterPOList");
        console.log({POList});
	    console.log('quotesList ---------> '+JSON.stringify(POList));
	    var poids = [];
	    for(var i=0 ; i < POList.length;i++){
	        if(POList[i].poCheck == true){
                console.log('POList[i].masterPORecord--->',POList[i].masterPORecord);
	            if(POList[i].masterPORecord != null){
                    console.log('IFF');
	                poids.push(POList[i].masterPORecord.Id);    
	            }
	        }
	    }
        console.log('poids.length---->' + poids.length);
	    if(poids.length > 0){
	        var action = component.get("c.importMasterPOLines");
	        action.setParams({
	            poIds : poids,
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
                "message": 'Please Select at least One PO record.',
                "type": 'Error',
                "duration": '10000',
				"mode": 'dismissible'
            });    
              toastEvent.fire();
	    }
	},
	
	next: function (component, event, helper) {
        var sObjectList = component.get("v.masterPOList");
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
        var sObjectList = component.get("v.masterPOList"); 
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