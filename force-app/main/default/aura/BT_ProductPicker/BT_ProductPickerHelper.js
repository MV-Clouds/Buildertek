({
	getPriceBooks : function(component, event, helper) {
		var getPB = component.get("c.getPriceBook");
        getPB.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
            	if(response.getReturnValue()){
            		var pbs = response.getReturnValue();
            		var field, pbFields = [];
            		
			        for (var i in pbs) {
			            field = {};
			            if(!pbs[i].Name){pbs[i].Name = '';}
			            field.label = pbs[i].Name;
			            field.value = pbs[i].Id;
			            pbFields.push(field);
			        }
			        
			        // sort the object fields in ASC ordered
			        pbFields.sort(function(a, b) {
			            var labelA = a.label.toLowerCase(),
			                labelB = b.label.toLowerCase();
			            if (labelA < labelB) //sort string ascending
			                return -1
			            if (labelA > labelB)
			                return 1
			            return 0 //default return value (no sorting)
			        });
 
            		component.set("v.pricebooks",pbFields);
            	} 
            }
        });
        
        $A.enqueueAction(getPB);
	},
	
	
	getProductCandidate : function(component, event, helper, pricebookId, callBack) {
		var pricebook2Id = pricebookId;
    	if(!pricebook2Id) {
    		// do some thing here to get product without price book
        }
        var getProductCandidate = component.get("c.getProductCandidate");
        getProductCandidate.setParams({
            "pricebook2Id":pricebook2Id,
            "orderBy" : 'ASC'
        });
        
        getProductCandidate.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                
                var productCandidate = response.getReturnValue();
                console.log('productCandidate-->',productCandidate);
                
                var products=[],priceBookByProductId  = {}, productDetals = {}, family = [], productsByFamily = {};
                for(var i in productCandidate){
                	products.push(productCandidate[i].pBEntry.Product2);
                	
                	var productDetal = {};
                	productDetal.Id = productCandidate[i].pBEntry.Product2.Id;
                	productDetal.UnitPrice = productCandidate[i].pBEntry.UnitPrice;
                	productDetal.Product2 = productCandidate[i].pBEntry.Product2;
                	
                	if(productDetal.Product2.Family && family.indexOf(productDetal.Product2.Family) === -1){
                		family.push(productDetal.Product2.Family);
                		var familyProduct = [];
                		familyProduct.push(productCandidate[i].pBEntry.Product2);
                		productsByFamily[productDetal.Product2.Family] = familyProduct;
                	} else if(productDetal.Product2.Family){
                		var familyProduct = productsByFamily[productDetal.Product2.Family];
                		familyProduct.push(productCandidate[i].pBEntry.Product2);
                		productsByFamily[productDetal.Product2.Family] = familyProduct;
                	}
                	
                	productDetals[productCandidate[i].pBEntry.Product2.Id] = productDetal;
                }
                
                console.log('AAAAA');
                
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
		        
		        
		        // create combo box list for product family
		        var familyfield, familyfieldFields = [];
		        for (var i in family) {
		            familyfield = {};
		            familyfield.label = family[i];
		            familyfield.value = family[i];
		            familyfieldFields.push(familyfield);
		        }
		        // sort the object fields in ASC ordered
		        familyfieldFields.sort(function(a, b) {
		            var labelA = a.label.toLowerCase(),
		                labelB = b.label.toLowerCase();
		            if (labelA < labelB) //sort string ascending
		                return -1
		            if (labelA > labelB)
		                return 1
		            return 0 //default return value (no sorting)
		        });
                
                
		        console.log('productFields-->',productFields);
		        callBack(familyfieldFields, productsByFamily, productFields,productDetals);
                
                //return products;   
            }else{
                console.log("Failed with state: "+ state);
            }
        });
        
        $A.enqueueAction(getProductCandidate);
	}
})