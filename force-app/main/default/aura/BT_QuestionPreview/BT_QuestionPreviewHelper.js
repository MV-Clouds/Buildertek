({
    getQuestions: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            action: "SHOW"
        }).fire();
        var action,
            state,
            questionGroupId = component.get("v.questionGroupId"),
            autoload = component.get("v.autoload");
        var questions = component.get("v.questions");

        if (
            (questions.length == 0 && autoload) ||
            component.get("v.requiredReload")
        ) {
            // Get all the related section's question group details
            action = component.get("c.retrieveQuestions");
            action.setParams({
                controlId: questionGroupId
            });
            action.setCallback(this, function(response) {
                console.log('response => ', { response });
                state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Response Value::", response.getReturnValue());
                    debugger;
                    component.set(
                        "v.questionsCopy",
                        JSON.parse(JSON.stringify(response.getReturnValue()))
                    );

                    var questions = response.getReturnValue();
                    console.log('====================================');
                    console.log('question see here ==>', { questions });
                    console.log('====================================');

                    if (questions != undefined) {
                        var multiOutput = [
                            "Multi Select~Checkbox",
                            "Multi Select~Checkbox-lineDirection",
                            "Multi Select~Multi Select List",
                        ];
                        for (var index = 0; index < questions.length; index++) {
                            var question = questions[index];

                            if (
                                question.check != undefined &&
                                question.check.buildertek__Answer_Choices__r != undefined
                            ) {

                                var answerChoices =
                                    question.check.buildertek__Answer_Choices__r;
                                debugger;
                                var inputOption = [
                                    "Date~Date Picker",
                                    "Text~Text Area",
                                    "Text~Simple Text",
                                ];
                                var responseTypeList = [];
                                var myMap = new Map();
                                var createChangeOrderonOverage = {};
                                debugger;


                                for (var i = 0; i < answerChoices.length; i++) {
                                    var answerChoice = answerChoices[i];
                                    if (!inputOption.includes(
                                            answerChoice.buildertek__Choice_Value__c
                                        )) {
                                        if (!myMap.has(
                                                answerChoice.Name +
                                                "~" +
                                                answerChoice.buildertek__Choice_Value__c
                                            )) {
                                            myMap.set(
                                                answerChoice.Name +
                                                "~" +
                                                answerChoice.buildertek__Choice_Value__c, []
                                            );
                                        }
                                        var responseAtt = {};
                                        responseAtt.buildertek__Choice_Text__c =
                                            answerChoice.buildertek__Choice_Text__c;
                                        responseAtt.Id = answerChoice.Id;
                                        responseAtt.buildertek__Image_Id__c =
                                            answerChoice.buildertek__Image_Id__c;
                                        responseAtt.buildertek__Document_Id__c =
                                            answerChoice.buildertek__Document_Id__c;
                                        responseAtt.buildertek__ParentId__c =
                                            answerChoice.buildertek__ParentId__c != undefined ?
                                            answerChoice.buildertek__ParentId__c :
                                            "";
                                        responseAtt.isVisible =
                                            answerChoice.buildertek__ParentId__c != "" ? true : false;
                                        responseAtt.buildertek__Text_Value__c =
                                            answerChoice.buildertek__Text_Value__c;
                                        responseAtt.buildertek__Additional_Cost__c =
                                            answerChoice.buildertek__Additional_Cost__c;
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
                                    if (!inputOption.includes(
                                            answerChoice.buildertek__Choice_Value__c
                                        )) {
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
                                        responseType.Id = answerChoice.Id;
                                        responseType.buildertek__Text_Value__c =
                                            answerChoice.buildertek__Text_Value__c;
                                        responseType.buildertek__Image_Id__c =
                                            answerChoice.buildertek__Image_Id__c;
                                        responseType.buildertek__Document_Id__c =
                                            answerChoice.buildertek__Document_Id__c;
                                        responseType.buildertek__ParentId__c =
                                            answerChoice.buildertek__ParentId__c != undefined ?
                                            answerChoice.buildertek__ParentId__c :
                                            "";
                                        responseType.isVisible =
                                            answerChoice.buildertek__ParentId__c != "" ? true : false;
                                        responseType.buildertek__Additional_Cost__c =
                                            answerChoice.buildertek__Additional_Cost__c;
                                        responseTypeList.push(responseType);
                                    }
                                }
                                if (
                                    responseTypeList != undefined &&
                                    responseTypeList.length > 0
                                ) {
                                    var inputLstObj = [];
                                    for (var j = 0; j < responseTypeList.length; j++) {
                                        var responseType = responseTypeList[j];
                                        var inputObj = {};
                                        inputObj.Name = responseType.responseTypeName;
                                        inputObj.Drop_Down_Value__c =
                                            responseType.selectedResponsetypeValue;

                                        inputObj.items = [];
                                        var selectionChoice = responseType.selectionChoices;

                                        if (selectionChoice != undefined) {
                                            for (var k = 0; k < selectionChoice.length; k++) {
                                                var choice = selectionChoice[k];
                                                var isMultiPicklist = false;
                                                if (!multiOutput.includes(
                                                        responseType.selectedResponsetypeValue
                                                    )) {
                                                    inputObj.values = "";
                                                    if (choice.buildertek__Text_Value__c != undefined) {
                                                        inputObj.values = choice.buildertek__Text_Value__c;

                                                        if (choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "") {
                                                            inputObj.isChild = true;
                                                            if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                                inputObj.isChild = false;
                                                                inputObj.isSaved = true;
                                                                inputObj.buildertek__Image_Id__c =
                                                                    choice.buildertek__Image_Id__c;
                                                                inputObj.buildertek__Document_Id__c =
                                                                    choice.buildertek__Document_Id__c;
                                                            }
                                                        } else {
                                                            inputObj.isChild = false;
                                                            if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                                inputObj.isSaved = true;
                                                                inputObj.buildertek__Image_Id__c =
                                                                    choice.buildertek__Image_Id__c;
                                                                inputObj.buildertek__Document_Id__c =
                                                                    choice.buildertek__Document_Id__c;
                                                            }
                                                        }
                                                        inputObj.isParent = choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "" ?
                                                            false :
                                                            true;
                                                        inputObj.buildertek__Additional_Cost__c =
                                                            choice.buildertek__Additional_Cost__c;
                                                    }
                                                } else {
                                                    if (inputObj.values == undefined) {
                                                        inputObj.values = [];
                                                    }
                                                    if (choice.buildertek__Text_Value__c != undefined) {
                                                        inputObj.values = JSON.parse(
                                                            choice.buildertek__Text_Value__c
                                                        );

                                                        if (choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "") {
                                                            inputObj.isChild = true;
                                                            if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                                inputObj.isChild = false;
                                                                inputObj.isSaved = true;
                                                                inputObj.buildertek__Image_Id__c =
                                                                    choice.buildertek__Image_Id__c;
                                                                inputObj.buildertek__Document_Id__c =
                                                                    choice.buildertek__Document_Id__c;
                                                            }
                                                        } else {
                                                            inputObj.isChild = false;
                                                            if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                                inputObj.isSaved = true;
                                                                inputObj.buildertek__Image_Id__c =
                                                                    choice.buildertek__Image_Id__c;
                                                                inputObj.buildertek__Document_Id__c =
                                                                    choice.buildertek__Document_Id__c;
                                                            }
                                                        }
                                                        inputObj.isParent = choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "" ?
                                                            false :
                                                            true;
                                                        inputObj.buildertek__Additional_Cost__c = JSON.parse(
                                                            choice.buildertek__Additional_Cost__c
                                                        );
                                                        isMultiPicklist = true;
                                                    }
                                                }
                                                var Option = {};
                                                Option.Id = choice.Id;
                                                Option.label = choice.buildertek__Choice_Text__c;
                                                Option.value = choice.buildertek__Choice_Text__c;
                                                Option.buildertek__Additional_Cost__c =
                                                    choice.buildertek__Additional_Cost__c;
                                                Option.buildertek__ParentId__c =
                                                    choice.buildertek__ParentId__c != undefined ?
                                                    choice.buildertek__ParentId__c :
                                                    "";
                                                Option.buildertek__Image_Id__c =
                                                    choice.buildertek__Image_Id__c;
                                                Option.buildertek__Document_Id__c =
                                                    choice.buildertek__Document_Id__c;
                                                Option.isVisible =
                                                    choice.buildertek__ParentId__c != "" ? true : false;

                                                if (inputObj.values.includes(Option.value)) {
                                                    Option.isSelected = true;
                                                }
                                                if (
                                                    isMultiPicklist &&
                                                    inputObj.values.includes(Option.value)
                                                ) {
                                                    Option.Selected = true;
                                                }
                                                inputObj.isParent = choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "" ?
                                                    false :
                                                    true;

                                                if (choice.buildertek__ParentId__c != undefined && choice.buildertek__ParentId__c != "") {
                                                    inputObj.isChild = true;
                                                    if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                        inputObj.isChild = false;
                                                        inputObj.isSaved = true;
                                                        inputObj.buildertek__Image_Id__c =
                                                            choice.buildertek__Image_Id__c;
                                                        inputObj.buildertek__Document_Id__c =
                                                            choice.buildertek__Document_Id__c;
                                                    }
                                                } else {
                                                    inputObj.isChild = false;
                                                    if (choice.buildertek__Text_Value__c != undefined && choice.buildertek__Text_Value__c != "") {
                                                        inputObj.isSaved = true;
                                                        inputObj.buildertek__Image_Id__c =
                                                            choice.buildertek__Image_Id__c;
                                                        inputObj.buildertek__Document_Id__c =
                                                            choice.buildertek__Document_Id__c;
                                                    }
                                                }
                                                inputObj.items.push(Option);
                                            }
                                        } else {
                                            inputObj.Id = responseType.Id;
                                            inputObj.values = responseType.buildertek__Text_Value__c;

                                            inputObj.buildertek__Additional_Cost__c =
                                                responseType.buildertek__Additional_Cost__c;
                                            inputObj.buildertek__ParentId__c =
                                                responseType.buildertek__ParentId__c != undefined ?
                                                responseType.buildertek__ParentId__c :
                                                "";
                                            inputObj.isVisible =
                                                responseType.buildertek__ParentId__c != "" ?
                                                false :
                                                true;
                                            inputObj.buildertek__Image_Id__c =
                                                responseType.buildertek__Image_Id__c;
                                            inputObj.buildertek__Document_Id__c =
                                                responseType.buildertek__Document_Id__c;
                                            if (responseType.buildertek__ParentId__c != undefined && responseType.buildertek__ParentId__c != "") {
                                                inputObj.isChild = true;
                                                if (responseType.buildertek__Text_Value__c != undefined && responseType.buildertek__Text_Value__c != "") {
                                                    inputObj.isChild = false;
                                                    inputObj.isSaved = true;
                                                }
                                            } else {
                                                inputObj.isChild = false;
                                                if (responseType.buildertek__Text_Value__c != undefined && responseType.buildertek__Text_Value__c != "") {
                                                    inputObj.isSaved = true;
                                                }
                                            }
                                            inputObj.isParent = responseType.buildertek__ParentId__c != undefined && responseType.buildertek__ParentId__c != "" ?
                                                false :
                                                true;
                                        }
                                        inputLstObj.push(inputObj);
                                    }
                                    question.responses = inputLstObj;
                                    questions[index] = question;
                                    questions[index].check.buildertek__Temp_Image_Id__c = question.check.buildertek__Image_Id__c;
                                    questions[index].check.buildertek__Temp_Document_Id__c = question.check.buildertek__Document_Id__c;
                                    console.log('Question Response :: ' + JSON.stringify(questions[index]));
                                }
                            }
                        }
                    }
                    console.log('Questions::::');
                    console.log({ questions });

                    component.set("v.questions", questions);
                    component.set("v.requiredReload", false);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        action: "HIDE"
                    }).fire();
                }
            });
            $A.enqueueAction(action);
        }
    },

    getImgVisibility: function(component, event, helper) {
        var action = component.get("c.getImageVisibility");
        action.setParams({
            recordId: component.get("v.selectionId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.imageVisibility", response.getReturnValue());
            }
        });
        // console.log(component.get("v.imageVisibility") + ')))))))))))))))))))))))))))))))))))))))'));
        $A.enqueueAction(action);
    },
});