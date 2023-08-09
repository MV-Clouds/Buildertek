({
    doInit: function (component, event, helper) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));
        component.set("v.BaseURL", baseURL);
        helper.getTradeType(component, event, helper);
    },

    openSchedule: function (component, event, helper) {
        var recordId = event.target.dataset.schedule;
        component.set('v.recordId', recordId);
    },
})