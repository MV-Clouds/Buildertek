({
    doInit : function(component, event, helper) {
        helper.getAccountData(component, event, helper);
    },
   closeModel: function(component, event, helper) {
       var accountObj = component.get('v.account'); 
       component.set("v.isOpen", false);       
       helper.navigateToDetailPage(accountObj.Id);
   },
})