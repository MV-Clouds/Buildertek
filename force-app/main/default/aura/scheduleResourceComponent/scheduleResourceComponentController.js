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
        })

    }

})