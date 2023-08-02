({
	doInit : function(component, event, helper) {
	    helper.getPODetails(component, event, helper);
		helper.getSchedules(component, event, helper);
		helper.fetchPickListVal(component, 'phaseId', 'buildertek__Phase__c');
	},
	 
	clearSelectedValue : function(component, event, helper) {
	    component.set("v.isProject", false);
	    component.set("v.selectedProjectRecord", null);
	    component.set("v.selectedLookUpRecordName", '');
	},
    clearSelectedValueAccount : function(component, event, helper) {
	    component.set("v.isVendor", false);
	    component.set("v.selectedAccountRecord", []); 
	},
	
	handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var schedules = component.get("v.Schedules");
	    for(var i=0 ; i < schedules.length;i++){
	        if(schedules[i].getSchedulesList.Id == checkbox.get("v.text") && schedules[i].scheduleCheckbox == false){
	            schedules[i].scheduleCheckbox = true;
	            component.find("checkContractor")[i].set("v.value", true);
	        }
	        else if(schedules[i].getSchedulesList.Id == checkbox.get("v.text") && schedules[i].scheduleCheckbox == true){
	             schedules[i].scheduleCheckbox = false;
	        }
	    }
	    //alert('Is Checked ---------> '+ checkbox.get("v.value"));
	    var scheduleId = checkbox.get("v.text");
	    component.set("v.scheduleRecId", scheduleId);
	    if(checkbox.get("v.value") == true){
	        //helper.openNewTaskPopup(component, event, scheduleId); 
	        component.set("v.isNewTask", true);
	    }
	},
	
	closeModel: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
   
   /*parentPress : function(component, event, helper) {
        var selectedRecord = component.get("v.selectedProjectRecord").Id;
	    //alert('selectedRecord -----> '+selectedRecord);
	    var action = component.get("c.getProjectSchedules");
	    action.setParams({
	        projectId : selectedRecord
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.Schedules", result);
	        }
	    });
	    $A.enqueueAction(action);
   },*/
   
   save : function(component, event, helper) {
       component.set("v.Spinner", true);
       var selectedRecordId;
       var selectedAccountId;
       var selectedRecord = component.get("v.selectedPredecessorId");
       console.log({selectedRecord});
       if(selectedRecord != undefined && selectedRecord != ''){
           selectedRecordId = selectedRecord;
       }else{
           selectedRecordId = null;
       }
       var selectedAccountRecord = component.get("v.selectedAccountRecord"); 
       if(selectedAccountRecord != undefined){
           selectedAccountId = selectedAccountRecord.Id;   
       }else{
           selectedAccountId = null;
       }
       var projectId;
       var slectedProjectId = component.get("v.selectedProjectRecord");
       //alert('slectedProjectId --------> '+JSON.stringify(slectedProjectId));
       if(slectedProjectId != undefined){
           projectId = slectedProjectId.Id;     
       }else{
           projectId =  component.get("v.selectedProjectId");
       }
       //alert('projectId --------> '+projectId);
       var scheduleId = component.get("v.selectedValue");
       console.log({selectedRecordId});
       //alert('scheduleId --------> '+scheduleId);
       var action = component.get('c.insertScheduleTask');
       action.setParams({
           task: component.get("v.taskRecord"),
           poId : component.get("v.recordId"),
           scheduleId : scheduleId,
           dependency : selectedRecordId,
           contactorResource : selectedAccountId,
           recordId : component.get("v.recordId")
       });
       action.setCallback(this, function(response){
            var state = response.getState();
            //alert('state -------> '+state);
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                //alert('result --------> '+JSON.stringify(result));
                if(result.MessageType === 'Success'){
                    component.set("v.Spinner", false);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": scheduleId,
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                    window.setTimeout(
                        $A.getCallback(function(){
                            var toastEvent = $A.get("e.force:showToast"); 
                            toastEvent.setParams({
                                "title" : "Success!",
                                "message" : 'Purchase Order scheduled successfully',
                                "type" : "success",
                                "duration" : 5000
                            });
                            toastEvent.fire();
                        }),2000
                    );
                   
                }else{
                    component.set("v.Spinner", false);
                     var toastEvent = $A.get("e.force:showToast"); 
                            toastEvent.setParams({
                                "title" : "Error",
                                //"message" : result.Message,
                                "message" : 'Something Went Wrong.',
                                "type" : "error",
                                "duration" : 5000
                            });
                            toastEvent.fire();
                }
                
            }
       });
       $A.enqueueAction(action);
   },
	
	SearchFunction : function(component, event, helper) {
	    var input, filter, table, tr, td, i,a,b,c;
    	input = document.getElementById("scheduleFilterInput");
    	filter = input.value.toUpperCase();
    	table = document.getElementById("myTables");
    	tr = table.getElementsByTagName("tr");
    	for (i = 0; i < tr.length; i++) {
    		td = tr[i].getElementsByTagName("td")[1];
    		
    		if (td) {
    			a=td;
    			if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
    				tr[i].style.display = "";
    			} else {
    				tr[i].style.display = "none";
    			}
    		}     
    	}
	},

    serachPredecessor:function(component, event, helper) {
        console.log('serachPredecessor test');
        component.set('v.diplayPredecessorlist' , true);
        console.log(component.get('v.selectedValue'));
        var action = component.get('c.getPredecessorList');
        action.setParams({
            scheduleId:component.get('v.selectedValue')
        });
        action.setCallback(this, function(response){
            console.log(response.getState());
            console.log(response.getError());
            console.log(response.getReturnValue());
            var state=response.getState();
            var result=response.getReturnValue();

            if(state === 'SUCCESS'){
                console.log('inside success');
                // var getValues=Object.values(result);
                // var getKeys=Object.keys(result);

                const keyValueArray = Object.entries(result).map(([key, value]) => ({ key, value }));

                component.set('v.allPredecessorValue' , keyValueArray);
                component.set('v.predecessorList' , keyValueArray);

            }


        });
        $A.enqueueAction(action);
        console.log(component.get('v.predecessorList'));
    },
    clickPredecessorValue:function(component, event, helper) {
        var record = event.currentTarget.dataset.value;
        var recordId = event.currentTarget.dataset.id;

        component.set("v.selectedPredecessor", record);
        component.set('v.diplayPredecessorlist' , false);
        component.set('v.selectedPredecessorId' , recordId);

        console.log({recordId});


    },
    handleScheduleChange:function(component, event, helper) {
        component.set('v.diplayPredecessorlist' , false);
        component.set('v.selectedPredecessor' , '');
        component.set('v.selectedPredecessorId' , '');


    },
    onkeyUp:function(component, event, helper) {
        var getkeyValue= event.getSource().get('v.value').toLowerCase();
        var getAllPredecessorValue= component.get('v.allPredecessorValue');
        var tempArray = [];
        var i;
        for (i = 0; i < getAllPredecessorValue.length; i++) {
            if ((getAllPredecessorValue[i].value.toLowerCase().indexOf(getkeyValue) != -1)) {
                    tempArray.push(getAllPredecessorValue[i]);
            }else{
                component.set("v.selectedPredecessorId" , '');
            }
        }
        console.log({tempArray});
        component.set('v.predecessorList' , tempArray);
    },
    hideList:function(component, event, helper){
            // component.set('v.diplayPredecessorlist' , false);

    },

})