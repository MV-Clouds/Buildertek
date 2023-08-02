({
  init: function (component, event, helper) {
    var columns = [],
      row = {};
    columns.push("Value");
    component.set("v.columns", columns);

    var selectionChoices = component.get("v.selectionChoices");
    if (
      !$A.util.isUndefinedOrNull(selectionChoices) &&
      selectionChoices.length == 0
    ) {
      row["buildertek__Choice_Text__c"] = "";
      row["buildertek__Question__c"] = component.get("v.questionId");
      selectionChoices.push(row);
      component.set("v.selectionChoices", selectionChoices);
    } else if ($A.util.isUndefinedOrNull(selectionChoices)) {
      component.set("v.selectionChoices", []);
    }
    var inputOption = [
      "Date~Date Picker",
      "Text~Text Area",
      "Text~Simple Text",
    ];
    var selectedResponsetypeValue = component.get(
      "v.selectedResponsetypeValue"
    );
    if (
      selectedResponsetypeValue != undefined &&
      inputOption.includes(selectedResponsetypeValue)
    ) {
      $A.util.addClass(component.find("NewSelectionChoices"), "slds-hide");
    } else {
      $A.util.removeClass(component.find("NewSelectionChoices"), "slds-hide");
    }
  },

  /*input type change*/

  onChangeTypeHandler: function (component, event, helper) {
    var inputOption = [
      "Date~Date Picker",
      "Text~Text Area",
      "Text~Simple Text",
    ];
    var selectedResponsetypeValue = component.get(
      "v.selectedResponsetypeValue"
    );
    if (
      selectedResponsetypeValue != undefined &&
      inputOption.includes(selectedResponsetypeValue)
    ) {
      $A.util.addClass(component.find("NewSelectionChoices"), "slds-hide");
    } else {
      $A.util.removeClass(component.find("NewSelectionChoices"), "slds-hide");
    }
  },

  /*This function is used for header column validation and Add new in the data table*/
  addNewRow: function (component, event, helper) {
    var selectionChoices = component.get("v.selectionChoices");
    var row = {};
    debugger;
    // validation on "Header" column
    //var isValid = helper.dataTableValidation(component, event, helper);

    // If there is not any validation in data table then add new row in the data table
    //if (isValid) {
    row["buildertek__Choice_Text__c"] = "";
    row["buildertek__Question__c"] = component.get("v.questionId");
    selectionChoices.push(row);
    component.set("v.selectionChoices", selectionChoices);
    debugger;
    //}
  },

  /* This function is used for delete row from the data table*/
  deleteRow: function (component, event, helper) {
    var rowNumber = event.getSource().get("v.name");
    var selectionChoices = component.get("v.selectionChoices");
    selectionChoices.splice(rowNumber, 1);
    component.set("v.selectionChoices", selectionChoices);
  },

  /* This function is used for change the check box value like as (true == Yes and False == No)*/
  changeInputValue: function (component, event, helper) {
    var source = event.getSource();
    if (source.get("v.checked")) {
      source.set("v.value", "Yes");
    } else {
      source.set("v.value", "No");
    }
  },

  /* this method is used for validation data table columns*/
  dataTableValidation: function (component, event, helper) {
    var columnHeaders = component.find("columnHeaders");
    if ($A.util.isUndefinedOrNull(columnHeaders)) {
      return false;
    } else {
      return helper.dataTableValidation(component, event, helper);
    }
  },

  addDependentResponseType: function (component, event, helper) {
    var rowNumber = event.getSource().get("v.name");

    var responseTypeList = [];
    if (component.get("v.selectionChoices") != undefined) {
      responseTypeList = component.get("v.selectionChoices");
    }
    debugger;
    //if (responseTypeList[rowNumber].children == undefined) {
    responseTypeList[rowNumber].children = [];
    //}
    var responseDependentTypeList = {};
    responseTypeList[rowNumber].children.push(responseDependentTypeList);
    component.set("v.selectionChoices", responseTypeList);
  },

  uploadphoto: function (component, event, helper) {
    var selectionChoices = component.get("v.selectionChoices");
    var index = event.getSource().get("v.name");
    $A.createComponents(
      [
        [
          "aura:html",
          {
            tag: "h2",
            body: "Upload Photo",
            HTMLAttributes: {
              class: "slds-text-heading_medium slds-hyphenate",
            },
          },
        ],
        [
          "c:BT_UploadFiles",
          {
            mainObjectFieldAPI: "buildertek__Selection_Type__c",
            mainObjectId: component.get("v.questionGroupId"),
            onCancel: function () {
              component.get("v.modalPromise").then(function (modal) {
                modal.close();
              });
            },
            onSuccess: function (file) {
              component.get("v.modalPromise").then(function (modal) {
                modal.close();
              });

              var selectedFiles = [],
                selectedFile = {};
              selectedFile.Id = file.Id;
              selectedFile.Name = file.Name;
              selectedFiles.push(selectedFile);

              if (selectionChoices[index].buildertek__Photo_Ids__c) {
                selectionChoices[index].buildertek__Photo_Ids__c =
                  selectionChoices[index].buildertek__Photo_Ids__c +
                  "," +
                  file.Id;
              } else {
                selectionChoices[index].buildertek__Photo_Ids__c = file.Id;
              }
              component.set("v.selectionChoices", selectionChoices);
            },
          },
        ],
      ],
      function (components, status) {
        if (status === "SUCCESS") {
          var modalPromise = component.find("overlay").showCustomModal({
            header: components[0],
            body: components[1],
            footer: components[1].find("footer"),
            showCloseButton: true,
            cssClass: "",
            closeCallback: function () {},
          });
          component.set("v.modalPromise", modalPromise);
        }
      }
    );
  },
});