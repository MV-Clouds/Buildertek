({
    doInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Schedule Tab"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom14',
                iconAlt: 'Schedule Tab'
            });
        })

    }

})