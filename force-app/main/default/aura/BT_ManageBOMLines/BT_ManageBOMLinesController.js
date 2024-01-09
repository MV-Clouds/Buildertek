({
    doInit: function (component, event, helper) {
        try {
          component.set("v.isLoading", true);
            var pageReference = component.get("v.pageReference");
            //var bomIdFromParentCmp = pageReference.attributes.attributes.recordId;
            var urlBomId = pageReference.state.buildertek__bomRecordId;
        
            if (urlBomId != null && urlBomId != undefined && urlBomId != "") {
              component.set("v.recordId", urlBomId);
            }
    
            console.log('Record ID : ', component.get("v.recordId"));
        
            // helper.checkFabricationTaxes(component, event, helper);
            component.set("v.massUpdateEnable", false);
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");

            helper.fetchTakeOffLinesData(component, event, helper);
            helper.setColumns(component);
            // helper.getFieldSetFields(component,event);
            // helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
        
            window.setTimeout(
              $A.getCallback(function () {
                helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
              }),
              1500
            );

            window.setTimeout(function () {
                var workspaceAPI = component.find("workspace");
                workspaceAPI
                  .getFocusedTabInfo()
                  .then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                      tabId: focusedTabId,
                      label: "BOM Lines",
                    });
                    workspaceAPI.setTabIcon({
                      tabId: focusedTabId,
                      icon: "custom:custom70",
                    });
                  })
                  .catch(function (error) {
                    // console.log("sub tab error::", error);
                    // alert(error);
                  });
              }, 100);
        
            var billOfMeterialId = component.get("v.recordId");
            // component.set("v.bomId", billOfMeterialId);
        
            //  helper.getPoList(component, event, helper);
            // component.set("v.isLoading", false);
        } catch (error) {
            console.log('error in DoInti : ', error.stack);
            component.set("v.isLoading", false);
        }
      },

      handleRecordLoaded: function(component, event, helper) {

        console.log(component.get("v.BTBOMtype.Name"));
        var BOMName = component.get("v.BTBOMtype")["Name"];
        component.set("v.BOMName", BOMName)
      },

      massUpdateLines: function(component, event, helper){

          var headerIndex = event.getSource().get("v.title");
          var massupdateIndex = component.get("v.massupdateIndex");
          // console.log('headerIndex :: ', headerIndex);
          var groupData = component.get("v.dataByGroup");

          if(!groupData[headerIndex].massUpdate){
            component.set("v.isLoading", true);

            console.log('enable mass update');
            groupData[headerIndex].massUpdate = true;
            component.set("v.dataByGroup", groupData);
            massupdateIndex.push(headerIndex);
            component.set("v.massupdateIndex", massupdateIndex);
            window.setTimeout(
              $A.getCallback(function () {
                component.set("v.isLoading", false);
              }),
              5000
            );
          }
          else{
            
            helper.MassUpdateHelper(component, event, helper, headerIndex, massupdateIndex);

          }
      },

      onMassUpdateCancel: function(component, event, helper){
        try {
          component.set("v.isLoading", true);
          var headerIndex = event.getSource().get("v.title");
          // console.log('headerIndex :: ', headerIndex);

          var groupData = component.get("v.dataByGroup");
          groupData[headerIndex].massUpdate = false;
          var Init_dataByGroup = component.get("v.Init_dataByGroup");
          groupData[headerIndex] = JSON.parse(JSON.stringify(Init_dataByGroup[headerIndex]));
          component.set("v.dataByGroup", groupData);
          // $A.get('e.force:refreshView').fire();
          // component.set("v.isLoading", false);

          var massupdateIndex = component.get("v.massupdateIndex");
          massupdateIndex = massupdateIndex.filter(ele => ele !== headerIndex)
          component.set("v.massupdateIndex", massupdateIndex);

          window.setTimeout(
              $A.getCallback(function () {
                component.set("v.isLoading", false);
              }),
              1500
            );

        } catch (error) {
          console.log('Error in onMassUpdateCancel : ', error.stack);
        }
      },

      redirect: function (component, event, helper) {
    
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: component.get("v.recordId"),
          slideDevName: "related",
        });
        navEvt.fire();
    
        var workspaceAPI = component.find("workspace");
        workspaceAPI
          .getFocusedTabInfo()
          .then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
              tabId: focusedTabId,
            });
          })
          .catch(function (error) {
            // console.log("Error", error);
          });
      },

      recordEditLoaded: function(component, event, helper){
        console.log('recordEditLoaded');
      },

      handleLookUpEvent: function(component, event, helper){
          component.set("v.isLoading", true);
          var selectedRecordId = event.getParam("selectedRecordId");
          var index = event.getParam('index');
          var headerIndex = event.getParam('phaseIndex');
          
          if(event.getParam("fieldName") == 'buildertek__BT_Price_Book__c'){
            component.set("v.isLoading", true);
            var groupData = component.get("v.dataByGroup");
            groupData[headerIndex].sObjectRecordsList[index].buildertek__BT_Price_Book__c = selectedRecordId[0];
            component.set("v.dataByGroup", groupData);

            var setProduct = false;   // Clear product...
    
            window.setTimeout(
              $A.getCallback(function () {
                helper.setProduct(component, event, helper, setProduct); 
              }),
              1000
            );
            // component.set("v.pricebookId", selectedRecordId);
          }
          else{
            component.set("v.isLoading", false);
          }

      },
      

    ProductSelectHandler: function(component, event, helper){
        component.set("v.isLoading", true);
        var setProduct = true;

        // to avoid lag after set product...
        window.setTimeout(
          $A.getCallback(function () {
            helper.setProduct(component, event, helper, setProduct);
          }),
          1000
        );

    },

    

    clearSelectedHandler :  function(component, event, helper){
        component.set("v.isLoading", true);
        var setProduct = false;   // Clear product...

        window.setTimeout(
          $A.getCallback(function () {
            helper.setProduct(component, event, helper, setProduct); 
          }),
          1000
        );
    },

    valueChnagedInFildsetMassUpdate : function(component, event, helper){
      try{
        helper.valueChnagedInFildsetMassUpdateHelper(component, event, helper);
      }
      catch(error){
          console.log('error in valueChnagedInFildsetMassUpdate : ', error.stack);
          
      }
    },

    onInputChange: function(component, event, helper){
      try {
        // var fieldName = event.getSource().get("v.name").split('-');
        var name = event.getSource().get("v.name");
        var parts = name.split('-');
        var index = parts[0];
        var headerIndex = parts[1];
        var fieldLabel = parts[2];

        var inputField = event.getSource();
        var selectedValue = event.getSource().get("v.value");
        console.log(' -- field : ', fieldLabel);


      if(fieldLabel == 'Name'){
          if(selectedValue == null || selectedValue.trim() == '' ){
              inputField.setCustomValidity(" Product Name Proposal is required to update records.");
          }
          else{
              inputField.setCustomValidity("");
          }
      }
      else if(fieldLabel == 'buildertek__Quantity__c' || fieldLabel == 'buildertek__BL_MARKUP__c' || fieldLabel == 'buildertek__BL_UNIT_COST__c'){
          helper.onInputChangeHelper(component, event, helper, selectedValue, fieldLabel,index, headerIndex )
      }
        
      } catch (error) {
        console.log('error in onInputChange : ', error.stack);
      }
    },

     
})