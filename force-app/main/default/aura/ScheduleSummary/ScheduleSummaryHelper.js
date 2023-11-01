({
    loadTasks: function (component, recordId) {
        var action = component.get("c.gettaskOfSchedules");
        action.setParams({ "recordId": recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tasks = response.getReturnValue();
                console.log('tasks---->', tasks);
                component.set("v.tasks", tasks);
                this.filterTasks(component);
            } else {
                console.log("Error: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    filterTasks: function (component) {
        try {
            var tasks = component.get("v.tasks");
            var today = new Date();
            var thisWeekStart = new Date(today);
            thisWeekStart.setDate(today.getDate() - today.getDay()); // Start of the week (Sunday)
            var thisWeekEnd = new Date(thisWeekStart);
            thisWeekEnd.setDate(thisWeekStart.getDate() + 6); // End of the week (Saturday)

            // Implement the logic to filter tasks into Past Due, Due This Week, and Due Next Week
            var pastDueTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) < today);
            var dueThisWeekTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) >= thisWeekStart && new Date(task.buildertek__Finish__c) <= thisWeekEnd);
            var nextWeekStart = new Date(thisWeekEnd);
            nextWeekStart.setDate(thisWeekEnd.getDate() + 1); // Start of next week (Sunday)
            var nextWeekEnd = new Date(nextWeekStart);
            nextWeekEnd.setDate(nextWeekStart.getDate() + 6); // End of next week (Saturday)
            var dueNextWeekTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) >= nextWeekStart && new Date(task.buildertek__Finish__c) <= nextWeekEnd);

            component.set("v.pastDueTasks", pastDueTasks);
            component.set("v.dueThisWeekTasks", dueThisWeekTasks);
            component.set("v.dueNextWeekTasks", dueNextWeekTasks);
        } catch (error) {
            console.log('error--->',error);
        }
    }
})
