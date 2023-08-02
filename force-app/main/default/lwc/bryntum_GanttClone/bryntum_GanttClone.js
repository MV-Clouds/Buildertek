/* globals bryntum : true */
import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import GanttDup from "@salesforce/resourceUrl/bryntumScheduleProModuleJS";
import GANTT from "@salesforce/resourceUrl/bryntum_gantt";
import GANTTModule from "@salesforce/resourceUrl/bryntumGanttModuleJs";
import SchedulerPro from "@salesforce/resourceUrl/bryntumScheduleProModuleJS";
import GanttToolbarMixin from "./lib/GanttToolbar";
import GanttToolbarMixinDup from "./lib/GanttToolbarDup";
import data from "./data/launch-saas";
import getScheduleItemRecords from "@salesforce/apex/BT_NewGanttChartCls.getScheduleItemRecords";
import insertUpdateTask from "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask";
import insertUpdateTaskList from "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTaskList";
import deleteTasks from "@salesforce/apex/BT_NewGanttChartCls.deleteTasks";
import getTask from "@salesforce/apex/BT_NewGanttChartCls.getTask";
import getEndDate from "@salesforce/apex/BT_NewGanttChartCls.getEndDate";
import getAllContacts from "@salesforce/apex/BT_NewGanttChartCls.getAllContacts";
import pickListValueDynamically from "@salesforce/apex/BT_NewGanttChartCls.pickListValueDynamically";
import addNotesCommentToRecord from "@salesforce/apex/BT_NewGanttChartCls.addNotesCommentToRecord";
import getNotesofRecord from "@salesforce/apex/BT_NewGanttChartCls.getNotesofRecord";
import getAllNotes from "@salesforce/apex/BT_NewGanttChartCls.getAllNotes";
import getattachmentLength from "@salesforce/apex/BT_NewGanttChartCls.getattachmentLength";
import saveResourceForRecord from "@salesforce/apex/BT_NewGanttChartCls.saveResourceForRecord";
import updateHideGanttOnSch from "@salesforce/apex/BT_NewGanttChartCls.updateHideGanttOnSch";
import { formatData } from "./bryntum_GanttHelper";
export default class Gantt_component extends NavigationMixin(LightningElement) {
  @api showpopup = false;
  @api fileTaskId = "";
  @api showDeletePopup = false;
  @api showEditPopup = false;
  @api showIframe = false;
  @api isLoaded = false;
  @api recordId;
  @api taskRecordId;
  @api objApiName = "buildertek__Project_Task__c";
  @track scheduleItemsData;
  @api scheduleItemsDataList;
  @api storeRes;
  @api scheduleItemIdsList = [];
  @api showAllContacts = [];
  @api predecessorVal = "";
  @api newTaskPopupName = "";
  @api taskPhaseVal = "";
  @api newTaskDuration = 1;
  @api newTaskStartDate = "";
  @api newTaskLag = 0;
  @api newTaskCompletion;
  @api GanttVar;
  @api schedulerVar;
  @api selectedPredecessor;
  @api showFileForRecord = "";
  @api showFilePopup = false;
  @api notesList;
  @api projectNameShow = false;
  @api ganttJsonData;
  @api loadedChart = false;
  @api newTaskRecordCreate = {
    sObjectType: "buildertek__Project_Task__c",
    Name: "",
    Id: "",
    buildertek__Phase__c: "",
    buildertek__Dependency__c: "",
    buildertek__Completion__c: "",
    buildertek__Start__c: "",
    buildertek__Finish__c: "",
    buildertek__Duration__c: "",
    buildertek__Lag__c: "",
    buildertek__Resource__c: "",
    buildertek__Contractor__c: "",
    buildertek__Contractor_Resource__c: "",
    buildertek__Schedule__c: "",
    buildertek__Order__c: "",
    buildertek__Notes__c: "",
    buildertek__Budget__c: "",
    buildertek__Add_To_All_Active_Schedules__c: "",
    buildertek__Type__c: "Task",
    buildertek__Indent_Task__c: false,
  };
  @api newTaskRecordClone = {
    sObjectType: "buildertek__Project_Task__c",
    Name: "",
    Id: "",
    buildertek__Type__c: "Task",
    buildertek__Phase__c: "",
    buildertek__Dependency__c: "",
    buildertek__Completion__c: "",
    buildertek__Start__c: "",
    buildertek__Finish__c: "",
    buildertek__Duration__c: "",
    buildertek__Lag__c: "",
    buildertek__Resource__c: "",
    buildertek__Contractor__c: "",
    buildertek__Contractor_Resource__c: "",
    buildertek__Schedule__c: "",
    buildertek__Order__c: "",
    buildertek__Notes__c: "",
    buildertek__Budget__c: "",
    buildertek__Indent_Task__c: false,
    buildertek__Add_To_All_Active_Schedules__c: "",
  };
  @api selectedResource;
  @api selecetedContratcResource;
  @api selectedContractor;

  @api isEndDateFocused = false;
  @api isEditEnabled = false;
  @api foucsedCellId = "";
  @api picklistVal;
  @api schItemComment = "";
  @api showCommentPopup = false;
  @api showAddCommentPopup = false;
  @api addCommentHeader = "";
  @api newNotesList = [];
  @api saveCommentSpinner = false;
  @api fileLengthCheck;
  @api showEditResourcePopup = false;
  @api selectedResourceContact;
  @api selectedContactApiName;
  @api uploadFileNameCheck = "";
  @api recordTaskParent;
  @api hideSchedule = false;
  @api hideuserSchedule = false;
  @api predecessorLookup = {};
  @api resourceLookup = {};
  @api contractorResourceLookup = {};
  @api contratctorLookup = {};
  @api userProfileName = "";
  @api getFiredFromAura() {
    this.refreshGantt();
  }
  //@api saveSelectedContact;
  //@api saveSelectedContactApiName;

  @wire(pickListValueDynamically, {
    customObjInfo: { sobjectType: "buildertek__Project_Task__c" },
    selectPicklistApi: "buildertek__Phase__c",
  })
  selectTargetValues;

  @wire(pickListValueDynamically, {
    customObjInfo: { sobjectType: "buildertek__Project_Task__c" },
    selectPicklistApi: "buildertek__Type__c",
  })
  selectTargetTypeValues;

