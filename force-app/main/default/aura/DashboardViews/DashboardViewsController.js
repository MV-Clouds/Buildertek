({
    doInit: function (component, event, helper) {
        component.set("v.Dashboardview", "calendarView");
        helper.gettabname(component);

    },

    onresourceview: function (component, event, helper) {
        component.set("v.Dashboardview", "Resourceview");
    },

    onTaskview: function (component, event, helper) {
        component.set("v.Dashboardview", "taskview");
    },

    onProjectView: function (component, event, helper) {
        component.set("v.Dashboardview", "projectView");
    },
    
    onCalendarview : function (component, event, helper) {
        component.set("v.Dashboardview", "calendarView");
    },

})