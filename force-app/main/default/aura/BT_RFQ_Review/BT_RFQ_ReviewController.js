({
	
    doinit:function(component, event, helper){
    	  
    },
    
    initialize:function(component, event, helper){
    	
    	
    	
    	var navigateToStep, rfq, config, actionRfqConfig;

		    actionRfqConfig = component.get("c.getRfqConfig");
		    actionRfqConfig.setParams({
		        rfqId: component.get("v.recordId")
		    });
		    actionRfqConfig.setCallback(this, function (response) {
		    	if (component.isValid() && response.getState() === "SUCCESS") {
		    		console.log(response.getReturnValue());
		    		
		    		var rfqConfig = response.getReturnValue();
		    		rfq = rfqConfig.rfq;
		    		config = rfqConfig.config;
		    		
		    		
		    		
		    		var actions, filterConditions = 'AND buildertek__Vendor__r.buildertek__RFQ__c = \''+component.get("v.recordId")+'\'';
			        
			        if(rfq.buildertek__Status__c != 'Awarded' && rfq.buildertek__Status__c != 'Accepted'){
			        	actions = ['Edit'];
					}
			        
			        $A.createComponent("c:BT_GridComponent",
							            {
							            	"aura:id":"vendorReviewList",
							                "objectName": component.get("v.objectName"),
							                "fieldSetName": component.get("v.fieldSetName"),
							                "filterConditions" : filterConditions,
							                "TableId":"reviewVendorQuoteTableId"+component.get("v.recordId"),
							                "PagerId":"reviewVendorQuoteTableIdPager"+component.get("v.recordId"),
							                "Pagination": false,
							                "multiselect": false,
							                "ColumnChooser": false,
							                "CheckAll":false,
							                "Grouping":false,
							                "GroupingColumns":['buildertek__Vendor__c'],
							                "showGroupingsummery":true,
							                "ShowGroupingColumns":[false],
							                "groupText":['{0}'],
							                "singleSelectGrouping":true,
							                "GroupingCollapse": false,
							                "AllowExpandAllCollapseAll":true,
							                "Height":"auto",
							                "defaultSelectAll":false,
							                "Searching": false,
							                "isGridDefaultValuesToCheck":true,
							                "RecordsToShowPerPage":10000,
							                "rowList":[],
							                "Frozen":true,
							                "ViewRecordsInfo":false,
							                "actions": actions
							            },
							            function(grid){
							               if (component.isValid()) {
							                    var targetCmp = component.find('reviewList');
							                    var body = targetCmp.get("v.body");
							                    body.push(grid);
							                    targetCmp.set("v.body", body); 
							                    
							                    helper.updateInfoMessage(component, event, helper, rfq.buildertek__Status__c);
							                }
							            }
							        );
		    		
		    		component.set("v.rfq",rfq);
		    		
		    		
		    	}
		    });
		    
		    $A.enqueueAction(actionRfqConfig);
    	
    	
        
        
    },
    
    
    updateRFQVendorStatus: function(component, event, helper){
    	helper.updateStatus(component, event, helper, event.getParam("id"), event.getParam("status"));
    },
    
    refreshVendorList: function(component, event, helper){
	     helper.refreshGrid(component, event, helper);
    },
    
    recordUpdated : function(component, event, helper) {
      var params = event.getParam('arguments');
      if (params) {
            var param1 = params.param1;
            component.set("v.rfq", param1);
            //helper.updateInfoMessage(component, event, helper);
      }
    }
    
})