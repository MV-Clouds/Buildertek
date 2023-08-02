({
	doInit : function(cmp, event, helper) {
		console.log('----doinit---');
		$A.createComponent("c:BT_GridComponent",
					            {
					            	"aura:id":"productpickerItemList",
					                "objectName": "Product2",
					                "fieldSetName": "buildertek__BT_Product_Picker_Fields",
					                "filterConditions" : "",
					                "TableId":"productpickerList"+cmp.get("v.recordId")+"table",
					                "PagerId":"productpickerListPager"+cmp.get("v.recordId")+"pager",
					                "Pagination": false,
					                "multiselect": true,
					                "ColumnChooser": false,
					                "CheckAll":true,
					                "Grouping":false,
					                "showGroupingsummery":false,
					                "Height":"225",
					                "defaultSelectAll":false,
					                "Searching": true,
					                "isGridDefaultValuesToCheck":true,
					                "RecordsToShowPerPage":10000,
					                "rowList":[],
					                "Frozen":true,
					                "ViewRecordsInfo":true,
					                "showSpinner":false,
					                "loadData":true
					            },
					            function(grid){
					               if (cmp.isValid()) {
					            	   console.log('----doinit productpicker created--1-');
					                    var targetCmp = cmp.find('productpicker');
					                    var body = targetCmp.get("v.body");
					                    body.push(grid);
					                    targetCmp.set("v.body", body); 
					                    console.log('----doinit productpicker created---');
					                }
					            }
					        );
		
	},
	
	close: function(cmp, event, helper) {
		cmp.get("v.cancelCallback")();
	},
	
	addSelectedProduct: function(cmp, event, helper) {
		var grdId = "productpickerList"+cmp.get("v.recordId")+"table";
		var grid = JQ$("#"+grdId);
		var i, selRowIds = grid.jqGrid("getGridParam", "selarrrow"), n, rowData;
		var newItems = [];
		if(selRowIds.length > 0){
			for (i = 0, n = selRowIds.length; i < n; i++) {
			    rowData = grid.jqGrid("getLocalRow", selRowIds[i]);
			    var newBi = new Object();
			    newBi.buildertek__Product__c = rowData.Id;
			    newBi.Name = rowData.Name;
			    newBi.buildertek__budget__c = cmp.get("v.recordId");
			    newBi.buildertek__Group__c = '';
			    newBi.errors = {
			                        "buildertek__quantity__c": "",
			                        "buildertek__unit_price__c" : "",
			                        "buildertek__product__c":"",
			                        "message" : ""
			                    }
			    newItems.push(newBi);
		   }
		   cmp.set("v.newBiItems",newItems);
	   } else {
			var result = {}, grid = cmp.find('productpickerItemList');
			grid.getSelectedRecords(result);
	    	if(!result || result.ids == -1) {
	            cmp.find('notifLib').showNotice({
		            "variant": "error",
		            "header": "Please select product(s)",
		            "message": "Please select product(s) to create budget item.",
		            closeCallback: function() {
		            }
		        });
	        }
        }
	}
})