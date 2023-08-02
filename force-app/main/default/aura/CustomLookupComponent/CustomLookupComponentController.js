({
	keyPressController : function(component, event, helper) {
        var strSearch = component.get("v.strSearch");
        
        if(strSearch.length >= 2){
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, helper);
        }
        else {  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
	},
    
	selectRecord : function(component, event, helper) {
        var recordId = event.currentTarget.dataset.record;
        var listOfSearchRecords = component.get("v.listOfSearchRecords");
        var record = {};
        
        listOfSearchRecords.forEach(function(value) {
            if(recordId == value.strId) {
                record = value;
            }
        });
        
        component.set("v.selectedRecord" , record);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show'); 
	},
    
    clear : function(component, event, helper) {
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.strSearch", null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} ); 
	}
})