  selectOptionChanveValue(event) {
    this.picklistVal = event.target.value;
    this.newTaskRecordCreate["buildertek__Phase__c"] = event.target.value;
  }
  selectOptionChanveTypeValue(event) {
    this.picklistVal = event.target.value;
    this.newTaskRecordCreate["buildertek__Type__c"] = event.target.value;
  }

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }
  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    let uploadedFileNames = "";
    for (let i = 0; i < uploadedFiles.length; i++) {
      uploadedFileNames += uploadedFiles[i].name + ", ";
    }
    this.uploadFileNameCheck = uploadedFileNames;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message:
          uploadedFiles.length +
          " Files uploaded Successfully: " +
          uploadedFileNames,
        variant: "success",
      })
    );
  }

  updateValOnSch(hideScheduleVal) {
    /*  updateHideGanttOnSch({schId: this.scheduleData.Id, hideGantt: hideScheduleVal}).then(function(response){
            console.log(response)
        }) */
  }
  updateValOnUser(hideScheduleVal) {
    var thatThis = this;
    updateHideGanttOnSch({ hideGantt: hideScheduleVal }).then((response) => {
      console.log(response);
      thatThis.hideScheduleFromUser = response.buildertek__Hide_Schedule__c;
    });
  }

  getComment() {
    var that = this;
    this.isLoaded = true;
    getAllNotes({ schId: this.taskRecordId })
      .then(function (response) {
        console.log(response);
        that.notesList = response;
        that.schItemComment = response.buildertek__Notes__c;
        that.isLoaded = false;
        that.showCommentPopup = true;
      })
      .catch(function (error) {
        that.isLoaded = false;
        console.log(error);
      });
  }

  commentValueChange(event) {
    console.log(event);
    console.log(event.target.value);
    console.log(event.currentTarget.dataset.index);
    var idx = event.currentTarget.dataset.index;
    this.newNotesList[idx]["TextPreview"] = event.target.value;
    this.showCommentPopup = true;
    //this.schItemComment = event.target.value
  }
  viewNotes(event) {
    this.addCommentHeader = "Comment";
    var noteIndex = event.currentTarget.dataset.index;
    var textPreview = this.notesList[noteIndex].TextPreview;
    // this.addComment(textPreview);
    this.schItemComment = textPreview;
    //this.addCommentHeader = 'Add Comment'
    this.showAddCommentPopup = true;
  }
  showSpinner() {
    this.isLoaded = true;
  }
  addComment() {
    this.showCommentPopup = false;
    var len = this.newNotesList.length;
    var obj = {
      Id: len + 1,
      TextPreview: "",
      Title: "Comment",
    };
    this.newNotesList.push(obj);
    this.showCommentPopup = true;
    /* this.schItemComment = '';
        this.addCommentHeader = 'Add Comment'
        this.showAddCommentPopup = true; */
  }
  closeaddCommentPopup() {
    this.showAddCommentPopup = false;
    this.addCommentClick = false;
  }
  saveComment() {
    var recId = this.taskRecordId;
    var newNotes = this.newNotesList;
    var that = this;
    if (recId && newNotes) {
      this.isLoaded = true;
      this.saveCommentSpinner = true;
      var commentList = [];
      for (var i = 0; i < newNotes.length; i++) {
        var newCommentTask = {
          sObjectType: "ContentNote",
          TextPreview: newNotes[i]["TextPreview"],
          Title: newNotes[i]["Title"],
        };
        if (newNotes[i]["TextPreview"]) {
          commentList.push(newCommentTask);
        }
      }
      //JSON.stringify(commentList)
      if (commentList.length) {
        addNotesCommentToRecord({
          schItem: this.taskRecordId,
          notes: commentList,
        })
          .then(function (response) {
            console.log(response);
            if (response == "Success") {
              that.saveCommentSpinner = false;
              that.taskRecordId = "";
              that.schItemComment = "";
              that.isLoaded = false;
              that.newNotesList = [];
              that.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: "Comment added successfully",
                  variant: "success",
                })
              );
              that.showCommentPopup = false;
              that.gettaskrecords();
            } else {
              console.log(response);
            }
          })
          .catch(function (error) {
            that.saveCommentSpinner = false;
            that.isLoaded = false;
          });
      } else {
        this.showCommentPopup = false;
        this.saveCommentSpinner = false;
        this.taskRecordId = "";
        this.schItemComment = "";
        this.isLoaded = false;
        this.newNotesList = [];
      }
    }
  }

  handleAccountSelection(event) {
    console.log("the selected record id is" + event.detail);
    if (event.detail.fieldNameapi == "buildertek__Dependency__c") {
      this.newTaskRecordCreate["buildertek__Dependency__c"] = event.detail.Id;
      this.predecessorLookup["Id"] = event.detail.Id;
      this.predecessorLookup["Name"] = event.detail.selectedName;
    } else if (event.detail.fieldNameapi == "buildertek__Resource__c") {
      this.newTaskRecordCreate["buildertek__Resource__c"] = event.detail.Id;
      this.resourceLookup["Id"] = event.detail.Id;
      this.resourceLookup["Name"] = event.detail.selectedName;
    } else if (event.detail.fieldNameapi == "buildertek__Contractor__c") {
      this.newTaskRecordCreate["buildertek__Contractor__c"] = event.detail.Id;
      this.contratctorLookup["Id"] = event.detail.Id;
      this.contratctorLookup["Name"] = event.detail.selectedName;
    } else if (
      event.detail.fieldNameapi == "buildertek__Contractor_Resource__c"
    ) {
      this.newTaskRecordCreate["buildertek__Contractor_Resource__c"] =
        event.detail.Id;
      this.contractorResourceLookup["Id"] = event.detail.Id;
      this.contractorResourceLookup["Name"] = event.detail.selectedName;
    }
  }
  handlecontactSelection(event) {
    console.log(event);
    this.selectedResourceContact = event.detail.Id;
    //this.selectedContactApiName =
  }
  saveSelectedContact() {
    var that = this;
    if (!this.taskRecordId.includes("_generated")) {
      saveResourceForRecord({
        taskId: this.taskRecordId,
        resourceId: this.selectedResourceContact,
        resourceApiName: this.selectedContactApiName,
      }).then(function (response) {
        const filterChangeEvent = new CustomEvent("filterchange", {
          detail: { message: "refresh page" },
        });
        that.dispatchEvent(filterChangeEvent);
        that.gettaskrecords();
        that.showEditResourcePopup = false;
      });
    } else {
    }
  }
  changeInputVal(e) {
    //lag
    console.log(e.currentTarget.dataset.inputname);

    if (e.currentTarget.dataset.inputname == "buildertek__Dependency__c") {
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        this.template.querySelectorAll("lightning-input-field")[1].value;
    } else if (e.currentTarget.dataset.inputname == "buildertek__Resource__c") {
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        this.template.querySelectorAll("lightning-input-field")[2].value;
    } else if (
      e.currentTarget.dataset.inputname == "buildertek__Contractor__c"
    ) {
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        this.template.querySelectorAll("lightning-input-field")[3].value;
    } else if (
      e.currentTarget.dataset.inputname == "buildertek__Contractor_Resource__c"
    ) {
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        this.template.querySelectorAll("lightning-input-field")[4].value;
    } else if (e.target) {
      if (e.currentTarget.dataset.inputname == "buildertek__Start__c") {
        var stDate = new Date(
          Number(e.target.value.split("-")[0]),
          Number(e.target.value.split("-")[1]) - 1,
          Number(e.target.value.split("-")[2])
        );
        var endDate;
        /* if(stDate.getDay() == 6){
                    stDate.setDate(stDate.getDate() +2);
                    console.log(stDate)
                    stDate = new Date(stDate)
                    //dt = new Date(dt);
                }
                if(stDate.getDay() == 0){
                    stDate.setDate(stDate.getDate() +2);
                    console.log(stDate)
                    stDate = new Date(stDate)
                    //dt = new Date(dt);
                } */
        var duration = Number(
          this.newTaskRecordCreate["buildertek__Duration__c"]
        );
        if (duration) {
          endDate = new Date(stDate.setDate(stDate.getDate() + (duration - 1)));
          // var days = this.workingDaysBetweenDates(stDate,endDate)
          //endDate.setDate(endDate.getDate() +days);
          var Difference_In_Time = endDate.getTime() - stDate.getTime();

          // To calculate the no. of days between two dates
          var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
          var dupStDate = stDate;
          for (var j = 0; j < duration - 1; j++) {
            var dt = new Date(dupStDate.setDate(dupStDate.getDate() + j));
            if (dt.getDay() == 6 || dt.getDay() == 0) {
              endDate = new Date(endDate.setDate(endDate.getDate() + 1));
            }
          }
          var thatThis = this;
          getEndDate({
            sDate: e.target.value,
            eDate: this.newTaskRecordCreate["buildertek__Finish__c"],
            duration: duration,
          }).then(function (response) {
            var newTaskeDate = response; //.toLocaleDateString().split('/');
            thatThis.newTaskRecordCreate["buildertek__Finish__c"] = response; // newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];
            if (thatThis.template.querySelectorAll("lightning-input")) {
              if (
                thatThis.template.querySelectorAll("lightning-input")[3]
                  .label == "End Date"
              ) {
                thatThis.template.querySelectorAll("lightning-input")[3].value =
                  thatThis.newTaskRecordCreate["buildertek__Finish__c"];
              }
            }
          });

          //endDate = endDate
        }
        //this.newTaskRecordCreate['buildertek__Finish__c'] =
      } else if (
        e.currentTarget.dataset.inputname == "buildertek__Duration__c"
      ) {
        var stdateVal = this.newTaskRecordCreate["buildertek__Start__c"];
        var stDate = new Date(
          Number(stdateVal.split("-")[0]),
          Number(stdateVal.split("-")[1]) - 1,
          Number(stdateVal.split("-")[2])
        );
        var endDate;
        /* if(stDate.getDay() == 6){
                    stDate.setDate(stDate.getDate() +2);
                    console.log(stDate)
                    stDate = new Date(stDate)
                    //dt = new Date(dt);
                }
                if(stDate.getDay() == 0){
                    stDate.setDate(stDate.getDate() +2);
                    console.log(stDate)
                    stDate = new Date(stDate)
                    //dt = new Date(dt);
                } */
        var duration = Number(e.target.value);
        if (duration) {
          endDate = new Date(stDate.setDate(stDate.getDate() + (duration - 1)));
          console.log(endDate);
          var Difference_In_Time = endDate.getTime() - stDate.getTime();

          // To calculate the no. of days between two dates
          var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
          var dupStDate = stDate;
          for (var j = 0; j < duration - 1; j++) {
            var dt = new Date(dupStDate.setDate(dupStDate.getDate() + j));
            if (dt.getDay() == 6 || dt.getDay() == 0) {
              endDate = new Date(endDate.setDate(endDate.getDate() + 1));
            }
          }
          // endDate = new Date(endDate)
          //var days = this.workingDaysBetweenDates(stDate,endDate)
          //endDate.setDate(endDate.getDate() +days);
          var thatThis = this;
          getEndDate({
            sDate: this.newTaskRecordCreate["buildertek__Start__c"],
            eDate: this.newTaskRecordCreate["buildertek__Finish__c"],
            duration: duration,
          }).then(function (response) {
            var newTaskeDate = response; //.toLocaleDateString().split('/');
            thatThis.newTaskRecordCreate["buildertek__Finish__c"] =
              newTaskeDate; // newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];
            if (
              thatThis.template.querySelectorAll("lightning-input")[3].label ==
              "End Date"
            ) {
              thatThis.template.querySelectorAll("lightning-input")[3].value =
                thatThis.newTaskRecordCreate["buildertek__Finish__c"];
            }
          });
          /* var newTaskeDate = endDate.toLocaleDateString().split('/');
                    this.newTaskRecordCreate['buildertek__Finish__c'] =  newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];
                    if(this.template.querySelectorAll('lightning-input')[3].label == 'End Date'){
                        this.template.querySelectorAll('lightning-input')[3].value = this.newTaskRecordCreate['buildertek__Finish__c']
                    } */
        } else if (!duration) {
          this.newTaskRecordCreate["buildertek__Duration__c"] = 1;
        }
      }

      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        e.target.value;
    }

    //this.newTaskRecordCreate[e.currentTarget.dataset.inputname] = e.target.value;
  }
  navigateToRecordViewPage(id) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: id,
        actionName: "view",
      },
    });
  }
  getRecordData(recID, recData) {
    if (recID) {
      this.isLoaded = true;
      var recThis = this;
      getTask({ taskId: recID })
        .then(function (response) {
          console.log(response);
          recThis.newTaskRecordCreate = response;
          // recThis.selectedPredecessor = response['buildertek__Dependency__c']
          //recThis.template.querySelector('.slds-select').value = response['buildertek__Phase__c'];

          if (recData.predecessor != response["buildertek__Dependency__c"])
            recThis.newTaskRecordCreate["buildertek__Dependency__c"] =
              recData.predecessor;
          if (recData.internalresource != response["buildertek__Completion__c"])
            recThis.newTaskRecordCreate["buildertek__Resource__c"] =
              recData.internalresource;
          if (
            recData.contractorresource != response["buildertek__Completion__c"]
          )
            recThis.newTaskRecordCreate["buildertek__Contractor_Resource__c"] =
              recData.contractorresource;
          if (recData.contractoracc != response["buildertek__Completion__c"])
            recThis.newTaskRecordCreate["buildertek__Contractor__c"] =
              recData.contractoracc;
          recThis.newTaskRecordCreate["Name"] = recData.name;
          // console.log(recThis.selectedPredecessor)
          if (recData.percentDone != response["buildertek__Completion__c"])
            recThis.newTaskRecordCreate["buildertek__Completion__c"] =
              recData.percentDone;
          recThis.isLoaded = false;
          recThis.showEditPopup = true;
          //recThis.template.querySelector('.slds-select').value = response['buildertek__Phase__c'];
          //that.gettaskrecords()
        })
        .catch((error) => {
          console.log(error);
          this.isLoaded = false;
        });
    }
  }

  getContacts() {
    var conthis = this;
    getAllContacts().then(function (response) {
      var resourceRowIdList = [];
      var allresourcesData = [];
      for (var i = 0; i < response.length; i++) {
        if (resourceRowIdList.indexOf(response[i].Id) < 0) {
          var resourceRow = {};
          resourceRow["id"] = response[i].Id;
          resourceRow["name"] = response[i].Name;
          resourceRow["calendar"] = "general";
          allresourcesData.push(resourceRow);
          resourceRowIdList.push(response[i].Id);
        }
      }
      conthis.showAllContacts = allresourcesData;
      /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                
                if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor__c) < 0){
                    var resourceRow = {}
                    resourceRow['id'] = taskListForPhase[i].buildertek__Contractor__c
                    resourceRow['name'] = taskListForPhase[i].buildertek__Contractor__r.Name;
                    resourceRow['calendar'] = "general";
                    resourceRowData.push(resourceRow)
                    resourceRowIdList.push(resourceRow['id'])
                }
                
            } */
    });
  }

  /* refreshTask(tasks){
        this.GanttVar.refresh();
    } */
  droprow(e) {
    console.log(e);
    /*  var data = e.dataTransfer.getData("text");
        // Find the record ID by crawling up the DOM hierarchy

        var tar 
        if(e.target.closest('[class*="b-grid-row"]')){
            tar = e.target.closest('[class*="b-grid-row"]').getAttribute('data-index') 
        }else if(e.target.closest('[class="b-grid-row b-tree-parent-row b-tree-expanded"]')){
            tar = e.target.closest('[class="b-grid-row b-tree-parent-row b-tree-expanded"]').getAttribute('data-index')
        }else if(e.target.closest('[class="b-grid-row b-tree-parent-row b-tree-collapsed"]')){
            tar = e.target.closest('[class="b-grid-row b-tree-parent-row b-tree-collapsed"]')
        } */
    //var tar  e.target.closest('[data-id]');
    //var phaseindex = e.currentTarget.dataset.phaseindex

    //var scheduleitemlst = ;
    console.log(this.scheduleItemIdsList);
    var taskIdList = this.scheduleItemIdsList;
    console.log(this.scheduleItemsDataList);
    //var phaseindex = taskIdList.indexOf()
    // var taskList = this.scheduleItemsDataList;
    /*  var taskList = this.GanttVar.tasks
        var index1, index2, temp;
        // Find the index of each item to move
        taskList.forEach((v,i)=>{if(i===Number(data)) index1 = i; if(i===Number(tar)) index2 = i;});
        if(index1<index2) {
            // Lower index to higher index; we move the lower index first, then remove it.
            taskList.splice(index2+1, 0,  taskList[index1]);
            console.log(taskList)
            taskList.splice(index1, 1);

           
            console.log(taskList)
           
        } else if(index1>index2) {
            // Higher index to lower index; we remove the higher index, then add it to the lower index.
            temp = taskList.splice(index1, 1)[0];
            taskList.splice(index2, 0, temp);
        }
        this.refreshTask(taskList); */
    //e.target.closest('[class*="b-grid-row"]').style.borderTop = '1px Solid green'
    var taskList = this.scheduleItemsDataList;
    var data = e.dataTransfer.getData("text");
    // Find the record ID by crawling up the DOM hierarchy

    var tar;
    if (e.target.closest('[class*="b-grid-row"]')) {
      tar = e.target.closest('[class*="b-grid-row"]').getAttribute("data-id");
    } else if (
      e.target.closest('[class="b-grid-row b-tree-parent-row b-tree-expanded"]')
    ) {
      tar = e.target
        .closest('[class="b-grid-row b-tree-parent-row b-tree-expanded"]')
        .getAttribute("data-index");
    } else if (
      e.target.closest(
        '[class="b-grid-row b-tree-parent-row b-tree-collapsed"]'
      )
    ) {
      tar = e.target.closest(
        '[class="b-grid-row b-tree-parent-row b-tree-collapsed"]'
      );
    }
    var index1, index2, temp;
    var isPhase = false;

    // Find the index of each item to move

    // dragging of task phase start
    if (
      data.indexOf("_") > -1 &&
      tar.indexOf("_") > -1 &&
      this.scheduleItemsData.length
    ) {
      var taskListNew = this.scheduleItemsData;
      var that = this;
      taskListNew.forEach((v, idx) => {
        if (that.scheduleData.Id + "_" + v.key == data) index1 = idx;
        if (that.scheduleData.Id + "_" + v.key == tar) index2 = idx;
        /* if(tar.indexOf('_')> -1 && !isPhase){
                    if(v.buildertek__Phase__c == tar.split("_")[1]){
                        index2 = i ? i-1: i;
                        isPhase = true;
                    }
                } */
      });
      console.log(index2);
      console.log(index1);
      if (index1 > index2) {
        var draggingPhase = taskListNew[index1].value;
        var dropPhase = taskListNew[index2].value;
        var dropLen = 0;
        var removeLen = 0;
        for (var i = 0; i < taskListNew.length; i++) {
          if (index1 == i) {
            //removeLen = taskList[i].value.length
            break;
          } else {
            removeLen += taskListNew[i].value.length;
          }
        }
        for (var i = 0; i < taskListNew.length; i++) {
          if (index2 == i) {
            //removeLen = taskList[i].value.length
            break;
          } else {
            dropLen += taskListNew[i].value.length;
          }
        }
        var fromatList = this.scheduleItemsDataList;
        temp = fromatList.splice(removeLen, draggingPhase.length);
        console.log(temp);
        for (var i = temp.length - 1; i >= 0; i--) {
          if (index2 == 0) {
            fromatList.splice(index2, 0, temp[i]);
          } else if (index2) {
            fromatList.splice(dropLen, 0, temp[i]);
          }
        }
        console.log(fromatList);
        this.scheduleItemsDataList = fromatList;
      } else {
        if (taskListNew[index2]) {
          var fromatList = this.scheduleItemsDataList;
          var draggingPhase = taskListNew[index1].value;
          var dropPhase = taskListNew[index2].value;
          var dropLen = 0;
          var removeLen = 0;
          for (var i = 0; i < taskListNew.length; i++) {
            if (index1 == i) {
              //removeLen = taskList[i].value.length
              break;
            } else {
              removeLen += taskListNew[i].value.length;
            }
          }
          for (var i = 0; i < taskListNew.length; i++) {
            if (index2 == i) {
              //removeLen = taskList[i].value.length
              break;
            } else {
              dropLen += taskListNew[i].value.length;
            }
          }

          var temp = fromatList.splice(
            dropLen,
            taskListNew[index2].value.length
          );

          /* for(var i=taskListNew[index1].value.length-1;i>0;i--){
                        fromatList.splice(dropLen,0,JSON.parse(JSON.stringify(taskListNew[index1].value[i])));
                    } */
          for (var i = temp.length - 1; i >= 0; i--) {
            fromatList.splice(removeLen, 0, temp[i]);
          }
          //fromatList.splice(removeLen,taskListNew[index1].value.length);
          console.log(fromatList);
        }

        this.scheduleItemsDataList = fromatList;
      }
    } else {
      // dragging of task row start
      taskList.forEach((v, i) => {
        if (v.Id == data) index1 = i;
        if (v.Id == tar) index2 = i;
        /* if(tar.indexOf('_')> -1 && !isPhase){
                if(v.buildertek__Phase__c == tar.split("_")[1]){
                    index2 = i ? i-1: i;
                    isPhase = true;
                }
            } */
      });
      console.log(taskList[index2]);
      console.log(taskList[index1]);
      console.log(taskList[index2 + 1]);
      if (index1 < index2) {
        // Lower index to higher index; we move the lower index first, then remove it.
        /* if(isPhase){
                taskList[index1].buildertek__Phase__c = null;
        }else  */
        if (
          taskList[index2].buildertek__Phase__c !=
            taskList[index1].buildertek__Phase__c &&
          taskList[index2].buildertek__Phase__c ==
            taskList[index2 + 1].buildertek__Phase__c
        ) {
          taskList[index1].buildertek__Phase__c =
            taskList[index2].buildertek__Phase__c;
        } else if (
          taskList[index2].buildertek__Phase__c !=
            taskList[index1].buildertek__Phase__c &&
          taskList[index2].buildertek__Phase__c !=
            taskList[index2 + 1].buildertek__Phase__c
        ) {
          taskList[index1].buildertek__Phase__c = null;
        }
        /* if(isPhase){
                if(taskList[index2].buildertek__Phase__c != taskList[index1].buildertek__Phase__c && taskList[index2].buildertek__Phase__c == taskList[index2+1].buildertek__Phase__c){
                    taskList[index1].buildertek__Phase__c = taskList[index2].buildertek__Phase__c
                }else if(taskList[index2].buildertek__Phase__c != taskList[index1].buildertek__Phase__c && taskList[index2].buildertek__Phase__c != taskList[index2+1].buildertek__Phase__c){
                    taskList[index1].buildertek__Phase__c = null;
                }
            }else{
                taskList[index1].buildertek__Phase__c = taskList[index2].buildertek__Phase__c
            } */
        taskList.splice(index2 + 1, 0, taskList[index1]);
        console.log(taskList);
        taskList.splice(index1, 1);
        console.log(taskList);
      } else if (index1 > index2) {
        /* if(isPhase){
                taskList[index1].buildertek__Phase__c = null;
            }else */
        /* if(isPhase){
                if(taskList[index2].buildertek__Phase__c != taskList[index1].buildertek__Phase__c && taskList[index2].buildertek__Phase__c == taskList[index2+1].buildertek__Phase__c){
                    taskList[index1].buildertek__Phase__c = taskList[index2].buildertek__Phase__c
                }else if(taskList[index2].buildertek__Phase__c != taskList[index1].buildertek__Phase__c && taskList[index2].buildertek__Phase__c != taskList[index2+1].buildertek__Phase__c){
                    taskList[index1].buildertek__Phase__c = null;
                }
            }else{
                taskList[index1].buildertek__Phase__c = taskList[index2].buildertek__Phase__c
            } */
        if (
          taskList[index2].buildertek__Phase__c !=
            taskList[index1].buildertek__Phase__c &&
          taskList[index2].buildertek__Phase__c ==
            taskList[index2 + 1].buildertek__Phase__c
        ) {
          taskList[index1].buildertek__Phase__c =
            taskList[index2].buildertek__Phase__c;
        } else if (
          taskList[index2].buildertek__Phase__c !=
            taskList[index1].buildertek__Phase__c &&
          taskList[index2].buildertek__Phase__c !=
            taskList[index2 + 1].buildertek__Phase__c
        ) {
          taskList[index1].buildertek__Phase__c = null;
        }
        // Higher index to lower index; we remove the higher index, then add it to the lower index.
        temp = taskList.splice(index1, 1)[0];
        console.log(temp);
        taskList.splice(index2, 0, temp);
      }
      //this.refreshTask(taskList);
      this.scheduleItemsDataList = taskList;

      // dragging of task row end
    }

    let recordsMap = new Map();
    for (var i in taskList) {
      if (taskList[i].buildertek__Phase__c) {
        if (!recordsMap.has(taskList[i].buildertek__Phase__c)) {
          recordsMap.set(taskList[i].buildertek__Phase__c, []);
        }
        recordsMap
          .get(taskList[i].buildertek__Phase__c)
          .push(JSON.parse(JSON.stringify(taskList[i])));
      } else {
        if (!recordsMap.has("null")) {
          recordsMap.set("null", []);
        }
        recordsMap.get("null").push(JSON.parse(JSON.stringify(taskList[i])));
      }
    }
    var result = Array.from(recordsMap.entries());
    var groupData = [];
    for (var i in result) {
      var newObj = {};
      newObj["key"] = result[i][0];
      newObj["value"] = result[i][1];
      groupData.push(newObj);
    }
    console.log(groupData);
    this.scheduleItemsData = groupData;
    this.isLoaded = true;
    if (this.template.querySelector(".container").children.length) {
      this.template.querySelector(".container").innerHTML = "";
      this.template.querySelector(".container1").innerHTML = "";
      this.createGantt();
      //this.GanttVar.crudManager.taskStore.refreshData()
    } else {
      this.createGantt();
      this.isLoaded = false;
    }
    // Trigger aura:valueChange, component will rerender
    // component.set("v.scheduleitemlst", scheduleitemlst);
    e.preventDefault();
  }
  allowDrop(e) {
    //e.target.closest('[class*="b-grid-row"]').style.border = '1px solid green'
    e.preventDefault();
    console.log(e);
    // e.target.style.cursor = 'move'
  }
  ondragrow(e) {
    console.log(e);
  }
  callinsertUpdateTaskList(taskData) {
    var that = this;
    this.isLoaded = true;
    insertUpdateTaskList({ taskJSON: JSON.stringify(taskData), isUpdate: true })
      .then(function (response) {
        console.log(response);
        // that.updateValOnSch(that.hideSchedule);
        const filterChangeEvent = new CustomEvent("filterchange", {
          detail: { message: "refresh page" },
        });
        that.isLoaded = false;
        that.dispatchEvent(filterChangeEvent);
        //that.gettaskrecords()
      })
      .catch((error) => {
        console.log(error);
        this.isLoaded = false;
      });
  }
  addNewTask(record) {
    var newTaskeDate;
    var dt;
    Object.assign(this.newTaskRecordCreate, this.newTaskRecordClone);

    if (record) {
      if (record._data.type == "Task") {
        this.newTaskRecordCreate["buildertek__Dependency__c"] = record._data.id;
        //this.predecessorVal = record._data.id;
        this.newTaskRecordCreate["buildertek__Order__c"] = record._data.order;
      }
      /* this.newTaskOrder = record._data.order;
            this.taskPhaseVal = record._data.phase != 'null' ? record._data.phase: '' */
      // this.newTaskRecordCreate['buildertek__Order__c'] = record._data.order;
      if (record._data.phase) {
        this.newTaskRecordCreate["buildertek__Phase__c"] =
          record._data.phase != "null" ? record._data.phase : "";
      } else if (record._data.type == "Phase") {
        this.newTaskRecordCreate["buildertek__Phase__c"] = record._data.name;
      }

      dt = record._data.endDate;
    }
    this.showEditPopup = true;
    this.taskRecordId = "";
    //this.newTaskPopupName = 'New Task';
    this.newTaskRecordCreate["Name"] = "";
    if (record && record._data.endDate) {
      // newTaskeDate  = record._data.endDate.toLocaleDateString().split('/');
      dt = record._data.endDate;
    } else {
      dt = new Date();
      newTaskeDate = new Date().toLocaleDateString().split("/");
    }

    console.log(dt);
    if (dt.getDay() == 6) {
      dt.setDate(dt.getDate() + 2);
      console.log(dt);
      //dt = new Date(dt);
    }
    if (dt.getDay() == 0) {
      dt.setDate(dt.getDate() + 1);
      console.log(dt);
      //dt = new Date(dt);
    }
    console.log(dt);
    newTaskeDate = dt.toLocaleDateString().split("/");
    /* this.newTaskStartDate = newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];
        this.newTaskDuration = 1;
        this.newTaskCompletion = 0;
        this.newTaskLag = 0; */
    //this.newTaskRecordCreate['buildertek__Start__c'] = newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];

    this.newTaskRecordCreate["buildertek__Start__c"] =
      dt.getFullYear() + "-" + Number(dt.getMonth() + 1) + "-" + dt.getDate();
    this.newTaskRecordCreate["buildertek__Duration__c"] = 1;
    this.newTaskRecordCreate["buildertek__Finish__c"] =
      this.newTaskRecordCreate["buildertek__Start__c"];
    this.newTaskRecordCreate["buildertek__Completion__c"] = 0;
    this.newTaskRecordCreate["buildertek__Lag__c"] = 0;
  }
  deleteRecord() {
    var task = this.readyTodeleteTask;
    var that = this;
    if (task) {
      that.GanttVar.project.stm.autoRecord = false;
      that.GanttVar.taskStore.remove(task);
      that.GanttVar.project.stm.autoRecord = true;
      //this.isLoaded = true;
      this.showDeletePopup = false;
      var deleteId;
      if (task._data.type == "Task") {
        deleteId = task._data.id;
      } else if (task._data.type == "Phase") {
        deleteId = task._data.name;
      } else if (task._data.type == "Project") {
        deleteId = this.scheduleData.Id;
      }

      that.GanttVar.project.propagate();
      that.GanttVar.refresh();
      deleteTasks({
        taskId: deleteId,
        type: task._data.type,
        ScheduleId: this.scheduleData.Id,
      })
        .then(function (response) {
          console.log(response);
          if (response == "deletedSchedule") {
            location.reload();
          } else {
            // that.gettaskrecords()
          }
        })
        .catch((error) => {
          console.log(error);
          this.isLoaded = false;
        });
    }
  }

  refreshGantt() {
    var that = this;
    getScheduleItemRecords({
      objApi: "buildertek__Project_Task__c",
      scheduleid: this.recordId,
    })
      .then((response) => {
        console.log(response);
        var records = response;
        var data = response.lstOfSObjs;
        this.scheduleItemsDataList = response.lstOfSObjs;
        console.log("test");
        this.scheduleData = response.scheduleObj;
        console.log("test");
        that.storeRes = response.filesandattacmentList;
        console.log("test");
        var scheduleItemsList = [];
        var scheduleItemsListClone = [];
        let scheduleItemsMap = new Map();
        let taskMap = new Map();
        for (var i in data) {
          if (
            data[i].Id != undefined &&
            data[i].buildertek__Milestone__c != undefined &&
            !data[i].buildertek__Milestone__c
          ) {
            scheduleItemsList.push(data[i]);
            // taskMap.set(data[i].buildertek__Phase__c, i);
            taskMap.set(
              data[i].buildertek__Phase__c,
              scheduleItemsList.length - 1
            );
          } else if (
            data[i].Id != undefined &&
            data[i].buildertek__Milestone__c != undefined &&
            data[i].buildertek__Milestone__c
          ) {
            scheduleItemsMap.set(data[i].buildertek__Phase__c, data[i]);
          }
        }
        for (var i = 0; i < scheduleItemsList.length; i++) {
          if (
            scheduleItemsList[i] != undefined &&
            scheduleItemsList[i].Id != undefined
          ) {
            scheduleItemsListClone.push(scheduleItemsList[i]);
            if (
              taskMap.has(scheduleItemsList[i].buildertek__Phase__c) &&
              i == taskMap.get(scheduleItemsList[i].buildertek__Phase__c) &&
              scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c) !=
                undefined
            ) {
              scheduleItemsListClone.push(
                scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c)
              );
              scheduleItemsMap.delete(
                scheduleItemsList[i].buildertek__Phase__c
              );
            }
          }
        }
        for (const [key, value] of scheduleItemsMap.entries()) {
          if (value != undefined) {
            scheduleItemsListClone.push(value);
          }
        }
        // component.set("v.totalPages", Math.ceil(response.getReturnValue().lstOfSObjs.length / component.get("v.pageSize")));
        //component.set("v.allData", scheduleItemsListClone);
        let recordsMap = new Map();
        for (var i in scheduleItemsListClone) {
          if (scheduleItemsListClone[i].buildertek__Phase__c) {
            if (
              !recordsMap.has(scheduleItemsListClone[i].buildertek__Phase__c)
            ) {
              recordsMap.set(
                scheduleItemsListClone[i].buildertek__Phase__c,
                []
              );
            }
            recordsMap
              .get(scheduleItemsListClone[i].buildertek__Phase__c)
              .push(JSON.parse(JSON.stringify(scheduleItemsListClone[i])));
          } else {
            if (!recordsMap.has("null")) {
              recordsMap.set("null", []);
            }
            recordsMap
              .get("null")
              .push(JSON.parse(JSON.stringify(scheduleItemsListClone[i])));
          }
        }
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for (var i in result) {
          var newObj = {};
          newObj["key"] = result[i][0];
          newObj["value"] = result[i][1];
          groupData.push(newObj);
        }
        //console.log(groupData);
        this.scheduleItemsData = groupData;

        if (this.template.querySelector(".container").children.length) {
          this.template.querySelector(".container").innerHTML = "";
          this.template.querySelector(".container1").innerHTML = "";
          this.createGantt();
          /* if(this.GanttVar){
                    this.GanttVar.refresh();
                }else{
                    this.gantt.refresh();
                } */

          //this.GanttVar.crudManager.taskStore.refreshData()
        } else {
          this.createGantt();
          this.isLoaded = false;
        }
      })
      .catch((error) => {
        console.log(error);
        if (error) {
          setTimeout(() => {
            if (error) {
              if (error.message) {
                if (error.message.includes("please check your input data")) {
                  this.gettaskrecords();
                }
              }
            }
          }, 3000);
          //Invalid time axis configuration or filter, please check your input data
        }
        this.isLoaded = false;
      });
  }

  gettaskrecords() {
    this.isLoaded = true;
    //this.getContacts();
    var that = this;

    getScheduleItemRecords({
      objApi: "buildertek__Project_Task__c",
      scheduleid: this.recordId,
    })
      .then((response) => {
        console.log(response);
        var records = response;

        var data = response.lstOfSObjs;
        this.scheduleItemsDataList = response.lstOfSObjs;
        this.scheduleData = response.scheduleObj;
        this.hideuserSchedule = response.hideScheduleFromUser;
        //this.ganttJsonData = response.ganttJSON;
        that.storeRes = response.filesandattacmentList;

        that.projectNameShow = true;
        that.userProfileName = response.profileName;
        var scheduleItemsList = [];
        var scheduleItemsListClone = [];
        let scheduleItemsMap = new Map();
        let taskMap = new Map();
        for (var i in data) {
          if (
            data[i].Id != undefined &&
            data[i].buildertek__Milestone__c != undefined &&
            !data[i].buildertek__Milestone__c
          ) {
            scheduleItemsList.push(data[i]);
            // taskMap.set(data[i].buildertek__Phase__c, i);
            taskMap.set(
              data[i].buildertek__Phase__c,
              scheduleItemsList.length - 1
            );
          } else if (
            data[i].Id != undefined &&
            data[i].buildertek__Milestone__c != undefined &&
            data[i].buildertek__Milestone__c
          ) {
            scheduleItemsMap.set(data[i].buildertek__Phase__c, data[i]);
          }
        }
        for (var i = 0; i < scheduleItemsList.length; i++) {
          if (
            scheduleItemsList[i] != undefined &&
            scheduleItemsList[i].Id != undefined
          ) {
            scheduleItemsListClone.push(scheduleItemsList[i]);
            if (
              taskMap.has(scheduleItemsList[i].buildertek__Phase__c) &&
              i == taskMap.get(scheduleItemsList[i].buildertek__Phase__c) &&
              scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c) !=
                undefined
            ) {
              scheduleItemsListClone.push(
                scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c)
              );
              scheduleItemsMap.delete(
                scheduleItemsList[i].buildertek__Phase__c
              );
            }
          }
        }
        for (const [key, value] of scheduleItemsMap.entries()) {
          if (value != undefined) {
            scheduleItemsListClone.push(value);
          }
        }
        // component.set("v.totalPages", Math.ceil(response.getReturnValue().lstOfSObjs.length / component.get("v.pageSize")));
        //component.set("v.allData", scheduleItemsListClone);
        let recordsMap = new Map();
        for (var i in scheduleItemsListClone) {
          if (scheduleItemsListClone[i].buildertek__Phase__c) {
            if (
              !recordsMap.has(scheduleItemsListClone[i].buildertek__Phase__c)
            ) {
              recordsMap.set(
                scheduleItemsListClone[i].buildertek__Phase__c,
                []
              );
            }
            recordsMap
              .get(scheduleItemsListClone[i].buildertek__Phase__c)
              .push(JSON.parse(JSON.stringify(scheduleItemsListClone[i])));
          } else {
            if (!recordsMap.has("null")) {
              recordsMap.set("null", []);
            }
            recordsMap
              .get("null")
              .push(JSON.parse(JSON.stringify(scheduleItemsListClone[i])));
          }
        }
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for (var i in result) {
          var newObj = {};
          newObj["key"] = result[i][0];
          newObj["value"] = result[i][1];
          groupData.push(newObj);
        }
        //console.log(groupData);
        this.scheduleItemsData = groupData;

        if (this.template.querySelector(".container").children.length) {
          this.template.querySelector(".container").innerHTML = "";
          this.template.querySelector(".container1").innerHTML = "";
          this.createGantt();
          /* if(this.GanttVar){
                this.GanttVar.refresh();
            }else{
                this.gantt.refresh();
            } */

          //this.GanttVar.crudManager.taskStore.refreshData()
        } else {
          this.createGantt();
          this.isLoaded = false;
        }
      })
      .catch((error) => {
        console.log(error);
        if (error) {
          setTimeout(() => {
            if (error) {
              if (error.message) {
                if (error.message.includes("please check your input data")) {
                  this.gettaskrecords();
                }
              }
            }
          }, 3000);
          //Invalid time axis configuration or filter, please check your input data
        }
        this.isLoaded = false;
      });
  }
  openMasterSchedule() {
    const urlWithParameters =
      "/lightning/cmp/buildertek__ImportMasterSchedule?buildertek__RecordId=" +
      this.scheduleData.Id +
      "&buildertek__isFromNewGantt=" +
      true;
    console.log("urlWithParameters..." + urlWithParameters);
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: urlWithParameters,
        },
      },
      false
    );
  }

  openScheduleLines() {
    const urlWithParameters =
      "/lightning/cmp/buildertek__ImportScheduleLines?buildertek__RecordId=" +
      this.scheduleData.Id +
      "&buildertek__isFromNewGantt=" +
      true;
    console.log("urlWithParameters..." + urlWithParameters);
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: urlWithParameters,
        },
      },
      false
    );
  }

  closeUploadModal(event) {
    if (!this.uploadFileNameCheck) {
      this.showpopup = false;
    } else {
      this.isLoaded = false;
      this.uploadFileNameCheck = "";
      event.preventDefault();
      event.stopPropagation();
      this.showpopup = false;
      this.fileTaskId = "";
      this.gettaskrecords();
    }
  }
  inputChange(event) {
    if (event.currentTarget.label == "Name") {
      this.newTaskPopupName = event.currentTarget.value;
    } else if (event.currentTarget.label == "Lag") {
      this.newTaskLag = event.currentTarget.value;
    } else if (event.currentTarget.label == "Duration") {
      this.newTaskDuration = event.currentTarget.value;
    } else if (event.currentTarget.value == "% Completion") {
      this.newTaskCompletion = event.currentTarget.value;
    }
    console.log(event);
  }
  closeEditPopup(event) {
    event.preventDefault();
    event.stopPropagation();
    this.selectedContactApiName = "";
    this.selectedResourceContact = "";
    this.showFileForRecord = "";
    this.showFilePopup = false;
    this.showCommentPopup = false;
    this.schItemComment = "";
    this.isLoaded = false;
    this.predecessorVal = "";
    this.taskPhaseVal = "";
    this.newTaskPopupName = "";
    this.newTaskStartDate = "";
    this.newTaskDuration = "";
    this.newTaskLag = 0;
    this.taskRecordId = "";
    this.newTaskOrder = null;
    this.newTaskCompletion = null;
    this.showEditPopup = false;
    this.showDeletePopup = false;
    this.showEditResourcePopup = false;
    Object.assign(this.newTaskRecordCreate, this.newTaskRecordClone);
  }
  saveeditRecord(event) {
    console.log('saveeditRecord');
    var isSaveNew = false;
    if (event.currentTarget.name == "saveNew") {
      isSaveNew = true;
    }
    var that = this;
    this.isLoaded = true;
    var isNotInsert;
    var schId;
    if (this.scheduleData.Id) {
      schId = this.scheduleData.Id;
    }
    if (this.taskRecordId) {
      this.newTaskRecordCreate.Id = this.taskRecordId;
      isNotInsert = true;
    } else {
      this.newTaskRecordCreate.Id = "";
      isNotInsert = false;
    }
    //that.isLoaded = false
    console.log('this.newTaskRecordCreate.Name',this.newTaskRecordCreate.Name);
    if (this.newTaskRecordCreate.Name) {
      var added;
      console.log(added);

      //this.isLoaded = true
      this.showEditPopup = false;
      console.log("test11", Date.now());
      var temp = this.newTaskRecordCreate;
      console.log("printed temp here ", { temp });
      insertUpdateTask({
        taskFields: JSON.stringify(this.newTaskRecordCreate),
        isUpdate: isNotInsert,
        scheduleId: schId,
      }).then((response) => {
        console.log(response);
        const filterChangeEvent = new CustomEvent("filterchange", {
          detail: { message: "refresh page" },
        });
        that.dispatchEvent(filterChangeEvent);
        that.gettaskrecords();
        console.log("test111", Date.now());
        if (isSaveNew) {
          that.addNewTask();
          that.showEditPopup = true;
        } else {
          Object.assign(that.newTaskRecordCreate, that.newTaskRecordClone);
        }
      });
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Please Enter Schedule Item Name",
          variant: "error",
        })
      );
    }
  }
  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant,
    });
    this.dispatchEvent(event);
  }
  renderedCallback() {
    if (this.bryntumInitialized) {
      return;
    }
    this.bryntumInitialized = true;
    Promise.all([
      loadScript(this, GANTTModule, GanttDup), //GanttDup ,SchedulerPro GANTTModule,GANTT + "/gantt.lwc.module.js"
      loadStyle(this, GANTT + "/gantt.stockholm.css"),
      // /gantt.material.css GANTTStockholm GANTT + "/gantt.stockholm.css" //GANTT + "/gantt.stockholm.css"
    ])
      .then(() => {
        //this.createGantt()
        console.log(this.recordId);
        this.gettaskrecords();
        this.loadedChart = true;
      })
      .catch((error) => {
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error loading Gantt Chart",
            message: error,
            variant: "error",
          })
        );
      });
  }
  createGantt() {
    var GanttToolbar;
    if (
      this.userProfileName != "System Administrator" &&
      this.userProfileName != "Project Coordination"
    ) {
      GanttToolbar = GanttToolbarMixinDup(bryntum.gantt.Toolbar);
    } else {
      GanttToolbar = GanttToolbarMixin(bryntum.gantt.Toolbar);
    }
    //GanttToolbar = GanttToolbarMixin(bryntum.gantt.Toolbar);
    var assignments = {};
    var resources = {};
    var tasks = {};
    var taskDependencyData = [];
    var resourceRowData = [];
    var assignmentRowData = [];
    var rows = [];
    var formatedSchData = formatData(
      this.scheduleData,
      this.scheduleItemsData,
      this.scheduleItemsDataList
    );
    tasks["rows"] = formatedSchData["rows"];
    resources["rows"] = formatedSchData["resourceRowData"];
    assignments["rows"] = formatedSchData["assignmentRowData"];
    taskDependencyData = formatedSchData["taskDependencyData"];
    resourceRowData = formatedSchData["resourceRowData"];
    assignmentRowData = formatedSchData["assignmentRowData"];
    //var parsedGanttData = JSON.parse(this.ganttJsonData);
    //tasks['rows'] = parsedGanttData.

    //var parsedGanttData = JSON.parse(this.ganttJsonData);
    //tasks['rows'] = parsedGanttData.

    const project = new bryntum.gantt.ProjectModel({
      // enableProgressNotifications : true,
      calendar: data.project.calendar,
      // startDate: data.project.startDate,
      tasksData: tasks.rows, //tasks.rows
      dependenciesData: taskDependencyData, //taskDependencyData
      // resourcesData: data.resources.rows,
      // /assignmentsData: data.assignments.rows,
      resourcesData: resourceRowData, //this.showAllContacts,//, //resourceRowData
      assignmentsData: assignmentRowData,
      calendarsData: data.calendars.rows,
      /* calendar: data.project.calendar,
            // startDate: data.project.startDate,
             tasksData: parsedGanttData.tasks.rows,
             dependenciesData: parsedGanttData.dependenciesRows,
            // resourcesData: data.resources.rows,
             // /assignmentsData: data.assignments.rows, 
             resourcesData: parsedGanttData.resourcerows,//this.showAllContacts,//, //resourceRowData
             assignmentsData: parsedGanttData.assignmentrows,
             calendarsData: data.calendars.rows */
    });

    const gantt = new bryntum.gantt.Gantt({
      project,
      appendTo: this.template.querySelector(".container"),
      //startDate: "2019-01-12",
      //endDate: "2019-03-24",
      infiniteScroll: true,
      bufferCoef: 2,
      tbar: new GanttToolbar(),

      viewPreset: "weekAndDayLetter",
      dependencyIdField: "sequenceNumber",
      //dependencyIdField: "wbsCode",
      columns: [
        {
          type: "wbs",
          editor: false,
        },

        {
          type: "action",
          text: "Edit",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-pen",
              onClick: ({ record }) => {
                console.log(record);
                if (record._data.type == "Task") {
                  this.taskRecordId = record._data.id;
                  this.getRecordData(record._data.id, record._data);
                }
              },
              renderer: ({ action, record }) => {
                if (record._data.type == "Task") {
                  return `<i class="b-action-item ${action.cls}" ></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "percentdone",
          showCircle: true,
          width: 70,
          text: "% Done",
          editor: true,
          /* renderer : function(record) {
                       console.log(record)
                        return record.cellElement.innerHTML
                    }, */
        },
        {
          type: "action",
          text: "Complete",
          width: 60,
          actions: [
            {
              cls: "b-fa b-fa-check",
              onClick: ({ record }) => {
                console.log(record);
                if (record._data.type == "Task") {
                  record.set("percentDone", 100);
                }

                console.log(record);
                //console.log(ganttCartData);
                //record._data.percentDone = 100;
                //record.originalData.percentDone = 100;
              },
              renderer: ({ action, record }) => {
                if (record._data.type == "Task") {
                  return `<i class="b-action-item ${action.cls}" ></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "name",
          width: 400,
          editor: true,
          renderer: function (record) {
            console.log(record.record._data.customtype);
            console.log(record.record._data.phase);
            console.log(record.record._data.name, record.record._data.type);
            if (record.record._data.type == "Phase") {
              record.cellElement.style.margin = "";
            }
            if (
              record.record._data.iconCls == "b-fa b-fa-arrow-left indentTrue"
            ) {
              //record.cellElement.style.margin = '0 0 0 1.5rem';
            }

            if (record.record._data.name == "Milestone Complete") {
              return "Milestone";
            } else {
              return record.value;
            }
            /*  if(record.record._data.name == 'Milestone Complete'){
                            record.rowElement.style.background = 'rgb(175, 204, 247)'
                        }else if(record.record._data.customtype == 'Milestone' && record.record._data.customtype != undefined){
                            console.log('test')
                            record.rowElement.style.background = 'rgb(199, 191, 215)'
                            console.log('test')
                        }
                        return record.value; */
          },
        },
        {
          type: "startdate",
          editor: true,
        },
        {
          type: "enddate",
          editor: true,
          renderer: function (record) {
            if (record.rowElement) {
              record.rowElement.draggable = true;
            }
            var endDate;
            var months = [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ];
            if (record.value) {
              if (
                record.record._data.duration >= 1 &&
                record.record._data.type == "Task" &&
                record.record._data.name != "Milestone Complete"
              ) {
                var start;
                var endDate = new Date(record.value);
                // if(record.record._data.startDate){
                /*  var start = new Date(record.record._data.startDate.getTime())
                                    var duration = record.record._data.duration */
                var start = new Date(record.record.startDate.getTime());
                var duration = record.record.duration;
                var eDate = new Date(start);
                var eDatebefore = endDate;
                // newly added
                var eDate2 = new Date(start);

                for (var i = 0; i < duration; i++) {
                  if (i == 0) {
                    eDate2 = new Date(start.setDate(start.getDate() + i));
                  } else {
                    eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 1));
                  }
                  if (new Date(eDate2).getDay() == 0) {
                    eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 1));
                  }
                  if (new Date(eDate2).getDay() == 6) {
                    eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 2));
                  }
                  console.log("custom", eDate2);
                  eDate2 = new Date(eDate2);
                }
                endDate.setDate(endDate.getDate() - 1);
                if (endDate.getTime() <= eDate2.getTime()) {
                  record.value.setMonth(eDate2.getMonth());
                  record.value.setFullYear(eDate2.getFullYear());
                  record.value.setDate(eDate2.getDate() + 1);
                  endDate = new Date(eDate2);
                } else if (endDate.getTime() <= start) {
                  record.value.setMonth(eDate2.getMonth());
                  record.value.setFullYear(eDate2.getFullYear());
                  record.value.setDate(eDate2.getDate() + 1);
                }
                console.log(
                  "testendDate-->",
                  record.record._data.name,
                  record.record._data.duration,
                  endDate
                );

                var eDateafter = endDate;
                console.log("eDateafter --> " + eDateafter);
                console.log(
                  "testendDate-->",
                  record.record._data.duration,
                  endDate
                );
                //console.log(endDate)
                return (
                  months[endDate.getMonth()] +
                  " " +
                  Number(endDate.getDate()) +
                  ", " +
                  endDate.getFullYear()
                );
              } else if (
                record.record._data.duration >= 1 &&
                record.record._data.type != "Task" &&
                record.record._data.name != "Milestone Complete"
              ) {
                endDate = new Date(record.value);
                endDate.setDate(endDate.getDate() - 1);
                endDate = new Date(endDate);
                return (
                  months[endDate.getMonth()] +
                  " " +
                  Number(endDate.getDate()) +
                  ", " +
                  endDate.getFullYear()
                );
              } else if (
                record.record._data.duration > -2 &&
                record.record._data.type == "Task" &&
                record.record._data.name != "Milestone Complete"
              ) {
                endDate = new Date(record.value);
                endDate.setDate(endDate.getDate() - 1);
                endDate = new Date(endDate);
                return (
                  months[endDate.getMonth()] +
                  " " +
                  Number(endDate.getDate()) +
                  ", " +
                  endDate.getFullYear()
                );
              } else {
                //endDate = new Date( new Date(record.value));
                endDate = new Date(record.value);
                /* getEndDate({sDate:record.record._data.startDate,eDate:endDate,duartion: record.record._data.duration}).then(function(response){
                                    console.log(response)
                                    endDate = response;
                                }) */
                //console.log(endDate)
                return (
                  months[endDate.getMonth()] +
                  " " +
                  Number(endDate.getDate()) +
                  ", " +
                  endDate.getFullYear()
                );
              }
            }

            //console.log(record)
          },
        },
        {
          type: "duration",
          width: "5%",
          editor: true,
          renderer: function (record) {
            if (record.value._magnitude > -1) {
              if (record.value._magnitude == 0) {
                return 1;
              } else {
                return record.value._magnitude; //record.value._magnitude ;
              }
            }
          },
        },
        /* { type : 'constrainttype' },
                { type : 'constraintdate' }, */
        /* { 
                    type: "resourceassignment", 
                    width: 120, 
                    text : 'Resources',
                    editor : true,
                    renderer : ({record }) => {
                        console.log(record)
                    }
                }, */
        {
          text: "Internal Resource",
          width: 120,
          editor: false,
          renderer: function (record) {
            if (
              record.record._data.type == "Task" &&
              record.record._data.name != "Milestone Complete"
            ) {
              if (record.record._data.internalresource) {
                record.cellElement.classList.add("b-resourceassignment-cell");
                record.cellElement.innerHTML = `<div class="b-assignment-chipview-wrap">
                                    <div class="b-assignment-chipview b-widget b-list b-chipview b-outer b-visible-scrollbar b-chrome b-no-resizeobserver b-widget-scroller b-hide-scroll" tabindex="0" style="overflow-x: auto;" >
                                        <div class="b-chip" data-index="0" data-isinternalresource="true" > ${record.record._data.internalresourcename}</div>
                                        <i id="editInternalResource" data-resource="${record.record._data.internalresource}" class="b-action-item b-fa b-fa-pen" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;" id="editInternalResource" ></i>
                                        </div>
                                </div>`;
              } else {
                record.cellElement.innerHTML = `
                                <i  class="b-action-item b-fa b-fa-user-plus addinternalresource" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;"  ></i>
                                `;
              }
              //<i class="b-action-item b-fa b-fa-pen" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;" id="editInternalResource" ></i>
            } else {
              record.cellElement.innerHTML = `<span></span>`;
            }
          },
        },
        {
          text: "Contractor Resource",
          width: 120,
          editor: false,
          renderer: function (record) {
            console.log(record);
            if (
              record.record._data.type == "Task" &&
              record.record._data.name != "Milestone Complete"
            ) {
              if (record.record._data.contractorresource) {
                record.cellElement.classList.add("b-resourceassignment-cell");
                record.cellElement.innerHTML = `<div id="" class="b-assignment-chipview-wrap">
                                    <div class="b-assignment-chipview b-widget b-list b-chipview b-outer b-visible-scrollbar b-chrome b-no-resizeobserver b-widget-scroller b-hide-scroll" tabindex="0" style="overflow-x: auto;" >
                                        <div class="b-chip" data-index="0" data-isinternalres="false" > ${record.record._data.contractorresourcename}</div>
                                        <i id="editcontractorResource" data-resource="${record.record._data.contractorresource}" class="b-action-item b-fa b-fa-pen" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;"  ></i>
                                        </div>
                                </div>`;
              } else {
                record.cellElement.innerHTML = `
                                <i  class="b-action-item b-fa b-fa-user-plus addcontractorresource" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;"  ></i>
                                `;
              }
            } else {
              record.cellElement.innerHTML = `<span></span>`;
            }
          },
        },

        {
          type: "action",
          text: "Attach File",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-paperclip",
              onClick: ({ record }) => {
                console.log(record);
                if (record._data.type == "Task") {
                  this.showpopup = true;
                  this.fileTaskId = record._data.id;
                }
              },
              renderer: ({ action, record }) => {
                if (record._data.type == "Task") {
                  return `<i class="b-action-item ${action.cls}" data-btip="Attach"></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" data-btip="Attach" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "action",
          text: "Files",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-file",
              onClick: ({ record }) => {
                console.log(record);
                console.log(gantt.selectedRecords);
                this.showFileForRecord = record._data.id;
                this.showFilePopup = true;
              },
              renderer: ({ action, record }) => {
                console.log(this.storeRes);
                if (record._data.type == "Task") {
                  if (this.storeRes["" + record._data.id]) {
                    if (this.storeRes["" + record._data.id]["fileLength"]) {
                      return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" ></i>`;
                    }
                    return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" ></i>`;
                  }
                  return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" ></i>`;
                  //return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" ></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;font-size:1.1rem;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "action",
          text: "Add",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-plus",
              onClick: ({ record }) => {
                console.log(record);
                console.log(gantt.taskStore.rootNode);
                this.recordTaskParent = record;
                // console.log(gantt.addTask(record))
                //var added = gantt.addTaskBelow(record);
                this.addNewTask(record);
                //console.log(added)
                /* added.then(function(res){
                                gantt.editTask(res);
                                console.log(res)
                            }); */
                //gantt.editTask(added);
                /*  */
                //var added = gantt.taskStore.rootNode.appendChild({ name : 'New task', duration : 1 });
                //gantt.editTask(added);
                //gantt.editTask(record);
                /*record.set('percentDone',100);
                            console.log(record);
                            ganttCartData = record.stores[0].storage._values;
                            console.log(ganttCartData);*/
                //record._data.percentDone = 100;
                //record.originalData.percentDone = 100;
              },
            },
          ],
        },
        {
          type: "action",
          text: "Go to Item",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-external-link-alt",
              onClick: ({ record }) => {
                console.log(record);
                this.navigateToRecordViewPage(record._data.id);
              },
              renderer: ({ action, record }) => {
                if (record._data.type == "Task") {
                  return `<i class="b-action-item ${action.cls}" data-btip="Go To Item"></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" data-btip="Go To Item" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "action",
          text: "Delete",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-trash",
              onClick: ({ record }) => {
                console.log(record);
                console.log(gantt.selectedRecords);
                this.readyTodeleteTask = record;
                this.showDeletePopup = true;
                //gantt.taskStore.remove(record);
              },
            },
          ],
        },
        {
          type: "action",
          text: "Comment",
          width: 50,
          actions: [
            {
              cls: "b-fa b-fa-comment-alt",
              onClick: ({ record }) => {
                console.log(record);
                console.log(gantt.selectedRecords);
                this.taskRecordId = record._data.id;
                this.getComment();
                //this.schItemComment = record._data.notes;
              },
              renderer: ({ action, record }) => {
                if (record._data.type == "Task") {
                  if (this.storeRes["" + record._data.id]) {
                    if (this.storeRes["" + record._data.id]["notesLength"]) {
                      return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" ></i>`;
                    }
                    return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" ></i>`;
                  }
                  return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" ></i>`;
                  //return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" ></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;font-size:1.1rem;"></i>`;
                }
              },
            },
          ],
        },
      ],
      subGridConfigs: {
        locked: {
          flex: 6,
        },
        normal: {
          flex: 4,
        },
      },
      columnLines: false,
      /* project : {
                enableProgressNotifications : true,
                calendar: data.project.calendar,
                taskStore                   : { useRawData : true },
                dependencyStore             : { useRawData : true },
                resourceStore : { useRawData : true },
                assignmentStore : { useRawData : true },
                calendarsData: data.calendars.rows
            },
            async generateDataset() {
                gantt.taskStore.data =  tasks.rows;//tasks.rows
                gantt.dependencyStore.data = taskDependencyData;
                gantt.resourceStore.data = resourceRowData;//this.showAllContacts,//, //resourceRowData
                gantt.assignmentStore.data = assignmentRowData;
                gantt.project.calendarManagerStore.data = data.calendars.rows
                gantt.project['calendar'] = data.project.calendar
            }, */
      features: {
        /* taskTooltip : {
                    template(data) {
                        const
                            me             = this,
                            { taskRecord } = data;
        
                        // Return the result of the feature's default template, with custom markup appended
                        return TaskTooltip.defaultConfig.template.call(me, data) 
                    }
                }, */
        rowReorder: {
          disabled: true,
          listeners: {},
        },
        dependencies: true,
        rollups: {
          disabled: true,
        },
        baselines: {
          disabled: true,
        },
        progressLine: {
          disabled: true,
          statusDate: new Date(2019, 0, 25),
        },
        filter: true,
        dependencyEdit: true,
        timeRanges: {
          showCurrentTimeLine: true,
        },
        labels: {
          left: {
            field: "name",
            editor: {
              type: "textfield",
            },
          },
        },
        taskMenu: {
          items: {
            editTask: false,
            deleteTask: false,
            indent: false,
            outdent: false,
          },
        },
        taskEdit: {
          items: {
            generalTab: {
              items: {
                // Remove "% Complete","Effort", and the divider in the "General" tab
                effort: false,
                generalTab: {
                  endDate: {
                    label: "End",
                    weight: "100",
                  },
                  bbar: {
                    items: {
                      deleteButton: false,
                    },
                  },
                },

                // divider     : false
              },
            },
            // Remove all tabs except the "General" tab
            /* notesTab        : false,
                        predecessorsTab : false,
                        successorsTab   : false,
                        resourcesTab    : false, */
            //advancedTab     : true
          },
        },
      },
      listeners: {
        beforeCellEditStart: ({ editorContext }) => {
          if (
            editorContext.column.field !== "percentDone" ||
            editorContext.record.isLeaf
          ) {
            if (editorContext.column.field == "endDate") {
              console.log(editorContext);
              var StartString =
                editorContext.record._data.startDate.getFullYear() +
                "-" +
                Number(editorContext.record._data.startDate.getMonth() + 1) +
                "-" +
                editorContext.record._data.startDate.getDate();
              var that = this;
              console.log(editorContext.value);
              var start = new Date(
                editorContext.record._data.startDate.getTime()
              );
              var duration = editorContext.record._data.duration;
              var eDate = new Date(start);
              for (var i = 0; i < duration; i++) {
                if (i == 0) {
                  eDate = new Date(start.setDate(start.getDate() + i));
                } else {
                  eDate = new Date(eDate.setDate(eDate.getDate() + 1));
                }
                //eDate = eDate.setDate(eDate.getDate() + 1)
                if (new Date(eDate).getDay() == 0) {
                  eDate = new Date(eDate.setDate(eDate.getDate() + 1));
                }
                if (new Date(eDate).getDay() == 6) {
                  eDate = new Date(eDate.setDate(eDate.getDate() + 2));
                }
                console.log("custom", eDate);
                eDate = new Date(eDate);
              }

              editorContext.value.setDate(eDate.getDate());
              editorContext.value.setMonth(eDate.getMonth());
              editorContext.value.setFullYear(eDate.getFullYear());

              console.log(editorContext.cell.innerHTML);
              //editorContext.value = new Date(2021,6,31)
              /* getEndDate({sDate:record.record._data.startDate,eDate:endDate,duartion: record.record._data.duration}).then(function(response){
                                console.log(response)
                                endDate = response;
                            })
                            editorContext.value.setDate(editorContext.value.getDate()-1) */
            }

            if (editorContext.column.field == "fullDuration") {
              /* setTimeout(() =>  {
                                if(this.template.querySelector(".b-cell-editor")){
                                    if(source._selectedRecordCollection._values[0]){
                                        if(source._selectedRecordCollection._values[0].name == 'Milestone Complete'){
                                            this.template.querySelector(".b-cell-editor").getElementsByTagName('input')[0].value = 1
                                        }
                                    }
                                    
                                }
                            },250) */
            }
          }
        },
        celldblclick: ({ source }) => {
          console.log(source);
        },
        cellClick: ({ source }) => {
          console.log(source);
        },
        finishCellEdit: ({ editorContext }) => {
          console.log(editorContext);
        },
        beforeFinishCellEdit: ({ editorContext }) => {
          if (
            editorContext.column.field !== "percentDone" ||
            editorContext.record.isLeaf
          ) {
            if (editorContext.column.field == "endDate") {
              console.log(editorContext);
              var StartString =
                editorContext.record._data.startDate.getFullYear() +
                "-" +
                Number(editorContext.record._data.startDate.getMonth() + 1) +
                "-" +
                editorContext.record._data.startDate.getDate();
              var endString =
                editorContext.value.getFullYear() +
                "-" +
                Number(editorContext.value.getMonth() + 1) +
                "-" +
                editorContext.value.getDate();
              console.log(this.template.querySelector(".b-cell-editor"));

              if (this.template.querySelector(".b-cell-editor")) {
                console.log(editorContext.value);
                console.log(
                  this.template
                    .querySelector(".b-cell-editor")
                    .getElementsByTagName("input")[0].value
                );
                var dateStringVal = this.template
                  .querySelector(".b-cell-editor")
                  .getElementsByTagName("input")[0].value;
                //Oct 8, 2021 sample value
                var months = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec",
                ];
                var endDateYearVal = dateStringVal.split(", ")[1];
                var endDateMonthVal = months.indexOf(
                  dateStringVal.split(", ")[0].split(" ")[0]
                );
                var endDateDateVal = dateStringVal.split(", ")[0].split(" ")[1];

                var dt = new Date(
                  endDateYearVal,
                  endDateMonthVal,
                  endDateDateVal
                );
                //editorContext.value = dt
                editorContext.value.setDate(dt.getDate());
                editorContext.value.setMonth(dt.getMonth());
                editorContext.value.setFullYear(dt.getFullYear());
                console.log(dt);
                var duration = 0;
                const date1 = new Date(editorContext.record._data.startDate);
                const date2 = new Date(dt);
                const diffTime = Math.abs(date2 - date1);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                console.log(diffTime + " milliseconds");
                console.log(diffDays + " days");
                var stDate = new Date(date1);

                for (var i = 0; i <= diffDays; i++) {
                  if (i == 0) {
                    stDate.setDate(stDate.getDate() + i);
                  } else {
                    stDate.setDate(stDate.getDate() + 1);
                  }

                  if (
                    new Date(stDate).getDay() != 0 &&
                    new Date(stDate).getDay() != 6
                  ) {
                    duration = duration + 1;
                  }
                }
                if (duration) {
                  editorContext.record.set("duration", duration);
                  // editorContext.record._data.duration = duration
                  this.foucsedCellId = editorContext.record._data.id;
                  //editorContext.record.set('duration',duration);
                }
                //this.GanttVar.refresh()
              }
            }
          }
        },
        beforerendertask: ({ source }) => {
          if (this.GanttVar) {
            if (this.GanttVar.subGrids) {
              if (
                this.GanttVar.subGrids["normal"].collapsed == true ||
                this.GanttVar.subGrids["normal"].collapsed == false
              ) {
                this.hideSchedule = this.GanttVar.subGrids["normal"].collapsed;
              }
            }
          }

          console.log("test", source);
          if (source._focusedCell) {
            /* if(source._focusedCell.columnId.indexOf('name') > -1){
                            if(this.template.querySelector(".b-cell-editor")){
                                if(source._selectedRecordCollection._values[0]){
                                    if(source._selectedRecordCollection._values[0].name == 'Milestone Complete'){
                                        this.template.querySelector(".b-cell-editor").getElementsByTagName('input')[0].value = 'Milestone'
                                    }
                                }
                                
                            }
                        } */

            if (source._focusedCell.columnId.indexOf("endDate") > -1) {
              console.log(source._focusedCell.element.innerText);
              console.log(source._selectedCell.element.innerText);
              //console.log(editorContext.value)
              if (this.template.querySelector(".b-cell-editor")) {
                console.log(
                  this.template
                    .querySelector(".b-cell-editor")
                    .getElementsByTagName("input")[0].value
                );
                //var dateStringVal = source._selectedCell.element.innerText
                var dateStringVal = this.template
                  .querySelector(".b-cell-editor")
                  .getElementsByTagName("input")[0].value;
                //Oct 8, 2021 sample value
                var months = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec",
                ];
                var endDateYearVal = dateStringVal.split(", ")[1];
                var endDateMonthVal = months.indexOf(
                  dateStringVal.split(", ")[0].split(" ")[0]
                );
                var endDateDateVal = dateStringVal.split(", ")[0].split(" ")[1];

                var dt = new Date(
                  endDateYearVal,
                  endDateMonthVal,
                  endDateDateVal
                );
                //editorContext.value = dt
                source._selectedRecordCollection._values[0].set("endDate", dt);
                console.log(dt);
                var duration = 0;
                const date1 = new Date(
                  source._selectedRecordCollection._values[0]._data.startDate
                );
                const date2 = new Date(dt);
                const diffTime = Math.abs(date2 - date1);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                console.log(diffTime + " milliseconds");
                console.log(diffDays + " days");
                var stDate = new Date(date1);

                for (var i = 0; i <= diffDays; i++) {
                  if (i == 0) {
                    stDate.setDate(stDate.getDate() + i);
                  } else {
                    stDate.setDate(stDate.getDate() + 1);
                  }

                  if (
                    new Date(stDate).getDay() != 0 &&
                    new Date(stDate).getDay() != 6
                  ) {
                    duration = duration + 1;
                  }
                }
                //this.foucsedCellId  = source._selectedRecordCollection._values[0]._data.id
                if (duration) {
                  //editorContext.record._data.duration
                  // source._selectedRecordCollection._values[0]._data.duration = duration;
                  // source._selectedRecordCollection._values[0].set('duration',duration);
                }
              }

              //this.GanttVar.refresh()
            } else if (
              source._focusedCell.columnId.indexOf("fullDuration") > -1
            ) {
            }
          }
        },
        /* catchAll : ({source}) => {
                    console.log(source)
                }, */
        beforeDestroy: ({ source }) => {
          console.log(source, "destroy");
        },
      },
      taskRenderer({ taskRecord, renderData }) {
        // Return some custom elements, described as DomSync config objects.
        // Please see https://bryntum.com/docs/gantt/#Core/helper/DomHelper#function-createElement-static for more information.
        var a = new Date();
        var dat = new Date(a.getFullYear(), a.getMonth(), a.getDate());
        var recEdate = new Date(taskRecord.endDate);

        if (taskRecord._data.endDate) {
          recEdate = new Date(taskRecord._data.endDate);
          console.log("testEdate", recEdate);
          var start = new Date(taskRecord.startDate.getTime());
          var duration = taskRecord.duration;
          var eDate = new Date(start);
          for (var i = 0; i < duration; i++) {
            if (i == 0) {
              eDate = new Date(start.setDate(start.getDate() + i));
            } else {
              eDate = new Date(eDate.setDate(eDate.getDate() + 1));
            }
            //eDate = eDate.setDate(eDate.getDate() + 1)
            if (new Date(eDate).getDay() == 0) {
              eDate = new Date(eDate.setDate(eDate.getDate() + 1));
            }
            if (new Date(eDate).getDay() == 6) {
              eDate = new Date(eDate.setDate(eDate.getDate() + 2));
            }
            console.log("custom", eDate);
            eDate = new Date(eDate);
          }
          console.log(eDate, dat, "444");
          if (eDate.getTime() < dat.getTime() && taskRecord.percentDone < 100) {
            // if (taskRecord.endDate.getTime() < Date.now() && taskRecord.percentDone < 100) {
            // fade out tasks in the past
            console.log(taskRecord);
            console.log(taskRecord.name);
            console.log(taskRecord.endDate);
            console.log(Date.now());
            renderData.wrapperCls.add("pastdateTextColor");
            renderData.taskRecord.cls.add("pastDueDatesText");
            /* if(!renderData.row.elements.locked.classList.contains('pastDueDatesText')){
                                renderData.row.elements.locked.classList.add('pastDueDatesText')
                                //renderData.taskRecord._data.cls += ' pastDueDatesText'
                                //renderData.row.cls.add('pastDueDatesText')
                                renderData.taskRecord.cls.add('pastDueDatesText')
                            } */
            if (renderData.taskRecord.cls.contains("notpastDueDatesText")) {
              renderData.taskRecord.cls.remove("notpastDueDatesText");
            }

            renderData.style += "background:red;";
          } else {
            if (renderData.taskRecord.cls.contains("pastDueDatesText")) {
              console.log(renderData.taskRecord.cls);
              renderData.taskRecord.cls.add("notpastDueDatesText");
              renderData.taskRecord.cls.remove("pastDueDatesText");
              delete renderData.taskRecord.cls["pastDueDatesText"];
              renderData.row.elements.locked.classList.remove(
                "pastDueDatesText"
              );
            }
          }
        } else {
          console.log(eDate, "5444");
          recEdate.setDate(recEdate.getDate() - 1);
          if (
            taskRecord.endDate &&
            recEdate.getTime() < Date.now() &&
            taskRecord.percentDone < 100
          ) {
            // if (taskRecord.endDate.getTime() < Date.now() && taskRecord.percentDone < 100) {
            // fade out tasks in the past
            console.log(taskRecord);
            console.log(taskRecord.name);
            console.log(taskRecord.endDate);
            console.log(Date.now());
            /* if(!renderData.row.elements.locked.classList.contains('pastDueDatesText')){
                                renderData.row.elements.locked.classList.add('pastDueDatesText')
                                //renderData.taskRecord._data.cls += ' pastDueDatesText'
                                renderData.taskRecord.cls.add('pastDueDatesText')
                            } */
            // renderData.taskRecord.cls.add('pastDueDatesText')
            if (renderData.taskRecord.cls.contains("notpastDueDatesText")) {
              renderData.taskRecord.cls.remove("notpastDueDatesText");
            }
            renderData.wrapperCls.add("pastdateTextColor");
            renderData.style += "background:red;";
          } else {
            if (renderData.taskRecord.cls.contains("pastDueDatesText")) {
              console.log(renderData.taskRecord.cls);
              renderData.taskRecord.cls.remove("pastDueDatesText");
              renderData.taskRecord.cls.add("notpastDueDatesText");
              delete renderData.taskRecord.cls["pastDueDatesText"];
              renderData.row.elements.locked.classList.remove(
                "pastDueDatesText"
              );
            }
          }
        }
      },
    });
    // gantt.generateDataset();
    if (this.template.querySelector(".projectname")) {
      if (this.scheduleData.buildertek__Project__c) {
        this.template
          .querySelector(".projectname")
          .getElementsByTagName("h1")[0].innerHTML =
          `Project - <a href='/` +
          this.scheduleData.buildertek__Project__c +
          `' style='color:white;'>` +
          this.scheduleData.buildertek__Project__r.Name +
          `</a>`;
      } else {
        this.template
          .querySelector(".projectname")
          .getElementsByTagName("h1")[0].innerText = "Project - ";
      }
    }

    if (this.GanttVar) {
      this.hideSchedule = this.GanttVar.subGrids.normal.collapsed;
    }

    this.GanttVar = gantt;

    if (this.loadedChart) {
      this.hideSchedule = this.hideuserSchedule;
      this.loadedChart = false;
    }

    //gantt.refresh();
    gantt.callGanttComponent = this;
    gantt.addListener("cellClick", (event) => {
      console.log(event);
      if (event.target.classList.contains("b-fa-arrow-right")) {
        event.record._data["iconCls"] = "b-fa b-fa-arrow-left indentTrue";
        event.record._data["indentVal"] = true;
        event.target.classList.remove("b-fa-arrow-right");

        if (!event.target.classList.contains("b-fa-arrow-left")) {
          event.target.classList.add("b-fa-arrow-left");
          event.target.classList.add("indentTrue");
        }
      } else if (event.target.classList.contains("b-fa-arrow-left")) {
        event.record._data["indentVal"] = false;

        event.target.classList.remove("b-fa-arrow-left");
        event.target.classList.remove("indentTrue");
        event.record._data["iconCls"] = "b-fa b-fa-arrow-right";
        if (!event.target.classList.contains("b-fa-arrow-right")) {
          event.target.classList.add("b-fa-arrow-right");
        }
      } else if (
        event.record._data.startDate &&
        !event.target.classList.contains("b-sch-timeaxis-cell")
      ) {
        this.GanttVar.scrollToDate(event.record._data.startDate, {
          block: "center",
          animate: 500,
        });
      }
      if (event.column.data.text == "Internal Resource") {
        if (event.target.id == "editInternalResource") {
          if (event.target.dataset.resource) {
            this.taskRecordId = event.record._data.id;
            this.showEditResourcePopup = true;
            this.selectedContactApiName = "buildertek__Resource__c";
            this.selectedResourceContact = event.record._data.internalresource;
          }
        } else if (event.target.classList.contains("addinternalresource")) {
          this.taskRecordId = event.record._data.id;
          this.showEditResourcePopup = true;
          this.selectedContactApiName = "buildertek__Resource__c";
          this.selectedResourceContact = "";
        }
      }
      if (event.column.data.text == "Contractor Resource") {
        if (event.target.id == "editcontractorResource") {
          console.log(event.target.classList.contains("addcontractorresource"));
          if (event.target.dataset.resource) {
            this.taskRecordId = event.record._data.id;
            this.showEditResourcePopup = true;
            this.selectedContactApiName = "buildertek__Contractor_Resource__c";
            this.selectedResourceContact =
              event.record._data.contractorresource;
          }
        } else if (event.target.classList.contains("addcontractorresource")) {
          console.log("test");
          this.taskRecordId = event.record._data.id;
          this.showEditResourcePopup = true;
          this.selectedContactApiName = "buildertek__Contractor_Resource__c";
          this.selectedResourceContact = "";
        }
      }
    });

    gantt.on("save", (source) => {
      console.log(source);
    });
    /* 
        gantt.on('expandnode', (source) => {
            //updating icons class on expand click 
               console.log(source);
                
        }); */
    /* const scheduler = new bryntum.gantt.SchedulerPro({
            project,
        
            appendTo            : this.template.querySelector(".container1"),
            minHeight           : '20em',
            position            : 'relative',
            top                 : '-0.5em',
            flex                : 1,
            partner             : gantt,
            rowHeight           : 45,
            eventColor          : 'gantt-green',
            useInitialAnimation : false,
            subGridConfigs: {
                locked: {
                    flex: 4
                },
                normal: {
                    flex: 4,
                }
            },
            features : {
                scheduleContextMenuFeature: false,
                HeaderContextMenu: false,
                dependencies : true,
                percentBar   : true,
                deleteTask: false,
                taskEdit : {
                    editorConfig : {
                        bbar : {
                            items : {
                                deleteButton : false
                            }
                        }
                    }
                }
                
            },
        
            columns : [
                {
                    type           : 'resourceInfo',
                    field          : 'name',
                    text           : 'Resource',
                    showEventCount : false,
                    width          : 330,
                    editor         : false
                },
                {
                    text     : 'Assigned tasks',
                    field    : 'events.length',
                    width    : 160,
                    editor   : false,
                    align    : 'right',
                    editor         : false,
                    renderer : ({ value }) => `${value} task${value !== 1 ? 's' : ''}`
                },
                {
                    text     : 'Assigned work days',
                    width    : 160,
                    editor   : false,
                    align    : 'right',
                    editor         : false,
                    renderer : ({ record }) => record.events.map(task => task.duration).reduce((total, current) => {
                        return total + current;
                    }, 0) + ' days'
                }
            ],
           /*  project : {
                enableProgressNotifications : true,
                calendar: data.project.calendar,
                taskStore                   : { useRawData : true },
                dependencyStore             : { useRawData : true },
                resourceStore : { useRawData : true },
                assignmentStore : { useRawData : true },
                calendarsData: data.calendars.rows
            }, */
    /* async generateDataset() {
                scheduler.taskStore.data =  tasks.rows;//tasks.rows
                scheduler.dependencyStore.data = taskDependencyData;
                 scheduler.resourceStore.data = resourceRowData;//this.showAllContacts,//, //resourceRowData
                 scheduler.assignmentStore.data = assignmentRowData;
                 scheduler.project.calendarManagerStore.data = data.calendars.rows
                 scheduler.project['calendar'] = data.project.calendar
        
            }, */
    /*});
        //scheduler.generateDataset();
        this.schedulerVar = scheduler; */
    project.commitAsync().then(() => {
      // console.timeEnd("load data");
      const stm = gantt.project.stm;

      stm.enable();
      stm.autoRecord = true;

      // let's track scheduling conflicts happened
      project.on("schedulingconflict", (context) => {
        // show notification to user
        bryntum.gantt.Toast.show(
          "Scheduling conflict has happened ..recent changes were reverted"
        );
        // as the conflict resolution approach let's simply cancel the changes
        context.continueWithResolutionResult(
          bryntum.gantt.EffectResolutionResult.Cancel
        );
      });
    });
    setTimeout(() => {
      this.isLoaded = false;
    }, 800);
    setTimeout(() => {
      var ele = this.template.querySelectorAll(".b-grid-row");
      for (let i = 0; i < ele.length; i++) {
        ele[i].addEventListener("dragstart", function (eve) {
          eve.dataTransfer.setData("text", eve.target.getAttribute("data-id"));
        });
      }
      //console.log(this.userProfileName)
      if (
        this.userProfileName != "System Administrator" &&
        this.userProfileName != "Project Coordination"
      ) {
        if (this.template.querySelector(".importMasterBtn")) {
          this.template.querySelector(".importMasterBtn").className +=
            " hideBtn";
        }
        if (this.template.querySelector(".importScheduleLinesBtn")) {
          this.template.querySelector(".importScheduleLinesBtn").className +=
            " hideBtn";
        }
      }
    }, 1000);
  }
}