({
    doInit: function (component, event, helper) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));
        console.log('Base URL::', baseURL);
        component.set("v.BaseURL", baseURL);
        helper.getProjects(component, event, helper);
    },

    openSchedule: function (component, event, helper) {
        var recordId = event.target.dataset.schedule;
        if (recordId != '' && recordId != undefined) {
            component.set('v.recordId', recordId);
        }
    },

    onExpandCollapse: function (component, event, helper) {
        console.log('Status :: ', event.target.dataset.status);
        var list = component.get('v.listOfRecords');
        var index = event.target.dataset.index;
        list[index].buildertek__Is_Expanded__c = !list[index].buildertek__Is_Expanded__c;
        component.set('v.listOfRecords', list);

    },
})