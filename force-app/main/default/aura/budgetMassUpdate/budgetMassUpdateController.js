({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var budgetId = myPageRef.state.c__budgetId;
        component.set("v.budgetId", budgetId); 
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: 'Mass Update Budget Lines'
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'Mass Update Budget Lines'
            });
        });
    },

    handleCancelEvent: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            if (event.getParam('refresh')) {
                window.postMessage({ action: 'closeSubtab' }, window.location.origin);
            }
            workspaceAPI.closeTab({tabId: tabId});
        });
    }
    
})