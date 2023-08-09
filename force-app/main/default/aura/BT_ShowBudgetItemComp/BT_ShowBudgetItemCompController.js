({
	handleShowBudgetLineComponent: function (component, event, helper) {
     
        var recordId = component.get("v.recordId");
        window.open("/lightning/cmp/buildertek__BT_NewBudgetItemClone?buildertek__recordId="+recordId,"_blank");
        
        component.set("v.showBudgetLineComp","true");
       /* var myPageRef = component.get("v.pageReference");
        var Id = myPageRef.state.buildertek__recordId;
        component.set("v.recordId",Id);*/
    },
})