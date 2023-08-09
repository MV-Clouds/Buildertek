({
    doInit : function(component, event, helper) {
        var redId = component.get("v.recordId");
        console.log('Service Resource ID ',redId);
        helper.getProductsForNewFSE(component,helper,redId);
        helper.getServiceRecource(component,helper,redId);
        helper.getServiceRecourceSelfOrOther(component,helper,redId);
        component.set("v.radioSelectedPreEmp",'PreEmp');
        component.set("v.radioSelectedNewFSE",'nonNewFSE'); 
        component.set("v.value", 'PreEmp');        
    },
    handleissueTypeChangeHandler : function(component,event,helper)
    {
        var cSelected = event.getSource().get("v.value");
        console.log(' Radion Selected ',cSelected);
        if(cSelected == "NewFSE")
        {
            component.set("v.radioSelectedNewFSE",cSelected);
            component.set("v.radioSelectedPreEmp",'noPreEmp'); 
        }
        if(cSelected == "PreEmp")
        {
            component.set("v.radioSelectedPreEmp",cSelected);
            component.set("v.radioSelectedNewFSE",'nonNewFSE'); 
        }
    },
    onRadioChangeNewFSE : function(component, event, helper) {
        
        var cSelected = event.getSource().get("v.value");
        var redId = component.get("v.recordId");
        component.set("v.radioSelectedNewFSE",cSelected);
        component.set("v.radioSelectedPreEmp",'noPreEmp');
        
        
    },
    
    onRadioChangePreEmp : function(component, event, helper) {
        
        var cSelected = event.getSource().get("v.value");
        var redId = component.get("v.recordId");
        component.set("v.radioSelectedPreEmp",cSelected);
        component.set("v.radioSelectedNewFSE",'nonNewFSE');
        
    },
    
    handleClickNewFSE : function(component,event,helper)
    {
        var newORpre = component.get("v.radioSelectedNewFSE");
        var newSelfFSE = component.get("v.selfNew");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RequestForNewFSETrunkStockCmp",
            componentAttributes: {
                getProducts:component.get("v.getProducts"),
                newFSESelf: component.get("v.selfNew"),
                serResRecId:component.get("v.recordId"),
                selfNew : newSelfFSE,
                getServiceRes : component.get("v.getServiceRes")
            }
        });
        evt.fire();
    },
    
    handleClickPreEmp : function(component,event,helper)
    {
        console.log('Service Resurce Id@@@ ',component.get("v.recordId"));
        var newSelfFSE = component.get("v.selfNew");
        var newORpre = component.get("v.radioSelectedPreEmp");
        var newPreSelf = component.get("v.nextPre");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RequestForPreEmptiveTrunkStockCmp",
            componentAttributes: {
                serResRecId:component.get("v.recordId"),
                newPreSelf:newSelfFSE,
                getServiceRes : component.get("v.getServiceRes")
            }
        });
        evt.fire();  
        console.log('Address info service resource ',component.get("v.getServiceRes"))
    },
    handleCancel : function(component,event,helper)
    {
        var recId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recId
        });
        urlEvent.fire();
    }
   
})