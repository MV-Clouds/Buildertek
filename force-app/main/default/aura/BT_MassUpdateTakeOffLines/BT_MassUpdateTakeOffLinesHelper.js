({
    // getTakeOffName: function (component, event, helper) {
    //     var action = component.get("c.getName");
    //     action.setParams({
    //         recordId: component.get('v.recordId')
    //     });
    //     action.setCallback(this, function (response) {
    //         component.set('v.takeoff', response.getReturnValue());
    //         console.log('takeoff Name:::', response.getReturnValue());
    //     })
    //     $A.enqueueAction(action);
    // },

    // getTakeOffParentId: function (component, event, helper) {
    //     var action = component.get("c.getParentId");
    //     action.setParams({
    //         recordId: component.get('v.recordId')
    //     });
    //     action.setCallback(this, function (response) {
    //         component.set('v.parentId', response.getReturnValue());
    //         console.log('parentId Id:::', response.getReturnValue());
    //     })
    //     $A.enqueueAction(action);
    // },

    // getTotalRecord: function (component, event, helper) {
    //     if(component.get('v.recordId') != undefined){
    //         var action = component.get("c.getCount");
    //         action.setParams({
    //             recordId: component.get('v.recordId'),
    //         });
    //         action.setCallback(this, function (response) {
    //             if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
    //                 // debugger;
    //                 component.set("v.TotalRecords", response.getReturnValue());
    //                 console.log('Total record', response.getReturnValue());
    //             }
    //         })
    //         $A.enqueueAction(action);
    //     }
       
    // },

    takeoffRelatedInfo: function (component, event, helper) {
        // console.log('in takeoffRelatedInfo');
        if(component.get('v.recordId') != undefined){
            var action = component.get("c.getTakeoffInfo");
            action.setParams({
                recordId: component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                if (result.status == 'SUCCESS') {
                    // debugger;
                    component.set("v.TotalRecords", result.count);
                    component.set('v.parentId', result.parentId);
                    component.set('v.takeoff', result.name);
                }
            })
            $A.enqueueAction(action);
        }
    },

    helpergetProductPhase_BuildPhase: function(component, event, helper){
        var action = component.get("c.get_ProductPhase_BuildPhase");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('helpergetProductPhase_BuildPhase : ', result);
            if(result !=  null){
                component.set("v.ProductPhase_Vs_BuildPhase", result);
            }
        })
        $A.enqueueAction(action);
    },

    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            console.log('@@fieldSetValues-- ', JSON.parse(JSON.stringify(fieldSetValues)));

            // var pageNumber = component.get("v.PageNumber");
            // var pageSize = component.get("v.pageSize");
            // var SearchProductType = component.find("SearchProductType").get("v.value");
            // var searchLocation = component.find("searchLocation").get("v.value");
            // var searchCategory = component.find("searchCategory").get("v.value");
            // var searchTradeType = component.find("searchTradeType").get("v.value");
            // helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType);

        })
        $A.enqueueAction(action);
    },

    getTableRows: function (component, event, helper, pageNumber, pageSize, productType, searchLocation, searchCategory, searchTradeType) {
        component.set('v.isLoading', true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        // console.log('@@fieldSetValues-- ', JSON.parse(JSON.stringify(fieldSetValues)));
        // var setfieldNames = new Set();

        // for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
        //     if (!setfieldNames.has(fieldSetValues[c].name)) {
        //         setfieldNames.add(fieldSetValues[c].name);
        //         if (fieldSetValues[c].type == 'REFERENCE') {
        //             if (fieldSetValues[c].name.indexOf('__c') == -1) {
        //                 setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');
        //             } else {
        //                 setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');
        //             }
        //         }
        //     }
        // }

        var arrfieldNames = [];
        // setfieldNames.forEach(v => arrfieldNames.push(v));
        // console.log('@@arrfieldNames-- ', arrfieldNames);
        // component.set('v.arrfieldNames', arrfieldNames);
        action.setParams({
            recordId: component.get('v.recordId'),
            fieldNameJson: JSON.stringify(arrfieldNames),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {
                    console.log('@@list-- ', list);
                    component.set("v.listOfRecords", list);
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                  
                    // debugger;
                    if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                } else {
                    component.set("v.listOfRecords", []);
                    component.set("v.cloneListOfRecords", []);
                    component.set('v.numberOfItems', 0);
                    component.set("v.PageNumber", 1);
                    component.set("v.RecordStart", 0);
                    component.set("v.RecordEnd", 0);
                    component.set("v.TotalPages", 0);
                    component.set("v.isNextVisible", true);

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'This TakeOff doesn\'t have any takeoff line!',
                        "type": 'Error',
                        "duration" : 5000
                    });
                    toastEvent.fire();
                }
                window.setTimeout(
                    $A.getCallback(function () {
                      component.set('v.isLoading', false);
                    }),
                    3000
                );
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
            }
        })
        $A.enqueueAction(action);
    },

    updateMassRecords: function (component, event, helper, productType, searchLocation, searchCategory, searchTradeType) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        var fieldSetValues = component.get('v.fieldSetValues');
        var action = component.get("c.updateRecords");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        /*for (var i in listOfRecords) {
            var record = listOfRecords[i];
            if (record != undefined) {
                for (var j in fieldSetValues) {
                    if (record.buildertek__Project_Takeoff__c === undefined || record.buildertek__Project_Takeoff__c === '') {
                        record.buildertek__Project_Takeoff__c = component.get('v.recordId');
                    } else if (record[fieldSetValues[j].name] === '' || record[fieldSetValues[j].name] === undefined) {
                        record[fieldSetValues[j].name] = null;
                        record[fieldSetValues[j].name] = fieldSetValues[j].name.includes('__r') ? null : record[fieldSetValues[j].name];
                    }
                }
            } else {
                listOfRecords.splice(i, 1);
                i--;
            }
        }*/
        component.set('v.listOfRecords', []); 
        // debugger;
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(listOfRecords),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var theBomId = component.get('v.bomId');
            // console.log('theBomId-- ',theBomId);
            // console.log('state-- ',state);
            if (state === "SUCCESS" && response.getReturnValue() == 'Success' && (theBomId == null || theBomId == undefined)) {
                component.set('v.isCancelModalOpen', false);
                // var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
                $A.get("e.force:refreshView").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": 'Record Save Successfully.',
                    "type": 'Success'
                });
                toastEvent.fire(); 
                // window.open(redirectUrl, '_self');
            }else if (state === "SUCCESS" && response.getReturnValue() == 'Success' && theBomId != null && theBomId != undefined && theBomId != '') {
                component.set('v.isCancelModalOpen', false);
                component.find("goToPrevious").navigate({
                    type: "standard__component",
                    attributes: {
                        componentName: "buildertek__DuplicateSSTLFromProducts",
                        attributes: {
                            "recordId": theBomId
                        } 
                    },
                    // state: { 
                    //     "c__recordId": component.get("v.recordId")
                    // }
                });
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": 'Record Save Successfully.',
                    "type": 'Success'
                });
                toastEvent.fire(); 
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Something went wrong!',
                    "type": 'error'
                });
                toastEvent.fire();
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, event, helper, deleteRecordId, productType, searchLocation, searchCategory, searchTradeType) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.deleteProject");
        action.setParams({
            deleteRecordId: deleteRecordId,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
          //  alert(JSON.parse(response.getReturnValue()));
      
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                if(list){
                     component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                }
                $A.get('e.force:refreshView').fire();
               
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    setProduct: function(component, event, helper, setProduct, index){
        try {
            // var index = event.getParam("index");
            // var listOfRecords = JSON.parse(JSON.stringify(component.get("v.listOfRecords")));
            var listOfRecords = component.get("v.listOfRecords");
            if(setProduct){
                // console.log("product : ", JSON.parse(JSON.stringify(event.getParam("recordByEvent"))));
                var product = event.getParam("recordByEvent");
                if(product){
                    var ProductPhase_Vs_BuildPhase = component.get("v.ProductPhase_Vs_BuildPhase");
                    // console.log('selected phase : ', product.buildertek__Quote_Group__c);
                    // console.log('current phase : ', ProductPhase_Vs_BuildPhase[product.buildertek__Quote_Group__c]);
                    listOfRecords[index].buildertek__Product__r = product;
                    listOfRecords[index].buildertek__Product__c = product.Id;
                    listOfRecords[index].buildertek__Description__c = product.Name;
                    listOfRecords[index].buildertek__Vendor__c = product.buildertek__Vendor__c;
                    listOfRecords[index].buildertek__Cost_Code__c = product.buildertek__Cost_Code__c;
                    listOfRecords[index].buildertek__Build_Phase__c = ProductPhase_Vs_BuildPhase[product.buildertek__Quote_Group__c] ? ProductPhase_Vs_BuildPhase[product.buildertek__Quote_Group__c] : null;
                    listOfRecords[index].buildertek__Quantity__c = 1;
                    listOfRecords[index].buildertek__Categories__c = product.buildertek__Category__c;

                }
              }
              else {
                listOfRecords[index].buildertek__Product__r = null;
                listOfRecords[index].buildertek__Product__c = null;
                listOfRecords[index].buildertek__Description__c = null;
                listOfRecords[index].buildertek__Vendor__c = null;
                listOfRecords[index].buildertek__Cost_Code__c = null;
                listOfRecords[index].buildertek__Build_Phase__c = null;
                listOfRecords[index].buildertek__Quantity__c = 0;
                listOfRecords[index].buildertek__Categories__c = null;
              }


            //   v.currectModifiedIndex & v.rerender used to Rerender FieldSetMass Update child Component (BUIL-3824)... 
            // these attribue used to rerendr only perticualar index's field...
            component.set("v.currectModifiedIndex", index);
            component.set("v.rerender", true);
            component.set("v.listOfRecords", listOfRecords);
            component.set("v.rerender", false);
            // console.log('listOfRecords After Update >> ', JSON.parse(JSON.stringify(listOfRecords)));
          
          window.setTimeout(
              $A.getCallback(function () {
                  component.set("v.isLoading", false);
            }),500
        );
        } catch (error) {
            console.log('error in setProduct : ', error.stack);
        }
      },
})