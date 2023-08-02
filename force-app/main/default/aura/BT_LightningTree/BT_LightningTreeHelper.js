/*
 * Copyright 2011-2018, @ thoriyas technologies.
 * All rights reserved
 */

/* Lightning CLI rule */
({
    doInit: function (component, event, helper) {
        // Get root nodes using tree type and tree configuration
        helper.getRootNodes(component, event, helper);
    },

    getRootNodes: function (component, event, helper) {
        // Get root nodes
        var getRootNodesAction = component.get("c.getRootNodes");
        getRootNodesAction.setParams({
            "treeType": component.get("v.treeType"),
            "treeConfigurationName": component.get("v.treeConfigurationName"),
            "defaultSobjectFields": "Id,Name",
            "isExpandTreeRoots": true,
            "defaultFilterCondition": component.get("v.defaultFilterCondition"),
            "treeDataFields": component.get("v.treeDataFields"),
            "isNoSharingOperation": component.get("v.noSharingOperation")
        });
        getRootNodesAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rootNodesIdArray = [];
                component.set("v.rootNodes", response.getReturnValue());
                var rootNode = JSON.parse(JSON.stringify(response.getReturnValue()));
                var rootNodesIdArray = [];
                for (var i = 0; i < rootNode.length; i++) {
                    if (rootNode[i].children != undefined) {
                        for (var j = 0; j < rootNode[i].children.length; j++) {
                            rootNodesIdArray.push(rootNode[i].children[j].key);
                        }
                    }
                }
                var setRootNodeIcon = component.get("c.setRootNodeIcon");
                setRootNodeIcon.setParams({
                    "rootNodesIdArray": JSON.stringify(rootNodesIdArray)
                });

                setRootNodeIcon.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var question = JSON.parse(response.getReturnValue());
                        console.log('Response Root Node::', question);
                        var processedQuestion = [];
                        var sectionWiseTotalQuestionCountMap = new Map();
                        var sectionWiseTotalAnswerCountMap = new Map();
                        var sumOfSelectedItems = 0;
                        if (question != undefined) {
                            for (var i = 0; i < question.length; i++) {
                                if (question[i].buildertek__Question_Group__r != undefined && question[i].buildertek__Is_Selected_Item__c != undefined) {
                                    question[i].buildertek__Question_Group__r.buildertek__Locked__c && question[i].buildertek__Is_Selected_Item__c ? sumOfSelectedItems += question[i].buildertek__Cost__c!=undefined ? question[i].buildertek__Cost__c:0 : sumOfSelectedItems += 0;
                                }
                                if (question[i].buildertek__Section__c != undefined) {
                                    if (question[i].buildertek__Is_Selected_Item__c) {
                                        if (!sectionWiseTotalAnswerCountMap.has(question[i].buildertek__Section__c)) {
                                            sectionWiseTotalAnswerCountMap.set(question[i].buildertek__Section__c, 0);
                                        }
                                        sectionWiseTotalAnswerCountMap.set(question[i].buildertek__Section__c, parseInt(sectionWiseTotalAnswerCountMap.get(question[i].buildertek__Section__c)) + 1);
                                    }
                                    if (question[i].buildertek__Question_Group__r != undefined && question[i].buildertek__Question_Group__r.Id != undefined && processedQuestion.indexOf(question[i].buildertek__Question_Group__r.Id) == -1 &&
                                        question[i].buildertek__Question_Group__r.buildertek__of_Options_Required__c != undefined) {
                                        processedQuestion.push(question[i].buildertek__Question_Group__r.Id);
                                        var lastCount = 0;
                                        if (sectionWiseTotalQuestionCountMap.has(question[i].buildertek__Section__c)) {
                                            lastCount = parseInt(sectionWiseTotalQuestionCountMap.get(question[i].buildertek__Section__c));
                                        }
                                        lastCount += parseInt(question[i].buildertek__Question_Group__r.buildertek__of_Options_Required__c);
                                        sectionWiseTotalQuestionCountMap.set(question[i].buildertek__Section__c, lastCount);
                                    }
                                }
                            }
                        }
                        if(sumOfSelectedItems!=NaN && sumOfSelectedItems!=undefined && sumOfSelectedItems!=null){
                            sumOfSelectedItems = sumOfSelectedItems;
                        }else{
                            sumOfSelectedItems = 0;
                        }
                        var total = new Intl.NumberFormat('en-US', {
                            style: 'currency',
                            currency: 'USD'
                        }).format(sumOfSelectedItems);
                        component.set('v.sumOfSelectedItems', total);
                        var rootNodes = component.get('v.rootNodes');
                        console.log({rootNodes});
                        for (var i = 0; i < rootNodes.length; i++) {
                            if (rootNodes[i].children != undefined) {
                                for (var j = 0; j < rootNodes[i].children.length; j++) {
                                    rootNodes[i].children.sort(function (a, b) {
                                        var x = a['title'];
                                        var y = b['title'];
                                        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                                    });
                                }
                                for (var j = 0; j < rootNodes[i].children.length; j++) {
                                    if (rootNodes[i].children[j].userData == undefined) {
                                        rootNodes[i].children[j].userData = {};
                                    }
                                    rootNodes[i].children[j].userData.totalOptions = sectionWiseTotalQuestionCountMap.get(rootNodes[i].children[j].key) == undefined ? 0 : sectionWiseTotalQuestionCountMap.get(rootNodes[i].children[j].key);
                                    rootNodes[i].children[j].userData.totalTestedOptions = sectionWiseTotalAnswerCountMap.get(rootNodes[i].children[j].key) == undefined ? 0 : sectionWiseTotalAnswerCountMap.get(rootNodes[i].children[j].key);

                                    if (!rootNodes[i].children[j].userData.isDue &&
                                        rootNodes[i].children[j].userData.totalTestedOptions != rootNodes[i].children[j].userData.totalOptions) {
                                        rootNodes[i].children[j].totalOptions = rootNodes[i].children[j].userData.totalOptions;
                                        rootNodes[i].children[j].colors = 'grey';
                                    } else if (rootNodes[i].children[j].userData.isDue) {
                                        rootNodes[i].children[j].totalOptions = rootNodes[i].children[j].userData.totalOptions;
                                        rootNodes[i].children[j].colors = 'red';
                                    } else if (!rootNodes[i].children[j].userData.isDue &&
                                        rootNodes[i].children[j].userData.totalTestedOptions == rootNodes[i].children[j].userData.totalOptions) {
                                        rootNodes[i].children[j].totalOptions = rootNodes[i].children[j].userData.totalOptions;
                                        rootNodes[i].children[j].colors = 'green';
                                    } else {
                                        rootNodes[i].children[j].totalOptions = rootNodes[i].children[j].userData.totalOptions;
                                        rootNodes[i].children[j].colors = 'red';
                                    }
                                }
                            }
                        }
                        // console.log('Root Nodes::'+JSON.stringify(rootNodes));
                        component.set('v.rootNodes', rootNodes);
                    }
                });
                $A.enqueueAction(setRootNodeIcon);
            }
        });
        $A.enqueueAction(getRootNodesAction);
    }
})