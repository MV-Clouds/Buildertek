({
    loadTasks: function (component, recordId) {
        var action = component.get("c.gettaskOfSchedules");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var tasks = response.getReturnValue();
                console.log('tasks---->', tasks);
                if (tasks.length > 0) {
                    tasks.forEach(task => {
                        if (!task.buildertek__Contractor__c) {
                            task.buildertek__Contractor__c = '';
                        }else{
                            task.buildertek__Contractor__c = task.buildertek__Contractor__c;
                        }
                    });
                }

                component.set("v.tasks", tasks);
                component.set("v.taskListInit", tasks);
                this.filterTasks(component);

            } else {
                $A.get("e.force:closeQuickAction").fire() 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type": "error",
                            "message": "Something went wrong."  
                        });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    filterTasks: function (component) {
        var taskList = component.get("v.tasks");
        var tasks= [];

        taskList.forEach(function(task) {
            if (task) {
                var dateStr = task.buildertek__Finish__c;
                if (dateStr) {
                    var date = new Date(dateStr);
                    var month = (date.getMonth() + 1).toString().padStart(2, '0');
                    var day = date.getDate().toString().padStart(2, '0');
                    var year = date.getFullYear().toString().substr(-2);
                    dateStr = month + '-' + day + '-' + year;
                }
                task.buildertek__Finish__c = dateStr;
                tasks.push(task);
            }
        });
        
        var today = new Date();
        today.setHours(0, 0, 0, 0); // Set the time to midnight

        var thisWeekStart = new Date(today);
        thisWeekStart.setDate(today.getDate() - today.getDay()); // Start of the week (Sunday)
        thisWeekStart.setHours(0, 0, 0, 0); // Set the time to midnight

        var thisWeekEnd = new Date(thisWeekStart);
        thisWeekEnd.setDate(thisWeekStart.getDate() + 6); // End of the week (Saturday)
        thisWeekEnd.setHours(23, 59, 59, 999); // Set the time to 23:59:59.999

        // Implement the logic to filter tasks into Past Due, Due This Week, and Due Next Week
        var pastDueTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) < thisWeekStart);
        var dueThisWeekTasks = tasks.filter(task => {
            var taskDate = new Date(task.buildertek__Finish__c);
            return taskDate >= thisWeekStart && taskDate <= thisWeekEnd;
        });

        var nextWeekStart = new Date(thisWeekEnd);
        nextWeekStart.setDate(thisWeekEnd.getDate() + 1); // Start of next week (Sunday)
        nextWeekStart.setHours(0, 0, 0, 0); // Set the time to midnight

        var nextWeekEnd = new Date(nextWeekStart);
        nextWeekEnd.setDate(nextWeekStart.getDate() + 6); // End of next week (Saturday)
        nextWeekEnd.setHours(23, 59, 59, 999); // Set the time to 23:59:59.999

        var dueNextWeekTasks = tasks.filter(task => {
            var taskDate = new Date(task.buildertek__Finish__c);
            return taskDate >= nextWeekStart && taskDate <= nextWeekEnd;
        });

        component.set("v.pastDueTasks", pastDueTasks);
        component.set("v.dueThisWeekTasks", dueThisWeekTasks);
        component.set("v.dueNextWeekTasks", dueNextWeekTasks);
    },
    FieterTaskWithVendorNameAndCurrentProject: function(component,recordId, contractorId) {
        var taskList = component.get("v.tasks");
        if (contractorId) {
            var matchingTasksList = [];
            taskList.filter(function(task) {
                if(task.buildertek__Contractor__c === contractorId){
                    matchingTasksList.push(task);
                }
            });
            // Set the matching tasks list back to the original taskList
            component.set("v.tasks", matchingTasksList);
            this.filterTasks(component);        
        } else {
            var taskListInit = component.get("v.taskListInit");
            component.set("v.tasks", taskListInit);
            this.filterTasks(component);

        }
    },
    getContractorListHelper: function(component, event, helper) {

        var action = component.get("c.getContractorRecords");
        component.set("v.Message" , 'Loading...');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result= response.getReturnValue();
            if (state === "SUCCESS") {
                if(result.length > 100){
                    var contractorListLimited = [];
                    for(var  i=0; i<=99; i++){
                        contractorListLimited.push(result[i]);
                    }
                    component.set("v.contractorList", contractorListLimited);
                    // console.log("contractorList => ", contractorListLimited);
                }
                else{
                    component.set('v.contractorList' ,result);
                }
                
                if (result.length > 0) {
                    component.set("v.Message" , '');  
                }else{
                    component.set("v.Message" , 'There are No Contractor.');  
                }
                component.set('v.allContractorRecords' ,result);
            }
        });
        $A.enqueueAction(action);
    },

    Cutout_ContractorRecords : function(component, event){
        var result =  component.get('v.allContractorRecords');
        if(result.length > 100){
            var contractorListLimited = [];
            for(var  i=0; i<=99; i++){
                contractorListLimited.push(result[i]);
            }
            component.set("v.contractorList", contractorListLimited);
            // console.log("contractorList => ", contractorListLimited);
        }
        else{
            component.set('v.contractorList' ,result);
        }
    }
})