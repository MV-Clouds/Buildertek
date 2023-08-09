({
    doInit : function(component,event,helper){
        var action = component.get("c.getProductFamilyPicklist");
        action.setCallback(this,function(response){
            var state = response.getState(); 
            if(state==='SUCCESS'){
                component.set("v.productFamily",JSON.parse(response.getReturnValue())); 
            }
        });
        $A.enqueueAction(action);
    },
    createProducts : function(component, event, helper){
        var selectedItemNum = component.get("v.selectedItemNum");
        if(selectedItemNum > 0){
            helper.fireCreateProductsEvent(component);
        }
    },
    checkAllCheckBoxes : function(component, event, helper){        
        var selectedProductMap = component.get("v.selectedProductMap");
        if(!selectedProductMap){
            selectedProductMap = {};
        }

		var currentRecords = component.get("v.productCandidatesInCurrentPage");
        var target = event.getSource();
        var checked = target.get("v.value");
        
        if(target.get("v.name") === "selectAll"){
            helper.checkAllCheckBoxes(selectedProductMap, currentRecords, checked);
            component.set("v.productCandidatesInCurrentPage", currentRecords);
        }else{
	        var recordId = target.get("v.name");	            
            helper.checkOneUnit(selectedProductMap, recordId, checked);
            component.set("v.checkedAll", 
                         helper.checkIfNeedToCheckAllCheckBoxes(selectedProductMap,currentRecords));
        }
        component.set("v.selectedProductMap", selectedProductMap);
    },
    autoUpdateCheckBox : function(component, event, helper){
        var selectedProductMap = component.get("v.selectedProductMap");
        if(!selectedProductMap){
            selectedProductMap = {};
        }
		var currentRecords = component.get("v.productCandidatesInCurrentPage");
        component.set("v.checkedAll", 
                      helper.checkIfNeedToCheckAllCheckBoxes(selectedProductMap,currentRecords));
    },
    updateSelectedItems : function(component, event, helper){
        var selectedProductMap = component.get("v.selectedProductMap");
        var index = 0;
        for(var key in selectedProductMap){
            if(selectedProductMap[key]){
                index ++;
            }
        }
        component.set("v.selectedItemNum", index);
       
    },
    clearSelectedItems : function(component, event, helper){	
        component.set("v.selectedProductMap", {});
        component.set("v.checkedAll",false);
        
    },
    toggleFilterBar : function(component, event, helper){
        var showFilter = component.get("v.showFilterBar");
        showFilter = !showFilter;
        component.set("v.showFilterBar", showFilter);
    },
    updateFilterListStyle : function(component){
        var showFilter = component.get("v.showFilterBar");
        if(showFilter){
            $A.util.addClass(component.find("filterList"),"slds-is-selected");
        }else{
            $A.util.removeClass(component.find("filterList"),"slds-is-selected");            
        }
    },
    parentComponentEvent : function(component, event) { 
        //Get the event message attribute
        var message = event.getParam("OrderByProduct");
        //Set the handler attributes based on event data 
        component.set("v.orderString", message); 
        var orderedBy = component.get("v.orderString");
        var cmpEvent = component.getEvent("ProductSelectionEvent"); 
        //Set event attribute value
        cmpEvent.setParams({"OrderByProduct" : orderedBy}); 
        cmpEvent.fire();
    } 
})