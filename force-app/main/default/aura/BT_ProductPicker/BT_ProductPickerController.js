({
	init : function(component, event, helper) {
		helper.getPriceBooks(component, event, helper);
	},
	
	addNewRow : function(component, event, helper){
		var line, pricebooks, products, productFamily, lines = component.get('v.lines');
        pricebooks = component.get("v.pricebooks");

        // assign default value 
        line = {};
        line.pricebooks = pricebooks;
        line.productFamilys = '[]';
        line.products = '[]';

        line.pricebook = '';
        line.productFamily = '';
        line.product = '';
        line.description = '';
        line.unitprice = 0;
        line.quantity = 1;
        
        lines.push(line);
        component.set('v.lines', lines);
	},
	
	deleteRow : function(component, event, helper){
		var lines, rowNumber = event.getSource().get('v.name');
        lines = component.get('v.lines');
        lines.splice(rowNumber, 1);
        component.set('v.lines', lines);
	},
	
	
	updateTotal : function(component, event, helper){
		var totalUnitPrice = 0.00, lines = component.get("v.lines");
		for (var i in lines) {
			if(lines[i].unitprice) {
				totalUnitPrice = totalUnitPrice + parseFloat(lines[i].unitprice);
			}
		}
		
		component.set("v.totalUnitPrice",totalUnitPrice);
	},
	
	
	
	
	getProducts : function(component, event, helper) {
		var rowData, lines = component.get("v.lines"),
            rowNumber = event.getSource().get("v.name");
        	rowData = lines[rowNumber];
        	
        	//helper.getProductCandidate(component, event, helper, rowData.pricebook);
        	
        	helper.getProductCandidate(component, event, helper, rowData.pricebook, function(productFamilys, productsByFamily, products,productDetals){
        		rowData.products = products;
        		rowData.productFamilys = productFamilys;
        		rowData.productsByFamily = productsByFamily;
        		rowData.productDetals = productDetals;
	        	lines[rowNumber] = rowData;
	        	component.set("v.lines",lines);
        	});
	},
	
	getFamilyProducts: function(component, event, helper) {
		var rowData, lines = component.get("v.lines"),
            rowNumber = event.getSource().get("v.name");
        	rowData = lines[rowNumber];
        	
        	var products = rowData.productsByFamily[rowData.productfamily];
        	
        	console.log(products);
        	
        	// create combobox list for product
    		var field, productFields = [];
	        for (var i in products) {
	            field = {};
	            field.label = products[i].Name;
	            field.value = products[i].Id;
	            productFields.push(field);
	        }
	        
	        // sort the object fields in ASC ordered
	        productFields.sort(function(a, b) {
	            var labelA = a.label.toLowerCase(),
	                labelB = b.label.toLowerCase();
	            if (labelA < labelB) //sort string ascending
	                return -1
	            if (labelA > labelB)
	                return 1
	            return 0 //default return value (no sorting)
	        });
	        
	        rowData.products = productFields;
	        lines[rowNumber] = rowData;
        	component.set("v.lines",lines);
	},
	
	getProductDetails : function(component, event, helper) {
		var rowData, lines = component.get("v.lines"),
            rowNumber = event.getSource().get("v.name");
        	rowData = lines[rowNumber];
        	
        	
        	var productDetails = rowData.productDetals[rowData.product];
        	rowData.unitprice = productDetails.UnitPrice;
        	rowData.description = productDetails.Product2.Description;
        	
        	
        	lines[rowNumber] = rowData;
	        component.set("v.lines",lines);
	        
	        var totalUnitPrice = 0.00;
			for (var i in lines) {
				if(lines[i].unitprice) {
					totalUnitPrice = totalUnitPrice + parseFloat(lines[i].unitprice);
				}
			}
			
			component.set("v.totalUnitPrice",totalUnitPrice);
        	
	}
})