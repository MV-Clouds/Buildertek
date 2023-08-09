({
	retrieveRFQ: function(component){

        var quotId = component.get("v.quotId");

        var getAllApprovedRFQ = component.get("c.getAllApprovedRFQ");
        getAllApprovedRFQ.setParams({
            "quotId":quotId
        });

        //   alert(quotId)
        getAllApprovedRFQ.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                // component.set("v.rfqs", response.getReturnValue());
                //   alert('ok')
                console.log( response.getReturnValue())
                var result = response.getReturnValue();
                component.set('v.columns', [
                    {label: 'Name', fieldName: 'Name', type: 'text', sortable:false},
                    {label: 'RFQ Details', fieldName: 'buildertek__RFQ_Details__c', type: 'text'},
                    {label: 'Project', fieldName: 'projectName', type: 'text'},
                    {label: 'Vendor', fieldName: 'vendorName', type: 'text'},
                    {label: 'Contractor Ammount', fieldName: 'buildertek__Vendor_Quote__c', type: 'currency',
                     typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },cellAttributes: { alignment: 'left' }},
                    {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'}
                ]);
                for ( var i = 0; i < result.length; i++ ) {
                var row = result[i];
                if(component.get("v.multicurrency") == true){
                    row.CurrencyIso = row.CurrencyIsoCode;
                }else{
                   row.CurrencyIso = component.get("v.currencycode");
               }

            }
            result.forEach(element => {
                if (element.buildertek__Vendor__c != null) {
                    element.vendorName = element.buildertek__Vendor__r.Name;
                }
                if (element.buildertek__Project__c != null) {
                    element.projectName = element.buildertek__Project__r.Name;
                }
            });
            console.log('result ==>',{result});
            component.set("v.rfqs", result);
        //    component.set("v.rfqs", response.getReturnValue());
            }else{
                console.log("Failed with state: "+ state);
            }
        });

        $A.enqueueAction(getAllApprovedRFQ);
    },

    onSearch: function (component, event, helper) {
        helper.doSearchHelper(component, event, helper);
   },

    close: function(component){
        component.get("v.cancelCallback")();
    },
    Next: function(component,event){
        var selectedRFQS = component.get("v.selectedRFQS");
      //  alert(selectedRFQS)
        if(selectedRFQS != null && selectedRFQS.length > 0){

            component.set("v.isShowQuoteDetails", true);
            console.log(selectedRFQS);

            component.set('v.quoteColumns', [
                {label: 'Quote Line', fieldName: 'Name', type: 'text', sortable:false, editable:true},
                {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text', editable:true},
                {label: 'Grouping', fieldName: 'buildertek__Grouping__c', type: 'Lookup', editable:true},
                {label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'number', editable:true},
                {label: 'Unit Price', fieldName: 'buildertek__Unit_Price__c', type: 'currency', cellAttributes: { alignment: 'left' }, editable:true},
                {label: 'Markup', fieldName: 'buildertek__Markup__c', type: 'Percent', editable:true}
            ]);

            var quoteLines = [];
            var line, key, item;
            for( key in selectedRFQS) {
                if( !selectedRFQS.hasOwnProperty(key) ) continue;
                item = selectedRFQS[key];
                console.log(item);
                line = {  buildertek__RFQ__c: item.Id,
                        Name:item.Name,
                        buildertek__Item_Name__c:item.Name,
                        buildertek__Description__c:item.Name,
                        buildertek__Quantity__c:1,
                        buildertek__Unit_Price__c:item.buildertek__Vendor_Quote__c,
                        buildertek__Markup__c:0,
                        buildertek__Quote__c:component.get("v.quotId")
                       };
                quoteLines.push(line);
            }

            component.set("v.quotes", quoteLines);


        }
        else{
           //   alert('null')
                component.set("v.isShowQuoteDetails", false);
           var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please select at least one RFQ. ',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }

    },

	save: function(component){
		 var quotes = component.get("v.quotes");

		 var line, key, item, quoteLines = [];
		 for( key in quotes) {
		    if( !quotes.hasOwnProperty(key) ) continue;
		    item = quotes[key];

            console.log({item});
		    line = {  buildertek__RFQ__c: item.buildertek__RFQ__c,
	    			  Name:item.Name,
	    			  buildertek__Item_Name__c:item.buildertek__Item_Name__c,
	    			  buildertek__Description__c:item.buildertek__Description__c,
	    			  buildertek__Quantity__c:item.buildertek__Quantity__c,
	    			  buildertek__Unit_Cost__c:item.buildertek__Unit_Price__c,
	    			  buildertek__Markup__c:item.buildertek__Markup__c,
	    			  buildertek__Quote__c:component.get("v.quotId"),
	    			  buildertek__Grouping__c:item.buildertek__Grouping__c
	    			};
		    quoteLines.push(line);
		}

		component.get("v.saveCallback")(quoteLines);
	},

	getSelected: function(component,event){
		var selectedRows = event.getParam('selectedRows');
	    // Display that fieldName of the selected rows

	    var selectedRFQS = [];
	    for (var i = 0; i < selectedRows.length; i++){
	        selectedRFQS.push(selectedRows[i]);
	    }

	    component.set("v.selectedRFQS", selectedRFQS);
	}
})