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
//import  SchedulerPro  from "@salesforce/resourceUrl/bryntumScheduleProModuleJS";
import GanttToolbarMixin from "./lib/GanttToolbar";
import GanttToolbarMixinDup from "./lib/GanttToolbarDup";
import data from "./data/launch-saas";

















import PARSER from "@salesforce/resourceUrl/PapaParse";

import { formatData, saveeditRecordMethod } from "./bryntum_GanttHelper";


import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";

export default class Gantt_component extends NavigationMixin(LightningElement) {
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
  @api mapOfWBSValue = [];
  //VARIABLE ADDED TO GET PHASE DATES - 09/10
  @api phaseDates = [];

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



  selectTargetValues;


  selectTargetTypeValues;

  picklistValues;

}