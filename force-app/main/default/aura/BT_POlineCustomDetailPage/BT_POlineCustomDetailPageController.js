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
                    console.log(listofAllPB[i].Name.toUpperCase().indexOf(searchFilter) != -1);
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
                component.set('v.ProductFamilyListSearched', []);
            }
            else if(field == 'PF'){
                component.set('v.selectedPFName','');
            }
        } catch (error) {
            console.log('error in clearInput', error.stack);
        }
    },

    clickonPBHandler : function (component, event, helper){
        component.set('v.displayPB', false);
        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedPBId', recordId);

        var PriceBookListSearched = component.get("v.PriceBookListSearched");
        PriceBookListSearched.forEach(element => {
            // console.log('element => ',element);
            if (recordId == element.Id) {
                component.set('v.selectedPBName', element.Name);

            }
        });

        helper.getRelatedProductFamilyHelper(component, event);
    },

    clickonPFHandler : function (component, event, helper){
        component.set('v.displayPF', false);
        var record = event.currentTarget.dataset.value;
        console.log('record ==> '+record);
        component.set('v.selectedPFName', record);

    },

    // searchPFData : function(component, event, helper){
    //     console.log('data-field >> ', event.getSource().get("v.title"));
    // }

})
