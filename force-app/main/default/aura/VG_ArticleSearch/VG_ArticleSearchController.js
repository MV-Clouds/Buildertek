({
    
    
    doInit : function(component, event, helper) {
        component.set("v.recordChosen", false);
        
    },
    doSearch : function(component, event, helper) {
        
        
        helper.serverSearch(component);   
        
        window.onclick = function(event) {
            var matchedRecords = [];
            component.set("v.matchedRecords", matchedRecords);
        }
    },
    setChosen : function(component, event, helper) {
        var record = event.getParam('record');
        component.set("v.lookupVal", record[0]);
        component.set("v.lookupLabel", record[1]); 
        component.set("v.recordChosen", true); 
    },  
    removeChosen : function(component, event, helper) {
        component.find("searchInput").set("v.value", "");
        component.set("v.matchedRecords", []);
        component.set("v.lookupVal", null);
        component.set("v.lookupLabel", null); 
        component.set("v.recordChosen", false); 
    }
    
})