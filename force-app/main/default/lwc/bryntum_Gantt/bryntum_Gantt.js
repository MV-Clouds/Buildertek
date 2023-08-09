/* globals bryntum : true */
import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
//import  GanttDup  from "@salesforce/resourceUrl/bryntumScheduleProModuleJS";
//import  GanttStyle  from "@salesforce/resourceUrl/Bt_BryntumNewGanttCss";
import GanttStyle from "@salesforce/resourceUrl/BT_Bryntum_NewGanttCss";
//import GANTT from "@salesforce/resourceUrl/bryntum_gantt";
import GANTTModule from "@salesforce/resourceUrl/BT_Bryntum_NewGantt_ModuleJS";
// import GANTTModule from "@salesforce/resourceUrl/BT_Bryntum_NewGantt_ModuleJS_2";
//import  SchedulerPro  from "@salesforce/resourceUrl/bryntumScheduleProModuleJS";
import GanttToolbarMixin from "./lib/GanttToolbar";
import GanttToolbarMixinDup from "./lib/GanttToolbarDup";
import data from "./data/launch-saas";
import getScheduleItemRecords from "@salesforce/apex/BT_NewGanttChartCls.getScheduleItemRecords";
import getPhaseDates from "@salesforce/apex/BT_NewGanttChartCls.getPhaseDates";
// import insertUpdateTask from "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask";
import insertUpdateTaskList from "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTaskList";
import deleteTasks from "@salesforce/apex/BT_NewGanttChartCls.deleteTasks";
import getTask from "@salesforce/apex/BT_NewGanttChartCls.getTask";
import getEndDate from "@salesforce/apex/BT_NewGanttChartCls.getEndDate";
import getAllContacts from "@salesforce/apex/BT_NewGanttChartCls.getAllContacts";
import pickListValueDynamically from "@salesforce/apex/BT_NewGanttChartCls.pickListValueDynamically";
import addNotesCommentToRecord from "@salesforce/apex/BT_NewGanttChartCls.addNotesCommentToRecord";
// import getNotesofRecord from "@salesforce/apex/BT_NewGanttChartCls.getNotesofRecord";
import getAllNotes from "@salesforce/apex/BT_NewGanttChartCls.getAllNotes";
// import getattachmentLength from "@salesforce/apex/BT_NewGanttChartCls.getattachmentLength";
import saveResourceForRecord from "@salesforce/apex/BT_NewGanttChartCls.saveResourceForRecord";
import updateHideGanttOnSch from "@salesforce/apex/BT_NewGanttChartCls.updateHideGanttOnSch";
import changeOriginalDates from "@salesforce/apex/BT_NewGanttChartCls.changeOriginalDates";

import setWBSValue from "@salesforce/apex/BT_NewGanttChartCls.setWBSValue";

import PARSER from "@salesforce/resourceUrl/PapaParse";

import { formatData, saveeditRecordMethod } from "./bryntum_GanttHelper";

import getRecordType from "@salesforce/apex/BT_NewGanttChartCls.getRecordType";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";

export default class Gantt_component extends NavigationMixin(LightningElement) {

  @track wpsValue = {};
  @track wpsBoolean = false;

  @api showpopup = false;
  @api holidays = [];
  @api monthsval = [];
  @api fileTaskId = "";
  @api showDeletePopup = false;
  @api showEditPopup = false;
  @api showIframe = false;
  @api isLoaded = false;
  @api recordId;
  @api taskRecordId;
  @api objApiName = "buildertek__Project_Task__c";
  @track scheduleItemsData;

  //VARIABLE ADDED TO GET PHASE DATES - 09/10
  @api phaseDates = [];
  @api mapOfWBSValue;

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
  @api
  selectedResource;
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
  @api isTabClosed;
  @api contractorResourceFilterVal = "";
  @api internalResourceFilterVal = "";
  @api getFiredFromAura() {
    this.refreshGantt();
  }
  @api plusChildRecord = [];
  @api addedTaskNumberCustom = 0;
  @api isrenderFromSaveorInsert = false;
  //@api saveSelectedContact;
  //@api saveSelectedContactApiName;

  //Added for contractor
  @api showContractor = false;
  @api selectedResourceAccount;
  @track contracFieldApiName;
  @track contractorname;
  @track showOriginalDateModal = false;
  @track blankPredecessor = false;

  //New Toast message
  @track showToast = true;
  @track isrowchange = false;

  // show export popup
  @track showExportPopup = false;
  @track fileName = "gantt-chart";

  @wire(getRecordType) objRecordType;


  @wire(pickListValueDynamically, {
    customObjInfo: {
      sobjectType: "buildertek__Project_Task__c",
    },
    selectPicklistApi: "buildertek__Phase__c",
  })
  selectTargetValues;

  @wire(pickListValueDynamically, {
    customObjInfo: {
      sobjectType: "buildertek__Project_Task__c",
    },
    selectPicklistApi: "buildertek__Type__c",
  })
  selectTargetTypeValues;

  @wire(getPicklistValues, {
    recordTypeId: "$objRecordType.data",
    fieldApiName: "buildertek__Project_Task__c.buildertek__Phase__c",
  })
  picklistValues;

  selectOptionChanveValue(event) {
    this.picklistVal = event.target.value;
    this.newTaskRecordCreate["buildertek__Phase__c"] = event.target.value;
  }
  selectOptionChanveTypeValue(event) {
    this.picklistVal = event.target.value;
    this.newTaskRecordCreate["buildertek__Type__c"] = event.target.value;
  }

  errorCallback(error, stack) {}

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg", ".csv", ".docx", ".doc"];
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

  updateValOnSch(hideScheduleVal) {}
  updateValOnUser(hideScheduleVal) {
    var thatThis = this;
    updateHideGanttOnSch({
      hideGantt: hideScheduleVal,
    }).then((response) => {
      thatThis.hideScheduleFromUser = response.buildertek__Hide_Schedule__c;
    });
  }

  getComment() {
    var that = this;
    this.isLoaded = true;
    getAllNotes({
      schId: this.taskRecordId,
    })
      .then(function (response) {
        that.notesList = response;
        that.schItemComment = response.buildertek__Notes__c;
        that.isLoaded = false;
        that.showCommentPopup = true;
      })
      .catch(function (error) {
        that.isLoaded = false;
      });
  }

