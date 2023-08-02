({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper); 
    },
    onCheck: function (component, event, helper) {
        helper.onCheck(component, event, helper);
    },  
    selectAllCheckbox: function(component,event,helper) {
        var isSelected = component.get('v.isAllSelected');
        helper.selectAll(component, event, helper,isSelected);
    },
    saveRecord : function(component, event, helper) {
        component.set("v.disableButton",true);
        var disableButton =  component.get("v.disableButton");
        if(disableButton){
            helper.createIssueFailureMode(component, event, helper);
        }
    },
    searchData : function(component, event, helper) {
        helper.searchResult(component, event, helper);
    },
    cancelRecord : function(component, event, helper) {
        helper.redirectToDetailPage(component, event, helper);
    },
})