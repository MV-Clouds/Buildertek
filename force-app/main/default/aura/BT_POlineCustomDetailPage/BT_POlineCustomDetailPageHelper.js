({
    doinitHelper : function(component, event){
        var Fields = [];
        var getFields = component.get("c.getFieldSet");
        getFields.setParams({
            objectName: 'buildertek__Purchase_Order_Item__c',
            fieldSetName: 'buildertek__Edit_Purchase_Order_Line'
        });
        getFields.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
               
                listOfFields.map(ele => {
                    Fields.push(ele.name);
                })
                console.log({listOfFields});
                component.set("v.listOfFields", listOfFields);
                component.set("v.TotalFields", listOfFields.length);
                console.log('TotalFields : ', component.get("v.TotalFields"));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getFields);
        console.log('Fields  :: ', Fields);
        console.log('Fields 2 :: ', JSON.stringify(Fields));

        var getRecordData = component.get("c.getRecordData");
        getRecordData.setParams({
            recordId : component.get("v.recordId"),
            FieldsToQuery : JSON.stringify(Fields)
        });
        getRecordData.setCallback(this, function (response) {
            var state = response.getState();
            console.log('status :: ', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result :: ', result);
                console.log("0.1");
                try {
                    console.log("0.5", component.get("v.recordId"));
                    // component.set("v.POlineid", component.get("v.recordId"));
                    console.log("1");
                    if(result.buildertek__Product__r){
                        console.log("2");
                        console.log('InitialProductName > ', result.buildertek__Product__r.Name); 
                        console.log("3");
                        component.set("v.selectedPRODId", result.buildertek__Product__r.Id);
                        console.log("4");
                        component.set("v.selectedPRODName", result.buildertek__Product__r.Name);
                    }
                    console.log("5");
                    var searchTimeout = setTimeout($A.getCallback(function() {
                        component.set("v.POlineInit", result);
                        console.log("6");
                        // console.log('polist >> ', component.get("v.POlineInit"));
                        component.set("v.POline", result);
                    }), 1000);
                } catch (error) {
                    console.log('error >> ', error.stack);
                    
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
                    "type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getRecordData);
    },

    getPriceBooksHelper: function(component, event){
        var getPricebooks = component.get("c.getPricebooks");
        // getPricebooks.setParams({

        // });
        getPricebooks.setCallback(this, function (response){
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS"){
                console.log('ProductFamilyList :: ', result);
                component.set("v.PriceBookList", result);
                component.set("v.PriceBookListSearched", result);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getPricebooks);

    },

    getProductRelatedtoPBHelper : function(component, event){
        component.set("v.isLoading", true);

        console.log('component.get("v.selectedPBId") >> ',component.get("v.selectedPBId"));
        var getProductRelatedtoPB = component.get("c.getProductRelatedtoPB");
        getProductRelatedtoPB.setParams({
            PricebookId : component.get("v.selectedPBId")
        });
        getProductRelatedtoPB.setCallback(this, function (response){
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS"){
                console.log('getProductRelatedtoPB :: ', result);
                var ProductFamilyList = [];
                var ProductFamilySet = new Set();
                var ProductList = [];
                result.forEach(ele => {
                    if(ele.Family){
                        ProductFamilySet.add(ele.Family);
                    }
                    ProductList.push(ele);
                });

                ProductFamilyList = Array.from(ProductFamilySet);  // converted Set Into Array for iteration in aura
                console.log('ProductFamilyList >> ', ProductFamilyList);
                component.set("v.ProductFamilyList", ProductFamilyList);
                component.set("v.ProductFamilyListSearched", ProductFamilyList);
                
                console.log('ProductList >> ', ProductList);
                component.set("v.ProductList", ProductList);
                component.set("v.ProductListSearched", ProductList);
                
                component.set("v.isLoading", false);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getProductRelatedtoPB);

    },

    getProductRelatedToPFhandler : function(component, event){

        component.set("v.isLoading", true);
        var getProductRelatedToPF = component.get("c.getProductRelatedToPF");
        getProductRelatedToPF.setParams({
            PricebookId : component.get("v.selectedPBId"),
            Product_Family : component.get("v.selectedPFName")
        });
        getProductRelatedToPF.setCallback(this, function (response){
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS"){
                console.log('getProductRelatedToPF :: ', result);

                component.set("v.ProductList", result);
                component.set("v.ProductListSearched", result);

                component.set("v.isLoading", false);

            }
            else{
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
                component.set("v.isLoading", false);
            }
        })

        $A.enqueueAction(getProductRelatedToPF);

    },
})
