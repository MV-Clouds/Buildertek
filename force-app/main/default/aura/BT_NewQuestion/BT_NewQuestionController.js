/* Lightning Component Controller.
 * Copyright 2018-2019,@ thoriyas.
 * All rights reserved
 *
 * Created by - Sagar
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */

({
  /*component init method, In this method get the fields from field set*/
  init: function (component, event, helper) {
    helper.getFieldSet(component);
    helper.listQuestionTypes(component);
    helper.fetchpricebooks(component, event, helper);
    helper.fetchPickListVal(component, event, helper);

    console.log(
      "questionDetail",
      JSON.stringify(component.get("v.questionDetail"))
    );
    var question = component.get("v.question");
    if (component.get("v.isNewQuestion")) {
      var questionGroup = component.get("v.questionGroup");
      if (!!questionGroup && !!questionGroup.Id) {
        //component.set("v.isNewControl",false);
        if (
          !$A.util.isUndefinedOrNull(questionGroup) &&
          !$A.util.isUndefinedOrNull(questionGroup.Id)
        ) {
          if (questionGroup.buildertek__Selection_Attributes__r != undefined) {
            var answerChoices =
              questionGroup.buildertek__Selection_Attributes__r;
            var inputOption = [
              "Date~Date Picker",
              "Text~Text Area",
              "Text~Simple Text",
            ];
            var responseTypeList = [];
            var myMap = new Map();
            for (var i = 0; i < answerChoices.length; i++) {
              var answerChoice = answerChoices[i];
              if (
                !inputOption.includes(answerChoice.buildertek__Choice_Value__c)
              ) {
                if (
                  !myMap.has(
                    answerChoice.Name +
                    "~" +
                    answerChoice.buildertek__Choice_Value__c
                  )
                ) {
                  myMap.set(
                    answerChoice.Name +
                    "~" +
                    answerChoice.buildertek__Choice_Value__c,
                    []
                  );
                }
                var responseAtt = {};
                responseAtt.buildertek__Choice_Text__c =
                  answerChoice.buildertek__Choice_Text__c;
                responseAtt.buildertek__Image_Id__c =
                  answerChoice.buildertek__Image_Id__c;
                responseAtt.buildertek__Document_Id__c =
                  answerChoice.buildertek__Document_Id__c;
                responseAtt.Id = answerChoice.Id;
                responseAtt.buildertek__Additional_Cost__c =
                  answerChoice.buildertek__Additional_Cost__c;
                responseAtt.buildertek__ParentId__c =
                  answerChoice.buildertek__ParentId__c != undefined ?
                  answerChoice.buildertek__ParentId__c :
                  "";
                myMap
                  .get(
                    answerChoice.Name +
                    "~" +
                    answerChoice.buildertek__Choice_Value__c
                  )
                  .push(responseAtt);
              }
            }
            var responseTypeList = [];
            var mapKey = [];
            for (var i = 0; i < answerChoices.length; i++) {
              var answerChoice = answerChoices[i];
              if (
                !inputOption.includes(answerChoice.buildertek__Choice_Value__c)
              ) {
                var key =
                  answerChoice.Name +
                  "~" +
                  answerChoice.buildertek__Choice_Value__c;
                if (!mapKey.includes(key)) {
                  mapKey.push(key);
                  if (myMap.has(key)) {
                    var responseType = {};
                    responseType.selectedResponsetypeValue =
                      answerChoice.buildertek__Choice_Value__c;
                    responseType.responseTypeName = answerChoice.Name;
                    responseType.selectionChoices = myMap.get(key);
                    responseTypeList.push(responseType);
                  }
                }
              } else {
                var responseType = {};
                responseType.selectedResponsetypeValue =
                  answerChoice.buildertek__Choice_Value__c;
                responseType.responseTypeName = answerChoice.Name;
                responseTypeList.push(responseType);
              }
            }
            component.set("v.responseTypeList", responseTypeList);
          }
        }
      }
    } else {
      if (
        !$A.util.isUndefinedOrNull(question) &&
        !$A.util.isUndefinedOrNull(question.Id)
      ) {
        if (question.buildertek__Answer_Choices__r != undefined) {
          var answerChoices = question.buildertek__Answer_Choices__r;
          var inputOption = [
            "Date~Date Picker",
            "Text~Text Area",
            "Text~Simple Text",
          ];
          var responseTypeList = [];
          var myMap = new Map();
          for (var i = 0; i < answerChoices.length; i++) {
            var answerChoice = answerChoices[i];
            if (
              !inputOption.includes(answerChoice.buildertek__Choice_Value__c)
            ) {
              if (
                !myMap.has(
                  answerChoice.Name +
                  "~" +
                  answerChoice.buildertek__Choice_Value__c
                )
              ) {
                myMap.set(
                  answerChoice.Name +
                  "~" +
                  answerChoice.buildertek__Choice_Value__c,
                  []
                );
              }
              var responseAtt = {};
              responseAtt.buildertek__Choice_Text__c =
                answerChoice.buildertek__Choice_Text__c;
              responseAtt.buildertek__Image_Id__c =
                answerChoice.buildertek__Image_Id__c;
              responseAtt.buildertek__Document_Id__c =
                answerChoice.buildertek__Document_Id__c;
              responseAtt.Id = answerChoice.Id;
              responseAtt.buildertek__Additional_Cost__c =
                answerChoice.buildertek__Additional_Cost__c;
              responseAtt.buildertek__ParentId__c =
                answerChoice.buildertek__ParentId__c != undefined ?
                answerChoice.buildertek__ParentId__c :
                "";
              myMap
                .get(
                  answerChoice.Name +
                  "~" +
                  answerChoice.buildertek__Choice_Value__c
                )
                .push(responseAtt);
            }
          }
          var responseTypeList = [];
          var mapKey = [];
          for (var i = 0; i < answerChoices.length; i++) {
            var answerChoice = answerChoices[i];
            if (
              !inputOption.includes(answerChoice.buildertek__Choice_Value__c)
            ) {
              var key =
                answerChoice.Name +
                "~" +
                answerChoice.buildertek__Choice_Value__c;
              if (!mapKey.includes(key)) {
                mapKey.push(key);
                if (myMap.has(key)) {
                  var responseType = {};
                  responseType.selectedResponsetypeValue =
                    answerChoice.buildertek__Choice_Value__c;
                  responseType.responseTypeName = answerChoice.Name;
                  responseType.selectionChoices = myMap.get(key);
                  responseTypeList.push(responseType);
                }
              }
            } else {
              var responseType = {};
              responseType.selectedResponsetypeValue =
                answerChoice.buildertek__Choice_Value__c;
              responseType.responseTypeName = answerChoice.Name;
              responseTypeList.push(responseType);
            }
          }
          component.set("v.responseTypeList", responseTypeList);
        }
      }
    }
    if (component.get("v.isNewQuestion")) {
      helper.getProductAttributes(component, event, helper);
    }
    var responseToRemove = [];

    for (var i in responseTypeList) {
      for (var j in responseTypeList[i].selectionChoices) {
        if (
          responseTypeList[i].selectionChoices[j].buildertek__ParentId__c !=
          "" ||
          responseTypeList[i].selectionChoices[j].buildertek__ParentId__c
          .length > 0
        ) {
          responseToRemove.push(i);
          debugger;
        }
        var parent = responseTypeList[i].selectionChoices;
        if (parent[j].buildertek__ParentId__c == "") {
          parent[j].children1 = [];
          var obj1 = {};
          obj1.selectionChoices = [];
          for (var m in responseTypeList) {
            var selection = responseTypeList[m].selectionChoices;
            for (var n in selection) {
              if (selection[n].buildertek__ParentId__c === parent[j].Id) {
                var obj = {};
                obj.Id = selection[n].Id;
                obj.buildertek__Additional_Cost__c =
                  selection[n].buildertek__Additional_Cost__c;
                obj.buildertek__Choice_Text__c =
                  selection[n].buildertek__Choice_Text__c;
                obj.buildertek__Image_Id__c =
                  selection[n].buildertek__Image_Id__c;
                obj.buildertek__Document_Id__c =
                  selection[n].buildertek__Document_Id__c;
                obj.buildertek__ParentId__c =
                  selection[n].buildertek__ParentId__c;

                obj1.responseTypeName = responseTypeList[m].responseTypeName;
                obj1.selectedResponsetypeValue =
                  responseTypeList[m].selectedResponsetypeValue;
                obj1.selectionChoices.push(obj);
                parent[j].children1.push(obj1);
              }
            }
          }
        }
      }
    }

    for (var i in responseTypeList) {
      for (var j in responseTypeList[i].selectionChoices) {
        for (var k in responseTypeList[i].selectionChoices[j].children1) {
          for (var l in responseTypeList[i].selectionChoices[j].children1[k]
              .selectionChoices) {
            responseTypeList[i].selectionChoices[j].children1[
              k
            ].selectionChoices[l].children1 = [];
            var obj1 = {};
            obj1.selectionChoices = [];
            for (var m in responseTypeList) {
              for (var n in responseTypeList[m].selectionChoices) {
                if (
                  responseTypeList[i].selectionChoices[j].children1[k]
                  .selectionChoices[l].Id ===
                  responseTypeList[m].selectionChoices[n]
                  .buildertek__ParentId__c
                ) {
                  var obj = {};
                  obj.Id = responseTypeList[m].selectionChoices[n].Id;
                  obj.buildertek__Additional_Cost__c =
                    responseTypeList[m].selectionChoices[
                      n
                    ].buildertek__Additional_Cost__c;
                  obj.buildertek__Choice_Text__c =
                    responseTypeList[m].selectionChoices[
                      n
                    ].buildertek__Choice_Text__c;

                  obj.buildertek__Image_Id__c =
                    responseTypeList[m].selectionChoices[
                      n
                    ].buildertek__Image_Id__c;
                  obj.buildertek__Document_Id__c =
                    responseTypeList[m].selectionChoices[
                      n
                    ].buildertek__Document_Id__c;
                  obj.buildertek__ParentId__c =
                    responseTypeList[m].selectionChoices[
                      n
                    ].buildertek__ParentId__c;

                  obj1.responseTypeName = responseTypeList[m].responseTypeName;
                  obj1.selectedResponsetypeValue =
                    responseTypeList[m].selectedResponsetypeValue;
                  obj1.selectionChoices.push(obj);
                  responseTypeList[i].selectionChoices[j].children1[
                    k
                  ].selectionChoices[l].children1.push(obj1);
                }
              }
            }
          }
        }
      }
    }

    for (var i in responseTypeList) {
      for (var j in responseTypeList[i].selectionChoices) {
        for (var k in responseTypeList[i].selectionChoices[j].children1) {
          for (var l in responseTypeList[i].selectionChoices[j].children1[k]
              .selectionChoices) {
            for (var m in responseTypeList[i].selectionChoices[j].children1[k]
                .selectionChoices[l].children1) {
              for (var n in responseTypeList[i].selectionChoices[j].children1[k]
                  .selectionChoices[l].children1[m].selectionChoices) {
                responseTypeList[i].selectionChoices[j].children1[
                  k
                ].selectionChoices[l].children1[m].selectionChoices[
                  n
                ].children1 = [];
                var obj1 = {};
                obj1.selectionChoices = [];
                for (var p in responseTypeList) {
                  for (var q in responseTypeList[p].selectionChoices) {
                    if (
                      responseTypeList[i].selectionChoices[j].children1[k]
                      .selectionChoices[l].children1[m].selectionChoices[n]
                      .Id ===
                      responseTypeList[p].selectionChoices[q]
                      .buildertek__ParentId__c
                    ) {
                      var obj = {};
                      obj.Id = responseTypeList[p].selectionChoices[q].Id;
                      obj.buildertek__Additional_Cost__c =
                        responseTypeList[p].selectionChoices[
                          q
                        ].buildertek__Additional_Cost__c;
                      obj.buildertek__Choice_Text__c =
                        responseTypeList[p].selectionChoices[
                          q
                        ].buildertek__Choice_Text__c;
                      obj.buildertek__Image_Id__c =
                        responseTypeList[p].selectionChoices[
                          q
                        ].buildertek__Image_Id__c;
                      obj.buildertek__Document_Id__c =
                        responseTypeList[p].selectionChoices[
                          q
                        ].buildertek__Document_Id__c;
                      obj.buildertek__ParentId__c =
                        responseTypeList[p].selectionChoices[
                          q
                        ].buildertek__ParentId__c;

                      obj1.responseTypeName =
                        responseTypeList[p].responseTypeName;
                      obj1.selectedResponsetypeValue =
                        responseTypeList[p].selectedResponsetypeValue;
                      obj1.selectionChoices.push(obj);
                      responseTypeList[i].selectionChoices[j].children1[
                        k
                      ].selectionChoices[l].children1[m].selectionChoices[
                        n
                      ].children1.push(obj1);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (var i in responseTypeList) {
      for (var j in responseTypeList[i].selectionChoices) {
        responseTypeList[i].selectionChoices[j].children = [];
        for (var k in responseTypeList[i].selectionChoices[j].children1) {
          if (k == 0) {
            //responseToKeep.push(i);
            responseTypeList[i].selectionChoices[j].children.push(
              responseTypeList[i].selectionChoices[j].children1[k]
            );
            for (var m in responseTypeList[i].selectionChoices[j].children1[k]
                .selectionChoices) {
              responseTypeList[i].selectionChoices[j].children1[
                k
              ].selectionChoices[m].children = [];
              for (var n in responseTypeList[i].selectionChoices[j].children1[k]
                  .selectionChoices[m].children1) {
                if (n == 0) {
                  //responseToKeep.push(i);
                  responseTypeList[i].selectionChoices[j].children1[
                    k
                  ].selectionChoices[m].children.push(
                    responseTypeList[i].selectionChoices[j].children1[k]
                    .selectionChoices[m].children1[n]
                  );
                  for (var p in responseTypeList[i].selectionChoices[j]
                      .children1[k].selectionChoices[m].children1[n]
                      .selectionChoices) {
                    responseTypeList[i].selectionChoices[j].children1[
                      k
                    ].selectionChoices[m].children1[n].selectionChoices[
                      p
                    ].children = [];
                    for (var q in responseTypeList[i].selectionChoices[j]
                        .children1[k].selectionChoices[m].children1[n]
                        .selectionChoices[p].children1) {
                      if (q == 0) {
                        //responseToKeep.push(i);
                        responseTypeList[i].selectionChoices[j].children1[
                          k
                        ].selectionChoices[m].children1[n].selectionChoices[
                          p
                        ].children.push(
                          responseTypeList[i].selectionChoices[j].children1[k]
                          .selectionChoices[m].children1[n].selectionChoices[
                            p
                          ].children1[q]
                        );
                      } else {
                        delete responseTypeList[i].selectionChoices[j]
                          .children1[k].selectionChoices[m].children1[n]
                          .selectionChoices[p].children1[q];
                      }
                    }
                  }
                } else {
                  delete responseTypeList[i].selectionChoices[j].children1[k]
                    .selectionChoices[m].children1[n];
                }
              }
            }
          } else {
            delete responseTypeList[i].selectionChoices[j].children1[k];
          }
        }
      }
    }

    var responseToRemove = [];
    for (var i in responseTypeList) {
      for (var j in responseTypeList[i].selectionChoices) {
        if (
          responseTypeList[i].selectionChoices[j].buildertek__ParentId__c
          .length > 0
        ) {
          delete responseTypeList[i];
          break;
        }
      }
    }

    var cloneResponseTypeList = [];
    for (var i in responseTypeList) {
      if (responseTypeList[i] != undefined) {
        cloneResponseTypeList.push(responseTypeList[i]);
      }
    }
    component.set("v.responseTypeList", cloneResponseTypeList);
    console.log("Response::", component.get("v.responseTypeList"));
  },

  deleteRow: function (component, event, helper) {},

  deleteAttributeType: function (component, event, helper) {
    if (event.getSource().get("v.name") != undefined) {
      var rowNumber = event.getSource().get("v.name");
      var selectionChoices = JSON.parse(
        JSON.stringify(component.get("v.responseTypeArray"))
      );
      var delteAttribute = component.get("v.deleteAttributeItem");
      var deleteAttributeType = [];
      if (delteAttribute != undefined) {
        deleteAttributeType = deleteAttributeType.concat(delteAttribute);
      }
      for (var i = 0; i < selectionChoices.length; i++) {
        if (i == rowNumber) {
          if (selectionChoices[i].Ids != undefined) {
            for (var j = 0; j < selectionChoices[i].Ids.length; j++) {
              deleteAttributeType.push(selectionChoices[i].Ids[j].Id);
            }
          }
        }
      }
      console.log("deleteAttributeType::", deleteAttributeType);
      component.set("v.deleteAttributeItem", deleteAttributeType);
    }
  },
  editAttributeItem: function (component, event, helper) {
    var rowId = event.getSource().get("v.name");
    var responseTypeArray = JSON.parse(
      JSON.stringify(component.get("v.responseTypeArray"))
    );

    for (var i = 0; i < responseTypeArray.length; i++) {
      if (responseTypeArray[i].Ids != undefined) {
        for (var j = 0; j < responseTypeArray[i].Ids.length; j++) {
          if (responseTypeArray[i].Ids[j].Id == rowId) {
            if (
              responseTypeArray[i].Ids[j].isDisabled == null ||
              !responseTypeArray[i].Ids[j].isDisabled
            ) {
              responseTypeArray[i].Ids[j].isDisabled = true;
            } else {
              responseTypeArray[i].Ids[j].isDisabled = null;
            }
          }
        }
      }
    }
    component.set("v.responseTypeArray", responseTypeArray);
  },
  deleteAttributeItem: function (component, event, helper) {
    var rowId = event.getSource().get("v.name");
    var responseTypeArray = JSON.parse(
      JSON.stringify(component.get("v.responseTypeArray"))
    );
    var deleteAttributeItem = [];
    var deleteIdList = JSON.parse(
      JSON.stringify(component.get("v.deleteAttributeItem"))
    );
    if (deleteIdList != undefined) {
      deleteAttributeItem = deleteAttributeItem.concat(deleteIdList);
    }
    deleteAttributeItem.push(rowId);
    component.set("v.deleteAttributeItem", deleteAttributeItem);

    for (var i = 0; i < responseTypeArray.length; i++) {
      if (responseTypeArray[i].Ids != undefined) {
        var temp = [];
        for (var j = 0; j < responseTypeArray[i].Ids.length; j++) {
          if (responseTypeArray[i].Ids[j].Id != rowId) {
            temp.push(responseTypeArray[i].Ids[j]);
          }
        }
        responseTypeArray[i].Ids = temp;
      }
    }
    component.set("v.responseTypeArray", responseTypeArray);
  },

  cancel: function (component, event, helper) {
    component.find("overlayLib").notifyClose();
  },

  onchangeProduct: function (component, event, helper) {
    helper.ongetQuestionInfo(component, event, helper);
  },

  /* Save Question record*/
  save: function (component, event, helper) {
    $A.get("e.c:BT_SpinnerEvent")
      .setParams({
        action: "SHOW",
      })
      .fire();
    component.set("v.isSaveAndNew", false);
    // validation before submit the record edit from
    var isValid = helper.validate(component, event);

    // if there is not any validation submit the record edit else show a error message.
    if (isValid) {
      //component.find('recordEditForm').submit();
      document.getElementById("saveQuestionbutton").click();
    } else {
      $A.get("e.buildertek:avSpinnerEvent")
        .setParams({
          action: "HIDE",
        })
        .fire();
      component.find("notifLib").showNotice({
        variant: "Error",
        header: "Error",
        message: "Require field missing",
      });
    }
  },

  /* Save Question record*/
  saveAndNew: function (component, event, helper) {
    $A.get("e.c:BT_SpinnerEvent")
      .setParams({
        action: "SHOW",
      })
      .fire();
    component.set("v.isSaveAndNew", true);
    // validation before submit the record edit from
    var isValid = helper.validate(component, event);

    // if there is not any validation submit the record edit else show a error message.
    if (isValid) {
      //component.find('recordEditForm').submit();
      document.getElementById("saveQuestionbutton").click();
    } else {
      $A.get("e.buildertek:avSpinnerEvent")
        .setParams({
          action: "HIDE",
        })
        .fire();
      component.find("notifLib").showNotice({
        variant: "Error",
        header: "Error",
        message: "Require field missing",
      });
    }
  },
  addNewResponseType: function (component, event, helper) {
    var responseTypeList = [];
    if (component.get("v.responseTypeList") != undefined) {
      responseTypeList = component.get("v.responseTypeList");
    }
    console.log("Response type List ::", responseTypeList);
    if (responseTypeList.length > 5) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        message: "Max 6 Attribute Allowed.",
        type: "Info",
      });

      toastEvent.fire();
      return;
    }
    var newResponseType = {};
    responseTypeList.push(newResponseType);
    console.log("Response Type List ::", JSON.stringify(responseTypeList));
    component.set("v.responseTypeList", responseTypeList);
  },

  onError: function (component, event, helper) {
    console.log("onError");
  },
  /* When Click on record edit submit button then this submit event fire.\
		Here save the Question object record and save control to check link object record.*/
  submitQuestionRecord: function (component, event, helper) {
    var namespace = component.get("v.namespace");
    var eventFields = event.getParam("fields");
    var richTableData = component.get("v.richTableData");
    var onSuccess = component.get("v.onSuccess");
    var selectionChoices = component.get("v.selectionChoices");
    var deleteAttribute = component.get("v.deleteAttribute");
    var deleteAttributeById = component.get("v.deleteAttributeItem");
    var question = component.get("v.question");
    var successmessage = "Selection Option Created";
    // additional fields
    var questionTypeLayout = component.get("v.selectedResponsetypeValue");
    var questionTypeAndLayout = questionTypeLayout.split("~");
    var questionObjectFields = [];

    questionObjectFields[
      "buildertek__Question_Type__c"
    ] = questionTypeAndLayout[0].trim();
    questionObjectFields[
      "buildertek__Display_Layout__c"
    ] = questionTypeAndLayout[1].trim();

    if (component.get("v.questionGroup")) {
      console.log("QuestionGroupId::", component.get("v.questionGroup").Id);
      questionObjectFields["buildertek__Question_Group__c"] = component.get(
        "v.questionGroup"
      ).Id;
      questionObjectFields["buildertek__Section__c"] = component.get(
        "v.questionGroup"
      ).buildertek__Section__c;
    }

    var imageId = component.get("v.imageId");
    var documentId = component.get("v.documentId");
    var selectedLookUpRecord = component.get("v.selectedLookUpRecord");
    if (imageId != undefined) {
      questionObjectFields["buildertek__Image_Id__c"] = imageId;
    }

    if (documentId != undefined) {
      questionObjectFields["buildertek__Document_Id__c"] = documentId;
    }
    if (
      selectedLookUpRecord != undefined &&
      !$A.util.isUndefinedOrNull(selectedLookUpRecord.Id)
    ) {
      questionObjectFields["buildertek__Product__c"] = selectedLookUpRecord.Id;
    }

    if (
      !$A.util.isUndefinedOrNull(question) &&
      !$A.util.isUndefinedOrNull(question.Id)
    ) {
      questionObjectFields["Id"] = question.Id;
      successmessage = "Selection Option Updated";
    }
    // Rich table data convert into JSON and set in the "rich table column herder" field
    if (
      questionTypeAndLayout[1].toLowerCase() === "rich table" &&
      !$A.util.isUndefinedOrNull(richTableData) &&
      !$A.util.isEmpty(richTableData)
    ) {
      questionObjectFields[
        "buildertek__Rich_Table_Column_Headers__c"
      ] = JSON.stringify(component.get("v.richTableData")).trim();
    }
    console.log("-----eventFields---");
    console.log(JSON.stringify(eventFields));
    Object.assign(eventFields, questionObjectFields);
    event.preventDefault();

    var responseTypeList = [];
    if (component.get("v.responseTypeList") != undefined) {
      responseTypeList = component.get("v.responseTypeList");
    }
    console.log("responseTypeList::", responseTypeList);
    var inputOption = [
      "Date~Date Picker",
      "Text~Text Area",
      "Text~Simple Text",
    ];
    var question = component.get("v.question");
    var choices = [];
    var childChoices1 = [];
    var childChoices2 = [];
    var childChoices3 = [];
    var number = 1;

    if (!component.get("v.isNewQuestion")) {
      for (var i = 0; i < responseTypeList.length; i++) {
        if (
          responseTypeList[i] != undefined &&
          responseTypeList[i].responseTypeName != undefined &&
          responseTypeList[i].selectedResponsetypeValue != undefined &&
          responseTypeList[i].selectionChoices != undefined &&
          question.Id != undefined &&
          !inputOption.includes(responseTypeList[i].selectedResponsetypeValue)
        ) {
          for (
            var j = 0; j < responseTypeList[i].selectionChoices.length; j++
          ) {
            var choice = {};

            if (responseTypeList[i].selectionChoices[j].Id != undefined) {
              choice.Id = responseTypeList[i].selectionChoices[j].Id;
            }
            choice.Name = responseTypeList[i].responseTypeName;
            debugger;
            choice.buildertek__Parent_Level__c = number++;
            choice.buildertek__Question__c = question.Id;
            choice.buildertek__Image_Id__c = responseTypeList[i].selectionChoices[
              j
            ].buildertek__Image_Id__c;
            choice.buildertek__Document_Id__c = responseTypeList[i].selectionChoices[
              j
            ].buildertek__Document_Id__c;
            choice.buildertek__Choice_Text__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Choice_Text__c;
            choice.buildertek__Image_Id__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Image_Id__c;
            choice.buildertek__Document_Id__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Document_Id__c;
            choice.buildertek__Additional_Cost__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Additional_Cost__c;
            choice.buildertek__Choice_Value__c =
              responseTypeList[i].selectedResponsetypeValue;
            choices.push(choice);
            for (var k in responseTypeList[i].selectionChoices[j].children) {
              var child = JSON.parse(
                JSON.stringify(responseTypeList[i].selectionChoices[j].children)
              );
              for (var l in child[k].selectionChoices) {
                var choice1 = {};
                if (child[k].selectionChoices[l].Id != undefined) {
                  choice1.Id = child[k].selectionChoices[l].Id;
                }
                choice1.Name = child[k].responseTypeName;
                choice1.buildertek__Parent_Level__c = number++;
                choice1.buildertek__Level__c =
                  choice.buildertek__Parent_Level__c;
                choice1.buildertek__Choice_Text__c =
                  child[k].selectionChoices[l].buildertek__Choice_Text__c;
                choice1.buildertek__Image_Id__c =
                  child[k].selectionChoices[l].buildertek__Image_Id__c;
                choice1.buildertek__Document_Id__c =
                  child[k].selectionChoices[l].buildertek__Document_Id__c;
                choice1.buildertek__Additional_Cost__c =
                  child[k].selectionChoices[l].buildertek__Additional_Cost__c;
                choice1.buildertek__Choice_Value__c =
                  child[k].selectedResponsetypeValue;
                choice1.buildertek__Image_Id__c = child[k].selectionChoices[l].buildertek__Image_Id__c;
                choice1.buildertek__Document_Id__c = child[k].selectionChoices[l].buildertek__Document_Id__c;
                childChoices1.push(choice1);
                for (var m in child[k].selectionChoices[l].children) {
                  var child2 = JSON.parse(
                    JSON.stringify(child[k].selectionChoices[l].children)
                  );

                  for (var n in child2[m].selectionChoices) {
                    var choice2 = {};
                    if (child2[m].selectionChoices[n].Id != undefined) {
                      choice2.Id = child2[m].selectionChoices[n].Id;
                    }
                    choice2.Name = child2[m].responseTypeName;
                    choice2.buildertek__Parent_Level__c = number++;
                    choice2.buildertek__Level__c =
                      choice1.buildertek__Parent_Level__c;
                    choice2.buildertek__Image_Id__c =
                      child2[m].selectionChoices[n].buildertek__Image_Id__c;
                    choice2.buildertek__Document_Id__c =
                      child2[m].selectionChoices[n].buildertek__Document_Id__c;
                    choice2.buildertek__Additional_Cost__c =
                      child2[m].selectionChoices[
                        n
                      ].buildertek__Additional_Cost__c;
                    choice2.buildertek__Image_Id__c = child2[m].selectionChoices[
                      n
                    ].buildertek__Image_Id__c;
                    choice2.buildertek__Document_Id__c = child2[m].selectionChoices[
                      n
                    ].buildertek__Document_Id__c;
                    choice2.buildertek__Choice_Value__c =
                      child2[m].selectedResponsetypeValue;
                    childChoices2.push(choice2);
                    for (var p in child2[m].selectionChoices[n].children) {
                      var child3 = JSON.parse(
                        JSON.stringify(child2[m].selectionChoices[n].children)
                      );

                      for (var q in child3[p].selectionChoices) {
                        var choice3 = {};
                        if (child3[k].selectionChoices[l].Id != undefined) {
                          choice3.Id = child3[k].selectionChoices[l].Id;
                        }
                        choice3.Name = child3[p].responseTypeName;
                        choice3.buildertek__Parent_Level__c = number++;
                        choice3.buildertek__Level__c =
                          choice2.buildertek__Parent_Level__c;
                        choice3.buildertek__Choice_Text__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Choice_Text__c;
                        choice3.buildertek__Image_Id__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Image_Id__c;
                        choice3.buildertek__Document_Id__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Document_Id__c;
                        choice3.buildertek__Additional_Cost__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Additional_Cost__c;
                        choice3.buildertek__Choice_Value__c =
                          child3[p].selectedResponsetypeValue;
                        choice3.buildertek__Image_Id__c = child3[m].selectionChoices[
                          n
                        ].buildertek__Image_Id__c;
                        choice3.buildertek__Document_Id__c = child3[m].selectionChoices[
                          n
                        ].buildertek__Document_Id__c;
                        childChoices3.push(choice3);
                      }
                    }
                  }
                }
              }
            }
          }
        } else if (
          responseTypeList[i] != undefined &&
          responseTypeList[i].selectedResponsetypeValue != undefined &&
          inputOption.includes(responseTypeList[i].selectedResponsetypeValue)
        ) {
          var choice = {};
          if (responseTypeList[i].Id != undefined) {
            choice.Id = responseTypeList[i].Id;
          }
          var responseTypeName = responseTypeList[i].responseTypeName;
          if (responseTypeName != undefined) {
            choice.Name = responseTypeName;
          } else {
            choice.Name = "Response Type";
          }
          choice.buildertek__Question__c = question.Id;
          choice.buildertek__Choice_Value__c =
            responseTypeList[i].selectedResponsetypeValue;
          choices.push(choice);
        }
      }
    } else {
      for (var i = 0; i < responseTypeList.length; i++) {
        if (
          responseTypeList[i] != undefined &&
          responseTypeList[i].selectionChoices != undefined &&
          responseTypeList[i].selectedResponsetypeValue != undefined &&
          !inputOption.includes(responseTypeList[i].selectedResponsetypeValue)
        ) {
          for (
            var j = 0; j < responseTypeList[i].selectionChoices.length; j++
          ) {
            var choice = {};
            if (responseTypeList[i].selectionChoices[j].Id != undefined) {
              //choice.Id = responseTypeList[i].selectionChoices[j].Id;
            }
            choice.Name = responseTypeList[i].responseTypeName;
            choice.buildertek__Parent_Level__c = number++;
            choice.buildertek__Choice_Text__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Choice_Text__c;
            choice.buildertek__Image_Id__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Image_Id__c;
            choice.buildertek__Document_Id__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Document_Id__c;
            choice.buildertek__Image_Id__c = responseTypeList[i].selectionChoices[
              j
            ].buildertek__Image_Id__c;
            choice.buildertek__Document_Id__c = responseTypeList[i].selectionChoices[
              j
            ].buildertek__Document_Id__c;
            choice.buildertek__Additional_Cost__c =
              responseTypeList[i].selectionChoices[
                j
              ].buildertek__Additional_Cost__c;
            choice.buildertek__Choice_Value__c =
              responseTypeList[i].selectedResponsetypeValue;
            choices.push(choice);
            debugger;
            for (var k in responseTypeList[i].selectionChoices[j].children) {
              var child = JSON.parse(
                JSON.stringify(responseTypeList[i].selectionChoices[j].children)
              );
              for (var l in child[k].selectionChoices) {
                var choice1 = {};
                if (responseTypeList[i].selectionChoices[j].Id != undefined) {
                  //choice.Id = responseTypeList[i].selectionChoices[j].Id;
                }
                choice1.Name = child[k].responseTypeName;
                choice1.buildertek__Parent_Level__c = number++;
                choice1.buildertek__Level__c =
                  choice.buildertek__Parent_Level__c;
                choice1.buildertek__Choice_Text__c =
                  child[k].selectionChoices[l].buildertek__Choice_Text__c;
                choice1.buildertek__Image_Id__c =
                  child[k].selectionChoices[l].buildertek__Image_Id__c;
                choice1.buildertek__Document_Id__c =
                  child[k].selectionChoices[l].buildertek__Document_Id__c;
                choice1.buildertek__Image_Id__c =
                  child[k].selectionChoices[l].buildertek__Image_Id__c;
                choice1.buildertek__Document_Id__c =
                  child[k].selectionChoices[l].buildertek__Document_Id__c;
                choice1.buildertek__Additional_Cost__c =
                  child[k].selectionChoices[l].buildertek__Additional_Cost__c;
                choice1.buildertek__Choice_Value__c =
                  child[k].selectionChoices[l].selectedResponsetypeValue;
                childChoices1.push(choice1);
                for (var m in child[k].selectionChoices[l].children) {
                  var child2 = JSON.parse(
                    JSON.stringify(child[k].selectionChoices[l].children)
                  );

                  for (var n in child2[m].selectionChoices) {
                    var choice2 = {};
                    if (child2[m].selectionChoices[n].Id != undefined) {
                      choice2.Id = child2[m].selectionChoices[n].Id;
                    }
                    choice2.Name = child2[m].responseTypeName;
                    choice2.buildertek__Parent_Level__c = number++;
                    choice2.buildertek__Level__c =
                      choice1.buildertek__Parent_Level__c;
                    choice2.buildertek__Choice_Text__c =
                      child2[m].selectionChoices[n].buildertek__Choice_Text__c;
                    choice2.buildertek__Image_Id__c =
                      child2[m].selectionChoices[n].buildertek__Image_Id__c;
                    choice2.buildertek__Document_Id__c =
                      child2[m].selectionChoices[n].buildertek__Document_Id__c;
                    choice2.buildertek__Image_Id__c =
                      child2[m].selectionChoices[
                        n
                      ].buildertek__Image_Id__c;
                    choice2.buildertek__Document_Id__c =
                      child2[m].selectionChoices[
                        n
                      ].buildertek__Document_Id__c;
                    choice2.buildertek__Additional_Cost__c =
                      child2[m].selectionChoices[
                        n
                      ].buildertek__Additional_Cost__c;
                    choice2.buildertek__Choice_Value__c =
                      child2[m].selectedResponsetypeValue;
                    childChoices2.push(choice2);
                    for (var p in child2[m].selectionChoices[n].children) {
                      var child3 = JSON.parse(
                        JSON.stringify(child2[m].selectionChoices[n].children)
                      );

                      for (var q in child3[p].selectionChoices) {
                        var choice3 = {};
                        if (child3[k].selectionChoices[l].Id != undefined) {
                          choice3.Id = child3[k].selectionChoices[l].Id;
                        }
                        choice3.Name = child3[p].responseTypeName;
                        choice3.buildertek__Parent_Level__c = number++;
                        choice3.buildertek__Level__c =
                          choice2.buildertek__Parent_Level__c;
                        choice3.buildertek__Choice_Text__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Choice_Text__c;
                        choice3.buildertek__Image_Id__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Image_Id__c;
                        choice3.buildertek__Document_Id__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Document_Id__c;

                        choice3.buildertek__Document_Id__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Document_Id__c;
                        choice3.buildertek__Additional_Cost__c =
                          child3[p].selectionChoices[
                            q
                          ].buildertek__Additional_Cost__c;
                        choice3.buildertek__Choice_Value__c =
                          child3[p].selectedResponsetypeValue;
                        childChoices3.push(choice3);
                      }
                    }
                  }
                }
              }
            }
          }
        } else if (
          responseTypeList[i] != undefined &&
          responseTypeList[i].selectedResponsetypeValue != undefined &&
          inputOption.includes(responseTypeList[i].selectedResponsetypeValue)
        ) {
          var choice = {};
          if (responseTypeList[i].Id != undefined) {
            //choice.Id=responseTypeList[i].Id;
          }
          var responseTypeName = responseTypeList[i].responseTypeName;
          if (responseTypeName != undefined) {
            choice.Name = responseTypeName;
          } else {
            choice.Name = "Response Type";
          }
          choice.buildertek__Choice_Value__c =
            responseTypeList[i].selectedResponsetypeValue;
          choice.push(choice);
        }
      }
    }

    if (eventFields["Name"] == undefined || eventFields["Name"] == "") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        message: "Please fill option name",
        type: "Info",
      });
      toastEvent.fire();
      $A.get("e.c:BT_SpinnerEvent")
        .setParams({
          action: "HIDE",
        })
        .fire();
      return;
    }
    eventFields["buildertek__Options_Name__c"] = eventFields["Name"];
    eventFields["buildertek__Additional_Cost__c"] =
      eventFields["buildertek__Additional_Cost__c"] != undefined ?
      eventFields["buildertek__Additional_Cost__c"].replace("$", "") :
      "";
    if (eventFields["Name"].length > 80) {
      eventFields["Name"] = eventFields["Name"].substring(0, 79);
    }

    console.log("eventFields::", JSON.stringify(eventFields));
    console.log("choices:0:", JSON.stringify(choices));
    console.log("childChoices:1:", JSON.stringify(childChoices1));
    console.log("childChoices:2:", JSON.stringify(childChoices2));
    console.log("Response List::", JSON.stringify(responseTypeList));
    var addNewQuestion = component.get("c.addQuestion1");
    addNewQuestion.setParams({
      questionRecord: JSON.stringify(eventFields),
      choices: JSON.stringify(choices),
      childChoicesLevelOne: JSON.stringify(
        JSON.parse(JSON.stringify(childChoices1))
      ),
      childChoicesLevelTwo: JSON.stringify(
        JSON.parse(JSON.stringify(childChoices2))
      ),
      childChoicesLevelThree: JSON.stringify(
        JSON.parse(JSON.stringify(childChoices3))
      ),
    });

    addNewQuestion.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          message: successmessage,
          type: "Success",
        });

        toastEvent.fire();

        if (!$A.util.isUndefinedOrNull(onSuccess)) {
          onSuccess();
        }

        $A.get("e.c:BT_SpinnerEvent")
          .setParams({
            action: "HIDE",
          })
          .fire();
        if (!component.get("v.isSaveAndNew")) {
          component.find("overlayLib").notifyClose();
        } else {
          var emptyList = [];
          var emptyStr = "";
          component.set("v.pricebookName", emptyStr);
          component.set("v.selectedLookUpRecord", {});
          component.set("v.responseTypeList", emptyList);
          component.set("v.productfamily", emptyStr);

          component.find("setupField").forEach(function (f) {
            f.reset();
          });
        }
      }
    });
    $A.enqueueAction(addNewQuestion);
  },

  onSuccessHandler: function (component, event, helper) {
    var onSuccess = component.get("v.onSuccess");
    var questionId = event.getParams().response;
    console.log("Question onSuccess::", JSON.stringify(questionId));
    if (!component.get("v.isNewQuestion")) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        message: "Selection Option Updated",
        type: "Success",
      });
      toastEvent.fire();
    }
    $A.get("e.c:BT_SpinnerEvent")
      .setParams({
        action: "HIDE",
      })
      .fire();
  },

  /* Here prepare delete confirmation modal*/
  deleteRecordModal: function (component, event, helper) {
    var question = component.get("v.question");
    $A.createComponents(
      [
        [
          "aura:html",
          {
            tag: "h2",
            body: "Delete Confirmation",
            HTMLAttributes: {
              class: "slds-text-heading_medium slds-hyphenate",
            },
          },
        ],
        [
          "lightning:button",
          {
            "aura:id": "no_button",
            label: "No",
            name: "no",
            onclick: component.getReference("c.deleteRecords"),
          },
        ],
        [
          "lightning:button",
          {
            "aura:id": "Yes_button",
            label: "Yes",
            name: "yes",
            variant: "brand",
            onclick: component.getReference("c.deleteRecords"),
          },
        ],
      ],
      function (components, status) {
        var buttons = [];
        buttons.push(components[1]);
        buttons.push(components[2]);
        if (status === "SUCCESS") {
          var modalPromise = component.find("overlayLib").showCustomModal({
            header: components[0],
            body: "Are you sure that you want to delete this selection option?",
            footer: buttons,
            showCloseButton: true,
          });
          component.set("v.modalPromise", modalPromise);
        }
      }
    );
  },

  /* Delete control to check link record*/
  deleteRecords: function (component, event, helper) {
    $A.get("e.c:BT_SpinnerEvent")
      .setParams({
        action: "SHOW",
      })
      .fire();
    var name = event.getSource().get("v.name");
    if (name === "yes") {
      var question = component.get("v.question");
      var deleteRecord = component.get("c.deleteCheckRecord");
      var checkId = question.Id;
      deleteRecord.setParams({
        checkId: checkId,
      });

      deleteRecord.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            message: "Deleted",
            type: "Success",
          });

          toastEvent.fire();
          var onDelete = component.get("v.onDelete");
          if (!$A.util.isUndefinedOrNull(onDelete)) {
            onDelete();
          }

          $A.get("e.c:BT_SpinnerEvent")
            .setParams({
              action: "HIDE",
            })
            .fire();
          component.get("v.modalPromise").then(function (modal) {
            modal.close();
          });
          component.find("overlayLib").notifyClose();
        }
      });
      $A.enqueueAction(deleteRecord);
    } else {
      $A.get("e.c:BT_SpinnerEvent")
        .setParams({
          action: "HIDE",
        })
        .fire();
      component.get("v.modalPromise").then(function (modal) {
        modal.close();
      });
    }
  },
  /*delete response type */

  onDeleteHandler: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var responseTypeList = component.get("v.responseTypeList");
    var responseTypeListNew = [];
    if (responseTypeList.length > index && index != undefined) {
      for (var i = 0; i < responseTypeList.length; i++) {
        if (index != i) {
          responseTypeListNew.push(responseTypeList[i]);
        }
      }
    }
    component.set("v.responseTypeList", responseTypeListNew);
  },

  /* On response type change show the fields that related to the response type */
  responsetype: function (component, event, helper) {
    console.log("---responsetype-- changes--");
    var index = event.getSource().get("v.name");
    var selectedOptionValue = event.getParam("value");
    console.log("Selected value::", selectedOptionValue + " index :: " + index);
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

  /*Show and hide the Text response data type fields*/
  handleQuestionResponseDataType: function (component, event, helper) {
    helper.questionResponseDataType(component, event);
  },

  /*This method is for validate the question text low and high value */
  validationForLowAndHigh: function (component, event, helper) {},
});