/* globals bryntum : true */
import { api, LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";

import GanttStyle from "@salesforce/resourceUrl/BT_Bryntum_NewGanttCss";
import GANTTModule from "@salesforce/resourceUrl/BT_Bryntum_NewGantt_ModuleJS";
import { NavigationMixin } from "lightning/navigation";

// import GanttStyle from "@salesforce/resourceUrl/BT_Bryntum_NewGanttCss";
import GanttToolbarMixin from "./lib/GanttToolbar";
import data from "./data/launch-saas";
import scheduleWrapperDataFromApex from "@salesforce/apex/bryntumGanttController.getScheduleWrapperAtLoading";
import saveResourceForRecord from "@salesforce/apex/bryntumGanttController.saveResourceForRecord";
import upsertDataOnSaveChanges from "@salesforce/apex/bryntumGanttController.upsertDataOnSaveChanges";
import getPickListValuesIntoList from "@salesforce/apex/bryntumGanttController.getPickListValuesIntoList";
import changeOriginalDates from "@salesforce/apex/bryntumGanttController.changeOriginalDates";
import {
  formatApexDatatoJSData,
  recordsTobeDeleted,
  makeComboBoxDataForContractor,
  calcBusinessDays,
  makeComboBoxDataForResourceData,
  mergeArrays
} from "./gantt_componentHelper";
import { populateIcons } from "./lib/BryntumGanttIcons";

export default class Gantt_component extends NavigationMixin(LightningElement) {
  @track spinnerDataTable = false;
  @track showSpinner = false;
  @track islibraryloaded = false;
  @track scheduleItemsDataList;
  @track scheduleData;
  @track scheduleItemsData;
  @track contractorAndResources;
  @track internalResources;

  @track error_toast = true;

  @api SchedulerId;
  @api isLoading = false;
  @api showExportPopup;
  @api showImportPopup;
  @api recordId;
  @api taskRecordId;
  @track showContractor = false;
  @track showEditResourcePopup = false;
  @track selectedContactApiName;

  //Phase list
  @track phaseNameList;
  @track showOriginalDateModal = false;
  //new
  @api showEditResourcePopup = false;
  @api selectedResourceContact;
  @api selectedContactApiName;
  @api resourceLookup = {};
  @api contractorResourceLookup = {};
  @api contratctorLookup = {};
  @api contractorResourceFilterVal = "";
  @api internalResourceFilterVal = "";
  @track setorignaldates = false;
  @api hideToolBar = false;
  //Added for contractor
  @api showContractor = false;
  @api selectedResourceAccount;
  @track contracFieldApiName;
  @track contractorname;

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

  // newPreview
  @api showpopup = false;
  @api storeRes;
  @api fileTaskId = "";
  @api uploadFileNameCheck = "";
  @api showFileForRecord = "";
  @api showFilePopup = false;

  connectedCallback() {
    console.log("Connected Callback new gantt chart");
    console.log("ReocrdID:- ", this.recordId);

    if (this.SchedulerId == null || this.SchedulerId == undefined) {
      if (this.recordId == null || this.recordId == undefined) {
        // this.SchedulerId = "a2zDm0000004bPuIAI"; // trail org
        this.SchedulerId = "a101K00000GobT6QAJ"; // New
        // this.SchedulerId = 'a101K00000GobTCQAZ' // Old
      } else {
        this.SchedulerId = this.recordId;
      }
    } else {
      console.log("SchedulerId :- ", this.SchedulerId);
    }
    this.loadLibraries();
    let intervalID = setInterval(() => {
      if (this.bryntumInitialized) {
        return;
      }
      //this.spinnerDataTable = true;
      this.bryntumInitialized = true;
      this.getPickListValuesIntoListFromApex();
      this.getScheduleWrapperDataFromApex();
    }, 1500);
  }

  renderedCallback() {
    let intervalID = setInterval(() => {
      if (this.bryntumInitialized) {
        return;
      }
      this.bryntumInitialized = true;
      this.loadLibraries();
    }, 1500);
  }

  @api updaterecordId(newid){
    this.SchedulerId = newid;
    this.getScheduleWrapperDataFromApex();
  }

  loadLibraries() {
    Promise.all([
      // loadScript(this, GANTT + "/gantt.lwc.module.min.js"),
      // loadStyle(this, GANTT + "/gantt.stockholm-1.css"),
      loadScript(this, GANTTModule),
      loadStyle(this, GanttStyle + "/gantt.stockholm.css"),
    ])
      .then(() => {
        // this.handleHideSpinner();
        console.log("lib loaded");
        this.islibraryloaded = true;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error loading Bryntum Gantt",
            message: error,
            variant: "error",
          })
        );
      });
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
    console.log("uploadFileNameCheck:", this.uploadFileNameCheck);
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

  navigateToRecordViewPage(id) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: id,
        actionName: "view",
      },
    });
  }

  getScheduleWrapperDataFromApex() {
    this.showSpinner = true;
    scheduleWrapperDataFromApex({
      scheduleid: this.SchedulerId,
    })
      .then((response) => {
        var data = response.lstOfSObjs;
        this.scheduleItemsDataList = response.lstOfSObjs;
        console.log('scheduleItemsDataList:- ', this.scheduleItemsDataList)
        console.log('scheduleItemsDataList:- ', this.scheduleItemsDataList.length)
        if(!this.shceduleItemsDataList){
          this.setorignaldates = true;
          console.log('orginaldates:- ',this.setorignaldates)
        }
        this.contractorAndResources = response.listOfContractorAndResources;
        this.internalResources = response.listOfInternalResources;
        console.log(
          "scheduleItemsDataList",
          JSON.parse(JSON.stringify(this.scheduleItemsDataList))
        );
        console.log(
          "internalResources",
          JSON.parse(JSON.stringify(this.internalResources))
        );
        this.scheduleData = response.scheduleObj;
        this.storeRes = response.filesandattacmentList;

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
          // this.template.querySelector(".container1").innerHTML = "";
          // this.handleHideSpinner();
          this.createGanttChartInitially();
          // this.createGantt();
        } else {
          // this.handleHideSpinner();
          this.createGanttChartInitially();
          // this.createGantt();
          // this.isLoaded = false;
        }
              })
      .catch((error) => {
        console.log(
          "error message to get while getting data from apex:- ",
          error.message
        );
        console.log("error:-", {error} )
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Something went Wrong",
            variant: "error",
          })
        );
      })
      .finally(()=>{
        this.showSpinner = false;
      });
  }

  getPickListValuesIntoListFromApex() {
    getPickListValuesIntoList()
      .then((result) => {
        console.log("lib loaded");
        this.phaseNameList = result;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error getting Phase data Bryntum Gantt",
            message: error,
            variant: "error",
          })
        );
      });
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
        console.log("taskRecordId:-", this.taskRecordId);
        console.log("selectedResourceAccount:-", this.selectedResourceAccount);
        console.log("contracFieldApiName:-", this.contracFieldApiName);
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
          that.getScheduleWrapperDataFromApex();
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
          that.getScheduleWrapperDataFromApex();
        });
      }
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

  //populateIconsOnExpandCollapse
  populateIconsOnExpandCollapse(source) {
    console.log("in populateiconsonexpandcollapse");
    console.log(
      "template queryselector :- ",
      this.template.querySelector('[data-id="' + source.record.id + '"]')
    );
    var rowPhaseElement = this.template.querySelector(
      '[data-id="' + source.record.id + '"]'
    );
    console.log("rowPhaseElement :- ", rowPhaseElement);
    if (rowPhaseElement && rowPhaseElement.innerHTML) {
      console.log("In Here first if condition");
      var iconElement = "";
      if (source.record.type == "Phase") {
        console.log("In Here phase if condition");
        iconElement = `<span class="slds-icon_container slds-icon-custom-custom62" >
        <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.3rem;width:1.3rem;">
        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom62">
        </use>
    </svg>
                                    </span>`;
        if (
          rowPhaseElement.innerHTML.indexOf("slds-icon-custom-custom62") == -1
        ) {
          if (rowPhaseElement.children.length) {
            if (rowPhaseElement.children[3].children.length) {
              rowPhaseElement.children[3].children[0].innerHTML =
                iconElement + rowPhaseElement.children[3].children[0].innerHTML;
            }
          }
        }
      } else if (source.record.type == "Project") {
        console.log("In Here Project if condition");
        iconElement = `<span class="slds-icon_container slds-icon-custom-custom70" >
                                        <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.3rem;width:1.3rem;">
                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom70">
                                            </use>
                                        </svg>
                                    </span>`;
        if (
          rowPhaseElement.innerHTML.indexOf("slds-icon-custom-custom70") == -1
        ) {
          if (rowPhaseElement.children.length) {
            if (rowPhaseElement.children[3].children.length) {
              rowPhaseElement.children[3].children[0].innerHTML =
                iconElement + rowPhaseElement.children[3].children[0].innerHTML;
            }
          }
        }
      }
    }
  }

  addtaskeventcall(taskrecord) {
    console.log("In addtaskeventcall method");
    console.log(taskrecord);
  }

  createGanttChartInitially() {
    const GanttToolbar = GanttToolbarMixin(bryntum.gantt.Toolbar);

    var assignments = {};
    var resources = {};
    var tasks = {};
    var taskDependencyData = [];
    var resourceRowData = [];
    var assignmentRowData = [];
    var rows = [];
    var toolbar;
    if(!this.hideToolBar){
      toolbar = new GanttToolbar()
    }
    var scheduleDataList = this.scheduleItemsDataList;
    this.scheduleItemsDataList = scheduleDataList;
    var formatedSchData = formatApexDatatoJSData(
      this.scheduleData,
      this.scheduleItemsData,
      this.scheduleItemsDataList
    );

    console.log("=== formatedSchData ===");
    console.log({
      formatedSchData,
    });

    tasks["rows"] = formatedSchData["rows"];
    resources["rows"] = formatedSchData["resourceRowData"];
    assignments["rows"] = formatedSchData["assignmentRowData"];
    taskDependencyData = formatedSchData["taskDependencyData"];
    resourceRowData = formatedSchData["resourceRowData"];
    assignmentRowData = formatedSchData["assignmentRowData"];
    console.log('assignmentRowData ',assignmentRowData);
    debugger

    let resourceData = makeComboBoxDataForResourceData(this.contractorAndResources, this.internalResources);

    const project = new bryntum.gantt.ProjectModel({
      calendar: data.project.calendar,
      // startDate: data.project.startDate,
      startDate: this.scheduleData.buildertek__Start_Date__c,
      // tasksData: data.tasks.rows,
      tasksData: tasks.rows,
      skipNonWorkingTimeWhenSchedulingManually: true,
      resourcesData: resourceData,
      // assignmentsData: data.assignments.rows,
      assignmentsData: assignmentRowData,
      // dependenciesData: data.dependencies.rows,
      dependenciesData: taskDependencyData,
      calendarsData: data.calendars.rows,
    });

    project.hoursPerDay = 8;
    project.calendar = "business";

    let contractorComboData = makeComboBoxDataForContractor(this.contractorAndResources);

    let gantt = new bryntum.gantt.Gantt({
      project,
      appendTo: this.template.querySelector(".container"),
      // startDate: "2019-07-01",
      // endDate: "2019-10-01",

      tbar: toolbar,
      rowHeight         : 30,
      barMargin         : 5,


      dependencyIdField: "sequenceNumber",
      columns: [
        {
          type: "wbs",
          draggable: false,
        },
        {
          type: "action",
          text: "",
          width: 30,
          actions: [
            {
              cls: "b-fa b-fa-check",
              onClick: ({ record }) => {
                if (record.type == "Task") {
                  if (record.percentDone == 100) {
                    record.set("percentDone", 0);
                  } else {
                    record.set("percentDone", 100);
                  }
                }
              },
              renderer: ({ action, record }) => {
                if (record.type == "Task" && record.name != "Milestone Complete") {
                  if (record.percentDone == 100) {
                    return `<i class="b-action-item ${action.cls}" style="color: #5ee14c;"></i>`;
                  } else {
                    return `<i class="b-action-item ${action.cls}"></i>`;
                  }
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "action",
          text: "",
          width: 15,
          actions: [
            {
              cls: "b-fa b-fa-arrow-up-from-bracket",
              onClick: ({ record }) => {
                if (record.type == "Task" && record.name != "Milestone Complete") {
                  this.navigateToRecordViewPage(record._data.id);
                }
              },
              renderer: ({ action, record }) => {
                if (record.type == "Task" && record.name != "Milestone Complete") {                
                  return `<i class="b-action-item ${action.cls}"></i>`;
                } else {
                  return `<i class="b-action-item ${action.cls}" style="display:none;"></i>`;
                }
              },
            },
          ],
        },
        {
          type: "action",
          text: "",
          width: 15,
          actions: [
            {
              cls: "b-fa b-fa-pen",
              onClick: ({ record }) => {
                if (record.type == "Task" && record.name != "Milestone Complete") {
                  gantt.editTask(record);
                }
              },
              renderer: ({ action, record }) => {
                if (record.type == "Task" && record.name != "Milestone Complete") {                
                  return `<i class="b-action-item ${action.cls}"></i>`;
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
          type: "name",
          draggable: false,
          width: 250,
          editor: true,
          renderer: (record) => {
            populateIcons(record);
            if (record.record._data.type == "Phase") {
              record.record.readOnly = true;
              record.cellElement.style.marginLeft = "7px";
              return record.value;
            } else{
              record.cellElement.style.marginLeft = "0";
            }
            if (
              record.record._data.iconCls == "b-fa b-fa-arrow-right indentTrue"
            ) {
              record.cellElement.style.margin = "0 0 0 1.5rem";
            }
            if (record.record._data.name == "Milestone Complete") {
              record.record.readOnly = true;
              return "Milestone";
            }
            if (record.record._data.type == "Project") {
              record.record.readOnly = true;
              return record.record.name;
            } else {
              return record.value;
            }
          },
        },
        {
          type: "startdate",
          draggable: false,
          allowedUnits: "datetime",
        },
        {
          type: "enddate",
          allowedUnits: "datetime",
          draggable: false,
          // editor: false,
        },
        {
          type: "duration",
          draggable: false,
          allowedUnits: "day",
          renderer: function (record) {
            if (record.record._data.type == "Project") {
              let projectStartDate = new Date(record.record.startDate);
              let projectEndDate = new Date(record.record.endDate);
              let projectDuration = calcBusinessDays(projectStartDate, projectEndDate);
              console.log('projectDuration ',projectDuration);
              return projectDuration + ' days';
            }
            if (record.record._data.type == "Phase") {
              return record.record.duration+' days';
            }
            if (record.record._data.name == "Milestone Complete") {
              return record.record._data.duration+' days';
            } else {
              return record.record._data.duration+' days';
            }
          }
        },
        {
          type: "predecessor",
          draggable: false,
          width: 180,
          editor: false,
          renderer: (record) => {
            populateIcons(record);
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
          type: "widget",
          text: "Vendor",
          draggable: false,
          width: 180,
          widgets: [
            {
              type: "Combo",
              items: contractorComboData,
              name: "contractorId",
              listeners:{
                change : (event) => {
                  // Use a debounce mechanism to delay execution
                  if (this.debouncedChange) {
                    clearTimeout(this.debouncedChange);
                  }
                  this.debouncedChange = setTimeout(() => {
                    if (event.value != event.oldValue && this.taskRecordId != null && this.taskRecordId != undefined) {
                      project.taskStore.getById(this.taskRecordId).assignments = [];
                    }
                  }, 300);
                }
              },
            },
          ],
          renderer: (record) => {
            if (record.record._data.type == "Project") {
              return {class: 'd-none'};
            }
            else if (record.record._data.type == "Phase") {
              return {class: 'd-none'};
            }
            else if (record.record._data.name == "Milestone Complete") {
              return {class: 'd-none'};
            }
          },
        },
        {
          type : 'resourceassignment',
          width : 120,
          showAvatars : true,
          draggable : false,
          cellCls: 'custom-cell b-icon b-icon-picker',
          editor      : {
            picker : {
              height   : 350,
              width    : 450,
              selectionMode: {
                rowCheckboxSelection: true,
                multiSelect: true,
                showCheckAll: false,
              },
              features : {
                  filterBar  : true,
                  group      : 'resource.type',
                  headerMenu : false,
                  cellMenu   : false,
              },
            },
          },
          itemTpl : assignment => assignment.resourceName
        },
        // {
        //   type: "addnew",
        // },
        {
          type : 'eventcolor',
          text : 'Color'
        },
        {
          type: "action",
        draggable: false,
        // text    : 'Attach File',
        width: 30,
        actions: [
        {
              cls: "b-fa b-fa-paperclip",
        onClick: ({ record }) => {
        if (
        record._data.type == "Task" &&
        record._data.id.indexOf("_generate") == -1 &&
        record._data.name != "Milestone Complete"
        ) {
        this.showpopup = true;
        this.fileTaskId = record._data.id;
        }
              },
        renderer: ({ action, record }) => {
        if (
        record._data.type == "Task" &&
        record._data.id.indexOf("_generate") == -1 &&
        record._data.name != "Milestone Complete"
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
        draggable: false,
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
        record._data.id.indexOf("_generate") == -1 &&
        record._data.name != "Milestone Complete"
        ) {
        if (this.storeRes["" + record._data.id]["fileLength"]) {
        return `<i style="font-size:1.1rem;color:green;" class="b-action-item ${action.cls}" data-btip="File"></i>`;
        }
                  return `<i style="font-size:1.1rem;" class="b-action-item ${action.cls}" data-btip="File"></i>`;
        // return `<i class="b-action-item ${action.cls}" data-btip="File"></i>`;
        } else {
        return `<i class="b-action-item ${action.cls}" data-btip="File" style="display:none;"></i>`;
        }
              },
        },
        ],
        },
      ],

      subGridConfigs: {
        locked: {
          flex: 5,
        },
        normal: {
          flex: 4,
        },
      },

      columnLines: false,

      features: {
        cellTooltip : {
          tooltipRenderer : ({ record, column }) => record[column.field],
        },
        dependencyEdit : true,
        // dependencies : {radius:10},
        rowReorder: false,
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
        taskEdit: {
          items: {
            generalTab: {
              items: {
                // Remove "% Complete","Effort", and the divider in the "General" tab
                effort: false,
                // flex:5,
                startDate: {
                  weight: 100,
                },
                endDate: {
                  weight: 100,
                },
                // colorField: true,
                divider: false,
                manuallyScheduledField : {
                  type     : 'checkbox',
                  weight   : 1100,
                  name     : 'manuallyScheduled',
                  label    : 'Manually scheduled',
                  cls      : 'b-last-row',
                },
                newCustomField: {
                  type: "Combo",
                  weight: 200,
                  label: "Phase",
                  items: this.phaseNameList,
                  name: "NewPhase",
                },
              },
            },
            // Remove all tabs except the "General" tab
            successorsTab: false,
            resourcesTab: false,
            advancedTab: false,
          },
        },
        taskMenu: {
          items: {
            // Hide delete task option
            // deleteTask: false,
            indent: false,
            outdent: false,
            convertToMilestone: false,
            linkTasks: false,
            unlinkTasks: false,

            // Hide item from the `add` submenu
            add: {
              menu: {
                subtask: false,
                successor: false,
                predecessor: false,
                milestone: false,
              },
            },
          },
        },
        cellEdit: {
          editNextOnEnterPress: false,
          addNewAtEnd: false,
        },
        // indicators : {
        //     items : {
        //         deadlineDate   : false,
        //         earlyDates     : false,
        //         lateDates      : false,
        //         // display constraint indicators
        //         constraintDate : true
        //     }
        // },
      },

      listeners: {
        taskMenuBeforeShow({ record }) {
          // put your location here where you want to disable the task menu
          if (
            record._data.type == "Phase" ||
            record._data.type == "Project" ||
            record._data.customtype == "Milestone"
          ) {
            // return false to prevent showing the task menu
            return false;
          }
        },
          beforeTaskEditShow({ editor, taskRecord }) {
              editor.widgetMap.newCustomField.value = taskRecord._data.NewPhase;
              console.log(taskRecord._data);
              editor.widgetMap.manuallyScheduledField.value = taskRecord._data.manuallyScheduled;
              return true;
          }
      },

      taskRenderer({ taskRecord, renderData }) {
        if (taskRecord.isLeaf && !taskRecord.isMilestone) {
            // For leaf tasks we return some custom elements, described as DomConfig objects.
            // Please see https://bryntum.com/products/grid/docs/api/Core/helper/DomHelper#typedef-DomConfig for more information.
            return [
                {
                    tag   : 'div',
                    class : 'taskName',
                    html  : taskRecord.name
                }
            ];
        }
      },
    });

    gantt.on("cellClick", ({ record }) => {
      gantt.scrollTaskIntoView(record);
    });

    gantt.on('startCellEdit', (editorContext) => {
      if ( editorContext.editorContext.column.type == 'resourceassignment' ) {
        let contractorId = editorContext.editorContext.record._data.contractorId;
        editorContext.editorContext.editor.inputField.picker.onShow = ({source}) => {
          source.store.filter(record => (record.resource.type == 'Internal Resources' || record.resource.contractorId == contractorId));
        };
        // editorContext.editorContext.editor.inputField.store.filter(record => (record.resource.type == 'Internal Resources') || record.resource.contractorId == contractorId);
      }
    });

    gantt.on('beforeTaskChange', ({event}) => {
      console.log('beforeTaskChange ',event.record);
      var task = event.record;
      var resources = task.getResources();

      // Check if the task already has two resources assigned
      if (resources.length >= 2) {
        // Prevent adding or removing resources
        if (event.field === 'resources') {
          event.preventDefault();
        }
      }
    });

    gantt.callGanttComponent = this;

    gantt.on("link", function (event) {
      const linkType = event.record.type; // 'StartToEnd' or 'EndToStart'
      const sourceTask = event.sourceRecord;
      const targetTask = event.targetRecord;
      console.log("event fired ");

      if (linkType === "StartToEnd") {
        // Allow link creation for predecessors (Start of one task to End of another)
        // Perform the default action for linking tasks
      } else if (linkType === "EndToStart") {
        // Disable link creation for successors (End of one task to Start of another)
        event.preventDefault();
      }
    });

    //Resources data
    gantt.addListener("cellClick", (event) => {
      if (event.column.data.text == "Internal Resource") {
        if (event.target.id == "editInternalResource") {
          if (event.target.dataset.resource) {
            this.taskRecordId = event.record._data.id;
            this.showEditResourcePopup = true;
            console.log("taskReocrdId:=- " + this.taskRecordId);
            this.selectedContactApiName = "buildertek__Resource__c";
            this.selectedResourceContact = event.record._data.internalresource;
          }
        } else if (event.target.classList.contains("addinternalresource")) {
          this.taskRecordId = event.record._data.id;
          console.log("taskReocrdId:=- " + this.taskRecordId);
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
            console.log("taskReocrdId:=- " + this.taskRecordId);
            this.showContractor = true;
            this.selectedContactApiName = "buildertek__Contractor__c";
            this.selectedResourceAccount = event.record._data.contractoracc;
          }
        } else if (event.target.classList.contains("addcontractor")) {
          this.taskRecordId = event.record._data.id;
          console.log("taskReocrdId:=- " + this.taskRecordId);
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
            console.log("taskReocrdId:=- " + this.taskRecordId);
            this.selectedContactApiName = "buildertek__Contractor_Resource__c";
            this.selectedResourceContact =
              event.record._data.contractorresource;
          }
        } else if (event.target.classList.contains("addcontractorresource")) {
          this.taskRecordId = event.record._data.id;
          this.showEditResourcePopup = true;
          console.log("taskReocrdId:=- " + this.taskRecordId);
          this.selectedContactApiName = "buildertek__Contractor_Resource__c";
          this.selectedResourceContact = "";
        }
      }
      if (event.column.text == "Contractor") {
        this.taskRecordId = event.record.id;
      }

    //   if ((event.column.data.text == "Name") && (event.record.type == "Task") && (event.record.name != "Milestone Complete")) {
    //     this.navigateToRecordViewPage(event.record.id);
    //   }
    });

    gantt.on("expandnode", (source) => {
      // populateIcons(record);
      this.populateIconsOnExpandCollapse(source);
    });
    gantt.on("collapsenode", (source) => {
      // populateIcons(record);
      this.populateIconsOnExpandCollapse(source);
    });

    gantt.on("gridRowDrop", (record) => {
      console.log("event", {
        record,
      });
      console.log("log :- ", record._data.type);

      // Example logic: If the dropped record should be added as a child of the target record
      if (position === "child") {
        // Add the dropped record as a child of the target record
        targetRecord.appendChild(droppedRecord);
      }
    });

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
  }

  //* calling toast message method
  showToastMessage(message) {
    console.log("show toast message method");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Warning",
        message: message,
        variant: "warning",
      })
    );
  }

  //* calling this method on save changes
  saveChanges(scheduleData, taskData, dependenciesDatamap, assignedResources) {
    this.handleShowSpinner();
    let mergeTaskData = mergeArrays(taskData, assignedResources);

    let listOfRecordsToDelete = recordsTobeDeleted(
      this.scheduleItemsDataList,
      taskData
    ); //!helper method to get list of string to delete

    console.log("taskdata:- ", taskData);
    let projectTaskObj = {};
    var newtasklistafterid = [];
    mergeTaskData.forEach((newTaskRecord) => {
      var demoidvar = newTaskRecord.Id;
      var demoidvar2 = newTaskRecord.buildertek__Dependency__c;

      if (demoidvar != undefined || demoidvar != null) {
        if (demoidvar.includes("_generatedt_")) {
          delete newTaskRecord.Id;
        }
      }
      if (demoidvar2 != undefined || demoidvar2 != null) {
        if (demoidvar2.includes("_generatedt_")) {
          delete newTaskRecord.buildertek__Dependency__c;
        }
      }
      projectTaskObj[demoidvar] = newTaskRecord;
      newtasklistafterid.push(newTaskRecord);
    });

    console.log("mergeTaskData before apex:- ", mergeTaskData);
    var that = this;

    let childParentObj = {};
    dependenciesDatamap.forEach(element => {
      childParentObj[element.to] = element.from;
    });

    var id = this.SchedulerId
    console.log('recordId:- ',this.SchedulerId)

    upsertDataOnSaveChanges({
      scheduleRecordStr: JSON.stringify(scheduleData),
      taskRecordsStr: JSON.stringify(newtasklistafterid),
      listOfRecordsToDelete: listOfRecordsToDelete,
      childParentMap : childParentObj,
      projectTaskMap : projectTaskObj,
      updateorginaldates : this.setorignaldates,
      scheduleid : id
    })
      .then(function (response) {
        console.log("response ", {
          response,
        });
        console.log("response ", response);
        debugger;
        if (response == "Success") {
          that.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Save changes Successfully",
              variant: "success",
            })
          );
          let intervalID = setInterval(() => {
            window.location.reload();
          }, 1000);
        } else {
          that.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "Something Went Wrong",
              variant: "error",
            })
          );
          that.handleHideSpinner();
        }
        // that.connectedCallback();
        // that.getScheduleWrapperDataFromApex();
      })
      .catch((error) => {
        console.log("error --> ", {
          error,
        });
        this.isLoaded = false;
      });
  }

  hideModalBox(event) {
    console.log("event in parent ", event.detail.message);
    this.showExportPopup = event.detail.message;
  }

  hideModalBox1(event) {
    console.log("event in parent ", event.detail.message);
    this.showImportPopup = false;
  }

  exportData() {
    this.showExportPopup = true;
  }

  importtData() {
    this.showImportPopup = true;
  }

  handleShowSpinner() {
    // Set isLoading to true to show the spinner
    // this.isLoading = true;
    this.spinnerDataTable = true;
  }

  handleHideSpinner() {
    // Set isLoading to true to show the spinner
    // this.isLoading = false;
    this.spinnerDataTable = false;
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
  openOriginDateModal() {
    this.showOriginalDateModal = true;
  }

  closeModal() {
    this.showOriginalDateModal = false;
  }

  changeOriginalDate() {
    this.spinnerDataTable = true;
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
        that.spinnerDataTable = false;
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
        that.spinnerDataTable = false;
      });
  }
}