  commentValueChange(event) {
    var idx = event.currentTarget.dataset.index;
    this.newNotesList[idx]["TextPreview"] = event.target.value;
    this.showCommentPopup = true;
  }
  viewNotes(event) {
    this.addCommentHeader = "Comment";
    var noteIndex = event.currentTarget.dataset.index;
    var textPreview = this.notesList[noteIndex].TextPreview;
    this.schItemComment = textPreview;
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
      if (!newNotes.length) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Warning",
            message: "No comments to save",
            variant: "warning",
          })
        );
      }
      for (var i = 0; i < newNotes.length; i++) {
        var newCommentTask = {
          sObjectType: "ContentNote",
          TextPreview: newNotes[i]["TextPreview"],
          Title: newNotes[i]["Title"],
        };
        if (newNotes[i]["TextPreview"].trim()) {
          commentList.push(newCommentTask);
        }
      }
      if (commentList.length) {
        addNotesCommentToRecord({
          schItem: this.taskRecordId,
          notes: commentList,
        })
          .then(function (response) {
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
            }
          })
          .catch(function (error) {
            that.saveCommentSpinner = false;
            that.isLoaded = false;
            that.newNotesList = [];
          });
      } else {
        this.saveCommentSpinner = false;
        this.isLoaded = false;
        if (newNotes.length > 0) {
          that.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: "Please enter some text to save comment",
              variant: "warning",
            })
          );
        }
      }
    }
  }

  handleAccountSelection(event) {
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
    this.selectedResourceContact = event.detail.Id;
  }
  handleaccountSelectionContractor(event) {
    this.selectedResourceAccount = event.detail.Id;
    this.contracFieldApiName = event.detail.fieldNameapi;
    this.contractorname = event.target.value;
  }
  saveSelectedContact() {
    var that = this;
    console.log("checking method*&");
    if (!this.taskRecordId.includes("_generated")) {
      console.log("^ other side condition ^");
      //Added for contractor ****Start****
      if (this.contracFieldApiName === "buildertek__Contractor__c") {
        console.log("^ In If ^");
        that.showContractor = false; //Added for contractor
        this.isLoaded = true;

        saveResourceForRecord({
          taskId: this.taskRecordId,
          resourceId: this.selectedResourceAccount,
          resourceApiName: this.contracFieldApiName,
        }).then(function (response) {
          const filterChangeEvent = new CustomEvent("filterchange", {
            detail: {
              message: "refresh page",
            },
          });
          that.dispatchEvent(filterChangeEvent);
          that.gettaskrecords();
          that.showEditResourcePopup = false;
        });
        that.contracFieldApiName = "";
      }
      //Added for contractor ****End****
      else {
        console.log("^ In else ^");
        that.showEditResourcePopup = false;
        this.isLoaded = true;

        saveResourceForRecord({
          taskId: this.taskRecordId,
          resourceId: this.selectedResourceContact,
          resourceApiName: this.selectedContactApiName,
        }).then(function (response) {
          const filterChangeEvent = new CustomEvent("filterchange", {
            detail: {
              message: "refresh page",
            },
          });
          that.dispatchEvent(filterChangeEvent);
          that.gettaskrecords();
        });
      }
    }
  }

  changeInputVal(e) {
    if (e.currentTarget.dataset.inputname == "buildertek__Dependency__c") {
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        this.template.querySelectorAll("lightning-input-field")[1].value;
      console.log(
        "NAME___>this.newTaskRecordCreate===>",
        this.newTaskRecordCreate
      );
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

        var duration = Number(
          this.newTaskRecordCreate["buildertek__Duration__c"]
        );
        if (duration) {
          endDate = new Date(stDate.setDate(stDate.getDate() + (duration - 1)));
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
              try {
                if (
                  thatThis.template.querySelectorAll("lightning-input")[3].label == "End Date"
                ) {
                  thatThis.template.querySelectorAll("lightning-input")[3].value =
                    thatThis.newTaskRecordCreate["buildertek__Finish__c"];
                }
              } catch (error) {
                console.log('log one error:- '+error);
              }
            }
          });
        }
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
        var duration = Number(e.target.value);
        if (duration) {
          endDate = new Date(stDate.setDate(stDate.getDate() + (duration - 1)));
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
            sDate: this.newTaskRecordCreate["buildertek__Start__c"],
            eDate: this.newTaskRecordCreate["buildertek__Finish__c"],
            duration: duration,
          }).then(function (response) {
            var newTaskeDate = response; //.toLocaleDateString().split('/');
            thatThis.newTaskRecordCreate["buildertek__Finish__c"] =
              newTaskeDate; // newTaskeDate[2]+'-'+newTaskeDate[1]+'-'+newTaskeDate[0];
              console.log('log 2.');
            if (
              thatThis.template.querySelectorAll("lightning-input")[3].label == "End Date"
            ) {
              thatThis.template.querySelectorAll("lightning-input")[3].value =
                thatThis.newTaskRecordCreate["buildertek__Finish__c"];
            }
          });
        } else if (!duration) {
          this.newTaskRecordCreate["buildertek__Duration__c"] = 1;
        }
      }

      console.log(">>>>this.newTaskRecordCreate===>", this.newTaskRecordCreate);
      this.newTaskRecordCreate[e.currentTarget.dataset.inputname] =
        e.target.value;
    }
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
      getTask({
        taskId: recID,
      })
        .then(function (response) {
          try {
            if (response.buildertek__Dependency__c == undefined) {
              recThis.blankPredecessor = true;
            } else {
              recThis.blankPredecessor = false;
            }
          } catch (error) {
            console.log("Error ==> ", {
              error,
            });
          }
          recThis.newTaskRecordCreate = response;
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
          if (recData.percentDone != response["buildertek__Completion__c"])
            recThis.newTaskRecordCreate["buildertek__Completion__c"] =
              recData.percentDone;
          recThis.isLoaded = false;
          recThis.showEditPopup = true;
        })
        .catch((error) => {
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
    });
  }

  droprow(e) {
    var taskIdList = this.scheduleItemIdsList;
    var taskList = this.scheduleItemsDataList;
    console.log('takslist droprow:-'+taskList);
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
      });
      if (index1 > index2) {
        var draggingPhase = taskListNew[index1].value;
        var dropPhase = taskListNew[index2].value;
        var dropLen = 0;
        var removeLen = 0;
        for (var i = 0; i < taskListNew.length; i++) {
          if (index1 == i) {
            break;
          } else {
            removeLen += taskListNew[i].value.length;
          }
        }
        for (var i = 0; i < taskListNew.length; i++) {
          if (index2 == i) {
            break;
          } else {
            dropLen += taskListNew[i].value.length;
          }
        }
        var fromatList = this.scheduleItemsDataList;
        temp = fromatList.splice(removeLen, draggingPhase.length);
        for (var i = temp.length - 1; i >= 0; i--) {
          if (index2 == 0) {
            fromatList.splice(index2, 0, temp[i]);
          } else if (index2) {
            fromatList.splice(dropLen, 0, temp[i]);
          }
        }
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
              break;
            } else {
              removeLen += taskListNew[i].value.length;
            }
          }
          for (var i = 0; i < taskListNew.length; i++) {
            if (index2 == i) {
              break;
            } else {
              dropLen += taskListNew[i].value.length;
            }
          }

          var temp = fromatList.splice(
            dropLen,
            taskListNew[index2].value.length
          );
          for (var i = temp.length - 1; i >= 0; i--) {
            fromatList.splice(removeLen, 0, temp[i]);
          }
        }
        this.scheduleItemsDataList = fromatList;
      }
    } else {
      // dragging of task row start
      taskList.forEach((v, i) => {
        if (v.Id == data) index1 = i;
        if (v.Id == tar) index2 = i;
      });
      if (index1 < index2) {
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
        taskList.splice(index2 + 1, 0, taskList[index1]);
        taskList.splice(index1, 1);
      } else if (index1 > index2) {
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
        taskList.splice(index2, 0, temp);
      }
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
    this.scheduleItemsData = groupData;
    this.isLoaded = true;
    if (this.template.querySelector(".container").children.length) {
      this.template.querySelector(".container").innerHTML = "";
      this.template.querySelector(".container1").innerHTML = "";
      this.createGantt();
    } else {
      this.createGantt();
      this.isLoaded = false;
    }
    this.isrowchange = true;
    this.showToast = true;
    this.handleBeforeUnload();
    e.preventDefault();
  }
  allowDrop(e) {
    e.preventDefault();
  }
  ondragrow(e) {}
  callinsertUpdateTaskList(taskData) {
    var that = this;
    this.isLoaded = true;
    console.log(
      "============In method=========================================="
    );
    console.log("taskData", {
      taskData,
    });
    insertUpdateTaskList({
      taskJSON: JSON.stringify(taskData),
      isUpdate: true,
    })
      .then(function (response) {
        const filterChangeEvent = new CustomEvent("filterchange", {
          detail: {
            message: "refresh page",
          },
        });
        that.isLoaded = false;
        that.dispatchEvent(filterChangeEvent);
        window.location.reload();
      })
      .catch((error) => {
        console.log("error --> ", {
          error,
        });
        this.isLoaded = false;
      });
  }
  addNewTask(record) {
    var newTaskeDate;
    var dt;
    Object.assign(this.newTaskRecordCreate, this.newTaskRecordClone);

    if (record) {
      console.log({
        record,
      });
      if (record._data.type == "Task") {
        this.newTaskRecordCreate["buildertek__Dependency__c"] = record._data.id;
        this.newTaskRecordCreate["buildertek__Order__c"] = record._data.order;
      }
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
    this.newTaskRecordCreate["Name"] = "";
    if (record && record._data.endDate && record._data.type == "Task") {
      dt = record._data.endDate;
    } else {
      dt = new Date();
      newTaskeDate = new Date().toLocaleDateString().split("/");
    }
    if (dt.getDay() == 6) {
      dt.setDate(dt.getDate() + 2);
    }
    if (dt.getDay() == 0) {
      dt.setDate(dt.getDate() + 1);
    }
    newTaskeDate = dt.toLocaleDateString().split("/");
    this.newTaskRecordCreate["buildertek__Start__c"] =
      dt.getFullYear() + "-" + Number(dt.getMonth() + 1) + "-" + dt.getDate();
    this.newTaskRecordCreate["buildertek__Duration__c"] = 1;
    this.newTaskRecordCreate["buildertek__Finish__c"] =
      this.newTaskRecordCreate["buildertek__Start__c"];
    this.newTaskRecordCreate["buildertek__Completion__c"] = 0;
    this.newTaskRecordCreate["buildertek__Lag__c"] = 0;
    this.blankPredecessor = false;
  }

  addStandardNew() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "buildertek__Project_Task__c",
        actionName: "new",
      },
    });
  }
  deleteRecord() {
    var task = this.readyTodeleteTask;
    var that = this;
    if (task) {
      that.GanttVar.project.stm.autoRecord = false;
      that.GanttVar.taskStore.remove(task);
      that.GanttVar.project.stm.autoRecord = true;
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
      const evt = new ShowToastEvent({
        title: "Success",
        message:
          task._data.type + " " + task._data.name + " deleted successfully",
        variant: "success",
      });
      that.dispatchEvent(evt);
      if (deleteId.indexOf("_generate") == -1) {
        deleteTasks({
          taskId: deleteId,
          type: task._data.type,
          ScheduleId: this.scheduleData.Id,
        })
          .then(function (response) {
            if (response == "deletedSchedule") {
              location.reload();
            }
          })
          .catch((error) => {
            this.isLoaded = false;
          });
      }
    }
  }

  refreshGantt() {
    // this.phaseFunction();

    console.log("refreshGantt");

    var that = this;
    getScheduleItemRecords({
      objApi: "buildertek__Project_Task__c",
      scheduleid: this.recordId,
    })
      .then((response) => {
        console.log({
          response,
        });
        var records = response;
        var data = response.lstOfSObjs;
        this.scheduleItemsDataList = response.lstOfSObjs;
        this.scheduleData = response.scheduleObj;
        that.storeRes = response.filesandattacmentList;
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
        this.scheduleItemsData = groupData;

        if (this.template.querySelector(".container").children.length) {
          this.template.querySelector(".container").innerHTML = "";
          this.template.querySelector(".container1").innerHTML = "";
          this.createGantt();
        } else {
          this.createGantt();
          this.isLoaded = false;
        }
      })
      .catch((error) => {
        if (error && !this.isTabClosed) {
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
    var that = this;
    getScheduleItemRecords({
      objApi: "buildertek__Project_Task__c",
      scheduleid: this.recordId,
    })
      .then((response) => {
        this.formatCustomResponse(response);
      })
      .catch((error) => {
        if (error && !this.isTabClosed) {
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
  changeFileName(event) {
    this.fileName = event.target.value;
  }
  exportData() {
    this.showExportPopup = true;
    console.log(this.scheduleItemsDataList);
  }

  exportScheduleData() {
    let getColumns = [
      "Name",
      "buildertek__Dependency__r.Name",
      "buildertek__Start__c",
      "buildertek__Finish__c",
      "buildertek__Completion__c",
      "buildertek__Phase__c",
      "buildertek__Notes__c",
      "buildertek__Lag__c",
    ];
    const convertedObject = this.scheduleItemsDataList.map((item) => {
      const obj = {};
      getColumns.forEach((column) => {
        if (item.hasOwnProperty(column)) {
          obj[column] = item[column];
        } else {
          obj[column] = null;
        }

        if (item.hasOwnProperty("buildertek__Dependency__c")) {
          obj["buildertek__Dependency__r.Name"] =
            item.buildertek__Dependency__r.Name;
        } else {
          obj["buildertek__Dependency__r.Name"] = null;
        }
      });
      return obj;
    });

    var csvData = Papa.unparse(convertedObject);
    const element = document.createElement("a");
    element.setAttribute(
      "href",
      "data:text/csv;charset=utf-8," + encodeURIComponent(csvData)
    );
    element.setAttribute("download", this.fileName + ".csv");
    element.style.display = "none";
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
    this.showExportPopup = false;
  }

  hideModalBox() {
    this.showExportPopup = false;
  }

  openScheduleLines() {
    const urlWithParameters =
      "/lightning/cmp/buildertek__ImportScheduleLines?buildertek__RecordId=" +
      this.scheduleData.Id +
      "&buildertek__isFromNewGantt=" +
      true;
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
    console.log('log 3.');
    if (event.currentTarget.label == "Name") {
      this.newTaskPopupName = event.currentTarget.value;
    } else if (event.currentTarget.label == "Lag") {
      this.newTaskLag = event.currentTarget.value;
    } else if (event.currentTarget.label == "Duration") {
      this.newTaskDuration = event.currentTarget.value;
    } else if (event.currentTarget.value == "% Completion") {
      this.newTaskCompletion = event.currentTarget.value;
    }
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
    this.saveCommentSpinner = false;
    this.newNotesList = [];

    this.showContractor = false; //Added for contractor
    Object.assign(this.newTaskRecordCreate, this.newTaskRecordClone);
  }
  saveeditRecord(event) {
    saveeditRecordMethod(event, this);
  }
  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant,
    });
    this.dispatchEvent(event);
  }

  phaseFunction() {
    //CODE ADDED TO GET PHASE DATES - 09-10
    getPhaseDates({
      scheduleId: this.recordId,
    })
      .then((data) => {
        console.log("in the phase data function");
        console.log({
          data,
        });
        var options = [];
        for (var key in data) {
          options.push({
            label: data[key].buildertek__Phase__c,
            value: data[key],
          });
        }
        console.log("==options==");
        console.log({
          options,
        });
        this.phaseDates = options;
        console.log("this.phaseDates-->" + this.phaseDates);
      })
      .catch((error) => {
        console.log({
          error,
        });
      });
  }

  connectedCallback() {
    this.phaseFunction();

    // event ot show toast message
    // window.addEventListener('beforeunload', this.handleBeforeUnload.bind(this));

    const holidayInterval = {
      startDate: new Date(2023, 3, 8), // March 9th
      endDate: new Date(2023, 3, 8), // March 9th
      isWorking: false,
    };

    console.log("Connected Callback");
  }

  renderedCallback() {

    let intervalID = setInterval(() => {

      if (this.bryntumInitialized) {
        return;
      }
      this.bryntumInitialized = true;

      Promise.all([
        loadScript(this, GANTTModule), //GanttDup ,SchedulerPro GANTTModule,GANTT + "/gantt.lwc.module.js"
        //loadStyle(this,  GANTT + "/gantt.stockholm.css")
        //loadStyle(this,  GANTT + "/gantt.stockholm.css")
        loadStyle(this, GanttStyle + "/gantt.stockholm.css"),
        // loadScript(this, Papa.unparse()), // papaparse lib..
        loadScript(this, PARSER + "/PapaParse/papaparse.js"),
      ])
        .then(() => {
          console.log("*******LIBRARY LOADED SUCCESSFULLY******");
          this.gettaskrecords();
          this.loadedChart = true;
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error loading Gantt Chart",
              message: error,
              variant: "error",
            })
          );
        });
      }, 1000);
  }

  //   disconnectedCallback() {
  //     window.removeEventListener('beforeunload', this.handleBeforeUnload.bind(this));
  // }

  populateIcons(record) {
    // console.log('popluate record-->',record);
    if (record.row) {
      if (record.row._allCells.length) {
        if (
          record.record._data.type == "Project" &&
          record.row._allCells[5].innerHTML
        ) {
          var iconElement = `<span class="slds-icon_container slds-icon-custom-custom70" >
                                            <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.2rem;width:1.2rem;">
                                                <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom70">
                                                </use>
                                            </svg>
                                        </span>`;
          if (record.row._allCells[5].children[0]) {
            if (
              record.row._allCells[5].children[0].innerHTML.indexOf(
                "custom70"
              ) == -1
            ) {
              record.row._allCells[5].children[0].innerHTML =
                iconElement + record.row._allCells[5].children[0].innerHTML;
            }
          }
        }
        if (
          record.record._data.type == "Phase" &&
          record.row._allCells[5].innerHTML
        ) {
          var iconElement = `<span class="slds-icon_container slds-icon-standard-task" >
                                            <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.2rem;width:1.2rem;">
                                                <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#task">
                                                </use>
                                            </svg>
                                        </span>`;
          if (record.row._allCells[5].children[0]) {
            if (
              record.row._allCells[5].children[0].innerHTML.indexOf(
                "slds-icon-standard-task"
              ) == -1
            ) {
              record.row._allCells[5].children[0].innerHTML =
                iconElement + record.row._allCells[5].children[0].innerHTML;
            }
          }
        }
        if (
          record.record._data.type == "Task" &&
          record.row._allCells[5].innerHTML
        ) {
          if (
            record.record._data.iconCls == "b-fa b-fa-arrow-left indentTrue" &&
            record.row._allCells[5].children[0].classList.contains(
              "indentCellTrue"
            ) == false
          ) {
            if (record.row._allCells[5].children[0]) {
              record.row._allCells[5].children[0].classList.add(
                "indentCellTrue"
              );
            }
            if (
              record.record._data.name == "Milestone Complete" ||
              record.record._data.customtype == "Milestone"
            ) {
              var iconElement = `<span class="slds-icon_container slds-icon-custom-custom8" style="background:white;">
                                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: #e56798 !important;height:1.2rem;width:1.2rem;">
                                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom8">
                                                        </use>
                                                    </svg>
                                                </span>`;
              if (record.row._allCells[5].children[0]) {
                if (
                  record.row._allCells[5].children[0].innerHTML.indexOf(
                    "slds-icon-utility-multi_select_checkbox"
                  ) == -1
                ) {
                  record.row._allCells[5].children[0].innerHTML =
                    iconElement + record.row._allCells[5].children[0].innerHTML;
                }
              }
            } else {
              var iconElement = `<span class="slds-icon_container slds-icon-utility-multi_select_checkbox" style="background:rgb(1 82 134 / 62%);">
                                                    <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
                                                            width="1.5rem" height="1.4rem" viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve">
                                                    <path fill="#FFFFFF" d="M73,20H41c-3.3,0-6,2.7-6,6v1c0,0.6,0.4,1,1,1h29c3.3,0,6,2.7,6,6v31c0,0.6,0.4,1,1,1h1c3.3,0,6-2.7,6-6V26
                                                        C79,22.7,76.3,20,73,20z"/>
                                                    <path fill="#FFFFFF" d="M59,34H27c-3.3,0-6,2.7-6,6v34c0,3.3,2.7,6,6,6h32c3.3,0,6-2.7,6-6V40C65,36.7,62.3,34,59,34z M56.3,51
                                                        L41,66.3c-0.6,0.6-1.3,0.9-2.1,0.9c-0.7,0-1.5-0.3-2.1-0.9l-7.4-7.4c-0.6-0.6-0.6-1.5,0-2.1l2.1-2.1c0.6-0.6,1.5-0.6,2.1,0l5.3,5.3
                                                        l13.2-13.2c0.6-0.6,1.5-0.6,2.1,0l2.1,2.1C56.8,49.5,56.8,50.5,56.3,51z"/>
                                                    </svg>
                                                </span>`;
              if (record.row._allCells[5].children[0]) {
                if (
                  record.row._allCells[5].children[0].innerHTML.indexOf(
                    "slds-icon-utility-multi_select_checkbox"
                  ) == -1
                ) {
                  record.row._allCells[5].children[0].innerHTML =
                    iconElement + record.row._allCells[5].children[0].innerHTML;
                }
              }
            }
          } else if (
            record.record._data.iconCls != "b-fa b-fa-arrow-left indentTrue"
          ) {
            if (
              record.record._data.name == "Milestone Complete" ||
              record.record._data.customtype == "Milestone"
            ) {
              var iconElement = `<span class="slds-icon_container slds-icon-custom-custom8" style="background:white;">
                                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: #e56798 !important;height:1.2rem;width:1.2rem;">
                                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom8">
                                                        </use>
                                                    </svg>
                                                </span>`;
              if (record.row._allCells[5].children[0]) {
                if (
                  record.row._allCells[5].children[0].innerHTML.indexOf(
                    "slds-icon-custom-custom8"
                  ) == -1
                ) {
                  record.row._allCells[5].children[0].innerHTML =
                    iconElement + record.row._allCells[5].children[0].innerHTML;
                }
              }
            } else {
              var iconElement = `<span class="slds-icon_container slds-icon-standard-task2" style="background:orange;">
                                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.2rem;width:1.2rem;">
                                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#task2">
                                                        </use>
                                                    </svg>
                                                </span>`;
              if (record.row._allCells[5].children[0]) {
                if (
                  record.row._allCells[5].children[0].innerHTML.indexOf(
                    "slds-icon-standard-task2"
                  ) == -1
                ) {
                  record.row._allCells[5].children[0].innerHTML =
                    iconElement + record.row._allCells[5].children[0].innerHTML;
                }
              }
            }
          }
        }
      }
    }
  }

  populateIconsOnExpandCollapse(source) {
    let id = source.record.id;
    console.log('populateIconsOnExpandCollapse source ',{source});
    console.log('id source ',id);
    var rowPhaseElement = this.template.querySelector(
      '[data-id="' + source.record.id + '"]'
    );
    if (rowPhaseElement && rowPhaseElement.innerHTML) {
      var iconElement = "";
      if (source.record.type == "Phase") {
        console.log('in phase condition');
        iconElement = `<span class="slds-icon_container slds-icon-standard-task" >
                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.2rem;width:1.2rem;">
                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#task">
                                        </use>
                                    </svg>
                                </span>`;
        if (
          rowPhaseElement.innerHTML.indexOf("slds-icon-standard-task") == -1
        ) {
          if (rowPhaseElement.children.length) {
            if (rowPhaseElement.children[5].children.length) {
              console.log('rowPhaseElement ',JSON.parse(JSON.stringify(rowPhaseElement.children[5])));
              rowPhaseElement.children[5].children[0].innerHTML =
                iconElement + rowPhaseElement.children[5].children[0].innerHTML;
            }
          }
        }
      } else if (source.record.type == "Project") {
        console.log('in project condition');
        iconElement = `<span class="slds-icon_container slds-icon-custom-custom70" >
                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.2rem;width:1.2rem;">
                                    <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom70">
                                        </use>
                                    </svg>
                                </span>`;
        if (
          rowPhaseElement.innerHTML.indexOf("slds-icon-custom-custom70") == -1
        ) {
          if (rowPhaseElement.children.length) {
            if (rowPhaseElement.children[5].children.length) {
              rowPhaseElement.children[5].children[0].innerHTML =
                iconElement + rowPhaseElement.children[5].children[0].innerHTML;
            }
          }
        }
      }
    }
  }

  formatCustomResponse(response) {
    var data = response.lstOfSObjs;
    this.scheduleItemsDataList = response.lstOfSObjs;
    this.scheduleData = response.scheduleObj;
    this.hideuserSchedule = response.hideScheduleFromUser;
    this.storeRes = response.filesandattacmentList;
    this.projectNameShow = true;
    this.userProfileName = response.profileName;

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
        taskMap.set(data[i].buildertek__Phase__c, scheduleItemsList.length - 1);
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
          scheduleItemsMap.delete(scheduleItemsList[i].buildertek__Phase__c);
        }
      }
    }
    for (const [key, value] of scheduleItemsMap.entries()) {
      if (value != undefined) {
        scheduleItemsListClone.push(value);
      }
    }
    let recordsMap = new Map();
    for (var i in scheduleItemsListClone) {
      if (scheduleItemsListClone[i].buildertek__Phase__c) {
        if (!recordsMap.has(scheduleItemsListClone[i].buildertek__Phase__c)) {
          recordsMap.set(scheduleItemsListClone[i].buildertek__Phase__c, []);
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
    console.log({
      recordsMap,
    });
    var result = Array.from(recordsMap.entries());
    console.log({
      result,
    });
    var groupData = [];
    for (var i in result) {
      var newObj = {};
      newObj["key"] = result[i][0];
      newObj["value"] = result[i][1];
      groupData.push(newObj);
    }
    this.scheduleItemsData = groupData;
    console.log({
      groupData,
    });
    if (this.template.querySelector(".container").children.length) {
      this.template.querySelector(".container").innerHTML = "";
      this.template.querySelector(".container1").innerHTML = "";
      this.createGantt();
    } else {
      this.createGantt();
    }
  }

  createGantt() {
    try {
      console.log("createGantt");
      console.log(this.GanttVar);
      var GanttToolbar;
      var wbsObj={};

      try {
        console.log('bryntum ==> ',JSON.parse(JSON.stringify(bryntum)));
      } catch (error) {
        console.log('error on JSON ',error);
      }


      var loc = window.location.href;
      var domName = loc.split(".lightning.force.com")[0].split("https://")[1];
      if (domName == "viewinc--bees" || domName == "viewinc") {
        if (
          this.userProfileName != "System Administrator" &&
          this.userProfileName != "Project Coordination"
        ) {
          GanttToolbar = GanttToolbarMixinDup(bryntum.gantt.Toolbar);
        } else {
          GanttToolbar = GanttToolbarMixin(bryntum.gantt.Toolbar);
        }
      } else {
        GanttToolbar = GanttToolbarMixin(bryntum.gantt.Toolbar);
      }

      var assignments = {};
      var resources = {};
      var tasks = {};
      var taskDependencyData = [];
      var resourceRowData = [];
      var assignmentRowData = [];
      var rows = [];

      var phaseDateList = this.phaseDates;
      console.log({
        phaseDateList,
      });
      var scheduleDataList = this.scheduleItemsDataList;
      console.log("scheduleDataList ==> ", {
        scheduleDataList,
      });

      for (var key in scheduleDataList) {
        if (scheduleDataList[key].buildertek__Milestone__c == true) {
          for (var ph of phaseDateList) {
            if (scheduleDataList[key].buildertek__Phase__c == ph.label) {
              scheduleDataList[key].buildertek__Start__c = ph.value.expr1;
              const date1 = new Date(ph.value.expr1);
              const date2 = new Date(ph.value.expr2);
              const diffTime = Math.abs(date2 - date1);
              const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
              // console.log(scheduleDataList[key].buildertek__Duration__c);
              scheduleDataList[key].buildertek__Duration__c = diffDays;
              // console.log(scheduleDataList[key].buildertek__Duration__c);
              // console.log(scheduleDataList[key].buildertek__Phase__c);
              // console.log('---------');
            }
          }
        }
      }
      console.log('scheduleDataList after logic changed ',{scheduleDataList});
      this.scheduleItemsDataList = scheduleDataList;
      var formatedSchData = formatData(
        this.scheduleData,
        this.scheduleItemsData,
        this.scheduleItemsDataList
      );
      console.log("=== formatedSchData ===");
      console.log({
        formatedSchData,
      });

      // var refVar = formatedSchData;
      // for(var key in refVar.rows[0].children){
      //     for(var key2 in refVar.rows[0].children[key].children){
      //         if(refVar.rows[0].children[key].children[key2].customtype == 'Milestone'){
      //           for(var dd of phaseDateList){
      //             if(dd.label == refVar.rows[0].children[key].name){
      //               console.log('--'+refVar.rows[0].children[key].name);
      //               console.log('-->'+dd.label);
      //               console.log(refVar.rows[0].children[key].children[key2].startDate);

      //               refVar.rows[0].children[key].children[key2].startDate == dd.value.expr1;

      //               console.log(dd.value.expr1);
      //               console.log(refVar.rows[0].children[key].children[key2].startDate);
      //               console.log('----------');
      //             }
      //           }
      //         }
      //     }
      // }
      // console.log({refVar});
      // formatedSchData = refVar;

      tasks["rows"] = formatedSchData["rows"];
      resources["rows"] = formatedSchData["resourceRowData"];
      assignments["rows"] = formatedSchData["assignmentRowData"];
      taskDependencyData = formatedSchData["taskDependencyData"];
      resourceRowData = formatedSchData["resourceRowData"];
      assignmentRowData = formatedSchData["assignmentRowData"];

      const holiday = [
        {
          id: "general",
          name: "General",
          intervals: [
            {
              recurrentStartDate: "on Sat at 0:00",
              recurrentEndDate: "on Mon at 0:00",
              isWorking: false,
            },
            {
              startDate: "2023-03-06",
              endDate: "2023-03-07",
              isWorking: false,
              name: "Vacation",
            },
          ],
          expanded: true,
          children: [
            {
              id: "business",
              name: "Business",
              hoursPerDay: 8,
              daysPerWeek: 5,
              daysPerMonth: 20,
              intervals: [
                {
                  recurrentStartDate: "every weekday at 12:00",
                  recurrentEndDate: "every weekday at 13:00",
                  isWorking: false,
                },
                {
                  recurrentStartDate: "every weekday at 17:00",
                  recurrentEndDate: "every weekday at 08:00",
                  isWorking: false,
                },
              ],
            },
            {
              id: "night",
              name: "Night shift",
              hoursPerDay: 8,
              daysPerWeek: 5,
              daysPerMonth: 20,
              intervals: [
                {
                  recurrentStartDate: "every weekday at 6:00",
                  recurrentEndDate: "every weekday at 22:00",
                  isWorking: false,
                },
              ],
            },
          ],
        },
      ];
      const project = new bryntum.gantt.ProjectModel({
        //enableProgressNotifications : true,
        calendar: data.project.calendar,
        // startDate: data.project.startDate,
        tasksData: tasks.rows, //tasks.rows
        dependenciesData: taskDependencyData,
        skipNonWorkingTimeWhenSchedulingManually: true, //taskDependencyData
        // resourcesData: data.resources.rows,
        // /assignmentsData: data.assignments.rows,
        resourcesData: resourceRowData, //this.showAllContacts,//, //resourceRowData
        assignmentsData: assignmentRowData,
        // calendarsData: data.calendars.rows,
        calendarsData: holiday,
      });
      console.log("calendar rows to  ==>", Array.isArray(data.calendars.rows));
      const gantt = new bryntum.gantt.Gantt({
        project,
        appendTo: this.template.querySelector(".container"),
        //startDate: "2019-01-12",
        //endDate: "2019-03-24",
        infiniteScroll: true,
        bufferCoef: 2,
        tbar: new GanttToolbar(),
        rowHeight: 30,
        barMargin: 5,
        // minHeight: "80em",
        viewPreset: "weekAndDayLetter",
        dependencyIdField: "sequenceNumber",
        // dependencyIdField: "wbsCode",
        columns: [
          {
            type: "wbs",
            editor: false,
          },
          {
            type: "action",
            text: "Add",
            width: 40,
            title: "Add",
            actions: [
              {
                cls: "b-fa b-fa-plus",
                onClick: ({ record }) => {
                  console.log("record ===>" + record);
                  if (record._data.id.indexOf("_generate") == -1) {
                    this.recordTaskParent = record;
                    this.addNewTask(record);
                  }
                },
              },
            ],
          },
          {
            type: "action",
            text: "Edit",
            width: 50,
            actions: [
              {
                cls: "b-fa b-fa-pen",
                onClick: ({ record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
                    this.taskRecordId = record._data.id;
                    this.getRecordData(record._data.id, record._data);
                  }
                },
                renderer: ({ action, record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
                    //&& record._data.id.indexOf('_generate') == -1
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
            width: 50,
            text: "% Done",
            editor: true,
          },
          {
            type: "action",
            text: "Complete",
            width: 50,
            actions: [
              {
                cls: "b-fa b-fa-check",
                onClick: ({ record }) => {
                  if (record._data.type == "Task") {
                    if (record._data.percentDone == 100) {
                      record.set("percentDone", 0);
                    } else {
                      record.set("percentDone", 100);
                    }
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
            type: "name",
            width: 250,
            editor: true,
            renderer: (record) => {
              this.populateIcons(record);
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
            },
          },
          {
            text: "Predecessor",
            width: 200,
            editor: false,
            renderer: (record) => {
              if (record.record._data.type == "Project") {
                return "";
              }
              if (record.record._data.type == "Phase") {
                return "";
              }
              if (record.record._data.name == "Milestone Complete") {
                return "";
              } else {
                return record.record._data.predecessorName;
              }
            },
          },
          {
            type: "startdate",
            editor: true,
            renderer: function (record) {
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
              if (
                record.value &&
                record.record._data.name == "Milestone Complete"
              ) {
                var endDate;
                var endDate1 = new Date(record.record.startDate);
                endDate1.setDate(
                  endDate1.getDate() + record.record._data.durationMile
                );
                if (record.record._parent._data.endDate != undefined) {
                  endDate = new Date(record.record._parent._data.endDate);
                  endDate.setDate(endDate.getDate() - 1);
                  endDate = new Date(endDate);
                  //return record.value;

                  return (
                    months[endDate.getMonth()] +
                    " " +
                    Number(endDate.getDate()) +
                    ", " +
                    endDate.getFullYear()
                  );
                }
              } else {
                console.log('record.record.startDate ',record.record.startDate);
                var sdate = new Date(record.record.startDate);
                return (
                  months[sdate.getMonth()] +
                  " " +
                  Number(sdate.getDate()) +
                  ", " +
                  sdate.getFullYear()
                );
              }
            },
          },
          {
            type: "enddate",
            editor: true,
            renderer: function (record) {
              if (record.rowElement) {
                record.rowElement.draggable = true;
              }
              var endDate;

              const map1 = new Map();
              var count = 0;

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
                // console.log('Record of endDate =>',{record});
                // console.log('duration>>>', record.record._data.duration);
                // console.log('type>>>', record.record._data.type);
                // console.log('name>>>', record.record._data.name);
                if (
                  record.record._data.duration >= 1 &&
                  record.record._data.type == "Task" &&
                  record.record._data.name != "Milestone Complete"
                  ) {
                    // console.log('In if conditon for enddate');
                    var start;
                    var endDate = new Date(record.value);
                  var start = new Date(record.record.startDate.getTime());
                  var duration = record.record.duration;
                  var eDate = new Date(start);
                  var eDatebefore = endDate;
                  // newly added
                  var eDate2 = new Date(start);
                  for (var i = 0; i < duration; i++) {
                    if (i == 0) {
                      // console.log("eDate2 before=> " + "i = " + i + " " + eDate2);
                      eDate2 = new Date(start.setDate(start.getDate() + i));
                      // console.log("eDate2 end=> " + "i = " + i + " " + eDate2);
                    } else {
                      // console.log("eDate2 else before=> " + "i = " + i + " " + eDate2);
                      eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 1));
                      // console.log("eDate2 els after=> " + "i = " + i + " " + eDate2);
                    }
                    if (new Date(eDate2).getDay() == 0) {
                      eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 1));
                    }
                    if (new Date(eDate2).getDay() == 6) {
                      eDate2 = new Date(eDate2.setDate(eDate2.getDate() + 2));
                    }
                    //console.log('custom',eDate2)
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
                  var eDateafter = endDate;
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
                  //   console.log('In phase');
                  //   console.log({record});
                  // console.log('In elseif(1) conditon for enddate');
                  // console.log('rc val>>>',record.value);
                  endDate = new Date(record.value);
                  endDate.setDate(endDate.getDate() - 1);
                  endDate = new Date(endDate);

                  map1.set(count, endDate);
                  //   console.log({map1});
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
                  // console.log('In elseif(-2) conditon for enddate');
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
                  // console.log('start Date',record.record.startDate);
                  //   console.log('MileStone EndDate');
                  //   console.log({record});
                  // console.log('-->'+record.record._data.name);

                  //COMMENTED
                  //endDate = new Date(record.value);

                  // console.log('Milestone endDate *** ===>' + endDate);
                  // console.log({record});
                  // console.log('Milestone endDate *** ===>' + JSON.parse(JSON.stringify(record.value)));

                  // console.log('Milestone End Date *** ===>' + months[endDate.getMonth()] +" " +Number(endDate.getDate()) +", " +endDate.getFullYear());
                  // endDate = map1.get(count);

                  // if(record.record._data.duration == 0){
                  //   endDate = new Date(record.record.startDate);
                  //   endDate.setDate(endDate.getDate() + record.record._data.durationMile);
                  // }else{
                  // console.log('--'+record.record._parent._data.endDate);
                  // endDate = new Date(record.record._parent._data.endDate);
                  if (record.record._parent._data.endDate != undefined)
                    console.log(
                      "-|-" +
                        record.record._parent._data.endDate
                          .toString()
                          .substring(8, 10)
                    );
                  // console.log({endDate});

                  // if(endDate != undefined && record.record._parent._data.endDate != undefined && record.record._parent._data.endDate.toString().substring(8,10) == endDate.getDate().toString()){
                  //   endDate.setDate(endDate.getDate() - 1);
                  // }else if(endDate != undefined && record.record._parent._data.endDate != undefined && record.record._parent._data.endDate.toString().substring(8,10) != endDate.getDate().toString()){
                  //   endDate.setDate(endDate.getDate() + 1);
                  // }
                  // console.log({endDate});

                  var endDate1 = new Date(record.record.startDate);
                  endDate1.setDate(
                    endDate1.getDate() + record.record._data.durationMile
                  );
                  // console.log({endDate1});

                  endDate = new Date(record.record._parent._data.endDate);
                  // console.log('1-'+endDate);
                  endDate.setDate(endDate.getDate() - 1);
                  // console.log('2-'+endDate);
                  endDate = new Date(endDate);
                  // console.log('3-'+endDate);

                  // endDate.setDate(endDate.getDate() + record.record._parent._data.duration);
                  // }

                  return (
                    months[endDate.getMonth()] +
                    " " +
                    Number(endDate.getDate()) +
                    ", " +
                    endDate.getFullYear()
                  );
                }
              }
            },
          },
          {
            type: "duration",
            width: "5%",
            editor: true,
            renderer: (record) => {
              this.populateIcons(record);
              // if(record.record._data.name == 'Milestone Complete'){
              //   console.log({record});
              //   console.log(record.value._magnitude);
              // }
              if (record.record._data.name == "Milestone Complete") {
                var phasePercent = record.record.taskStore.storage.getBy(
                  "_internalId",
                  record.record._parent._internalId
                ).percentDone;
                if (phasePercent != record.record.percentDone) {
                }
              }
              if (record.value._magnitude > -1) {
                if (record.value._magnitude == 0) {
                  return 1;
                } else {
                  return record.value._magnitude;
                }
              }
            },
          },
          {
            text: "Internal Resource",
            width: 100,
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
              } else {
                record.cellElement.innerHTML = `<span></span>`;
              }
            },
            filterable: ({ record, value, operator }) => {
              if (record._data.internalresourcename && value) {
                if (
                  record._data.internalresourcename
                    .toUpperCase()
                    .indexOf(value.toUpperCase()) > -1
                ) {
                  return true;
                }
              }
            },
          },
          //Added for Contractor
          {
            text: "Contractor",
            width: 110,
            editor: false,
            renderer: function (record) {
              if (
                record.record._data.type == "Task" &&
                record.record._data.name != "Milestone Complete"
              ) {
                if (record.record._data.contractoracc) {
                  record.cellElement.classList.add("b-resourceassignment-cell");
                  record.cellElement.innerHTML = `<div id="" class="b-assignment-chipview-wrap">
                                    <div class="b-assignment-chipview b-widget b-list b-chipview b-outer b-visible-scrollbar b-chrome b-no-resizeobserver b-widget-scroller b-hide-scroll" tabindex="0" style="overflow-x: auto;" >
                                        <div class="b-chip" data-index="0" data-isinternalres="false" > ${record.record._data.contractorname}</div>
                                        <i id="editcontractor" data-resource="${record.record._data.contractorname}" class="b-action-item b-fa b-fa-pen" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;"  ></i>
                                        </div>
                                </div>`;
                } else {
                  record.cellElement.innerHTML = `
                                <i  class="b-action-item b-fa b-fa-user-plus addcontractor" style="font-size:1rem;color:#cfd1d3;margin-left:0.2rem;"  ></i>
                                `;
                }
              } else {
                record.cellElement.innerHTML = `<span></span>`;
              }
            },
            filterable: ({ record, value, operator }) => {
              if (record._data.contractorresourcename && value) {
                if (
                  record._data.contractorresourcename
                    .toUpperCase()
                    .indexOf(value.toUpperCase()) > -1
                ) {
                  return true;
                }
              }
            },
          },
          {
            text: "Contractor Resource",
            width: 110,
            editor: false,
            renderer: function (record) {
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
            filterable: ({ record, value, operator }) => {
              if (record._data.contractorresourcename && value) {
                if (
                  record._data.contractorresourcename
                    .toUpperCase()
                    .indexOf(value.toUpperCase()) > -1
                ) {
                  return true;
                }
              }
            },
          },
          {
            type: "action",
            // text    : 'Attach File',
            width: 30,
            actions: [
              {
                cls: "b-fa b-fa-paperclip",
                onClick: ({ record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
                    this.showpopup = true;
                    this.fileTaskId = record._data.id;
                  }
                },
                renderer: ({ action, record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
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
            // text    : 'Files',
            width: 30,
            actions: [
              {
                cls: "b-fa b-fa-file",
                onClick: ({ record }) => {
                  this.showFileForRecord = record._data.id;
                  this.showFilePopup = true;
                },
                renderer: ({ action, record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
                    if (this.storeRes["" + record._data.id]) {
                      if (this.storeRes["" + record._data.id]["fileLength"]) {
                        return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" data-btip="File"></i>`;
                      }
                      return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" data-btip="File"></i>`;
                    }
                    return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" data-btip="File"></i>`;
                  } else {
                    return `<i class="b-action-item ${action.cls}" style="display:none;font-size:1.1rem;" data-btip="File"></i>`;
                  }
                },
              },
            ],
          },
          {
            type: "action",
            //text    : 'Go to Item',
            width: 30,
            actions: [
              {
                cls: "b-fa b-fa-external-link-alt",
                onClick: ({ record }) => {
                  if (record._data.id.indexOf("_generate") == -1) {
                    this.navigateToRecordViewPage(record._data.id);
                  }
                },
                renderer: ({ action, record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
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
            // text    : 'Delete',
            width: 30,
            actions: [
              {
                cls: "b-fa b-fa-trash",
                onClick: ({ record }) => {
                  this.readyTodeleteTask = record;
                  this.showDeletePopup = true;
                },
              },
            ],
          },
          {
            type: "action",
            //text    : 'Comment',
            width: 30,
            actions: [
              {
                cls: "b-fa b-fa-comment-alt",
                onClick: ({ record }) => {
                  this.taskRecordId = record._data.id;
                  this.getComment();
                },
                renderer: ({ action, record }) => {
                  if (
                    record._data.type == "Task" &&
                    record._data.id.indexOf("_generate") == -1
                  ) {
                    if (this.storeRes["" + record._data.id]) {
                      if (this.storeRes["" + record._data.id]["notesLength"]) {
                        return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" data-btip="Add Comment"></i>`;
                      }
                      return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" data-btip="Add Comment"></i>`;
                    }
                    return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" data-btip="Add Comment"></i>`;
                  } else {
                    return `<i class="b-action-item ${action.cls}" style="display:none;font-size:1.1rem;" data-btip="Add Comment"></i>`;
                  }
                },
              },
            ],
          },
        ],
        subGridConfigs: {
          locked: {
            flex: 20,
          },
          normal: {
            flex: 7,
          },
        },
        columnLines: false,
        features: {
          pdfExport: {
            exportServer: "http://localhost:8080", // Required
          },
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
              add: false,
              convertToMilestone: false,
            },
          },
          taskEdit: {
            items: {
              generalTab: {
                items: {
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
              resourcesTab: false,
              notesTab: false,
              advancedTab: false,
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
                var StartString =
                  editorContext.record._data.startDate.getFullYear() +
                  "-" +
                  Number(editorContext.record._data.startDate.getMonth() + 1) +
                  "-" +
                  editorContext.record._data.startDate.getDate();
                var that = this;
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
                  if (new Date(eDate).getDay() == 0) {
                    eDate = new Date(eDate.setDate(eDate.getDate() + 1));
                  }
                  if (new Date(eDate).getDay() == 6) {
                    eDate = new Date(eDate.setDate(eDate.getDate() + 2));
                  }
                  eDate = new Date(eDate);
                }
                editorContext.value.setDate(eDate.getDate());
                editorContext.value.setMonth(eDate.getMonth());
                editorContext.value.setFullYear(eDate.getFullYear());
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
          celldblclick: ({ source }) => {},
          cellClick: ({ source }) => {},
          finishCellEdit: ({ editorContext }) => {},
          beforeFinishCellEdit: ({ editorContext }) => {
            if (
              editorContext.column.field !== "percentDone" ||
              editorContext.record.isLeaf
            ) {
              if (editorContext.column.field == "endDate") {
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
                if (this.template.querySelector(".b-cell-editor")) {
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
                  var endDateDateVal = dateStringVal
                    .split(", ")[0]
                    .split(" ")[1];
                  var dt = new Date(
                    endDateYearVal,
                    endDateMonthVal,
                    endDateDateVal
                  );
                  editorContext.value.setDate(dt.getDate());
                  editorContext.value.setMonth(dt.getMonth());
                  editorContext.value.setFullYear(dt.getFullYear());
                  var duration = 0;
                  const date1 = new Date(editorContext.record._data.startDate);
                  const date2 = new Date(dt);
                  const diffTime = Math.abs(date2 - date1);
                  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
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
                    this.foucsedCellId = editorContext.record._data.id;
                  }
                }
              }
            }
          },
          beforerendertask: ({ source }) => {
            if (source.selectedRecordCollection) {
              if (source.selectedRecordCollection._values.length) {
                if (
                  source.selectedRecordCollection._values[0].predecessors
                    .length == 0 &&
                  (source.selectedRecordCollection._values[0].constraintType ==
                    "" ||
                    source.selectedRecordCollection._values[0].constraintType ==
                      null)
                ) {
                  source.selectedRecordCollection._values[0].set(
                    "constraintType",
                    "startnoearlierthan"
                  );
                  source.selectedRecordCollection._values[0].set(
                    "predecessor",
                    undefined
                  );
                  source.selectedRecordCollection._values[0].set(
                    "constraintDate",
                    source.selectedRecordCollection._values[0].data.startDate
                  );
                } else if (
                  source.selectedRecordCollection._values[0].predecessors
                    .length == 0
                ) {
                  source.selectedRecordCollection._values[0].set(
                    "constraintDate",
                    source.selectedRecordCollection._values[0].data.startDate
                  );
                  source.selectedRecordCollection._values[0].set(
                    "predecessor",
                    undefined
                  );
                }
              }
            }
            if (this.GanttVar) {
              if (this.GanttVar.subGrids) {
                if (
                  this.GanttVar.subGrids["normal"].collapsed == true ||
                  this.GanttVar.subGrids["normal"].collapsed == false
                ) {
                  this.hideSchedule =
                    this.GanttVar.subGrids["normal"].collapsed;
                }
              }
            }
            if (source._focusedCell) {
              if (source._focusedCell.columnId.indexOf("endDate") > -1) {
                if (this.template.querySelector(".b-cell-editor")) {
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
                  var endDateDateVal = dateStringVal
                    .split(", ")[0]
                    .split(" ")[1];
                  var dt = new Date(
                    endDateYearVal,
                    endDateMonthVal,
                    endDateDateVal
                  );
                  source._selectedRecordCollection._values[0].set(
                    "endDate",
                    dt
                  );
                  var duration = 0;
                  const date1 = new Date(
                    source._selectedRecordCollection._values[0]._data.startDate
                  );
                  const date2 = new Date(dt);
                  const diffTime = Math.abs(date2 - date1);
                  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
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
                }
              } else if (
                source._focusedCell.columnId.indexOf("fullDuration") > -1
              ) {
              }
            }
          },
          beforeDestroy: ({ source }) => {
            ////console.log(source,'destroy')
          },

          beforeDependencySave: ({ source, dependencyRecord, values }) => {
            ////console.log(source ,'eventRecord ')
          },
        },
        taskRenderer({ taskRecord, renderData }) {
          // Return some custom elements, described as DomSync config objects.
          // Please see https://bryntum.com/docs/gantt/#Core/helper/DomHelper#function-createElement-static for more information.
          var a = new Date();
          var dat = new Date(a.getFullYear(), a.getMonth(), a.getDate());
          var recEdate = new Date(taskRecord.endDate);
          var eveLitener = function (e) {
            if (!e.currentTarget.classList.contains("pastDueDatesText")) {
              var ele = e.currentTarget;
              setTimeout(() => {
                if (!ele.classList.contains("pastDueDatesText")) {
                  //  ele.classList.add('pastDueDatesText')
                }
              }, 150);
            }
          };
          if (taskRecord._data.endDate) {
            recEdate = new Date(taskRecord._data.endDate);
            var start = taskRecord.startDate
              ? new Date(taskRecord.startDate.getTime())
              : new Date(taskRecord._data.startDate.getTime());
            var duration = taskRecord.duration;
            var eDate = new Date(start);
            // console.log('Start date ==> ',{start});
            // console.log({duration});
            // console.log({eDate});
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
              eDate = new Date(eDate);
            }

            if (
              eDate.getTime() < dat.getTime() &&
              taskRecord.percentDone < 100
            ) {
              renderData.wrapperCls.add("pastdateTextColor");
              renderData.taskRecord.cls.add("pastDueDatesText");
              if (
                !renderData.row.elements.locked.classList.contains(
                  "pastDueDatesText"
                )
              ) {
                renderData.row.elements.locked.classList.add(
                  "pastDueDatesText"
                );
                renderData.row.elements.locked.addEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.locked.addEventListener(
                  "mouseleave",
                  eveLitener
                );
                renderData.row.elements.normal.addEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.normal.addEventListener(
                  "mouseleave",
                  eveLitener
                );
                renderData.row.cls.add("pastDueDatesText");
              }
              if (renderData.taskRecord.cls.contains("notpastDueDatesText")) {
                renderData.taskRecord.cls.remove("notpastDueDatesText");
              }

              renderData.style += "background:red;";
            } else {
              if (renderData.taskRecord.cls.contains("pastDueDatesText")) {
                renderData.row.elements.locked.removeEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.locked.removeEventListener(
                  "mouseleave",
                  eveLitener
                );
                renderData.row.elements.normal.removeEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.normal.removeEventListener(
                  "mouseleave",
                  eveLitener
                );
                renderData.row.cls.remove("pastDueDatesText");
                renderData.taskRecord.cls.add("notpastDueDatesText");
                renderData.taskRecord.cls.remove("pastDueDatesText");
                delete renderData.taskRecord.cls["pastDueDatesText"];
                renderData.row.elements.locked.classList.remove(
                  "pastDueDatesText"
                );
              }
            }
          } else {
            recEdate.setDate(recEdate.getDate() - 1);
            if (
              taskRecord.endDate &&
              recEdate.getTime() < Date.now() &&
              taskRecord.percentDone < 100
            ) {
              if (renderData.taskRecord.cls.contains("notpastDueDatesText")) {
                renderData.taskRecord.cls.remove("notpastDueDatesText");
              }
              renderData.wrapperCls.add("pastdateTextColor");
              renderData.style += "background:red;";
            } else {
              if (renderData.taskRecord.cls.contains("pastDueDatesText")) {
                renderData.row.elements.locked.removeEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.locked.removeEventListener(
                  "mouseleave",
                  eveLitener
                );
                renderData.row.elements.normal.removeEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.elements.normal.removeEventListener(
                  "mouseover",
                  eveLitener
                );
                renderData.row.cls.remove("pastDueDatesText");
                renderData.taskRecord.cls.remove("pastDueDatesText");
                renderData.taskRecord.cls.add("notpastDueDatesText");
                delete renderData.taskRecord.cls["pastDueDatesText"];
                renderData.row.elements.locked.classList.remove(
                  "pastDueDatesText"
                );
              }
            }
          }

          // for milestone percentdone update
          if (taskRecord._data.type == "Phase") {
            if (taskRecord._data.children) {
              if (taskRecord._data.children.length) {
                var phaseTask = taskRecord;
                if (
                  phaseTask.children[phaseTask.children.length - 1].name ==
                  "Milestone Complete"
                ) {
                  if (
                    phaseTask.children[phaseTask.children.length - 1]
                      .percentDone != taskRecord.percentDone
                  ) {
                    phaseTask.children[
                      phaseTask.children.length - 1
                    ].percentDone = taskRecord.percentDone;
                  }
                }
              }
            }
          }
          //on save editor popup if removed dependency make constraint as 'startnoearlier'
          /*if(taskRecord._data.type == 'Task'){
                        if(renderData.task){
                            if(!renderData.task.predecessors.length){
                                renderData.task.constraintType = 'startnoearlierthan';
                            }
                        }
                    }*/

        wbsObj[renderData.taskRecord.wbsValue._value]=renderData.taskRecord.id.split('_')[0];
        // wbsObj[renderData.taskRecord.id.split('_')[0]]=renderData.taskRecord.wbsValue._value;

        var that = this;
        that.wpsValue = wbsObj;

          if (that.wpsBoolean == undefined || that.wpsBoolean == null) {
            that.wpsBoolean = false;
          }

          try {
            var that = this;
            if (that.wpsBoolean == false) {
              that.wpsValue = wbsObj;
              that.wpsBoolean = true;

              console.log('*** 1');
              setTimeout(() => {
                setWBSValue({
                  scheduleItemMap: JSON.stringify(wbsObj),
                })
                  .then(function (response) {
                    console.log('successfilly called setWBSValue');
                    // console.log(response);
                  })
                  .catch(function (error) {
                    console.log('Error from apex call in setWBSValue');
                  });


              },5000);

                console.log('*** 2');

            }
          } catch (error) {
            console.log('Error in custom WBS logic');
            console.log({error});
            console.log(JSON.stringify(error));
          }
          // const timeoutMilliseconds = 5000;

        },

      });

      // console.log(gantt.taskRenderer({x , y}));
      console.log('*** N3');
      // console.log(taskRenderer({x , y}));

      if (this.GanttVar) {
        this.hideSchedule = this.GanttVar.subGrids.normal.collapsed;
      }

      this.GanttVar = gantt;

      var lastInteractedTask = window.sessionStorage.getItem(
        "lastInteractedTaskId"
      );
      if (lastInteractedTask) {
        var taskRec = this.GanttVar.taskStore.getById(lastInteractedTask);
        if (taskRec) {
          this.GanttVar.scrollTaskIntoView(taskRec, {
            block: "start",
            animate: 500,
            edgeOffset: 50,
            highlight: true,
            focus: false,
          });
        }
        window.sessionStorage.clear();
      }

      if (this.loadedChart) {
        this.hideSchedule = this.hideuserSchedule;
        this.loadedChart = false;
      }
      gantt.callGanttComponent = this;
      gantt.addListener("cellClick", (event) => {
        if (event.target.classList.contains("b-fa-arrow-right")) {
          event.record._data["iconCls"] = "b-fa b-fa-arrow-left indentTrue";
          event.record._data["indentVal"] = true;
          event.target.classList.remove("b-fa-arrow-right");
          event.target.parentElement.parentElement.classList.add(
            "indentCellTrue"
          );
          if (!event.target.classList.contains("b-fa-arrow-left")) {
            event.target.classList.add("b-fa-arrow-left");
            event.target.classList.add("indentTrue");
          }
        } else if (event.target.classList.contains("b-fa-arrow-left")) {
          event.record._data["indentVal"] = false;

          event.target.classList.remove("b-fa-arrow-left");
          event.target.parentElement.parentElement.classList.remove(
            "indentCellTrue"
          );
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
          window.sessionStorage.setItem(
            "lastInteractedTaskId",
            event.record._data.id
          );
        }
        if (event.column.data.text == "Internal Resource") {
          if (event.target.id == "editInternalResource") {
            if (event.target.dataset.resource) {
              this.taskRecordId = event.record._data.id;
              this.showEditResourcePopup = true;
              console.log('taskReocrdId:=- '+this.taskRecordId);
              this.selectedContactApiName = "buildertek__Resource__c";
              this.selectedResourceContact =
              event.record._data.internalresource;
            }
          } else if (event.target.classList.contains("addinternalresource")) {
            this.taskRecordId = event.record._data.id;
            console.log('taskReocrdId:=- '+this.taskRecordId);
            this.showEditResourcePopup = true;
            this.selectedContactApiName = "buildertek__Resource__c";
            this.selectedResourceContact = "";
          }
        }
        //Added for Contractor
        if (event.column.data.text == "Contractor") {
          if (event.target.id == "editcontractor") {
            if (event.target.dataset.resource) {
              this.taskRecordId = event.record._data.id;
              this.showContractor = true;
              this.selectedContactApiName = "buildertek__Contractor__c";
              this.selectedResourceAccount = event.record._data.contractoracc;
            }
          } else if (event.target.classList.contains("addcontractor")) {
            this.taskRecordId = event.record._data.id;
            this.showContractor = true;
            this.selectedContactApiName = "buildertek__Contractor__c";
            this.selectedResourceAccount = "";
          }
        }
        if (event.column.data.text == "Contractor Resource") {
          if (event.target.id == "editcontractorResource") {
            if (event.target.dataset.resource) {
              this.taskRecordId = event.record._data.id;
              this.showEditResourcePopup = true;
              console.log('taskReocrdId:=- '+this.taskRecordId);
              this.selectedContactApiName =
                "buildertek__Contractor_Resource__c";
              this.selectedResourceContact =
                event.record._data.contractorresource;
              //   console.log(
              //     "this.selectedResourceContact>>>",
              //     this.selectedResourceContact
              //   );
            }
          } else if (event.target.classList.contains("addcontractorresource")) {
            this.taskRecordId = event.record._data.id;
            this.showEditResourcePopup = true;
            console.log('taskReocrdId:=- '+this.taskRecordId);
            this.selectedContactApiName = "buildertek__Contractor_Resource__c";
            this.selectedResourceContact = "";
          }
        }
      });

      gantt.on("save", (source) => {
        ////console.log(source)
      });
      gantt.on("expandnode", (source) => {
        this.populateIconsOnExpandCollapse(source);
      });
      gantt.on("collapsenode", (source) => {
        this.populateIconsOnExpandCollapse(source);
      });

      project.commitAsync().then(() => {
        const stm = gantt.project.stm;
        stm.enable();
        stm.autoRecord = true;
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
      }, 1200);
      setTimeout(() => {
        var ele = this.template.querySelectorAll(".b-grid-row");
        for (let i = 0; i < ele.length; i++) {
          ele[i].addEventListener("dragstart", function (eve) {
            eve.dataTransfer.setData(
              "text",
              eve.target.getAttribute("data-id")
            );
          });
        }
        var loc = window.location.href;
        var domName = loc.split(".lightning.force.com")[0].split("https://")[1];
      }, 1000);
    } catch (error) {
      if (error && !this.isTabClosed) {
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
    }
  }

  openOriginDateModal() {
    this.showOriginalDateModal = true;
  }

  closeModal() {
    this.showOriginalDateModal = false;
  }

  changeOriginalDate() {
    this.isLoaded = true;
    this.showOriginalDateModal = false;
    var that = this;
    var recId = this.recordId;
    changeOriginalDates({
      recordId: recId,
    })
      .then(function (response) {
        // console.log("response");
        // console.log({ response });
        that.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Original Dates Changed Successfully.",
            variant: "success",
          })
        );
        that.isLoaded = false;
      })
      .catch(function (error) {
        console.log("error");
        console.log({
          error,
        });
        that.dispatchEvent(
          new ShowToastEvent({
            title: "Try Again",
            message: "Something Went Wrong, Please Try Again",
            variant: "warning",
          })
        );
        that.isLoaded = false;
      });
  }
  handleBeforeUnload() {
    console.log("handleBeforeUnload");
    if (this.showToast && this.isrowchange) {
      console.log("handleBeforeUnload in if condition");
      const toastEvent = new ShowToastEvent({
        title: "Warning",
        message: "Your have made changes please save before closing.",
        variant: "warning",
      });
      this.dispatchEvent(toastEvent);

      setTimeout(() => {
        const toastCloseEvent = new ShowToastEvent({
          title: "",
          message: "",
          variant: "",
        });
        this.dispatchEvent(toastCloseEvent);
      }, 5000);
    }
  }



}