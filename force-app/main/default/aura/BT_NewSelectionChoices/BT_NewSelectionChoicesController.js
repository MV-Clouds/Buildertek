/* Lightning Component Controller.
 * Copyright 2018-2019, thoriyas.
 * All rights reserved
 *
 * Created by - Sagar
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/* global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */

({
  init: function (component, event, helper) {
    var columns = [];
    var row = {};
    columns.push("Value");
    component.set("v.columns", columns);

    var selectionChoices = component.get("v.selectionChoices");
    console.log('selectionChoices::', selectionChoices);
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

    var items = [];
    items.push({
      label: "Single Select With Drop Down",
      value: "Single Select~Drop Down",
    });
    items.push({
      label: "Single Select With Radio",
      value: "Single Select~Radio",
    });
    items.push({
      label: "Single Select With Horizontal Radio",
      value: "Single Select~Radio-lineDirection",
    });
    items.push({
      label: "Multi Select With Checkbox",
      value: "Multi Select~Checkbox",
    });
    items.push({
      label: "Multi Select With Horizontal Checkbox",
      value: "Multi Select~Checkbox-lineDirection",
    });
    items.push({
      label: "Multi Select With Drop Down",
      value: "Multi Select~Multi Select List",
    });
    items.push({
      label: "Simple Text",
      value: "Text~Simple Text"
    });
    items.push({
      label: "Long Text",
      value: "Text~Text Area"
    });
    items.push({
      label: "Date",
      value: "Date~Date Picker"
    });

    component.set("v.responsetypeOptions", items);
  },

  onReuploadPhoto: function (component, event, helper) {
    var index = event.currentTarget.dataset.id;
    var questions = component.get("v.selectionChoices");
    questions[index].buildertek__Image_Id__c = "";
    component.set('v.selectionChoices', questions);
  },

  handleUploadFinished: function (component, event, helper) {
    var uploadedFiles = event.getParam("files");
    var rowNumber = event.getSource().get('v.name');
    var title = event.getSource().get('v.title');
    var selectionChoices = component.get('v.selectionChoices');
    helper.getContentVersionId(component, event, helper, selectionChoices, uploadedFiles[0].documentId, rowNumber);
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

    // validation on "Header" column
    //var isValid = helper.dataTableValidation(component, event, helper);

    // If there is not any validation in data table then add new row in the data table
    //if (isValid) {
    row.buildertek__Choice_Text__c = "";
    row.buildertek__Question__c = component.get("v.questionId");
    selectionChoices.push(row);
    component.set(
      "v.selectionChoices",
      JSON.parse(JSON.stringify(selectionChoices))
    );
  },

  /* This function is used for delete row from the data table*/
  onDeleteHandler: function (component, event, helper) {
    var rowNumber = event.getSource().get("v.name");
    console.log('Row Number ::', rowNumber);
    console.log('Selection Choices::', JSON.stringify(component.get('v.selectionChoices')));
    /*var selectionChoices = component.get("v.selectionChoices");
    selectionChoices.splice(rowNumber, 1);
    component.set("v.selectionChoices", selectionChoices);*/
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
    component.set("v.selectionChoices", JSON.parse(JSON.stringify(responseTypeList)));
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

  responsetype: function (component, event, helper) {
    debugger;
    var index = event.getSource().get("v.name");
    var selectedOptionValue = event.getParam("value");

    var questionscoring;

    if (
      !$A.util.isUndefinedOrNull(selectedOptionValue) &&
      component.find("buildertek__choice_template__c")[index] != undefined
    ) {
      $A.util.addClass(
        component.find("buildertek__choice_template__c")[index],
        "slds-hide"
      );
      $A.util.addClass(component.find("rich_table")[index], "slds-hide");

      var responseTypeAndLayout = selectedOptionValue.split("~");
      if (
        !$A.util.isUndefinedOrNull(responseTypeAndLayout[0]) &&
        (responseTypeAndLayout[0].toUpperCase() === "SINGLE SELECT" ||
          responseTypeAndLayout[0].toUpperCase() === "MULTI SELECT")
      ) {
        $A.util.addClass(
          component.find("buildertek__choice_template__c")[index],
          "slds-hide"
        );
      } else if (
        selectedOptionValue.trim().toUpperCase() === "TEXT~RICH TABLE"
      ) {
        $A.util.removeClass(maxRow, "slds-hide");
        $A.util.removeClass(visibleRow, "slds-hide");
        $A.util.removeClass(component.find("rich_table")[index], "slds-hide");
      }
    } else {
      $A.util.addClass(
        component.find("buildertek__choice_template__c"),
        "slds-hide"
      );
      $A.util.addClass(component.find("rich_table"), "slds-hide");

      var responseTypeAndLayout = selectedOptionValue.split("~");
      if (
        !$A.util.isUndefinedOrNull(responseTypeAndLayout[0]) &&
        (responseTypeAndLayout[0].toUpperCase() === "SINGLE SELECT" ||
          responseTypeAndLayout[0].toUpperCase() === "MULTI SELECT")
      ) {
        $A.util.addClass(
          component.find("buildertek__choice_template__c"),
          "slds-hide"
        );
      } else if (
        selectedOptionValue.trim().toUpperCase() === "TEXT~RICH TABLE"
      ) {
        $A.util.removeClass(maxRow, "slds-hide");
        $A.util.removeClass(visibleRow, "slds-hide");
        $A.util.removeClass(component.find("rich_table"), "slds-hide");
      }
    }
  },
});