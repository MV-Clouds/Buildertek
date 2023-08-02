({
    openFilters: function( component, event, helper ) {
        component.set("v.openFilter",true);
    },
    closeModel: function( component, event, helper ) {
        component.set("v.openFilter",false);
    },
    downloadFT: function( component, event, helper ) {
        var wrapData = component.get("v.wrapDataMaster");
        var finalListToDownload = wrapData.oppAccLvlRecd;
        helper.downloadExcell(component, event, finalListToDownload, 1);
    },
    downloadST: function( component, event, helper ) {
        var wrapData = component.get("v.wrapDataMaster");
        var finalListToDownload = wrapData.cntctRleLvlRecd;
        helper.downloadExcell(component, event, finalListToDownload, 2);
    },
    
    downloadPT: function( component, event, helper ) {
        var wrapData = component.get("v.wrapDataMaster");
        var finalListToDownload = wrapData.partRleLvlRecd;
        helper.downloadExcell(component, event, finalListToDownload, 3);
    },
    resetFilters: function(component, event, helper) {
        helper.resetData(component, event, helper);
    },
    applyFilters: function(component, event, helper) {
        helper.applyFilters(component, event, helper);
    },
    handleChange: function( component, event, helper ) {
       
        var changeValue = event.getSource().get("v.text")

        
        
        
        
     //   var changeValue = event.getParam("value");
        
        component.set("v.disableLookup",false);
       component.set("v.accountType","");
        component.set("v.oppStage","");
        component.set("v.constructionType","");
        component.set("v.partneraccountrole","");
        component.set("v.wrapDataMaster.cntctRleLvlRecd","");
        component.set("v.wrapDataMaster.partRleLvlRecd","");
        component.set("v.wrapDataMaster.oppAccLvlRecd","");
       // alert(changeValue);
        // alert(changeValue);
        if(changeValue === 'oppAccLevel'){
            component.set("v.showCon",false);
            component.set("v.showpart",false);
            component.set("v.showOpp",true);
            component.set("v.Searchrecordtype","Account");
        }
        if(changeValue === 'conLevel'){
            component.set("v.showOpp",false);
            component.set("v.showpart",false);
            component.set("v.showCon",true);
            component.set("v.Searchrecordtype","Contact");
        }
        if(changeValue === 'partLevel'){
            component.set("v.showOpp",false);
            component.set("v.showCon",false);
            component.set("v.showpart",true);
            component.set("v.Searchrecordtype","Account");
        }
        var childComp = component.find('custlookup');
        childComp.callChild();
       
    },
    fetchAccountInfo: function(component, event, helper) {
        helper.fetchAccountInfo(component, event, helper);
    },
    sortByAcccount: function(component, event, helper) {
        helper.sortBy(component,helper, "AccountName");
        var a=component.get("v.sortAsc");
        
        component.set("v.Account",a);
    },
    sortBypartacc: function(component, event, helper) {
        helper.sortBy(component,helper, "PartnerAccountName");
        var a=component.get("v.sortAsc");
        //alert('76');
        component.set("v.Partneraccount",a);
    },
    sortByOppName: function(component, event, helper) {
        helper.sortBy(component,helper, "OpportunityName");
        var a=component.get("v.sortAsc");
        
        component.set("v.OpportunityName",a);
    },
    sortByoppacc: function(component, event, helper) {
        helper.sortBy(component,helper, "AccountName");
        var a=component.get("v.sortAsc");
        
        component.set("v.OpportunityName",a);
    },
    sortBystage: function(component, event, helper) {
        helper.sortBy(component,helper, "Stage");
        var a=component.get("v.sortAsc");
        
        component.set("v.stagename",a);
    },
    sortByamount: function(component, event, helper) {
        helper.sortBy(component,helper, "TotalBuildingSQFT");
        var a=component.get("v.sortAsc");
        
        component.set("v.Amountusd",a);
    },
sortByConstruction: function(component, event, helper) {
        helper.sortBy(component,helper, "ConstructionType");
        var a=component.get("v.sortAsc");
        
        component.set("v.Construction",a);
    },
 sortByState: function(component, event, helper) {
        helper.sortBy(component,helper, "State");
        var a=component.get("v.sortAsc");
        
        component.set("v.State",a);
    },  
    
    cleardata: function(component, event, helper)
    {
       component.set("v.wrapDataMaster.cntctRleLvlRecd","");
        component.set("v.wrapDataMaster.partRleLvlRecd","");
        component.set("v.wrapDataMaster.oppAccLvlRecd","");
    },
    
    getdata: function(component, event, helper)
    {
        alert();
    }
    
})