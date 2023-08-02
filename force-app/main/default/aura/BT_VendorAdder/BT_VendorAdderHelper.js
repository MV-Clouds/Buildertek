({
	search: function(component){
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire(); 
        component.set("v.Spinner", true);
        var vendorValue = component.get("v.searchVendorNameFilter");
        var ratingValue = component.get("v.searchRatingFilter");
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");
        
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text' }, //initialWidth: 1000 
            {
                label : 'Trade Type',
                //buildertek__Trade_Type__c
                fieldName : 'Tradetype',
                type : 'text'
                //sortable : true
            },
             {label: 'Insurance', fieldName: 'buildertek__Insurance__c', type: 'text'},
            //  {label: 'Cost Code', fieldName: 'buildertek__Cost_Code__c', type: 'text'}
        ]);
        
        var VendorList,actionRfqToVendorList;
        actionRfqToVendorList = component.get("c.getAllVendors");
        actionRfqToVendorList.setParams({
            "vendorName" : vendorValue.trim(),
            "ratingValue" : ratingValue.trim(),
            "tradeType": tradeTypeValue.trim(),
            //filterInfoStr: JSON.stringify(component.get("v._filter")),
            "rfqId":component.get("v.parentId")
        });
        actionRfqToVendorList.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var rfqToVendorList = response.getReturnValue();
                //component.set("v.vendorList",rfqToVendorList);
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
        	//component.set("v.vendorOptionList",rows);
        	component.set("v.Spinner", false);    		
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();    		
		   }
		});
		    
		$A.enqueueAction(actionRfqToVendorList);
		    
	}
})