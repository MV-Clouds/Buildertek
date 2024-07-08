({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var quoteId = myPageRef.state.c__quoteId;
        component.set("v.quoteId", quoteId); 
        console.log(`Quote Id: ${quoteId}`);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: 'Mass Update Quote Lines'
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'Mass Update Quote Lines'
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