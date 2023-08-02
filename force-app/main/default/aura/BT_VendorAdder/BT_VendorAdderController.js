({

    initialize : function(component, event, helper){
        $A.get('e.force:refreshView').fire();

        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire(); 
         
        var VendorList,actionRfqToVendorList;
        component.set("v.Spinner", true);
        $A.get('e.force:refreshView').fire();
        
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text' }, //initialWidth: 1000
            {
                label : 'Trade Type',
                //buildertek__Trade_Type__c
                fieldName : 'Tradetype',
                type : 'text'
                //sortable : true
            },
            {label: 'Insurance', fieldName: 'buildertek__Insurance__c', type: 'text'}
            //  {label: 'Cost Code', fieldName: 'buildertek__Cost_Code__c', type: 'text'}
        ]);
        
        var vendorValue = component.get("v.searchVendorNameFilter");
        var ratingValue = component.get("v.searchRatingFilter");
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");
        
        actionRfqToVendorList = component.get("c.getAllVendors");
        actionRfqToVendorList.setParams({
            rfqId:component.get("v.parentId"),
            "vendorName" : vendorValue.trim(),
            "ratingValue" : ratingValue.trim(),
            "tradeType": tradeTypeValue.trim(),
        });
        actionRfqToVendorList.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var rfqToVendorList = response.getReturnValue();
                /*component.set("v.vendorList",rfqToVendorList);
                component.set("v.vendorOptionList",rfqToVendorList);*/
            	var rows = rfqToVendorList;
                 var filteredRows = []
                for (var i = 0; i < rows.length; i++) {
                    if(rows[i].Contacts){
                        var row = rows[i];
                        if (row.buildertek__Trade_Type_Lookup__c){
                            row.Tradetype = row.buildertek__Trade_Type_Lookup__r.Name; 
                            //  row.Insurance=row.buildertek__Insurance__c;
                        }
                        filteredRows.push(rows[i])
                    }
                   
                }
               
                
                component.set("v.vendorList",filteredRows);
                component.set("v.vendorOptionList",filteredRows);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();  
                component.set("v.Spinner", false);
                 //$A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(actionRfqToVendorList);
        
        
	
	},
	
	getSelectedRows : function(component, event, helper){
	    var selectedRows = event.getParam('selectedRows');
	    if(selectedRows.length > 0){
	        component.set("v.IsDisable", false);    
	    }else{
	        component.set("v.IsDisable", true);   
	    }
	},
	
	
	toggleFilterBar : function(component, event, helper){
        var showFilterBar = component.get("v.showFilterBar");
        if(showFilterBar){
	        $A.util.removeClass(component.find("productFilterBar"),"slds-hide")
        }else{
            $A.util.addClass(component.find("productFilterBar"),"slds-hide")
        }
    },
    applyFilter : function(component, event, helper){
    	console.log(component.get("v._filter"));
        helper.search(component);
    },
    
    toggleFilterBar: function(component, event, helper){
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
        
        var showFilterBar = component.get("v.showFilterBar");
        if(showFilterBar){
	        $A.util.removeClass(component.find("productFilterBar"),"slds-hide")
        }else{
            $A.util.addClass(component.find("productFilterBar"),"slds-hide")
        }
    },
    
    onCancel : function(component,event, helper){
       component.get("v.onCancel")();
    },
    
    addVendors:function(component,event, helper){
        component.set("v.IsDisable",true);
        component.set("v.Spinner",true)
    	var selectedvendors = component.find("vendorlist").getSelectedRows();
       // component.set("v.Spinner", true);
        component.set("v.showMessage", true);
    	if(selectedvendors.length > 0){
    		component.get("v.savecallback")(selectedvendors);
            component.set("v.Spinner", false);
        component.set("v.showMessage", false);
    	}
    	else {
            component.set("v.Spinner", false);
        component.set("v.showMessage", false);
            component.set("v.IsDisable",false); 
    		component.find('notifLib').showNotice({
	            "variant": "error",
	            "header": "Error!",
	            "message": "Please Select Vendors.",
	            closeCallback: function() {
	            }
	        });
    	}
    	
    },
    handleVendorChange : function(component,event, helper){
        console.log(event.getSource().get("v.value"));
        var selectedVendor = event.getSource().get("v.value");
        component.set("v.selectedVendor",selectedVendor);
        component.set("v.Spinner", true);
        var action = component.get("c.getSelectedVendor");
        var actionRfqToVendorList = component.get("c.getAllVendors");
        if(selectedVendor == 'All'){
            actionRfqToVendorList.setParams({
                rfqId:component.get("v.parentId")
            });
            actionRfqToVendorList.setCallback(this, function (response) {
                if (component.isValid() && response.getState() === "SUCCESS") {
                    var rfqToVendorList = response.getReturnValue();
                    component.set("v.vendorList",rfqToVendorList);	
                    component.set("v.Spinner", false);  		
                }
            });
            
            $A.enqueueAction(actionRfqToVendorList);
        }else{
            action.setParams({
                "selectedvendorId" : selectedVendor
            });
            action.setCallback(this, function (response) {
                if(response.getState() == "SUCCESS"){
                    component.set("v.vendorList",response.getReturnValue());
                    component.set("v.Spinner", false);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
    doSearch: function (component, event, helper) {
        var ratingValue = component.get("v.searchRatingFilter");
        //var value = component.get("v.searchRfqFilter");//event.getSource().get("v.value");
       // alert('ratingValue.trim()'+ratingValue.trim());
        if(ratingValue.trim() <= 5){
            helper.search(component, event, helper);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'Please select rating less than or equal to 5.',
                duration:'5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    }
})