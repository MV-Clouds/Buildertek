({
	getPODetails : function(component, event, helper) {
	    var action = component.get("c.getPurchaseOrderData");  
	    action.setParams({
	        "recordId" : component.get("v.recordId")
	    });
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
                console.log(result);
        	    if(result.buildertek__Project__c != null){
                    component.set("v.selectedProjectId", result.buildertek__Project__c);
                }
                if(result.buildertek__Description__c != null){
                    component.set("v.selectedTaskName", result.buildertek__Description__c);
                }
                if(result.buildertek__Vendor__c != null){
                    component.set("v.selectedVendorId",result.buildertek__Vendor__c);
                }
                if( result.buildertek__BT_Build_Phase__c != null  && (result.buildertek__BT_Build_Phase__r.Name != null || result.buildertek__BT_Build_Phase__r.Name != '' || result.buildertek__BT_Build_Phase__r.Name != undefined)){
                    //if result.buildertek__BT_Build_Phase__r.Name isn't in phaseoption
                    var phaseOptions = component.get("v.phaseOptions");
                    if(phaseOptions.indexOf(result.buildertek__BT_Build_Phase__r.Name) == -1){
                        var selectedPhase = '';
                        for(var i=0;i<phaseOptions.length;i++){
                            if(phaseOptions[i] == 'No Phase'){
                                selectedPhase = phaseOptions[i];
                            }
                        }
                        component.set("v.selectedPhase",selectedPhase);
                    }else{
                        component.set("v.selectedPhase",result.buildertek__BT_Build_Phase__r.Name);
                    }
                }else{
                    //find if we have 'No Phase' in the picklist
                    var phaseOptions = component.get("v.phaseOptions");
                    var selectedPhase = '';
                    for(var i=0;i<phaseOptions.length;i++){
                        if(phaseOptions[i] == 'No Phase'){
                            selectedPhase = phaseOptions[i];
                        }
                    }
                    component.set("v.selectedPhase",selectedPhase);
                }
                //BUIL-4184: we are not counting if the start date, end date and duration are mathethically physible because the ticket says they come from different object
                if(result.buildertek__Estimated_Start_Date__c != null){
                    component.set("v.StartDate",result.buildertek__Estimated_Start_Date__c);
                }
                if(result.buildertek__Estimated_Completion_Date__c != null){
                    component.set("v.FinishDate",result.buildertek__Estimated_Completion_Date__c);
                    component.set("v.disablefields", false);
                }
                if(result.buildertek__Estimated_Completion_Date__c != null && result.buildertek__Estimated_Start_Date__c != null){
                    var includeWeekend = component.get("v.includeWeekends");
                    console.log('includeWeekend--->',includeWeekend);
                    if(includeWeekend){
                        helper.calDurationwithWeekend(component, event, helper);
                    }else{
                        helper.calcDurartionwithoutweekend(component, event, helper);
                    }
                }
                helper.getSchedules(component, event, helper);
        	} 
        });  
        $A.enqueueAction(action);    
	}, 

    checkWeekend:function(component, event, helper){
        console.log('checkWeekend--->');
        var action = component.get("c.checkIncludeWeekend");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result--->',result);
                component.set("v.includeWeekends", result);
            }});    
        $A.enqueueAction(action);
    },

    calDurationwithWeekend:function(component, event, helper){
        var startDate = component.get('v.StartDate');
        var finishDate = component.get('v.FinishDate');
        var start = new Date(startDate);
        var finish = new Date(finishDate);
        console.log('start--->',start);
        console.log('finish--->',finish);  
        var diffMs = finish - start;
        var diffDays = diffMs / (1000 * 60 * 60 * 24);
        diffDays = diffDays + 1;
        console.log('diffDays--->',diffDays);
        component.set('v.durationNum', diffDays);
    },

    calcDurartionwithoutweekend:function(component, event, helper){
        try {
            console.log('calcDur--->');
            var startDate = component.get('v.StartDate');
            var finishDate = component.get('v.FinishDate');
            console.log('StartDate: ' + startDate);
            console.log('finishDate: ' + finishDate);
            console.log('finishDate--->',finishDate);
            if (finishDate != null) {
                var inputField = component.find('finishDate');
                if (finishDate < startDate) {
                    inputField.setCustomValidity('Finish Date must be after Start Date');
                    inputField.reportValidity();
                } else {
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                    var escapeWeekendDays = helper.modifyDate(finishDate);
                    var formattedFinishDate = escapeWeekendDays.getFullYear() + '-' + 
                                            ('0' + (escapeWeekendDays.getMonth() + 1)).slice(-2) + '-' + 
                                            ('0' + escapeWeekendDays.getDate()).slice(-2);
                    console.log('finishDate-->',formattedFinishDate);
                    component.set('v.FinishDate', formattedFinishDate);
                    var start = new Date(startDate);
                    var finish = new Date(formattedFinishDate);
                    var workingDays = 0;
                    
                    // Loop through each day between start and finish dates
                    while (start <= finish) {
                        // Check if the day is not a weekend (Saturday or Sunday)
                        if (start.getDay() !== 0 && start.getDay() !== 6) {
                            workingDays++;
                        }
                        // Move to the next day
                        start.setDate(start.getDate() + 1);
                    }
                    
                    console.log('workingDays--->',workingDays);
                    // let date1 = new Date(startDate);
                    // let date2 = new Date(finishDate);
                    // let Difference_In_Time = date2.getTime() - date1.getTime();
                    // let Difference_In_Days = Math.round(Difference_In_Time / (1000 * 3600 * 24));
                    // console.log("Total number of days between dates: " , Difference_In_Days);
                    component.set('v.durationNum', workingDays);
                }
            } else {
                component.set('v.durationNum', '');
            }
        } catch (error) {
            console.log('error--->',error);
        }
    },

	getSchedules : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function () {
                component.set("v.Spinner", false);
            }), 2000
        );
		var action = component.get("c.getSchedulelist"); 
		action.setParams({
		    "recordId" : component.get("v.recordId")
		});
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
        		component.set("v.Schedules", result);
        	} 
        });  
        $A.enqueueAction(action);
	},

    getFieldsetValue : function(component, event, helper) {
        component.set("v.Spinner", true);
		var getFields = component.get("c.getFieldSet");
        getFields.setParams({
            objectName: 'buildertek__Project_Task__c',
            fieldSetName: 'buildertek__New_Fieldset_For_Po'
        });
        getFields.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                console.log({listOfFields});
                var phaseField = listOfFields.find(field => field.name === 'buildertek__Phase__c');
                if(phaseField != null && phaseField != undefined){
                    // console.log('phaseField.pickListValuesList--->', phaseField.pickListValuesList);
                    component.set("v.phaseOptions", phaseField.pickListValuesList);
                }
                component.set("v.listOfFields", listOfFields);
            }
        });
        $A.enqueueAction(getFields);
        helper.getPODetails(component, event, helper);
	},

    modifyDate: function(inputDate) {
        // Convert the inputDate to a JavaScript Date object
        var dt = new Date(inputDate);
        
        // Check if the inputDate is Saturday (6) or Sunday (0)
        var dayOfWeek = dt.getDay();
        if (dayOfWeek === 6) { // Saturday
            dt.setDate(dt.getDate() + 2); // Add 2 days
        } else if (dayOfWeek === 0) { // Sunday
            dt.setDate(dt.getDate() + 1); // Add 1 day
        }
        // Return the modified date
        return dt;
    },

})