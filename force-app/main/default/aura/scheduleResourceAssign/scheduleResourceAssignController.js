({
    doInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Schedule Resources Tab"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom92',
                iconAlt: 'Schedule Tab'
            });
        });

        console.log('page refrence :', JSON.parse(JSON.stringify(component.get("v.pageReference"))));

        var pageRefrence = component.get("v.pageReference");
        var states = pageRefrence.state;
        var scheduleId = states.c__scheduleId;
        var vendorId = states.c__vendorId ? states.c__vendorId : null;
        var vendorResourceId = states.c__vendorResourceId ? states.c__vendorResourceId : null;

        component.set("v.scheduleId", scheduleId);
        component.set("v.vendorId", vendorId);
        component.set("v.vendorResourceId", vendorResourceId);

    }

})