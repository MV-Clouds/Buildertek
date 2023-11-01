({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        console.log('record Id :: ', component.get("v.recordId"));
        helper.doinitHelper(component, event);
        helper.getPriceBooksHelper(component, event);

        // component.set("v.RecordID", component.get("v.recordId"))     
    },

    editRecord : function(component, event, helper) {
            component.set("v.isLoading", true);
            console.log('Edit Record');
            component.set("v.viewMode", false);
            component.set("v.isLoading", false);

            component.set('v.selectedPBName','');
            component.set('v.selectedPBId','');
            component.set('v.selectedPFName','');
            var POlineInit = component.get("v.POlineInit");
            component.set("v.POline", POlineInit);
            // console.log("Poline >> ", component.get("v.POline"));
    },

    leaveEditForm : function(component, event, helper){
        component.set("v.isLoading", true);
        $A.get('e.force:refreshView').fire();
        component.set("v.viewMode", true);
        component.set("v.isLoading", false);

    }, 

    projectChange : function(component, event, helper){
        try {
            console.log('project Change', component.get("v.SelectedProject"));
        } catch (error) {
            console.log('error in project change : ', error.stack);
        }
    },

    saveRecord : function(component, event, helper){
        component.set("v.isLoading", true);
        console.log('Save Record', component.get('v.POline'));
        event.preventDefault();
        var fields = event.getParam("fields");
        fields['buildertek__Product__c'] = component.get("v.selectedPRODId");
        console.log('fields', JSON.parse(JSON.stringify(fields)));
        console.log('recordId : ' + component.get("v.recordId"));
        var updatedData = JSON.stringify(fields);
        var action = component.get("c.updateRecord");
        action.setParams({            
            updatedData : updatedData,
            recordID : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            component.set("v.viewMode", true);
            var state = response.getState();
            console.log('state ==> '+state);
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
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
        $A.enqueueAction(action);
        
    }, 

    searchRecordData: function (component, event, helper){
        try {
            var field = event.getSource().get("v.title");
            console.log('field >> ', field);
            if(field == 'PB'){
                component.set("v.displayPB", true);
            }
            else if(field == 'PF'){
                component.set("v.displayPF", true);
            }
            else if(field == 'PROD'){
                component.set("v.displayPROD", true);
            }
            event.stopPropagation();
        } catch (error) {
            console.log('error in searchRecordData', error.stack);
        }

    },

    keyupSearchData: function(component, event, helper){
        try {
            var field = event.getSource().get("v.title");
            if(field == 'PB'){
                var listofAllPB=component.get('v.PriceBookList');
                var searchFilter = event.getSource().get("v.value").toUpperCase();
                var tempArray = [];
                var i;
                for (i = 0; i < listofAllPB.length; i++) {
                    console.log(listofAllPB[i].Name);
                    console.log(listofAllPB[i].toUpperCase().indexOf(searchFilter) != -1);
                    if ((listofAllPB[i].Name && listofAllPB[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                            tempArray.push(listofAllPB[i]);
                    }else{
                        component.set('v.selectedPBId' , ' ')
                    }
                }
        
                component.set("v.PriceBookListSearched", tempArray);
                console.log({searchFilter});
                if(searchFilter == undefined || searchFilter == ''){
                    component.set("v.PriceBookListSearched", listofAllPB);
                }

            }
            else if(field == 'PF'){
                var listofAllPF=component.get('v.ProductFamilyList');
                var searchFilter = event.getSource().get("v.value").toUpperCase();
                var tempArray = [];
                var i;
                for (i = 0; i < listofAllPF.length; i++) {
                    console.log(listofAllPF[i].Name);
                    console.log(listofAllPF[i].Name.toUpperCase().indexOf(searchFilter) != -1);
                    if ((listofAllPF[i].Name && listofAllPF[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                            tempArray.push(listoflistofAllPFAllPB[i]);
                    }else{
                        component.set('v.selectedPFName' , ' ')
                    }
                }
        
                component.set("v.ProductFamilyListSearched", tempArray);
                console.log({searchFilter});
                if(searchFilter == undefined || searchFilter == ''){
                    component.set("v.ProductFamilyListSearched", listofAllPF);
                }
            }

            else if(field == 'PROD'){
                var listofAllPROD = component.get('v.ProductList');
                var searchFilter = event.getSource().get("v.value").toUpperCase();
                var tempArray = [];
                var i;
                for (i = 0; i < listofAllPROD.length; i++) {
                    console.log(listofAllPROD[i].Name);
                    console.log(listofAllPROD[i].Name.toUpperCase().indexOf(searchFilter) != -1);
                    if ((listofAllPROD[i].Name && listofAllPROD[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                            tempArray.push(listofAllPROD[i]);
                    }else{
                        component.set('v.selectedPRODId' , ' ')
                    }
                }
        
                component.set("v.ProductListSearched", tempArray);
                console.log({searchFilter});
                if(searchFilter == undefined || searchFilter == ''){
                    component.set("v.ProductListSearched", listofAllPROD);
                }
            }
            
        } catch (error) {
            console.log('error in keyupSearchData', error.stack);
        }
    },

    hidePBList : function(component, event, helper) {
        component.set('v.displayPB', false);
    },

    hidePFList: function(component, event, helper){
        component.set('v.displayPF', false);
    },

    hidePRODList: function(component, event, helper){
        component.set('v.displayPROD', false);
    },

    preventHide: function(component, event, helper) {
        event.preventDefault();
    },

    clearInput: function(component, event, helper) {
        try {
            var field = event.getSource().get("v.title");
            console.log('field clear >> ', field);
            if(field == 'PB'){
                component.set('v.selectedPBName','');
                component.set('v.selectedPBId','');

                // component.set('v.ProductFamilyListSearched', []);
                // component.set('v.ProductListSearched', []);
                component.set('v.selectedPFName','');


                component.set('v.selectedPRODName','');
                component.set('v.selectedPRODId','');

            }
            else if(field == 'PF'){
                component.set("v.isLoading", true);
                component.set('v.selectedPFName','');

                component.set('v.selectedPRODName','');
                component.set('v.selectedPRODId','');

                helper.getProductRelatedtoPBHelper(component, event); // When you create Product Family get prodct related to Price book Only
            }
            else if(field == 'PROD'){
                console.log('prod');
                component.set('v.selectedPRODName','');
                component.set('v.selectedPRODId','');
            }
        } catch (error) {
            console.log('error in clearInput', error.stack);
        }
    },

    clickonPBHandler : function (component, event, helper){
        component.set('v.displayPB', false);

        var previousSelectedPB = component.get('v.selectedPBId');

        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedPBId', recordId);

        if(previousSelectedPB != recordId){
            component.set('v.selectedPFName','');

            component.set('v.selectedPRODName','');
            component.set('v.selectedPRODId','');
        }

        var PriceBookListSearched = component.get("v.PriceBookListSearched");
        PriceBookListSearched.forEach(element => {
            if (recordId == element.Id) {
                component.set('v.selectedPBName', element.Name);
            }
        });

        helper.getProductRelatedtoPBHelper(component, event);
    },

    clickonPFHandler : function (component, event, helper){
        component.set('v.displayPF', false);
        var PrevousSelectedPF = component.get("v.selectedPFName")

        var record = event.currentTarget.dataset.value;
        console.log('record ==> '+record);
        component.set('v.selectedPFName', record);
        
        if(PrevousSelectedPF != record){
            component.set('v.selectedPRODName','');
            component.set('v.selectedPRODId','');
        }
        helper.getProductRelatedToPFhandler(component, event);


    },

    clickonPRODHandler :  function (component, event, helper){
        try {
            component.set("v.isLoading", true);
            component.set('v.displayPROD', false);
            var previusPROD = component.get("v.selectedPRODId");
            var recordId = event.currentTarget.dataset.value;
            console.log('recordId ==> '+recordId);
            if(previusPROD != recordId){
                component.set('v.selectedPRODId', recordId);
                var updatedPOline = component.get("v.POline");
                console.log('previus PO >> ', updatedPOline);
                
                var ProductListSearched = component.get("v.ProductListSearched");
                ProductListSearched.forEach(element => {
                    if (recordId == element.Id) {
                        console.log('selected product >>', element)
                        component.set('v.selectedPRODName', element.Name);
                        updatedPOline.buildertek__Unit_Price__c = element.UnitCost ? element.UnitCost : 0 ;
                        updatedPOline.buildertek__Cost_Code__c = element.CostCode ? element.CostCode : null ;
                        updatedPOline.buildertek__Product__r.Name = component.get("v.selectedPRODName");
                        updatedPOline.buildertek__Product__r.Id = component.get("v.selectedPRODId");
                        updatedPOline.buildertek__Quantity__c = 1 ;
                    }
                });
                    component.set("v.POline", updatedPOline);
                    console.log('updatedPOline > ', component.get("v.POline")); 
                    
            }
    
            component.set("v.isLoading", false);
            
        } catch (error) {
            console.log('error in clickonPRODHandler > ', error.stack);
            
        }
    },

})
