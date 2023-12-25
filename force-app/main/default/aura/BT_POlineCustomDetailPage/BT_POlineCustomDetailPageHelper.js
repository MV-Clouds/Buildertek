({
    doinitHelper : function(component, event, InitalLoading){

        try {
            
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
                // console.log('status :: ', state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('result :: ', result);
                        if(result.buildertek__Product__r){
                            console.log('InitialProductName > ', result.buildertek__Product__r.Name); 
                            component.set("v.selectedPRODId", result.buildertek__Product__r.Id);
                            component.set("v.selectedPRODName", result.buildertek__Product__r.Name);
                        }
                        else{
                            component.set("v.selectedPRODId", '');
                            component.set("v.selectedPRODName", '');
                        }
                        if(InitalLoading){
                            var stopSpinner = setTimeout($A.getCallback(function() {
                                component.set("v.isLoading", false);
                            }), 3000);
                            var searchTimeout = setTimeout($A.getCallback(function() {
                                component.set("v.POline", result);
                            }), 1000);
                            console.log("InitalLoading");
                        }
                        else{
                            component.set("v.POline", result);
                            component.set("v.isLoading", false);
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
        } catch (error) {
            console.log("error in Inti >> ", error.message);
            
        }
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
    
            // console.log('component.get("v.selectedPBId") >> ',component.get("v.selectedPBId"));
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
                    // console.log('ProductFamilyList >> ', ProductFamilyList);
                    component.set("v.ProductFamilyList", ProductFamilyList);
                    component.set("v.ProductFamilyListSearched", ProductFamilyList);
                    
                    // console.log('ProductList >> ', ProductList);
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

    RestoreProductRelatedDetail: function(component, event){
        component.set('v.selectedPRODName','');
            component.set('v.selectedPRODId','');
            var updatedPOline = component.get("v.POline");
            updatedPOline.Name = component.get("v.selectedPRODName");
            if(updatedPOline.buildertek__Product__c){
                updatedPOline.buildertek__Product__r.Name = component.get('v.selectedPRODName');
                updatedPOline.buildertek__Product__r.Id = component.get("v.selectedPRODId");
            }
            updatedPOline.buildertek__Unit_Price__c = null;
            updatedPOline.buildertek__Cost_Code__c = null ;
            updatedPOline.buildertek__Quantity__c = '' ;
            component.set("v.POline", updatedPOline);
    },
})
